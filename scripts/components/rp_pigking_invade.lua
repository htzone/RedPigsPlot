--[入侵猪王机制]--

--普通怪物入侵配置列表
local normal_monster_table = {
{prefab = "bunnyman", health = 200, damage = 30, attack_period = nil, size = 1, color = nil, num = 5},
{prefab = "merm", health = 200, damage = 30, attack_period = nil, size = nil, color = nil, num = 5},
{prefab = "rocky", health = 200, damage = 30, attack_period = nil, size = nil, color = nil, num = 5},
}

--特殊怪物入侵配置列表
local special_monster_table = {
{prefab = "walrus", health = 300, damage = 30, attack_period = nil, size = 1, color = nil, num = 3},
{prefab = "leif", health = 300, damage = 30, attack_period = nil, size = 1, color = nil, num = 4},
{prefab = "knight", health = 300, damage = 30, attack_period = nil, size = 1, color = nil, num = 4},
{prefab = "worm", health = 300, damage = 30, attack_period = nil, size = 1, color = nil, num = 4},
{prefab = "firehound", health = 300, damage = 30, attack_period = nil, size = 1, color = nil, num = 4},
{prefab = "spider_spitter", health = 300, damage = 30, attack_period = nil, size = 1, color = nil, num = 4},
{prefab = "tallbird", health = 300, damage = 30, attack_period = nil, size = 1, color = nil, num = 4},
}

--设置掉落权值
local loot_weighted_table = {
monstermeat = 200,
meat = 200,
thulecite_pieces = 10,
hambat = 10,
redgem = 10,
bluegem = 10,
houndstooth = 10,
bluegem =10,
slurtleslime =10,
slurtle_shellpieces =10,
blowdart_sleep = 10,
blowdart_pipe =10,
blowdart_fire = 10,
boomerang = 10,
dragonfruit = 10,
greengem = 10,
papyrus = 10,
gears = 10,
batbat = 20,
footballhat = 10,
tophat = 10,
armorwood = 10,
armormarble = 10,
trunkvest_summer = 10,
beefalohat = 10,
bushhat = 10,
bedroll_straw = 10,
bedroll_furry = 10,
healingsalve = 10,
minerhat = 10,
nightsword = 10,
armor_sanity = 10,
}

--计算入侵的怪物数量
local function calculateMonsterNum(base_num, days)
	local monster_num = 0
	if days < 10 then
		monster_num = base_num
	elseif days < 20 then
		monster_num = base_num + math.floor(math.random(1,2))
	elseif days < 30 then
		monster_num = base_num + math.floor(math.random(2,3))
	elseif days < 50 then
		monster_num = base_num + math.floor(math.random(2,4))
	else
		monster_num = base_num + math.floor(math.random(3,5))
	end
	return monster_num
end

--改变攻击目标
local function changeAttack(inst)
	local origCanTarget = inst.components.combat.keeptargetfn
	local function keepTargetOverride(inst, target)
		return inst.components.combat:CanTarget(target)
	end
	inst.components.combat:SetKeepTargetFunction(keepTargetOverride)
	local function retargetfn(inst)
		local dist = 60		
		local invader = nil
		invader = FindEntity(inst, dist, function(guy)
			return guy:HasTag("king")
			and not guy:HasTag("rp_monster") 
			and not guy:HasTag("wave_monster")
			and not guy:HasTag("shadowboss")
			and not guy:HasTag("playerghost")
		end)
		return invader
	end
	inst.components.combat:SetRetargetFunction(2, retargetfn)
end

--产生对猪王的入侵
local function makePigKingInvasion(world, monster_attr)
	SpawnPrefab("lightning")
	local monster_num = calculateMonsterNum(monster_attr.num, TheWorld.state.cycles)
	for i = 1, monster_num do 
		local monster = rp_SpawnPrefabNearPigKing(monster_attr.prefab, 15, 30, 30)
		if monster then
			--让怪物具有进攻性
			if not monster.components.rp_invasive then
				monster:AddComponent("rp_invasive")
			end
			--(make_type, health, damage, attackPeriod, size, color, changeAttackFn)
			monster.components.rp_invasive:makeMonster(INVASIVE_MOB, 
			monster_attr.health, 
			monster_attr.damage, 
			monster_attr.attack_period, 
			monster_attr.size, 
			monster_attr.color, 
			changeAttack)
			
			--设置怪物掉落
			if not monster.components.rp_droploot then
				monster:AddComponent("rp_droploot")
			end
			monster.components.rp_droploot:setLoot(loot_weighted_table, 0, 1, 0.5) --0-1个掉落
			
		end
	end
end

--更新世界
local function updateWorld(world)
	
	---------测试---------
	--if TheWorld.state.cycles == 1 then
	--	for n,player in pairs(AllPlayers) do 
	--		rp_SpawnPlayerNearPigKing(player)
	--	end
	--end
	-----------------------
	
	if world.rp_pigking_invasion and TheWorld.state.cycles > 0 and TheWorld.state.cycles % 3 == 0 then  
		if not rp_findPigKing() then
			return nil
		end
		--进攻延迟
		local delay_time = 5
		--玩家语言提示
		TheWorld:DoTaskInTime(delay_time, function()
			rp_makeAllPlayersSpeak("猪王即将有危险了！")
		end)
		--系统公告提示
		TheWorld:DoTaskInTime(delay_time + 5, function()
			TheNet:Announce("不好了，怪物进攻猪王了！请保卫猪王！")
		end)
		--产生怪物入侵
		TheWorld:DoTaskInTime(delay_time + 7, function()
			if math.random() < .5 then
				makePigKingInvasion(world, normal_monster_table[math.random(#normal_monster_table)])
			else
				makePigKingInvasion(world, special_monster_table[math.random(#special_monster_table)])
			end
		end)
		--产生怪物入侵
		TheWorld:DoTaskInTime(delay_time + 20, function()
			if math.random() < .5 then
				makePigKingInvasion(world, normal_monster_table[math.random(#normal_monster_table)])
			else
				makePigKingInvasion(world, special_monster_table[math.random(#special_monster_table)])
			end
		end)
	end
	
end

--main--
local RP_PigKing_Invade = Class(function(self, inst)
	self.inst = inst
	self.inst:ListenForEvent("ms_cyclecomplete", function() updateWorld(self.inst) end)
end)

function RP_PigKing_Invade:OnSave()
	return
	{
		
	}
end
	
function RP_PigKing_Invade:OnLoad(data)
	if data ~= nil then
		
	end
end

return RP_PigKing_Invade