-- Seasons mod by xyz

-- Some constant values
-- Feel free to modify them

-- Time amount, after what ABM '' table for winter will be built
-- This is required because Minetest doesn't have function that run after all nodes were registered
local time_to_load = 5

-- How many seconds one season lasts?
local season_duration = 1200
---------------------------

-- Profiler stuff
dofile(minetest.get_modpath('seasons')..'/profiler.lua')
local profiler = newProfiler()
profiler:start()
local function stopProfiler()
    profiler:stop()
    local outfile = io.open("profile.txt", "w+")
    profiler:report(outfile)
    outfile:close()
end
minetest.register_on_chat_message(function(name, message)
    if message == "/stop" then
        stopProfiler()
        minetest.chat_send_player(name, "Profiler stopped!")
    end
end)
----------------

math.randomseed(os.time())

local season_time = 0.0
local time_file = minetest.get_modpath('seasons')..'/'..'time'
-- init seasons
local f = io.open(time_file, "r")
season_time = f:read("*n")
io.close(f)

local function pp(x, y, z)
    return "("..x.." "..y.." "..z..")"
end

local function get_season_time()
    return season_time
end

local function set_season_time(t)
    season_time = t
    -- write to file
    local f = io.open(time_file, "w")
    f:write(season_time)
    io.close(f)
end

local cur_season = ""

-- spring, summer, autumn, winter
--[[function cur_season
    if season_time < 1 then
        return "spring"
    elseif season_time < 2 then
        return "summer"
    elseif season_time < 3 then
        return "autumn"
    else
        return "winter"
    end
end]]

-----------------------------------------------
-- privilege and chatcommand for easy season changes
-----------------------------------------------

minetest.register_privilege("seasons", {
description = "Change the season",
give_to_singleplayer = false
})

-- Set the season
minetest.register_chatcommand("setseason", {
    params = "<0...3>",
    description = "Set season to 0(spring),1(summer),2(autumn),3(winter)", -- full description
    privs = {seasons = true},
    func = function(name, param)
        if param == "" then
            minetest.chat_send_player(name, "Missing parameter")
            return
        end
        local newseason = tonumber(param)
        --if newseason == nil then
            --minetest.chat_send_player(name, "Invalid season")
        if newseason > 3 then
            minetest.chat_send_player(name, "Wrong parameter")
        else
            set_season_time(newseason % 4)
            minetest.chat_send_player(name, "Season changed.")
            minetest.log("action", name .. " sets season to " .. newseason)
        end
    end,
})

-------------------
--register nodes
-------------------

minetest.register_node("seasons:treetop", {
    description = "Treetop",
    tiles = {"default_tree_top.png", "default_tree_top.png", "default_tree.png"},
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
    sounds = default.node_sound_wood_defaults(),
    on_place = minetest.rotate_node
})

minetest.register_craft({
    output = 'default:stick 4',
    recipe = {
        {'seasons:treetop'},
    }
})

--[[minetest.register_node("seasons:ice", {
    description = "Ice",
    tiles = {"default_ice.png"},
    is_ground_content = true,
    paramtype = "light",
    freezemelt = "default:water_source",
    groups = {cracky=3, melts=1},
    sounds = default.node_sound_glass_defaults(),
})]]

minetest.register_node("seasons:autumn_leaves", {
    description = "Autumn Leaves",
    drawtype = "allfaces_optional",
    visual_scale = 1.3,
    tiles = {"seasons_autumn_leaves.png"},
    paramtype = "light",
    waving = 1,
    is_ground_content = false,
    groups = {snappy=3, leafdecay=3, flammable=2, leaves=1, not_in_creative_inventory=1},
    sounds = default.node_sound_leaves_defaults(),
})

