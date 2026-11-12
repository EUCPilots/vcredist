# Release process

This runbook covers a development branch and PR, beta publication, and a new stable
(production) version. Run commands from the repository root. Examples use `5.1.0`;
choose a version newer than the current [module manifest](../VcRedist/VcRedist.psd1)
and check existing GitHub releases and Gallery packages before starting.

## What is manual and what is automatic?

| Stage | Manual action | Automatic result |
| --- | --- | --- |
| Development | Create a branch, change code/tests/help, update the changelog, commit, push, and open a PR to `main`. | Pushes and PRs changing `VcRedist/**` or `tests/**` run **Validate module**. No version bump or publication occurs. |
| Development merge | Review the PR, confirm **Validation gate** passes, and merge. | Matching changes on `main` run validation again. Merging does not publish. |
| Release preparation | Dispatch **Prepare module release** on `main` with `version`, `prerelease`, and `issue`. | Updates release metadata/docs, runs focused tests, signs and pushes a commit on `release/<full-version>`, and opens a PR to `main`. |
| Release PR | Review generated files, wait for **Validation gate**, and merge. | Validates the release branch/PR and matching changes merged to `main`. No tag or package is created yet. |
| Publication request | Dispatch **Publish module to PowerShell Gallery** on `main` with the exact `tag` and optionally `commit`. | Checks metadata and ancestry, stages the module, and runs the full validation matrix plus live Intune tests for that exact commit. |
| Publication approval | Approve the pending deployment in the `powershell-gallery` environment. | Creates the exact tag and draft GitHub release, publishes the tested artifact, verifies Gallery contents, then makes the GitHub release public. Beta releases are marked as prereleases. |
| Stable promotion | Prepare and publish a stable release separately, leaving `prerelease` empty. | Removes the beta label and repeats the release PR, validation, approval, and publication process. There is no automatic beta-to-stable promotion. |

Source workflows: [validation](../.github/workflows/validate-module.yml),
[preparation](../.github/workflows/update-module.yml), and
[publishing](../.github/workflows/publish-module.yml).

## 1. Check prerequisites

* Authenticate `gh` with access to this repository. Release preparation requires
  an **open GitHub issue**; create or identify it before starting.
