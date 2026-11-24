# Elianware Testing

The experimental development workspace for [Elianware](https://github.com/elianxyzz-projects/elianware). New modules, interface changes and diagnostics are developed here before promotion to the main project.

## Experimental features

- FallDamageHUD — estimates upcoming drops, with Safe and Void indicators and a landing hold.
- Experimental damage estimates are provisional and require controlled testing.

## Debug

Compact, individually toggleable, draggable graphs:

| Module | Measurement |
|---|---|
| CombatPing | Network latency |
| HitDelayGraph | Intervals between incoming health losses |
| FrameTimeGraph | Average frame duration |
| DamageTakenGraph | Health lost per damage event |
| MovementSpeedGraph | Horizontal movement speed |

Each graph includes a rolling five-second average and the most recent detected spike. Graphs retain their position during the session.

## Project files and isolation

- [Testing loader](./loader.lua)
- [Experimental workspace](./experimental/)
- [Compatibility library](./src/libraries/cheatengine_compat.lua)

The testing build uses the `elianware_testing/` cache and separate shared runtime keys. Settings and profiles are not automatically imported from the upstream client. Runtime isolation has not been verified end to end; simultaneous clients may still conflict.

## Development status

These features are experimental and have not been verified in a live game client. Follow Roblox and game-specific rules and use experimental features only in authorised environments.

## Credits

Upstream GUI, modules and libraries: [wrealaero/aerov4](https://github.com/wrealaero/aerov4), pinned revision `b723802d331778a362bfbd475fc2fb6f831c3fc1`. Elianware Testing is a separately maintained derivative, not an official upstream release.

CatVape is acknowledged separately as a reference for earlier compatibility research. Its protected library is not distributed here. Original authors retain their rights; public availability does not imply redistribution permission.
