-----------------------------------
-- Area: The Shrouded Maw
--  Mob: Diabolos
-----------------------------------
local ID = require("scripts/zones/The_Shrouded_Maw/IDs")
mixins = {require("scripts/mixins/job_special")}
-----------------------------------
local entity = {}

-- TODO: CoP Diabolos
-- 1) Make the diremites in the pit all aggro said player that falls into region. Should have a respawn time of 10 seconds.
-- 2) Diremites also shouldnt follow you back to the fight area if you make it there. Should despawn and respawn instantly if all players
--    make it back to the Diabolos floor area.
-- 3) ANIMATION Packet ids for instance 2 and 3 are wrong (needs guesswork). Sounds working.
--    Update 2018-01-02 these no longer seem to work for any instance. neither animation nor sound.

-- TODO: Diabolos Prime
-- Note: Diabolos Prime fight drops all tiles at once.

entity.onMobSpawn = function(mob)
    local dBase = ID.mob.DIABOLOS_OFFSET
    local dPrimeBase = dBase + 27

    -- Determine which group of Diabolos is being called
    if mob:getID() >= dPrimeBase then dBase = dPrimeBase end  -- Prime "block" of mobs is offset 27 from CoP mobs
    local area = utils.clamp((mob:getID() - dBase) / 7 + 1, 1, 3)  -- Area should calculate to 1, 2, or 3 only

    -- Tile Drop Trigger:  Max HPP = 74%, Min HPP = 20%, central tendency of ~47%
    local triggerVal = math.random(2, 29) + math.random(2, 29) + 16

    mob:setLocalVar("TileTriggerHPP", triggerVal) -- Starting point for tile drops
    mob:setLocalVar("Area", area)                 -- Determined area based on which ID spawned
    mob:setMobMod(xi.mobMod.DRAW_IN, 1)

    -- Only add these for the CoP Diabolos NOT Prime
    local copDiabolos = ID.mob.DIABOLOS_OFFSET
    if mob:getID() >= copDiabolos and mob:getID() <= copDiabolos + 14 then  -- three possible instances of Diabolos
        mob:addMod(xi.mod.INT, -50)
        mob:addMod(xi.mod.MND, -50)
        mob:addMod(xi.mod.ATTP, -15)
        mob:addMod(xi.mod.DEFP, -15)
        mob:addMod(xi.mod.MDEF, -40)
    end

    -- Configure Ruinous Omen
    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            {id = 1911},
        }
    })

    -- Print debug data
    print(string.format("Diabolos ID: %s | Area: %s", mob:getID(), area))
end

entity.onMobFight = function(mob, target)
    local area = mob:getLocalVar("Area") - 1 
    local trigger = mob:getLocalVar("TileTriggerHPP")
    local hpp = math.floor(mob:getHP()*100/mob:getMaxHP())
    
    local tileDrops =
        {   -- {Animation Area 1, Animation Area 2, Animation Area 3}
            {"byc8", "bya8", "byb8"},
            {"byc7", "bya7", "byb7"},
            {"byc6", "bya6", "byb6"},
            {"byc5", "bya5", "byb5"},
            {"byc4", "bya4", "byb4"},
            {"byc3", "bya3", "byb3"},
            {"byc2", "bya2", "byb2"},
            {"byc1", "bya1", "byb1"},
        }


    if hpp < trigger then   -- Trigger the tile drop events
        mob:setLocalVar("TileTriggerHPP", -1)            -- Prevent tiles from being dropped twice
        local tileBase = ID.npc.DARKNESS_NAMED_TILE_OFFSET + area * 8
 
        for offset, animationSet in ipairs(tileDrops) do
            local tileId = tileBase + offset - 1
            local tile = GetNPCByID(tileId)

            if tile:getLocalVar("Dropped") ~= xi.anim.OPEN_DOOR then
                tile:setLocalVar("Dropped", xi.anim.OPEN_DOOR)

                -- All players within zone need to receive packet to indicate the tile drop or the client will not render
                SendEntityVisualPacket(tileId, animationSet[area + 1], 3)                -- Animation for floor dropping
                -- SendEntityVisualPacket(tileId, "s123", 3)                                -- Tile dropping sound (TODO)
                tile:timer(2750, function(tile)                                          -- 2.7s second delay (ish)
                    tile:updateToEntireZone(xi.status.NORMAL, xi.anim.OPEN_DOOR, true)   -- Floor opens
                end)
                tile:timer(5000, function(tile)
                    tile:setStatus(xi.status.DISAPPEAR)
                end)
            end
        end
    end


    --[[ Previous LSB Version
    local mobOffset = mob:getID() - ID.mob.DIABOLOS_OFFSET
    if (mobOffset >= 0 and mobOffset <= 14) then
        local inst = math.floor(mobOffset/7)

        local hpp = ((mob:getHP()/mob:getMaxHP())*100)
        for k, v in pairs(tileDrops) do
            if (hpp < v[1]) then
                local tileId = ID.npc.DARKNESS_NAMED_TILE_OFFSET + (inst * 8) + (k - 1)
                local tile = GetNPCByID(tileId)
                if (tile:getAnimation() == xi.anim.CLOSE_DOOR) then
                    SendEntityVisualPacket(tileId, v[inst+2])  -- Animation for floor dropping
                    SendEntityVisualPacket(tileId, "s123")     -- Tile dropping sound
                    tile:timer(5000, function(tileArg)
                        tileArg:setAnimation(xi.anim.OPEN_DOOR)     -- Floor opens
                    end)
                end
                break
            end
        end
    end --]]
end

entity.onMobDeath = function(mob, player, isKiller)
end

return entity
