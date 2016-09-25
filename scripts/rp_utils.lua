----[[RedPig的常用的工具函数0-0]]----

--放置特效
function rp_spawnFX(fx_name, pos_pt)
	local fx = nil
	fx = SpawnPrefab(fx_name)
	if fx and pos_pt then
		fx.Transform:SetPosition(pos_pt:Get())
	end
end

--放置prefab
function rp_spawnPrefab(prefab_name, pos_pt, fx_name)
	local prefab = nil 
	prefab = SpawnPrefab(prefab_name)
	if prefab and pos_pt ~= nil then
		prefab.Transform:SetPosition(pos_pt:Get())
		if fx_name ~= nil then
			local currentscale = prefab.Transform:GetScale()
			local fx = SpawnPrefab(fx_name)
			if fx then
				fx.Transform:SetPosition(pos_pt:Get())
				fx.Transform:SetScale(currentscale*1,currentscale*1,currentscale*1)
			end
		end
	end
	return prefab
end

--获取要放置的位置
function rp_GetSpawnPoint(target, min_dist, max_dist)
	if min_dist == nil or max_dist == nil then
		min_dist = 15
		max_dist = 35
	end
	local pt = Vector3(target.Transform:GetWorldPosition())
	local theta = math.random() * 2 * PI
    local radius = math.random(min_dist, max_dist)
	local result_offset = FindValidPositionByFan(theta, radius, 36, function(offset) --这里其实就找是一个没有被其他物体占用的位置
		local pos = pt + offset
		local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1)
		return next(ents) == nil
    end)
	if result_offset ~= nil then
        local pos = pt + result_offset
		return pos
	end
end

--尝试在目标附近放置prefab
function rp_TrySpawn(target, prefab_name, min_dist, max_dist, max_trying_times, fx_name)
	if min_dist == nil or max_dist == nil then
		min_dist = 15
		max_dist = 35
	end
	if max_trying_times == nil then
		max_trying_times = 40
	end
	if max_trying_times < 0 then --递归 尝试 max_trying_times 次，如果找不到有效地点则返回空
		return nil
	end
	local b = nil
	if target then
		local player_pt = Vector3(target.Transform:GetWorldPosition())
		local pt = rp_GetSpawnPoint(target, min_dist, max_dist)
		if pt ~= nil then
			local tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
			local canspawn = tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID and tile ~= 255 --找到一个有效的位置才放置物体
			if canspawn then
				b = rp_spawnPrefab(prefab_name, pt, fx_name)
				if b and player_pt then 
					b:FacePoint(player_pt)
				end
				return b
			else
				b = rp_TrySpawn(target, prefab_name, min_dist, max_dist, max_trying_times - 1)
			end
		end
	end
	return b
end

--尝试在目标附近放置玩家
function rp_TrySpawnPlayer(target, player, min_dist, max_dist, max_trying_times)
	if min_dist == nil or max_dist == nil then
		min_dist = 8
		max_dist = 25
	end
	if max_trying_times == nil then
		max_trying_times = 40
	end
	if max_trying_times < 0 then --递归 尝试 max_trying_times 次，如果找不到有效地点则返回空
		return nil
	end
	if target then
		local target_pt = Vector3(target.Transform:GetWorldPosition())
		local pt = rp_GetSpawnPoint(target, min_dist, max_dist)
		if pt ~= nil then
			local tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
			local canspawn = tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID and tile ~= 255 --找到一个有效的位置才放置物体
			if canspawn then
				if player then 
					player.Transform:SetPosition(pt:Get())
					if target_pt then 
						player:FacePoint(target_pt)
					end 
				end
			else
				 rp_TrySpawnPlayer(target, player, min_dist, max_dist, max_trying_times - 1)
			end
		end
	end
end

--随机在地图上安置prefab
function rp_spawnPrefabInWorld(prefab_name)

	local prefab = SpawnPrefab(prefab_name)
	
	if prefab then
		local size_x, size_y = TheWorld.Map:GetSize()
		local tx = math.floor(size_x * math.random())
        local ty = math.floor(size_y * math.random())
		local tile = TheWorld.Map:GetTile(tx, ty)
		local canspawn = tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID and tile ~= 255
		if canspawn then
			prefab.Transform:SetPosition(tx, 0, ty)
		else 
			prefab = rp_spawnPrefabInWorld(prefab_name)
		end
	end
	return prefab
end

--将所有玩家聚集在一个目标附近
function rp_gatherAllPlayersInTarget(target, player, min_dist, max_dist, max_trying_times)
	if min_dist == nil then
		min_dist = 4
	end
	if max_dist == nil then
		max_dist = 10
	end
	for _,player in pairs(AllPlayers) do 
		rp_TrySpawnPlayer(target, player, min_dist, max_dist, max_trying_times)	
	end
end

--让所有的玩家说同一句话
function rp_makeAllPlayersSpeak(speech_str)
	for _,player in pairs(AllPlayers) do 
		if player and player.components.talker then
			player.components.talker:Say(speech_str)
		end
	end
end

--根据tag来找到最近的prefab
function rp_findFirstPrefabByTag(tag)
	return TheSim:FindFirstEntityWithTag(tag)
end

--找到猪王
function rp_findPigKing()
	return TheSim:FindFirstEntityWithTag("king")
