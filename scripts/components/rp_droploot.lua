--[设置怪物掉落]--
local RP_DropLoot = Class(function(self, inst)
	self.inst = inst
end)

function RP_DropLoot:setLoot(weighted_table, min_loot_num, max_loot_num, chance)
	local loot_num = 1
	
	if min_loot_num == nil then
		min_loot_num = 1
	end
	
	if max_loot_num == nil then
		max_loot_num = min_loot_num
	end
	
	if chance == nil then
		chance = 1
	end
	
	if min_loot_num < 0 or max_loot_num < min_loot_num then
		loot_num = 0
	else
		loot_num = math.floor(math.random(min_loot_num, max_loot_num))
		if math.random() < chance then
			loot_num = loot_num
		else
			loot_num = 0
		end
	end
	
	if not self.inst.components.lootdropper then
		self.inst:AddComponent("lootdropper")
	end
	
	if self.inst.components.lootdropper.loot then 
		self.inst.components.lootdropper:SetLoot(nil)
	end
	
	if self.inst.components.lootdropper.lootsetupfn then
		self.inst.components.lootdropper:SetLootSetupFn(nil)
	end
	
	if self.inst.components.lootdropper.chanceloottable then
		local loot_table = LootTables[self.inst.components.lootdropper.chanceloottable]
		if loot_table then
			self.inst.components.lootdropper:SetChanceLootTable(nil)
		end
	end

	local loot_item 
	local loot = {}
	for i=1, loot_num do
		loot_item = rp_weighted(weighted_table)
		table.insert(loot, loot_item)
	end
	self.inst.components.lootdropper:SetLoot(loot)
	
	self.inst.rp_isSetedLoot = true
	self.inst.rp_weighted_table = weighted_table
	self.inst.rp_min_loot_num = min_loot_num
	self.inst.rp_max_loot_num = max_loot_num
	
end

function RP_DropLoot:OnSave()
	return
	{
		isSetedLoot = self.inst.rp_isSetedLoot,
		weighted_table = self.inst.rp_weighted_table,
		min_loot_num = self.inst.rp_min_loot_num,
		max_loot_num = self.inst.rp_max_loot_num,
	}
end
	
function RP_DropLoot:OnLoad(data)
	if data ~= nil then
		if data.isSetedLoot == true then
			self.inst:DoTaskInTime(0, function()
				self:setLoot(data.weighted_table, data.min_loot_num, data.max_loot_num)
			end)
		end
	end
end

return RP_DropLoot