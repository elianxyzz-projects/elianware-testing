-- Elian testing build: isolated settings, profiles, cache and shared state.
-- This repository does not contain or redistribute the upstream UI or module sources.
-- Upstream: https://github.com/wrealaero/aerov4

repeat task.wait() until game:IsLoaded()
-- Wait 10 seconds after the game has finished loading before initializing Aero.
task.wait(10)

-- Verify executor identity before downloading, running modules, or modifying any files.
-- Only exact name prefixes are allowed; names are case-insensitive.
local function executorFamily(name)
    if type(name) ~= 'string' then return nil end
    local normal = name:lower():match('^%s*(.-)%s*$')
    if normal == 'potassium' or normal:match('^potassium[%s%p]') then return 'Potassium' end
    if normal == 'real' or normal:match('^real[%s%p]') then return 'Real' end
    return nil
end

local detectedName = 'Unknown'
local executorKind
if type(identifyexecutor) == 'function' then
    local ok, name = pcall(identifyexecutor)
    if ok and type(name) == 'string' then
        detectedName = name
        executorKind = executorFamily(name)
    end
end
-- Real also documents getexecutorname(); use it only as a fallback.
if not executorKind and type(getexecutorname) == 'function' then
    local ok, name = pcall(getexecutorname)
    if ok and type(name) == 'string' then
        detectedName = name
        executorKind = executorFamily(name)
    end
end

local function rejectAndUninject(message)
    -- Unload any previously running copy; this invocation has not injected yet.
    if type(shared) == 'table' and type(shared.elianTestingVape) == 'table'
        and type(shared.elianTestingVape.Uninject) == 'function' then
        pcall(function() shared.elianTestingVape:Uninject() end)
    end
    -- Independent top-right error: survives AeroV4 Uninject.
    local ok, err = pcall(function()
        local parent
        -- PlayerGui is preferred for a visible client-side top-right error.
        local player = game:GetService('Players').LocalPlayer
        parent = player and player:FindFirstChildOfClass('PlayerGui')
        if not parent and type(gethui) == 'function' then
            local good, gui = pcall(gethui)
            if good and typeof(gui) == 'Instance' and not gui:IsA('ScreenGui') then
                parent = gui
            end
        end
        if not parent then parent = game:GetService('CoreGui') end

        local existing = parent:FindFirstChild('AeroV4LiteExecutorError')
        if existing then existing:Destroy() end
        local screen = Instance.new('ScreenGui')
        screen.Name = 'AeroV4LiteExecutorError'
        screen.IgnoreGuiInset = true
        screen.ResetOnSpawn = false
        screen.DisplayOrder = 999999
        screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
        screen.Parent = parent

        local frame = Instance.new('Frame')
        frame.AnchorPoint = Vector2.new(1, 0)
        frame.Position = UDim2.new(1, -16, 0, 20)
        frame.Size = UDim2.fromOffset(350, 84)
        frame.BackgroundColor3 = Color3.fromRGB(37, 30, 32)
        frame.BorderSizePixel = 0
        frame.Parent = screen
        local corner = Instance.new('UICorner')
        corner.CornerRadius = UDim.new(0, 9)
        corner.Parent = frame
        local stripe = Instance.new('Frame')
        stripe.Size = UDim2.fromOffset(4, 84)
        stripe.BackgroundColor3 = Color3.fromRGB(236, 79, 92)
        stripe.BorderSizePixel = 0
        stripe.Parent = frame
        local title = Instance.new('TextLabel')
        title.BackgroundTransparency = 1
        title.Position = UDim2.fromOffset(15, 7)
        title.Size = UDim2.new(1, -26, 0, 25)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 15
        title.TextColor3 = Color3.fromRGB(255, 115, 125)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Text = 'AeroV4 Lite - Unsupported executor'
        title.Parent = frame
        local detail = Instance.new('TextLabel')
        detail.BackgroundTransparency = 1
        detail.Position = UDim2.fromOffset(15, 32)
        detail.Size = UDim2.new(1, -26, 0, 43)
        detail.Font = Enum.Font.Gotham
        detail.TextSize = 12
        detail.TextWrapped = true
        detail.TextXAlignment = Enum.TextXAlignment.Left
        detail.TextYAlignment = Enum.TextYAlignment.Top
        detail.TextColor3 = Color3.fromRGB(232, 225, 225)
        detail.Text = message
        detail.Parent = frame
        task.delay(18, function()
            if screen and screen.Parent then screen:Destroy() end
        end)
    end)
    if not ok then
        warn('[AeroV4 Lite] Could not display top-right error: ' .. tostring(err))
        pcall(function()
            game:GetService('StarterGui'):SetCore('SendNotification', {
                Title = 'AeroV4 Lite: Unsupported executor',
                Text = message,
                Duration = 15
            })
        end)
    end
    warn('[AeroV4 Lite] Load aborted and existing instance uninject attempted: ' .. message)
