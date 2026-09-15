--英雄(伙伴)的常量
-- by lwc
HeroConst = HeroConst or {}


--英雄背包页签类型
HeroConst.BagTab = {
    eBagHero        = 1 , --英雄页签
    eBagPokedex    = 2 , --图鉴页签
    eElfin          = 3,  -- 精灵
    eHalidom        = 4,  -- 圣物
}

--英雄主信息界面页签类型
HeroConst.MainInfoTab = {
    eMainTrain          = 1 , --培养  -- eMainEquip          = 2 , --装备 装备界面被移除了 放到英雄旁边
    eMainUpgradeStar    = 2 , --升星 
    eMainTalent         = 3 , --天赋
    eMainHolyequipment  = 4 , --神装
    eMainSoulHomology   = 5 , --灵魂同调
    eMainSpecial        = 6 , --潜能释放
    eMainAwarken        = 7 , --觉醒
}

-- 英雄主信息界面页签类型名字
HeroConst.MainInfoTabName = {
    [HeroConst.MainInfoTab.eMainTrain] = TI18N("语言_c_3289"),
    [HeroConst.MainInfoTab.eMainUpgradeStar] = TI18N("语言_c_2970"),
    [HeroConst.MainInfoTab.eMainTalent] = TI18N("语言_c_3133"),
    [HeroConst.MainInfoTab.eMainHolyequipment] = TI18N("语言_exc_02_24"),
    [HeroConst.MainInfoTab.eMainSoulHomology] = TI18N("语言_c_4529"),
    [HeroConst.MainInfoTab.eMainSpecial] = TI18N("语言_c_6740"),
    [HeroConst.MainInfoTab.eMainAwarken] = TI18N("语言_c_7242"),
}
--布阵界面中间的页签类型
HeroConst.FormMiddleTab = {
    eFormHero          = 1 , --上阵英雄
    eFormHallows       = 2 , --神器
    eFormFormation     = 3 , --阵法
}

HeroConst.FormShowType = {
    eFormFight   = 1 , --出战
    eFormSave    = 2 , --保存布阵
}
--英雄献祭类型
HeroConst.SacrificeType = {
    eHeroFuse          =   1, --融合神殿
    eHeroSacrifice     =   2, --英雄献祭
    eHeroReplace       =   3, --置换神殿
    eHeroDisband       =   4, --英雄重生
    eChipSacrifice     =   5, --英雄碎片献祭
    eSoulHomology     =   6, --灵魂同调
}

HeroConst.tabType = {
    [HeroConst.SacrificeType.eHeroFuse] = TI18N("语言_c_3290"),
    [HeroConst.SacrificeType.eHeroSacrifice] = TI18N("语言_c_3291"),
    [HeroConst.SacrificeType.eHeroReplace] = TI18N("语言_c_1532"),
    [HeroConst.SacrificeType.eHeroDisband] = TI18N("语言_c_3214"),
    [HeroConst.SacrificeType.eSoulHomology] = TI18N("语言_c_4529"),
}
--英雄共鸣类型
HeroConst.ResonateType = {
    eResonate        =   1, --英雄水晶
    eStoneTablet     =   2, --英雄石碑增益
    eEmpowerment     =   3, --英雄石碑注能
}
--英雄分解类型
HeroConst.ResetType = {
    eHeroReset     =   1, --英雄献祭
    eChipReset     =   2, --英雄碎片献祭
    eHolyEquipSell =   3, --神装出售
    eTenStarChang  =   4, --10星置换
    eActionHeroReset   =   5, --活动的英雄重生
    eFunriture     =   6, -- 家具出售
    eHeroReturn   =   7, --常驻的英雄回退
    eSpriteReturn   =   8, --活动的精灵重生
}


