	--[[RedPig]]--
	
	--PrefabFiles = {
	--"rp_merm",
	--}
	
	local require = GLOBAL.require
	local SpawnPrefab = GLOBAL.SpawnPrefab
	local COLLISION = GLOBAL.COLLISION
	
	require "rp_debug"
	require "rp_utils"
	
	--GLOBAL.GAME_DIFFICULTY = GetModConfigData("invade_style")
	--------------【声明全局变量】--------------
	--进攻怪物类型
	GLOBAL.INVASIVE_MOB = 1
	GLOBAL.INVASIVE_COMMANDER = 2
	GLOBAL.INVASIVE_KING = 3
	
	--防御怪物类型
	GLOBAL.DEFENSIVE_MOB = 1
	GLOBAL.DEFENSIVE_COMMANDER = 2
	GLOBAL.DEFENSIVE_KING = 3
	
	--boss复活时间(秒)
	GLOBAL.BOSS_REVIVE_TIME = 1000
	
	--兔人boss相关
	GLOBAL.BUNNYMAN_HEALTH = 8000 --兔人boss生命值
	GLOBAL.BUNNYMAN_HYPONSIS_COOLDOWN = 8 --催眠冷却时间
	GLOBAL.BUNNYMAN_LIGHTING_COOLDOWN = 8 --落雷冷却时间
	GLOBAL.BUNNYMAN_HYPONSIS_RANGE = 20 --催眠范围
	GLOBAL.BUNNYMAN_LIGHTING_RANGE = 8 --落雷范围
	
	--鱼人boss相关
	GLOBAL.MERM_HEALTH = 8000 --鱼人boss生命值
	GLOBAL.MERM_TOGGLE_COOLDOWN = 8 --鱼人攻击方式转变时间
	
	--石虾boss相关
	GLOBAL.ROCKY_HEALTH = 8000--石虾boss生命值 
	--GLOBAL.ROCKY_GROUNDPOUND_COOLDOWN = 5 --拍地板冷却时间
	GLOBAL.ROCKY_CALLMETEOR_COOLDOWN = 8 --召唤流星雨冷却时间
	
	--野猪兄弟boss相关
	GLOBAL.LITTLE_PIGBROTHER_HEALTH = 6000 --小野猪boss生命值
	GLOBAL.BIG_PIGBROTHER_HEALTH = 8000 --大野猪boss生命值 	
	
	--树人boss相关
	GLOBAL.LEIF_HEALTH = 8000
	GLOBAL.LEIF_EARTHQUACK_COOLDOWN = 6 --大地颤怒冷却时间
	--GLOBAL.LEIF_ROOTTHORN_COOLDOWN = 2 
	
	--猪人boss相关
	GLOBAL.PIGMAN_HEALTH = 200
	
	modimport("scripts/rp_post_init.lua")
	
	---------------------------------------------------------------------------------------
	local monster_table = {
		"pigman",
		"merm",
		"bunnyman",
		"rocky",
		"pigguard",
		"leif_sparse",
		"leif",
		"spider",
	}
	
	local goods_table = {
		"poop",
	}
	
	--添加怪物潜在属性
	local function addAttributes_1(inst)
		if GLOBAL.TheWorld.ismastersim then
			inst:AddComponent("rp_invasive") --入侵性
			inst:AddComponent("rp_defensive") --防御性
			inst:AddComponent("rp_autodelete") --自动消失
		end
	end
	
	local function addAttributes_2(inst)
		if GLOBAL.TheWorld.ismastersim then
			inst:AddComponent("rp_autodelete") --自动消失
		end
	end
	
	--------------PrefabPostInit------------
	for k,v in pairs(monster_table) do
		AddPrefabPostInit(v, addAttributes_1) --让怪物们具有新特性的潜质
	end
	
	for k,v in pairs(goods_table) do
		AddPrefabPostInit(v, addAttributes_2) --让物品具有新特性的潜质
	end
	
	--[[
	AddSimPostInit(function()
		if GLOBAL.TheWorld.ismastersim then
			GLOBAL.TheWorld:DoTaskInTime(12, function()
				local pig_king = GLOBAL.TheSim:FindFirstEntityWithTag("king")
				if pig_king then
					local x1, y1, z1 = pig_king.Transform:GetWorldPosition()
					print("find pigking!!!")
					
					for i, player in ipairs(GLOBAL.AllPlayers) do
						print("spawned!-----postion:("..x1..", "..y1..", "..z1..")")
						player.Transform:SetPosition(x1+3, y1, z1+2)
					end		

					local pigmanking = GLOBAL.rp_TrySpawn(pig_king, "pigman", 4, 10, 50)
					
					if not pigmanking.components.rp_defensive then
						print("add_defensive!!!")
						pigmanking:AddComponent("rp_defensive")
					end
					
					pigmanking.components.rp_defensive:Make(DEFENSIVE_KING)
					--if not pigmanking.components.rp_pigmanking then
					--	pigmanking:AddComponent("rp_pigmanking")
					--end
				else
					print("no find pigking!!")
				end
			end)

		end
	end)
	]]--
	
	--针对玩家
	AddPlayerPostInit(function(inst)
		if inst then
			if GLOBAL.TheWorld.ismastersim then
				--inst:AddComponent("rp_monster_attack") --怪物袭击机制
				if not inst.components.rp_upgrade then
					inst:AddComponent("rp_upgrade") --玩家升级组件
					inst.components.rp_upgrade:make()
				end
				
				if not inst.components.rp_buff then --玩家buff组件
					inst:AddComponent("rp_buff")
				end
			end
		end
	end)
	
	--针对世界
	AddPrefabPostInit("world", function(inst)
		if inst.ismastersim then
			inst:AddComponent("rp_monster_point") --怪物据点机制
			--inst:AddComponent("rp_monster_invade")  --怪物入侵机制
			inst:AddComponent("rp_killed_handler") --怪物击杀处理
		end
	end)	

	--[[
	local function addGoodsAttributes(inst)
		if GLOBAL.TheWorld.ismastersim then
			inst:AddComponent("rp_goods")
		end
	end
	
	AddPrefabPostInit("batbat", addGoodsAttributes)
	]]--