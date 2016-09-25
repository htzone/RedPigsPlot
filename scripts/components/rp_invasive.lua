--[[怪物进攻性 Monster Invasive]]--

local RP_Invasive = Class(function(self, inst)
	self.inst = inst
end)

--帽子列表
local hat_table = {
"hat_football",
"hat_flower",
"hat_spider",
"hat_slurtle",
"hat_beefalo",
"hat_top",
"hat_straw",
"hat_bush",
"hat_walrus",
"hat_winter",
"hat_feather",
}		
	
local brain = require "brains/rp_invade_monsterbrain"
--local brain = require "brains/leifbrain"

--改变攻击目标
local function changeAttackTarget(inst)
	local origCanTarget = inst.components.combat.keeptargetfn
	local function keepTargetOverride(inst, target)
		return inst.components.combat:CanTarget(target)
	end
	inst.components.combat:SetKeepTargetFunction(keepTargetOverride)
	
	local function retargetfn(inst)
		local dist = 40		
		local invader = nil
		invader = FindEntity(inst, dist, function(guy)
			return guy:HasTag("player") or guy:HasTag("king")
			and not guy:HasTag("rp_monster") 
			and not guy:HasTag("wave_monster")
			and not guy:HasTag("shadowboss")
			and not guy:HasTag("playerghost")
		end)
		return invader
	end
	inst.components.combat:SetRetargetFunction(2, retargetfn)
end

--给怪物戴帽子
local function wearHat(inst, hat_type_str)
	inst.AnimState:OverrideSymbol("swap_hat", hat_type_str, "swap_hat")
	inst.AnimState:Show("HAT")
	inst.AnimState:Show("HAT_HAIR")
	inst.AnimState:Hide("HAIR_NOHAT")
	inst.AnimState:Hide("HAIR")
end

--监听怪物攻击
local function onAttack(inst)
	inst:ListenForEvent("onattackother", function(inst,data)
		local target = data.target
	end)
	inst:ListenForEvent("doattack", function(inst,data)
		local target = data.target
	end)
end

--制造普通的入侵的怪物
local function makeMob(inst, health, damage, attackPeriod, size, color, changeAttackFn)
	--添加tag
	rp_addInvasiveMobTag(inst)
	--设置生命值
	if health ~= nil then
		rp_setMaxHealth(inst, health)
	end
	--设置伤害
	if damage ~= nil then
		rp_setCombat(inst, damage, attackPeriod)
	end
	--设置大小
	if size ~= nil then
		rp_setSize(inst, size)
	end
	--设置怪物颜色
	if color ~= nil then
		rp_setColor(inst, color)
	end
	--戴帽子
	wearHat(inst, hat_table[math.random(#hat_table)])
	--改变攻击目标
	changeAttackFn(inst)
	--changeAttackTarget(inst)
	--设置大脑
	inst:SetBrain(nil)
	inst:SetBrain(brain)
	--怪物成长
	if not inst.components.rp_monster_grow then
		inst:AddComponent("rp_monster_grow")
	end
	--自动消失
	if not inst.components.rp_autodelete then
		inst:AddComponent("rp_autodelete")
	end
	inst.components.rp_autodelete:SetPerishTime(60 * 8)
	inst.components.rp_autodelete:StartPerishing()
end

local function makeKing(inst)
end

local function makeCommander(inst)
end

--让怪物具有入侵属性
function RP_Invasive:makeMonster(make_type, health, damage, attackPeriod, size, color, changeAttackFn)
	local monster = self.inst
	if make_type == INVASIVE_MOB then
		makeMob(monster, health, damage, attackPeriod, size, color, changeAttackFn)
		self.inst.makeType = INVASIVE_MOB
		self.inst.isInvasive = true
	elseif make_type == INVASIVE_COMMANDER then
		makeCommander(monster, health, damage, attackPeriod, size, color, changeAttackFn)
		self.inst.makeType = INVASIVE_COMMANDER
		self.inst.isInvasive = true
	elseif make_type == INVASIVE_KING then
		makeKing(monster, health, damage, attackPeriod, size, color, changeAttackFn)
		self.inst.makeType = INVASIVE_KING
		self.inst.isInvasive = true
	end
end

function RP_Invasive:OnSave()
	return
	{
		isInvasive = self.inst.isInvasive, --是否属于入侵怪物
		makeType = self.inst.makeType --入侵的怪物类别
		
	}
end

function RP_Invasive:OnLoad(data)
	if data ~= nil then
		self.inst.isInvasive = data.isInvasive
		self.inst.makeType = data.makeType
		if self.inst.isInvasive then
			self.inst:DoTaskInTime(0, function()
				self:makeMonster(self.inst.makeType)
			end)
		end
	end
end

return RP_Invasive