end

if not executorKind then
    rejectAndUninject('Only Potassium and Real are supported. Detected: ' .. detectedName .. '. Nothing was loaded.')
    return nil
end

print('[AeroV4 Lite] Selected executor: ' .. executorKind)


-- The module set below is specific to Roblox BedWars.
local BEDWARS_GAME_ID = 2619619496
if game.GameId ~= BEDWARS_GAME_ID then
    error('[AeroV4 Lite] This build only supports Roblox BedWars (GameId 2619619496).')
end

-- Pinning this known upstream snapshot prevents unexpected upstream changes.
local UPSTREAM_COMMIT = 'b723802d331778a362bfbd475fc2fb6f831c3fc1'
local UPSTREAM_BASE = 'https://raw.githubusercontent.com/wrealaero/aerov4/' .. UPSTREAM_COMMIT .. '/'
local DEFAULT_SELF_URL = 'https://raw.githubusercontent.com/elianxyzz-projects/catvape-cv-modules/main/loader.lua'
local env = getgenv()
local SELF_URL = env.ElianTestingURL or DEFAULT_SELF_URL

-- Verify essential executor capabilities before modifying cached files.
for _, fnName in ipairs({
    'getgenv', 'loadstring', 'readfile', 'writefile',
    'isfile', 'isfolder', 'makefolder', 'listfiles'
}) do
    if type(env[fnName]) ~= 'function' and type(_G[fnName]) ~= 'function' then
        error('[AeroV4 Lite] Your executor is missing ' .. fnName .. '. Cannot safely load.')
    end
end

print('[AeroV4 Lite] Starting original AeroV4 UI on ' .. executorKind)

if SELF_URL ~= nil and (type(SELF_URL) ~= 'string'
    or not SELF_URL:match('^https://raw%.githubusercontent%.com/.+/loader%.lua$')) then
    error('[AeroV4 Lite] AeroV4LiteURL must be a raw.githubusercontent.com URL ending with /loader.lua')
end

-- Separate local caches, profile data and shared state from AeroV4.
local function elianNamespaceSource(source)
    if type(source) ~= 'string' then return source end
    source = source:gsub('aerov4/', 'elianware_testing/')
    -- Keep upstream download addresses pointing at the actual upstream repo.
    source = source:gsub('wrealaero/elianware_testing/', 'wrealaero/aerov4/')
    source = source:gsub('shared%.vape', 'shared.elianTestingVape')
    source = source:gsub('shared%.Vape', 'shared.ElianTestingVape')
    source = source:gsub('shared%.aerov4User', 'shared.elianTestingUser')
    source = source:gsub('getgenv%(%)%.Closet', 'getgenv().ElianTestingCloset')
    source = source:gsub('getgenv%(%)%._vape', 'getgenv()._elianTestingVape')
    return source
end

local function replaceOnce(haystack, needle, replacement, label)
    local startPos, endPos = haystack:find(needle, 1, true)
    if not startPos then
        error('[AeroV4 Lite] Upstream main.lua is incompatible (missing ' .. label .. '). No code executed.')
    end
    return haystack:sub(1, startPos - 1) .. replacement .. haystack:sub(endPos + 1)
