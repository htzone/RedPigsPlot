	--[[RedPig 2016-06-21]]--
	
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
	--游戏中一天的时间（秒）
	GLOBAL.GAME_DAY = GLOBAL.TUNING.TOTAL_DAY_TIME
	
	--怪物被安置的时间
	GLOBAL.MONSTER_START_POINT_DAY = 1
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
	GLOBAL.BUNNYMAN_HEALTH = 400 --兔人boss生命值
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
	GLOBAL.PIGMAN_HEALTH = 100
	
	modimport("scripts/rp_post_init.lua")
	
	---------------------------------------------------------------------------------------
	--怪物列表
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
	
	--物品列表
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
			inst:AddComponent("rp_pigking_invade") --猪王袭击机制
			--inst:AddComponent("rp_monster_invade")  --怪物入侵机制
			inst:AddComponent("rp_killed_handler") --怪物击杀处理
		end
	end)	

	--自定义物品列表
	local rp_prefab_table = {
	"gravestone",
	}
	
	local function addPrefabAttributes(inst)
		if GLOBAL.TheWorld.ismastersim then
			inst:AddComponent("rp_prefabs")
		end
	end
	
	for _,v in pairs(rp_prefab_table) do
		AddPrefabPostInit(v, addPrefabAttributes) --我的自定义物品
	end