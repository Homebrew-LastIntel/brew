# Homebrew-LastIntel / brew

Unofficial fork of [Homebrew/brew](https://github.com/Homebrew/brew). Not affiliated with or endorsed by Homebrew. The beer-mug logo and the text below the line are upstream's. Donations linked there go to the upstream project.

This repository is the package manager. It is BSD-2-Clause. The copyright notice in `LICENSE.txt` stays with the Homebrew contributors.

## Goals

Keep `brew` running on Intel Macs, and keep taking upstream's new work.

- The Intel baseline is commit [`518895ab7be7407523990f86eb6a1a53eb35a72f`](https://github.com/Homebrew/brew/commit/518895ab7be7407523990f86eb6a1a53eb35a72f), the parent of pull request 23679, merged 2026-09-01. That is the last client commit before Intel was marked Tier 3. Release **6.0.20** (2026-08-27) is the last release cut while Intel bottles were still being built.
- This fork started from upstream `main` at `8a17c2078a1a2f91248915546216783978399e0c` (2026-10-31). The newest release tag then was [7.0.11](https://github.com/Homebrew/brew/releases/tag/7.0.11) (`c6069d2a943b`, 2026-10-26), which is behind that `main`. We do not boot 6.0.20 as the daily client. Formulae published since Homebrew 7.0.0 need the current client.
- Each upstream change is merged. If it removes an Intel behavior that existed at the baseline, that behavior is put back. New features that are not tied to Apple Silicon come with the merge.
- Sandbox, bottle attestations, tap trust, and `brew vulns` stay on. This fork does not document turning them off.
- macOS Tahoe 26 is the last macOS that runs on Intel. macOS 27 Golden Gate does not boot on these CPUs. This fork will not claim that it does.

Upstream stopped routine Intel bottles on 2026-08-28 because their Sonoma x86_64 CI virtual machines went from seconds of setup to more than two hours and blocked the rest of the queue. They said so on [discussion 7044](https://github.com/orgs/Homebrew/discussions/7044). Apple ended Intel hardware at Tahoe 26. GitHub is removing Intel Mac runners in fall 2027. Those are the limits. The client still runs on Intel today.

## What this repo does not do

- It does not fork `homebrew-core` or `homebrew-cask`. Formulae and casks stay on Homebrew's API at `https://formulae.brew.sh`.
- It does not rebuild all 8,687 formulae. A missing Intel bottle compiles from source when the upstream project still supports `x86_64-apple-darwin`.
- It does not rehost upstream bottles or cask binaries.
- It does not ship a `curl | bash` installer.

## Install on an Intel Mac

The official script at `Homebrew/install` aborts on macOS unless `uname -m` is `arm64`. Use git. You need macOS 15 or 26, the Xcode Command Line Tools, git, and an admin account. `/usr/local` is the Intel prefix. Do not install this fork into `/opt/homebrew`. That prefix is for Apple Silicon bottles and is too long for existing Intel bottles.

These commands create Homebrew's own directories. They do not delete Node, the .NET SDK, Tailscale, MacPorts, or anything else already under `/usr/local`.

```bash
sudo mkdir -p /usr/local/Homebrew /usr/local/Cellar /usr/local/Caskroom /usr/local/Frameworks
sudo chown "$(whoami):admin" /usr/local/Homebrew /usr/local/Cellar /usr/local/Caskroom /usr/local/Frameworks
git clone https://github.com/Homebrew-LastIntel/brew.git /usr/local/Homebrew
ln -sfn /usr/local/Homebrew/bin/brew /usr/local/bin/brew
brew update
brew config
brew doctor
```

`brew config` should show an Intel CPU and prefix `/usr/local`. `brew doctor` may still warn that upstream treats Intel as Tier 3. That warning is not a failed install. Do not set `HOMEBREW_NO_VERIFY_ATTESTATIONS`, `HOMEBREW_NO_SANDBOX`, or `HOMEBREW_NO_REQUIRE_TAP_TRUST`.

`/usr/local/bin` is on the default macOS `PATH`. If `brew` is not found, add this one line to `~/.zprofile` and open a new terminal:

```bash
eval "$(/usr/local/bin/brew shellenv)"
```

## Stay current with upstream

From the checkout:

```bash
cd /usr/local/Homebrew
git remote add upstream https://github.com/Homebrew/brew.git
git fetch upstream
git merge upstream/main
```

Resolve conflicts by keeping upstream's feature and putting the Intel behavior back. If a commit only builds with the macOS 27 SDK, stop on the previous commit and record the SHA. Do not delete sandbox or attestation code to force the merge.

Push fork work to `Homebrew-LastIntel/brew`. Open a pull request. Do not push the fork's commits to `Homebrew/brew`.

## Install a package

```bash
brew install <formula>
```

If no Intel bottle exists, `brew` compiles from source. That is the fallback upstream added when they turned the Intel builders off. A package whose own project removed `x86_64-apple-darwin` will fail that compile. The formula cannot invent the source.

Casks install the vendor's build. If the vendor ships only Apple Silicon, the cask will not gain an Intel app from this fork.

## Layout of the other repositories

| Repository | What it is |
| --- | --- |
| [Homebrew-LastIntel/brew](https://github.com/Homebrew-LastIntel/brew) | This client. |
| [Homebrew-LastIntel/BrewUI](https://github.com/Homebrew-LastIntel/BrewUI) | Fork of the official Mac GUI. AGPL-3.0. |
| [Homebrew-LastIntel/homebrew-lastintel](https://github.com/Homebrew-LastIntel/homebrew-lastintel) | Notes, checks, and the short list of formulae we had to adjust. |

---

The upstream README follows.

# 🍺 Homebrew

[![Latest GitHub release](https://img.shields.io/github/release/Homebrew/brew.svg)](https://github.com/Homebrew/brew/releases)
[![BSD-2-Clause License](https://img.shields.io/github/license/Homebrew/brew)](https://github.com/Homebrew/brew/blob/HEAD/LICENSE.txt)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/homebrew?label=GitHub%20Sponsors)](https://github.com/sponsors/Homebrew)
[![Open Collective backers and sponsors](https://img.shields.io/opencollective/all/homebrew?label=Open%20Collective)](https://opencollective.com/homebrew)

See [Homebrew's homepage at `brew.sh`](https://brew.sh) for installation instructions, what homebrew does, packages, `brew bundle` and more.

<img src="https://brew.sh/assets/img/brew-install.gif" alt="Homebrew install demo" width="580" height="424">

## 💸 Donations

Homebrew is a non-profit project run entirely by volunteers, not employees.
We need your funds to pay for software, hardware and hosting around continuous integration and future improvements to the project.
Every donation will be spent on making Homebrew better for our users.

Please consider a regular donation through [GitHub Sponsors](https://github.com/sponsors/Homebrew), [Open Collective](https://opencollective.com/homebrew) or [Patreon](https://www.patreon.com/homebrew).
Homebrew is fiscally hosted by the [Open Source Collective](https://opencollective.com/opensource).

## 📚 Documentation

Read the Homebrew manual with [`man brew`](https://docs.brew.sh/Manpage).

Read [installation](https://docs.brew.sh/Installation),
[troubleshooting](https://docs.brew.sh/Troubleshooting),
[contribution](https://github.com/Homebrew/brew/blob/HEAD/docs/How-To-Open-a-Homebrew-Pull-Request.md)
including the [FAQ](https://docs.brew.sh/FAQ) on [`docs.brew.sh`](https://docs.brew.sh/).

Read the [Homebrew Blog](https://brew.sh/blog/) for release notes, project updates and announcements.

## 📦 Packages
Find [formulae](https://formulae.brew.sh/formula/), [casks](https://formulae.brew.sh/cask/), dependencies, versions and package metadata on [`formulae.brew.sh`](https://formulae.brew.sh).

View anonymised install, build and operating system usage data at [`formulae.brew.sh/analytics`](https://formulae.brew.sh/analytics/).
Read how Homebrew uses [Anonymous Analytics](https://docs.brew.sh/Analytics).

## 🔧 Get Help

First, please run `brew update` and run (and **read**) `brew doctor`.

Second, read the [Troubleshooting Checklist](https://docs.brew.sh/Troubleshooting).

**If you don't read these it will take us far longer to help you with your problem.**

After this, if you still need help, please ask in
[Homebrew/discussions](https://github.com/orgs/Homebrew/discussions)
or follow (and **read**) the
[Homebrew/brew new issue chooser](https://github.com/Homebrew/brew/issues/new/choose).

## 💬 Social

Follow Homebrew on [Mastodon](https://fosstodon.org/@homebrew),
[Bluesky](https://bsky.app/profile/brew.sh),
[𝕏 (Twitter)](https://x.com/MacHomebrew) or subscribe to the
[newsletter](https://buttondown.email/homebrew).

## 🤝 Contributing

We'd love you to join us and >10,000 others by contributing to Homebrew!

First, please read our [Contribution Guide](CONTRIBUTING.md) and [Code of Conduct](https://github.com/Homebrew/.github/blob/HEAD/CODE_OF_CONDUCT.md#code-of-conduct).

A good starting point for contributing is:

- `brew tap --force homebrew/core` or `brew tap --force homebrew/cask` (depending on whether you'd rather work on formulae or casks)
- perform a strict audit on a package you use e.g. `brew audit --strict ffmpeg` for FFmpeg
- if no warnings, run `brew audit --strict` to run on all packages and pick one to fix
- read through the warnings and fix them until `brew audit --strict <package>` shows no results
- [submit a pull request](https://docs.brew.sh/How-To-Open-a-Homebrew-Pull-Request) with your fixes

Alternatively, for something more substantial, check out one of the open issues in
[Homebrew/brew](https://github.com/homebrew/brew/issues),
[Homebrew/homebrew-core](https://github.com/homebrew/homebrew-core/issues) or
[Homebrew/homebrew-cask](https://github.com/homebrew/homebrew-cask/issues).

If you've had inspiration for a new feature or bug fix: we don't need you to open an issue first, just [open a pull request](https://docs.brew.sh/How-To-Open-a-Homebrew-Pull-Request) with your implementation and we'll review it.

Good luck!

## 🔐 Security

Please see [our security policy](https://github.com/Homebrew/.github/blob/HEAD/SECURITY.md) for how to report security issues and what is in scope.

## 👥 Who We Are

Homebrew's [Project Leader](https://docs.brew.sh/Homebrew-Governance#project-leader) is [Mike McQuaid](https://github.com/MikeMcQuaid).

Homebrew's [Lead Maintainers](https://docs.brew.sh/Homebrew-Governance#lead-maintainer) are [Bevan Kay](https://github.com/bevanjkay), [Carlo Cabrera](https://github.com/carlocab), [Issy Long](https://github.com/issyl0), [Justin Krehel](https://github.com/krehel), [Michael Cho](https://github.com/cho-m), [Mike McQuaid](https://github.com/MikeMcQuaid), [Nanda H Krishna](https://github.com/nandahkrishna), [Patrick Linnane](https://github.com/p-linnane), [Rui Chen](https://github.com/chenrui333), [Ruoyu Zhong](https://github.com/ZhongRuoyu), [Sam Ford](https://github.com/samford) and [Sean Molenaar](https://github.com/SMillerDev).

Homebrew's other Maintainers are [Andrew Nesbitt](https://github.com/andrew), [Anton Melnikov](https://github.com/botantony), [Bo Anderson](https://github.com/Bo98), [Branch Vincent](https://github.com/branchv), [Caleb Xu](https://github.com/alebcay), [Daeho Ro](https://github.com/daeho-ro), [Douglas Eichelberger](https://github.com/dduugg), [Dustin Rodrigues](https://github.com/dtrodrigues), [FX Coudert](https://github.com/fxcoudert), [Klaus Hipp](https://github.com/khipp), [Markus Reiter](https://github.com/reitermarkus), [Michka Popoff](https://github.com/iMichka), [Štefan Baebler](https://github.com/stefanb), [Thierry Moisan](https://github.com/Moisan) and [William Woodruff](https://github.com/woodruffw).

Homebrew was originally created by [Max Howell](https://github.com/mxcl).

## 📜 License

Code is under the [BSD 2-clause "Simplified" License](LICENSE.txt).
Documentation is under the [Creative Commons Attribution license](https://creativecommons.org/licenses/by/4.0/).

## 💛 Sponsors

Our macOS continuous integration infrastructure is hosted by [MacStadium's Orka](https://www.macstadium.com/customers/homebrew).

[![Powered by MacStadium](https://cloud.githubusercontent.com/assets/125011/22776032/097557ac-eea6-11e6-8ba8-eff22dfd58f1.png)](https://www.macstadium.com)

Secure password storage and syncing is provided by [1Password for Teams](https://1password.com/teams/).

[<img src="https://i.1password.com/akb/featured/1password-icon.svg" alt="1Password" height="64">](https://1password.com)

<https://brew.sh>'s DNS is [resolving with DNSimple](https://dnsimple.com/resolving/homebrew).

[![DNSimple](https://cdn.dnsimple.com/assets/resolving-with-us/logo-light.png)](https://dnsimple.com/resolving/homebrew#gh-light-mode-only)
[![DNSimple](https://cdn.dnsimple.com/assets/resolving-with-us/logo-dark.png)](https://dnsimple.com/resolving/homebrew#gh-dark-mode-only)

Homebrew is generously supported by [Joshua Baer](https://github.com/joshuabaer), [Randy Reddig](https://github.com/ydnar), [Codecademy](https://github.com/Codecademy), [Gusto](https://github.com/Gusto), [b.well](https://github.com/icanbwell), [Workbrew](https://github.com/Workbrew), [GitHub](https://github.com/github) and many other users and organisations via [GitHub Sponsors](https://github.com/sponsors/Homebrew).

[![GitHub](https://github.com/github.png?size=64)](https://github.com/github)
