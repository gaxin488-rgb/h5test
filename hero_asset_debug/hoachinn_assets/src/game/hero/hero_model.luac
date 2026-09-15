-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      英雄model, 客户端 lwc 策划 陈星宇
-- <br/>Create: 2018-11-14
-- --------------------------------------------------------------------
HeroModel = HeroModel or BaseClass()

local table_insert = table.insert
local string_format = string.format
local table_sort = table.sort
local table_remove = table.remove
local hero_dic_num = -100 -- 下阵成功
local hero_dic_count = -100 -- 下阵计数
local recommend_bid = 0 -- 大神推荐 英雄bid
function HeroModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function HeroModel:config()
    --伙伴数据列表 (id :英雄唯一标识)
    --结构 self.hero_list[id] = hero_vo
    self.hero_list = {}  
    -- 伙伴bid列表的  
    --结构 self.hero_bid_list[bid] = {hero_vo1,hero_vo2}
    self.hero_bid_list = {}
    --伙伴数据数组形式存储，便于排序
    self.hero_array = Array.New() 

    --记录星级数量 self.dic_star_count[star] = n
    self.dic_star_count = {}

    --皮肤数据  结构: self.hero_skin_list[皮肤id] = 皮肤结束时间   (如果时间 == 0 表永久)
    self.hero_skin_list = nil   --nil用于判定是否初始化
    --英雄上限
    self.hero_max_count = 0
    --英雄已激活上限次数 
    self.buy_num = 0

    --英雄图书馆信息
    self.dic_pokedex_info = nil
    --英雄图书馆信息 [bid] = 数据
    self.dic_pokedex_bid = {}

    --熔炼祭坛的列表
    self.dic_fuse_info = nil
    --熔炼祭坛主界面是否显示红点
    self.is_fuse_redpoint = false
    --熔炼祭坛记录红点信息 self.dic_fuse_redpoint[bid] = true
    self.dic_fuse_redpoint = {}

    --已拥过有英雄id [bid] = 1
    self.dic_had_hero_info = {}

    --位置参数
    self.pos_param = 10
    --布阵站位信息 self.pos_list[布阵类型][pos] = v(网络返回的数据)
    --pos 结构 其值 = index * self.pos_param + pos   其中 index 表示(队伍索引 - 1)  pos 才是其在阵法上的位置
    self.pos_list = {}

    self.expedit_list = nil
    --阵法类型
    self.use_formation_type = 1
    --使用的圣器id
    self.use_hallows_id = 0

    --装备红点背包已更新 记录
    self.is_equip_redpoint_bag_update = true
    --装备红点英雄已更新 记录
    self.is_equip_redpoint_hero_update = true

    --是否延迟红点更新中 例子:self.is_delay_redpoint_update[HeroConst.RedPointType.eRPLevelUp] = true
    --目前只有升级红点用
    self.is_delay_redpoint_update = {}

    --进阶和升星材料消耗 只能写死 如果策划改了.跟着改吧
    self.upgrade_star_cost_id = 10001 
    self.upgrade_star_cost_id_2 = 10090
    --天赋技能升星的材料
    self.talent_skill_cost_id = 10450

    --升星红点背包已更新 记录
    self.is_upgradestar_redpoint_bag_update = true
    --升星红点英雄已更新 记录
    self.is_upgradestar_redpoint_hero_update = true

    --阵法 红点 (一次性的)
    self.is_redpoint_form = false
    --圣器 红点 (一次性的)
    self.is_redpoint_hallows = false

    --记录登陆时候角色的等级 判断阵法是否新解锁用
    self.record_login_lev = 0

    --符文解锁条件信息
    local artifact_one = Config.PartnerData.data_partner_const["artifact_one"].val 
    local artifact_two = Config.PartnerData.data_partner_const["artifact_two"].val
    self.artifact_lock_list = {artifact_one, artifact_two}
    self.artifact_lucky = 0 -- 符文祝福值
    self.artifact_lucky_red = false -- 祝福值红点

    --英雄信息界面 升星页签的参数  6星才限时页签(后面策划要求熔炼祭坛的也加入)
    self.hero_info_upgrade_star_param = 6
    --(4-5星的ui 和 11星ui一致) ...(6-10星的ui一致)
    self.hero_info_upgrade_star_param2 = 10
    self.hero_info_upgrade_star_param3 = 11
    self.hero_info_upgrade_star_param4 = 12

    --英雄信息界面 天赋页签的参数  6星才限时页签
    self.hero_info_talent_skill_param =  Config.PartnerSkillData.data_partner_skill_const["skill_slot"].val   
    
    --天赋技能可学习的列表 用于红点 结构 self.dic_hero_talent_skill_learn_redpoint[skill_id] = 1
    self.dic_hero_talent_skill_learn_redpoint  = {}

    self.is_need_update_talent_redpoint = true

    --穿戴在英雄身上的神装信息结构 self.hero_holy_list[id] = good_vo
    self.hero_holy_list = {}

    --穿戴在英雄身上的神装ID信息结构 self.dic_itemid_to_partner_id[id] = partner_id
    self.dic_itemid_to_partner_id = {}


    --共鸣水晶等级
    self.resonate_cystal_lev = 0

    --英雄共鸣锁定信息
    self.dic_resonate_lock_info = {}
    --共鸣石碑等级
    self.resonate_stone_level = 0
    --共鸣历史星级
    self.resonate_max_partner_lev = nil --一定要nil 有地方判断nil来决定有木有数据
    --共鸣精炼红点
    self.is_resonate_extract_redpoint = false

    --重生次数(针对 100级以下的)
    self.reset_count = 0
end

function HeroModel:resetAllData()
    self.hero_list = {} 
    self.hero_bid_list = {}
    self.hero_array = Array.New() 

    self.hero_skin_list = nil

    self.hero_holy_list = {}
    self.dic_itemid_to_partner_id = {}
    self.pos_list = {}
    self.is_delay_redpoint_update = {}
end


-------------------英雄信息--------------------------
--更新英雄信息列表 not_show_power:不显示战力变化提示
--@is_detail_info 是否是详细信息
function HeroModel:updateHeroList(data_list, not_show_power, is_detail_info)
    if not data_list then return end
    --设置数据
    for __, info in pairs(data_list) do
        self:updateHeroVo(info, not_show_power, is_detail_info)
    end
end

--更新单个英雄信息 如果没该英雄是新增
function HeroModel:updateHeroVo(info, not_show_power, is_detail_info)
    if info == nil then return end
    --新旧版本容错的
    info.id = info.partner_id
    --新旧版本容错的
    local hero_id = info.id
    local is_add = false  --判断是否增加新伙伴
    if not self.hero_list[hero_id] then
        if is_detail_info then
            return
        end
        self.hero_list[hero_id] = HeroVo.New()
        is_add = true
    end
    local hero_vo = self.hero_list[hero_id]

    if not is_detail_info then
        --获取数据缺少的项 配置表信息
        --由于出现 camp_type 的类型不对问题..暂时把此赋值开放..查看导致英雄数据bug是否还出现
        local bid = info.bid
        local config = Config.PartnerData.data_partner_base[bid]
        if config then
            for key,value in pairs(config) do
                if key ~= "skills" then 
                    info[key] = value
                end
            end
            local star = info.star or config.init_star
            if self.dic_had_hero_info[bid] then
                if self.dic_had_hero_info[bid] < star then
                    self.dic_had_hero_info[bid] = star
                end
            else
                self.dic_had_hero_info[bid] = star
            end
        end
    end
    -- 设置伙伴的角色id
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo ~= nil then
        info.rid = role_vo.rid
        info.srv_id = role_vo.srv_id
    end
    local old_vo
    local open_type = 0
    if not is_add then
        --处理战力提升特效(11007更新英雄列表时不飘战力提示)
        if not not_show_power and hero_vo.power < info.power   then 
            -- if info.resonate_lev and info.resonate_lev > 0 then
            --     --原力水晶的英雄 不显示战力飘字
            -- else
                GlobalMessageMgr:getInstance():showPowerMove( info.power-hero_vo.power,nil,hero_vo.power )
            -- end
        end

        if not is_detail_info then
            --处理升星 进阶
            if info.star and hero_vo.star < info.star then
                open_type = 1 
                old_vo = clone(hero_vo)
                if hero_vo.star == (self.hero_info_talent_skill_param[2] - 1) then
                    hero_vo.is_open_talent = true
                end
                if info.star >= 10 then
                    --清除 星级数量记录
                    self.dic_star_count = {}
                end
            elseif info.break_lev and hero_vo.break_lev < info.break_lev then 
                if not self:isResonateCystalHero(info) then --不是共鸣水晶上面的英雄才计算进阶逻辑
                    open_type = 2
                    old_vo = clone(hero_vo)
                end
            end
        end
    end

    hero_vo:updateHeroVo(info)
    if is_add then
        self.hero_array:PushBack(hero_vo)
        if not self.hero_bid_list[hero_vo.bid] then
            self.hero_bid_list[hero_vo.bid] = {}
        end
        table_insert(self.hero_bid_list[hero_vo.bid], hero_vo)
    else
        if open_type == 1 and old_vo and next(old_vo) ~= nil then
            self.ctrl:openHeroUpgradeStarExhibitionPanel(true,old_vo,hero_vo)
            --升星可能导致上阵英雄有红点
            HeroCalculate.clearAllHeroRecordByRedPointType(HeroConst.RedPointType.eRPStar)
        elseif open_type == 2 and old_vo and next(old_vo) ~= nil then
            self.ctrl:openBreakExhibitionWindow(true,old_vo,hero_vo)
        end
        if is_detail_info then
            hero_vo:setInitAttr()
            GlobalEvent:getInstance():Fire(HeroEvent.Hero_Detail_Data_Update, hero_vo)
        else
            GlobalEvent:getInstance():Fire(HeroEvent.Hero_Data_Update, hero_vo)
        end
    end
end

--通过bid获取等级最高的英雄信息
function HeroModel:getTopLevHeroInfoByBid(bid)
    if not bid then return end
    local list = self.hero_bid_list[bid]
    if list then
        table_sort(list, SortTools.tableUpperSorter({"lev","power"}))
        return list[1]
    end
    return nil
end

function HeroModel:getHeroNumByBid(bid)
    if not bid then return 0 end
    local list = self.hero_bid_list[bid] or {}
    return #list
end

--根据bid 和star 获取对应的英雄信息
--@return 英雄信息列表
function HeroModel:getHeroInfoByBidStar(bid, star)
    if not bid or not star then return end
    local list = self.hero_bid_list[bid]
    if list then
        local return_list = {}
        for i, hero_vo in ipairs(list) do
            if hero_vo.star == star then
                table_insert(return_list, hero_vo)
            end
        end
        return return_list
    end
    return nil
end

--增加详细信息
function HeroModel:updateHeroVoDetailedInfo(info)
    if not info then return end
    if self.hero_list[info.partner_id] then
        for k,v in pairs(info) do
            self.hero_list[info.partner_id][k] = v
        end
        self.hero_list[info.partner_id]:setIsHadDetail(true)
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Vo_Detailed_info, self.hero_list[info.partner_id])
    end
end
function HeroModel:clearHeroVoDetailedInfoByPartnerID(partner_id)
    if self.hero_list and self.hero_list[partner_id] then
        self.hero_list[partner_id]:setIsHadDetail(false)
    end
end

--清除英雄信息信息的记录
function HeroModel:clearHeroVoDetailedInfo()
    if not self.hero_list then return end
    for k,v in pairs(self.hero_list) do
        v:setIsHadDetail(false)
    end
end
--更新天赋信息
function HeroModel:updateHeroVoTalent(data_list, is_not_check)
    local is_team = false
    for i,v in ipairs(data_list) do
        if self.hero_list[v.partner_id] then
            self.hero_list[v.partner_id]:updateSkill(v.dower_skill)
            --因为天赋可能会影响影响的详细信息  这里标志要刷新一下
            self.hero_list[v.partner_id]:setIsHadDetail(false)
            if not is_team then
                if self.hero_list[v.partner_id]:isFormDrama() then
                    is_team = true
                end
            end
        end
    end
    if is_team and not is_not_check then
        --如果有剧情阵容的英雄..需要检查红点
        --检测红点
        HeroCalculate.checkAllHeroRedPoint()    
    end
end

-- 根据符石bid判断，上阵英雄中是否有已经学习的英雄
function HeroModel:checkTalentIsLearnByBid( bid )
    local is_learn = false
    for k,hero_vo in pairs(self.hero_list) do
        if hero_vo:isFormDrama() and hero_vo:checkIsHaveTalentByBid(bid) then
            is_learn = true
            break
        end
    end
    return is_learn
end

function HeroModel:setLockByPartnerid(partner_id, is_lock)
    if self.hero_list[partner_id] ~= nil then
        self.hero_list[partner_id].is_lock = is_lock or 0
    end
end

--删除英雄 
--list 
function HeroModel:delHeroDataList(list)
    if list == nil then return end
    for i,v in ipairs(list) do
        if self.hero_list[v.partner_id] then
            local temp_bid = self.hero_list[v.partner_id].bid
            self.hero_list[v.partner_id] = nil
            --同时从bid英雄列表删除该英雄记录
            local bidlist = self.hero_bid_list[temp_bid]
            if bidlist then
                for i=#bidlist,1,-1 do
                    local hero_vo = bidlist[i]
                    if hero_vo.partner_id == v.partner_id then
                        table_remove(bidlist, i)
                    end
                end
            end
        end
    end
    self.hero_array = Array.New()
    for i,v in pairs(self.hero_list) do 
        self.hero_array:PushBack(v)
    end
    

    self:checkHeroChangeRedPoint()

    GlobalEvent:getInstance():Fire(HeroEvent.Del_Hero_Event, list)
end

--检测英雄数量或者英魂发生变化的时候需要做的事情
function HeroModel:checkHeroChangeRedPoint()
    --消除熔炼祭坛的红点 删除也要重新算
    HeroCalculate.clearAllStarFuseRedpointRecord()

    --升星红点
    self.is_upgradestar_redpoint_hero_update = true
    self:checkUpgradeStarRedPointUpdate()
end

--雇佣的
function HeroModel:getExpeditHeroData()
    local hero_list = self:getAllHeroArray().items
    local list = {}

    for i,hero in ipairs(hero_list) do
        local tab = {}
        tab.power = hero.power
        tab.name = hero.name
        tab.bid = hero.bid
        tab.index = i

        tab.rid = hero.rid
        tab.srv_id = hero.srv_id
        tab.id = hero.id
        tab.star = hero.star
        tab.lev = hero.lev
        tab.use_skin = hero.use_skin
        table_insert(list, tab)
    end
   
    table.sort(hero_list, function(a, b) return b.power < a.power end)
    return hero_list
end

--获取当前拥有的英雄数据,
--@ return Array
function HeroModel:getAllHeroArray()
    return self.hero_array or Array.New()
end

--获取最高战力的英雄战力
function HeroModel:getMaxFight()
    if self.hero_array then
        self.hero_array:UpperSortByParams("power")
        local hero_vo = self.hero_array:Get(0)
        if hero_vo then
            return hero_vo.power
        end
    end
    return 0
end

--获取当前拥有英雄数据 [唯一id] = 英雄数据
function HeroModel:getHeroList()
    return self.hero_list or {}
end

--获取单个伙伴数据,id
--@id 是英雄唯一标识id 
function HeroModel:getHeroById(partner_id)
    if not self.hero_list then return end
    if not partner_id or type(partner_id) ~= "number" then return end
    return self.hero_list[partner_id] or {}
end

--根据初始星级 或者对应英雄最大进阶次数
function HeroModel:getHeroMaxBreakCountByInitStar(init_star)
    if self.dic_max_break == nil then
        local val = Config.PartnerData.data_partner_const.advanced_limit.val
        self.dic_max_break = {}
        for i,v in ipairs(val) do
            self.dic_max_break[v[1]] = v[2]
        end
    end
    return self.dic_max_break[init_star] or 0
end

--根据根据品质获取获取随机头像
function HeroModel:getRandomHeroHeadByQuality( quality)
    if self.dic_random_hero_head == nil then
        local val = Config.PartnerData.data_partner_const.random_hero_icon.val
        self.dic_random_hero_head = {}
        for i,v in ipairs(val) do
            local item_config = Config.ItemData.data_get_data(v[2])
            if item_config then
                self.dic_random_hero_head[v[1]] = item_config.icon
            end
        end
    end
    local quality = quality or 0
    if quality < 0 then
        quality = 0
    elseif quality > 5 then
        quality = 5
    end
    return self.dic_random_hero_head[quality] or 1
end

--根据阵营和星级.得到对应来源的道具id
--self.dic_source_item_ids[camp][star] = item_id
function HeroModel:getSourceHeroCombinationByCampStar(camp, star)
    if self.dic_source_item_ids == nil then
        self.dic_source_item_ids = {}
        local val = Config.PartnerData.data_partner_const.source_hero_combination.val
        for i,v in ipairs(val) do
            if self.dic_source_item_ids[v[1]] == nil then
                self.dic_source_item_ids[v[1]] = {}
            end
            self.dic_source_item_ids[v[1]][v[2]] = v[3]
        end
    end
    if self.dic_source_item_ids[camp] then
        local star = star or 0
        if star == 0 then
            star = 3 --最低星就三
        end
        return self.dic_source_item_ids[camp][star]
    end
end

--英雄上限
function  HeroModel:setHeroMaxCount(count)   --英雄上限
    if count then
        self.hero_max_count = count 
    end
end
--获取英雄上限
--return 英雄上限, 当前英雄数量
function  HeroModel:getHeroMaxCount()   --英雄上限
    local max_count = self.hero_max_count or 0
    local count = self:getAllHeroArray():GetSize()

    return max_count, count
end
--获取购买已购买英雄次数
function HeroModel:getHeroBuyNum( )
    return self.buy_num or 0
end

--获取购买已购买英雄次数
function HeroModel:setHeroBuyNum(num)
    self.buy_num = num or 0
end

function HeroModel:setHadHeroInfo(list)
    if not list then return end
    for i,v in ipairs(list) do
        if self.dic_had_hero_info[v.partner_id] then
            if self.dic_had_hero_info[v.partner_id] < v.max_star then
                self.dic_had_hero_info[v.partner_id]  = v.max_star
            end
        else
            self.dic_had_hero_info[v.partner_id] = v.max_star --最大星级
        end
    end
end
function HeroModel:getHeroLibInfo(bid)
    if tableLen(self.lib_list) == 0 then
        return {bid,1} 
    end
    return {bid,self.lib_list[bid]}
end
function HeroModel:getHeroLibRed(bid)
    if not self.lib_list or tableLen(self.lib_list) == 0 then
        return false
    end
    if self.lib_list[bid] == 0 then
        return true
    end
    return false
end
function HeroModel:getHeroLib(bid)
    if not self.lib_list or tableLen(self.lib_list) == 0 then
        return false
    end
    if self.lib_list[bid] then
        return true
    end
    return false
end
function HeroModel:getHeroRed()
    local role_vo = RoleController:getInstance():getRoleVo()
    local level_cfg = Config.PartnerData.data_partner_const.library_level
    if level_cfg and role_vo and level_cfg.val > role_vo.lev then
        return false
    end
    for key, value in pairs(self.hero_lib_list or {}) do
        if value.lib_reward == 0 then
            return true
        end
    end
    return false