end

--找到最近的怪物国王
function rp_findMonsterKing()
	return TheSim:FindFirstEntityWithTag("rp_monster_king")
end

--在猪王附近安置prefab
function rp_SpawnPrefabNearPigKing(prefab_name, min_dist, max_dist, max_try_times)
	if min_dist == nil then
		min_dist = 4
	end
	if max_dist == nil then
		max_dist = 12
	end
	if max_try_times == nil then
		max_try_times = 40
	end
	local monster = nil 
	local pig_king = TheSim:FindFirstEntityWithTag("king")
	if pig_king then
		monster = rp_TrySpawn(pig_king, prefab_name, min_dist, max_dist, max_try_times)	
	end
	return monster
end

--在猪王附近安置玩家
function rp_SpawnPlayerNearPigKing(player, min_dist, max_dist, max_try_times)
	local pig_king = TheSim:FindFirstEntityWithTag("king")
	if pig_king then
		if min_dist == nil or max_dist == nil then
			min_dist = 5
			max_dist = 12
		end
		rp_TrySpawnPlayer(pig_king, player, min_dist, max_dist, max_try_times)
	end
end

--自定义prefab，只是看起来具有prefab的效果
function rp_makePrefab(prefab, color)
	if prefab then
		if not prefab.components.rp_prefabs then
			prefab:AddComponent("rp_prefabs")
		end
		if color ~= nil then
			prefab.components.rp_prefabs:setColor(color)
		end
		prefab.components.rp_prefabs:makePrefab() --定制prefab
	end
end

--添加入侵怪物的tag
function rp_addInvasiveMobTag(monster)
	monster:AddTag("shadowboss")
	monster:AddTag("wave_monster")
	monster:AddTag("rp_monster")
	monster:AddTag("houndedKiller")
	monster:AddTag("hostile")
	monster:AddTag("monster")
end

--添加据点怪物boss的tag
function rp_addDefensiveKingTag(monster)
	monster:AddTag("shadowboss")
	monster:AddTag("wave_monster")
	monster:AddTag("rp_monster")
	monster:AddTag("rp_monster_king")
	monster:AddTag("houndedKiller")
	monster:AddTag("hostile")
	monster:AddTag("pointed_monster_king")
end

function rp_HexToRGB(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end
function rp_RGBToPercentColor(r, g, b)
    return r/255, g/255, b/255
end

--根据颜色字符串转换成rgb的值
function rp_HexToPercentColor(hex)
    return RGBToPercentColor(HexToRGB(hex))
end

--设置物品大小
function rp_setSize(inst, size, isRelative)
	if inst and inst.Transform then
		if isRelative ~= nil then
			local currentscale = inst.Transform:GetScale()
			inst.Transform:SetScale(currentscale*size,currentscale*size,currentscale*size)
		else
			inst.Transform:SetScale(1*size,1*size,1*size)
		end
	end
end

--设置生命值
function rp_setMaxHealth(inst, maxHealth)
	if inst and inst.components.health then
		inst.components.health:SetMaxHealth(maxHealth)
	end
end

--设置攻击力
function rp_setCombat(inst, damage, attackPeriod)
	if inst and inst.components.combat then
		if attackPeriod == nil then
			attackPeriod = inst.components.combat.min_attack_period
		end
		inst.components.combat:SetDefaultDamage(damage)
		inst.components.combat:SetAttackPeriod(attackPeriod)
	end
end

--设置颜色
function rp_setColor(inst, color_str, alpha)
	if alpha == nil then
		alpha = 1
	end
	if inst and inst.AnimState then
		local r, g, b = rp_HexToPercentColor(color_str)
		inst.AnimState:SetMultColour(r, g, b, alpha)
	end
end

--获取最大生命值
function rp_getMaxHealth(inst)
	if inst and inst.components.health then
		return inst.components.health.maxhealth
	end
	return nil
end

--获取大小
function rp_getSize(inst)
	if inst and inst.Transform then
		return inst.Transform:GetScale()
	end
	return nil
end

--获取攻击力
function rp_getDamage(inst)
	if inst and inst.components.combat then
		return inst.components.combat.defaultdamage
	end
	return nil
end

--获取攻击频率
function rp_getAttackPeriod(inst)
	if inst and inst.components.combat then
		return inst.components.combat.min_attack_period
	end
	return nil
end

--获取玩家数量(准确的说是地上的玩家数量)
function rp_getPlayerNum()
	local nump = 0
	for _, v0 in pairs(AllPlayers) do
		if v0 then
			nump = nump + 1
		end
	end
	return nump
end

--根据权值获取物品,需传入一个table
function rp_weighted(choices)
    local function weighted_total(choices)
        local total = 0
        for choice, weight in pairs(choices) do
            total = total + weight
        end
        return total
    end
    local threshold = math.random() * weighted_total(choices)
    local last_choice
    for choice, weight in pairs(choices) do
        threshold = threshold - weight
        if threshold <= 0 then return choice end
        last_choice = choice
    end
    return last_choice
end

--系统公告
function rp_announce(str)
	TheNet:Announce(str)
end

--函数注入
function rp_Inject(comp,fn_name,fn)
	local old = comp[fn_name]
	comp[fn_name] = function(self,...)
		old(self,...)
		fn(self.inst)
	end
end
