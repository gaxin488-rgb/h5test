-- --------------------------------------------------------------------
-- (必填, 创建模块的人员)
-- @description:
-- <br/>Create: 2018年11月14日
--
-- --------------------------------------------------------------------
HeroBagWindow = HeroBagWindow or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function HeroBagWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full
    self.layout_name = "hero/hero_bag_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("herobag","herobag"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_bag_bg", true), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_bag_bg_1", false), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_ur_nin", false), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_ur_tai", false), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("holy_starup","holy_starup"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("common","common_1"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("elfin","elfin_starup"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("pet","pet"), type = ResourcesType.plist },
		{ path = PathTool.getPlistImgForDownLoad("hero","special_hero"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("hero","ultra_hero"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("hero","mystery_hero"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("hero","txt_cn_ur_fusion"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("partnersummon", "partnersummon"), type = ResourcesType.plist },
    }

    --背包列表 结构
    --图鉴列表
    self.hero_bag_list = {}
    --拥有英雄列表
    self.dic_pokedex_info = {}
    --阵营
    self.select_camp = 0

    --是否要重置 切换页签用
    self.is_must_reset = true

    --按钮位置列表
    self.btn_pos_list = {}
end

function HeroBagWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_bag_bg", true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

    self.mainContainer = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.mainContainer , 1)  

    self.container = self.mainContainer:getChildByName("container")
    self.box_1 = self.mainContainer:getChildByName("box_1")
    if self.box_1 and not tolua.isnull(self.box_1) then
        self.box_1:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_bag_bg_1", false), LOADTEXT_TYPE)
    end

    self.no_vedio_image = self.container:getChildByName("no_vedio_image")
    self.no_vedio_label = self.container:getChildByName("no_vedio_label")
    self.no_vedio_image:setVisible(false)
    self.no_vedio_label:setVisible(false)
    self.no_vedio_label:setString(TI18N("语言_c_3043"))
    self.lay_scrollview = self.container:getChildByName("lay_scrollview")
    self.con_panel = self.container:getChildByName("con_panel")
    self.img_line = self.container:getChildByName("img_line")

    local tab_container = self.container:getChildByName("tab_container")
    local tab_btn_name = {
        [1] = TI18N("语言_c_1184"),
        [2] = TI18N("语言_c_329"),
        [3] = TI18N("语言_ite_6_td_1"),
        [4] = TI18N("语言_hol_pe_gi_01_5"),
    }
    local tab_btn_type = {
        [1] = HeroConst.BagTab.eBagHero,     --英雄
        [2] = HeroConst.BagTab.eBagPokedex,  --图书馆
        [3] = HeroConst.BagTab.eElfin,       --精灵
        [4] = HeroConst.BagTab.eHalidom,     --圣物
    }
    self.tab_btn_list = {}
    -- local _position_arr = {}
    -- local _size_arr = {}
    -- local _add_arr = {}
    for i=1,4 do
        local tab_btn = {}
        local item = tab_container:getChildByName("tab_btn_"..i)
        tab_btn.btn = item
        tab_btn.index = tab_btn_type[i]
        tab_btn.select_bg = item:getChildByName("select_img")
        tab_btn.select_bg:setVisible(false)
        tab_btn.title = item:getChildByName("label")
        tab_btn.title:getVirtualRenderer():setLineSpacing(-10)
        tab_btn.title:setTextColor(cc.c4b(249,238,208,255))
        tab_btn.title:enableOutline(cc.c4b(58,41,10,255), 2)
        tab_btn.title:setFontSize(24)
        tab_btn.title:setString(tab_btn_name[i])

        -- _position_arr[i] = item:getPositionX()
        -- _size_arr[i] = item:getContentSize()
        -- _add_arr[i] = 0
        -- if i == 3 then _add_arr[i] = 1 end
        tab_btn.red_point = item:getChildByName("red_point")
        tab_btn.red_point:setVisible(false)
        self.tab_btn_list[tab_btn.index] = tab_btn
    end
    -- 做自适应的一个尝试
    -- local _initW = 168
    -- local _initW = 168
    -- local _maxW = 200
    -- local _movex = 32
    -- local _moveW = 32
    -- for i=4,1,-1 do
    --     local item = self.tab_btn_list[tab_btn_type[i]].btn
    --     if item then
    --         if _add_arr[i] == 1 then
    --             local normal_img = item:getChildByName("normal_img")
    --             local select_img = item:getChildByName("select_img")
    --             normal_img:setContentSize(cc.size(190,50))
    --             select_img:setContentSize(cc.size(190,50))
    --             _size_arr[i].width = 198 -- _size_arr[i].width + _moveW
    --             -- _position_arr[i] = _position_arr[i] - 6 --(_movex*0.5)
    --             if i-1 > 1 then 
    --                 for b=1,i-1 do
    --                     _position_arr[b] = _position_arr[b] - 30 --_movex
    --                 end
    --             end
    --         end
    --         print("_position_arr",vardump(_position_arr))
    --         print("_size_arr",vardump(_size_arr))
    --         item:setPositionX(_position_arr[i])
    --         item:setContentSize(_size_arr[i])
    --         self.tab_btn_list[tab_btn_type[i]].title:setString(tab_btn_name[i])
    --     end
    -- end

    self.embattle_btn = self.container:getChildByName("embattle_btn")
    --筛选
    self.screen_panel = self.container:getChildByName("screen_panel")
    self.screen_panel:setVisible(false)
    self.screen_bg = self.screen_panel:getChildByName("screen_bg")
    self.camp_panel = self.screen_panel:getChildByName("camp_panel")
    self.camp_bg = self.camp_panel:getChildByName("camp_bg")
    self.new_camp_btn_list = {}
    self.new_camp_redpoint_list = {}
    self.new_camp_btn_list[0] = self.camp_panel:getChildByName("camp_btn0")
    self.new_camp_btn_list[1] = self.camp_panel:getChildByName("camp_btn1")
    self.new_camp_btn_list[2] = self.camp_panel:getChildByName("camp_btn2")
    self.new_camp_btn_list[3] = self.camp_panel:getChildByName("camp_btn3")
    self.new_camp_btn_list[4] = self.camp_panel:getChildByName("camp_btn4")
    self.new_camp_btn_list[5] = self.camp_panel:getChildByName("camp_btn5")
    self.new_camp_btn_list[7] = self.camp_panel:getChildByName("camp_btn7")
    self.camp_select = self.camp_panel:getChildByName("camp_select")
    local x, y = self.new_camp_btn_list[0]:getPosition()
    self.camp_select:setPosition(x - 0.5, y + 1)
    self.camp_btn_size = self.new_camp_btn_list[1]:getContentSize()
    
    self.career_panel = self.screen_panel:getChildByName("career_panel")
    self.career_btn_list = {}
    self.career_redpoint_list = {}
    self.career_btn_list[0] = self.career_panel:getChildByName("career_btn0")
    self.career_btn_list[1] = self.career_panel:getChildByName("career_btn1")
    self.career_btn_list[2] = self.career_panel:getChildByName("career_btn2")
    self.career_btn_list[3] = self.career_panel:getChildByName("career_btn3")
    self.career_btn_list[4] = self.career_panel:getChildByName("career_btn4")
    self.career_select = self.career_panel:getChildByName("career_select")
    local x, y = self.career_btn_list[0]:getPosition()
    self.career_select:setPosition(x - 0.5, y + 1)
    self.career_btn_size = self.career_btn_list[1]:getContentSize()

    self.other_panel = self.screen_panel:getChildByName("other_panel")
    self.other_btn_list = {}
    self.other_redpoint_list = {}
    self.other_btn_list[0] = self.other_panel:getChildByName("other_btn0")
    self.other_btn_list[1] = self.other_panel:getChildByName("other_btn1")
    self.other_btn_list[2] = self.other_panel:getChildByName("other_btn2")
    self.other_select = self.other_panel:getChildByName("other_select")
    local x, y = self.other_btn_list[0]:getPosition()
    self.other_select:setPosition(x - 0.5, y + 1)
    self.other_btn_size = self.other_btn_list[1]:getContentSize()

    self.all_btn = self.screen_panel:getChildByName("all_btn")
    self.all_red = self.screen_panel:getChildByName("all_red")
    self.all_red:setVisible(false)
    self.close_panel = self.screen_panel:getChildByName("close_panel")
    self:updateScreenPanel(false)

    self.item_buy_panel = self.container:getChildByName("item_buy_panel")
    --英雄数量
    self.hero_label = self.item_buy_panel:getChildByName("label")
    self.add_btn = self.item_buy_panel:getChildByName("add_btn")

    self.library_btn = self.container:getChildByName("library_btn")
    local library_btn_label = self.library_btn:getChildByName("label")
    if library_btn_label then
        library_btn_label:setString(TI18N("语言_c_6558"))
        setTextSpacing(library_btn_label)
    end
    self.library_btn.library_btn_label = library_btn_label

    self.treasure_btn = self.container:getChildByName("treasure_btn")
    local mid_btn_label = self.treasure_btn:getChildByName("label")
    if mid_btn_label then
        mid_btn_label:setString(TI18N("语言_c_6945"))
        setTextSpacing(mid_btn_label,-10)
    end
    self.treasure_btn.mid_btn_label = mid_btn_label
    self.treasure_btn:setVisible(false)
    self.skin_shop_btn = self.container:getChildByName("skin_shop_btn")
    self.skin_shop_btn:setVisible(false)
    local shop_btn_label = self.skin_shop_btn:getChildByName("label")
    if shop_btn_label then
        shop_btn_label:setString(TI18N("语言_c_3104"))
    end
    self.skin_shop_btn.shop_btn_label = shop_btn_label

    self.jump_btn = self.container:getChildByName("jump_btn")
    local jump_btn_label = self.jump_btn:getChildByName("label")
    if jump_btn_label then
        jump_btn_label:setString(TI18N("语言_cit_01_7"))
    end
    self:checkSkinShopBtnStatus()

    self:updateTabBtnStatus()

    
    if MAKELIFEBETTER_NEW then
        self.jump_btn:setVisible(false)
        for i,v in ipairs(self.tab_btn_list) do
            if i ~= 1 then
                v.btn:setVisible(false)
            end
        end
    end
end
--status true为展开 false未关闭
function HeroBagWindow:updateScreenPanel(status)
    if status == self.screen_status then return false end
    self.screen_status = status
    self.career_panel:setVisible(status)
    self.other_panel:setVisible(status)
    self.close_panel:setVisible(status)
    self.screen_bg:setVisible(status)
    self.camp_bg:setVisible(not status)
    self.all_btn:setRotation(status and 90 or -90)
    self.all_red:setPositionY(status and 209 or 55)
    self.all_btn:setPositionY(status and 189 or 35)
    if status then
        -- self.other_btn_list[1]:setVisible(model:getProsIsShield())
        -- local is_opne = KeyinController:getInstance():getModel():checkFunctionOpenStatus()
        -- if is_opne then
        --     local keyin_base_cfg = Config.PartnerEngravedData.data_constant
        --     local role_vo = RoleController:getInstance():getRoleVo()
        --     is_opne = role_vo.lev >= keyin_base_cfg.tab_order.val --到达指定等级后显示底部页签
        -- end
        -- self.other_btn_list[2]:setVisible(is_opne)
    end
end

function HeroBagWindow:register_event()
    registerButtonEventListener(self.embattle_btn, handler(self, self._onClickBtnEmbattle) ,true, 2)
    --tab_container
    for index, tab_btn in ipairs(self.tab_btn_list) do
       registerButtonEventListener(tab_btn.btn, function() self:changeTabIndex(tab_btn.index) end ,false, 2) 
    end

    registerButtonEventListener(self.jump_btn, function() 
        HeroController:getInstance():openHeroResetWindow(true,HeroConst.SacrificeType.eHeroFuse)
    end ,true, 2) 

    --阵营按钮
    for index, v in pairs(self.new_camp_btn_list) do
        registerButtonEventListener(v, function() self:_onClickBtnShowByIndex(index) end ,true, 2)
    end
    --职业按钮
    for index, v in pairs(self.career_btn_list) do
        registerButtonEventListener(v, function() self:_onClickCareerBtnIndex(index) end ,true, 2)
    end
    --功能按钮
    --[[for index, v in pairs(self.other_btn_list) do
        registerButtonEventListener(v, function() self:_onClickOtherBtnIndex(index) end ,true, 2)
    end]]
    registerButtonEventListener(self.add_btn, handler(self, self.onClickAddBtn) ,true, 2)

    registerButtonEventListener(self.library_btn, handler(self, self.onClickLibraryBtn) ,true, 2)

    registerButtonEventListener(self.skin_shop_btn, handler(self, self.onClickSkinShopBtn) ,true, 2)
    
    
    registerButtonEventListener(self.all_btn, function()
        self:updateScreenPanel(not self.screen_status)
    end ,true, 2)

    registerButtonEventListener(self.close_panel, function()
        self:updateScreenPanel(false)
    end ,true, 2)

    self:addGlobalEvent(HeroEvent.All_Hero_Detail_Info_Event, function(hero_vo)
        --检测一下红点
        --装备信息回来了..检查多一次吧
        HeroCalculate.checkAllHeroRedPoint()
    end)

    --更新英雄上限事件
    self:addGlobalEvent(HeroEvent.Buy_Hero_Max_Count_Event, function() self:updateHeroMaxInfo() end)
    
    --剧情布阵改变了
    self:addGlobalEvent(HeroEvent.Form_Drama_Event, function()
        self:updateEmbattleBtnRedPoint()
    end)    
    --新增英雄
    self:addGlobalEvent(HeroEvent.Hero_Data_Add, function()
        self.hero_bag_list = model:getAllHeroArray()
        self.is_must_reset = true
        self:updateHeroList(self.select_camp)
        self.is_must_reset = false
        self:updateEmbattleBtnRedPoint()
        self:updateHeroMaxInfo()
    end)

    --删除英雄
    self:addGlobalEvent(HeroEvent.Del_Hero_Event, function()
        self.hero_bag_list = model:getAllHeroArray()
        self.is_must_reset = true
        self:updateHeroList(self.select_camp)
        self.is_must_reset = false
        self:updateHeroMaxInfo()
    end)

    --英雄红点更新
    self:addGlobalEvent(HeroEvent.All_Hero_RedPoint_Event, function(status_data)
        self:updateHeroBagRedpoint(status_data)
        --需要刷新一下全部英雄
    end)

    --所有英雄基本信息事件
    self:addGlobalEvent(HeroEvent.All_Hero_Base_Info_Event, function(status_data)
        self.hero_bag_list = model:getAllHeroArray()
        self.is_must_reset = true
        self:updateHeroList(self.select_camp)
        self.is_must_reset = false
        self:updateEmbattleBtnRedPoint()
        self:updateHeroMaxInfo()
    end)

    -- 圣物红点
    self:addGlobalEvent(HalidomEvent.Update_Halidom_Red_Event, function(status_data)
        self:updateHeroBagHalidomRedStatus( true )
    end)

    -- 精灵红点
    self:addGlobalEvent(ElfinEvent.Update_Elfin_Red_Event, function(status_data)
        self:updateHeroBagElfinRedStatus( )
    end)

    --道具增加
    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
        if not self.list_view then return end
        if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
            for i,item in pairs(temp_add) do
                if item.base_id == model.upgrade_star_cost_id or item.base_id == model.upgrade_star_cost_id_2 then
                    self.list_view:resetCurrentItems()
                end
            end
        end
    end)
    --物品道具删除 判断红点
    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code,temp_add)
        if not self.list_view then return end
        if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
            for i,item in pairs(temp_add) do
                if item.base_id == model.upgrade_star_cost_id or item.base_id == model.upgrade_star_cost_id_2 then
                    self.list_view:resetCurrentItems()
                end
            end
        end
    end)
    --物品道具删除 判断红点
    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_add)
        if not self.list_view then return end
        if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
            for i,item in pairs(temp_add) do
                if item.base_id == model.upgrade_star_cost_id or item.base_id == model.upgrade_star_cost_id_2 then
                    self.list_view:resetCurrentItems()
                end
            end
        end
    end)

    --引导前给需要特殊处理界面抛事件
    self:addGlobalEvent(GuideEvent.Update_Guide_Open_Event, function()
        if self.select_btn and self.select_btn.index == HeroConst.BagTab.eBagHero and self.select_camp == 0 and self.list_view then
            self.list_view:resetCurrentItems()
        end
    end)

    -- 角色等级变化
    if self.role_vo == nil then
        self.role_vo = RoleController:getInstance():getRoleVo()
    end
    if not self.role_assets_event then
        if self.role_vo then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "lev" then
                    self:updateTabBtnStatus()
                    self:setLibraryBtnStatus()
                end
            end)
        end
    end

    if not self.role_lev_event and self.role_vo then
        self.role_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value) 
            if key == "lev" then 
                self:checkSkinShopBtnStatus()
            end
        end)
    end
    self:addGlobalEvent(HeroEvent.Get_Had_Hero_Star_Event, function(data)
        addRedPointToNodeByStatus(self.library_btn,model:getHeroRed())
        local btn = self.tab_btn_list[HeroConst.BagTab.eBagHero]
        btn.red_point:setVisible(self.is_redpoint or model:getHeroRed())
    end)