--英雄锁定类型(一般由服务端定义)
HeroConst.LockType = {
    eHeroLock          =   1, --英雄锁定
    eHeroChangeLock    =   2, --英雄置换锁定
    eHeroSoulLock      =   3, --英雄灵魂锁定
    eHeroSoulCoverLock =   4, --英雄灵魂被锁定
    eHeroResonateLock  =   98, --英雄共鸣锁定 --客户端定义
    eFormLock          =   99, --英雄上阵锁定 --客户端定义 
}

--英雄阵营类型
HeroConst.CampType = { 
    eNone          = 0 , --无
    eWater         = 1 , --水
    eFire          = 2 , --火
    eWind          = 3 , --风
    eLight         = 4 , --光
    eDark          = 5 , --暗
    eLingtDark     = 6 , --光暗
    eAlien         = 7 , --异界
}

--英雄阵营对应名字
HeroConst.CampName = { --水火风光暗
    [HeroConst.CampType.eNone]          = TI18N("语言_c_2103") , --无
    [HeroConst.CampType.eWater]         = TI18N("语言_c_3292") , --无
    [HeroConst.CampType.eFire]          = TI18N("语言_c_3293") , --无
    [HeroConst.CampType.eWind]          = TI18N("语言_c_3294") , --无
    [HeroConst.CampType.eLight]         = TI18N("语言_rec_hi_03_5") , --无
    [HeroConst.CampType.eDark]          = TI18N("语言_rec_hi_03_6") , --无
    [HeroConst.CampType.eAlien]         = TI18N("语言_c_4530") , --无
}
--英雄阵营对应属性名字
HeroConst.CampAttrName = { --水火风光暗
    [HeroConst.CampType.eNone]          = TI18N("语言_c_2103") , --无
    [HeroConst.CampType.eWater]         = TI18N("语言_c_1138") , --无
    [HeroConst.CampType.eFire]          = TI18N("语言_c_1139") , --无
    [HeroConst.CampType.eWind]          = TI18N("语言_c_3297") , --无
    [HeroConst.CampType.eLight]         = TI18N("语言_c_3298") , --无
    [HeroConst.CampType.eDark]          = TI18N("语言_c_3299") , --无
    [HeroConst.CampType.eAlien]         = TI18N("语言_c_4531") , --无
}

--阵营背景资源名字
HeroConst.CampBgRes = {
    [HeroConst.CampType.eWater] = "hero_info_bg_1",
    [HeroConst.CampType.eFire]  = "hero_info_bg_2",
    [HeroConst.CampType.eWind]  = "hero_info_bg_3",
    [HeroConst.CampType.eLight] = "hero_info_bg_4",
    [HeroConst.CampType.eDark]  = "hero_info_bg_5",
    [HeroConst.CampType.eAlien] = "hero_info_bg_5",
}
--阵营背景资源名字sp
HeroConst.SpCampBgRes = {
    [HeroConst.CampType.eWater] = "hero_special_water_bg",
    [HeroConst.CampType.eFire]  = "hero_special_fire_bg",
    [HeroConst.CampType.eWind]  = "hero_special_wind_bg",
    [HeroConst.CampType.eLight] = "hero_special_yang_bg",
    [HeroConst.CampType.eDark]  = "hero_special_dark_bg",
    [HeroConst.CampType.eAlien] = "hero_info_bg_5",
}

--阵营底座背景资源名字
HeroConst.CampBottomBgRes = {
    [HeroConst.CampType.eWater] = "hero_camp_1",
    [HeroConst.CampType.eFire]  = "hero_camp_2",
    [HeroConst.CampType.eWind]  = "hero_camp_3",
    [HeroConst.CampType.eLight] = "hero_camp_4",
    [HeroConst.CampType.eDark]  = "hero_camp_5",
    [HeroConst.CampType.eAlien] = "hero_camp_5",
}


