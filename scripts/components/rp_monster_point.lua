--[[怪物据点 Monster point]]--

local monster_table = {
	--"rocky",
	"pigman",
	--"bunnyman",
	--"merm",
	--"pigguard",
	--"leif_sparse",
	}

--应该放置在那块区域
local tilefns = {}
	
tilefns.rocky = function(tile)
	return (tile == GROUND.ROCKY)
end
	
tilefns.merm = function(tile)
	return (tile == GROUND.MARSH)
end
	
tilefns.pigman = function(tile)
	return (tile == GROUND.DECIDUOUS)
end

tilefns.bunnyman = function(tile)
	return (tile == GROUND.SAVANNA)
end

tilefns.pigguard = function(tile)
	return (tile == GROUND.GRASS)
end

tilefns.leif_sparse = function(tile)
	return (tile == GROUND.FOREST)
end

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

--根据地皮类型来放置Prefab
local function rp_SpawnPrefabInWorldByTile(prefab_name)
print("tilefns--"..#tilefns)

	local b = nil
	local size_x, size_y = TheWorld.Map:GetSize()
	local pt = Vector3(math.random(-size_x, size_x), 0, math.random(-size_y, size_y))
	local tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
	local canspawn = tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID and tile ~= 255
	local tilecheck = tilefns[prefab_name]
	canspawn = canspawn and tilecheck(tile)
	
	if canspawn then
		b = SpawnPrefab(prefab_name)
		b.Transform:SetPosition(pt:Get())
	else
		b = rp_SpawnPrefabInWorldByTile(prefab_name)
	end
	
	return b

end	

local function makePigBrother(monster)
	if monster.prefab == "pigguard" then
		local b = rp_TrySpawn(monster, monster.prefab, 5, 15, 50)
		
		if b and not b.components.follower then
			b:AddComponent("follower")
		end
		b.components.follower:SetLeader(monster)
		
		b:AddTag("little_pig")
		if not b.components.rp_defensive then
			b:AddComponent("rp_defensive")
		end
		b.components.rp_defensive:Make(DEFENSIVE_KING)
		print("little pig spawn")
	end
end

--给玩家任务
local function givePlayerTaskSpeech(task_speech)
	for n,player in pairs(AllPlayers) do 
		if player.components.talker then 
			--player.Transform:SetPosition(x1+3, y1, z1+3)	"★任务：抵御入侵怪物的同时找到并击杀怪物首领"
			player.components.talker:Say(task_speech, 8)
		end 
	end
end

--根据prefab获取boss称号
local function getNameBasePrefab(prefab_name)
	local boss_name = ""
	if prefab_name == "pigman" then
		boss_name = "红猪傀儡"
	elseif prefab_name == "merm" then
		boss_name = "鱼人王"
	elseif prefab_name == "bunnyman" then
		boss_name = "兔人王"
	elseif prefab_name == "rocky" then
		boss_name = "石虾首领"
	elseif prefab_name == "pigguard" then
		boss_name = "野猪兄弟"
	elseif prefab_name == "leif_sparse" then
		boss_name = "树精长老"
	end
	return boss_name
end

--世界在运行 用于初次放置怪物据点
local function updateWorld(world)
	if world.monster_point_mode and TheWorld.state.cycles >= 1 then
		if not world.is_pointed then 
		SpawnPrefab("lightning")
		SpawnPrefab("lightning")
		TheNet:Announce("不好啦，这片大陆已经被怪物首领们占领了！！")
		world:DoTaskInTime(10, function()
			TheNet:Announce("被召唤至此的人们啊，赶快行动起来吧！！！")
		end)
		--givePlayerTaskSpeech("★任务：抵御与反击")
		
		local monster = nil
		
		local start_monster_str = monster_table[math.random(#monster_table)]
		
		if start_monster_str == "pigman" then
			start_monster_str = monster_table[math.random(#monster_table)]
		end
		
		for i = 1, #monster_table do 
			if monster_table[i] == "pigman" then
				monster = rp_SpawnNearPigKing(monster_table[i])
			else
				monster = rp_SpawnPrefabInWorldByTile(monster_table[i])
			end
		    
			makePigBrother(monster)
			
			if not monster.components.rp_defensive then
				monster:AddComponent("rp_defensive")
			end
			monster.components.rp_defensive:Make(DEFENSIVE_KING)
			
			if monster_table[i] == start_monster_str then --随机怪物安置玩家
				for n,player in pairs(AllPlayers) do 
					rp_TrySpawnPlayer(monster, player, 2, 10, 30)
				end
			end
		end
		
		world.is_pointed = true
		end
		--world.components.rp_monster_invade:SetIfCanInvade(false)
	end
	
end

--重新放置怪物据点
local function respawnPointInWorld(monster_str)
	SpawnPrefab("lightning")
	local boss_name = getNameBasePrefab(monster_str)
	TheNet:Announce("恐怖再一次降临，"..boss_name.." 复活了！！！")
	
	local monster = rp_SpawnPrefabInWorldByTile(monster_str)
	makePigBrother(monster)
	
	if not monster.components.rp_defensive then
		monster:AddComponent("rp_defensive")
	end
	monster.components.rp_defensive:Make(DEFENSIVE_KING)
	
	--for n,player in pairs(AllPlayers) do 
	--	rp_TrySpawnPlayer(monster, player, 2, 10, 30)	
	--end
	
end

--为每个被击杀的国王添加一个task用来计算定时恢复入侵和复活
function executeReInvadeTask(inst, monster_name)
	inst.tasks[monster_name] = inst:DoPeriodicTask(2, function ()
		inst.revive_list[monster_name].remain_time = inst.revive_list[monster_name].remain_time - 2
		if inst.revive_list[monster_name].remain_time <= 0 then
			if inst.components.rp_monster_invade then 
				--恢复该类怪物入侵	
				inst.components.rp_monster_invade:RemoveCantInvadeMob(monster_name)
			end 
			inst.revive_list[monster_name].remain_time = BOSS_REVIVE_TIME
				
			respawnPointInWorld(monster_name)
				
			print(monster_name.." success!!")
			if inst.tasks[monster_name] ~= nil then
				inst.tasks[monster_name]:Cancel()
				inst.tasks[monster_name] = nil
				inst.revive_list[monster_name] = nil
				print(monster_name.." cancel success!!")
			end		
		end
	end)
end

--开启重新进攻计时器
local function startReInvadeTimer(inst, data)
	if data.name == "pigman" then
		local monster_name = "pigman"
		executeReInvadeTask(inst, monster_name)
	elseif data.name == "merm" then
		local monster_name = "merm"
		executeReInvadeTask(inst, monster_name)
	elseif data.name == "bunnyman" then
		local monster_name = "bunnyman"
		executeReInvadeTask(inst, monster_name)
	elseif data.name == "rocky" then
		local monster_name = "rocky"
		executeReInvadeTask(inst, monster_name)
	elseif data.name == "pigguard" then
		local monster_name = "pigguard"
		executeReInvadeTask(inst, monster_name)
	elseif data.name == "leif_sparse" then
		local monster_name = "leif_sparse"
		executeReInvadeTask(inst, monster_name)
	end
end

--当怪物国王被击杀时执行
local function onKingBeKilled(inst, data)
	if data then
		if inst.components.rp_monster_invade then
			--停止该类怪物入侵		
			inst.components.rp_monster_invade:AddCantInvadeMob(data.name)
		end 
	
		local revive_item = {}
		revive_item.name = data.name
		revive_item.remain_time = BOSS_REVIVE_TIME
		inst.revive_list[data.name] = revive_item
		
		--启动恢复计时器
		startReInvadeTimer(inst, data)	
		
		inst:DoTaskInTime(20, function()
			local monster_king = TheSim:FindFirstEntityWithTag("pointed_monster_king")
			
			if monster_king then
				print("find monster king success!!"..monster_king.prefab)
				for n,player in pairs(AllPlayers) do 
					rp_TrySpawnPlayer(monster_king, player, 2, 10, 30)	
				end
			else
				print("no find monster king!!")
			end
			
			
		end)
		
		
	end
end

local RP_Monster_Point = Class(function(self, inst)
	self.inst = inst
	self.inst.monster_point_mode = true
	self.inst.is_pointed = false
	self.inst.tasks = {}
	self.inst.revive_list = {}
	self.inst:ListenForEvent("ms_cyclecomplete", function() updateWorld(self.inst) end)
	self.inst:ListenForEvent("rp_kingbekilled", onKingBeKilled)
end)

function RP_Monster_Point:OnSave()
	return
	{
		monster_point_mode = self.inst.monster_point_mode,
		revive_list = self.inst.revive_list,
		is_pointed = self.inst.is_pointed
	}
end
	
function RP_Monster_Point:OnLoad(data)
	if data ~= nil then
		self.inst.monster_point_mode = data.monster_point_mode
		self.inst.revive_list = data.revive_list
		self.inst.is_pointed = data.is_pointed
		--游戏重新加载时，恢复计时任务
		if next(self.inst.revive_list) ~= nil then 
			for k,v in pairs(self.inst.revive_list) do
				if v.remain_time > 0 then
					startReInvadeTimer(self.inst, v)
				end
			end
		end
	end
end

return RP_Monster_Point