end

local function getUpstream(path)
    local success, content = pcall(function()
        return game:HttpGet(UPSTREAM_BASE .. path, true)
    end)
    if not success or type(content) ~= 'string' or content == '' or content == '404: Not Found' then
        error('[AeroV4 Lite] Could not retrieve pinned upstream file ' .. path .. ': ' .. tostring(content))
    end
    return content
end

local function ensureFolder(path)
    if not isfolder(path) then makefolder(path) end
end

for _, folder in ipairs({
    'elianware_testing', 'elianware_testing/profiles', 'elianware_testing/assets',
    'elianware_testing/libraries', 'elianware_testing/guis', 'elianware_testing/games',
    'elianware_testing/assets/new'
}) do
    ensureFolder(folder)
end

writefile('elianware_testing/profiles/commit.txt', UPSTREAM_COMMIT)
writefile('elianware_testing/profiles/latest.txt', UPSTREAM_COMMIT)
writefile('elianware_testing/profiles/gui.txt', 'new')

local filterCode = [==[
    -- Filter after BedWars module registration, before enabling saved modules.
    do
        local keep = {
            AimAssist = true,
            SilentAim = true,
            Reach = true,
            HitFix = true,
            KitESP = true,
            KitRender = true,
            NameTags = true,
            HitBoxes = true,
            ESP = true,
            BedPlates = true,
            FPSBoost = true,
            AutoTool = true,
            Freecam = true,
            FOV = true
        }
        local keepCategories = {
            Main = true,
            Friends = true,
            Targets = true,
            Profiles = true,
            Favorites = true,
            Combat = true,
            Blatant = true,
            Render = true,
            Utility = true,
            World = true,
            Kits = true,
            Minigames = true,
            Legit = true,
            ['Experimental (Ban)'] = true
        }
        local function pruneModules(tab)
            if type(tab) ~= 'table' then return end
            local unwanted = {}
            for moduleName in pairs(tab) do
                if not keep[moduleName] then
                    unwanted[#unwanted + 1] = moduleName
                end
            end
            for _, moduleName in ipairs(unwanted) do
                local module = tab[moduleName]
                if module and module.Enabled then
                    pcall(function() module:Toggle() end)
                end
                local ok, err = pcall(function() vape:Remove(moduleName) end)
                if not ok then
                    warn('[AeroV4 Lite] Could not remove ' .. moduleName .. ': ' .. tostring(err))
                end
            end
        end

        pruneModules(vape.Modules)
        if vape.Legit then pruneModules(vape.Legit.Modules) end

        -- Disable registration-time defaults before the original profile loader runs.
        -- Fresh profiles therefore start OFF; existing profiles then restore
        -- their saved Enabled values, along with all options and keybinds.
        local function stopEnabledModules(modules)
            if type(modules) ~= 'table' then return end
            for _, module in pairs(modules) do
                if module.Enabled and type(module.Toggle) == 'function' then
                    local ok, err = pcall(function() module:Toggle() end)
                    if not ok then
                        warn('[AeroV4 Lite] Could not disable active module: ' .. tostring(err))
                    end
                end
            end
        end
        stopEnabledModules(vape.Modules)
        if vape.Legit then stopEnabledModules(vape.Legit.Modules) end

        -- Keep internal categories for friend/target settings and other dependencies.
        if type(vape.Categories) == 'table' then
            for categoryName, category in pairs(vape.Categories) do
                if type(category) == 'table' and category.Type == 'Category'
                    and not keepCategories[categoryName] then
                    if category.Object then category.Object.Visible = false end
                    if category.Button and category.Button.Object then
                        category.Button.Object.Visible = false
                    end
                end
            end
        end

        -- Previous full-client profiles must not reveal hidden categories.
        local experimentalFirstLoad = true
        local upstreamLoad = vape.Load
        if type(upstreamLoad) == 'function' then
            function vape:Load(...)
                local result = table.pack(upstreamLoad(self, ...))
                for categoryName, category in pairs(self.Categories or {}) do
                    if not keepCategories[categoryName]
                        and type(category) == 'table'
                        and category.Type == 'Category' then
                        if category.Object then category.Object.Visible = false end
                        if category.Button and category.Button.Object then
                            category.Button.Object.Visible = false
                        end
                    end
                end
                local experimental = self.Categories and self.Categories['Experimental (Ban)']
                if experimental and experimental.Button then
                    if experimental.Button.Object then experimental.Button.Object.Visible = true end
                    if experimentalFirstLoad then
                        experimentalFirstLoad = false
                        if not experimental.Button.Enabled then experimental.Button:Toggle() end
                        if not experimental.Expanded and experimental.Expand then experimental:Expand() end
                    end
                end
                return table.unpack(result, 1, result.n)
            end
        end
        if game.PlaceId == 6872274481 then
            for moduleName in pairs(keep) do
                if not ((vape.Modules and vape.Modules[moduleName])
                    or (vape.Legit and vape.Legit.Modules and vape.Legit.Modules[moduleName])) then
                    warn('[AeroV4 Lite] Missing upstream module: ' .. moduleName)
                end
            end
        end
    end
]==]

local originalMain = getUpstream('main.lua')
local needle = '\tfinishLoading()\nelse\n\tvape.Init = finishLoading'
local newMain = replaceOnce(
    originalMain,
    needle,
    filterCode .. '\n\tfinishLoading()\nelse\n\tvape.Init = finishLoading',
    'load-before-finish insertion point'
)

-- Ensure teleport reloads return to this Lite build instead of full upstream.
if SELF_URL then
    local oldLoader = 'local LOADER_URL = "https://raw.githubusercontent.com/wrealaero/aerov4/main/downloader.lua"'
    newMain = replaceOnce(newMain, oldLoader,
        'local LOADER_URL = ' .. string.format('%q', SELF_URL),
        'teleport loader URL')
    local marker = '\n\t\tif identifyexecutor and ({identifyexecutor()})[1] == \'Potassium\' then'
    local queuePrefix = 'getgenv().ElianTestingURL = ' .. string.format('%q', SELF_URL) .. '\n'
    newMain = replaceOnce(newMain, marker,
        '\n\t\tteleportScript = ' .. string.format('%q', queuePrefix) .. ' .. teleportScript' .. marker,
        'teleport queue context')
else
    newMain = replaceOnce(newMain,
        'local function buildTeleportScript()\n',
        'local function buildTeleportScript()\n\t\treturn nil -- Disable full-client reloader.\n',
        'teleport hook')
end

-- Fetch the original GUI, universal modules and selected BedWars game code.
local transformerForMain = [==[
-- Separate local caches, profile data and shared state from AeroV4.
local function elianNamespaceSource(source)
    if type(source) ~= 'string' then return source end
    source = source:gsub('aerov4/', 'elianware_testing/')
    -- Keep upstream download addresses pointing at the actual upstream repo.
    source = source:gsub('wrealaero/elianware_testing/', 'wrealaero/aerov4/')
    source = source:gsub('shared%.vape', 'shared.elianTestingVape')
    source = source:gsub('shared%.Vape', 'shared.ElianTestingVape')
    source = source:gsub('shared%.aerov4User', 'shared.elianTestingUser')
    source = source:gsub('getgenv%(%)%.Closet', 'getgenv().ElianTestingCloset')
    source = source:gsub('getgenv%(%)%._vape', 'getgenv()._elianTestingVape')
    return source
end

]==]
-- Namespace dynamically downloaded Lua as well (libraries, entities, game helpers).
-- Patch only the upstream main's source-download cache point, not binary assets.
newMain = replaceOnce(newMain,
    "writefile(path, res)\n\tend\n\treturn (func or readfile)(path)",
    "writefile(path, path:sub(-4) == '.lua' and elianNamespaceSource(res) or res)\n\tend\n\treturn (func or readfile)(path)",
    'downloaded Lua namespace')
newMain = transformerForMain .. elianNamespaceSource(newMain)
writefile('elianware_testing/main.lua', newMain)
-- Use the original GUI profile loader without changing its saved Enabled states.
-- No saved profile -> modules stay disabled; saved profile -> prior enabled
-- module choices and all settings are restored automatically.
-- Load the supplied Elian banner as a local custom asset.
local imageURL = 'https://raw.githubusercontent.com/elianxyzz-projects/elianware/main/assets/elian.png'
local imageOK, imageBytes = pcall(function() return game:HttpGet(imageURL, true) end)
if imageOK and type(imageBytes) == 'string' and #imageBytes > 1000 then
    writefile('elianware_testing/assets/new/elian.png', imageBytes)
else
    warn('[AeroV4 Lite] Could not download custom Elian banner')
end

local customGUI = getUpstream('guis/new.lua')
-- Apply the Elian blue gradient to every category window and module row,
-- including the different pop-out menu windows constructed by the upstream GUI.
local blueMenuHelper = [==[
local function aeroLiteBlueGradient(object, subtle)
    if not object or object:FindFirstChild('AeroLiteBlueGradient') then return end
    local gradient = Instance.new('UIGradient')
    gradient.Name = 'AeroLiteBlueGradient'
    gradient.Rotation = 90
    gradient.Color = subtle and ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 52, 139)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(9, 78, 169)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 112, 190))
    }) or ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 34, 132)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 109, 232)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 195, 241))
    })
    gradient.Parent = object