end
function HeroBagWindow:setLibraryBtnStatus(lev)
    local role_vo = RoleController:getInstance():getRoleVo()
    if not role_vo then return end
    local level_cfg = Config.PartnerData.data_partner_const.library_level
    if level_cfg then
        if level_cfg.val > role_vo.lev then
            setChildUnEnabled(true, self.library_btn)
            self.library_btn.library_btn_label:enableOutline(cc.c4b(58,41,10,255), 2)
        else
            setChildUnEnabled(false, self.library_btn)    
            self.library_btn.library_btn_label:enableOutline(cc.c4b(92,39,5,255), 2)
        end
    else
        setChildUnEnabled(false, self.library_btn)
    end
end

function HeroBagWindow:_onClickBtnClose()
    controller:openHeroBagWindow(false)
end

function HeroBagWindow:checkSkinShopBtnStatus()
    local role_vo = RoleController:getInstance():getRoleVo()
    if not role_vo then return end
    local limit_cfg = Config.ChargeMallData.data_const["skin_mall_lev"]
    if limit_cfg and limit_cfg.val > role_vo.lev then
        setChildUnEnabled(true, self.skin_shop_btn)
        self.skin_shop_btn.shop_btn_label:enableOutline(cc.c4b(58,41,10,255), 2)
    else
        setChildUnEnabled(false, self.skin_shop_btn)
        self.skin_shop_btn.shop_btn_label:enableOutline(cc.c4b(92,39,5,255), 2)
    end