end
function HeroModel:getHadHerozbRed()
    local role_vo = RoleController:getInstance():getRoleVo()
    local partner_const = Config.PartnerEqmData.data_partner_const
    if role_vo.vip_lev < partner_const.synthesis_vip_lev.val and role_vo.lev < partner_const.synthesis_character_lev.val then
        return false
    end
    local dic_pokedex_info = self:getAllHeroArray()
    for key, value in pairs(dic_pokedex_info.items or {}) do
        if value.is_in_form > 0 then
            local is_redpoint = HeroCalculate.checkSingleHeroRedPoint(value)
            if is_redpoint then
                return true    
            end
        end
    end
    return false
end

function HeroModel:getHadHeroInfo()
    return self.dic_had_hero_info or {}
end

function HeroModel:getHadHeroStarBybid(bid)
    if self.dic_had_hero_info and self.dic_had_hero_info[bid] then
        return self.dic_had_hero_info[bid]
    end
    return 0
end

--是否开启天赋 判断一个
function HeroModel:isOpenTanlentById(partner_id)
    if self.hero_list[partner_id] then
        return self:isOpenTanlentByHerovo(self.hero_list[partner_id])
    end
    return false
    
end

function HeroModel:isOpenTanlentByHerovo(hero_vo)
    if hero_vo[self.hero_info_talent_skill_param[1]] then
        if hero_vo[self.hero_info_talent_skill_param[1]] >= self.hero_info_talent_skill_param[2] then
            return true
        end
    end
    return false
end

--@config Config.PartnerSkillData.data_partner_skill_pos
function HeroModel:checkOpenTanlentByconfig(config, hero_vo)
    if not config then return end
    if not hero_vo then return end
    if config.pos_limit[1] == 'star' then
        is_open = (hero_vo.star >= config.pos_limit[2])
        if is_open then
            return is_open
        else
            return is_open, (string.format(TI18N("语言_c_4741"),config.pos_limit[2]))
        end
    end
end

--判断星阶是否激活
function HeroModel:checkStarStepCompleteByIndex(hero_vo, index)
    local star_step = hero_vo.star_step or 0
    local list = {}
    list = bit._d2b(star_step)
    return  list[32 - index + 1] == 1
end

--判断是否有任意星阶疑惑
function HeroModel:checkAnyStarStepComplete(hero_vo)
    for i=1,4 do
        if self:checkStarStepCompleteByIndex(hero_vo, i) then
            return true
        end
    end
    return false
end

--获取星阶激活的等级加成
function HeroModel:getStarStepCompleteAddLev(hero_vo)
    local addLev = 0
    for i=1,4 do
        local isComplete = self:checkStarStepCompleteByIndex(hero_vo, i)
        if isComplete then
            local key = getNorKey(hero_vo.bid, hero_vo.star, i)
            local star_rank_config = Config.PartnerData.data_partner_star_step(key)
            local lev_max_up = star_rank_config.lev_max_up
            addLev = addLev + lev_max_up
        end
    end
    return addLev
end

--判断一个英雄的星级是不是满星
function HeroModel:isMaxStarHero(bid, star)
    if not bid or not star then return false end
    local max_star = Config.PartnerData.data_partner_max_star[bid]
    if max_star and star >= max_star then
        return true
    end
    return false
end

--初始化英雄图鉴数据
function HeroModel:getHeroPokedexList()
    if self.dic_pokedex_info == nil then
        self.dic_pokedex_info = {}
        -- self.dic_pokedex_info[0] = {} --表示全部
        self.dic_pokedex_info[HeroConst.CampType.eWater] = {} --阵营 水
        self.dic_pokedex_info[HeroConst.CampType.eFire]  = {} --阵营 火
        self.dic_pokedex_info[HeroConst.CampType.eWind]  = {} --阵营 风
        self.dic_pokedex_info[HeroConst.CampType.eLight] = {} --阵营 光
        self.dic_pokedex_info[HeroConst.CampType.eDark]  = {} --阵营 暗
        self.dic_pokedex_info[HeroConst.CampType.eAlien]  = {} --阵营 异界
        local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("partner_data")

        if Config.PartnerData.data_partner_pokedex then
            for bid,star_list in pairs(Config.PartnerData.data_partner_pokedex) do
                local base_config = Config.PartnerData.data_partner_base[bid]
                if base_config then
                    if base_config.isshow == 0 and not table.indexof(nohideIds,bid) then
                        -- 后台配置屏蔽的
                    else
                        for i,v in ipairs(star_list) do
                            local star = v.star
                            local key = getNorKey(bid,star)
                            local info = self:getHeroPokedexByBid(key)
                            if info then
                                if MAKELIFEBETTER == true then
                                    info.aaaaa = math.random( 1, 1000 )
                                end
                                table.insert(self.dic_pokedex_info[info.camp_type], info)
                            end
                        end
                    end
                end
            end

            --排序
            local sort_func
            if MAKELIFEBETTER == true then
                sort_func = SortTools.tableLowerSorter({"aaaaa"})
            else
                sort_func = SortTools.tableUpperSorter({"is_mr","is_ur","is_sp","camp_type", "star", "score" , "bid"})
            end
            for k,_table in pairs(self.dic_pokedex_info) do
                table.sort(_table, sort_func)    
            end
        end
    end
    return self.dic_pokedex_info
end

--@ key 如: key = 50507_10
--@ data 是 Config.PartnerData.data_partner_pokedex信息
function HeroModel:getHeroPokedexByBid(key)
    if self.dic_pokedex_bid[key] then
        return self.dic_pokedex_bid[key]
    end
    local data = Config.PartnerData.data_partner_show(key)
    if not data then 
        if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" then
            message(string.format("英雄图鉴没有[%s](bid_star)的数据", tostring(key)))
        end
        return nil  
    end
    local base_config = Config.PartnerData.data_partner_base[data.bid]
    if base_config then
        --这里由于是图鉴..所以不怕被破坏数据
        local break_lev = self:getHeroMaxBreakCountByInitStar(data.star)
        data.hp_max = data.hp --为了计算战力用的 
        data.power = PartnerCalculate.calculatePower(data)
        data.camp_type = base_config.camp_type
        data.name = base_config.name
        data.init_star = base_config.init_star
        data.type  = base_config.type 
        data.break_id = base_config.break_id 
        data.introduce_str = base_config.introduce_str 
        data.break_lev = break_lev
        data.score = base_config.score
        data.is_sp = base_config.score == 9 and 1 or 0
        data.is_ur = base_config.score == 10 and 1 or 0
        data.is_mr = base_config.score == 11 and 1 or 0
        data.show_order = base_config.show_order or 1
        --定义一个唯一id
        data.partner_id = data.bid * 10 + data.star
        data.is_pokedex = true -- 是不是图鉴
        self.dic_pokedex_bid[key] = data
        return self.dic_pokedex_bid[key]
    end
    return nil
end

function HeroModel:getIsFuseRedPoint( )
    return self.is_fuse_redpoint or false
end

function HeroModel:setIsFuseRedPoint(is_point)
    self.is_fuse_redpoint = is_point or false
end

--检测熔炼祭坛是否有新的红点信息
function HeroModel:checkNewFuseRedPoint()
    if not self.dic_fuse_info then return false end

    local is_new_redpoint = false
    local list = self.dic_fuse_info[0] or {}
    for i,v in ipairs(list) do
        if v.cur_redpoint == 1 then
            if self.dic_fuse_redpoint[v.bid] == nil then
                is_new_redpoint = true
                break
            end
        end
    end
    return is_new_redpoint
end

--记录红点信息
function HeroModel:recordFuseRedPointInfo()
    if not self.dic_fuse_info then return false end
    local list = self.dic_fuse_info[0] or {}
    for i,v in ipairs(list) do
        if v.cur_redpoint == 1 then
            self.dic_fuse_redpoint[v.bid] = true
        end
    end
end

--获取熔炼祭坛的数据列表
function HeroModel:getStarFuseList()
    -- if self.dic_fuse_info then 
    --     return self.dic_fuse_info
    -- end

    self.dic_fuse_info = {}
    self.dic_fuse_info[0] = {} --表示全部
    self.dic_fuse_info[HeroConst.CampType.eWater] = {} --阵营 水
    self.dic_fuse_info[HeroConst.CampType.eFire]  = {} --阵营 火
    self.dic_fuse_info[HeroConst.CampType.eWind]  = {} --阵营 风
    self.dic_fuse_info[HeroConst.CampType.eLight] = {} --阵营 光
    self.dic_fuse_info[HeroConst.CampType.eDark]  = {} --阵营 暗
    -- self.dic_fuse_info[HeroConst.CampType.eAlien]  = {} --阵营 异界
    local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("partner_data")
    for bid,star_list in pairs(Config.PartnerData.data_partner_fuse_star) do
        local base_config = Config.PartnerData.data_partner_base[bid]
        if base_config then
            if base_config.isshow == 0 and not table.indexof(nohideIds, bid) then
                --屏蔽
            else
                for i,v in ipairs(star_list) do
                    local star = v.star
                    local key = getNorKey(bid, star)
                    local star_config = Config.PartnerData.data_partner_star(key)
                    if star_config and #star_config.expend1 > 0 then
                        local fuse_data = {}
                        fuse_data.base_config = base_config
                        fuse_data.star_config = star_config
                        fuse_data.camp_type = base_config.camp_type
                        fuse_data.bid = bid
                        fuse_data.star = star
                        if MAKELIFEBETTER == true then
                            fuse_data.aaaaa = math.random( 1, 10000 )
                        end
                        if base_config.camp_type ~= HeroConst.CampType.eAlien then
                            table.insert(self.dic_fuse_info[0], fuse_data)
                        end
                        if self.dic_fuse_info[base_config.camp_type] then
                            table.insert(self.dic_fuse_info[base_config.camp_type], fuse_data)
                        end
                    end
                end
            end
        end
    end
    --排序
    local sort_func = SortTools.tableLowerSorter({"star", "camp_type", "bid"})
    for k,_table in pairs(self.dic_fuse_info) do
        table.sort(_table, sort_func)    
    end
    return self.dic_fuse_info
end

--根据bid 获取一个模拟herovo对象..属性都是1级的
function HeroModel:getMockHeroVoByBid(bid)
    local base_config = Config.PartnerData.data_partner_base[bid]
    local attr_config = Config.PartnerData.data_partner_attr[bid]
    if not base_config or not attr_config then
        return
    end

    local hero_vo = DeepCopy(base_config)
    hero_vo.star = base_config.init_star --默认星数
    hero_vo.break_lev = 0 --默认进阶
    for k,v in pairs(attr_config) do
        if hero_vo[k] == nil then
            hero_vo[k] = v
        end
    end
    hero_vo.hp = attr_config.hp_max --血量等于最大血量
    hero_vo.power = PartnerCalculate.calculatePower(hero_vo)
    return hero_vo
end

--活动英雄列表 根据匹配信息 --熔炼祭坛用
--@dic_the_conditions --指定匹配 dic_the_conditions[bid][star] = 数量
--@dic_random_conditions --随机阵容匹配 dic_the_conditions[camp][star] = 数量
--@dic_hero_id 标志已用
--return
--@ count 拥有不重复英雄总数量
function HeroModel:getHeroListByMatchInfo(dic_the_conditions, dic_random_conditions, dic_hero_id)
    --找不重复的数量
    local count  = 0
    local dic_hero_id = dic_hero_id or {}
    local dic_count = {}

    local _setDicCount = function( partner_id, str, max)
        --判断是否重复
        if dic_hero_id[partner_id] == nil then
            if dic_count[str] == nil then
                dic_count[str] = 0
            end
            if dic_count[str] < max then
                dic_count[str] = dic_count[str] + 1
                count = count + 1    
                dic_hero_id[partner_id] = 1
            end
        end 
    end

    for k,hero in pairs(self.hero_list) do
        if not hero:isResonateHero() then
            if dic_the_conditions and dic_the_conditions[hero.bid] and dic_the_conditions[hero.bid][hero.star] then
                --指定的.范围最小
                local str = string_format("%s%s", hero.bid, hero.star)
                _setDicCount(hero.partner_id, str, dic_the_conditions[hero.bid][hero.star])
            end

            if dic_random_conditions then
                if dic_random_conditions[hero.camp_type] and dic_random_conditions[hero.camp_type][hero.star] then
                    --先判定指定阵营的 ,先小范围.再大范围
                    local str = string_format("_%s%s", hero.camp_type, hero.star)
                    _setDicCount(hero.partner_id, str, dic_random_conditions[hero.camp_type][hero.star])
                elseif dic_random_conditions[0] and dic_random_conditions[0][hero.star] then
                    --0表示所有阵营的合适
                    local str = string_format("_%s%s", 0, hero.star)
                    _setDicCount(hero.partner_id, str, dic_random_conditions[0][hero.star])
                end    
            end
        end
    end

    local list = BackpackController:getInstance():getModel():getHeroHunList()

    for k,good_vo in pairs(list) do
        if good_vo.config then
            local camp_type = good_vo.config.camp_type
            local star = good_vo.config.eqm_jie
            if dic_random_conditions[camp_type] and dic_random_conditions[camp_type][star] then
                local str = string_format("_%s%s", camp_type, star)

                if dic_count[str] == nil then
                    dic_count[str] = 0
                end
                if dic_count[str] < dic_random_conditions[camp_type][star] then
                    local cur_count = dic_random_conditions[camp_type][star] - dic_count[str]
                    if good_vo.quantity < cur_count then
                        cur_count = good_vo.quantity
                    end
                    count = count + cur_count 
                    dic_count[str] = dic_count[str] + cur_count
                end
            end
        end
    end

    return count
end
-------------------英雄信息结束--------------------------


---------------------装备相关------------------------------
function HeroModel:updateHeroEquipList(data)
    local id = data.partner_id or 0
    if self.hero_list[id] then 
        local hero_vo =  self.hero_list[id]
        if hero_vo.power < data.power then 
            GlobalMessageMgr:getInstance():showPowerMove( data.power-hero_vo.power,nil,hero_vo.power  )     
        end
        self.hero_list[id]:updateHeroVo(data)
        -- local bool = PartnerCalculate.getIsJingEquip(hero_vo.bid)
        -- hero_vo:updateRedPoint(PartnerConst.Vo_Red_Type.EequipJing,bool)
    end
end

function HeroModel:getHeroEquipList(id)
    if self.hero_list[id] then 
        return self.hero_list[id].eqm_list or {}
    end
    return {}
end
----------------------装备相关结束---------------------------------------


----------------------------------神装开始----------------------------------------

--神装页签是否开启
function HeroModel:isOpenHolyEquipMentTabByHerovo(hero_vo, is_show_tips)
    if not hero_vo then return false end
    --神装开启所需英雄星级
    local tips = ""
    local config = Config.PartnerHolyEqmData.data_const.show_star_condition
    local star = hero_vo.star or 1
    if config then
        if hero_vo.star < config.val then
            return false
        end
        tips = config.desc
    end

    local role_vo = RoleController:getInstance():getRoleVo()
    local lev = 0
    if role_vo then
        lev = role_vo.lev or 0
    end

    --策划要求两个情况 : 1世界等级110且个人等级105开启 2个人等级120开启
     -- 个人等级限制 --先判断2
    local role_second_lv_cfg = Config.PartnerHolyEqmData.data_const.open_lev_second_condition
    if role_second_lv_cfg and lev < role_second_lv_cfg.val then
        --不满足2 再判断1
        -- 个人等级条件
        local role_lv_cfg = Config.PartnerHolyEqmData.data_const.open_lev_condition
        if lev < role_lv_cfg.val then
            return false
        end
        -- 世界等级限制
        local world_lv_cfg = Config.PartnerHolyEqmData.data_const.open_worldlev_condition
        local world_lev = RoleController:getInstance():getModel():getWorldLev()
        if world_lev and world_lv_cfg and world_lev < world_lv_cfg.val then
            -- if is_show_tips then
            --     message(world_lv_cfg.desc)
            -- end
            return false
        end
    end

    return true, tips
end

   
--是否神装开启 --旧的 改变前的条件判断 写死的
--神装改开启条件了,但是需要兼容旧数据,判断玩家之前有神装的装备的 也能显示页签 并且显示开启状态
function HeroModel:isOpenHolyEquipMentOldByHerovo(hero_vo, is_show_tips)
    if not hero_vo then return false end
    --旧的数据记录一下
    -- ["open_star_condition"] = {val=6, desc="神装开启所需英雄星级"},
    -- ["open_worldlev_condition"] = {val=110, desc="神装开启所需世界等级"},
    -- ["open_lev_condition"] = {val=105, desc="神装开启所需个人等级"},
    -- ["open_lev_second_condition"] = {val=120, desc="神装开启所需第二个人等级"},
    --神装开启所需英雄星级
    local star = hero_vo.star or 1
    if hero_vo.star < 6  then 
        return false
    end

    local role_vo = RoleController:getInstance():getRoleVo()
    local lev = 0
    if role_vo then
        lev = role_vo.lev or 0
    end

    --策划要求两个情况 : 1世界等级110且个人等级105开启 2个人等级120开启
     -- 个人等级限制 --先判断2
    if lev < 120 then
        --不满足2 再判断1
        -- 个人等级条件
        if lev < 105 then
            return false
        end
        -- 世界等级限制
        local world_lev = RoleController:getInstance():getModel():getWorldLev()
        if world_lev and world_lev < 110 then
            return false
        end
    end

    return true
end

--是否神装开启
--@is_show_tips 是否显示提示 --暂时没用
function HeroModel:isOpenHolyEquipMentByHerovo(hero_vo, is_show_tips)
    if not hero_vo then return false end

    --神装开启所需英雄星级
    local config = Config.PartnerHolyEqmData.data_const.open_star_condition
    local star = hero_vo.star or 1
    if config and hero_vo.star < config.val  then
        -- if is_show_tips then
        --     message(config.desc)
        -- end
        return false
    end

    local role_vo = RoleController:getInstance():getRoleVo()
    local lev = 0
    if role_vo then
        lev = role_vo.lev or 0
    end

    --策划要求两个情况 : 1世界等级110且个人等级105开启 2个人等级120开启
     -- 个人等级限制 --先判断2
    local role_second_lv_cfg = Config.PartnerHolyEqmData.data_const.open_lev_second_condition
    if role_second_lv_cfg and lev < role_second_lv_cfg.val then
        --不满足2 再判断1
        -- 个人等级条件
        local role_lv_cfg = Config.PartnerHolyEqmData.data_const.open_lev_condition
        if lev < role_lv_cfg.val then
            return false
        end
        -- 世界等级限制
        local world_lv_cfg = Config.PartnerHolyEqmData.data_const.open_worldlev_condition
        local world_lev = RoleController:getInstance():getModel():getWorldLev()
        if world_lev and world_lv_cfg and world_lev < world_lv_cfg.val then
            -- if is_show_tips then
            --     message(world_lv_cfg.desc)
            -- end
            return false
        end
    end

    return true
end

