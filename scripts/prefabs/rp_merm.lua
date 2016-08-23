local assets =
{
    Asset("ANIM", "anim/merm_build.zip"),
    Asset("ANIM", "anim/ds_pig_basic.zip"),
    Asset("ANIM", "anim/ds_pig_actions.zip"),
    Asset("ANIM", "anim/ds_pig_attacks.zip"),
    Asset("SOUND", "sound/merm.fsb"),
}

local prefabs =
{
    "fish",
    "froglegs",
}

local loot =
{
    "fish",
    "froglegs",
}

local brain = require "brains/leifbrain"

local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

local function FindInvaderFn(guy)
    return guy:HasTag("character") and not guy:HasTag("merm")
end

local function FindTarget(inst, radius)
    return FindEntity(
        inst,
        SpringCombatMod(radius),
        function(guy)
            return inst.components.combat:CanTarget(guy)
                and not (inst.components.follower ~= nil and inst.components.follower.leader == guy)
        end,
        { "_combat", "character" },
        { "monster", "INLIMBO" }
    )
end

local function RetargetFn(inst)
   return FindTarget(inst, 6)
end

local function keeptargetfn(inst, target)
   return target ~= nil
        and target.components.combat ~= nil
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and not (inst.components.follower ~= nil and
                (inst.components.follower.leader == target or inst.components.follower:IsLeaderSame(target)))
end
--[[
local function KeepTargetFn(inst, target)
    local home = inst.components.homeseeker and inst.components.homeseeker.home
    if home then
        return home:GetDistanceSqToInst(target) < TUNING.MERM_DEFEND_DIST*TUNING.MERM_DEFEND_DIST
               and home:GetDistanceSqToInst(inst) < TUNING.MERM_DEFEND_DIST*TUNING.MERM_DEFEND_DIST
    end
    return inst.components.combat:CanTarget(target)
end
]]--
local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    if attacker and inst.components.combat:CanTarget(attacker) then
        inst.components.combat:SetTarget(attacker)
        local targetshares = MAX_TARGET_SHARES
        if inst.components.homeseeker and inst.components.homeseeker.home then
            local home = inst.components.homeseeker.home
            if home and home.components.childspawner and inst:GetDistanceSqToInst(home) <= SHARE_TARGET_DIST*SHARE_TARGET_DIST then
                targetshares = targetshares - home.components.childspawner.childreninside
                home.components.childspawner:ReleaseAllChildren(attacker)
            end
            inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude)
                return dude.components.homeseeker
                       and dude.components.homeseeker.home
                       and dude.components.homeseeker.home == home
            end, targetshares)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("pigman")
    inst.AnimState:SetBuild("merm_build")
    inst.AnimState:Hide("hat")
	
	inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("leif")
    inst:AddTag("tree")
    inst:AddTag("evergreens")
    inst:AddTag("largecreature")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.MERM_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.MERM_WALK_SPEED

    inst:SetStateGraph("SGmerm")

    inst:SetBrain(brain)

    --inst:AddComponent("eater")
    --inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })

   -- inst:AddComponent("sleeper")
    --inst.components.sleeper:SetNocturnal(true)

    inst:AddComponent("health")
	
	inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.LEIF_DAMAGE)
    inst.components.combat.playerdamagepercent = TUNING.LEIF_DAMAGE_PLAYER_PERCENT
    inst.components.combat.hiteffectsymbol = "pig_torso"
    inst.components.combat:SetAttackPeriod(TUNING.LEIF_ATTACK_PERIOD)
	inst.components.health:SetMaxHealth(TUNING.MERM_HEALTH)
	--[[
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"
    inst.components.combat:SetAttackPeriod(TUNING.MERM_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargdwetFunction(keeptargetfn)
    inst.components.combat:SetDefaultDamage(TUNING.MERM_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.MERM_ATTACK_PERIOD)
]]--
    MakeHauntablePanic(inst)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    --MakeMediumBurnableCharacter(inst, "pig_torso")
    --MakeMediumFreezableCharacter(inst, "pig_torso")
	local r, g, b = HexToPercentColor("#2205BC")
	--设置怪物颜色
	inst.AnimState:SetMultColour(r, g, b, 1)

    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

return Prefab("rp_merm", fn, assets, prefabs)