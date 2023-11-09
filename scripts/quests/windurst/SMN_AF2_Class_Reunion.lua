-----------------------------------
-- Class Reunion
-- !addquest 2 82
-- Koru-Moru !pos -120 -6 124 239
-- Fuepepe !gotoid 17752118
-- Furakku-Norakku !gotoid 17752081
-- Shantotto !gotoid 17756186
-- Gulmama !gotoid 17723592
-----------------------------------
require('scripts/globals/npc_util')
require('scripts/globals/quests')
require('scripts/globals/zone')
require('scripts/globals/interaction/quest')
-----------------------------------

local quest = Quest:new(xi.quest.log_id.WINDURST, xi.quest.id.windurst.CLASS_REUNION)

quest.reward =
{
    item        = xi.items.EVOKERS_SPATS,
    fame        = 40,
    fameArea    = xi.quest.fame_area.WINDURST,
}

quest.sections =
{
    --Section: Quest Available
    {
        check = function(player, status, vars)
            return status == QUEST_AVAILABLE and
                player:getMainLvl() >= xi.settings.main.AF2_QUEST_LEVEL and
                player:getMainJob() == xi.job.SMN and
                not quest:getMustZone(player) and
                player:getQuestStatus(xi.quest.log_id.WINDURST, xi.quest.id.windurst.THE_PUPPET_MASTER) == QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WALLS] =
        {
            ['_6n2'] = quest:progressEvent(413),

            onEventFinish =
            {
                [413] = function(player, csid, option, npc)
                    quest:begin(player)
                    npcUtil.giveKeyItem(player, xi.ki.CARBUNCLES_TEAR)
                    quest:setVar(player, 'Prog', 1)
                end
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == QUEST_ACCEPTED
        end,

        --Section: Quest Accepted

        [xi.zone.WINDURST_WALLS] =
        {
            ['Koru-Moru'] =
            {
                onTrigger = function(player, npc)
                    local questProgress = quest:getVar(player, 'Prog')

                    if questProgress == 1 then
                        return quest:progressEvent(412, 0, xi.ki.CARBUNCLES_TEAR, xi.items.ASTRAGALOS)
                    elseif questProgress == 2 then
                        return quest:event(414)
                    elseif
                        questProgress == 6 and
                        quest:getVar(player, 'taruTalk1') == 1 and
                        quest:getVar(player, 'taruTalk2') == 1
                    then
                        return quest:progressEvent(410)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if
                        quest:getVar(player, 'Prog') == 2 and
                        npcUtil.tradeHasExactly(trade, { { xi.items.ASTRAGALOS, 4 } })
                    then
                        return quest:progressEvent(407)
                    end
                end,
            },

            ['Shantotto'] =
            {
                onTrigger = function(player, npc)
                    local questProgress = quest:getVar(player, 'Prog')

                    if questProgress == 3 then
                        return quest:progressEvent(409)
                    end
                end,
            },

            onEventFinish =
            {
                [407] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:setVar(player, 'Prog', 3)
                end,

                [409] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 4)
                end,

                [410] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        xi.quest.setMustZone(player, xi.quest.log_id.WINDURST, xi.quest.id.windurst.CARBUNCLE_DEBACLE)
                    end
                end,

                [412] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.CARBUNCLES_TEAR)
                    quest:setVar(player, 'Prog', 2)
                end,
            },
        },

        [xi.zone.WINDURST_WATERS] =
        {
            ['Fuepepe'] =
            {
                onTrigger = function(player, npc)
                    if
                        quest:getVar(player, 'Prog') >= 3 and
                        quest:getVar(player, 'taruTalk1') ~= 1
                    then
                        return quest:progressEvent(817)
                    end
                end,
            },

            ['Furakku-Norakku'] =
            {
                onTrigger = function(player, npc)
                    if
                        quest:getVar(player, 'Prog') >= 3 and
                        quest:getVar(player, 'taruTalk2') ~= 1
                    then
                        return quest:progressEvent(816)
                    end
                end,
            },

            onEventFinish =
            {
                [816] = function(player, csid, option, npc)
                    quest:setVar(player, 'taruTalk2', 1)
                end,

                [817] = function(player, csid, option, npc)
                    quest:setVar(player, 'taruTalk1', 1)
                end,
            },
        },

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Gulmama'] =
            {
                onTrigger = function(player, npc)
                    local questProgress = quest:getVar(player, 'Prog')

                    if questProgress == 4 then
                        return quest:progressEvent(713, 0, xi.items.ICE_PENDULUM)
                    elseif
                        questProgress == 5 and
                        not player:hasItem(xi.items.ICE_PENDULUM)
                    then
                        return quest:progressEvent(712, 0, xi.items.ICE_PENDULUM)
                    end
                end,
            },

            onEventFinish =
            {
                [713] = function(player, csid, option, npc)
                    npcUtil.giveItem(player, xi.items.ICE_PENDULUM)
                    quest:setVar(player, 'Prog', 5)
                end,

                [712] = function(player, csid, option, npc)
                    npcUtil.giveItem(player, xi.items.ICE_PENDULUM)
                end,
            },
        },
    },
}

return quest
