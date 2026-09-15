-- --------------------------------------------------------------------
-- 活动相关的常量
-- 
-- (必填, 创建模块的人员)
-- (必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
ActionConstants = ActionConstants or {}

ActionType = {
	Operate = 0,        -- 运营活动
	OpenServer = 1,     -- 开服活动
	Combine = 2,        -- 合服活动
	Wonderful = 4,      -- 精彩活动(包含0,1,3)
	SingleWonderful = 3,-- 个人精彩活动
}

ActonExchangeType = {
    Other = 0,          --其他
    Perday = 1,         --每日限兑
    AllServer = 2,      --全服限兑
    Activity = 3,       --活动限兑
}

--- 活动所有标签页的类型控制器
ActionPanelTypeView = {
	[1] = "ActionInvestPanel"         --投资计划
	,[2] = "ActionGiftPanel"           --超值礼包
	,[3] = "ActionAccChargePanel"      --首冲+累充
	,[4] = "ActionAccCostPanel"       --累计消费
	,[5] = "ActionLimitBuyPanel"       --每日抢购 
	,[6] = "ActionLimitBossPanel"	   --限时BOSS
	,[7] = "ActionGrowFundPanel"	   -- 成长基金    
    ,[15] = "ActionAccLevelUpGiftPanel" --升级有礼
    ,[16] = "ActionCommonPanel" --点金活动、远航夺宝、速战达人、远征精英(改位面排行)、冒险排行、积天豪礼、累计充值、累计消费、升星有礼
                                --融合祝福、节日登录好礼、砸蛋豪礼、觉醒豪礼
    ,[17] = "ActionLimitChangePanel" --限时兑换活动
    ,[20] = "ActionLimitGroupbuyPanel" --限时团购
    ,[30] = "StartWorkPanel" --开工福利
    ,[100] = "AnimateActionFestvalPanel" --元宵灯会
    ,[101] = "AnimateYuanzhenKitchenPanel"--元宵厨房
    ,[102] = "ActionLimitYuanZhenPanel" --元宵冒险、逐浪之夏、试炼有礼、松果大作战、合服任务
    ,[103] = "ActionTimeSummonPanel" --限时召唤
    ,[104] = "ActionTimeShopPanel"   --限时商城
    ,[105] = "ActionLimitFullExchangePanel" --满减商城
    ,[106] = "DialActionMainPanel" --转盘
    ,[107] = "QingMingPanel" --踏青 (节日活动范围)
    ,[109] = "ActionSmasheggPanel" --砸金蛋

    --,[110] = "ActionHeroConvertPanel" -- 英雄10置换活动
    ,[111] = "ActionHighValueGiftPanel" -- 超值礼包活动
    ,[112] = "ActionSandybeachBossFightPanel" -- 沙滩争夺战
    ,[113] = "ActionMysteriousStorePanel" --神秘杂货铺
    --,[114] = "ActionHeroClothesPanel" --神装道具商店
    ,[115] = "ActionBuySkinPanel" --皮肤购买
    ,[116] = "TreasurePanel" --一元夺宝 (节日活动范围)
    ,[117] = "ActionSevenChargePanel" --7天连充
    ,[118] = "LimitExercisePanel" --限时试炼之境
    ,[119] = "ActionHeroResetPanel" --英雄重生
    ,[120] = "EliteSummonPanel" --精英限时招募
    ,[121] = "PresageSummonPanel" --预言召唤
    ,[122] = "ActionSkinLotteryPanel" --皮肤抽奖
    ,[123] = "ActiontermbeginsPanel" --开学季boss活动
    ,[124] = "PetardActionMainPanel" --花火大会
    ,[125] = "ActionActivityNoticePanel" --活动预告 (节日活动范围)
    ,[126] = "ActionCarnivalReportPanel" --嘉年华报告活动
    ,[142] = "ActionRechargeRebatePanel" --充值返利
    ,[145] = "ActionLuckyDogPanel" --幸运锦鲤
    ,[144] = "ActionFortuneBagDrawPanel" --不放回抽奖
    ,[147] = "ActionGrowGiftPanel" --成长自选
    ,[148] = "ActionSweetPanel" --甜蜜大作战（情人节活动）
    ,[149] = "SelectEliteSummonPanel" --自选精英召唤
    ,[150] = "ActionWhiteDayPanel" -- 白色情人节(打女神)活动
    
    --合服相关
    
    ,[127] = "MergeTimeShopPanel" --合服商城
    ,[128] = "MergeSignPanel" --合服签到
    ,[129] = "MergeFirstChargePanel" --合服首充
    ,[130] = "MergeAimPanel" -- 合服目标
    --合服相关结束
    ,[131] = "ActionTimeElfinSummonPanel" -- 精灵召唤
    ,[132] = "ActionSmallAmountGiftPanel" -- 小额礼包
    ,[134] = "ActionSkinDirectPurchasePanel" -- 皮肤直购界面
    ,[141] = "ReturnActionShopPanel" -- 回归兑换
    ,[143] = "ActionSpriteResetWindow" -- 限时精灵重生
    ,[151] = "ActionSuperValueWeeklyCardPanel" -- 超值周卡
    ,[152] = "ActionNoviceGiftPanel" -- 新手礼包
    ,[153] = "ActionPractiseTowerPanel" -- 新人练武场
    ,[155] = "ActionWarOrderPanel" -- 战令集结
	,[156] = "ElitePanel" -- 大闹天宫和皮肤之约活动
    ,[157] = "ActionOptionalGiftPanel" -- 自选礼包
    ,[158] = "ActionRisingStarGiftPanel" -- 升星豪礼
    ,[159] = "ActionGoodGiftPanel" -- 单笔好礼
    -- ,[159] = "ActionForgingPanel" -- 五金锻造铺
}

--是否存在需要转换为类型4
ActionTypeChange = {
	[0] = ActionType.Operate,
	[1] = ActionType.OpenServer,
	[3] = ActionType.SingleWonderful,
} 

-- 活动额外参数类型
ActionExtType = {
	ActivityMaxCount         = 2  -- 单笔充值限制次数
    ,RechageTotalCount       = 4  -- 限购购买总次数
    ,RechageCurCount         = 5  -- 限购已购买次数
    ,ActivityCurrentCount    = 6  -- 单笔充值当前次数
    ,BossId                  = 8  -- BOSSID
    ,BossIcon                = 9  -- BOSS展示图标 
    ,BossMinPower            = 10 -- BOSS最小通关战力
    ,BossReplayId            = 11 -- BOSS击杀录像ID  
    ,BossRecommendPower      = 12 -- BOSS推荐通关战力
    ,RechargeMaxCount        = 13 -- 充值返利最大次数
    ,RechargeUseCount        = 14 -- 充值返利已用最大次数
    ,RechargeAvailableCount  = 15 -- 充值返利可用次数
    ,RechargeBackOutItem     = 16 -- 充值返利已出物品
    ,RechargeRMB             = 17 -- 充值返利充值人民币
    ,GodPartnerId            = 18 -- 神将id
    ,ItemId                  = 19 -- 消耗道具id
    ,ItemNum                 = 20 -- 消耗道具数量
    ,PopItemId               = 21 -- 弹窗道具id
    ,PopItemNum              = 22 -- 弹窗道具数量
    ,ActivityAddCount        = 23 -- 累积可领取次数
    ,ActivityFestvalTime     = 24 -- 节日登录时间
    ,ActivityFestvalDiscount = 25 -- 活动打折标签号
    ,ActivityOldPrice        = 26 -- 活动原价
    ,ActivityCurrentPrice    = 27 -- 活动现价
    ,ItemRechargeId          = 33 -- 物品支付ID
    ,ItemDesc                = 34 -- 物品描述
    ,ExbItemBid              = 36 -- 展示物品bid
    ,ExbItemNum              = 37 -- 展示物品数量
    ,ResigninCharge          = 38 -- 补签待充值数额
}


ActionStatus = {
    un_finish = 0,              -- 进行中
    finish = 1,                 -- 可提交
    completed = 2,              -- 已提交
}

--- 特殊活动这类活动不显示在活动面板,而是显示在福利界面
ActionSpecialID = {
	invest = 991003,
    growfund =  991008,
}

-- 基金类型
FundType = {
    type_one = 101,  -- 128元基金
    type_two = 102,  -- 328元基金
}

-- 基金红点类型
FundRedIndex = {
    fund_get_one = 1, -- 128元基金可领取
    fund_get_two = 2, -- 328元基金可领取
    fund_buy_one = 3, -- 购买128元基金红点
    fund_buy_two = 4, -- 购买328元基金红点
}

--限时活动通用面板
ActionRankCommonType = {
    --排行榜
    epoint_gold  = 97001,      --点金
    speed_fight  = 97002,      --快速作战
    voyage       = 97003,      --远航
    hero_expedit = 97004,      --远征
    adventure    = 97005,     --冒险
    limit_exercise = 97007,     --试炼之境
    yuanzhen_adventure = 93018, --元宵冒险、逐浪之夏、松果大作战
    planes_rank  = 97009,    --位面排行榜活动
    exercise_1 = 93031, --试炼有礼
    exercise_2 = 93032, --试炼有礼2
    exercise_3 = 93033, --试炼有礼3
    elite_summon = 93034, --精英招募
    time_summon = 93019, -- 限时召唤
    start_welfare = 93020, -- 开工福利
    term_begins = 97008, -- 开学季

    dial = 93022,   -- 星辰转盘
    qingming = 93023,--踏青
    smashegg = 93024, -- 砸金蛋
    petard = 93037, -- 花火大会
    sweet = 93049, -- 甜蜜大作战（情人节活动）

    --全面屏的活动    
    common_day = 991011, --普通节日
    festval_day = 991024, --春节活动
    lover_day   = 991025, --情人节活动
    

    longin_gift = 991027, --登录好礼
    limit_charge = 991028, --限时累充
    limit_charge_1 = 991045, --限时累充
    luckly_egg = 93025, --砸蛋好礼
    acc_luxury = 991021, -- 积天豪礼
    totle_charge = 91022, --累计充值
    totle_consume = 991023, --累计消费
    trause_grade_shop = 991026, --夺宝商城
    fusion_blessing = 993013,   --融合祝福
    updata_star = 993014,       --升星有礼
    hero_awake = 993026,       --觉醒豪礼
    open_server = 91029,   --开服限购
    high_value_gift = 991030, --超值小额礼包

    over_value_gift_1 = 991033, --超值小额礼包
    over_value_gift_2 = 991043, --超值小额礼包

    mysterious_store = 993028, --神秘杂货铺
    action_wolf = 93018, --魔狼传说活动
    action_skin_buy = 991032, --皮肤购买
    action_treasure = 993029, --一元夺宝
    week_gift = 991034, --周卡礼包
    seven_charge = 991036, --7天连充

    lottery_skin = 993036, --皮肤抽奖
    summon_luxury = 991037,  -- 召唤豪礼
    recruit_luxury = 991038,  --先知豪礼
    activity_Notice = 993038 , -- 活动预告

    merge_task = 9993033,   --合服任务
    merge_shop = 9991039,   --合服商城
    merge_sign = 9991040,   --合服签到
    merge_first_charge = 9991041, --合服首充
    merge_aim = 9993039, --合服首充 --
    time_elfin_summon = 93041, --精灵召唤
    carnival_report = 993043, --嘉年华报告活动

    skin_direct_purchase = 91046, --皮肤直购
    recharge_rebate = 991047, --元旦充值返利
    sprite_return = 993044, --精灵重生
    lucky_dog = 993046, --幸运锦鲤
    FortuneBagDraw = 993045, --不放回抽奖

    year_monster_fight = 93032, --年兽大作战
    ouqi_gift = 93048,   --欧气大礼 
    white_day = 93050,   --白色情人节活动(女神试炼)
    select_elite_summon = 93051,   --自选精英召唤 
    grow_gift = 991050,   --成长自选礼包
    super_week_card = 993052,   --超值周卡
    new_totle_charge = 91052, --新累计充值
    novice_gift = 91053, --新手直购商城
    new_totle_charge1 = 91054, --新累计充值1
    practise_tower = 93053, --新人练武场
    
    kaifu_hero_collect = 91055,--开服英雄集结
    kaifu_soul = 93055, --开服武魂试炼
    elite_palance = 93056, --大闹天宫 抽奖
    elite_palance2 = 993056, --大闹天宫 抽奖
    elite_skin = 93057, --皮肤之约
    elite_skin2 = 993057, --皮肤之约
    war_order_assembly = 91056, --战令集结
    optional_gift = 91057, --自选礼包
    good_gift = 991059, --自选礼包
    -- updata_star = 993014,       --升星有礼
}

--限时活动兑换通用面板
ActionChangeCommonType = {
    limit_change  = 93003, --限时兑换
    limit_change1 = 993003, --限时兑换
    limit_festive = 93011, --纳福迎春
    limit_festive1= 993011, --纳福迎春
    limit_gift    = 93010, --白雪献礼
    limit_gift1   = 993010, --白雪献礼
    limit_garden  = 93012, --游园祭点
    limit_garden1  = 993012, --游园祭点
    limit_yuanzhen  = 93017, --元宵兑换
    limit_yuanzhen1  = 993017, --元宵兑换
}
--任务描述改为可传参数
function ActivityTaskDescription(data)
    if not data then return {} end
    if data[1] == "artifact" then
        return {BackPackConst.quality_name[data[2]]}
    elseif data[1] == "eqm" then
        return {data[2],BackPackConst.quality_name[data[3]]}
    elseif data[1] == "sprite_quality" then
        return {BackPackConst.quality_name[data[2]]}
    
    elseif data[1] == "heroid" then
        local id = 0
        if type(data[2]) == "table" then
            if data[2][1] then
                id = data[2][1]
            end
        else
            id = data[2]
        end
        if Config.PartnerData.data_partner_base[id] and Config.PartnerData.data_partner_base[id].name then
            return {Config.PartnerData.data_partner_base[id].name}
        end
        return {""}
    elseif data[1] == "itemid" then
        if Config.ItemData.data_get_data(data[2]) and Config.ItemData.data_get_data(data[2]).name then
            return {Config.ItemData.data_get_data(data[2]).name}
        end
        return {""}
    elseif data[1] == "star" then
        return {data[2]}
    elseif data[1] == "limit" then
        return {data[2]}
    elseif data[1] == "score" then
        if HeroConst.ScoreList[data[2]] then
            return {HeroConst.ScoreList[data[2]]}
        else
            return {HeroConst.ScoreList[1]}
        end
    elseif data[1] == "maze_lv" then
        local cfg = Config.MazeData.data_diff_info
        if cfg[data[2]] then
            return {cfg[data[2]].name}
        else
            return {cfg[1].name}
        end
    elseif data[1] == "camp_type" then
        if data[2] == 0 then
            return {TI18N("")}
        elseif HeroConst.CampName[data[2]] then
            return {HeroConst.CampName[data[2]]}
        end
    elseif data[1] == "submit_itemid" then
        if Config.ItemData.data_get_data(data[2][1]) and Config.ItemData.data_get_data(data[2][1]).name then
            return {Config.ItemData.data_get_data(data[2][1]).name,MoneyTool.GetMoneyString(data[2][2])}
        end
        return {""}
    elseif data[1] == "num" then
        return {data[2]}
    end
    return {}
end
--后端存储布尔值类型  16808 16809 --12 13不能用 已经废弃的字段 
--2000-2999用作编年史研发项目期数红点
--3000-3999 用作记录潜能页签的首次点击
--10000-99999用作记录5系转换忍者的首次解锁条件
--100000-999999用作记录忍者bid刻印的首次点击事件(筛选按钮专用)
ActionStorageBool = {
    IsJumpOverAnimation = 1, -- 是否跳过动画 全游戏通用
    PoolParty = 2, -- 泳池派对
    AdventureMopup = 3, -- 生存冒险扫荡
    MoreMonopolyBoss = 4, -- 走格子多对战未上阵提示
    BonsSkill = 5, -- 羁绊技开启
    Form_BonsSkill = 6, -- 布阵羁绊技是否生效  0生效 1不生效
    Heaven_Hide = 7, -- 是否查看过妙木山隐藏关卡  0未看过 1看过
    ResonateHigh = 8, -- 是否查看过神树同步进度  0未进入 1已进入
    TreasureResearchFinish = 9, -- 编年史研发是否点击过完成构成 0未点击 1已点击
    TreasureResearchInto = 10, -- 编年史研发是否点击过实战投入 0未点击 1已点击
    BreakNew = 11, -- 成就 界限突破是否点击过新的
    SpSummon = 14, -- sp招募
    SpElitePanel = 15, -- sp神忍之约
    NewGrowFund = 16, -- 豚豚钱罐
    returnResBack = 17, -- 新回归活动资源回溯弹出
    gemAutoRemove = 18, -- 宝石自动分解选择内容
    gemIsAutoRemove = 19, -- 宝石是否自动分解
    gemIsSkipSmelt = 20, -- 宝石合成是否跳过动画
    forgeIsSkipSmelt = 21, -- 符文合成是否跳过动画
    gemBackRed = 22, -- 宝石背包首次点击
    gemStoneRed = 23, -- 宝石功能
    btIsSkipSmelt = 24, -- 神王宝库是否跳过动画
    allBtIsSkipSmelt = 25, -- 神王宝库是否跳过动画
    allBtHolidayFirstRed = 26, -- 忍道对决首次红点
    allBtFirstRed = 27, -- 忍道对决抽奖首次红点
    URSkillClick = 28, -- 图鉴ur技能首次点击
    UrElitePanel = 29, -- ur神忍之约首次弹窗
    xiaoxiaoleFirst = 30, -- 消消乐首次进入
    mooncombat_directpurchase = 31, --
    olympicGameTips = 32, -- 奥运会首次进入
    NeworderactionPop = 33, -- 新忍者战令弹窗
    autoRemoveElfin = 34, -- 自动分解通灵兽
    puzzleBook = 35, -- 拼图图鉴
    ninjaVillageCombat = 36, -- 影之意志首次红点
    angerUpLevCostType = 37, -- 怒气技升级消耗类型
    bondSkillCostType = 38, -- 羁绊技激活消耗类型
    FullReduction = 1000, -- 黑色星期五满减红点
    optional_gift2 = 1001, -- 自选礼包首次红点
    ForgeHouse_Gold_Equip = 7001, -- 锻造屋金装首次红点
}
--后端存储今日是否弹窗  16810  16811 
ActionStorageBool2 = {
    PoolParty = 1, -- 泳池派对
    ShinobuStore = 2, -- 忍魂商店
    Treasure = 3, -- 魔导器战令倒计时弹窗
    MagicSummon = 7, --新的忍者羁绊活动
    DramaWar = 8, --忍界大战首次进入
    TreasureWar = 9, --忍界大战首次进入
    Turkey = 10, -- 火鸡节战令倒计时弹窗
    TurkeyWar = 11, --火鸡节战令首次进入
    TimeShop = 12, --属性招募限时商店
    ElfinDispatch = 13, --通灵兽派遣
    DdpFirst = 14, --对对碰首次进入
    GuildFirstRedBag = 15, --首次登陆工会发红包的红点
    Dispatch = 16, -- 通灵兽派遣战令倒计时弹窗
    DispatchOrder = 17, --通灵兽派遣战令首次进入
    BackSixGift = 18, --回归活动6元礼包
    DispatchFirst = 19, --通灵兽派遣每日首次弹窗
    PitAlert = 20,--挖矿弹窗
    NewBossTreasure = 21,--忍道对决首次开战
    NewlyPackagedGift = 22,--先锋测试招募每日首次弹出
    StarExclusive = 23,--星级专属未选择红点
}
--后端存储活动首次点击 bid
ActionStorageBool3 = {
    ActionRankCommonType.timeShop, --限时属性商店
    ActionRankCommonType.lottery, --拉霸
    ActionRankCommonType.time_elfin_summon, --精灵召唤
    ActionRankCommonType.mooncombatmono, --海岛寻宝
    ActionRankCommonType.olympic_puzzle, --运动会 活动合集   拼图图鉴
    ActionRankCommonType.collection_jinqi,-- 合集页禁器
}
--额外推送后红点储存
ActionCurrentRedPoint = {
    [993114] = ActionRankCommonType.ddp_fp,
}
--对对碰活动特殊类型
DdpSpecialType = {
    Time = 1, --倒计时
}
--转盘类型
ActionTreasureType = {
    Lucky = 1, --幸运转盘
    Senior = 2, --高级转盘
    Elite = 3, --精英转盘
    Natural = 4, --天道转盘
    Gemstone = 5, --宝石转盘
}