--英雄职业类型
HeroConst.CareerType ={
    eNone     = 0 , --无
    eMagician     = 2 , --法师
    eWarrior      = 3 , --战士
    eTank         = 4 , --坦克
    eSsistant     = 5 , --辅助
    eURMagician     = 12 , --法师UR
    eURWarrior      = 13 , --战士UR
    eURTank         = 14 , --坦克UR
    eURSsistant     = 15 , --辅助UR
    eMRMagician     = 22 , --法师MR
    eMRWarrior      = 23 , --战士MR
    eMRTank         = 24 , --坦克MR
    eMRSsistant     = 25 , --辅助MR
    eOther     = 999 , --特殊
}
--英雄职业对应名字
HeroConst.CareerName ={
    [0] = TI18N("语言_c_2103"),
    [HeroConst.CareerType.eMagician]    = TI18N("语言_c_814"),
    [HeroConst.CareerType.eWarrior]     = TI18N("语言_c_815"),
    [HeroConst.CareerType.eTank]        = TI18N("语言_c_816"),
    [HeroConst.CareerType.eSsistant]    = TI18N("语言_c_817"),
    [HeroConst.CareerType.eURMagician]    = TI18N("语言_c_7252"),
    [HeroConst.CareerType.eURWarrior]     = TI18N("语言_c_7253"),
    [HeroConst.CareerType.eURTank]        = TI18N("语言_c_7254"),
    [HeroConst.CareerType.eURSsistant]    = TI18N("语言_c_7255"),
    [HeroConst.CareerType.eMRMagician]    = TI18N("语言_c_7924"),
    [HeroConst.CareerType.eMRWarrior]     = TI18N("语言_c_7925"),
    [HeroConst.CareerType.eMRTank]        = TI18N("语言_c_7926"),
    [HeroConst.CareerType.eMRSsistant]    = TI18N("语言_c_7927"),
    [HeroConst.CareerType.eOther]       = TI18N("语言_c_6971"),
}
--英雄职业对应名字
HeroConst.CareerName2 ={
    [0] = TI18N("语言_c_2103"),
    [HeroConst.CareerType.eMagician]    = TI18N("语言_c_3300"),
    [HeroConst.CareerType.eWarrior]     = TI18N("语言_c_2934"),
    [HeroConst.CareerType.eTank]        = TI18N("语言_c_3301"),
    [HeroConst.CareerType.eSsistant]    = TI18N("语言_c_3302"),
}
--英雄职业对应图标
HeroConst.CareerImg ={
    [HeroConst.CareerType.eMagician]    = "common_90047",
    [HeroConst.CareerType.eWarrior]     = "common_90048",
    [HeroConst.CareerType.eTank]        = "common_90049",
    [HeroConst.CareerType.eSsistant]    = "common_90050",
}
--英雄item显示类型
HeroConst.ExhibitionItemType = {
    eNone  =   0, -- 无
    eHeroBag = 1 , --英雄背包类型
    ePokedex = 2 , --图鉴变灰类型
    eHeroChange = 4 , --英雄转换界面
    eFormFight = 7 , --布阵出战界面
    eVoyage = 8 , --远航界面
    eExpeditFight = 9 , --远征
    eStronger = 10 , --我要变强
    eEndLessHero = 11 , --是否是无尽试炼雇佣的英雄
    eAdventure = 12, -- 冒险
    eLimitExercise = 13, -- 限时试炼之境
    ePlanes = 14, -- 位面
    eLegendTrial = 15, -- 传奇试炼
    eCrossLegender = 16 , --跨服传奇忍者
    eShadowChallenge = 17 , --影之试炼
    eMaze = 18 , --地下迷宫
    eTeamDun = 19, -- 组队副本
}

