# AeroV4 Lite — 11-module BedWars build

A pared-down module view using the **original AeroV4 GUI** and each retained module's **original settings and callbacks**. This repository contains an allowlist loader, **not copies of AeroV4's source or assets**. On launch it retrieves upstream source files from a pinned snapshot of [wrealaero/aerov4](https://github.com/wrealaero/aerov4).

## Quick start

**Execute this only in a Roblox environment and executor you trust, after reviewing the source.**

~~~lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/elianxyzz-projects/aeroclone/main/loader.lua', true))()
~~~

Source: [loader.lua](./loader.lua) — the script the loadstring fetches.

## Included modules (all 11)

| Module | AeroV4 UI tab | Original options retained |
|---|---|---|
| AimAssist (AA) | Combat | Yes |
| ProjectileAimbot (PA) | Blatant | Yes |
| HitFix | Legit | Original toggle |
| HitBoxes (hotboxes/hitboxes) | Combat | Yes |
| ESP (regular player boxes) | Render | Yes — choose Mode → 2D and Bounding Box |
| BedPlates | Minigames | Yes |
| KitESP | Kits | Yes |
| KitRender | Utility | Yes |
| NameTags | Render | Yes |
| **FPSBoost (FPS booster)** | **World** | **Yes** |
| **AutoTool** | **World** | **Yes — original block-breaking tool selection** |

**Note:** The upstream module is called FPSBoost, not FPSBOOSTER. Keeping the original names protects module-option/profile compatibility. The original Friends, Targets, Favorites, Profiles and configuration controls are retained. Unused optional tabs are hidden.

## About Frame Buffer (not included)

The commonly mentioned Roblox "Frame Buffer" FastFlag is `DFIntMaxFrameBufferSize`, often shown with a value of `4` in community performance lists. Roblox introduced an allowlist for local FastFlag overrides in September 2025, and `DFIntMaxFrameBufferSize` is **not** in its published allowlist. We have not verified a supported, effective in-session change using Potassium or Real. As requested, no experimental or potentially nonfunctional Frame Buffer toggle was added.

Official announcement: https://devforum.roblox.com/t/allowlist-for-local-client-configuration-via-fast-flags/3966569

## How the loader works

1. Runs in Roblox BedWars only (GameId 2619619496). Match-specific modules may not register until you enter a match.
2. Fetches the original AeroV4 main UI, main loader, universal modules and the appropriate BedWars-specific file from pinned upstream commit b723802d331778a362bfbd475fc2fb6f831c3fc1 (October 14, 2026).
3. Inserts the 11-module allowlist into local cached upstream main code. The original modules register and unwanted modules are removed **before** loading saved profile module settings. Retained module settings and callbacks are not reimplemented.
4. Retains the upstream Potassium-specific teleport delay and redirects the upstream teleport reload path to this repository's loader.

This script modifies the executor's **aerov4/** file cache. Back up original profiles before mixing it with an unmodified AeroV4 installation, and don't run both in the same game session.

## Potassium and Real — enforced executor check

At startup, the loader checks identifyexecutor(), with getexecutorname() as a fallback if the first name is unavailable or unsupported. Executor name detection is case-insensitive and accepts only Potassium or Real.

- **Potassium:** HitFix uses Potassium's documented debug.getconstant, debug.setconstant, debug.getupvalue and debug.setupvalue APIs.
- **Real:** HitFix uses Real's documented getconstant, setconstant, getupvalue and setupvalue APIs (falling back to Real's debug.* aliases).
- **Any other executor or an unknown name:** the loader attempts to uninject any existing AeroV4 interface, displays a red error in the upper-right for 18 seconds, and stops before downloading modules or modifying cached files.
- **A supported executor missing essential HitFix APIs:** likewise stops and displays an error rather than offering a broken HitFix module.

The selected HitFix adapter is the only one used during a given load. Its patch still targets the original BedWars sword-swing function, and now records/restores the original constant and upvalue when disabled. Settings are preserved. The loader also validates basic filesystem functions before caching.

**Not verified end to end:** no tests have been run in a live Roblox BedWars client using Potassium or Real. The pinned upstream module code and local static checks do not guarantee that HitFix—or every other module—works on all executor versions or after game updates.

## Config saving and first-run behavior

**Fresh installation / new profile:** Every module starts OFF if no saved configuration exists. You can enable whichever modules you want manually. Any modules that upstream activated during registration are turned off before loading the profile.

**Existing saved profile:** The original AeroV4 loader restores the saved `Enabled` state of each module, including the Legit tab, as well as sliders, dropdowns, colors, and keybinds. After you enable modules and the profile is saved, they automatically turn on again when you next launch or select that profile. The original periodic autosave still runs approximately every 10 seconds while loaded.

This fixes the temporary version that forced every module off on every launch. **Previously overwritten profiles cannot be reconstructed automatically:** if that version saved `Enabled = false` over your earlier preferences, you'll need to turn the modules back on once (or restore your own backup), and the saved state will then persist normally.

## Unsupported-executor error notification

The executor check runs before file writes. If neither Potassium nor Real is detected (or if essential HitFix APIs are unavailable), the loader attempts to uninject an existing AeroV4 instance, **stops**, and displays a red **top-right** message for roughly 18 seconds. It first tries Roblox PlayerGui so the notification is independent of AeroV4's own notification settings; if UI construction fails, it attempts Roblox's built-in notification API. The original AeroV4 notification system remains available for regular module messages.

**Verification limit:** source inspection and static tests confirm the display code and startup gate, but a rendered notification and executor-specific behavior have not been tested in a running Roblox client.

## Testing and troubleshooting

- Check that the raw loader URL returns Lua text, not a 404.
- Open BedWars, not a different Roblox game.
- Test match-only modules inside a match; some are absent from the lobby.
- Use Render → ESP → Mode → 2D and enable Bounding Box to show regular ESP boxes.
- For HitFix problems, look for executor-console warnings about debug APIs.
- If you have an old full-client profile, test a new profile rather than deleting your original files.

## Attribution / permissions

Upstream: [wrealaero/aerov4](https://github.com/wrealaero/aerov4). Its public repository has no declared license as inspected. Public visibility and noncommercial use do not automatically establish redistribution permission. This project hosts only a loader and fetches original source from upstream; it does not copy their original Lua sources or GUI images into this repository.
