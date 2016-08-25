--主要负责猪王周围进攻怪物的安置

--将怪物安置在猪王周边
local function rp_SpawnNearPigKing(prefab_name)
	local monster = nil 
	local pig_king = TheSim:FindFirstEntityWithTag("king")
	if pig_king then
		print("find pigking!!!")
		local x1, y1, z1 = pig_king.Transform:GetWorldPosition()
		monster = rp_TrySpawn(pig_king, prefab_name, 4, 10, 50)	
	else
		print("no find pigking!!")
	end
	return monster
end

--更新世界
local function updateWorld(world)
	
	if TheWorld.state.cycles == 1 then
		for n,player in pairs(AllPlayers) do 
			rp_SpawnPlayerNearPigKing(player)
		end
	end
	
	if TheWorld.state.cycles > 1 and TheWorld.state.cycles % 2 == 0 then  
		for i = 1, 3 do 
			SpawnPrefab("lightning")
			local monster = rp_SpawnPrefabNearPigKing("merm")
		end
	end
	
end

--[入侵猪王机制]--
local RP_PigKing_Monster_Point = Class(function(self, inst)
	self.inst = inst
	self.inst:ListenForEvent("ms_cyclecomplete", function() updateWorld(self.inst) end)
	
end)

function RP_PigKing_Monster_Point:OnSave()
	return
	{
		
	}
end
	
function RP_PigKing_Monster_Point:OnLoad(data)
	if data ~= nil then
		
	end
end

return RP_PigKing_Monster_Point