-----------------------------------
-- Nether Blast
-- Ranged Attack
-- Deals a ranged attack to a single target.
-----------------------------------
require("scripts/globals/mobskills")
-----------------------------------
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    -- Ranged attack only used when target is out of range
    if
        mob:checkDistance(target) > 2 or
        skill:getID() == 1910 -- Diabolos Dynamis Tavnazia doesnt care about range
    then
        return 0
    else
        return 1
    end
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local multiplier = 5
    -- Diabolos Dynamis Tavnazia tosses nether blast for ~1k
    if skill:getID() == 1910 then
        multiplier = 10
    end

    local dmg = mob:getMainLvl() * multiplier + 10 -- http://wiki.ffo.jp/html/4045.html
    local dmgmod = 1
    local ignoreres = true

    local info = xi.mobskills.mobMagicalMove(mob, target, skill, dmg, xi.magic.ele.DARK, dmgmod, xi.mobskills.magicalTpBonus.NO_EFFECT, ignoreres)

    dmg = xi.mobskills.mobFinalAdjustments(info.dmg, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.DARK, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(dmg, mob, xi.attackType.MAGICAL, xi.damageType.DARK)
    return dmg
end

return mobskillObject