--英雄红点类型
HeroConst.RedPointType ={
    eRPLevelUp  = 1,   --升级升阶
    eRPEquip    = 2,   --装备
    eRPStar     = 3,   --升星
    eRPTalent   = 4,   --天赋技能
    eRPHalidom_Unlock = 5, -- 圣物解锁
    eRPHalidom_Lvup = 6,   -- 圣物升级
    eRPHalidom_Step = 7,   -- 圣物进阶
    eResonate_extract = 8,   -- 共鸣精炼
    eResonate_stone = 9,   -- 共鸣石碑
    -- Artifact = 5,
    eElfin_hatch_done = 10, -- 精灵孵化完成
    eElfin_tree_lvup = 11,  -- 精灵古树可升级或进阶
    eElfin_empty_pos = 12,  -- 精灵古树有可放置的精灵
    eElfin_compound = 13,   -- 上阵的精灵可合成
    eElfin_higher_lv = 14,  -- 上阵精灵有更高级的精灵
    eElfin_hatch_lvup = 15, -- 灵窝可升级
    eElfin_hatch_egg = 16,  -- 有可孵化的灵窝和蛋
    eElfin_activate = 17,   -- 精灵图鉴红点
    eElfin_hatch_open = 18,   -- 灵窝可解锁
    eElfin_summon = 19,   -- 精灵免费召唤
}

--装备位置列表
HeroConst.EquipPosList = {
    [1] = BackPackConst.item_type.WEAPON, -- 武器
    [2] = BackPackConst.item_type.SHOE, -- 鞋子
    [3] = BackPackConst.item_type.CLOTHES, -- 衣服
    [4] = BackPackConst.item_type.HAT, -- 头盔
}

--神装装备位置列表
HeroConst.HolyequipmentPosList = {
    [1] = BackPackConst.item_type.GOD_EARRING,  -- 耳环
    [2] = BackPackConst.item_type.GOD_NECKLACE, -- 项链
    [3] = BackPackConst.item_type.GOD_RING,     -- 戒指
    [4] = BackPackConst.item_type.GOD_BANGLE,   -- 手镯
}

-- 神装item对应的默认资源名称
HeroConst.HolyEmptyIconName = {
    [BackPackConst.item_type.GOD_EARRING] = "hero_info_25",  --耳环
    [BackPackConst.item_type.GOD_RING] = "hero_info_27",  --戒指
    [BackPackConst.item_type.GOD_NECKLACE] = "hero_info_26",  --项链
    [BackPackConst.item_type.GOD_BANGLE] = "hero_info_28",  --手镯
}

--英雄绘图分享来源类型
HeroConst.ShareType = {
    eHeroInfoShare = 1,     --英雄信息绘图分享
    eLibraryInfoShare = 2,  --图书馆信息绘图分享
}

--英雄界面分享频道类型
HeroConst.ShareBtnType = {
    eHeroShareCross = 1 , --跨服频道 
    eHeroShareWorld = 2 , --世界频道 
    eHeroShareGuild = 3 , --公会频道 
}

--打开装备tips、面板来源类型
HeroConst.EnterType = {
    eOhter        = 0, --其他
    eHolyPlan     = 1, --神装方案管理
}
--打开天赋学习界面，激活、背包
HeroConst.learnType = {
    learn        = 1, --激活
    bag     = 2, --天赋背包
}

HeroConst.SelectHeroType = {
    eStarFuse     = 1, --表示融合祭坛
    eUpgradeStar  = 2, --表示升星界面的
    eHalidom      = 3, --圣物
    eTenConvert   = 4, --活动10星置换
    eResonateStone     = 5, --共鸣圣阵选择英雄
    eResonateEmpowerment = 6,   -- 共鸣赋能选择英雄
    eResonateCrystal = 7, --共鸣水晶(改版后增加的第一个页签)
    eSoulHomology = 8, --灵魂同调
}

--长时间点击类型
LONG_TOUCH_INIT_TYPE = 0   --初始化状态
LONG_TOUCH_BEGAN_TYPE = 1  --长按开始 
LONG_TOUCH_END_TYPE = 2    --长按因为触发了事件结束了
LONG_TOUCH_CANCEL_TYPE = 3 --长按取消

-- 忍具/异界之心
HERO_SOUL_TYPE = 0  --忍具
HERO_HEART_TYPE = 1 --异界之心

