-----------------------------------
-- Area: The_Shrouded_Maw
--  NPC: MementoCircle
-----------------------------------
local ID = require ("scripts/zones/The_Shrouded_Maw/IDs")
require("scripts/globals/bcnm")
-----------------------------------
local entity = {}

entity.onTrade = function(player, npc, trade)
    xi.bcnm.onTrade(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    xi.bcnm.onTrigger(player, npc)
end

entity.onEventUpdate = function(player, csid, option, extras)
    xi.bcnm.onEventUpdate(player, csid, option, extras)
end

entity.onEventFinish = function(player, csid, option)
    if csid == 32000 then
        local area = player:getLocalVar("[battlefield]area")
        print(string.format("ONEVENTFINISH:  Moving %s to Area %s", player:getName(), area))
        if area >= 1 and area <= 3 then
            -- Set spawn point by area
            local spawnPos = ID.spawn
            player:setPos(spawnPos[area][1], spawnPos[area][2], spawnPos[area][3], 0)
        end
    end

    xi.bcnm.onEventFinish(player, csid, option)
end

return entity
