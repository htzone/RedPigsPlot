--[[制造人形怪 RP_Players]]--

local RP_Players = Class(function(self, inst)
	self.inst = inst
	self.inst.isMakePlayer = nil
end)

----	武器样式
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_spear", "swap_spear")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end
local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

----	武器栏
local function GetInventory(inst)
    if inst.components.inventory ~= nil and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local meleeweapon = CreateEntity()
        meleeweapon.entity:AddTransform()
        meleeweapon:AddComponent("weapon")
        meleeweapon.components.weapon:SetDamage(17)
        meleeweapon:AddComponent("inventoryitem")
        meleeweapon.persists = false
        meleeweapon.components.inventoryitem:SetOnDroppedFn(inst.Remove)
        meleeweapon:AddComponent("equippable")
		----	武器外观
		meleeweapon.components.equippable:SetOnEquip(onequip)
		meleeweapon.components.equippable:SetOnUnequip(onunequip)
        meleeweapon:AddTag("meleeweapon")
		inst.components.inventory:Equip(meleeweapon)
    end
end

function RP_Players:makePlayer()
	self.inst.isMakePlayer = true
	self.inst.AnimState:SetBank("wilson")
	self.inst.AnimState:SetBuild("wilson")
	self.inst.AnimState:PlayAnimation("idle")
	self.inst.AnimState:OverrideSymbol("swap_hat", "hat_feather", "swap_hat")
	self.inst.AnimState:Show("HAT")
	self.inst.AnimState:Show("HAT_HAIR")
	self.inst.AnimState:Hide("HAIR_NOHAT")
	self.inst.AnimState:Hide("HAIR")
	self.inst.AnimState:OverrideSymbol("swap_body", "armor_wood", "swap_body")
	self.inst.AnimState:OverrideSymbol("beard", "beard", "beard_long")
	
	self.inst:SetStateGraph("SGzg_ch_waxwell")
	local brain = require "brains/zg_ch_wickerbrain"	
    self.inst:SetBrain(brain)
	
	GetInventory(self.inst)
	
	local currentscale = self.inst.Transform:GetScale()
	self.inst.Transform:SetScale(currentscale*2,currentscale*2,currentscale*2)
	
	self.inst.components.health:SetMaxHealth(1000)
	self.inst.components.health:StartRegen(400, 100)
	self.inst.components.combat:SetDefaultDamage(40)
	self.inst.components.combat:SetAttackPeriod(2)
	
end

function RP_Players:OnSave()
	
	return
	{
		isMakePlayer = self.inst.isMakePlayer
	}
end

function RP_Players:OnLoad(data)
	if data ~= nil then
		if data.isMakePlayer then
			self.inst:DoTaskInTime(2, function()	
				SpawnPrefab("lightning").Transform:SetPosition(self.inst.Transform:GetWorldPosition())
				self:makePlayer()
			end)
		end
	end
end

return RP_Players