HeroConst.Recommend = {
    topLevel     = 1, --顶级玩家
    lineup  = 2, --阵容推荐
    comment      = 3, --评论
}

--13星星阶属性描述
--数值
HeroConst.AttributesDescribe1 = {
    atk = TI18N("语言_gui_sk_05_3"),
	def_p = TI18N("语言_att_01_2"),
	def_s = TI18N("语言_att_01_3"),
	hp_max = TI18N("语言_gui_sk_05_8"),
	hp = TI18N("语言_gui_sk_05_8"),
	speed = TI18N("语言_att_01_5"),
	def = TI18N("语言_att_01_6"),
}
HeroConst.AttributesDescribe2 = {
	hit_rate = TI18N("语言_att_01_7"),
	dodge_rate = TI18N("语言_att_01_8"),
	crit_rate = TI18N("语言_att_01_9"),
	crit_ratio = TI18N("语言_gui_sk_05_4"),
	hit_magic = TI18N("语言_att_01_11"),
	dodge_magic = TI18N("语言_att_01_12"),
	tenacity = TI18N("语言_gui_sk_05_9"),
	atk_per = TI18N("语言_gui_sk_05_3"),
	def_per = TI18N("语言_att_01_6"),
	hp_max_per = TI18N("语言_gui_sk_05_8"),
	dam = TI18N("语言_att_01_15"),
	res = TI18N("语言_att_01_16"),
	cure = TI18N("语言_gui_sk_05_10"),
	be_cure = TI18N("语言_att_01_18"),
	dam_p = TI18N("语言_att_01_19"),
	dam_s = TI18N("语言_att_01_20"),
	res_p = TI18N("语言_att_01_21"),
	res_s = TI18N("语言_att_01_22"),
	speed_per = TI18N("语言_att_01_5"),
	def_p_per = TI18N("语言_att_01_2"),
	def_s_per = TI18N("语言_att_01_3"),
	toughness = TI18N("语言_att_01_23")
}

--羁绊技能类型
HeroConst.BondSkillType = {
    ebondskill        =   1, --羁绊技
    efitskill         =   2, --合体技
}
--支援技能
HeroConst.Support = {
    elfin = 1, --通灵兽
}
--评分
HeroConst.ScoreList = {
    [1] = "D",
    [2] = "C",
    [3] = "B",
    [4] = "A",
    [5] = "A+",
    [6] = "S-",
    [7] = "S",
    [8] = "S+",
    [9] = "SP",
    [10] = "UR",
}
HeroConst.Artiface_Gold_Type = {
    no_tip = 1,--非tip
    tip = 2,--tip
}

HeroConst.HeroQualityId = {
    mr = 11,--MR
    ur = 10,
    sp = 9,
}
HeroConst.HeroStarName = {
    [1] = string.format(TI18N("语言_c_6876"),1),
    [2] = string.format(TI18N("语言_c_6876"),2),
    [3] = string.format(TI18N("语言_c_6876"),3),
    [4] = string.format(TI18N("语言_c_6876"),4),
    [5] = string.format(TI18N("语言_c_6876"),5),
    [6] = string.format(TI18N("语言_c_6876"),6),
    [7] = string.format(TI18N("语言_c_6876"),7),
    [8] = string.format(TI18N("语言_c_6876"),8),
    [9] = string.format(TI18N("语言_c_6876"),9),
    [10] = string.format(TI18N("语言_c_6876"),10),
    [11] = string.format(TI18N("语言_c_6876"),11),
    [12] = string.format(TI18N("语言_c_6876"),12),
    [13] = string.format(TI18N("语言_c_6876"),13),
    [14] = string.format(TI18N("语言_c_6876"),14),
    [15] = string.format(TI18N("语言_c_6876"),15),
    [16] = TI18N("语言_c_7577"),
    [17] = TI18N("语言_c_7979"),
    [18] = string.format(TI18N("语言_c_6876"),18),
}