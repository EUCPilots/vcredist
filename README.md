# VcRedist

[![License][license-badge]][license]
[![PowerShell Gallery Version][psgallery-version-badge]][psgallery]
[![PowerShell Gallery][psgallery-badge]][psgallery]

[![Master build status][appveyor-badge]][appveyor-build]
[![Development build status][appveyor-badge-dev]][appveyor-build]

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/556b5c464f6a4981b357cbb0cae230c5)](https://app.codacy.com/manual/aaronparker/VcRedist?utm_source=github.com&utm_medium=referral&utm_content=aaronparker/VcRedist&utm_campaign=Badge_Grade_Dashboard)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/2f7df6d226c9404daad08890aa006ed7)](https://www.codacy.com/manual/aaronparker/VcRedist?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=aaronparker/VcRedist&amp;utm_campaign=Badge_Grade)

## About

VcRedist is a PowerShell module for lifecycle management of the [Microsoft Visual C++ Redistributables](https://support.microsoft.com/en-au/help/2977003/the-latest-supported-visual-c-downloads). VcRedist downloads the supported (and unsupported) Redistributables, for local install, master image deployment or importing as applications into the Microsoft Deployment Toolkit or Microsoft Endpoint Configuration Manager. Supports passive and silent installs and uninstalls of the Visual C++ Redistributables.

### Visual C++ Redistributables

The Microsoft Visual C++ Redistributables are a core component of any Windows desktop deployment. Because multiple versions are often deployed they need to be imported into your deployment solution or installed locally, which can be time consuming. The aim of this module is to reduce the time required to import the Redistributables or install them locally.

### Documentation

Full documentation for the module is located at [https://docs.stealthpuppy.com/vcredist/](https://docs.stealthpuppy.com/vcredist/)

### PowerShell Gallery

The VcRedist module is published to the PowerShell Gallery and can be found here: [VcRedist](https://www.powershellgallery.com/packages/VcRedist/). Install the module from the gallery with:

```powershell
Install-Module -Name VcRedist -Force
```

[appveyor-badge]: https://img.shields.io/appveyor/ci/aaronparker/Install-VisualCRedistributables/master.svg?style=flat-square&logo=appveyor&label=master
[appveyor-badge-dev]: https://img.shields.io/appveyor/ci/aaronparker/Install-VisualCRedistributables/development.svg?style=flat-square&logo=appveyor&label=development
[appveyor-build]: https://ci.appveyor.com/project/aaronparker/install-visualcredistributables
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/vcredist.svg?logo=PowerShell&style=flat-square
[psgallery]: https://www.powershellgallery.com/packages/vcredist
[psgallery-version-badge]: https://img.shields.io/powershellgallery/v/vcredist.svg?logo=PowerShell&style=flat-square
[psgallery-version]: https://www.powershellgallery.com/packages/vcredist
[license-badge]: https://img.shields.io/github/license/aaronparker/Install-VisualCRedistributables.svg?style=flat-square
[license]: https://github.com/aaronparker/vcredist/blob/master/LICENSE