end
]==]
local helperAnchor = 'local color = {}'
customGUI = replaceOnce(customGUI, helperAnchor, blueMenuHelper .. '\n' .. helperAnchor, 'blue-gradient helper')
local windowToken = 'window.Parent = clickgui'
local windowCount
customGUI, windowCount = customGUI:gsub(windowToken, windowToken .. '\n\t\taeroLiteBlueGradient(window, false)')
if windowCount < 3 then
    error('[AeroV4 Lite] Expected category/menu windows were not found for blue gradient')
end
customGUI = replaceOnce(customGUI,
    'modulebutton.Parent = children',
    'modulebutton.Parent = children\n\t\taeroLiteBlueGradient(modulebutton, true)',
    'module row gradient')

-- Replace only the main GUI branding and its Settings pane styling.
local oldLogo = "logo.Image = getcustomasset('aerov4/assets/new/guivape.png')"
local newLogo = "logo.Image = getcustomasset('aerov4/assets/new/elian.png')"
customGUI = replaceOnce(customGUI, oldLogo, newLogo, 'main GUI logo')
customGUI = replaceOnce(customGUI,
    "logov4.Parent = logo",
    "logov4.Visible = false\n\tlogov4.Parent = logo",
    'legacy V4 logo overlay')
customGUI = replaceOnce(customGUI,
    "logo.Size = UDim2.fromOffset(62, 18)",
    "logo.Size = UDim2.fromOffset(49, 30)",
    'main GUI logo dimensions')