end

function HeroBagWindow:onClickSkinShopBtn()
    local role_vo = RoleController:getInstance():getRoleVo()
    local limit_cfg = Config.ChargeMallData.data_const["skin_mall_lev"]
    if limit_cfg and limit_cfg.val > role_vo.lev then
        message(limit_cfg.desc)
        return
    end

    MallController:getInstance():openSkinShopWindow(true)
end

-- 打开布阵界面
function HeroBagWindow:_onClickBtnEmbattle()
    controller:openFormMainWindow(true)
end
--显示根据类型 0表示全部
function HeroBagWindow:_onClickBtnShowByIndex(index)
    if self.camp_select and self.new_camp_btn_list[index] then
        local x, y = self.new_camp_btn_list[index]:getPosition()
        self.camp_select:setPosition(x - 0.5, y + 1)
    end
    if self.select_btn then
        if self.select_btn.index == HeroConst.BagTab.eBagHero or self.select_btn.index == HeroConst.BagTab.eBagPokedex then
            self:updateHeroList(index,self.select_career,self.select_other)
        elseif self.select_btn.index == HeroConst.BagTab.eHalidom then
            if self.halidom_panel then
                self.halidom_panel:choseHalidomByCamp(index)
            end
        end
    end
end
--显示根据类型 0表示全部 职业
function HeroBagWindow:_onClickCareerBtnIndex(index)
    if self.career_select and self.career_btn_list[index] then
        local x, y = self.career_btn_list[index]:getPosition()
        self.career_select:setPosition(x - 0.5, y + 1)
    end
    if self.select_btn then
        if self.select_btn.index == HeroConst.BagTab.eBagHero or self.select_btn.index == HeroConst.BagTab.eBagPokedex then
            self:updateHeroList(self.select_camp,index,self.select_other)
        end
    end