--[[minetest.register_node("seasons:autumn_falling_leaves", {
    description = "Autumn Falling Leaves",
    drawtype = "allfaces_optional",
    visual_scale = 1.3,
    tiles = {"seasons_autumn_leaves.png"},
    paramtype = "light",
    waving = 1,
    is_ground_content = false,
    groups = {snappy=3, leafdecay=3, flammable=2, leaves=1, falling_node = 1, not_in_creative_inventory=1},
    sounds = default.node_sound_leaves_defaults(),
})]]

minetest.register_node("seasons:snow", {
    description = "Snow",
    tiles = {"default_snow.png"},
    inventory_image = "default_snowball.png",
    wield_image = "default_snowball.png",
    is_ground_content = true,
    paramtype = "light",
    buildable_to = true,
    leveled = 7,
    drawtype = "nodebox",
    freezemelt = "default:water_flowing",
    node_box = {
        type = "leveled",
        fixed = {
            {-0.5, -0.5, -0.5,  0.5, -0.5+2/16, 0.5},
        },
    },
    groups = {crumbly=3,falling_node=1, melts=1, float=1},
    sounds = default.node_sound_dirt_defaults({
        footstep = {name="default_snow_footstep", gain=0.25},
        dug = {name="default_snow_footstep", gain=0.75},
    }),
    on_construct = function(pos)
        pos.y = pos.y - 1
        if minetest.get_node(pos).name == "default:dirt_with_grass" then
            minetest.set_node(pos, {name="default:dirt_with_snow"})
        end
    end,
})
minetest.register_alias("snow", "default:snow")

local function vector_length(v)
    return math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
end

local function vector_resize(v, l)
    local s = vector_length(v)
    nv = {x = 0.0, y = 0.0, z = 0.0}
    nv.x = v.x / s * l
    nv.y = v.y / s * l
    nv.z = v.z / s * l
    return nv
end

minetest.register_node("seasons:snowblock", {
    description = "Snow Block",
    tiles = {"default_snow.png"},
    is_ground_content = true,
    freezemelt = "default:water_source",
    groups = {crumbly=3, melts=1},
    sounds = default.node_sound_dirt_defaults({
        footstep = {name="default_snow_footstep", gain=0.25},
        dug = {name="default_snow_footstep", gain=0.75},
    }),
})

minetest.register_craftitem("seasons:snowball", {
    image = "seasons_snowball.png",
    on_drop = function(item, dropper, pos)
        local p = dropper:getpos()
        p.y = p.y + 1
        local x = minetest.add_entity(p, "seasons:snowball_flying")
        x:setacceleration({x = 0, y = -10, z = 0})
        local look_dir = dropper:get_look_dir()
        print(pp(look_dir.x, look_dir.y, look_dir.z))
        -- TODO: resize look_dir
        x:setvelocity(vector_resize(look_dir, 10))
    end
})

minetest.register_entity("seasons:snowball_flying", {
    physical = true,
    collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
    visual = "sprite",
    textures = {"seasons_snowball.png"},
    on_step = function(self, dtime)
        local pos = self.object:getpos()
        local bcp = {x=pos.x, y=pos.y-0.7, z=pos.z}
        local bcn = minetest.get_node(bcp)
        if bcn.name ~= "air" then
            self.object:remove()
        end
    end,
})

minetest.register_node("seasons:puddle", {
    description = "Puddle",
    inventory_image = "default_water.png",
    drawtype = "nodebox",
    tiles = {"default_water.png"},
    alpha = WATER_ALPHA,
    paramtype = "light",
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    drop = "",
    leveled = 7,
    liquid_viscosity = WATER_VISC,
    freezemelt = "default:ice",
    node_box = {
        type = "leveled",
        fixed = {
            {-0.5, -0.5, -0.5,  0.5, -0.5+2/16, 0.5},
        },
    },
    groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1, freezes=1, melt_around=1, falling_node=1},
})

