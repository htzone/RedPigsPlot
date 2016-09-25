--世界剧情流程

--更新世界
local function updateWorld(world)
	--[[
	if TheWorld.state.cycles > 20 then  
		world.rp_pigking_invasion = false
		world.rp_monster_invade = true
	else
		world.rp_pigking_invasion = true
		world.rp_monster_invade = false
	end
	]]--
	if TheWorld.state.cycles > 1 then  
		world.rp_pigking_invasion = true
	end
end

--[入侵猪王机制]--
local RP_PigKing_Invade = Class(function(self, inst)
	self.inst = inst
	self.inst:ListenForEvent("ms_cyclecomplete", function() updateWorld(self.inst) end)
	
end)

function RP_PigKing_Invade:OnSave()
	return
	{
		rp_pigking_invasion = self.inst.rp_pigking_invasion,
	}
end
	
function RP_PigKing_Invade:OnLoad(data)
	if data ~= nil then
		self.inst.rp_pigking_invasion = data.rp_pigking_invasion
	end
end

return RP_PigKing_Invade