end
--显示根据类型 0表示全部 功能
function HeroBagWindow:_onClickOtherBtnIndex(index)
    if self.other_select and self.other_btn_list[index] then
        local x, y = self.other_btn_list[index]:getPosition()
        self.other_select:setPosition(x - 0.5, y + 1)
    end
    if self.select_btn then
        if self.select_btn.index == HeroConst.BagTab.eBagHero or self.select_btn.index == HeroConst.BagTab.eBagPokedex then
            self:updateHeroList(self.select_camp,self.select_career,index)
        end
    end
    if index == 2 then
        local list = {}
        for k, v in pairs(model:getKeyinFirstRedList()) do
            local _list = {}
            _list.type = k
            _list.is_save = 1
            _list.msg = ""
            table.insert(list, _list)
        end
        ActionController:getInstance():sender16827(list)
    end
end

--加英雄数量
function HeroBagWindow:onClickAddBtn()
    local buy_num = model:getHeroBuyNum()
    local config = Config.PartnerData.data_partner_buy[buy_num + 1]
    if config then 
        local item_id = config.expend[1][1] or 3
        local count = config.expend[1][2] or 100
        local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
        local str = string_format(TI18N("语言_c_3105"), iconsrc, count, config.add_num)
        local call_back = function()
            controller:sender11009()
        end
        CommonAlert.show(str, TI18N("语言_c_63"), call_back, TI18N("语言_c_62"), nil, CommonAlert.type.rich)
    else
        message(TI18N("语言_c_94"))
    end
end

function HeroBagWindow:onClickLibraryBtn()
    local role_vo = RoleController:getInstance():getRoleVo()
    if not role_vo then return end
    local level_cfg = Config.PartnerData.data_partner_const.library_level
    if level_cfg and level_cfg.val > role_vo.lev then
        message(level_cfg.desc)
        return
    end
    HeroController:getInstance():openHeroLibraryMainWindow(true)
end

-- 刷新tab按钮锁定状态
function HeroBagWindow:updateTabBtnStatus(  )
        if not self.tab_btn_list then return end
    for index, tab_btn in ipairs(self.tab_btn_list) do
        local is_open = true
        if tab_btn.index == HeroConst.BagTab.eHalidom then
            is_open = HalidomController:getInstance():getModel():checkHalidomIsOpen(true)
        elseif tab_btn.index == HeroConst.BagTab.eElfin then
            is_open = ElfinController:getInstance():getModel():checkElfinIsOpen(true)
        end
        if tab_btn.btn then
            setChildUnEnabled( not is_open, tab_btn.btn)
        end
    end
end

function HeroBagWindow:updateTabBtnZOrder()
    if not self.tab_btn_list then return end
    for index, tab_btn in ipairs(self.tab_btn_list) do
        if tab_btn.btn then
            tab_btn.btn:setLocalZOrder(5 - index)
        end
    end
end

