-- Clean-room, partial replacement for the public-facing CatVape cheatengine.lua API.
-- Based ONLY on references observed in src/games/6872274481.lua.
-- No Luraph VM, protected payload, executor hook, or game internals included.
--
-- Call signature mirrors the visible original: loadstring(source)(vape, events, entity).
-- Pass an optional fourth argument with backend implementations.
--
-- IMPORTANT: This is an interface adapter, NOT a working game-hook library.
-- Operations requiring private/internal game hooks fail explicitly when missing.
local function createLibrary(vape, events, entity, backend)
    backend = backend or {}
    assert(type(backend) == "table", "backend must be a table")

    local library = {}
    local active = {}

    local function requireAdapter(key, method)
        local source = backend[key]
        if type(source) ~= "table" or type(source[method]) ~= "function" then
            error(("CV compatibility: %s.%s requires an external game adapter"):format(key, method), 3)
        end
        return source
    end

    local function bind(key, data)
        local source = requireAdapter(key, "Bind")
        local cleanup = source.Bind(data)
        assert(type(cleanup) == "function", key .. ".Bind must return a cleanup function")
        active[cleanup] = true
        return function()
            if active[cleanup] then
                active[cleanup] = nil
                cleanup()
            end
        end
    end

    local function read(key, method, ...)
        local source = requireAdapter(key, method)
        return source[method](...)
    end

    -- Seen in SilentAim and ProjectileAimbot. The Solve callback takes
    -- (launchData, origin, speed, optionalPreview) and may return a Vector3.
    -- The game-specific interception mechanism is NOT recoverable from call sites.
    library.ProjectileAim = {
        Bind = function(settings)
            assert(type(settings) == "table" and type(settings.Solve) == "function",
                "ProjectileAim.Bind expects a settings table with Solve")
            return bind("ProjectileAim", settings)
        end
    }

    -- Seen in Reach. Place/Break are optional callbacks returning reach or nil.
    library.BlockReach = {
        Bind = function(settings)
            assert(type(settings) == "table"
                and type(settings.Place) == "function"
                and type(settings.Break) == "function",
                "BlockReach.Bind expects Place and Break functions")
            return bind("BlockReach", settings)
        end
    }

    library.CannonBoost = {
        Bind = function(callback)
            assert(type(callback) == "function", "CannonBoost.Bind expects a callback")
            return bind("CannonBoost", callback)
        end,
        GetSpeed = function()
            return read("CannonBoost", "GetSpeed")
        end
    }

    library.DamageIndicator = {
        Bind = function(callback)
            assert(type(callback) == "function", "DamageIndicator.Bind expects a callback")
            return bind("DamageIndicator", callback)
        end
    }

    library.BlockTarget = {
        GetBlock = function()
            return read("BlockTarget", "GetBlock")
        end
    }

    library.HotbarVisual = {
        GetSlot = function(tool)
            return read("HotbarVisual", "GetSlot", tool)
        end,
        Select = function(slot)
            return read("HotbarVisual", "Select", slot)
        end
    }

    library.GetBlockBreaker = function()
        -- The caller checks a falsy return to handle an unavailable breaker.
        local provider = backend.GetBlockBreaker
        if type(provider) ~= "function" then return nil end
        return provider()
    end

    -- Observed cached fields. Values are NOT reconstructed from the packed VM;
    -- callers must provide their own verified data.
    library.RateLimits = backend.RateLimits or {}
    library.BowConstantsTable = backend.BowConstantsTable
    library.TeamUpgradeMeta = backend.TeamUpgradeMeta
    library.Debug = backend.Debug
    library.LastOwnPlace = backend.LastOwnPlace or 0

    -- The original calls await() on named entries keyed by module full paths.
    -- Named deferred module entries can be registered explicitly by an integrator.
    library.RegisterModule = function(path, awaitable)
        assert(type(path) == "string" and path ~= "", "module path required")
        assert(type(awaitable) == "table" and type(awaitable.await) == "function",
            "module provider must expose :await()")
        library[path] = awaitable
    end

    library.Cleanup = function()
        local errors = {}
        for cleanup in pairs(active) do
            active[cleanup] = nil
            local ok, err = pcall(cleanup)
            if not ok then errors[#errors + 1] = tostring(err) end
        end
        return #errors == 0, errors
    end

    library.Capabilities = function()
        local result = {}
        for _, name in ipairs({
            "ProjectileAim", "BlockReach", "CannonBoost",
            "DamageIndicator", "BlockTarget", "HotbarVisual"
        }) do
            result[name] = type(backend[name]) == "table"
        end
        result.Debug = backend.Debug ~= nil
        result.ModuleProvider = type(backend.GetBlockBreaker) == "function"
        return result
    end

    -- Save the public constructor arguments for host-provided integrations.
    library.Context = {vape = vape, events = events, entity = entity}
    return library
end

return createLibrary
