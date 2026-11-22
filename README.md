# CatVape CV modules — separate integration workspace

This repository contains the **CV integration groundwork** previously staged in `elianxyzz-projects/aeroclone`. The AeroV4 application and loader remain in [aeroclone](https://github.com/elianxyzz-projects/aeroclone).

## Files
- [Integration requirements](experimental/CATVAPE_CV_INTEGRATION.md): planned Hitreg Adjuster (CV), SilentAim (CV), and Hitboxes (CV) functionality, dependencies, and blockers.
- [Sword timing helper](experimental/cv_swordtiming.lua): standalone arithmetic routines; not a functional hit-registration module.
- [Dependency probe](experimental/cv_dependency_probe.lua): read-only checks for required APIs, not a functional module.

## Status
**Not a runnable CatVape replacement or three-module port.** The game-event adapters, entity hooks, and projectile targeting/interception integrations are not implemented or tested. Do not execute unknown or obfuscated code without inspecting and trusting its provenance.

The protected CatVape `cheatengine.lua` is **not** copied into this public repository. Do not redistribute third-party code unless its license or author permits it.

The original AeroV4 repo's `main` remains unchanged.