-- @index  1 表示英雄  2 表示 图鉴  3表示圣物
function HeroBagWindow:changeTabIndex(index)
    if self.select_btn and self.select_btn.index == index then return end

    if index == HeroConst.BagTab.eHalidom then -- 圣物需要判断是否开启
        if not HalidomController:getInstance():getModel():checkHalidomIsOpen() then
            return
        end
    elseif index == HeroConst.BagTab.eElfin then
        if not ElfinController:getInstance():getModel():checkElfinIsOpen() then
            return
        end
    end

    if self.select_btn then 
        self.select_btn.select_bg:setVisible(false)
        self.select_btn.title:setTextColor(cc.c4b(249,238,208,255))
        self.select_btn.title:enableOutline(cc.c4b(58,41,10,255), 2)
        self.select_btn.title:setFontSize(24)
    end
    
    --刷新一下按钮层级
    self:updateTabBtnZOrder()
    self.select_btn = self.tab_btn_list[index]
    if self.select_btn then 
        self.select_btn.select_bg:setVisible(true)
        self.select_btn.btn:setLocalZOrder(9)
        self.select_btn.title:setTextColor(cc.c4b(248,239,118,255))
        self.select_btn.title:enableOutline(cc.c4b(92,39,5,255), 2)
        self.select_btn.title:setFontSize(26)
    end
    if self.library_btn then
        self.library_btn:setVisible(false)
    end
    if self.jump_btn then
        self.jump_btn:setVisible(false)
    end
    -- if self.skin_shop_btn then
    --     self.skin_shop_btn:setVisible(false)
    -- end

    if index == HeroConst.BagTab.eBagHero then --英雄页签
        self.lay_scrollview:setVisible(true)
        self.con_panel:setVisible(false)
        self:setCampBtnPos(1)
        self.select_camp = 0
        self.select_career = 0
        self.select_other = 0
        self.item_buy_panel:setVisible(true)
        self:updateHeroMaxInfo()
        self.library_btn:setVisible(true)
        self.jump_btn:setVisible(true)
        -- self.skin_shop_btn:setVisible(true)
        local role_vo = RoleController:getInstance():getRoleVo()
        if not role_vo or role_vo.lev < 40 then
            self.all_btn:setVisible(false)
            self.camp_bg:setVisible(false)
        else
            self.all_btn:setVisible(true)
            self.camp_bg:setVisible(true)
        end
    elseif index == HeroConst.BagTab.eBagPokedex then --图鉴页签
        self.lay_scrollview:setVisible(true)
        self.con_panel:setVisible(false)
        self:setCampBtnPos(2)
        self.select_camp = 1 
        self.select_career = 0
        self.select_other = 0
        self.item_buy_panel:setVisible(false)
        local role_vo = RoleController:getInstance():getRoleVo()
        if not role_vo or role_vo.lev < 40 then
            self.all_btn:setVisible(false)
            self.camp_bg:setVisible(false)
        else
            self.all_btn:setVisible(true)
            self.camp_bg:setVisible(true)
        end       
    elseif index == HeroConst.BagTab.eHalidom then --圣物
        if not self.halidom_panel then
            if not HalidomMainPanel then
                require("game.halidom.view.halidom_main_panel")
            end
            self.halidom_panel = HalidomMainPanel.new(handler(self, self._onChangeSelectCamp),self.page_index)
            self.con_panel:addChild(self.halidom_panel)
        end
        if self.elfin_panel then
            self.elfin_panel:setVisible(false)
        end
        self.halidom_panel:setVisible(true)
        self.lay_scrollview:setVisible(false)
        self.con_panel:setVisible(true)
        self:setCampBtnPos(3)
        self.select_camp = self.sub_type or 1
        self.item_buy_panel:setVisible(false)

        self.no_vedio_image:setVisible(false)
        self.no_vedio_label:setVisible(false)
        self.all_btn:setVisible(false)
        self.camp_bg:setVisible(false)
    elseif index == HeroConst.BagTab.eElfin then --精灵
        if not self.elfin_panel then
            self.elfin_panel = ElfinMainPanel.new(self.sub_type)
            self.con_panel:addChild(self.elfin_panel)
        end
        if self.halidom_panel then
            self.halidom_panel:setVisible(false)
        end
        self.elfin_panel:setVisible(true)
        self.lay_scrollview:setVisible(false)
        self.con_panel:setVisible(true)
        self.item_buy_panel:setVisible(false)

        self.no_vedio_image:setVisible(false)
        self.no_vedio_label:setVisible(false)
    end
    if self.career_select and self.career_btn_list[self.select_career] then
        local x, y = self.career_btn_list[self.select_career]:getPosition()
        self.career_select:setPosition(x - 0.5, y + 1)
    end
    if self.other_select and self.other_btn_list[self.select_other] then
        local x, y = self.other_btn_list[self.select_other]:getPosition()
        self.other_select:setPosition(x - 0.5, y + 1)
    end
    self.img_line:setVisible(false)--(index ~= HeroConst.BagTab.eElfin)
    self.screen_panel:setVisible(index ~= HeroConst.BagTab.eElfin)
    
    self:updateHeroBagHalidomRedStatus()
    self:updateHeroBagElfinRedStatus()
    self.is_must_reset = true
    self:_onClickBtnShowByIndex(self.select_camp)
    self.is_must_reset = false
end

function HeroBagWindow:_onChangeSelectCamp( index )
    if self.camp_select and self.new_camp_btn_list[index] then
        local x, y = self.new_camp_btn_list[index]:getPosition()
        self.camp_select:setPosition(x - 0.5, y + 1)
    end
end

--更新tab红点
function HeroBagWindow:updateHeroBagRedpoint(status_data)
    if self.redpoint_status == nil then
        self.redpoint_status = {}
    end
    for i,data in pairs(status_data) do
        if data and data.bid then
            self.redpoint_status[data.bid] = data.status
        end
    end
    local is_redpoint = false
    for k, status in pairs(self.redpoint_status) do
        if status == true then
            is_redpoint = true 
            break
        end
    end
    if not is_redpoint then
        local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("features_shield")
        local featuresId = MainuiConst.FeaturesShield.Treasure
        if table.indexof(nohideIds,featuresId) then
            is_redpoint = TreasureController:getInstance():getModel():getTreasureRed()
        end
    end
    --目前只有英雄红点
    local btn = self.tab_btn_list[HeroConst.BagTab.eBagHero]
    if btn then
        self.is_redpoint = is_redpoint
        btn.red_point:setVisible(is_redpoint or model:getHeroRed())
    end

    if self.select_btn and self.select_btn.index == HeroConst.BagTab.eBagHero  then
        --刷新一下当前红点
        if self.list_view then
            self.list_view:resetCurrentItems()
        end
    end