minetest.register_on_generated(function(minp, maxp)
    -- replace top tree block with TREETOP
    -- TODO: it should definetly be done in sources
    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            for ly = minp.y, maxp.y do
                -- TODO: fix that
                local y = maxp.y + minp.y - ly
                if minetest.get_node({x = x, y = y, z = z}).name == "default:tree" then
                    --print("New treenode at "..pp(x, y, z))
                    minetest.add_node({x = x, y = y, z = z}, {name = "seasons:treetop"})
                    local ny = y - 1
                    local t_node = minetest.get_node({x = x, y = ny, z = z})
                    while t_node.name == "default:tree" or t_node.name == "seasons:treetop" do
                        -- if there is already treetop below me, it should be removed
                        if t_node.name == "seasons:treetop" then
                            minetest.add_node({x = x, y = ny, z = z}, {name = "tree"})
                            --print("Old treetop removed at "..pp(x, y, z))
                        end
                        ny = ny - 1
                        t_node = minetest.get_node({x = x, y = ny, z = z})
                    end
                    break
                else
                end
            end
        end
    end
end)

local delta = 0.0
minetest.register_globalstep(function(dtime)
    delta = delta + dtime
    if delta > 5 then
        local time = get_season_time() + delta / season_duration
        set_season_time(time)
        if time >= 4 then
            set_season_time(time - 4)
            time = time - 4
        end
        if time < 1 then
            cur_season = "spring"
        elseif time < 2 then
            cur_season = "summer"
        elseif time < 3 then
            cur_season = "autumn"
        else
            cur_season = "winter"
        end
        print(cur_season.." "..time)
        delta = 0
    end
end)

--------
-- abm
--------

-- leaves become orange in autumn
minetest.register_abm({
    nodenames = {"default:leaves"},
    neighbors = {"air", "seasons:autumn_leaves"},
    interval = 5.0,
    chance = 10,
    action = function(pos, node)
        if cur_season == "autumn" then
            minetest.remove_node(pos)
            minetest.add_node(pos, {name = "seasons:autumn_leaves"})
        end
    end
})

--[[ leaves fall in autumn:
minetest.register_abm({
    nodenames = {"seasons:autumn_leaves"},
    neighbors = {"air"},
    interval = 5.0,
    chance = 10,
    action = function(pos, node)
        if cur_season == "autumn" then
            local b_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
            if minetest.get_node(b_pos).name == "air" then
                if get_season_time() > 2.3 then
                    minetest.remove_node(pos)
                    minetest.add_node(pos, {name = "seasons:autumn_falling_leaves"})
                    nodeupdate_single(pos)
                end
            end
        end
    end
})]]

-- das wird offenbar für den Frühling benötigt um neue Blätter zu bilden
local function sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then 
        return -1
    else 
        return 0
    end
end

-- leaves grow in spring
-- TODO: refactor this afwul cycle
-- (maybe) shuffle something?
minetest.register_abm({
    nodenames = {"seasons:treetop"},
    interval = 5.0,
    chance = 10,
    action = function(pos, node)
        if cur_season == "spring" then
            --print("Spring time!")
            local modcnt = 0
            for x = -2,2 do
            for y = -1,2 do
            for z = -2,2 do
                local n_pos = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
                if minetest.get_node(n_pos).name == "air" then
                    for dx = -1,1 do
                    for dy = -1,1 do
                    for dz = -1,1 do
                        if (math.abs(sign(dx)) + math.abs(sign(dy)) + math.abs(sign(dz)) == 1) then
                        else
                            local d_pos = {x = n_pos.x + dx, y = n_pos.y + dy, z = n_pos.z + dz}
                            local d_node = minetest.get_node(d_pos)
                            if d_node.name == "default:leaves" or d_node.name == "seasons:treetop" then
                                if math.random(30) == 1 then
                                    modcnt = modcnt + 1
                                    minetest.add_node(n_pos, {name = "default:leaves"})
                                    if modcnt == 5 then
                                        return
                                    end
                                end
                            end
                        end
                    end
                    end
                    end
                end
            end
            end
            end
        end
    end
})