customGUI = replaceOnce(customGUI,
    "logo.Position = UDim2.fromOffset(11, 10)",
    "logo.Position = UDim2.fromOffset(10, 3)",
    'main GUI logo position')
customGUI = replaceOnce(customGUI,
    "logo.ImageColor3 = select(3, uipallet.Main:ToHSV()) > 0.5 and uipallet.Text or Color3.new(1, 1, 1)",
    "logo.ImageColor3 = Color3.new(1, 1, 1)\n\tlogo.ScaleType = Enum.ScaleType.Fit",
    'main GUI image color')
customGUI = replaceOnce(customGUI,
    "settingspane.Parent = window",
    [[settingspane.Parent = window
    settingspane.BackgroundColor3 = Color3.fromRGB(5, 38, 112)
    local blueGradient = Instance.new('UIGradient')
    blueGradient.Rotation = 90
    blueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 34, 132)),
        ColorSequenceKeypoint.new(0.48, Color3.fromRGB(0, 109, 232)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 195, 241))
    })
    blueGradient.Parent = settingspane]],
    'Settings background')
customGUI = replaceOnce(customGUI,
    "settingschildren.BackgroundColor3 = uipallet.Main",
    "settingschildren.BackgroundColor3 = Color3.fromRGB(5, 57, 144)\n\tlocal childrenGradient = Instance.new('UIGradient')\n\tchildrenGradient.Rotation = 90\n\tchildrenGradient.Color = ColorSequence.new(Color3.fromRGB(6, 69, 178), Color3.fromRGB(2, 150, 216))\n\tchildrenGradient.Parent = settingschildren",
    'Settings content background')