function HeroModel:updateHolyEquipmentInfo(data)
    local id = data.partner_id or 0
    if self.hero_list[id] then 
        local hero_vo =  self.hero_list[id]
        if hero_vo.power < data.power then 
            GlobalMessageMgr:getInstance():showPowerMove( data.power-hero_vo.power ,nil,hero_vo.power )
        end

        --先清空神装记录
        if hero_vo.holy_eqm_list then
            for _, equip_vo in pairs(hero_vo.holy_eqm_list) do
                self.hero_holy_list[equip_vo.id] = nil
                self.dic_itemid_to_partner_id[equip_vo.id] = nil
            end
        end
        hero_vo:updateHeroVo(data)
        --在重新记录新的记录
        if hero_vo.holy_eqm_list then
            for _, equip_vo in pairs(hero_vo.holy_eqm_list) do
                self.hero_holy_list[equip_vo.id] = equip_vo
                self.dic_itemid_to_partner_id[equip_vo.id] = hero_vo.partner_id
            end
        end
        GlobalEvent:getInstance():Fire(HeroEvent.Holy_Equipment_Update_Event,hero_vo)
    end
end

function HeroModel:getHeroHolyEquipList(id)
    if self.hero_list[id] then 
        return self.hero_list[id].holy_eqm_list or {}
    end
    return {}
end

--获取所有英雄穿戴的装备信息
--@ return 
function HeroModel:getAllHeroHolyEquipList()
    return self.hero_holy_list or {}
end

function HeroModel:getHolyEquipById(id)
    if self.hero_holy_list then
        return self.hero_holy_list[id] 
    end
end

--更新神装信息
function HeroModel:updateHeroVoHolyEquipment(data_list, is_not_check)
    local is_team = false
    for i,v in ipairs(data_list) do
        if self.hero_list[v.partner_id] then
            self.hero_list[v.partner_id]:updateHolyEqmList(v.holy_eqm)
            if not is_team then
                if self.hero_list[v.partner_id]:isFormDrama() then
                    is_team = true
                end
            end
        end
    end
    self.hero_holy_list = {}
    for k,v in pairs(self.hero_list) do
        if v.holy_eqm_list then
            for _, equip_vo in pairs(v.holy_eqm_list) do
                self.hero_holy_list[equip_vo.id] = equip_vo
                self.dic_itemid_to_partner_id[equip_vo.id] = v.partner_id
            end
        end
    end

    -- 检查红点是要的暂时不考虑.留着
    -- if is_team and not is_not_check then
    --     --如果有剧情阵容的英雄..需要检查红点
    --     --检测红点
    --     HeroCalculate.checkAllHeroRedPoint()    
    -- end
end

--获取神装的属性颜色 根据 套装id 和神装属性
--@item_id 道具id
--@ attr_key  属性名字 
--@ value 属性值
--@return_format 返回格式  1 格式: #ffffff  2 格式: c4b(0xff,0xff,0xff,0xff) 默认1
--@color_type  1 黑底  2 白底 默认 1
function HeroModel:getHolyEquipmentColorByItemIdAttrKey(item_id, attr_key, value, return_format, color_type)
    local return_format = return_format or 1
    local color_type = color_type or 1
    local quality = self:getHolyEquipmentQualityByItemIdAttrKey(item_id, attr_key, value)
   
    if return_format == 2 then
        if color_type == 2 then
            return BackPackConst.getWhiteQualityColorC4B(quality)
        else
            return BackPackConst.getBlackQualityColorC4B(quality)
        end
    else
        if color_type == 2 then
           return BackPackConst.getWhiteQualityColorStr(quality)
        else
            return BackPackConst.getBlackQualityColorStr(quality)
        end
    end   
end

--获取品质
--@item_id 道具id
--@ attr_key  属性名字 
--@ value 属性值
function HeroModel:getHolyEquipmentQualityByItemIdAttrKey(item_id, attr_key, value)
    local quality = 0
    local holy_equip_config = Config.PartnerHolyEqmData.data_base_info(item_id)
    if holy_equip_config then
        local key = getNorKey(holy_equip_config.group_id, attr_key)
        local config = Config.PartnerHolyEqmData.data_attr_color_rule_fun(key)
        if value > 0 and config and config.color_list[1] then
            local list = config.color_list[1] -- {0-12}
            for i,v in ipairs(list) do
                if list[i+1] then
                    if value >= list[i] and value < list[i+1] then
                        quality = i - 1
                    end
                else
                    if value >= list[i] then
                       quality = i - 1
                    end
                end
            end
        end
    end
    return quality
end

--获取某个属性最大值
function HeroModel:getHolyEquipmentMaxAttrByItemIdAttrKey(item_id, attr_key)
    local max_count = 1
    local holy_equip_config = Config.PartnerHolyEqmData.data_base_info(item_id)
    if holy_equip_config then
        local config = Config.PartnerHolyEqmData.data_attr_max_info[holy_equip_config.group_id]
        if config then
            for i,v in ipairs(config.max_attr) do
                if v[1] and v[1] == attr_key then
                    max_count = v[2] or 1
                    break
                end
            end
        end
    end

    return max_count
end


----------------------------------神装结束----------------------------------------


----------------------红点检查-------------------------------------------
--检测升级红点更新
function HeroModel:checkLevelRedPointUpdate()
    GlobalEvent:getInstance():Fire(HeroEvent.Level_RedPoint_Event) 
    if self.is_delay_redpoint_update[HeroConst.RedPointType.eRPLevelUp] then
        return
    end
    self.is_delay_redpoint_update[HeroConst.RedPointType.eRPLevelUp] = true
    --清除升级红点记录
    HeroCalculate.clearAllHeroRecordByRedPointType(HeroConst.RedPointType.eRPLevelUp, true)
    
end

--设置更新equip红点的记录
function HeroModel:setEquipUpdateRecord(bool)
    self.is_equip_redpoint_bag_update = bool
    self.is_equip_redpoint_hero_update = bool
end


function HeroModel:checkEquipRedPointUpdate()
    --需要 背包 返回 和 英雄更新返回 才处理红点计算
    if self.is_equip_redpoint_bag_update and self.is_equip_redpoint_hero_update then
        --清除装备红点记录
        HeroCalculate.clearAllHeroRecordByRedPointType(HeroConst.RedPointType.eRPEquip)
        GlobalEvent:getInstance():Fire(HeroEvent.Equip_RedPoint_Event)
    end
end

function HeroModel:checkEquipComposeIsOpen(is_tips)
    local role_vo = RoleController:getInstance():getRoleVo()
    local partner_const = Config.PartnerEqmData.data_partner_const
    if role_vo.vip_lev < partner_const.synthesis_vip_lev.val and role_vo.lev < partner_const.synthesis_character_lev.val then
        if is_tips then
            local str = string.format(TI18N("语言_c_2302"),partner_const.synthesis_character_lev.val,partner_const.synthesis_vip_lev.val)
            message(str)
        end
        return false
    end
    return true
end

--设置更新升星红点的记录
function HeroModel:setUpgradeStarUpdateRecord(bool)
    self.is_upgradestar_redpoint_bag_update = bool
    self.is_upgradestar_redpoint_hero_update = bool
end


function HeroModel:checkUpgradeStarRedPointUpdate()
    --需要 背包 返回 和 英雄更新返回 才处理红点计算
    if self.is_upgradestar_redpoint_bag_update and self.is_upgradestar_redpoint_hero_update then
        --清除升星红点记录
        HeroCalculate.clearAllHeroRecordByRedPointType(HeroConst.RedPointType.eRPStar)
        -- GlobalEvent:getInstance():Fire(HeroEvent.UpgradeStar_RedPoint_Event)
    end
end

--检测天赋红点更新
function HeroModel:checkTalentRedPointUpdate()
    -- GlobalEvent:getInstance():Fire(HeroEvent.Level_RedPoint_Event) 
    if self.is_delay_redpoint_update[HeroConst.RedPointType.eRPTalent] then
        return
    end
    self.is_delay_redpoint_update[HeroConst.RedPointType.eRPTalent] = true
    --清除天赋红点记录
    HeroCalculate.clearAllHeroRecordByRedPointType(HeroConst.RedPointType.eRPTalent, true)
    
end

--检查阵法解锁    
--@lev 角色等级
function HeroModel:checkUnlockFormRedPoint(lev)
    local config = Config.FormationData.data_form_data
    if config then
        for i,v in pairs(config) do
            if v.need_lev > self.record_login_lev and v.need_lev <= lev then
                self.is_redpoint_form = true
                GlobalEvent:getInstance():Fire(HeroEvent.Form_RedPoint_Event) 
            end
        end
    end
    self.record_login_lev = lev
end

--检查圣器解锁
function HeroModel:checkUnlockHallowsRedPoint()
   self.is_redpoint_hallows = true
end

--------------------------------红点检查结束---------------------

---------------------神器相关相关------------------------------
function HeroModel:updatePartnerArtifactList(data)
    local id = data.partner_id or 0
    if self.hero_list[id] then 
        local hero_vo =  self.hero_list[id]
        if hero_vo.power < data.power then 
            GlobalMessageMgr:getInstance():showPowerMove( data.power-hero_vo.power ,nil,hero_vo.power )
        end
        self.hero_list[id]:updateHeroVo(data)
        GlobalEvent:getInstance():Fire(HeroEvent.Artifact_Update_Event,hero_vo)
        local is_artifact =  PartnerCalculate.getIsCanClothArtifact(hero_vo.bid) 
        hero_vo:updateRedPoint(PartnerConst.Vo_Red_Type.Artifact,is_artifact)
    end
   
end
function HeroModel:getPartnerArtifactList(id)
    if self.hero_list[id] then 
        return self.hero_list[id].artifact_list or {}
    end
    return {}
end
function HeroModel:getArtifactByType(id,pos)
    if self.hero_list[id] then 
        local artifact_list = self.hero_list[id].artifact_list or {}
        for i,v in pairs(artifact_list) do 
            if v and v.pos == pos then 
                return v
            end
        end
    end
    return {}
end

-- 符文祝福值
function HeroModel:setArtifactLucky( value )
    self.artifact_lucky = value
    self:updateArtifactLuckyRed()
end
function HeroModel:getArtifactLucky(  )
    return self.artifact_lucky
end

function HeroModel:updateArtifactLuckyRed(  )
    local max_lucky = 0
    local lucky_cfg = Config.PartnerArtifactData.data_artifact_const["change_condition"]
    if lucky_cfg and lucky_cfg.val then
        max_lucky = lucky_cfg.val
    end
    if self.artifact_lucky >= max_lucky then
        self.artifact_lucky_red = true
    else
        self.artifact_lucky_red = false
    end
    GlobalEvent:getInstance():Fire(HeroEvent.Artifact_Lucky_Red_Event)
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.mall, self.artifact_lucky_red)
end

-- 根据符文的技能id判断是否为稀有高级技能
local artifact_tag_list = Config.PartnerArtifactData.data_artifact_const.recast_tag
function HeroModel:checkIsUnusualSkillById( skill_id )
    local is_unusual = false
    if artifact_tag_list then
        for _,v in pairs(artifact_tag_list.val) do
            if skill_id == v then
               is_unusual = true
               break 
            end
        end
    end
    return is_unusual
end

-- 根据符文的技能id判断是否为强力高级技能
local recast_power_tag_list = Config.PartnerArtifactData.data_artifact_const.recast_power_tag
function HeroModel:checkIsUnusualSkillById2( skill_id )
    local is_unusual = false
    if recast_power_tag_list then
        for _,v in pairs(recast_power_tag_list.val) do
            if skill_id == v then
               is_unusual = true
               break 
            end
        end
    end
    return is_unusual
end

-- 获取符文祝福红点状态
function HeroModel:getArtifactLuckyRedStatus(  )
    return self.artifact_lucky_red
end

-- 符文重铸次数相关数据
function HeroModel:updateArtifactRecastCount( data_list )
    self.artifact_recast_data = data_list or {}
end
-- 根据符文品质获取对应品质的重铸次数
function HeroModel:getArtifactRecastCountByQuality( quality )
    local count = 0
    local max_count = 0
    local _type = 0 
    if quality == BackPackConst.quality.orange then -- 彩虹符文
        _type = 1
    elseif quality == BackPackConst.quality.red then -- 闪烁符文
        _type = 2
    end
    if self.artifact_recast_data and _type > 0 then
        for k,v in pairs(self.artifact_recast_data) do
            if v.type == _type then
                count = v.current
                max_count = v.limit
                break
            end
        end
    end
    return count, max_count
end

------------------------神器相关相关结束-------------------------------------

-------------------阵法相关--------------------------
function HeroModel:setFormList(data, index)
    local form_type = data.type or PartnerConst.Fun_Form.Drama
    local index = index or 1

    if self.pos_list[form_type]  then
        if next(self.pos_list[form_type]) ~= nil then 
            for pos, v in pairs(self.pos_list[form_type]) do
                local _index = math.floor(pos/self.pos_param) + 1
                if _index == index then
                    local vo = self:getHeroById(v.id)
                    --容错处理  bugly出现说  updateFormPos 这个是 (a nil value)
                    if vo and vo.updateFormPos then
                        vo:updateFormPos(0, form_type)
                        self.pos_list[form_type][pos] = nil
                    end
                end
            end
        end
    else
        self.pos_list[form_type] = {}
    end

    for i,v in pairs(data.pos_info) do 
        local pos = v.pos + (index - 1) * self.pos_param
        self.pos_list[form_type][pos] = v
        local vo = self:getHeroById(v.id)
        --容错处理  bugly出现说  updateFormPos 这个是 (a nil value)
        if vo and vo.updateFormPos then
            vo:updateFormPos(pos, form_type)
        end
    end

    --剧情阵法逻辑
    if form_type == PartnerConst.Fun_Form.Drama then

        self.form_power = data.power or 0
        --阵法类型
        self.use_formation_type = data.formation_type
        --使用的圣器id
        self.use_hallows_id = data.hallows_id

        GlobalEvent:getInstance():Fire(HeroEvent.Form_Drama_Event,data)
        
        local list = {}
        for k,v in pairs(self.pos_list[form_type]) do
            table_insert(list, {partner_id = v.id})
        end
        --请求天赋的
        HeroController:getInstance():sender11099(list)
        --请求神装
        -- HeroController:getInstance():sender11092(list)
    end
end

--发送获取所有英雄的属性 装备等数据
function HeroModel:sendAllHeroInfo()
    if self.hero_list then
        local list = {}
        for k,v in pairs(self.hero_list) do
            table_insert(list, {partner_id = v.id})
        end
        if #list > 0 then
            --请求英雄详细信息
            HeroController:getInstance():sender11026(list)
        end
    end
end

--批量请求英雄的属性 装备等数据 11026
function HeroModel:batchSendHeroInfo()
    if self.hero_list then
        local list = {}
        for k,v in pairs(self.hero_list) do
            table_insert(list, {partner_id = v.id})
            if #list > 150 then
                HeroController:getInstance():sender11026(list)
                list = {}    
            end
        end
        if #list > 0 then
            --请求英雄详细信息
            HeroController:getInstance():sender11026(list)
        end
    end
end

--获取所有英雄的神装信息
function HeroModel:sendAllHeroHolyEquipInfo()
    if self.hero_list then
        local list = {}
        for k,v in pairs(self.hero_list) do
            if not v:ishaveHolyEquipmentData() then
                table_insert(list, {partner_id = v.id})
            end
        end
        if #list > 0 then
            --所有英雄的神装信息
            HeroController:getInstance():sender11092(list)
        end
    end
end

--获取自己的队伍阵法站位
--@team_index --队伍索引 不传返回所有队伍的信息 
function HeroModel:getMyPosList(team_index)
    if not self.pos_list[PartnerConst.Fun_Form.Drama] then return {} end
    if team_index == nil then
        local drama_list = self.pos_list[PartnerConst.Fun_Form.Drama] or {}
        local pos_list = {}
        for pos, v in pairs(drama_list) do
            if self.hero_list[v.id] then
                pos_list[pos] = v
            end
        end
        return pos_list
    end
    local list = {}
    for pos,v in pairs(self.pos_list[PartnerConst.Fun_Form.Drama]) do
        local index = math.floor(pos/self.pos_param) + 1
        if index == team_index and self.hero_list[v.id] then
            table_insert(list, v) 
        end
    end
    return list
end

-----------------------------------阵法结束--------------------------


-------------------------------天赋技能开始===================================

--设置更新天赋红点
function HeroModel:setUpdateTalentRedpoint()
    self.is_need_update_talent_redpoint = true
end

--获取可学习天赋的记录 dic_hero_talent_skill_learn_redpoint[skill_id] = true
function HeroModel:getTalentRedpointRecord()
    if self.is_need_update_talent_redpoint then
        local dic_config = Config.PartnerSkillData.data_partner_skill_learn
        if dic_config then
            local is_enough
            for k,config in pairs(dic_config) do
                self.dic_hero_talent_skill_learn_redpoint[config.id] = nil
                is_enough = true
                for i,v in ipairs(config.expend) do
                    local count = BackpackController:getInstance():getModel():getItemNumByBid(v[1])
                    if count < v[2] then
                        is_enough = false
                        break
                    end
                end
                if is_enough then
                    self.dic_hero_talent_skill_learn_redpoint[config.id] = config.id
                end
            end
        end
    end
    -- self.is_need_update_talent_redpoint = false
    return self.dic_hero_talent_skill_learn_redpoint
end

-------------------------------天赋技能结束===================================

--创建星星显示
--@num 星星数量
--@star_con 星星父类
--@star_setting 星星设置结构
--star_setting.star_list = {}  1到5星的星星对象集合
--star_setting.star_list2 = {}  6到9星的星星对象集合
--star_setting.star10  10星对象
--star_setting.star_label  11星label
--@star_width 星星位置宽度

