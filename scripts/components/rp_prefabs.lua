--[[怪物防御性 Monster Defensive]]--

--猪王的坟墓
local function rp_pigking_grave(inst)
	inst.mound = nil
	local r, g, b = HexToPercentColor("#FF0705")
	inst.AnimState:SetMultColour(r, g, b, 1)
	local currentscale = inst.Transform:GetScale()
	inst.Transform:SetScale(currentscale*3,currentscale*3,currentscale*3)
	inst.entity:AddLight() 
	inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.6)
    inst.Light:SetRadius(4)
    inst.Light:Enable(true)
	--inst.Light:SetColour(r, g, b)
    inst.Light:SetColour(180/255, 195/255, 50/255)
	if inst.Transform then
		local x, y, z = inst.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 4)
		for _,obj in pairs(ents) do
			if obj and obj.prefab == "mound" then
				obj:Remove()
				break
			end
		end
	end
end

local LOOTS =
{
	teleportato_potato = 1, --头
	teleportato_ring = 1, --环
	teleportato_box =1, --盒
	teleportato_crank = 1, --柄
	ghost = 1,
	minotaurhorn = 1,
	deerclops_eyeball = 1,
	bearger_fur = 1,
	dragon_scales = 1,
	lavae_egg = 1,
}

--修改坟墓挖出的东西
local function onfinishcallback(inst, worker)
    inst.AnimState:PlayAnimation("dug")
    inst:RemoveComponent("workable")

    if worker ~= nil then
        if worker.components.sanity ~= nil then
            worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
        end
		
		local item = nil
		
		item = weighted_random_choice(LOOTS)

		if item ~= nil then
			inst.components.lootdropper:SpawnLootPrefab(item)
		end

    end
end

--怪物boss的坟墓
local function rp_monsterking_grave(inst)
	--设置外形
	if inst.color then
		local r, g, b = HexToPercentColor(inst.color)
		inst.AnimState:SetMultColour(r, g, b, 1)
	end
	local currentscale = inst.Transform:GetScale()
	inst.Transform:SetScale(currentscale*2.5,currentscale*2.5,currentscale*2.5)
	--设置掉落物
	inst.mound.components.workable:SetOnFinishCallback(onfinishcallback)
	--自动删除
	if not inst.components.rp_autodelete then
		inst:AddComponent("rp_autodelete")
	end
	if not inst.mound.components.rp_autodelete then
		inst.mound:AddComponent("rp_autodelete")
	end
	inst.components.rp_autodelete:SetPerishTime(GAME_DAY)
	inst.components.rp_autodelete:StartPerishing()
	inst.mound.components.rp_autodelete:SetPerishTime(GAME_DAY)
	inst.mound.components.rp_autodelete:StartPerishing()
	
end

local function rp_teleportato_base(inst)
	local r, g, b = HexToPercentColor("#000000")
	inst.AnimState:SetMultColour(r, g, b, .8)
end

local RP_Prefabs = Class(function(self, inst)
	self.inst = inst
	self.inst.is_rp_prefab = false
	self.inst.tag = nil 
end)

--自定义prefab
function RP_Prefabs:makePrefab()
	self.inst.is_rp_prefab = true
	
	if self.inst.prefab == "gravestone" and self.inst:HasTag("pigking_grave") then
		self.inst.tag = "pigking_grave"
		rp_pigking_grave(self.inst)
	elseif self.inst.prefab == "gravestone" and self.inst:HasTag("monsterking_grave") then
		self.inst.tag = "monsterking_grave"
		rp_monsterking_grave(self.inst)
	elseif self.inst.prefab == "teleportato_base" then
		rp_teleportato_base(self.inst)
 	end
 	
end

--设置颜色
function RP_Prefabs:setColor(color)
	self.inst.color = color
end

function RP_Prefabs:OnSave()
	
	return
	{
		is_rp_prefab = self.inst.is_rp_prefab,
		tag = self.inst.tag, 
		color = self.inst.color
	}
end

function RP_Prefabs:OnLoad(data)
	if data ~= nil then
	
		if data.tag then
			self.inst:AddTag(data.tag)
		end
		
		if data.is_rp_prefab then
			self:makePrefab()
		end
		
		if data.color then
			self.inst.color = data.color
		end
		
	end
end

return RP_Prefabs