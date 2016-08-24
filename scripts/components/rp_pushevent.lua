--[[推送事件组件]]--
local function OnDeath(inst)
	inst:ListenForEvent("death", function()
		print("猪死了2！！！")
		TheWorld:PushEvent("rp_pigkingbekilled")
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