function HeroModel:createStar(num, star_con, star_setting, star_width)
    local num = num or 0
    local star_setting = star_setting or {}
    if star_setting.star_list == nil then
        star_setting.star_list = {}
    end

    if star_setting.star_list2 == nil then
        star_setting.star_list2 = {}
    end

    for i,v in pairs(star_setting.star_list) do
        v:setVisible(false)
    end
    for i,v in pairs(star_setting.star_list2) do
        v:setVisible(false)
    end
    if star_setting.star10 then
        star_setting.star10:setVisible(false)
    end

    if star_setting.moon then
        star_setting.moon:setVisible(false)
    end

    local width_s = star_width or (29 + 3)
    local _cStar = function(star_count, res, star_list,moveW,posy,scale)
        local posy = posy or 0
        local scale = scale or 1
        local width = star_width or (29 + 3)
        local x = - star_count * width * 0.5 + width * 0.5
        if moveW then 
            x = x + moveW
        end
        for i=1,star_count do
            if not star_list[i] or tolua.isnull(star_list[i]) then 
                local star = createImage(star_con,res,0,posy,cc.p(0.5,0.5),true,1,false)
                star:setScale(scale)
                star_list[i] = star
            end
            star_list[i]:loadTexture(res, LOADTEXT_TYPE_PLIST)
            star_list[i]:setVisible(true)
            star_list[i]:setPositionX(x + (i-1) * width)
        end
    end
    if num > 0 and num <= 5 then
        local res = PathTool.getResFrame("common","common_90074")
        _cStar(num, res, star_setting.star_list)
    elseif num >= 6 and num <= 9 then
        local res = PathTool.getResFrame("common","common_90074")
        local moonres = PathTool.getResFrame("common","common_90075_1")
        if star_setting.moon == nil or tolua.isnull(star_setting.moon) then 
            local star = createImage(star_con,moonres,0, 0,cc.p(0.5,0.5),true,0,false)
            star_setting.moon = star
            star_setting.moon:setScale(1.2)
        else
            star_setting.moon:setVisible(true)
        end
        local count = num - 5
        _cStar(count, res, star_setting.star_list,width_s*0.5)

        local startmoon = - count * width_s * 0.5 + width_s * 0.5 -width_s*0.5
        star_setting.moon:setPositionX(startmoon)
    elseif num >= 10 and num <= 15 then
        local new_num  = num - 10
        local res = PathTool.getResFrame("common","common_90073_1")
        if star_setting.star10 == nil then 
            local star = createImage(star_con,res,0, 0,cc.p(0.5,0.5),true,0,false)
            star:setScale(1.2)
            star:setCascadeOpacityEnabled(true)
            star_setting.star10 = star
        else
            star_setting.star10:setVisible(true)
        end
        if new_num > 0 then
            if star_setting.star_label == nil then
                local size = star_setting.star10:getContentSize()
                star_setting.star_label = createLabel(18,Config.ColorData.data_color4[1],Config.ColorData.data_color4[9],size.width * 0.5 - 2, size.height * 0.5,"10",star_setting.star10, 1, cc.p(0.5,0.5))
            else
                star_setting.star_label:setVisible(true)
            end
            star_setting.star_label:setString(new_num)
        else
            if star_setting.star_label then
                star_setting.star_label:setVisible(false)
            end
        end
    elseif num >= 16 then
        local new_num  = num - 10
        local res = PathTool.getResFrame("common_1","common_1_581")
        if star_setting.star10 == nil or tolua.isnull(star_setting.star10) then 
            local star = createImage(star_con,res,0, 0,cc.p(0.5,0.5),true,0,false)
            star:setScale(1.2)
            star:setCascadeOpacityEnabled(true)
            star_setting.star10 = star
        else
            star_setting.star10:setVisible(true)
        end
        if new_num > 0 then
            if star_setting.star_label == nil then
                local size = star_setting.star10:getContentSize()
                star_setting.star_label = createLabel(18,Config.ColorData.data_color4[1],Config.ColorData.data_color4[9],size.width * 0.5 - 2, size.height * 0.5,"10",star_setting.star10, 1, cc.p(0.5,0.5))
            else
                star_setting.star_label:setVisible(true)
            end
            star_setting.star_label:setString(new_num)
        else
            if star_setting.star_label then
                star_setting.star_label:setVisible(false)
            end
        end
    end
    return star_setting
end


function HeroModel:getTipsStr(star)
    local tips_str
    if star == 11 then
        tips_str = TI18N("满足以下任意条件开启：\n1. 个人等级达到110级或世界等级达到100级 \n2. 拥有5个不同的10星英雄 并且个人等级达到100级")
    elseif star == 12 then
        tips_str = TI18N("满足以下任意条件开启：\n1. 个人等级达到150级或世界等级达到140级 \n2. 拥有5个不同的11星英雄 并且个人等级达到120级")
    elseif star == 13 then
        tips_str = TI18N("满足以下任意条件开启：\n1. 拥有2个不同的12星英雄 并且个人和世界等级达到170级 \n2. 拥有2个不同的12星英雄 并且个人等级到达180级 \n3. 拥有5个不同的12星英雄 并且个人等级达到150级")
    else
        tips_str = ""
    end
    return tips_str
end

--检查是否开启11星条件 retur true:开启  false:不开启
function HeroModel:checkOpenStar11(is_show_tips)
    --策划要求 要么满足世界等级条件
    -- local config = Config.PartnerData.data_partner_const.staropen11_world_lev
    -- local is_open = true
    -- if config then
    --     if config.val[1] == "world_lev" then
    --         local world_lev = RoleController:getInstance():getModel():getWorldLev() or 0
    --         if world_lev < config.val[2]  then
    --             is_open = false
    --         end
    --     end
    -- end

    -- --要么满足 个人等级条件
    -- if not is_open then
    --     is_open = true
    --     local config_lev = Config.PartnerData.data_partner_const.staropen11_player_lev
    --     if config_lev and config_lev.val[1] == "lev" then
    --         local role_vo = RoleController:getInstance():getRoleVo()
    --         if role_vo and role_vo.lev < config_lev.val[2] then
    --             is_open = false
    --         end
    --     end
    -- end
    -- --策划加的额外条件
    -- local config = Config.PartnerData.data_partner_const.staropen11_3rd_open_limit
    -- local is_condition_3 = self:checkExtOpenInfo(config)
    -- if not is_open then
    --     is_open = is_condition_3 or false
    -- end

    -- local tips_str = nil
    -- if is_show_tips and not is_open then
    --     tips_str = self:getTipsStr(11)
    -- end

    local config = Config.PartnerData.data_partner_const.staropen11_crystal_limit
    if not config then return true end
    local is_open = true
    for i,v in ipairs(config.val) do
        if self:checkOpenByKeyValue(v[1],v[2]) then
            is_open = false
        end
    end
    return is_open, config.desc
end

-- 检查是否开启12星条件
function HeroModel:checkOpenStar12(is_show_tips)
    -- local config = Config.PartnerData.data_partner_const.staropen12_world_lev
    -- local is_open = true
    -- if config then
    --     if config.val[1] == "world_lev" then
    --         local world_lev = RoleController:getInstance():getModel():getWorldLev() or 0
    --         if world_lev < config.val[2]  then
    --             is_open = false
    --         end
    --     end
    -- end

    --  --要么满足 个人等级条件
    -- if not is_open then
    --     is_open = true
    --     local config_lev = Config.PartnerData.data_partner_const.staropen12_player_lev
    --     if config_lev and config_lev.val[1] == "lev" then
    --         local role_vo = RoleController:getInstance():getRoleVo()
    --         if role_vo and role_vo.lev < config_lev.val[2] then
    --             is_open = false
    --         end
    --     end
    -- end
    
    -- --策划加的额外条件
    -- local config = Config.PartnerData.data_partner_const.staropen12_3rd_open_limit
    -- local is_condition_3 = self:checkExtOpenInfo(config)
    -- if not is_open then
    --     is_open = is_condition_3 or false
    -- end

    -- local tips_str = nil
    -- if is_show_tips and not is_open then
    --     tips_str = self:getTipsStr(12)
    -- end

    local config = Config.PartnerData.data_partner_const.staropen12_crystal_limit
    if not config then return true end
    local is_open = true
    for i,v in ipairs(config.val) do
        if self:checkOpenByKeyValue(v[1],v[2]) then
            is_open = false
        end
    end

    return is_open, config.desc
end


-- 检查是否开启13星条件
function HeroModel:checkOpenStar13(is_show_tips)
    -- if self.is_star13_open then --如果已经计算开启过了.就不计算了
    --     return true
    -- end
    -- --优先判断 等级 第一条件不满足再判断第二条件
    -- local config = Config.PartnerData.data_partner_const.staropen13_limit_lev2
    -- local is_open = true
    -- if config then
    --     if self:checkOpenByKeyValue(config.val[1],config.val[2]) then
    --         is_open = false
    --     end
    -- end
    -- --如果上面不满足 再判断第二个条件
    -- if not is_open then
    --     is_open = true
    --     local config = Config.PartnerData.data_partner_const.staropen13_limit_lev1
    --     if config then
    --         for i,v in ipairs(config.val) do
    --             if self:checkOpenByKeyValue(v[1],v[2]) then
    --                 is_open = false
    --                 break
    --             end
    --         end
    --     end
    -- end
    -- --条件1 个人和世界等级达到170级 或 个人等级到达180级 开启升星
    -- local is_condition_1 = is_open
    -- --条件2 拥有2个12星英雄开启升星
    -- local is_condition_2 = false
    -- --条件3 个人等级达到150，且拥有5个及以上的12星，13星
    -- local is_condition_3 = false

    -- --第二个硬性条件
    -- --13星特殊要 曾经有2个12星英雄
    -- local config = Config.PartnerData.data_partner_const.staropen13_limit_partner
    -- if config and next(config.val) then
    --     local count = 0
    --     for k,star in pairs(self.dic_had_hero_info) do
    --         if star >= config.val[1] then
    --             count = count + 1
    --             if count >= config.val[2] then
    --                 break
    --             end
    --         end
    --     end
    --     if count < config.val[2] then
    --         is_open = false
    --         is_condition_2 = false
    --     else
    --         is_condition_2 = true
    --     end
    -- end
    -- is_condition_2 = is_open

    -- --策划加的额外条件
    -- local config = Config.PartnerData.data_partner_const.staropen13_3rd_open_limit
    -- is_condition_3 = self:checkExtOpenInfo(config)
    -- if not is_open then
    --     is_open = is_condition_3 
    -- end
    
    -- local tips_str = nil
    -- if is_show_tips and not is_open then
    --     -- if not is_condition_1 and not is_condition_2 and not is_condition_3 then
    --     --     --三个条件都不满足
    --     --     tips_str = TI18N("满足以下任意条件开启：1.拥有2个12星英雄 并且个人和世界等级达到170级 \n2. 拥有2个12星英雄 并且个人等级到达180级 \n3.拥有5个12星英雄 并且个人等级达到150级")
    --     -- end

    --     -- if not is_condition_1 and not is_condition_2 then
    --     --     --两个都不满足
    --     --     tips_str = TI18N("满足以下条件开启：1.拥有2个12星英雄\n2.个人和世界等级达到170级 或 个人等级到达180级")
    --     -- elseif not is_condition_1 and is_condition_2 then
    --     --     tips_str = TI18N("个人和世界等级达到170级 或 个人等级到达180级 开启升星")
    --     -- else
    --     --     tips_str = TI18N("拥有2个12星英雄开启升星")
    --     -- end
    --     tips_str = self:getTipsStr(13)
    -- end
    -- if is_open then
    --     --如果已经开启 那么记录
    --     self.is_star13_open = true
    -- end
    local config = Config.PartnerData.data_partner_const.staropen13_crystal_limit
    if not config then return true end
    local is_open = true
    for i,v in ipairs(config.val) do
        if self:checkOpenByKeyValue(v[1],v[2]) then
            is_open = false
        end
    end
    return is_open, config.desc
end

function HeroModel:checkExtOpenInfo(config)
    -- 策划要求:原来的条件没变。只是新增一个或条件，
    -- 个人等级达到100/120/150，且拥有5个及以上的10/11/12星，开启11/12/13星
    local val = config.val
    if val == nil or next(val) == nil then return false end

    if self:checkOpenByKeyValue(val[1][1], val[1][2]) then
        return false
    end 
    if val[2] == nil then return false end
    -- local hero_star = val[2][1] or "hero_star" --这个前端不需要..因为需要写死的
    local star = val[2][2] or 10
    local count = val[2][3] or 5


    if self.dic_star_count[star] == nil then
        self.dic_star_count[star] = 0
        for k,_star in pairs(self.dic_had_hero_info) do
            if _star >= star then
                self.dic_star_count[star] = self.dic_star_count[star] + 1
                if self.dic_star_count[star] >= count then
                    break
                end
            end
        end
        if self.dic_star_count[star] >= count then
            return true
        end
    else
        if self.dic_star_count[star] >= count then
            return true
        end
    end
    return false
end

--return true 表示不满足  false 表示满足
function HeroModel:checkOpenByKeyValue(key, value)
    if not value then return false end
    if key == "world_lev" then
        local world_lev = RoleController:getInstance():getModel():getWorldLev() or 0
        return world_lev < value
    elseif key == "lev" then
        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo and role_vo.lev < value then
            return true
        end
    end
    return false
end


--获取神装套装描述
--@equip_vo_list 装备列表 结构{goods_vo,goods_vo,...}  
--return 描述list
-- 返回结构 {}
function HeroModel:getHolyEquipSuitDes(equip_vo_list)
    if not equip_vo_list then return {} end
        

    local dic_suit_set = {}
    local dic_eqm_set_list = {}
    local math_floor = math.floor
    for k,euip_vo in pairs(equip_vo_list) do
        if euip_vo.config then
            local eqm_key = math_floor(euip_vo.config.eqm_set/100)
            if dic_suit_set[eqm_key] == nil then
                dic_suit_set[eqm_key] = 1
                dic_eqm_set_list[eqm_key] = {euip_vo.config.eqm_set}
            else
                dic_suit_set[eqm_key] = dic_suit_set[eqm_key] + 1
                table_insert(dic_eqm_set_list[eqm_key], euip_vo.config.eqm_set)
            end
        end
    end
    local suit_config = {}
    for eqm_key, count in pairs(dic_suit_set) do
        local eqm_set_list = dic_eqm_set_list[eqm_key]
        if count > 1 then
            table.sort( eqm_set_list, function(a,b) return a > b end)

            local cur_eqm_set = nil
            local cur_config = nil
            for i,eqm_set in ipairs(eqm_set_list) do
                if cur_eqm_set == nil then
                    cur_eqm_set = eqm_set
                    cur_config = Config.PartnerHolyEqmData.data_suit_info[eqm_set]
                    table_sort( cur_config, function(a, b) return a.num < b.num end)
                else
                    if cur_eqm_set ~= eqm_set then
                        cur_config = Config.PartnerHolyEqmData.data_suit_info[eqm_set]
                        table_sort( cur_config, function(a, b) return a.num < b.num end)    
                    end
                    for _,suit_info in ipairs(cur_config) do
                        if suit_info.num == i then
                            table_insert(suit_config, suit_info)
                            break
                        end
                    end
                end
            end
        end
    end
    -- local suit_data_list = {}
    local list = {}
    for i,v in ipairs(suit_config) do
        --说明是激活的
        local eqm_set = v.id
        local id = math_floor(eqm_set/100)
        local config = Config.PartnerHolyEqmData.data_suit_res_prefix_fun(id)
        if config then
            local data = {}
            data.num = v.num
            data.icon_res = PathTool.getSuitRes(config.prefix)
            data.name = string_format(TI18N("语言_c_4886"), v.name, v.num)
            data.id  = eqm_set 

            -- if suit_data_list[eqm_set] == nil or suit_data_list[eqm_set].num < v.num then 
            --     suit_data_list[eqm_set] = data
            -- end
            table_insert(list, data)
        end
    end

    -- for k,v in pairs(suit_data_list) do
    --     table_insert(list, v)
    -- end
    local sort_fun = SortTools.tableLowerSorter({"id","num"})
    table_sort(list, sort_fun)

    return list
end

--初始化皮肤 信息英雄皮肤 
function HeroModel:initHeroSkin(data)
    if not data then return end

    --判定是否要显示卡片展示界面
    if self.hero_skin_list then
        local show_skin_id
        for i,v in ipairs(data.partner_skins) do
            if self.hero_skin_list[v.id] == nil then
                --说明本地没有 --只第一个
                show_skin_id = v.id
                break
            end
        end
        if show_skin_id then
            --显示
            local skin_config = Config.PartnerSkinData.data_skin_info[show_skin_id]
            if skin_config then
                local setting = {}
                setting.partner_bid = skin_config.bid
                setting.is_chips = 1
                setting.init_star = 5
                setting.status = 1
                setting.show_type = PartnersummonConst.Gain_Show_Type.Skin_show
                setting.skin_id = show_skin_id
                PartnersummonController:getInstance():openSummonGainShowWindow(true, setting, 2)
            end
        end
    end

    self.hero_skin_list = {}
    --是否开启定时器 时间后端算了..前端不用背锅
    -- local can_start_ticket = false
    for i,v in ipairs(data.partner_skins) do
        self.hero_skin_list[v.id] = v.end_time
        -- if v.end_time > 0 then
        --     can_start_ticket = true
        -- end
    end

    -- --启动定时器算时间
    -- if can_start_ticket and self.hero_skin_time_ticket == nil  then
    --     self.hero_skin_time_ticket = GlobalTimeTicket:getInstance():add(function()
    --         local sever_time = GameNet:getInstance():getTime()
    --         local have_skin_time = false
    --         for k,end_time in pairs(self.hero_skin_list) do
    --             if end_time ~= 0 then
    --                 if end_time <= sever_time  then
    --                     self.hero_skin_list[k] = nil
    --                 else
    --                     have_skin_time = true
    --                 end
    --             end
    --         end
    --         if not have_skin_time then
    --             self:clearHeroSkinTimeTicket()
    --         end
    --     end,1)
    -- end
end

--根据皮肤id 返回皮肤数据  
--@return 皮肤有效时间点..  如果永久返回 0 如果返回nil 表示 没有解锁该皮肤
function HeroModel:getHeroSkinInfoBySkinID(skin_id)
    if self.hero_skin_list and self.hero_skin_list[skin_id] then
        return self.hero_skin_list[skin_id]
    end
end
--是否解锁该皮肤
--is_check_time:判断是否存在过期
function HeroModel:isUnlockHeroSkin(skin_id, is_check_time)
    if self.hero_skin_list and self.hero_skin_list[skin_id] then
        if is_check_time then
            if self.hero_skin_list[skin_id] > 0 then
                return false
            end 
        end
        return true
    end 
    return false
end



function HeroModel:clearHeroSkinTimeTicket()
    if self.hero_skin_time_ticket then
        GlobalTimeTicket:getInstance():remove(self.hero_skin_time_ticket)
        self.hero_skin_time_ticket = nil
    end
end
--远征阵法
function HeroModel:setExpeditPosList(data)
    
end
function HeroModel:getExpeditPosList()
    return self.expedit_list or {}
end

function HeroModel:updateHolyEquipmentPlan(data)
    if data.num then --格子上限
        self.holy_equip_plan_count = data.num
    end
    if self.holy_equip_plan == nil then
        self.holy_equip_plan = {}
    end
    if data.holy_eqm_set_cell then
        for i,cell in ipairs(data.holy_eqm_set_cell) do
            if self.holy_equip_plan[cell.id] then
                for k,v in pairs(cell) do
                    self.holy_equip_plan[cell.id][k] = v
                end
            else
                self.holy_equip_plan[cell.id] = cell
            end
        end
    end
end

function HeroModel:getHolyEquipmentPlanData()
    return self.holy_equip_plan
end

--检查道具是否在神装管理里面
--@item_id 物品唯一id
function HeroModel:checkHolyEquipmentPalnByItemID( item_id)
    if not item_id then return false end
    if not self.holy_equip_plan then return false end
    for i,cell in pairs(self.holy_equip_plan) do
        for i,v in ipairs(cell.list) do
            if item_id == v.item_id then
                return true,cell
            end
        end
    end
    return false
end

function HeroModel:getCystalPreLevLimit( )
    if self.cystal_pre_lev_limit == nil then
        self.cystal_pre_lev_limit = 340
        local config = Config.ResonateData.data_const.cystal_pre_lev_limit
        if config then
            self.cystal_pre_lev_limit = config.val
        end
    end
    return self.cystal_pre_lev_limit or 340
end

--是否共鸣水晶最大等级 注意: 还有一个突破上限等级  后端传过来的
function HeroModel:isResonateCystalMaxLev()
    --340 英雄 13星升级的最大等级 
    if self.resonate_cystal_lev and self.resonate_cystal_lev >= self:getCystalPreLevLimit() then
        return true
    end
    return false
end