end

-- 更新圣物的红点(包括tab和阵营)
function HeroBagWindow:updateHeroBagHalidomRedStatus( force )
    local halidom_model = HalidomController:getInstance():getModel()
    local red_status = halidom_model:getHalidomRedStatus()
    -- tab红点
    local btn = self.tab_btn_list[HeroConst.BagTab.eHalidom]
    if btn then
        btn.red_point:setVisible(red_status)
    end
    -- 阵营红点 
    if self.select_btn and self.select_btn.index == HeroConst.BagTab.eHalidom then
        if force or not self.halidom_camp_red or next(self.halidom_camp_red) == nil then
            self.halidom_camp_red = {}
            for k,hData in pairs(Config.HalidomData.data_base) do
                local camp_btn = self.new_camp_btn_list[hData.camp]
                if camp_btn then
                    local camp_red_status = false
                    if halidom_model:checkHalidomIsUnlock(hData.id) then
                        local halidom_vo = halidom_model:getHalidomDataById(hData.id)
                        if halidom_vo and next(halidom_vo) ~= nil then
                            if halidom_vo:getRedStatusByType(HalidomConst.Red_Type.Lvup) or halidom_vo:getRedStatusByType(HalidomConst.Red_Type.Step) then
                                camp_red_status = true
                            end
                        end
                    elseif halidom_model:checkHalidomIsCanUnlock(hData.id) then
                        camp_red_status  = true
                    end
                    self.halidom_camp_red[hData.camp] = camp_red_status
                    self:setRedPointcamp(hData.camp, camp_red_status)
                end
            end
        else
            if self.halidom_camp_red then
                for k,camp_btn in pairs(self.new_camp_btn_list) do
                    if k ~= 0 then
                        local camp_red_status = self.halidom_camp_red[k]
                        self:setRedPointcamp(k, camp_red_status)
                    end
                    
                end
            end
        end
    else
        for k,camp_btn in pairs(self.new_camp_btn_list) do
            if k ~= 0 then
                self:setRedPointcamp(k, false)
            end
        end
    end
end

-- 精灵tab按钮红点
function HeroBagWindow:updateHeroBagElfinRedStatus(  )
    local elfin_model = ElfinController:getInstance():getModel()
    local red_status = elfin_model:getElfinRedStatus()
    local btn = self.tab_btn_list[HeroConst.BagTab.eElfin]
    if btn then
        btn.red_point:setVisible(red_status)
    end
end

function HeroBagWindow:setRedPointcamp(camp, is_visible)
    if is_visible then
        if self.new_camp_redpoint_list[camp] == nil then
            local camp_btn = self.new_camp_btn_list[camp]
            local x, y = camp_btn:getPosition()
            red_res = PathTool.getResFrame("mainui","mainui_1009")
            self.new_camp_redpoint_list[camp] = createSprite(red_res,0,0,self.camp_panel,cc.p(1,1),LOADTEXT_TYPE_PLIST)
            self.new_camp_redpoint_list[camp]:setPosition(x + self.camp_btn_size.width*0.5, y+self.camp_btn_size.height*0.5)
        end
        self.new_camp_redpoint_list[camp]:setVisible(is_visible)
    else
        if self.new_camp_redpoint_list[camp] then
            self.new_camp_redpoint_list[camp]:setVisible(false)
        end
    end
end

function HeroBagWindow:setRedPointCareer(career, is_visible)
    if is_visible then
        if self.career_redpoint_list[career] == nil then
            local camp_btn = self.career_btn_list[career]
            local x, y = camp_btn:getPosition()
            red_res = PathTool.getResFrame("mainui","mainui_1009")
            self.career_redpoint_list[career] = createSprite(red_res,0,0,self.career_panel,cc.p(1,1),LOADTEXT_TYPE_PLIST)
            self.career_redpoint_list[career]:setPosition(x + self.career_btn_size.width*0.5, y+self.career_btn_size.height*0.5)
        end
        self.career_redpoint_list[career]:setVisible(is_visible)
    else
        if self.career_redpoint_list[career] then
            self.v[career]:setVisible(false)
        end
    end
end

function HeroBagWindow:setRedPointOther(camp, is_visible)
    if is_visible then
        if self.other_redpoint_list[camp] == nil then
            local camp_btn = self.other_btn_list[camp]
            local x, y = camp_btn:getPosition()
            red_res = PathTool.getResFrame("mainui","mainui_1009")
            self.other_redpoint_list[camp] = createSprite(red_res,0,0,self.other_panel,cc.p(1,1),LOADTEXT_TYPE_PLIST)
            self.other_redpoint_list[camp]:setPosition(x + self.other_btn_size.width*0.5, y+self.other_btn_size.height*0.5)
        end
        self.other_redpoint_list[camp]:setVisible(is_visible)
    else
        if self.other_redpoint_list[camp] then
            self.other_redpoint_list[camp]:setVisible(false)
        end
    end
end

