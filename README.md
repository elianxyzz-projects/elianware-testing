# CatVape CV modules — separate integration workspace

This repository contains the **CV integration groundwork** previously staged in `elianxyzz-projects/aeroclone`. The AeroV4 application and loader remain in [aeroclone](https://github.com/elianxyzz-projects/aeroclone).

## Isolated Elian testing loader

The new [loader.lua](loader.lua) is an experimental Elian script build placed **only in this testing repository**. It uses a separate `elianware_testing/` filesystem tree for settings, profiles, cached libraries, assets and GUI files, rather than AeroV4's `aerov4/` tree. Upstream Lua sources are rewritten before execution to use the test namespace, including shared runtime keys (`shared.elianTestingVape` instead of `shared.vape`). The default teleport reload URL points back to this repository.

**Testing status:** This has not been run in a Roblox executor, so full runtime isolation and compatibility are not yet verified. Existing AeroV4 settings are not imported into the new test folder, and the standard AeroV4 installation is not modified by this repository update. Running multiple clients simultaneously can still cause conflicts at the game-hook level even with separate profile storage.

## Files
- [Integration requirements](experimental/CATVAPE_CV_INTEGRATION.md): planned Hitreg Adjuster (CV), SilentAim (CV), and Hitboxes (CV) functionality, dependencies, and blockers.
- [Sword timing helper](experimental/cv_swordtiming.lua): standalone arithmetic routines; not a functional hit-registration module.
- [Dependency probe](experimental/cv_dependency_probe.lua): read-only checks for required APIs, not a functional module.

## Status
**Not a runnable CatVape replacement or three-module port.** The game-event adapters, entity hooks, and projectile targeting/interception integrations are not implemented or tested. Do not execute unknown or obfuscated code without inspecting and trusting its provenance.

The protected CatVape `cheatengine.lua` is **not** copied into this public repository. Do not redistribute third-party code unless its license or author permits it.

The original AeroV4 repo's `main` remains unchanged.
