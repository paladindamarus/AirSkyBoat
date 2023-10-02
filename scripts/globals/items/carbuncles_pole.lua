-----------------------------------
-- ID: 18581
-- Item: Carbuncles Pole
-- Item Effect: Restores 160-170 HP
-----------------------------------
local itemObject = {}

itemObject.onItemCheck = function(target)
    if target:getHP() == target:getMaxHP() then
        return xi.msg.basic.ITEM_UNABLE_TO_USE
    end

    return 0
end

itemObject.onItemUse = function(target)
    local hpHeal = math.random(160, 170)
    local dif = target:getMaxHP() - target:getHP()
    if hpHeal > dif then
        hpHeal = dif
    end

    target:addHP(hpHeal)
    target:messageBasic(xi.msg.basic.RECOVERS_HP, 0, hpHeal)
end

return itemObject