--更新出征按钮红点
function HeroBagWindow:updateEmbattleBtnRedPoint()
    if not model then return end
    local is_redpoint = false
    --目前只开了一队的数量..第二对不知道什么时候开. 如果开了第二对..那么这里的逻辑需要加上开启第二队伍的逻辑
    local open_team_count = 1
    local hallow_list = HallowsController:getInstance():getModel():getHallowsList() or {}
    local horo_list = model:getAllHeroArray()
    local dic_hallows = {} --标志神器被使用
    local dic_pos_list = model:getMyPosList() --如果以后多队伍的情况下会有超过5个
    local dic_hero_bid = {}
    for k,v in pairs(dic_pos_list) do
        if v.id then
            local hero_vo = model:getHeroById(v.id)
            if hero_vo and hero_vo.bid then
                dic_hero_bid[hero_vo.bid] = true
            end
        end
    end

    for i=1,open_team_count do
        local hollows_id = model.use_hallows_id or 0 --目前神器只有一个列表..等开了多队伍后要改成数组

        if hollows_id == 0 then --没穿戴神器  
            -- 判断有没有可用的神器
            for i,v in ipairs(hallow_list) do
                if v.id and dic_hallows[v.id] == nil then
                    is_redpoint = true
                    break
                end
            end
        else
            if hollows_id then
                dic_hallows[hollows_id] = true
            end
        end
        --判断有没有空位置 并且不能同名
        local list = model:getMyPosList(i)
        local count = #list
        if count < 5 then
            for j=1,horo_list:GetSize() do
                local hero_vo = horo_list:Get(j-1)
                if hero_vo and hero_vo.bid and dic_hero_bid[hero_vo.bid] == nil then
                    is_redpoint = true
                    break    
                end
            end
        end
    end

    addRedPointToNodeByStatus(self.embattle_btn, is_redpoint, -5, -30, nil ,2)
end

function HeroBagWindow:openRootWnd(index, sub_type,page_index)
    local index = index or HeroConst.BagTab.eBagHero
    self.sub_type = sub_type
    self.page_index = page_index
    if index == HeroConst.BagTab.eHalidom then -- 圣物需要判断是否已经开启，没开启则默认选中英雄分页
        local open_cfg = Config.HalidomData.data_const["halidom_open_lev"]
        local role_vo = RoleController:getInstance():getRoleVo()
        if not open_cfg or not role_vo or open_cfg.val > role_vo.lev then
            index = HeroConst.BagTab.eBagHero
        end
    elseif index == HeroConst.BagTab.eElfin then
        if not ElfinController:getInstance():getModel():checkElfinIsOpen(true) then
            index = HeroConst.BagTab.eBagHero
        end
    end
    --已拥有信息信息
    self.dic_had_hero_info = HeroController:getInstance():getModel():getHadHeroInfo()
    self:initHeroBagList()
    self:changeTabIndex(index)

    --检测一下红点
    HeroCalculate.checkAllHeroRedPoint()
    --布阵按钮的红点
    self:updateEmbattleBtnRedPoint()
    self:setLibraryBtnStatus()
    addRedPointToNodeByStatus(self.library_btn,model:getHeroRed(),15,10)
end

--初始化背包伙伴列表 
function HeroBagWindow:initHeroBagList()
    --英雄列表
    self.hero_bag_list = model:getAllHeroArray()
    --图书馆列表
    self.dic_pokedex_info = model:getHeroPokedexList()
end

function HeroBagWindow:updateHeroMaxInfo()
    if self.hero_label then
        local max, count = model:getHeroMaxCount()
        self.hero_label:setString(string_format("%s/%s", count, max))
    end
end

--设置种族按钮位置 根据按钮数量来设定位置
--@ btn_Type 按钮类型 1 有全部按钮类型  2 无全部按钮类型
function HeroBagWindow:setCampBtnPos(btn_Type)
    if self.btn_pos_list[btn_Type] == nil then
        self.btn_pos_list[btn_Type] = {}

        local offset = 20
        local width = 58 -- 按钮大小
        local count = 7
        -- if btn_Type == 1   then
        --     count = 6
        -- end
        
        local x = - (width * count + offset *(count -1)) * 0.5 + width * 0.5
        for i=1,count do
            -- self.btn_pos_list[btn_Type][i] = x + (i-1) * (width + offset)
            self.btn_pos_list[btn_Type][i] = 198 + (i-1) * (width + offset)
        end
    end
    if self.new_camp_btn_list[7] then
        self.new_camp_btn_list[7]:setVisible(true and model:checkSoulHeroIsOpen())
    end
    if btn_Type == 1  then
        self.new_camp_btn_list[0]:setVisible(true)
        for i=0, 6 do
            local x = self.btn_pos_list[btn_Type][i+1] or 0
            local camp = i == 6 and 7 or i
            self.new_camp_btn_list[camp]:setPositionX(x)
        end
    elseif btn_Type == 3  then --不显示异界类型
        self.new_camp_btn_list[0]:setVisible(false)
        if self.new_camp_btn_list[7] then
            self.new_camp_btn_list[7]:setVisible(false)
        end
        for i=0, 6 do
            local x = self.btn_pos_list[btn_Type][i+1] or 0
            local camp = i == 6 and 7 or i
            self.new_camp_btn_list[camp]:setPositionX(x)
        end
    else
        self.new_camp_btn_list[0]:setVisible(false)
        for i=1, 6 do
            local x = self.btn_pos_list[btn_Type][i + 1] or 0
            local camp = i == 6 and 7 or i
            self.new_camp_btn_list[camp]:setPositionX(x)
        end
    end
end