function HeroModel:isCanShowLabelMaxLev(lev)
    if lev and lev < self:getCystalPreLevLimit() then
        return false
    end
    return true
end

function HeroModel:getDicResonateFiveHeroVo(  )
    return self.dic_resonate_five_hero_vo or {}
end

--是否共鸣水晶上阵的英雄 如果 hero_vo 不确定是 hero_vo 类的 用此方法判断
function HeroModel:isResonateCystalHero(hero_vo)
    if hero_vo.isResonateCrystalHero then
        if hero_vo:isResonateCrystalHero() then
            return true
        end
    elseif hero_vo.resonate_lev and hero_vo.resonate_lev > 0 then
        return true
    end
    return false
end
--是否升星神树上阵的英雄 如果 hero_vo 不确定是 hero_vo 类的 用此方法判断
function HeroModel:isStarCystalHero(hero_vo)
    if hero_vo.isUpStarTreeHero then
        if hero_vo:isUpStarTreeHero() then
            return true
        end
    elseif hero_vo.resonate_star and hero_vo.resonate_star > 0 then
        return true
    end
    return false
end
function HeroModel:getResonateCystalInfo()
    return self.resonate_cystal_info
end
--更新共鸣锁定信息
function HeroModel:updateResonateCystalInfo(data)
    if not data then return end
    self.resonate_cystal_lev = data.lev

    self.dic_resonate_five_hero_vo = {}

    local star = 0
    for i,v in ipairs(data.con_list) do
        if v.id ~= 0 then
            local hero_vo = self:getHeroById(v.id)
            if hero_vo and next(hero_vo) ~= nil then
                self.dic_resonate_five_hero_vo[hero_vo.id] = hero_vo
            end
            if hero_vo.star then
                star = star + hero_vo.star
            end
        end
    end

    for id, hero_vo in pairs(self.dic_resonate_lock_info) do
        if hero_vo.updateLock then
            local data = {{lock_type = HeroConst.LockType.eHeroResonateLock, is_lock = 0}}
            hero_vo:updateLock(data)
        end
    end
    self.dic_resonate_lock_info = {}
    for i,v in ipairs(data.res_list) do
        if v.id ~= 0 then
            local hero_vo = self:getHeroById(v.id)
            if hero_vo and hero_vo.updateLock then
                self.dic_resonate_lock_info[v.id] = hero_vo
                local data = {{lock_type = HeroConst.LockType.eHeroResonateLock, is_lock = 1}}
                hero_vo:updateLock(data)
            end
        end
    end
    if self.resonate_max_partner_lev == nil then
        -- 说明26400没有返回了
        self.resonate_max_partner_lev = star
    end
end

function HeroModel:updateResonateLockInfo(data)
    self.resonate_stone_level = data.lev or 0
    self.resonate_max_partner_lev = data.max_partner_lev or 0
    -- for id, hero_vo in pairs(self.dic_resonate_lock_info) do
    --     if hero_vo.updateLock then
    --         local data = {{lock_type = HeroConst.LockType.eHeroResonateLock, is_lock = 0}}
    --         hero_vo:updateLock(data)
    --     end
    -- end
    -- self.dic_resonate_lock_info = {}
    -- for i,v in ipairs(data.list) do
    --     if v.id ~= 0 then
    --         local hero_vo = self:getHeroById(v.id)
    --         if hero_vo and hero_vo.updateLock then
    --             self.dic_resonate_lock_info[v.id] = hero_vo
    --             local data = {{lock_type = HeroConst.LockType.eHeroResonateLock, is_lock = 1}}
    --             hero_vo:updateLock(data)
    --         end
    --     end
    -- end

    --判断是有红点
    self:checkResonateRedPoint()
end

function HeroModel:checkResonateRedPoint()
    if not self.resonate_stone_level then return end
    if not self.resonate_max_partner_lev then return end

    local resonate_stone_condition = 50
    local config = Config.ResonateData.data_const.amp_all_start_limit
    if config then
        resonate_stone_condition = config.val
    end
    --不满足开启不计算显示了
    if self.resonate_max_partner_lev < resonate_stone_condition then
        return 
    end

    local config = Config.ResonateData.data_level_up(self.resonate_stone_level)
    local is_redpoint = false
    if config then
        if config.expend and next(config.expend) ~= nil then
            is_redpoint = true
            for i,v in ipairs(config.expend) do
                local bid = v[1] 
                local num = v[2] 
                local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                if num and num > have_num then
                    is_redpoint = false
                end
            end
        end
    end
    self.is_resonate_stone_redpoint = is_redpoint
    local data = {bid = HeroConst.RedPointType.eResonate_stone, status = self.is_resonate_stone_redpoint}
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.resonate, {data})
end
--是否最高等级
function HeroModel:isResonateMaxLevel(lev)
    if lev then
        local config = Config.ResonateData.data_level_up(lev + 1)
        if config == nil then
            return true
        end
    end
    return false
    -- body
end
-- 共鸣是否开启
function HeroModel:checkResonateIsOpen( not_tips )
    local role_vo = RoleController:getInstance():getRoleVo()
    local limit_lv_cfg = Config.ResonateData.data_const["open_lev"]
    if limit_lv_cfg and role_vo and limit_lv_cfg.val <= role_vo.lev then
        return true
    end
    if not not_tips and limit_lv_cfg then
        message(limit_lv_cfg.desc)
    end
    return false
end

-- 异界英雄是否开启
function HeroModel:checkSoulHeroIsOpen()
    local role_vo = RoleController:getInstance():getRoleVo()
    local limit_lv_cfg = Config.PartnerData.data_partner_const["sphero_lev"]
    if limit_lv_cfg and role_vo and limit_lv_cfg.val[2] <= role_vo.lev then
        return true
    end
    return false
end

--检查共鸣精炼经验的红点 data 是 26410协议结构
function HeroModel:checkResonateExtractRedpoint(data)
    if not self:checkResonateIsOpen(true) then
        return 
    end
    self.is_resonate_extract_redpoint = false

    if not self.resonate_max_partner_lev then return end
    
    local resonate_stone_condition = 50
    local config = Config.ResonateData.data_const.amp_all_start_limit
    if config then
        resonate_stone_condition = config.val
    end
    --不满足开启不计算显示了
    if self.resonate_max_partner_lev < resonate_stone_condition then
        return 
    end

    if data.all_num ~= 0 then
        local count = data.do_num + data.get_num
        if count >= data.all_num then
            self.is_resonate_extract_redpoint = true
        end
    else
        self.is_resonate_extract_redpoint = (data.is_point == 1)
        if self.is_resonate_extract_redpoint then
            --等级不满的情况下
            if not self:isResonateMaxLevel(self.resonate_stone_level) then
                local config = Config.ResonateData.data_const.single_refine_consume
                if config and next(config.val) ~= nil then
                    local cost_item_id = config.val[1][1]
                    local single_cost_count = config.val[1][2]
                    local count = BackpackController:getInstance():getModel():getItemNumByBid(cost_item_id, BackPackConst.Bag_Code.BACKPACK)
                    if count < single_cost_count then
                        self.is_resonate_extract_redpoint = false
                    end
                end
            end
        end
    end

    --策划要求不显示在主界面 
    local data = {bid = HeroConst.RedPointType.eResonate_extract, status = self.is_resonate_extract_redpoint}
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.resonate, {data})

    --红点有变化
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Extract_Redpoint_Event, self.is_resonate_extract_redpoint)
end
--是否有共鸣精炼经验红点
function HeroModel:isResonateExtractRedpoint()
    return (self.is_resonate_extract_redpoint == true)
end


--重生次数
function HeroModel:setResetCount(data)
    if not data then return end
    self.reset_count = data.day_num
    local hero_vo = self:getHeroById(data.partner_id)
    if hero_vo and next(hero_vo) ~= nil then
        hero_vo:initResetTime(data.end_time)
    end
end

function HeroModel:getResetCount()
    return self.reset_count 
end
function HeroModel:removeResetTimeInfo()
   for k,v in pairs(self.hero_list) do
       v.reset_time = nil
   end
end

--是否是公会pvp 阵法类型 
function HeroModel:isGuildPvpFrom(form_type)
    if self.dic_guild_from_type == nil then
        self.dic_guild_from_type = {}
        local config_list = Config.CombatTypeData.data_fight_list
        if config_list then
            for k,config in pairs(config_list) do
                if config.is_guild_pvp == 1 then
                    if next(config.from) ~= nil then
                        for _,form in pairs(config.from[1]) do
                            self.dic_guild_from_type[form] = true
                        end
                    end
                end
            end
        end
    end
    return self.dic_guild_from_type[form_type]
end
--根据bid返回英雄分数
function HeroModel:heroBidScore(bid)
    if bid then
        local cfg = Config.PartnerData.data_partner_base[bid]
        if not cfg then return "" end 
        local score = cfg.score
        local skin_cfg = Config.PartnerSkinData.data_partner_bid_info[bid]
        if skin_cfg then
            for k, v in pairs(skin_cfg) do
                if self:isUnlockHeroSkin(v.skin_id) then
                    local skin_config = Config.PartnerSkinData.data_skin_info[v.skin_id]
                    if skin_config then
                        score = score + skin_config.score_add
                    end
                end
            end
        end
        return score
    end
    return ""
end

--判断是否高过共鸣水晶等级
function HeroModel:checkEnoughResLev(lv)
    if self.resonate_cystal_lev then 
        return self.resonate_cystal_lev>=lv
    end
    return false
end

--自动献祭相关
function HeroModel:getAutoSacrificeList()
    local status = SysEnv:getInstance():getNum(SysEnv.keys.one_key_sacrifice, 0)
    if status == 0 then return end--么有勾选自动献祭
    local cfg = Config.PartnerData.data_partner_const.game_select
    local diffItem = cfg.val[status]
    local star = diffItem[1]
    local leftNum = diffItem[2]
    local hero_list = self:getHeroList()
    local show_list = {}
    local lock_list = {}
    for k, hero_vo in pairs(hero_list) do
        if not hero_vo:isResonateHero() then
            -- 锁定 , 上阵,不能被分解
            if hero_vo:isLock() or (hero_vo.isInForm and hero_vo:isInForm()) or hero_vo:checkHeroLockTips(true, nil, true) then
                table_insert(lock_list, hero_vo)
            else
                if hero_vo.star <= star then --小于指定星级
                    table_insert(show_list, hero_vo)
                end
            end
        end
    end 
    local sort_func = SortTools.tableUpperSorter({"camp_type","star", "lev",})
    table_sort(lock_list, sort_func) 
    table_sort(show_list, sort_func) 
    local saveList1 = {}
    local saveList2 = {}
    local saveList3 = {}
    local saveList4 = {}
    local saveList5 = {}
    for i,hero_vo in ipairs(show_list) do
        if hero_vo.star <= star and hero_vo.is_in_form <= 0 then
            if hero_vo.camp_type == 1 and tableLen(saveList1) < leftNum then
                table_insert(saveList1,hero_vo.partner_id)
            end 
            if hero_vo.camp_type == 2 and tableLen(saveList2) < leftNum then
                table_insert(saveList2,hero_vo.partner_id)
            end 
            if hero_vo.camp_type == 3 and tableLen(saveList3) < leftNum then
                table_insert(saveList3,hero_vo.partner_id)
            end 
            if hero_vo.camp_type == 4 and tableLen(saveList4) < leftNum then
                table_insert(saveList4,hero_vo.partner_id)
            end 
            if hero_vo.camp_type == 5 and tableLen(saveList5) < leftNum then
                table_insert(saveList5,hero_vo.partner_id)
            end 
        end
    end
    local disbleList = {}
    for i,hero_vo in ipairs(show_list) do
        if hero_vo.star <= star and hero_vo.is_in_form then
            if hero_vo.camp_type == 1 then
            local isIn1 = self:in_array(hero_vo.partner_id,saveList1)
                if isIn1 == false then  
                    table_insert(disbleList, {partner_id = hero_vo.partner_id})      
                end
            end 
            if hero_vo.camp_type == 2 then
                local isIn2 = self:in_array(hero_vo.partner_id,saveList2)
                if isIn2 == false then
                    table_insert(disbleList, {partner_id = hero_vo.partner_id})  
                end
            end 
            if hero_vo.camp_type == 3 then
                local isIn3 = self:in_array(hero_vo.partner_id,saveList3)
                if isIn3 == false then
                    table_insert(disbleList, {partner_id = hero_vo.partner_id})     
                end
            end 
            if hero_vo.camp_type == 4 then
                local isIn4 = self:in_array(hero_vo.partner_id,saveList4)
                if isIn4 == false then
                    table_insert(disbleList, {partner_id = hero_vo.partner_id}) 
                end
            end 
            if hero_vo.camp_type == 5 then
            local isIn5 = self:in_array(hero_vo.partner_id,saveList5)
                if isIn5 == false then
                    table_insert(disbleList, {partner_id = hero_vo.partner_id}) 
                end
            end 
        end
    end
    return disbleList
end

function HeroModel:in_array(b,list)
    if not list then
      return false 
    end 
    if list then
        for k, v in pairs(list) do
            if v == b then
                return true
            end
        end
    end
    return false
end 
function HeroModel:getHeroCampList(select_camp)
    local config_list = Config.PartnerData.data_partner_base or {}
    
    local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("partner_data")
    local list = {}
    for k, config in pairs(config_list) do
        if select_camp == 0 or (select_camp == config.camp_type) then
            if config.isshow == 0 and not table.indexof(nohideIds,config.bid) then
                -- 后台配置屏蔽的
            else
                table_insert(list, config)    
            end
        end
    end
    return list
end
function HeroModel:getHeroCampListRed(select_camp)
    local list = self:getHeroCampList(select_camp)
    for k, v in pairs(list) do
        if self:getHeroLibRed(v.bid) then
            status = true
            return true 
        end
    end
    return false
end
--英雄下阵
function HeroModel:openherotips(item,hero_vo)
    if not HeroController:getInstance():openHeroResetWindowIsOpen() and not HeroController:getInstance():openHeroMainInfoWindowIsOpen() and not HeroController:getInstance():openUpgradeStarSelectPanelIsOpen() then return end
    self.item = item
    self.hero_vo = hero_vo
    local str = hero_vo:checkHeroSacrificeTips(hero_vo.dic_in_form)
    hero_dic_num = tableLen(hero_vo.dic_in_form)
    hero_dic_count = tableLen(hero_vo.dic_in_form)
    HeroController:getInstance():openHeroTipsWindow(true,str,hero_vo)
end
function HeroModel:SetNextBattle(num) -- 下阵接收协议
    if not HeroController:getInstance():openHeroResetWindowIsOpen() and not HeroController:getInstance():openHeroMainInfoWindowIsOpen() and not HeroController:getInstance():openUpgradeStarSelectPanelIsOpen() then return end
    table.insert(self.hero_protocol,num)
end
function HeroModel:NextBattle(num) -- 下阵
    if not HeroController:getInstance():openHeroResetWindowIsOpen() and not HeroController:getInstance():openHeroMainInfoWindowIsOpen() and not HeroController:getInstance():openUpgradeStarSelectPanelIsOpen() then return end
    for key, value in pairs(self.hero_protocol) do
        if value == num then 
            table.remove(self.hero_protocol,key)
        end
        if tableLen(self.hero_protocol) == 0 then
            if self.isFirst then
                self.isFirst = false
                self:FinishNextBattle()
            end
        end
    end
end
function HeroModel:setHeroSacrificelist(_index)
    local cfg = Config.PartnerData.data_partner_const.game_select.val
    if cfg[_index] then
        local list = cfg[_index]
        HeroController:getInstance():sender29201(list[1],list[2])
    else
        HeroController:getInstance():sender29201(0,0)
    end
end
function HeroModel:getHeroSacrifice(_star,_num)
    if _star and _num then
        local cfg = Config.PartnerData.data_partner_const.game_select.val
        for key, value in pairs(cfg) do
            if value[1] == _star and value[2] == _num then
                self.one_key_sacrifice = key
                GlobalEvent:getInstance():Fire(HeroEvent.Hero_Sacrifice_Event)
                return
            end
        end
    end
    self.one_key_sacrifice = 0
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Sacrifice_Event)
    return 
end
function HeroModel:getHeroSacrificeNum()
    return self.one_key_sacrifice or 0
end
function HeroModel:FinishNextBattle() -- 下阵完毕
    if not self.hero_vo then return end
    local hero_vo = self.hero_list[self.hero_vo.partner_id]
    if hero_vo and hero_vo.is_in_form == 0 and not hero_vo:isInTeamAction() then
        if hero_vo.is_lock == 0 then
            message(TI18N("语言_c_4558"))
            self.isFirst = true
            if self.item and self.item.showLockIcon then
                self.item:showLockIcon(false)
            end
        elseif hero_vo.is_lock == 1 and hero_vo:isLock() then
            message(TI18N("语言_c_3286"))
        end
    else
        if self.item and self.item.showLockIcon then
            self.item:showLockIcon(true)
        end
        self.isFirst = true
        HeroController:getInstance():openHeroFailTipsWindow(true,self.hero_vo.partner_id)
    end
end
--符文重铸自选技能列表
function HeroModel:getRecastOptionalList(id)
    if id > 10456 then
        return Config.PartnerArtifactData.data_artifact_const["super_recast_tag"]
    else
        return Config.PartnerArtifactData.data_artifact_const["recast_tag"]
    end
end
--神装升星返回当前星阶升到满星还可以激活哪些属性
function HeroModel:getGodBaseList(id)
    local list = {}
    local function getList(id)
        local data = Config.PartnerHolyEqmData.data_step_info(id) 
        if data then
            local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("features_shield")
            local featuresId = MainuiConst.FeaturesShield.godOutfit
            local nohideIds2 = RoleController:getInstance():getModel():getSeverShowIds("partner_holy_eqm_data")
            if data.is_base >= 1 and table.indexof(nohideIds,featuresId) and (data.isshow == 1 or (data.isshow == 0 and table.indexof(nohideIds2,data.id))) then
                local item_data = Config.ItemData.data_get_data(id)
                if item_data and item_data.eqm_star then
                    local attList = {item_data.eqm_star,data.step}
                    table.insert(list,attList)
                end
            end
            getList(data.next_id)
        end
    end
    local data = Config.PartnerHolyEqmData.data_step_info(id)
    if data then
        getList(data.next_id)
    end
    return list
end
function HeroModel:getGodRandList(id)
    local list = {}
    local function getList(id)
        local data = Config.PartnerHolyEqmData.data_step_info(id) 
        if data then
            local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("features_shield")
            local featuresId = MainuiConst.FeaturesShield.godOutfit
            local nohideIds2 = RoleController:getInstance():getModel():getSeverShowIds("partner_holy_eqm_data")
            if data.is_rand >= 1 and table.indexof(nohideIds,featuresId) and (data.isshow == 1 or (data.isshow == 0 and table.indexof(nohideIds2,data.id))) then
                local item_data = Config.ItemData.data_get_data(id)
                if item_data and item_data.eqm_star then
                    local attList = {item_data.eqm_star,data.step}
                    table.insert(list,attList)
                end
            end
            getList(data.next_id)
        end
    end
    local data = Config.PartnerHolyEqmData.data_step_info(id)
    if data then
        getList(data.next_id)
    end
    return list
