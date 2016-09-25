	--[[By RedPig 2016-06-21]]--
	
	local require = GLOBAL.require
	local SpawnPrefab = GLOBAL.SpawnPrefab
	local COLLISION = GLOBAL.COLLISION
	local AllPlayers = GLOBAL.AllPlayers
	
	-------------【依赖文件】--------------
	require "rp_debug"
	require "rp_utils"
		
	-------------【导入文件】--------------
	modimport("rp_global")
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
		"walrus",
		"knight",
		"worm",
		"firehound",
		"spider_spitter",
		"tallbird",
	}
	
	--物品列表
	local goods_table = {
		"poop",
	}
	
	--添加怪物潜在属性
	local function addAttributes_monster(inst)
		if GLOBAL.TheWorld.ismastersim then
		
			inst:AddComponent("rp_invasive") --入侵性
			inst:AddComponent("rp_defensive") --防御性
			inst:AddComponent("rp_autodelete") --自动消失
			inst:AddComponent("rp_players") --人形怪
			inst:AddComponent("rp_droploot") --掉落

		end
	end
	
	local function addAttributes_goods(inst)
		if GLOBAL.TheWorld.ismastersim then
			inst:AddComponent("rp_autodelete") --自动消失
		end
	end
	
	--------------PrefabPostInit------------
	for k,v in pairs(monster_table) do
		AddPrefabPostInit(v, addAttributes_monster) --让怪物们具有新特性的潜质
	end
	
	for k,v in pairs(goods_table) do
		AddPrefabPostInit(v, addAttributes_goods) --让物品具有新特性的潜质
	end
	
	--出生点测试
	AddPrefabPostInit("multiplayer_portal", function(inst)
		inst:DoTaskInTime(3, function()
			
			local player_monster = GLOBAL.rp_TrySpawn(inst, "pigman", 5, 15, 40)
			SpawnPrefab("lightning").Transform:SetPosition(player_monster.Transform:GetWorldPosition())
			
			if not player_monster.components.rp_players then
				player_monster:AddComponent("rp_players")
			end
			player_monster.components.rp_players:makePlayer()
			
		end)
		
		--inst:DoTaskInTime(15, function()
		--	local prefab = TheSim:FindFirstEntityWithTag("rp_redpig")
			
			
		--end)
		
	end)
	
	
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
			inst:AddComponent("rp_plot") --开启剧本
			inst:AddComponent("rp_monster_point") --怪物据点机制
			inst:AddComponent("rp_pigking_invade") --猪王袭击机制
			--inst:AddComponent("rp_monster_invade")  --怪物入侵机制
			inst:AddComponent("rp_killed_handler") --怪物击杀处理
		end
	end)	

	--自定义物品列表
	local rp_prefab_table = {
	"gravestone",
	"teleportato_base",
	}
	
	local function addPrefabAttributes(inst)
		if GLOBAL.TheWorld.ismastersim then
			inst:AddComponent("rp_prefabs")
		end
	end
	
	for _,v in pairs(rp_prefab_table) do
		AddPrefabPostInit(v, addPrefabAttributes) --我的自定义物品
	end