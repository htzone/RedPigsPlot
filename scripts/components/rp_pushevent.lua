--[[推送事件组件]]--
local function OnDeath(inst)
	inst:ListenForEvent("death", function()
	
		local data = {}
		data.name = inst.prefab
		data.pt = Vector3(inst.Transform:GetWorldPosition())

		--猪王死了
		if inst.prefab == "pigking" then
			TheWorld:PushEvent("rp_pigkingbekilled", data)
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