end
function HeroModel:getGodCanUpStar(data,config)
    local can_up = false
    local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("features_shield")
    local featuresId = MainuiConst.FeaturesShield.godOutfit
    local nohideIds2 = RoleController:getInstance():getModel():getSeverShowIds("partner_holy_eqm_data")
    if RoleController:getInstance():getRoleVo().lev >= Config.PartnerHolyEqmData.data_const["open_lev_star_up"].val and table.indexof(nohideIds,featuresId) then
        if Config.PartnerHolyEqmData.data_step_info(data.base_id) then
            local cfg = Config.PartnerHolyEqmData.data_step_info(data.base_id)
            if  (cfg.isshow == 1 or (cfg.isshow == 0 and table.indexof(nohideIds2,cfg.id))) then
                if self:canUpStar(data,config)[1] == 1 and cfg.next_id ~= 0 then
                    local step_price = cfg.step_price
                    local num = 0
                    for key, value in pairs(step_price) do
                        local have_num = BackpackController:getInstance():getModel():getItemNumByBid(value[1])
                        if have_num >= value[2] then
                            num = num+1
                        end
                    end
                    if num >= #step_price then
                        can_up = true
                    end
                end
            end
        end
    end
    return can_up
end

--神装开启升星升阶的条件是否满足  评分 洗练次数
function HeroModel:canUpStar(data,item_config)
    local count = 0  --  洗练次数
    for k,v in pairs(data.extra) do
        if v.extra_k == 10 then
            count = v.extra_v
        end
    end
    local need_count = 0
    local cfg = Config.PartnerHolyEqmData.data_step_info(item_config.id)
    if cfg then
        need_count = cfg.reset_times or 0
    end
    local need_soure = 0
    local data_const = Config.PartnerHolyEqmData.data_const["shop_unlock_condition"]
    if cfg.next_id ~= 0 then
        local item_cfg = Config.ItemData.data_get_data(cfg.next_id)
        if item_cfg then
            local item_star = item_cfg.eqm_star + 1
            if data_const and data_const.val and data_const.val[item_star] and data_const.val[item_star][2] then
                need_soure = data_const.val[item_star][2] or 0
            end
            local score = HeavenController:getInstance():getModel():getAllScore() or 0 --评分
            if score < need_soure then
                return {2,need_soure}
            end
            if count < need_count then
                return {3,need_count}
            end
        end
    end
    return {1,0}
end
function HeroModel:getcan(pos,skill_id)
    local noUseVis = false
    local top_skill_cfg = Config.PartnerSkillData.data_partner_skill_const["common_skill_item"].val
    local bottom_skill_cfg = Config.PartnerSkillData.data_partner_skill_const["special_skill_item"].val
    if pos == 3 then
        -- if table.indexof(top_skill_cfg,skill_id) then
            -- noUseVis = false
        -- else
            noUseVis = true
        -- end
    else
        if not table.indexof(top_skill_cfg,skill_id) then
            noUseVis = false
        else
            noUseVis = true
        end
    end
    return noUseVis
end
--将数组中相同id的物品数量相加
function HeroModel:updateList(list)
    for key, value in pairs(list) do
        value.index = key
    end

    local data = {}
    for key, value in pairs(list) do
        local istrue = false
        for k, v in pairs(data) do
            if value.id == k then
                istrue = true
            end
        end
        if istrue then
            data[value.id].num = data[value.id].num + value.num
        else
            data[value.id] = value
        end
    end
    local list = {}
    for key, value in pairs(data) do
        table.insert(list,value)
    end
    table.sort(list, function(a,b)
        return a.index<b.index
    end)
    return list
end

------------升星神树开始-----------------
function HeroModel:updateUpStarCystalInfo(data)
    if not data then return end
    self.star_data = data
    self.con_list = data.con_list
    self.re_list = data.res_list
    self.share_level = data.share_level
    self:setCanResonateStar(data.flag == 1)
    self:updateStarTreeRed()
    -- for id, hero_vo in pairs(self.dic_star_lock_info) do
    --     if hero_vo.updateLock then
    --         local data = {{lock_type = HeroConst.LockType.eHeroStarLock, is_lock = 0}}
    --         hero_vo:updateLock(data)
    --     end
    -- end
    -- self.dic_star_lock_info = {}
    -- for i,v in ipairs(data.res_list) do
    --     if v.id ~= 0 then
    --         local hero_vo = self:getHeroById(v.id)
    --         if hero_vo and hero_vo.updateLock then
    --             self.dic_star_lock_info[v.id] = hero_vo
    --             local data = {{lock_type = HeroConst.LockType.eHeroStarLock, is_lock = 1}}
    --             hero_vo:updateLock(data)
    --         end
    --     end
    -- end
    -- self.star_five_hero_vo = {}
    -- for i,v in ipairs(data.con_list) do
    --     if v.id ~= 0 then
    --         local hero_vo = self:getHeroById(v.id)
    --         if hero_vo and hero_vo.updateLock then
    --             self.star_five_hero_vo[v.id] = hero_vo
    --             local data = {{lock_type = HeroConst.LockType.eHeroStarLock, is_lock = 1}}
    --             hero_vo:updateLock(data)
    --         end
    --     end
    -- end
end
--
function HeroModel:updateStarTreeRed()
    self.is_resonate_star_up_redpoint = self:getTreeUpStarRed()
    local data = {bid = HeroConst.RedPointType.eStarTreeUpStar, status = self.is_resonate_star_up_redpoint}
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.resonate, {data})
end
function HeroModel:getStarData()
    return self.star_data
end
function HeroModel:getUpStarCon()
    return self.con_list or nil
end
function HeroModel:getUpStarReList()
    return self.re_list or nil
end
function HeroModel:checkEnoughResUpStar(lv)
    if self.share_level then 
        return self.share_level>=lv
    end
    return false
end
function HeroModel:getUpStarShareLevel()
    return self.share_level or 0
end
function HeroModel:getUpStarConForId(id)
    for key, value in pairs(self.con_list) do
        if id == value.id then
            return true
        end    
    end
    return false
end
--获取神树应有星级（没有等级限制情况下原有星级）
function HeroModel:getRealStar(data)
    self.real_star = nil
    for key, value in pairs(data.con_list) do
        local hero_vo = self:getHeroById(value.id)
        if hero_vo.star then
            if not self.real_star then
                self.real_star = hero_vo.star
            else
                self.real_star = math.min(self.real_star,hero_vo.star)
            end
        end
    end    
    return self.real_star or 1
end
--获取神树应有星阶（没有等级限制情况下原有星阶）
function HeroModel:getRealStarStep(data)
    local real_star = self:getRealStar(data)
    self.real_star_step = nil
    for key, value in pairs(data.con_list) do
        local hero_vo = self:getHeroById(value.id)
        if hero_vo.star == real_star and hero_vo.star_step then
            if not self.real_star_step then
                self.real_star_step = hero_vo.star_step
            else
                self.real_star_step = math.min(self.real_star_step,hero_vo.star_step)
            end
        end
    end
    return self.real_star_step or 0
end

--是否完成升星神树的条件
function HeroModel:getMinStar(data)
    if not data then return self.resonate_star or 1 end
    self.resonate_star = nil
    for key, value in pairs(data.con_list or {}) do
        local hero_vo = self:getHeroById(value.id)
        if hero_vo.star then
            if not self.resonate_star then
                self.resonate_star = hero_vo.star
            else
                self.resonate_star = math.min(self.resonate_star,hero_vo.star)
            end
        end
    end
    if self.resonate_star and self.resonate_star >= 14 then
        if self.share_level > 0 then
            local cfg = Config.ResonateData.data_const["tree_star_limit"].val
            for k, v in pairs(cfg) do
                if self.share_level == v[3] then
                    self.resonate_star = math.min(self.resonate_star,v[1])
                end
            end
        else
            self.resonate_star = 14
        end
    end
    return self.resonate_star or 1
end


function HeroModel:getMinStarStep(data)
    local min_star = self:getMinStar(data)
    self.resonate_star_step = nil
    for key, value in pairs(data.con_list) do
        local hero_vo = self:getHeroById(value.id)
        if hero_vo.star == min_star and hero_vo.star_step then
            if not self.resonate_star_step then
                self.resonate_star_step = hero_vo.star_step
            else
                self.resonate_star_step = math.min(self.resonate_star_step,hero_vo.star_step)
            end
        end
    end
    if min_star >= 14 then
        if self.share_level > 0 then
            local cfg = Config.ResonateData.data_const["tree_star_limit"].val
            for k, v in pairs(cfg) do
                if self.share_level == v[3] then
                    if not self.resonate_star_step then
                        self.resonate_star_step = v[2]
                    else
                        self.resonate_star_step = math.min(self.resonate_star_step,v[2])
                    end
                end
            end
        else
            self.resonate_star_step = 0
        end
    end
    return self.resonate_star_step or 0
end
function HeroModel:setCanResonateStar(status)
    self.canResonateStar = status or false
end
--是否完成升星神树的条件
function HeroModel:isCanResonateStar()
    return self.canResonateStar or false
end
-- 升星神树是否开启
function HeroModel:checkStarIsOpen( not_tips )
    local role_vo = RoleController:getInstance():getRoleVo()
    local limit_lv_cfg = Config.ResonateData.data_const["star_open_lv"]
    if limit_lv_cfg and role_vo and limit_lv_cfg.val <= role_vo.lev then
        return true
    end
    if not not_tips and limit_lv_cfg then
        message(limit_lv_cfg.desc)
    end
    return false
end
function HeroModel:getTreeList()
    local hero_list = {}
    for key, value in pairs(self.hero_list) do
        if value and value.power then
            table.insert(hero_list, value)
        end
    end
    table.sort(hero_list,function(a,b) return a.power > b.power end)
    local temp_list = Config.ResonateData.data_const["consecrate_ele_limit"].val -- 可以放的属性列表
    local star_num = Config.ResonateData.data_const["star_open_condition"].val[1][1] -- 可以放的最低星级
    local star = Config.ResonateData.data_const["star_open_condition"].val[1][2] -- 可以放的最低星级
    local list = {}
    for key, value in pairs(hero_list) do
        if value.isResonateHero and value:isResonateHero() then
        else
            if value.star >= star and table.indexof(temp_list,value.camp_type) and tableLen(list) < star_num then
                local iscan = true
                for k, v in pairs(list) do
                    if v.bid == value.bid then
                        iscan = false
                    end
                end
                if iscan then
                    local data = {
                        id = value.partner_id ,
                        bid = value.bid,
                        pos = tableLen(list) + 1,
                    }
                    table.insert(list, data)
                end
            end
        end
        if tableLen(list) > star_num then
            return list
        end
    end
    return list
end
--查看功能是否屏蔽
function HeroModel:isHideLevelUp()
	local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("features_shield")
	local featuresId = MainuiConst.FeaturesShield.resonate_uplv
    if not table.indexof(nohideIds,featuresId) then
		return true
	end
	return false
end
--升星神树升阶红点
function HeroModel:getTreeUpStarRed()
    local tree_star = self:getMinStar(self:getStarData())
    if tree_star < 14 then return false end
    local real_star =  self:getRealStar(self:getStarData())
    local tree_star_step = self:getMinStarStep(self:getStarData())
    local real_star_step =  self:getRealStarStep(self:getStarData())
    local share_lv =  self:getUpStarShareLevel()
    local cfg_star = 1 -- 当前共享等级 对应星级
    local cfg_star_step = 0 -- 当前共享等级 对应星阶
    local status = false
    if self:isHideLevelUp() then return false end
    if share_lv > 0 then
        local cfg = Config.ResonateData.data_const["tree_star_limit"].val
        for k, v in pairs(cfg) do
            if share_lv == v[3] then
                cfg_star = v[1]
                cfg_star_step = v[2]
            end
        end
    end
    if self:isHideLevelUp() == false then
        if tree_star < real_star then
            if cfg_star < real_star then
                status = true
            elseif cfg_star == real_star then
                if cfg_star_step < real_star_step then
                    status = true
                else
                    status = false
                end
            else
                status = false
            end
        elseif tree_star == real_star then
            if tree_star_step < real_star_step then
                if cfg_star_step < real_star_step then
                    status = true
                else
                    status = false
                end
            else
                status = false
            end
        else
            status = false
        end
    else
        status = false
    end
    if not status then return false end
    local lev = self:getUpStarShareLevel()
    local cfg = Config.ResonateData.data_share_lev_up_cost
    if cfg[lev] and cfg[lev + 1] then
        local item_cost = cfg[lev].cost_item
        for k, v in pairs(item_cost) do
            local have_num = BackpackController:getInstance():getModel():getItemNumByBid(v[1])
            if have_num < v[2] then
                return false
            end
        end
        local hero_cost = cfg[lev].cost_p
        if not self:checkSingleStarFuseRedPointByStarConfig({lev_up_expend2={},lev_up_expend3=hero_cost}) then
            return false        
        end
        return true
    end
    return false
end
----------------Sp升星神树----------------------------
function HeroModel:updateUpSpStarCystalInfo(data)
    self.sp_res_list = data.res_list
    self.sp_gold_count = data.gold_count
    self.sp_item_count = data.item_count
end
function HeroModel:getSpHeroTreeShield()
    local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("features_shield")
    local featuresId = MainuiConst.FeaturesShield.SpUpStarTree
    if nohideIds and next(nohideIds) and table.indexof(nohideIds,featuresId) then
        return true
    end
    return false
end
------------升星神树结束-----------------

--------------------------------羁绊技-----------------------------
function HeroModel:setBondSkillList(data)
    self.bond_list = {}
    self.bond_list_as = {}
    for key, value in pairs(data.bond_skills) do
        self:setOneBondSkillList(value)
        self.bond_list_as[value.bsid] = value
        for i = value.b_lev, 1,-1 do
            if self:getBondIsAct(value.bsid,i) then
                local list = deepCopy(value)
                list.b_lev = i
                self.bond_list[value.bsid] = list
                break
            end
        end
    end
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Bond_Skill_Open_Event)
end
function HeroModel:setOneBondSkillList(data)
    if data.b_lev == 0 and data.bsid == 0 then
        local id = data.partner_id or 0
        self.hero_list[id]:updateHeroVo(data)
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Bond_Skill_Event,data)
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Bond_Update_Event, self.hero_list[id])
    end
    if not self.bond_list_as then
        self.bond_list_as = {}
    end
    self.bond_list_as[data.bsid] = data
    for i = data.b_lev, 1,-1 do
        if self:getBondIsAct(data.bsid,i) then
            local list = deepCopy(data)
            list.b_lev = i
            self.bond_list[data.bsid] = list
            local id = list.partner_id or 0
            if self.hero_list[id] then 
                local hero_vo =  self.hero_list[id]
                if hero_vo.power < list.power then 
                    GlobalMessageMgr:getInstance():showPowerMove( list.power-hero_vo.power ,nil,hero_vo.power )
                end
                self.hero_list[id]:updateHeroVo(list)
                GlobalEvent:getInstance():Fire(HeroEvent.Hero_Bond_Update_Event, hero_vo)
            else
                if self.hero_list[list.b_partner_id] then
                    self.hero_list[list.b_partner_id]:updateBondData(list)
                end
            end
            GlobalEvent:getInstance():Fire(HeroEvent.Hero_Bond_Skill_Event,list)
            return
        end
    end
end
function HeroModel:getAsBondDataForId(id)
    return self.bond_list_as and self.bond_list_as[id] or nil
end
function HeroModel:getBondDataForId(id)
    return self.bond_list[id] or nil
end
--通过bid获取等级最高的英雄信息 在神树上的按照原本星级比较
function HeroModel:getTopLevHeroInfoByBidNoResona(bid)
    if not bid then return end
    local list = deepCopy(self.hero_bid_list[bid])
    local data = {}
    if list then
        for key, value in pairs(list) do
            if value.isResonateHero and not value:isResonateHero() then
                table.insert(data,value)
            else
                local list1 = deepCopy(value)
                list1.star = list1.resonate_star
                table.insert(data,list1)
            end
        end
        table_sort(data, SortTools.tableUpperSorter({"star","lev"}))
        return data[1]
    end
    return nil
end
function HeroModel:getBondIsAct(id,lev)
    local config = deepCopy(Config.PartnerBondSkillData.data_base_info[id])
    if config and config[lev] then
        local cfg = config[lev]
        local limit = cfg.limit
        for key, value in pairs(limit) do
            if value[1] == "evt_partner_star_up" then --英雄星级
                local hero_vo = self:getTopLevHeroInfoByBidNoResona(cfg.partner_id)
                if not hero_vo then
                    return false
                end
                if hero_vo.star < value[2] or (hero_vo:isResonateHero() and hero_vo.resonate_star < value[2]) then
                    return false
                end
            elseif value[1] == "evt_horcruxes_lev_up" then -- 魂器等级
                local list = self.hero_bid_list[cfg.partner_id]
                local status = false
                if not list then
                    return false
                end
                for k, v in pairs(list) do
                    if v.h_lev >= value[2] then
                        status = true
                    end
                end
                if not status then
                    return false
                end
            end
        end
        return true
    end
    return false
end
function HeroModel:getBondSkillList()
    local list = {}
    for i = 1, 4 do
        list[i] = {}
    end
    local cfg = deepCopy(Config.PartnerBondSkillData.data_base_info)
    for key, value in pairs(cfg) do
        local data = self:getBondDataForId(key)
        local list1 = {}
        if data then
            local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("partner_bond")
            local featuresId = value[data.b_lev].id
            if (value[data.b_lev].is_show == 0 and table.indexof(nohideIds,featuresId)) or value[data.b_lev].is_show == 1 then
                list1 = value[data.b_lev]
                list1.data = data
            end
        else
            local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("partner_bond")
            local featuresId = value[1].id
            if (value[1].is_show == 0 and table.indexof(nohideIds,featuresId)) or value[1].is_show == 1 then
                list1 = value[1]
            end
        end
        if next(list1) then
            table.insert(list[value[1].career_type-1],key,list1)
        end
    end
    for key, value in pairs(list) do
        table.sort(value, function(a,b) return a.sort < b.sort end)
    end
    return list
end
--羁绊技能否被激活
function HeroModel:getBondSkillAct(id)
    local lev = 1
    if not self:getBondDataForId(id) then
        lev = 1
    else
        local data = self:getBondDataForId(id)
        if data then
            lev = data.b_lev + 1
        end
    end
    local cfg = deepCopy(Config.PartnerBondSkillData.data_base_info[id])
    if cfg[lev] then
        local limit = cfg[lev].limit
        for key, value in pairs(limit) do
            if value[1] == "evt_partner_star_up" then --英雄星级
                local hero_vo = self:getTopLevHeroInfoByBidNoResona(cfg[1].partner_id)
                if not hero_vo then
                    return false
                end
                if hero_vo.star < value[2] or hero_vo:isResonateHero() then
                    return false
                end
            elseif value[1] == "evt_horcruxes_lev_up" then -- 魂器等级
                local list = self.hero_bid_list[cfg[1].partner_id]
                local status = false
                if not list then
                    return false
                end
                for k, v in pairs(list) do
                    if v.h_lev >= value[2] then
                        status = true
                    end
                end
                if not status then
                    return false
                end
            end
        end
        local cost_list = cfg[lev].lev_up_cost
        for key, value in pairs(cost_list) do
            local num = BackpackController:getInstance():getModel():getItemNumByBid(value[1])
            if num < value[2] then
                return false
            end
        end
        if not self:checkSingleStarFuseRedPointByStarConfig(cfg[lev]) then
            return false
        end
    else
        return false
    end
    return true
