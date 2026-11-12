# Continuous Integration scripts

Scripts used during workflows to validate this project.

The manifest update workflow runs x86 and x64 checks on an AMD64 runner, then ARM64 checks on an ARM64 runner. The update script skips entries not supported by the runner's native architecture and fails if a compatible installation cannot be found.

## Release process

Follow the [release process runbook](../docs/release-process.md) for branch creation,
commits and PRs, beta iterations, stable promotion, workflow inputs, approvals, and
recovery. Release preparation creates a versioned PR; merging it does not publish.
Publishing validates the merged commit and requires environment approval.

Existing tags also trigger publishing, but cannot bypass ancestry, metadata, tests or approval. Manual publishing from development branches is rejected. Publishing never bumps the version.

### Validation

[validate-module.yml](../.github/workflows/validate-module.yml) runs for branch pushes and PRs to `main` that change `VcRedist/**` or `tests/**`. Documentation/workflow-only changes require manual dispatch; see the [trigger exception](../docs/release-process.md#2-develop-commit-and-merge-a-pr). It is also reusable by publishing. It stages an immutable module artifact before testing; all four Windows runner/shell combinations test those files. The analyzer is a reusable required job, not just a SARIF report. Obsolete CI runs may be cancelled manually; releases are serialized and never automatically cancelled.

Pester is pinned to **5.7.1**, PSScriptAnalyzer to **1.25.0**, MSAL.PS to **4.37.0.0**, IntuneWin32App to **1.5.0**, and publishing uses PowerShellGet **2.2.5**. Dependency installation fails explicitly. Secret-free validation excludes `Intune`-tagged live tests; these run separately on manual request or during publishing. Architecture-specific tests retain their existing skips. Both failed tests and incomplete module-test discovery fail the gate: every script must have two validation cases, every function two cases, plus the two metadata checks.

Run the shared test entry point on a disposable Windows machine: the existing integration suite installs and uninstalls redistributables and MDT.

```powershell
./ci/Test-Module.ps1
./ci/Test-Module.ps1 -Intune -ResultName intune
```

Focused release/helper checks (no installation of redistributables):

```powershell
./tests/Install-Pester.ps1
Import-Module ./VcRedist/VcRedist.psd1 -Force
Invoke-Pester -Path ./tests/Module.Tests.ps1, ./tests/CI
```

### GitHub configuration

* Protect `main`: require PRs and the **Validation gate** check from GitHub Actions, require up-to-date branches, dismiss stale reviews, resolve conversations, enforce restrictions for administrators, and disallow force-pushes/deletion. Review approval is optional for a solo maintainer; publishing approval is mandatory.
* Create the `powershell-gallery` environment with a required maintainer reviewer and deployment policies permitting `main` and `v*` tags only. Allow the initiating maintainer to approve their own release if there is no second maintainer. Disable administrator bypass.
* Store `NUGETAPIKEY` in that environment, not as a repository-wide secret. It must belong to an owner of the Gallery module.
* Configure `PAT` with repository contents and pull-request write access (or replace it with a GitHub App installation token). Release branch pushes and PR creation use this token so GitHub actually triggers validation; ordinary `GITHUB_TOKEN` pushes would suppress those events.
* Release preparation retains signed commits and requires `GPGKEY`, `GPGPASSPHRASE`, `COMMIT_NAME`, and `COMMIT_EMAIL`.
* Live Intune tests require `TENANT_ID`, `CLIENT_ID`, and `CLIENT_SECRET`. They are never passed to ordinary PR/branch tests.

Repository settings are not installed by merging YAML. Configure and verify them separately. Do not enable publishing until the new workflows are merged and required checks have run successfully.

### Versioning and recovery

Versions have three numeric components without leading zeros. Prerelease labels are lowercase letters/digits beginning with a letter; labels at the same numeric version follow ordinal SemVer ordering (`beta1` before `beta2`, then stable). To avoid lexical surprises such as `beta10` sorting before `beta2`, use consistent zero-padded labels when more than nine prereleases are expected. Stable-to-prerelease regression and duplicate/lower releases are rejected during preparation.

Documentation is generated directly from the bundled redistributable JSON, supporting both the v4 and v5 schemas; no remote manifest can change a release's documentation.

If publishing fails, keep the tag on its original commit and rerun **all jobs** of the same workflow (to recreate its staged artifact if necessary). An existing Gallery version is accepted only if every module file matches the validated artifact and there are no unexpected module files. A conflicting package fails explicitly and requires a new release version. A successful publication followed by failed GitHub finalization is recoverable without republishing. GitHub releases remain drafts until Gallery verification succeeds.