-- flowers grow in spring from default flowers\init.lua i=50,chance=25
minetest.register_abm({
    nodenames = {"group:flora"},
    neighbors = {"default:dirt_with_grass", "default:desert_sand"},
    interval = 2,
    chance = 5,
    action = function(pos, node)
        if cur_season == "spring" then
            print("Spring time!")
            pos.y = pos.y - 1
            local under = minetest.get_node(pos)
            pos.y = pos.y + 1
            if under.name == "default:desert_sand" then
                minetest.set_node(pos, {name="default:dry_shrub"})
            elseif under.name ~= "default:dirt_with_grass" then
                return
            end
        
            local light = minetest.get_node_light(pos)
            if not light or light < 13 then
                return
            end
        
            local pos0 = {x=pos.x-4,y=pos.y-4,z=pos.z-4}
            local pos1 = {x=pos.x+4,y=pos.y+4,z=pos.z+4}
            if #minetest.find_nodes_in_area(pos0, pos1, "group:flora_block") > 0 then
            return
            end
        
            local flowers = minetest.find_nodes_in_area(pos0, pos1, "group:flora")
            if #flowers > 3 then
                return
            end
        
            local seedling = minetest.find_nodes_in_area(pos0, pos1, "default:dirt_with_grass")
            if #seedling > 0 then
                seedling = seedling[math.random(#seedling)]
                seedling.y = seedling.y + 1
                light = minetest.get_node_light(seedling)
                if not light or light < 13 then
                    return
                end
                if minetest.get_node(seedling).name == "air" then
                    minetest.set_node(seedling, {name=node.name})
                end
            end
        end
    end,
})

--[[minetest.register_abm({
    nodenames = {"group:flora"},
    neighbors = {"air", "default:dirt_with_grass"},
    interval = 3.0,
    chance = 1,
    action = function(pos, node)
        if cur_season ~= "winter" then
            minetest.add_node(pos, {name = 'group:flora'})
        end
    end
})]]

minetest.register_abm({
    nodenames = {"default:leaves", 'default:stone', 'default:dirt', 'default:dirt_with_grass', 'default:sand', 'default:gravel', 'default:sandstone',
                 'default:clay', 'default:brick', 'default:tree', 'seasons:treetop', 'default:jungletree', 'default:cactus', 'default:glass',
                 'default:wood', 'default:cobble', 'default:mossycobble'},
    neighbors = {"air"},
    interval = 5.0,
    chance = 25,
    action = function(pos, node)
        if cur_season ~= "winter" then
            return
        end
        local t_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
        if minetest.get_node(t_pos).name == "air" and minetest.get_node_light(t_pos, 0.5) == 15 then
            -- Grow snow!
            --if math.random(17 - math.pow(get_season_time(), 2)) == 1 then
                --print("Growing snow")
                minetest.add_node(t_pos, {name = 'seasons:snow', param2 = 8})
            --end
        end
    end
})

minetest.register_abm({
    -- FIXME: need better way (like getting block temperature?)
    nodenames = {'default:water_source', 'default:ice'},
    neighbors = {"air"},
    interval = 5.0,
    chance = 5,
    action = function(pos, node)
        if cur_season ~= "winter" then
            return
        end
        local t_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
        if minetest.get_node(t_pos).name == "air" and minetest.get_node_light(t_pos, 0.5) == 15 then
            -- Grow ice on water!
            --if math.random(5) == 1 then
                if node.name == "default:ice" then
                    return
                end
                minetest.add_node(pos, {name = 'default:ice'})
            --end
        end
    end
})

-- Erde mit Schnee wird in Erde mit Gras gewandelt
minetest.register_abm({
    nodenames = {"default:dirt_with_snow"},
    --neighbors = {"air"},
    interval = 5.0,
    chance = 10,
    action = function(pos, node)
        if cur_season ~= "winter" then
            --local b_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
            --if minetest.get_node(b_pos).name == "snow" then
            --if get_season_time() < 2 then
            minetest.remove_node(pos)
            minetest.add_node(pos, {name = "default:dirt_with_grass"})
            nodeupdate_single(pos)
                --end
            --end
        end
    end
})

-- Remove snow which has air below it
minetest.register_abm({
    nodenames = {"seasons:snow", "default:snow"},
    interval = 1.0,
    chance = 1,
    action = function(pos, node)
        local b_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
        if minetest.get_node(b_pos).name == "air" or cur_season ~= "winter" then
            --print('Killing snow')
            minetest.remove_node(pos)
        end
    end
})

minetest.register_abm({
    nodenames = {"default:ice"},
    interval = 1.0,
    chance = 5,
    action = function(pos, node)
        if cur_season == "winter" then
            return
        end
        if get_season_time() <= 0.2 then
            -- remove ice
            --if math.random(4) == 1 then
                minetest.add_node(pos, {name = 'default:water_source'})
            --end
        else
            minetest.add_node(pos, {name = 'default:water_source'})
        end
    end
})

minetest.register_on_dignode(function(pos, oldnode, digger)
    if oldnode.name == "default:ice" then
        minetest.add_node(pos, {name = "default:water_source"})
    end
end)

minetest.register_abm({
    nodenames = {"default:leaves"},
    interval = 3.0,
    chance = 1,
    action = function(pos, node)
        if cur_season == "winter" then
            minetest.remove_node(pos)
        end
    end
})

-- auskommentiert, weil keine blätter fallen sollen
minetest.register_abm({
    nodenames = {"seasons:autumn_leaves"--[[, "seasons:autumn_falling_leaves"]]},
    interval = 3.0,
    chance = 1,
    action = function(pos, node)
        if cur_season ~= "autumn" then
            minetest.remove_node(pos)
        end
    end
})

minetest.register_abm({
    nodenames = {"group:flora"},
    neighbors = {"seasons:snow", "default:ice"},
    interval = 3.0,
    chance = 1,
    action = function(pos, node)
        if cur_season == "winter" then
            minetest.remove_node(pos)
        end
    end
})

minetest.register_abm({ --remove puddles
  nodenames = {"seasons:puddle"},
  interval = 10,
  chance = 4,
  action = function(pos, node, _, _)
    minetest.remove_node(pos)
  end,
})

-----------------------------------------------
-- snowfall im Winter und raindrops im Herbst
-----------------------------------------------

-- ToDo: Parameter finden, die nicht benötigt werden

-- snowdrift 0.2.5 by paramat
-- For latest stable Minetest and back to 0.4.6
-- Depends default
-- Licenses: code WTFPL, textures CC BY-SA

-- Parameters

local SCALP = 3 -- Time scale for precipitation in minutes
local PRET = -1 -- -1 to 1. Precipitation threshold: 1 none, -1 continuous, 0 half the time, 0.3 one third the time
local PPPCHA = 0.1 -- 0 to 1. Per player processing chance. Controls and randomizes processing load
local SETCHA = 0.1 -- 0 to 1. Snow settling chance
local PUDCHA = 1 -- 0 to 1. Puddle chance (rain settling)
local DROPS = 16 -- Rainfall heaviness
local SNOW = true -- Snowfall below temperature threshold
local SETTLE = true -- Snow collects on ground within 32 nodes of player
local RAIN = false -- Rain above humidity threshold
local THOVER = false -- Instead use a temperature and humidity system with
            -- snow in overlap of cold and humid areas, else rain in humid areas
            
-- Temperature noise parameters
local SEEDT = 112 -- 112 These are default noise parameters from snow mod by Splizard
local OCTAT = 3  -- 3       use these for snowfall in those snow biomes
local PERST = 0.5 -- 0.5
local SCALT = 150 -- 150
local TET = -0.53 -- -0.53 Temperature threshold for snow

-- Humidity noise parameters
local SEEDH = 72384 -- 72384 These are default noise parameters for mapgen V6 humidity
local OCTAH = 4 -- 4        note these cause rain in deserts
local PERSH = 0.66 -- 0.66
local SCALH = 500 -- 500
local HUT = -4 -- Humidity threshold for rain

-- Stuff

snowdrift = {}

-- Globalstep function

minetest.register_globalstep(function(dtime)
    local perlinp = minetest.get_perlin(813, 1, 0.5, SCALP)
    if perlinp:get2d({x = os.clock()/60, y = 0}) < PRET then
        return
    end 
    for _, player in ipairs(minetest.get_connected_players()) do
        if math.random() > PPPCHA then
            return
        end
        local ppos = player:getpos()
        if minetest.get_node_light(ppos, 0.5) ~= 15 then
            return
        end
        local pposx = math.floor(ppos.x)
        local pposy = math.floor(ppos.y)
        local pposz = math.floor(ppos.z)
        local snow = false
        local rain = false
        local noiset
        local noiseh
        if SNOW or THOVER then
            local perlint = minetest.get_perlin(SEEDT, OCTAT, PERST, SCALT)
            noiset = perlint:get2d({x = pposx, y = pposz})
        end
        if RAIN or THOVER then  
            local perlinh = minetest.get_perlin(SEEDH, OCTAH, PERSH, SCALH)
            noiseh = perlinh:get2d({x = pposx, y = pposz})
        end
        if THOVER then
            if noiset < TET and noiseh > HUT then
                snow = true
            elseif noiseh > HUT then
                rain = true
            end
        elseif SNOW then
            if -noiset < TET then -- negative sign because snow mod noise is 'coldness'
                snow = true
            elseif RAIN then
                if noiseh > HUT then
                    rain = true
                end
            end
        elseif RAIN then
            if noiseh > HUT then
                rain = true
            end
        end
        --if snow then
        if cur_season == "winter" then
            minetest.add_particle(
                {x=pposx-32+math.random(0,63), y=pposy+16, z=pposz-16+math.random(0,63)}, -- posi
                {x=math.random()/5-0.1, y=math.random()/5-1.1, z=math.random()/5-1.1}, -- velo
                {x=math.random()/50-0.01, y=math.random()/50-0.01, z=math.random()/50-0.01}, -- acce
                32,
                2.8,
                false,
                "snowdrift_snowflake1.png",
                player:get_player_name()
            )
            minetest.add_particle(
                {x=pposx-32+math.random(0,63), y=pposy+16, z=pposz-16+math.random(0,63)}, -- posi
                {x=math.random()/5-0.1, y=math.random()/5-1.1, z=math.random()/5-1.1}, -- velo
                {x=math.random()/50-0.01, y=math.random()/50-0.01, z=math.random()/50-0.01}, -- acce
                32,
                2.8,
                false,
                "snowdrift_snowflake2.png",
                player:get_player_name()
            )
            minetest.add_particle(
                {x=pposx-32+math.random(0,63), y=pposy+16, z=pposz-16+math.random(0,63)}, -- posi
                {x=math.random()/5-0.1, y=math.random()/5-1.1, z=math.random()/5-1.1}, -- velo
                {x=math.random()/50-0.01, y=math.random()/50-0.01, z=math.random()/50-0.01}, -- acce
                32,
                2.8,
                false,
                "snowdrift_snowflake3.png",
                player:get_player_name()
            )
            minetest.add_particle(
                {x=pposx-32+math.random(0,63), y=pposy+16, z=pposz-16+math.random(0,63)}, -- posi
                {x=math.random()/5-0.1, y=math.random()/5-1.1, z=math.random()/5-1.1}, -- velo
                {x=math.random()/50-0.01, y=math.random()/50-0.01, z=math.random()/50-0.01}, -- acce
                32,
                2.8,
                false,
                "snowdrift_snowflake4.png",
                player:get_player_name()
            )
            if SETTLE and math.random() < SETCHA then -- settling snow
                local sposx = pposx - 32 + math.random(0, 63)
                local sposz = pposz - 32 + math.random(0, 63)
                if minetest.get_node_light({x=sposx, y=pposy+32, z=sposz}, 0.5) == 15 then -- check under open sky
                    for y = pposy + 32, pposy - 64, -1 do -- find surface
                        local nodename = minetest.get_node({x=sposx, y=y, z=sposz}).name
                        if nodename ~= "air" and nodename ~= "ignore" then
                            if nodename == "default:desert_sand" -- no snow on these
                            or nodename == "default:desert_stone"
                            or nodename == "default:water_source" then
                                break
                            else -- check node drawtype
                                local drawtype = minetest.registered_nodes[nodename].drawtype
                                if drawtype == "normal"
                                or drawtype == "glasslike"
                                or drawtype == "glasslike_framed"
                                or drawtype == "allfaces"
                                or drawtype == "allfaces_optional" then
                                    if nodename == "default:dirt_with_grass" then
                                        minetest.add_node({x=sposx, y=y, z=sposz}, {name="default:dirt_with_snow"})
                                    end
                                    minetest.add_node({x=sposx, y=y+1, z=sposz}, {name="default:snow"})
                                    break
                                elseif drawtype == "plantlike" then -- dirt with snow added under plants
                                    local unodename = minetest.get_node({x=sposx, y=y-1, z=sposz}).name
                                    if unodename == "default:dirt_with_grass" then
                                        minetest.add_node({x=sposx, y=y-1, z=sposz}, {name="default:dirt_with_snow"})
                                    end
                                    break
                                else
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        if cur_season == "autumn" then
            for drop = 1, DROPS do
                minetest.add_particle(
                    {x=pposx-24+math.random(0,48), y=pposy+16, z=pposz-24+math.random(0,48)}, -- posi
                    {x=0, y=-8, z=-1}, -- velo
                    {x=0, y=0, z=0}, -- acce
                    4,
                    2.8,
                    false,
                    "snowdrift_raindrop.png",
                    player:get_player_name()
                )
            end
            if SETTLE and math.random() < PUDCHA then -- settling rain
                local sposx = pposx - 32 + math.random(0, 63)
                local sposz = pposz - 32 + math.random(0, 63)
                if minetest.get_node_light({x=sposx, y=pposy+32, z=sposz}, 0.5) == 15 then -- check under open sky
                    for y = pposy + 32, pposy - 64, -1 do -- find surface
                        local nodename = minetest.get_node({x=sposx, y=y, z=sposz}).name
                        if nodename ~= "air" and nodename ~= "ignore" then
                            if nodename == "default:desert_sand" -- no snow on these
                            or nodename == "default:desert_stone"
                            or nodename == "default:water_source" then
                                break
                            else -- check node drawtype
                                local drawtype = minetest.registered_nodes[nodename].drawtype
                                if drawtype == "normal"
                                or drawtype == "glasslike"
                                or drawtype == "glasslike_framed"
                                or drawtype == "allfaces"
                                or drawtype == "allfaces_optional" then
                                    --[[if nodename == "default:dirt_with_grass" then
                                        minetest.add_node({x=sposx, y=y, z=sposz}, {name="farming:soil"})
                                    end]]
                                    minetest.add_node({x=sposx, y=y+1, z=sposz}, {name="seasons:puddle"}) -- das funktioniert, aber der dirt block färbt sich dunkel und kein Schnee bleibt darauf liegen
                                    break
                                elseif drawtype == "plantlike" then -- dirt with snow added under plants
                                    local unodename = minetest.get_node({x=sposx, y=y-1, z=sposz}).name
                                    if unodename == "default:dirt_with_grass" then
                                        minetest.add_node({x=sposx, y=y-1, z=sposz}, {name="seasons:puddle"})
                                    end
                                    break
                                else
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
