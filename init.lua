-- K ambient light

-- a few predefined light levels
local presetLevels = {
    _global = tonumber(minetest.settings:get("k_ambient_light.global_illumination")) or 3,
    match_by_name = {},
    match_by_group = {},
    name_cache = {},
    protected = {
        -- leave it at that. air should not be illuminated. breaks sunlight/skybox.
        air = 1,
        ignore = 1,
    },
}

local function strSplit(str)
    local splt = string.split(str, ",")
    local leList = {}
    for _, x in ipairs(splt) do
        x = ("" .. x):trim()

        local splt2 = string.split(x, " ")

        if nil ~= splt2[1] and nil ~= splt2[2] then
            table.insert(leList, { splt2[1], tonumber(splt2[2]) or 0 })
        end
    end
    return leList
end

local function saneLevel(lvl)
    return math.floor(math.max(0, math.min(tonumber(lvl) or 0, minetest.LIGHT_MAX)))
end

-- determins light level for a certain node def.
local function getLightLevel(nodedef)
    local name = nodedef.name

    -- some shouldn't
    if nil ~= presetLevels.protected[name] then
        return nil
    end

    -- cache and some predefined
    if nil ~= presetLevels.name_cache[name] then
        return presetLevels.name_cache[name]
    end

    local lvl = presetLevels._global

    -- raise illumination to global
    if
        nil ~= nodedef.light_source
        and lvl < nodedef.light_source
    then
        lvl = nodedef.light_source
    end

    -- find name match.
    for i = 1, #presetLevels.match_by_name, 1 do
        local pattern = presetLevels.match_by_name[i][1]
        local delta = presetLevels.match_by_name[i][2]
        if string.match(name, pattern) then
            lvl = saneLevel(presetLevels._global + delta)
            -- print("by name " .. name .. " " .. pattern .. " -> " .. lvl)
            presetLevels.name_cache[name] = lvl
            return lvl
        end
    end

    -- then by group
    local groups = nodedef.groups or {}
    for i = 1, #presetLevels.match_by_group, 1 do
        local grp = presetLevels.match_by_group[i][1]
        local delta = presetLevels.match_by_group[i][2]
        if nil ~= groups[grp] then
            lvl = saneLevel(presetLevels._global + delta)
            -- print("by group " .. name .. " " .. grp .. " -> " .. lvl)
            presetLevels.name_cache[name] = lvl
            return lvl
        end
    end

    return saneLevel(lvl)
end


minetest.register_on_mods_loaded(function()

    -- load after mods to allow some overrides.
    -- @todo an API for overrides
    presetLevels.match_by_name = strSplit(minetest.settings:get("k_ambient_light.match_by_name") or "")
    presetLevels.match_by_group = strSplit(minetest.settings:get("k_ambient_light.match_by_group") or "")


    for name, def in pairs(minetest.registered_nodes) do
        local lvl = getLightLevel(def)

        if nil ~= lvl then
            -- print("override " .. name .. " -> " .. lvl)
            minetest.override_item(name, { light_source = lvl })
        end
    end

    -- print(dump(presetLevels))
end)