end

--计算升星红点红点根据升星表
--@is_ignore_master_card 是否忽视主卡(6星以上的升星逻辑)
--@partner_id 忽视主卡的 唯一id
function HeroModel:checkSingleStarFuseRedPointByStarConfig(star_config)
    if not star_config then return false end
    --特定条件数据 结构 dic_the_conditions[bid][星级] = 数量
    local dic_the_conditions = {}
    --随机条件 dic_random_conditions[阵营][星级] = 数量
    local dic_random_conditions = {}
    --标志已用
    local dic_hero_id = {}
    local need_count = 0
    if next(star_config.lev_up_expend2) then
        for i,expend in ipairs(star_config.lev_up_expend2) do
            --指定的 {10402,4,1} : 10402: 表示bid, 4: 表示星级 1:表示数量
            local bid, star, count = expend[1], expend[2], expend[3]
            if dic_the_conditions[bid] == nil then
                dic_the_conditions[bid] = {}
            end
            if dic_the_conditions[bid][star] == nil then
                dic_the_conditions[bid][star] = count
            else
                dic_the_conditions[bid][star] = dic_the_conditions[bid][star] + count
            end
            need_count = need_count + count
        end
    end
    --随机的 {1,4,2} : 1 表示阵营  4: 表示星级 2表示数量
    for i,expend in ipairs(star_config.lev_up_expend3) do
        local camp, star, count = expend[1], expend[2], expend[3]
        if dic_random_conditions[camp] == nil then
            dic_random_conditions[camp] = {}
        end
        if dic_random_conditions[camp][star] == nil then
            dic_random_conditions[camp][star] = count
        else
            dic_random_conditions[camp][star] = dic_random_conditions[camp][star] + count
        end
        need_count = need_count + count
    end
    --获取列表
    local total_count = self:getHeroListByMatchInfo(dic_the_conditions, dic_random_conditions, dic_hero_id)
    return total_count >= need_count, need_count, total_count
end

function HeroModel:getBondSkillIdle(index)
    local list = self:getBondSkillList()
    for key, value in pairs(list[index]) do
        if value.data and value.data.b_partner_id == 0 then
            return true
        end
    end
    -- for key, value in pairs(self.bond_list[index]) do
    --     local lev = value.lev or value.b_lev or 0
    --     local id = value.b_partner_id or -1
    --     if lev > 0 and id == 0 then
    --         return true
    --     end
    -- end
    return false
end
--羁绊技是否有红点
function HeroModel:getBondSkillRed(id)
    if self:getBondSkillAct(id) then
        return 1 --可激活
    end
end
--获取品质
--@item_id 道具id
--@ attr_key  属性名字 
--@ value 属性值
function HeroModel:getBondQualityByItemIdAttrKey(item_id, lev, attr_key, value)
    local quality = 0
    local bond_config = deepCopy(Config.PartnerBondSkillData.data_base_info[item_id])
    if bond_config then
        if bond_config[lev] then
            local key = getNorKey(bond_config[lev].group_id, attr_key)
            local config = deepCopy(Config.PartnerBondSkillData.data_attr_color_rule[key])
            if value > 0 and config and config.color_list[1] then
                local list = config.color_list[1] -- {0-12}
                for i,v in ipairs(list) do
                    if list[i+1] then
                        if value >= list[i] and value < list[i+1] then
                            quality = i - 1
                        end
                    else
                        if value >= list[i] then
                           quality = i - 1
                        end
                    end
                end
            end
        end
    end
    return quality
end
--获取某个属性最大值
function HeroModel:getBondMaxAttrByItemIdAttrKey(item_id, lev, attr_key)
    local max_count = 1
    local bond_config = deepCopy(Config.PartnerBondSkillData.data_base_info[item_id])
    if bond_config then
        if bond_config[lev] then
            local config = deepCopy(Config.PartnerBondSkillData.data_attr_max_info[bond_config[lev].group_id])
            if config then
                for i,v in ipairs(config.max_attr) do
                    if v[1] and v[1] == attr_key then
                        max_count = v[2] or 1
                        break
                    end
                end
            end
        end
    end

    return max_count
end

--获取每个等级拥有的数量
function HeroModel:getBondNumForLv()
    local max_lev = 0
    local cfg = deepCopy(Config.PartnerBondSkillData.data_base_info)
    for key, value in pairs(cfg) do
        max_lev = math.max(max_lev,tableLen(value))
    end
    local list = {}
    for i = 1, max_lev do
        list[i] = 0
    end
    for key, value in pairs(self.bond_list) do
        local lev = value.b_lev
        list[lev] = list[lev] + 1
    end
    return list
end
function HeroModel:setIsFirst(num)
    self.isBondFirst = num
end
function HeroModel:getIsFirst()
    if MAKELIFEBETTER_NEW then return 1 end
    local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("features_shield")
    local featuresId = MainuiConst.FeaturesShield.BondSkill
    if not table.indexof(nohideIds,featuresId) then return 1 end
	if self.isBondFirst then
		return self.isBondFirst
	end
	return 0
end
function HeroModel:setFormBondTakeEffect(num)
    self.form_bond = num
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Form_Bond_Open_Event)
end
function HeroModel:getFormBondTakeEffect()
    if MAKELIFEBETTER_NEW then return 1 end
    local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("features_shield")
    local featuresId = MainuiConst.FeaturesShield.BondSkill
    if not table.indexof(nohideIds,featuresId) then return 1 end
	if self.form_bond then
		return self.form_bond
	end
    return 0
end

function HeroModel:setAwakenSkillList(data)
    for key, value in pairs(data.partner_ids) do
        self.awaken_skills[value.partner_id] = value.awaken_skills
        if self.hero_list[value.partner_id] then
            self.hero_list[value.partner_id]:updateAwakenSkill(value.awaken_skills)
        end
    end   
end

function HeroModel:getAwakenSkillId(index)
    return self.awaken_skills[index] or {}
end

function HeroModel:updataAwakenSkillId(partner_id,awaken_skill)
    self.awaken_skills[partner_id] = awaken_skill
    if self.hero_list[partner_id] then
        self.hero_list[partner_id]:updateAwakenSkill(awaken_skill)
    end
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Awaken_Update_Event, partner_id)
end
function HeroModel:setBossFormPoint()
    local list = self:getHeroList()
    for k,v in pairs(list) do
        v.point_id = nil
        v.is_ui_select = false
    end
end

--------------------英雄转换----------------------------
function HeroModel:ConvertSta(hero_vo)
    local cfg = deepCopy(Config.PartnerData.data_partner_transform)
    if cfg then
        for key, value in pairs(cfg) do
            if (value.bid == hero_vo.bid or value.transform_bid_list[1] == hero_vo.bid) and value.turn_type == 1 then
                local need_star = Config.PartnerData.data_partner_const["commutation_open_starlev"].val
                if need_star > hero_vo.star then return false end
                return true
            end        
        end
    end
    return false
end

function HeroModel:isSameForId(bid1,bid2)
    local cfg = deepCopy(Config.PartnerData.data_partner_transform)
    if cfg then
        for key, value in pairs(cfg) do
            if value.turn_type == 1 then
                if (bid1 == value.transform_bid_list[1] and bid2 == value.bid) or (bid2 == value.transform_bid_list[1] and bid1 == value.bid) then
                    return true
                end
            end
        end
    end
    return false
end

function HeroModel:isConvert(hero_vo)
    local cfg = deepCopy(Config.PartnerData.data_partner_transform)
    if cfg then
        for key, value in pairs(cfg) do
            if value.turn_type == 1 then
                if value.bid == hero_vo.bid or value.transform_bid_list[1] == hero_vo.bid then
                    return true
                end        
            end
        end
    end
    return false
end
function HeroModel:isTransformConvert(hero_vo)
    local cfg = deepCopy(Config.PartnerData.data_partner_transform)
    if cfg then
        for key, value in pairs(cfg) do
            if value.turn_type == 1 and value.transform_bid_list[1] == hero_vo.bid then
                return true
            end
        end
    end
    return false
end
--5系转换
function HeroModel:isNewConvertSta(hero_vo)
    local cfg = deepCopy(Config.PartnerData.data_partner_transform)
    if cfg then
        for key, value in pairs(cfg) do
            if value.turn_type == 2 then
                if value.bid == hero_vo.bid or table.indexof(value.transform_bid_list,hero_vo.bid) then
                    return true
                end        
            end
        end
    end
    return false
end
function HeroModel:NewConvertSta(hero_vo)
    local cfg = deepCopy(Config.PartnerData.data_partner_transform)
    if cfg then
        for key, value in pairs(cfg) do
            if value.turn_type == 2 then
                if value.bid == hero_vo.bid or table.indexof(value.transform_bid_list,hero_vo.bid) then
                    local need_star = Config.PartnerData.data_partner_const["commutation_open_starlev_5"].val
                    if need_star > hero_vo.star then return false end
                    return true
                end        
            end
        end
    end
    return false
end
--5系转换本体bid
function HeroModel:getNewConvertStaBid(bid)
    local cfg = Config.PartnerData.data_partner_transform
    if cfg then
        for k, v in pairs(cfg) do
            if v.turn_type == 2 then
                if v.bid == bid then
                    return bid
                else
                    if table.indexof(v.transform_bid_list,bid) then
                        return v.bid
                    end
                end
            end
        end
    end
    return nil
end
--阴阳转换本体
function HeroModel:getConvertStaBid(bid)
    local cfg = Config.PartnerData.data_partner_transform
    if cfg then
        for k, v in pairs(cfg) do
            if v.turn_type == 1 then
                if v.bid == bid then
                    return bid
                else
                    if table.indexof(v.transform_bid_list,bid) then
                        return v.bid
                    end
                end
            end
        end
    end
    return nil
end
function HeroModel:isNewConvertSameForId(bid1,bid2)
    local id_1 = self:getNewConvertStaBid(bid1)
    local id_2 = self:getNewConvertStaBid(bid2)
    if id_1 and id_2 and id_1 == id_2 then
        return true
    end
    return false
end
function HeroModel:isNewConvert(hero_vo)
    local cfg = deepCopy(Config.PartnerData.data_partner_transform)
    if cfg then
        for key, value in pairs(cfg) do
            if value.turn_type == 2 then
                if value.bid == hero_vo.bid or table.indexof(value.transform_bid_list,hero_vo.bid) then
                    return true
                end
            end
        end
    end
    return false
end
function HeroModel:setNewConvertFirstRed(type,status)
    if type > 10000 and type <= 99999 then
        self.new_convert_red_list[type - 10000] = status
    end
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_New_Convert_Red_Event)
end
function HeroModel:getNewConvertFirstRed(hero_vo)
    if self.new_convert_red_list[hero_vo.partner_id] then
        return true
    end
    return false
end
--------------------神装新词条激活属性----------------------------
function HeroModel:getHolyComList(id,data)
    local cfg = Config.PartnerHolyEqmData.data_base_info(id)
    local color_rand = cfg and cfg.color_rand or 0
    local color_cfg = Config.PartnerHolyEqmData.data_color_info[color_rand]
    local color_list = {}
    if color_cfg then
        for k, v in pairs(data) do
            if v.pos < 100 then
                if color_list[v.color] then
                    color_list[v.color] = color_list[v.color] + 1
                else
                    color_list[v.color] = 1
                end
            end
        end
    end
    return color_list
end
function HeroModel:getHolyCombinationList(id,data)
    local cfg = Config.PartnerHolyEqmData.data_base_info(id)
    local color_rand = cfg and cfg.color_rand or 0
    local color_cfg = Config.PartnerHolyEqmData.data_color_info[color_rand]
    local color_list = self:getHolyComList(id,data)
    local list = {}
    if color_cfg then
        for k, v in pairs(color_list) do
            local attr_list = color_cfg[k].attr_list
            table.sort(attr_list,function(a,b) return a[1] < b[1] end)
            for key, value in ipairs(attr_list) do
                if v >= value[1] then
                    list[k] = value[1]
                end
            end
        end
    end
    return list
end
-----------------------禁术-------------------------------
--功能屏蔽
function HeroModel:getProsIsShield()
    local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("features_shield")
	local featuresId = MainuiConst.FeaturesShield.Proscription
    if table.indexof(nohideIds,featuresId) then
		return true
	end
    return false
end
--单个屏蔽
function HeroModel:getOneProsIsShield(data)
    local hero_cfg = Config.PartnerData.data_partner_base[data.bid]
    if not hero_cfg then return false end
    if hero_cfg.proscription_id == 0 then return false end
    if hero_cfg then
        if hero_cfg.proscription_show == 1 then
        else
            local hero_nohideIds = RoleController:getInstance():getModel():getSeverShowIds("proscription_show")
            if not table.indexof(hero_nohideIds,hero_cfg.bid) then
                return false
            end
        end
    end
    return true
end
--单个禁术第4个技能的屏蔽
function HeroModel:getOneProsSkillIsShield(data)
    local hero_cfg = Config.PartnerData.data_partner_base[data.bid]
    if not hero_cfg then return false end
    if hero_cfg.proscription_id == 0 then return false end
    if hero_cfg then
        if hero_cfg.proscription_skil == 1 then
        else
            local hero_nohideIds = RoleController:getInstance():getModel():getSeverShowIds("proscription_skill")
            if not table.indexof(hero_nohideIds,hero_cfg.bid) then
                return false
            end
        end
    end
    return true
end

function HeroModel:getProsIsOpen(data)
    local id = Config.PartnerData.data_partner_base[data.bid].proscription_id
    local list = Config.PartnerProscriptionData.data_get_open_lv[id]
    return list and data.h_lev and data.h_lev >= list.lv and data.star >= list.star and self:getProsIsShield() and self:getOneProsIsShield(data)
end
function HeroModel:getProsRedForType(hero_vo,type)
    if not self:getProsIsShield() or type < 1 or type > 4 then return false end
    local cfg = {}
    if hero_vo and hero_vo.bid and Config.PartnerData.data_partner_base[hero_vo.bid] then
        local id = Config.PartnerData.data_partner_base[hero_vo.bid].proscription_id
        local limit_lev = Config.PartnerProscriptionData.data_get_open_lv[id]
        if limit_lev then
            if not hero_vo.h_lev or not hero_vo.star or hero_vo.h_lev < limit_lev.lv or hero_vo.star < limit_lev.star then return false end
        end
        if id and id ~= 0 then
            local config = Config.PartnerProscriptionData.data_lv_info[id]
            if config then
                cfg = config
            else
                return false
            end
        else
            return false
        end
        local lv_order = Config.PartnerProscriptionData.data_constant["lv_order"].val

        local data = {}
        if hero_vo and hero_vo.proscription and next(hero_vo.proscription) then
            for k, v in pairs(hero_vo.proscription) do
                if v.p_type == type then
                    data = v
                end
            end
        end

        if next(data) then
            if data.p_lev >= tableLen(cfg[data.p_type]) then return false end
            local config = cfg[data.p_type][data.p_lev + 1]
            for k, v in pairs(config.expend1) do
                local num = 0
                local list = self.hero_bid_list[v[1]] or {}
                table.sort(list,function(a,b) return a.star < b.star end)
                for key, hero_vo in pairs(list) do
                    if hero_vo:isUpStarTreeHero() and hero_vo.resonate_star == v[2] or hero_vo.star == v[2] then
                        num = num + 1
                        if num >= v[3] then
                            break
                        end
                    end
                end
                if num < v[3] then return false end
            end
            if hero_vo.h_lev < lv_order[tableLen(hero_vo.proscription)] then return false end
            for k, v in pairs(config.cost_num) do
                local id = v[1]
                local need_num = v[2]
                local have_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(id)
                if have_num < need_num then return false end
            end
            return true
        else
            local _type = 0
            if type == 4 then
                if tableLen(hero_vo.proscription) < 3 then
                    return false
                end
            end
            _type = type
            local config = cfg[_type][1]
            for k, v in pairs(config.expend1) do
                local num = 0
                local list = self.hero_bid_list[v[1]] or {}
                table.sort(list,function(a,b) return a.star < b.star end)
                for k, hero_vo in pairs(list) do
                    if hero_vo:isUpStarTreeHero() and hero_vo.resonate_star == v[2] or hero_vo.star == v[2] then
                        num = num + 1
                        if num >= v[3] then
                            break
                        end
                    end
                end
                if num < v[3] then return false end
            end
            if hero_vo.h_lev < lv_order[tableLen(hero_vo.proscription) + 1] then return false end
            for k, v in pairs(config.cost_num) do
                local id = v[1]
                local need_num = v[2]
                local have_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(id)
                if have_num < need_num then return false end
            end
            return true
        end
    end

    return false
end
--某个忍者的禁术功能是否达到显示条件
function HeroModel:getProsIsVis(hero_vo)
    if not Config.PartnerData then return false end
    local role_vo = RoleController:getInstance():getRoleVo()
    local h_cfg = Config.PartnerData.data_partner_base_fun(hero_vo.bid)
    local limit_cfg = Config.PartnerSoulData.data_const["entrance_lv"]
    local horcruxes = h_cfg.horcruxes
    local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("partner_soul_data")
    local status = false
    if h_cfg.horcruxes_show == 0 and not table.indexof(nohideIds,horcruxes) then
        return false
    else
        if horcruxes and horcruxes ~= 0 and limit_cfg and limit_cfg.val <= role_vo.lev then
            status = true
        else
            return false
        end
    end
    if self:getOneProsIsShield(hero_vo) and status then
        return true
    end
    return false
end
---------------潜能释放start--------------------
--功能屏蔽
function HeroModel:getSpecialHeroShield()
    local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("features_shield")
    local featuresId = MainuiConst.FeaturesShield.PartnerSpecial
    if nohideIds and next(nohideIds) and table.indexof(nohideIds,featuresId) then
        return true
    end
    return false
end
--功能屏蔽SP光环
function HeroModel:getSpecialHeroHuanShield()
    local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("features_shield")
    local featuresId = MainuiConst.FeaturesShield.SpSkill
    local cfg_lev = Config.PartnerSpecialData.data_const["guang_open"].desc
    local role_vo = RoleController:getInstance():getRoleVo()
    if nohideIds and next(nohideIds) and table.indexof(nohideIds,featuresId) and role_vo.lev >= tonumber(cfg_lev) then
        return true
    end
    return false
end

--页签显示条件
function HeroModel:isopenSpecialTab(id)
    if not self:getSpecialHeroShield() then return false end
    local hero_vo = self:getHeroById(id)
    if not hero_vo then return false end
    local hero_cfg = Config.PartnerData.data_partner_base[hero_vo.bid]
    if not hero_cfg then return false end
    if hero_cfg.sp_skills_show == 1 then
    else
        local hero_nohideIds = RoleController:getInstance():getModel():getSeverShowIds("sp_skills_show")
        if not table.indexof(hero_nohideIds,hero_cfg.bid) then
            return false
        end
    end
    return true
end
--是否满足开放条件
function HeroModel:getSpecialHeroOpne(id)
    if not self:isopenSpecialTab(id) then return false end
    local hero_vo = self:getHeroById(id)
    local const_cfg = Config.PartnerSpecialData.data_const
    if hero_vo.star < const_cfg.potential_open.val then return false end
    return true