-- Enforce capped sliders for typed values and restored profiles as well.
customGUI = replaceOnce(customGUI,
    "function optionapi:SetValue(value, pos, final)\n\t\t\tif tonumber(value) == math.huge or value ~= value then return end",
    "function optionapi:SetValue(value, pos, final)\n\t\t\tif tonumber(value) == math.huge or value ~= value then return end\n\t\t\tif optionsettings.AeroLiteCap then value = math.clamp(tonumber(value) or optionsettings.Min, optionsettings.Min, optionsettings.Max) end",
    'capped slider value validation')
customGUI = replaceOnce(customGUI,
    "scarcitybanner.Text = 'shitty ass aerov4 script gang gang'",
    "scarcitybanner.Text = ''",
    'bottom banner text')
customGUI = replaceOnce(customGUI,
    "mainapi.Categories.Main:CreateDivider('misc')",
    "if game.GameId == 2619619496 then\n    mainapi:CreateCategory({\n        Name = 'Experimental (Ban)',\n        Icon = getcustomasset('aerov4/assets/new/blatanticon.png'),\n        Size = UDim2.fromOffset(14, 14)\n    })\n    local experimental = mainapi.Categories['Experimental (Ban)']\n    if experimental and experimental.Object then\n        experimental.Object.Position = UDim2.fromOffset(466, 120)\n        if experimental.Button and experimental.Button.Object then\n            experimental.Button.Object.Visible = true\n        end\n    end\nend\nmainapi.Categories.Main:CreateDivider('misc')",
    'experimental category')
writefile('elianware_testing/guis/new.lua', elianNamespaceSource(customGUI))
-- Preserve the upstream AeroV4 implementations of Freecam and FOV.
-- Freecam's original registration is in World; move only that module to Legit.
local universalSource = getUpstream('games/universal.lua')
local upstreamFreecam = "Freecam = vape.Categories.World:CreateModule({"
universalSource = replaceOnce(universalSource, upstreamFreecam,
    "Freecam = vape.Categories.Legit:CreateModule({", 'original Freecam category')
writefile('elianware_testing/games/universal.lua', elianNamespaceSource(universalSource))


-- Limit only the original BedWars module sliders, preserving their other options.
local function capSlider(source, marker, cap)
    local first, last = source:find(marker, 1, true)
    if not first or source:find(marker, last + 1, true) then
        error('[AeroV4 Lite] Unexpected slider registration: ' .. marker)
    end
    local head, tail = source:sub(1, last), source:sub(last + 1)
    local changed, count = tail:gsub('^(%s*Name%s*=%s*[^,\n]+,%s*.-Min%s*=%s*%d+,%s*)Max%s*=%s*%d+,(%s*)Default%s*=%s*%d+,', function(prefix, spacing)
        return prefix .. 'Max = ' .. cap .. ',' .. spacing .. 'Default = ' .. cap .. ', AeroLiteCap = true,'
    end, 1)
    if count ~= 1 then error('[AeroV4 Lite] Slider layout changed: ' .. marker) end
    return head .. changed
end