* Verify the protections, environment approval, and secrets in
  [CI configuration](../ci/README.md#github-configuration). Merging workflow YAML
  does not configure repository settings. The required reviewer must be configured
  for publication to actually pause for approval.
* Use disposable Windows machines for local integration tests: they download,
  install, and uninstall redistributables and MDT. Both Windows PowerShell 5.1 and
  PowerShell 7 are supported; there is no build step.
* Do not manually bump `ModuleVersion`, set `PSData.Prerelease`, or push release
  tags as part of ordinary development. Preparation owns version changes;
  publishing never changes the version.

## 2. Develop, commit, and merge a PR

Start with a clean worktree; preserve any existing local work before switching.

```shell
git switch main
git pull --ff-only origin main
git switch -c feature/release-change
```

Make the implementation, tests, and directly related help/documentation changes.
Add release notes under exactly one `## VERSION` heading at the top of
[the changelog](./changelog.md). The section must be nonempty. If the preceding
release consumed that heading, add a new one above its numbered section; preserve
the published history.

On Windows, run validation appropriate to the change:

```powershell
# Full secret-free validation, including coverage and test-discovery checks:
./ci/Test-Module.ps1

# Analyzer (also required by CI):
./ci/Install-Analyzer.ps1
Invoke-ScriptAnalyzer -Path ./VcRedist -Recurse -Settings ./.rules/PSScriptAnalyzerSettings.psd1
```

Use focused Pester tests during development; see [CI validation](../ci/README.md#validation).
Live Intune tests are not part of ordinary branch/PR validation.

Review and stage only intended changes, then commit and push:

```shell
git diff --check
git diff
git add --patch
git diff --cached
git commit -m "Describe the change" -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
git push --set-upstream origin feature/release-change
gh pr create --base main --head feature/release-change
```

Add any new files explicitly with `git add <path>`; `git add --patch` does not
stage untracked files. In the interactive PR flow, use
[the PR template](../.github/PULL_REQUEST_TEMPLATE.md), link the open issue,
describe test commands/results and the environment, and complete the applicable
checklist items. Keep a release-tracking issue open until the final release;
use `Related to #<issue>` rather than an auto-closing reference if reusing it for
release preparation.

Wait for **Validation gate**, review, and merge through the PR. If further changes
are needed, commit and push them to the same branch and wait for fresh checks.
Do not push directly to `main`.

**Trigger exception:** the validation workflow's push/PR path filters only match
`VcRedist/**` and `tests/**`. Documentation-, CI-script-, or workflow-only changes
do not automatically run it. You can manually validate the selected branch:

```shell
gh workflow run validate-module.yml --ref feature/release-change -f run_intune=false
```

Check that branch protection recognizes the required check for the PR's current
commit. A manual branch run is not a PR event; if a required check remains
pending, resolve that with the repository maintainer rather than bypassing it or
assuming a missing run passed.

## 3. Prepare the beta release

After development and the nonempty `## VERSION` notes are merged into `main`,
open **Actions > Prepare module release > Run workflow**.

| Input | Beta example | Meaning |
| --- | --- | --- |
| Use workflow from | `main` | Required branch; other branches are rejected. |
| `version` | `5.1.0` | Exactly three numeric components, without `v`, a suffix, or leading zeros. |
| `prerelease` | `beta1` | Lowercase letters/digits, starting with a letter. Do not include a hyphen. |
| `issue` | `123` | Replace with an actual open release issue number; `#123` is also accepted. |

CLI equivalent (replace `123`):

```shell
gh workflow run update-module.yml --ref main -f version=5.1.0 -f prerelease=beta1 -f issue=123
```

The workflow automatically:

1. Checks the branch, automation token, and open issue.
2. Sets `ModuleVersion` to `5.1.0`, sets `PSData.Prerelease` to `beta1`, and
   refreshes the public function exports in the module manifest.
3. Renames `## VERSION` to `## 5.1.0-beta1` and regenerates
   [redistributable version documentation](./versions.md) from the **bundled**
   JSON, not the remote manifest.
4. Runs module metadata and release-helper tests.
5. Creates a signed commit changing the module manifest, changelog, and version
   documentation on `release/5.1.0-beta1`, pushes it, and opens a release PR.

Review those three files and the generated PR description/checklist, wait for
**Validation gate**, and merge. Preparation does not tag or publish. Do not
re-run preparation to create another commit for the same version if its branch
already exists; use the existing release PR.

## 4. Publish and approve the beta

Identify the **merged commit on `main`**, not the release branch head before
merging. This distinction matters for squash and rebase merges.

Open **Actions > Publish module to PowerShell Gallery > Run workflow**:

| Input | Beta example | Meaning |
| --- | --- | --- |
| Use workflow from | `main` | Manual dispatch from development branches is rejected. |
| `tag` | `v5.1.0-beta1` | Must exactly match the manifest's full version, prefixed with `v`. |
| `commit` | Full 40-character merged SHA | Optional; empty uses the `main` commit selected when dispatching. Pin the SHA if `main` has moved since the release PR merged. |

CLI equivalent (replace the SHA placeholder):

```shell
gh workflow run publish-module.yml --ref main -f tag=v5.1.0-beta1 -f commit=<full-merged-main-sha>
```

Replace angle-bracket placeholders before running commands. Alternatively, with
the clean checkout on the intended merged release commit:

```powershell
./ci/Push-Tag.ps1
```

Despite its name, this helper **dispatches publishing** with the local manifest's
tag and `HEAD` SHA; it does not push a tag. Local uncommitted changes are not
published.

Watch the run in Actions. Before approval, it checks that the commit belongs to
`main`, the tag matches the manifest, exports match public functions, and release
notes/version documentation match the release. Any existing tag must point to
the same commit. It stages a `release-candidate` artifact and runs:

* Pester on `windows-2025` and `windows-11-arm`, each with `powershell` and `pwsh`.
* PSScriptAnalyzer as a required job.
* Live Intune tests using `TENANT_ID`, `CLIENT_ID`, and `CLIENT_SECRET`.
* The aggregate **Validation gate**.

Once validation passes, manually approve the pending `powershell-gallery`
deployment in the run's **Review deployments** UI. After approval, the workflow:

1. Validates the staged package again.
2. Creates `v5.1.0-beta1` at the validated SHA and a draft prerelease.
3. Publishes that tested artifact with the environment's `NUGETAPIKEY`.
4. Downloads the Gallery package and checks all module files and their hashes,
   rejecting missing, changed, or unexpected module files.
5. Finalizes the GitHub prerelease with changelog notes, validated SHA, and run URL.

Manually confirm the run succeeded, the GitHub prerelease points to the intended
commit, and the Gallery beta is available. On a disposable Windows test machine,
install the exact beta and test the scenarios changed:

```powershell
Install-Module -Name "VcRedist" -RequiredVersion "5.1.0-beta1" -AllowPrerelease -Scope "CurrentUser" -Force
```

## 5. Iterate on betas, then release to production

For beta fixes, repeat the development branch/PR steps, including a fresh nonempty
`## VERSION` section. Prepare `version=5.1.0`, `prerelease=beta2`, merge the new
release PR, then publish `tag=v5.1.0-beta2` and approve again.

Versions must advance relative to the manifest. At the same numeric version,
prerelease labels use ordinal ordering: `beta1`, `beta2`, then stable is valid,
but `beta10` sorts before `beta2`. Use a consistent padded scheme such as
`beta01`, `beta02`, ... from the first beta if more than nine are expected.
After a stable version, the next beta must increase the numeric version.

When beta testing is complete:

1. Merge any final fixes and a **new nonempty `## VERSION` section** through a
   development PR. Include the stable release summary, even if no code changed
   since the beta. Do not rename or delete the beta's historical notes.
2. Dispatch preparation on `main` with the same numeric version and an **empty**
   prerelease label, using an open release issue:

   ```shell
   gh workflow run update-module.yml --ref main -f version=5.1.0 -f prerelease= -f issue=123
   ```

3. Review and merge `release/5.1.0` after **Validation gate** passes. Preparation
   removes `PSData.Prerelease`, titles the new notes `5.1.0`, and regenerates the
   version documentation.
4. Dispatch publishing on `main` with `tag=v5.1.0` and the full merged stable SHA:

   ```shell
   gh workflow run publish-module.yml --ref main -f tag=v5.1.0 -f commit=<full-merged-main-sha>
   ```

5. Wait for all validation, including live Intune tests, and approve deployment
   again. The workflow publishes a **new stable package** and finalizes a
   non-prerelease GitHub release. It does not relabel or overwrite the beta.
6. Confirm the stable Gallery package and GitHub release, then smoke-test:

   ```powershell
   Install-Module -Name "VcRedist" -RequiredVersion "5.1.0" -Scope "CurrentUser" -Force
   ```

7. Record the outcome and close the release issue manually when complete.

## Other workflows and recovery

* **Validate module**: manual input `run_intune` defaults to `false`; set it to
  `true` for live Intune validation on a trusted branch. Publishing always requests
  these tests; ordinary PR validation does not receive the tenant secrets.
* **Run PSScriptAnalyzer**: manually dispatch
  [analyzer.yml](../.github/workflows/analyzer.yml) on the desired branch; no custom
  manual inputs. It also runs automatically inside validation.
* **Update module manifest**:
  [update-manifest.yml](../.github/workflows/update-manifest.yml) runs daily at
  **18:00 UTC**, on pushes changing `ci/Update-Manifest.ps1`, or manually with no
  custom inputs. It checks redistributables, commits detected JSON changes on
  `manifest-update`, and creates/updates a PR when possible (`PAT` is required for
  new PR creation). Review/merge and ensure validation runs; its `GITHUB_TOKEN`
  pushes do not themselves trigger further workflows. This updates redistributable
  data, **not** the module's release version, tag, or Gallery package.
* A pushed `v*` tag also triggers publishing, but cannot bypass ancestry,
  metadata, tests, or environment approval. Prefer manual publishing and let it
  create the tag after validation.
* Preparation requires `## VERSION`; publishing requires the **numbered version**
  as the first changelog release. A new `## VERSION` or changed bundled JSON after
  preparation can make a later `main` commit unsuitable for publishing. Pin the
  intended merged release SHA rather than assuming the latest `main` is releasable.
* Preparation and publishing each serialize their runs and do not automatically
  cancel an in-progress release. Avoid duplicate dispatches.
* If preparation pushed its branch but PR creation failed, open the PR manually
  from that branch rather than rerunning preparation.
* If publishing fails, keep the tag on its original commit and **re-run all jobs
  of the same run** (for example `gh run rerun <run-id>`), not only failed jobs.
  The staged artifact expires after seven days; rerunning all jobs recreates it.
  Approval is required again when the environment job is reached.
* An existing Gallery version is reused only when every module file matches the
  tested artifact and no unexpected module files exist. A conflict requires a new
  version and release PR; never overwrite a package or move its tag.
* If Gallery publication succeeded but GitHub finalization failed, the same retry
  verifies the existing package and completes finalization without republishing.
  New GitHub releases remain drafts until Gallery verification succeeds.
