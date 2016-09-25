--[怪物随时间成长机制]--

--生命的天增长率
local HEALTH_GROW_RATE =  0.05
--大小的天增长率
local SIZE_GROW_RATE = 0.02
--伤害的天增长率
local DAMAGE_GROW_RATE = 0.01

--生命值的增长
local function healthDelta(health, days)
	local delta = 0
	--怪物生命值每天会以XX%的速度成长
	if days > 5 and days <= 100 then
		delta = days * health * HEALTH_GROW_RATE
	end
	if days > 100 then
		delta = health * HEALTH_GROW_RATE * 100
	end
	return delta
end

--大小的增长
local function sizeDelta(size, days)
	local delta = 0
	if days > 5 and days <= 100 then
		delta = days * 1 * SIZE_GROW_RATE
	end
	if days > 100 then
		delta = 1 * SIZE_GROW_RATE * 100
	end
	return delta
end

--伤害的增长
local function damageDelta(damage, days)
	local delta = 0
	if days > 5 and days <= 100 then
		delta = days * damage * DAMAGE_GROW_RATE
	end
	if days > 100 then
		delta = damage * DAMAGE_GROW_RATE * 100
	end
	return delta
end

--根据天数来成长
local function growBaseDays(inst)
	--当前世界天数
	local days = TheWorld.state.cycles
	print("days:"..days)
	--获取各项初始值
	local base_health = rp_getMaxHealth(inst)
	local base_size = rp_getSize(inst)
	local base_damage = rp_getDamage(inst)
	local base_attack_period = rp_getAttackPeriod(inst)
	
	print("--><--base_health:"..base_health..", base_size:"..base_size..", base_damage:"..base_damage)
	
	--成长
	rp_setMaxHealth(inst, (base_health + healthDelta(base_health, days)))
	rp_setSize(inst, (base_size + sizeDelta(base_size, days)))
	rp_setCombat(inst, (base_damage + damageDelta(base_damage, days)))
end

local RP_Monster_Grow = Class(function(self, inst)
	self.inst = inst
	
	growBaseDays(self.inst)
	
	local health = rp_getMaxHealth(inst)
	local size = rp_getSize(inst)
	local damage = rp_getDamage(inst)
	
	print("--><--health:"..health..", size:"..size..", damage:"..damage)
	
end)

--将成长置零
function RP_Monster_Grow:Reset()

end

function RP_Monster_Grow:OnSave()
	return
	{
		
	}
end
	
function RP_Monster_Grow:OnLoad(data)
	if data ~= nil then
		
	end
end

return RP_Monster_Grow