--创建英雄列表 
-- @select_camp 选中阵营
function HeroBagWindow:updateHeroList(select_camp,select_career,select_other)
    local select_camp = select_camp or self.select_camp or 1
    local select_career = select_career or self.select_career or 0
    local select_other = select_other or self.select_other or 0
    if not self.is_must_reset and select_camp == self.select_camp and select_career == self.select_career and select_other == self.select_other then 
        return
    end
    if not self.list_view then
        local scroll_view_size = cc.size(660,770)--(600,680)
        local setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 4,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 132,               -- 单元的尺寸width
            item_height = 136,              -- 单元的尺寸height
            delay = 1,
            -- row = 1,                        -- 行数，作用于水平滚动类型
            col = 5,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true
        }
        local size = self.lay_scrollview:getContentSize()
        self.list_view = CommonScrollViewSingleLayout.new(self.lay_scrollview, cc.p(size.width * 0.5, size.height * 0.5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0.5,0.5))

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    
    self.select_camp = select_camp
    self.select_career = select_career
    self.select_other = select_other
    local size = 0
    if self.select_btn and self.select_btn.index == HeroConst.BagTab.eBagPokedex then
        --图书馆
        local list = self.dic_pokedex_info[self.select_camp] or {}
        size = #list
        if size > 0 then
            self.show_list = {}
            for k, hero_vo in pairs(list) do
                if select_career == 0 or (select_career + 1 == hero_vo.type) then
                    local function_status = false
                    if select_other == 1 then--禁术
                        function_status = model:getProsIsVis(hero_vo)
                    elseif select_other == 2 then--刻印
                        function_status = KeyinController:getInstance():getModel():heroIsOpen(hero_vo)
                    end
                    if select_other == 0 or function_status then
                        table_insert(self.show_list, hero_vo)
                    end
                    -- vo:PushBack(hero_vo)
                end
            end
            -- self.show_list =list
        else
            self.show_list = {}
        end 
    else
        --英雄列表 (默认)
        local hero_array = self.hero_bag_list or Array.New()
        local form_list = {}
        local list = {}
        for j=1,hero_array:GetSize() do
            local hero_vo = hero_array:Get(j-1)
            if (select_camp == 0 or (select_camp == hero_vo.camp_type)) and (select_career == 0 or (select_career + 1 == hero_vo.type)) then
                local function_status = false
                if select_other == 1 then--禁术
                    function_status = model:getProsIsVis(hero_vo)
                elseif select_other == 2 then--刻印
                    function_status = KeyinController:getInstance():getModel():heroIsOpen(hero_vo)
                end
                if select_other == 0 or function_status then
                    if hero_vo.isFormDrama and hero_vo:isFormDrama() then
                        table_insert(form_list, hero_vo)
                    else
                        table_insert(list, hero_vo)
                    end
                end
                -- vo:PushBack(hero_vo)
            end
        end
        size = #list + #form_list
        if size > 0 then
            -- vo:UpperSortByParams("star", "power", "lev", "sort_order")
            -- local sort_func1 = SortTools.tableCommonSorter({{"star", true}, {"power", true}, {"lev", true}, {"sort_order", true}})
            local sort_func = SortTools.tableCommonSorter({{"star", true}, {"power", true}, {"lev", true}, {"sort_order", true}})
            table_sort(form_list, sort_func)
            table_sort(list, sort_func)
            local count = #form_list
            for i=count, 1, -1 do
                table_insert(list, 1, form_list[i])
            end
            self.show_list = list
        else
            self.show_list = {}
        end
    end
    self.list_view:reloadData()

    if size == 0 then
        -- self.no_vedio_image:setVisible(true)
        -- self.no_vedio_label:setVisible(true)
        self.no_vedio_image:setVisible(false)
        self.no_vedio_label:setVisible(false)
        return
    else
        self.no_vedio_image:setVisible(false)
        self.no_vedio_label:setVisible(false)
    end
end

function HeroBagWindow:selectHero(item, hero_vo)
    if not hero_vo  then return end
    if not item then return end
    local show_model_type = HeroConst.BagTab.eBagHero
    if self.select_btn then
        show_model_type = self.select_btn.index or HeroConst.BagTab.eBagHero
    end 
    --打开英雄信息ui
    HeroController:getInstance():openHeroMainInfoWindow(true, hero_vo, self.show_list, {show_model_type = show_model_type})
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroBagWindow:createNewCell(width, height)
    local cell = HeroExhibitionItem.new(1, true)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function HeroBagWindow:numberOfCells()
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function HeroBagWindow:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.show_list[index]
    if hero_vo then
        if self.select_btn then
            if self.select_btn.index == HeroConst.BagTab.eBagPokedex then
                --图书馆
                local dic_had_hero_info = HeroController:getInstance():getModel():getHadHeroInfo()
                local is_have
                if self.dic_had_hero_info[hero_vo.bid] and self.dic_had_hero_info[hero_vo.bid] >= hero_vo.star then
                    is_have = false
                else
                    is_have = true
                end

                cell:setHeadUnEnabled(is_have)
                if cell.partner_type then
                    setChildUnEnabled(is_have, cell.partner_type)
                end
                cell:showRedPoint(false)
                cell:showFightImg(false)
                cell.from_type = HeroConst.ExhibitionItemType.eBagPokedex
            elseif self.select_btn.index == HeroConst.BagTab.eBagHero then
                --英雄页签
                cell:setHeadUnEnabled(false)
                if cell.partner_type then
                    setChildUnEnabled(false, cell.partner_type)
                end
                -- if HeroCalculate.isCheckHeroRedPointByHeroVo(hero_vo) then
                    if hero_vo.star == 13 and hero_vo.star_step == 10 then
                        hero_vo.red_point[HeroConst.RedPointType.eRPStar] = nil
                    end
                    local is_redpoint = HeroCalculate.checkSingleHeroRedPoint(hero_vo)
                    cell:showRedPoint(is_redpoint, 10, 5)
                -- else
                --     cell:showRedPoint(false)
                -- end
                cell.from_type = HeroConst.ExhibitionItemType.eHeroBag

                if hero_vo:isFormDrama() then
                    cell:showFightImg(true)
                else
                    cell:showFightImg(false)
                end
            end
        end
        cell:setData(hero_vo)
    end

end

--点击cell .需要在 createNewCell 设置点击事件
function HeroBagWindow:onCellTouched(cell)
    local index = cell.index
    local hero_vo = self.show_list[index]
    if hero_vo then
        self:selectHero(cell, hero_vo)
    end
end


function HeroBagWindow:close_callback()
    if self.list_view then
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    if self.halidom_panel then
        self.halidom_panel:DeleteMe()
        self.halidom_panel = nil
    end
    if self.elfin_panel then
        self.elfin_panel:DeleteMe()
        self.elfin_panel = nil
    end
    if self.role_assets_event and self.role_vo then
        self.role_vo:UnBind(self.role_assets_event)
        self.role_assets_event = nil
    end
    if self.role_vo then
        if self.role_lev_event then
            self.role_vo:UnBind(self.role_lev_event)
            self.role_lev_event = nil
        end
    end
    if self.role_vo then
        self.role_vo = nil
    end
    controller:openHeroBagWindow(false)
end