end

function HeroModel:getSpSkillList(data)
    if not data or not next(data) then return end
    for key, value in pairs(data) do
        if value.skills then
            for k, v in pairs(value.skills) do
                local cfg = Config.SkillData.data_get_skill(v.skill_bid)
                local bid = value.bid
                local id = self:getNewConvertStaBid(bid)
                if id then
                    bid = id
                end
                local hero_cfg = Config.SkillExtensionData.data_get_sp_halo_skill_group[bid]
                if cfg and hero_cfg and cfg.group == hero_cfg.sp_halo_skill_group then
                    return true
                end
            end
        end
    end
    return false
end
function HeroModel:getSpSkillForNum(data)
    local num = 0
    if data and next(data) then
        for key, value in pairs(data) do
            if value.skills then
                for k, v in pairs(value.skills) do
                    local cfg = Config.SkillData.data_get_skill(v.skill_bid)
                    local hero_cfg = Config.SkillExtensionData.data_get_sp_halo_skill_group[value.bid]
                    if cfg and hero_cfg and cfg.group == hero_cfg.sp_halo_skill_group then
                        num = num + 1
                    end
                end
            end
        end
    end
    return num
end
--获得是否满超过升星神树星级 sp
function HeroModel:getTreeCanUp(hero_vo)
    if hero_vo and hero_vo.star and hero_vo.star_step and hero_vo.resonate_star then
        local data = self:getStarData()
        local star = self:getMinStar(data)
        local star_step = self:getMinStarStep(data)
        if hero_vo.star > star then
            return false
        elseif hero_vo.star == star then
            if hero_vo.star_step < star_step then
                return true
            end
        elseif hero_vo.star < star then
            return true
        end
    end
    return false
end
function HeroModel:isSpHero(hero_vo)
    local cfg = Config.PartnerData.data_partner_sp_desc
    if cfg[hero_vo.bid] then
        return true
    end
    return false
end
---------------潜能释放end--------------------
---------------金色装备-----------------------
function HeroModel:checkGoldEqmCanUplv(vo)
    local equip_bid = vo.id
    local break_level = vo.refine_level
    local now_lv = vo.enchant_level
    local cfg = Config.PartnerGoldeqmData.data_get_eqm_refine(getNorKey(equip_bid, break_level)) 
    local max_level = cfg["enchant_max_lev"]
    if now_lv == max_level then ---需要进行突破
        local next_key = getNorKey(equip_bid, (now_lv + 1))
        local lv_cfg = Config.PartnerGoldeqmData.data_get_eqm_enchant
        if lv_cfg(next_key) then -- 未满级
            local cost = cfg.cost
            local is_enough = true
            for k, v in pairs(cost) do
                local item_id = v[1]
                local own_num = BackpackController:getInstance():getModel():getItemNumByBid(item_id)
                if v[2] > own_num then
                    is_enough = false
                    break
                end
            end
            return is_enough
        end 
    else --可以升级
        local next_key = getNorKey(equip_bid, (now_lv + 1))
        local lv_cfg = Config.PartnerGoldeqmData.data_get_eqm_enchant
        if lv_cfg(next_key) then -- 未满级
            local cost_cfg = Config.PartnerGoldeqmData.data_get_eqm_star_exp
            for k, v in pairs(cost_cfg) do
                local item_id = v.id
                local own_num = BackpackController:getInstance():getModel():getItemNumByBid(item_id)
                if 0 < own_num then
                    return true
                end
            end
        end
    end
    return false
end

function HeroModel:checkGoldEqmCanUpStar(vo)
    local star = vo.star_level
    local equip_bid = vo.id
    local cfg = Config.PartnerGoldeqmData.data_get_eqm_star 
    local now_key = getNorKey(equip_bid, star)
    local cost = cfg(now_key).cost
    if cost and next(cost) then
        local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost[1][1])
        if cost[1][2] <= own_num then
            return true
        end
    end
    return false
end

function HeroModel:checkGoldEqmCanSoul(vo)
    local equip_bid = vo.id
    local soul_lv = vo.soul_level
    local star_level = vo.star_level
    local max_soul_level = 1

    local can_soul_lv = Config.PartnerGoldeqmData.data_get_constant.forge_limit.val or 2
    if star_level < can_soul_lv then --未解锁
       return false
    end
    local cfg = Config.PartnerGoldeqmData.data_get_eqm_soul 
    for i = 0, 10, 1 do
        local key = getNorKey(equip_bid,i)
        local soul_cfg_item = cfg(key)
        if soul_cfg_item then
            if soul_cfg_item.star ~= 0 and soul_cfg_item.star == star_level and soul_cfg_item.lev > (max_soul_level) then --
                max_soul_level = soul_cfg_item.lev
            end
        else
            break
        end
    end
    max_soul_level = max_soul_level + 1
    if soul_lv == max_soul_level then--到达等级上限
        return false
    else
        if soul_lv == 0 then --需要激活
            local cfg = Config.PartnerGoldeqmData.data_get_eqm_soul 
            local now_key = getNorKey(equip_bid, 0)
            local data = cfg(now_key)
            local unlock_item = data.unlock_item
            local own_num = BackpackController:getInstance():getModel():getItemNumByBid(unlock_item[1][1],BackPackConst.Bag_Code.EQUIPS)
            if unlock_item[1][2] <= own_num then
                return true
            else
                return false
            end
        else
            local soul_up_cfg = Config.PartnerGoldeqmData.data_get_eqm_soul_exp
            local equip_type = Config.ItemData.data_get_data(equip_bid).type
            for k, v in pairs(soul_up_cfg) do
                local item_cfg = Config.ItemData.data_get_data(k)
                if item_cfg.type == equip_type or (item_cfg.type ~= BackPackConst.item_type.WEAPON and item_cfg.type ~= BackPackConst.item_type.SHOE and item_cfg.type ~= BackPackConst.item_type.CLOTHES and item_cfg.type ~= BackPackConst.item_type.HAT) then
                    local own_num =  BackpackController:getInstance():getModel():getItemNumByBid(k)
                    if own_num == 0 then
                        own_num = BackpackController:getInstance():getModel():getEquipItemNumByBid(k)
                    end
                    if own_num > 0 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function HeroModel:setHeroTreeLoginRed(bl)
    self.herotree_login_red = bl

    local data = {bid = HeroConst.RedPointType.eHeroTreeRed, status = self.herotree_login_red}
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.resonate, {data})
end
--忍者筛选刻印首次红点
function HeroModel:sendKeyinFirstRed()
    local list = {}
    for k, v in pairs(self.bid_keyin_first_list) do
        table.insert(list,v+100000)
    end
    ActionController:getInstance():sender16808(list)
end

function HeroModel:setKeyinFirstRed(type,status)
    if type > 100000 and  type <= 999999 then
        if not self.keyin_first_red then
            self.keyin_first_red = {}
        end
        self.keyin_first_red[type] = status
        if tableLen(self.keyin_first_red) >= tableLen(self.bid_keyin_first_list) then
            MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.partner,{bid=HeroConst.RedPointType.eKeyinFirst, status = self:getKeyinFirstRed()})
            GlobalEvent:getInstance():Fire(HeroEvent.Hero_Keyin_First_Red_Event)
        end
    end
end
function HeroModel:getKeyinFirstRed()
    if self.keyin_first_red and next(self.keyin_first_red) then
        for k, v in pairs(self.keyin_first_red) do
            if v then
                return true
            end
        end
    end
    return false
end
function HeroModel:getKeyinFirstRedList()
    if self.keyin_first_red and next(self.keyin_first_red) then
        return self.keyin_first_red
    end
    return {}
end

--获取忍者是否满足条件 --评分 星级 数量
function HeroModel:getHeroReachCon(list)
    local need_score = list[1]
    local need_star = list[2]
    local need_num = list[3]
    local have_num = 0
    local list = self:getHeroList()
    for k, v in pairs(list) do
        if v.star >= need_star then
            local score = self:heroBidScore(v.bid)
            if score >= need_score then
                have_num = have_num + 1
                if have_num >= need_num then
                    return {true,have_num,need_num}
                end
            end 
        end
    end
    return {false,have_num,need_num}
end

function HeroModel:checkIsEnoughStarNum(star,need_num)
    local num = 0
    for k, v in pairs(self.hero_list) do
        local _star = v.star 
        if _star >= star then
            num = num + 1
        end
        if num >= need_num then
            return true
        end
    end
    return false
end
------------------------------ur 新品质--------------------------------------
function HeroModel:setHeroEnableData(data)
    if not self.hero_enable_data then
        self.hero_enable_data = {}
    end
    self.hero_enable_data[data.pid] = data.use_pid
    if not self.use_hero_enable_data then
        self.use_hero_enable_data = {}
    end
    self.use_hero_enable_data[data.use_pid] = data.pid
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_UR_Score_Enable_Event, data)
end
function HeroModel:getHeroEnable(pid)
    if self.hero_enable_data and self.hero_enable_data[pid] then
        return self.hero_enable_data[pid]
    end
    return nil
end
function HeroModel:getUseHeroEnable(pid)
    if self.use_hero_enable_data and self.use_hero_enable_data[pid] then
        return self.use_hero_enable_data[pid]
    end
    return nil
end
function HeroModel:getHeroIsEnable(pid)
    local use_id = self:getHeroEnable(pid)
    if use_id and use_id ~= 0 then
        return true
    end
    return false
end
function HeroModel:getHeroEnableIsOpen(pid)
    local hero_vo = self:getHeroById(pid)
    local need_star = Config.PartnerUltraData.data_const.open_ur_star.val
    if hero_vo and hero_vo.star >= need_star then
        return true
    end
    return false
end
function HeroModel:getHeroEnableAttrList(use_pid)
    local right_hero_vo = self:getHeroById(use_pid)
    local right_cfg = Config.PartnerData.data_partner_base[right_hero_vo.bid]
    local camp_type = right_cfg.camp_type
    local camp_page = 1
    for key,value in ipairs(Config.PartnerUltraData.data_ene_attr) do
        for k,v in pairs(value) do
            if table.indexof(v.camp_type,camp_type) then
                camp_page = v.page
            end
            break
        end
    end
    local cfg = Config.PartnerUltraData.data_ene_attr[camp_page][right_hero_vo.star]
    if not cfg then
        for i=right_hero_vo.star,1,-1 do
            cfg = Config.PartnerUltraData.data_ene_attr[camp_page][i]
            if cfg then
                break
            end
        end
    end
    if cfg then
        return cfg
    end
    return {}
end
function HeroModel:getHeroEnableSkillCfg(pid,use_pid)
    if use_pid ~= 0 then
        local hero_vo = self:getHeroById(pid)
        local use_hero_vo = self:getHeroById(use_pid)
        local cfg = Config.PartnerUltraData.data_ene_skill[hero_vo.bid]
        if cfg then
            table.sort(cfg,function(a,b) return a.lev > b.lev end)
            for key,value in ipairs(cfg) do
                local status = false
                for k,v in ipairs(value.limit) do
                    if v[1] == "star" then
                        if use_hero_vo and use_hero_vo.star and use_hero_vo.star >= v[2] then
                            status = true
                            break
                        end
                    end
                end
                if status then
                    return value
                end
            end
        end
    end
    return {}
end
function HeroModel:getHeroEnableSkillId(pid,use_pid)
    if use_pid ~= 0 then
        local cfg = self:getHeroEnableSkillCfg(pid,use_pid)
        if cfg and next(cfg) then
            return cfg.skill[1]
        end
    end
    return 0
end

function HeroModel:setUrSkillClick(data)
    if data.type == ActionStorageBool.URSkillClick then
        self.is_ur_skill_click = {}
        local list = {}
        if data.msg and data.msg ~= "" then
            list = string.split(data.msg,",")
        end
        for i, v in pairs(list) do
            self.is_ur_skill_click[tonumber(v)]=1
        end
    end
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_UR_Skill_Click_Event)
end
function HeroModel:getUrSkillClick(bid)
    if self.is_ur_skill_click and self.is_ur_skill_click[bid] and self.is_ur_skill_click[bid] == 1 then
        return true
    end
    return false
end
function HeroModel:updateUrSkillClick(bid)
    local txt = ""..bid
    for k, v in pairs(self.is_ur_skill_click or {}) do
        txt = txt..","..k
    end
    ActionController:getInstance():sender16809(ActionStorageBool.URSkillClick,1,txt)
end

--ur觉醒
function HeroModel:setHeroAwakenData(info)
    local hero_id = info.partner_id
    local hero_vo = self.hero_list[hero_id]
    if hero_vo.power < info.power then 
        GlobalMessageMgr:getInstance():showPowerMove(info.power-hero_vo.power,nil,hero_vo.power)
    end
    hero_vo:updateHeroVo(info)
    hero_vo:setUrAweakenStatus()
end
function HeroModel:setHeroAwakenListData(data)
    local list = data.list
    for k, info in pairs(list) do
        local hero_id = info.partner_id
        local hero_vo = self.hero_list[hero_id]
        if hero_vo then
            hero_vo:updateHeroVo(info)
            hero_vo:setUrAweakenStatus()
        end
    end
end
function HeroModel:getHeroAwakenMaxLev(id)
    local max = 0
    if Config.PartnerUrAwakenData.data_lv_info[id] then
        local lv_cfg = Config.PartnerUrAwakenData.data_lv_info[id][1]
        for i, v in ipairs(lv_cfg) do
            if v.lv > max then
                max = v.lv
            end
        end
    end
    return max
end

-------------属性丹---------------------------------
function HeroModel:setShuxingDanData(data)
    self.shuxingDanData = data.num
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_SHUXINGDAN_Update_Event)
    self:setShuxingDanRed()
end
function HeroModel:getShuxingDanData()
    return self.shuxingDanData
end
function HeroModel:setShuxingDanRed()
    local tree_lv = self.max_resonate_lev
    local _data = Config.ResonateData.data_altar_info
    local config = {}
    for k, v in pairs(_data) do
        table.insert(config,deepCopy(v))
    end
    table.sort(config, function(a,b)
        return a.chakra_lv < b.chakra_lv
    end)
    local _data
    local _last_data
    local _next_data
    for i, v in ipairs(config) do
        local now_lv = v.chakra_lv
        local next_lv = 0
        if config[i+1] then
            next_lv = config[i+1].chakra_lv
        end
        if tree_lv >= now_lv and tree_lv < next_lv then
            _data = v
            _next_data = config[i+1]
            _last_data = config[i-1]
        end
    end
    if not _data then
        _data = config[#config]
    end
    local use_num = self.shuxingDanData or 0
    local total_num = _data.use_limit
    local is_can_buy_num = total_num - use_num
    local item_id  = Config.ResonateData.data_const.altar_item.val
    local own_num = BackpackController:getInstance():getModel():getItemNumByBid(item_id)
    if own_num > 0 and is_can_buy_num > 0 then
        local data = {bid = HeroConst.RedPointType.eTree_shuxingdan, status = true}
        MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.resonate, {data})
        return true
    end
    local data = {bid = HeroConst.RedPointType.eTree_shuxingdan, status = false}
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.resonate, {data})
    return false
end
--检查英雄的卷轴是否可装备红点
function HeroModel:checkHeroRollerRed()
    local hero_bag_list = self:getAllHeroArray()
    local hero_array = hero_bag_list or Array.New()
    for j=1,hero_array:GetSize() do
        local hero_vo = hero_array:Get(j-1)
        local unlock_red = HeroCalculate.checkSingleHeroRollerRedPoint(hero_vo)
        if unlock_red then
            return true
        end
        local equip_red = HeroCalculate.checkSingleHeroHaveRollerEquipRedPoint(hero_vo)
        if equip_red then
            return true
        end
    end
    return false
end
---------------------------------金色秘卷 start--------------------------------------------
--设置金色秘卷信息
function HeroModel:setGoldArtifactData(data)
    self.artifact_skill_list = {}
    self.artifact_skill_list2 = {}
    for k, v in pairs(data.artifact_list) do
        -- self.artifact_skill_list[v.artifact_id] = v.skill_list
        self.artifact_skill_list[v.artifact_id] = {}
        for key, value in pairs(v.skill_list) do
            self.artifact_skill_list[v.artifact_id][value.skill_id] = 1
        end
        for key, value in pairs(v.skill_list) do
            self.artifact_skill_list2[value.skill_id] = 1
        end
    end
    self.artifact_exclusive_skill_use_list = {}
    for k, v in pairs(data.exclusive_skill_use_list) do
        self.artifact_exclusive_skill_use_list[v.skill_id] = v
    end
    
    GlobalEvent:getInstance():Fire(HeroEvent.Gold_Artifact_Update_Data_Event)
end
--获取金色秘卷技能列表
function HeroModel:getArtifactSkillList()
    return self.artifact_skill_list
end
function HeroModel:getArtifactSkillListForId(artifact_id)
    return self.artifact_skill_list and self.artifact_skill_list[artifact_id]
end
function HeroModel:getArtifactSkillListForSkillId(artifact_id,skill_id)
    if self.artifact_skill_list and self.artifact_skill_list[artifact_id] and self.artifact_skill_list[artifact_id][skill_id] then
        return true
    end
    return false
end
function HeroModel:getArtifactSkillListForSkillId2(skill_id)
    if self.artifact_skill_list2 and self.artifact_skill_list2[skill_id] then
        return true
    end
    return false
end
--获取金色秘卷专属技能信息
function HeroModel:getArtifactExclusiveSkillUseList()
    return self.artifact_exclusive_skill_use_list
end
function HeroModel:getArtifactExclusiveSkillUseListForId(skill_id)
    return self.artifact_exclusive_skill_use_list and self.artifact_exclusive_skill_use_list[skill_id]
end

----------------------------------金色秘卷 end--------------------------------------------
function HeroModel:checkIsTryout(partner_id)
    local hero_vo = self:getHeroById(partner_id)
    if hero_vo then
        if hero_vo.end_time ~= 0 and hero_vo.dic_locks and hero_vo.dic_locks[12] == 1 then
            return true
        end
    end
    return false
end

function HeroModel:getMaxHeroStar()
    local hero_lsit = self:getHeroList()
    local max_star = 0
    for k, v in pairs(hero_lsit) do
        local star = v.star
        if star > max_star then
            max_star = star
        end
    end
    return max_star
end

function HeroModel:checkIsContentHighHero(hero_list)
    if hero_list and next(hero_list) then
        for k, v in pairs(hero_list) do
            local partner_id = v.partner_id
            local hero_info = self:getHeroById(partner_id)
            local bid = hero_info.bid
            local hero_cfg = Config.PartnerData.data_partner_base[bid]
            if hero_cfg.score >= 9 then
                return true
            end
        end
    end
    return false
end
function HeroModel:__delete()
end
function HeroModel:getAllStarOrderLevel(bid, star, star_step_list, star_order)
    local lev = 0
    if star_step_list and bid and star then
        for i,v in pairs(star_step_list) do
            if star_order == nil or v.step ~= star_order then
                local key = getNorKey(bid, star, v.step)
                local star_order_config = Config.PartnerData.data_partner_star_order(key)
                if star_order_config then
                    lev = lev + star_order_config.add_max_lev
                end
            end
        end
    end
    return lev 
end
