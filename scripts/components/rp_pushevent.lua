--[[推送事件组件]]--
local function OnDeath(inst)
	inst:ListenForEvent("death", function()
		
		--猪王死了
		if inst.prefab == "pigking" then
			SpawnPrefab("lightning")
			TheNet:Announce("猪王已死亡，世界即将陷入一片黑暗中！！！")
			local pigking_grave = SpawnPrefab("gravestone")
			local pt = Vector3(inst.Transform:GetWorldPosition())
			if pigking_grave and pigking_grave.Transform then
				pigking_grave.Transform:SetPosition(pt:Get())
				pigking_grave:AddTag("pigking_grave")
				if not pigking_grave.components.rp_prefabs then
					pigking_grave:AddComponent("rp_prefabs")
				end
				pigking_grave.components.rp_prefabs:makePrefab() --定制prefab
			end
			TheWorld:PushEvent("rp_pigkingbekilled")
		end

	end)
end

local RP_PushEvent = Class(function(self, inst)
	self.inst = inst
	OnDeath(self.inst)
end)

function RP_PushEvent:OnSave()
	return
	{

	}
end

function RP_PushEvent:OnLoad(data)
	if data ~= nil then

	end
end

return RP_PushEvent