-- Retain the existing standalone HitFix compatibility and restore logic.
local function patchHitFix(source)
    local startMarker = "run(function()\n\tlocal Hitfix "
    local endMarker = "\nrun(function()\n\tlocal Interface"
    local first = source:find(startMarker, 1, true)
    local last = first and source:find(endMarker, first, true)
    if not first or not last or not source:sub(first, last - 1):find("Name = 'HitFix'", 1, true) then
        error('[AeroV4 Lite] HitFix block changed; cannot apply HitFix compatibility patch.')
    end
    local replacement = [==[
run(function()
    local HitFix
    local active
    local getConstant = debug.getconstant or getconstant
    local setConstant = debug.setconstant or setconstant
    local getUpvalue = debug.getupvalue or getupvalue
    local setUpvalue = debug.setupvalue or setupvalue

    local function report(message, force)
        if force then warn('[AeroLite HitFix] ' .. message)
        else print('[AeroLite HitFix] ' .. message) end
    end

    local function restore()
        if not active then return true end
        local old = active
        local a = pcall(setConstant, old.func, old.index, old.constant)
        local b = pcall(setUpvalue, old.func, 4, old.value)
        if a and b then active = nil end
        return a and b
    end

    local function reconcile()
        local enabled = HitFix and HitFix.Enabled
        if not enabled then
            if not restore() then report('Could not restore original raycast.', true) end
            return
        end
        if type(getConstant) ~= 'function' or type(setConstant) ~= 'function'
            or type(getUpvalue) ~= 'function' or type(setUpvalue) ~= 'function' then
            report('Required executor APIs unavailable.', true)
            return
        end
        local controller = bedwars.SwordController
        local func = controller and controller.swingSwordAtMouse
        if type(func) ~= 'function' then return end
        local target = bedwars.QueryUtil
        local constant = 'raycast'
        if not target then report('Selected query unavailable.', true) return end
        if active and active.func ~= func and not restore() then
            report('Could not restore previous controller.', true)
            return
        end
        if not active then
            local index, original
            for n = 1, 50 do
                local ok, val = pcall(getConstant, func, n)
                if not ok then break end
                if val == 'Raycast' or val == 'raycast' then
                    index, original = n, val
                    break
                end
            end
            if not index then report('Raycast not found; controller unchanged.', true) return end
            local ok, first, second = pcall(getUpvalue, func, 4)
            local value = second ~= nil and second or first
            if not ok or (value ~= workspace and value ~= bedwars.QueryUtil) then
                report('Unexpected query object; controller unchanged.', true)
                return
            end
            active = {func = func, index = index, constant = original, value = value}
        end
        local a = pcall(setConstant, func, active.index, constant)
        local b = a and pcall(setUpvalue, func, 4, target)
        if not a or not b then
            restore()
            report('Could not apply selected mode.', true)
            return
        end
    end

    HitFix = vape.Categories.Legit:CreateModule({
        Name = 'HitFix',
        Function = function() reconcile() end,
        Tooltip = 'Original AeroV4 query behavior.'
    })

    vape:Clean(function() restore() end)
end)
]==]
    return source:sub(1, first - 1) .. replacement .. source:sub(last)
end

local gameFileId = (game.PlaceId == 6872265039) and 6872265039 or 6872274481
local bedwarsSource = getUpstream('games/' .. tostring(gameFileId) .. '.lua')
if gameFileId == 6872274481 then
    bedwarsSource = bedwarsSource:gsub('\r\n', '\n')
    bedwarsSource = capSlider(bedwarsSource, 'Attack = Reach:CreateSlider({', 16)
    bedwarsSource = capSlider(bedwarsSource, 'Mine = Reach:CreateSlider({', 16)
    bedwarsSource = capSlider(bedwarsSource, 'FOV = SilentAim:CreateSlider({', 100)
    bedwarsSource = patchHitFix(bedwarsSource)
end
writefile('elianware_testing/games/' .. tostring(gameFileId) .. '.lua', elianNamespaceSource(bedwarsSource))

local originalDownloader = getUpstream('downloader.lua')
local runDownloader, compileError = loadstring(elianNamespaceSource(originalDownloader), 'elian-testing-downloader')
if not runDownloader then
    error('[AeroV4 Lite] Original downloader could not be compiled: ' .. tostring(compileError))
end
return runDownloader()
