-----------------------------------
-- Zone: Castle_Oztroja (151)
-----------------------------------
local oztrojaGlobal = require('scripts/zones/Castle_Oztroja/globals')
local ID = require('scripts/zones/Castle_Oztroja/IDs')
require('scripts/globals/conquest')
require('scripts/globals/treasure')
require('scripts/globals/zone')
-----------------------------------
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    -- NM Persistence
    local timeOfDeath = GetServerVariable("[POP]Tzee_Xicu_the_Manifest")
    local popNow      = GetServerVariable("[POPNUM]Tzee_Xicu_the_Manifest") == 4

    if os.time() > timeOfDeath and popNow then
        xi.mob.nmTODPersistCache(zone, ID.mob.TZEE_XICU_THE_MANIFEST)
    else
        xi.mob.nmTODPersistCache(zone, ID.mob.YAGUDO_AVATAR)
    end

    oztrojaGlobal.pickNewCombo() -- update combination for brass door on floor 2
    oztrojaGlobal.pickNewPassword() -- update password for trap door on floor 4

    xi.treasure.initZone(zone)
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(-239.447, -1.813, -19.98, 250)
    end

    return cs
end

zoneObject.onConquestUpdate = function(zone, updatetype, influence, owner, ranking, isConquestAlliance)
    xi.conq.onConquestUpdate(zone, updatetype, influence, owner, ranking, isConquestAlliance)
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
end

zoneObject.onGameHour = function(zone)
    local vanadielHour = VanadielHour()

    -- every game day
    if vanadielHour % 24 == 0 then
        oztrojaGlobal.pickNewCombo() -- update combination for brass door on floor 2
        oztrojaGlobal.pickNewPassword() -- update password for trap door on floor 4
    end
end

zoneObject.onEventUpdate = function(player, csid, option)
end

zoneObject.onEventFinish = function(player, csid, option)
end

return zoneObject
