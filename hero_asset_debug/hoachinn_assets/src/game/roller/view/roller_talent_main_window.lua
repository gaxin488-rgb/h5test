--****************

--****************
RollerTalentMainWindow = RollerTalentMainWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local table_insert = table.insert

function RollerTalentMainWindow:__init()
    self.is_full_screen = true
	self.win_type = WinType.Full
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.tab_list = {}
    self.square_list = {}
    self.talent_item_list = {}
    self.layout_name = "roller/roller_talent_mian_window"
	self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("prohibitor", "prohibitor"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("prohibited_scroll", "scroll_talent"), type = ResourcesType.plist}
	}
    self.tab_name = {
        [1] = TI18N("语言_c_7234"),
        [2] = TI18N("语言_c_7235"),
        [3] = TI18N("语言_c_7236"),
    }
    self.tab_color = {
        [1] = cc.c4b(0xff, 0xf1, 0xce, 0xff),
        [2] = cc.c4b(0xff, 0xcf, 0x72, 0xff),
        [3] = cc.c4b(0xff, 0x46, 0x28, 0xff),
    }
end

function RollerTalentMainWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end
	local main_panel = self.root_wnd:getChildByName("main_container")
    commonOpenActionLeftMove(main_panel)
    
    self.close_btn = main_panel:getChildByName("close_btn")

    self.img_title = main_panel:getChildByName("img_title")
    self.tiel = main_panel:getChildByName("tiel")
    self.tiel:setString(TI18N("语言_c_7211"))

    self.bottom_bg = main_panel:getChildByName("bottom_bg")
    self.aoyi_scroller = main_panel:getChildByName("aoyi_scroller")
    self.help_btn = main_panel:getChildByName("help_btn")
    self.item_icon = main_panel:getChildByName("icon")
    self.icon_count = main_panel:getChildByName("icon_count")
    self.add_btn = main_panel:getChildByName("add_btn")
    self.restet_btn = main_panel:getChildByName("restet_btn")
    self.restet_btn:getChildByName("label"):setString(TI18N("语言_c_6528"))
    self.roller_btn = main_panel:getChildByName("roller_btn")
    self.roller_label = self.roller_btn:getChildByName("label")
    self.opne_condition = main_panel:getChildByName("opne_condition")
    self.opne_condition:setString("")

    for i = 1, 3, 1 do
        local tab_btn = main_panel:getChildByName("roller_"..i)
        local tab = {}
        local select_bg = tab_btn:getChildByName("select_img")
        select_bg:setVisible(false)
        local label = tab_btn:getChildByName("label")
        label:setString(self.tab_name[i])
        label:setTextColor(self.tab_color[i])
        local lock_panel = tab_btn:getChildByName("lock_panel")
        -- local red_point = tab_btn:getChildByName("red_point")
        -- red_point:setVisible(false)
        tab.btn = tab_btn
        tab.lock_panel = lock_panel
        tab.index = i
        tab.select_bg = select_bg
        tab.label = label
        -- tab.red_point = red_point
        self.tab_list[i] = tab
    end

    self.collect_label = createRichLabel(22, cc.c4b(0xff, 0xff, 0xff, 0xff), cc.p(0.5, 0), cc.p(360, 305))
    main_panel:addChild(self.collect_label)
    self.collect_label:setString(TI18N("语言_c_7217"))
    self.high_collect_label = createRichLabel(22, cc.c4b(0xff, 0xff, 0xff, 0xff), cc.p(0.5, 0), cc.p(360, 277))
    main_panel:addChild(self.high_collect_label)
    self.high_collect_label:setString(TI18N("语言_c_7218"))

    self.power_label = main_panel:getChildByName("power_label")
    self.power_label:setString("")
    
    -- self:adaptationScreen()
    for i = 1, 9, 1 do
        for j = 1, 9, 1 do
            local layer = ccui.Layout:create()
            layer:setAnchorPoint(cc.p(0, 0))
            layer:setContentSize(cc.size(77,77))
            self.aoyi_scroller:addChild(layer)
            -- local img = createSprite(PathTool.getResFrame("scroll_talent", "scroll_skill_icon_1"), 38, 38, layer, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
            -- local label = createRichLabel(20, cc.c4b(0xff, 0xff, 0xff, 0xff), cc.p(0.5, 0.5), cc.p(38, 38))
            -- layer:addChild(label)
            -- label:setString(string.format("<div fontcolor=#ffffff outline=2,#000000>%s*%s</div>",i,j))
            layer:setPositionY((i-1)*77)
            layer:setPositionX((j-1)*77)
            layer.init_pos = cc.p((j-1)*77, (i-1)*77)
            self.square_list[i.."_"..j] = layer
        end
    end

    self.player_info_panel = PlayerInfoPanel.new()
    main_panel:addChild(self.player_info_panel)
    local top_y = display.getTop(main_panel)
    self.player_info_panel:setPositionY(top_y)
    self.img_title:setPositionY(top_y-23)
    self.tiel:setPositionY(top_y-69)

end

-- function RollerTalentMainWindow:adaptationScreen()
--     --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
--     local top_y = display.getTop(self.mainContainer)
--     local bottom_y = display.getBottom(self.mainContainer)
--     self.bottom_bg:setPositionY(bottom_y)
--     self.tab_container:setPositionY(bottom_y+5)
--     self.close_btn:setPositionY(bottom_y+150) 64
-- end

function RollerTalentMainWindow:openRootWnd(index,id)
    for i = 1, 3, 1 do
        local lock_status,tips = controller:getModel():getTalentOpenCondition(i)
        if lock_status then
            self.tab_list[i].lock_panel:setVisible(false)
        else
            self.tab_list[i].lock_panel:setVisible(true)
        end
    end
    index = index or 1
    self:changeTab(index)
    self:setTips(index)
    self:updateItemListRedStatus()
end

function RollerTalentMainWindow:setTips(index)
    local step,lv = controller:getModel():getNowTalentStepLv()
    self.roller_label:setString(string.format(TI18N("语言_c_7208"), step,lv))
    self.roller_btn:loadTexture(PathTool.getResFrame("scroll_talent",RollerConst.TalentIcon[step]), LOADTEXT_TYPE_PLIST)

    local active_lv,active_high_lv = controller:getModel():getActiveTotalTalentLvAndHighLvByIndex(index)
    local total_lv,total_high_lv = controller:getModel():getTotalTalentLvAndHighLvByIndex(index)
    self.collect_label:setString(string.format(TI18N("语言_c_7217"),active_high_lv,total_high_lv) )
    self.high_collect_label:setString(string.format(TI18N("语言_c_7218"),active_lv,total_lv))

    local base_cfg = Config.ProhibitedScrollData.data_get_constant["scroll_talent_consume"].val
    local item_cfg =  Config.ItemData.data_get_data(base_cfg)
    loadSpriteTexture(self.item_icon, PathTool.getItemRes(item_cfg.icon), LOADTEXT_TYPE) 
    local own_num = BackpackController:getInstance():getModel():getItemNumByBid(base_cfg)
    self.icon_count:setString(own_num)

    local power = controller:getModel():getTalentPower()
    self.power_label:setString(MoneyTool.moneyFormat(power))

    local talent_data = controller:getModel():getTalentData()
    local num = tableLen(talent_data)
    if num > 0 then
        if not self.roller_btn.btn_eff then
            self.roller_btn.btn_eff = createEffectSpine("E50104", cc.p(56, 56), cc.p(0.5, 0.5), true, "action1")
            self.roller_btn:addChild(self.roller_btn.btn_eff)
        end
        self.roller_btn.btn_eff:setVisible(true)
    else
        if self.roller_btn.btn_eff then
            self.roller_btn.btn_eff:setVisible(false)
        end
    end
end

function RollerTalentMainWindow:register_event()
    if self.help_btn then
        self.help_btn:addTouchEventListener(function( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                local cfg = Config.ProhibitedScrollData.data_get_func_show[5]
                MainuiController:getInstance():openCommonExplainView(true, cfg)
            end
        end)
    end
	registerButtonEventListener(self.close_btn, function ()
		controller:openRollerTalentMainWindow(false)
	end, true, 2)
	registerButtonEventListener(self.roller_btn, function ()
		controller:openRollerTalentPreviewWindow(true,1)
	end, true, 2)
	registerButtonEventListener(self.add_btn, function ()
        local base_cfg = Config.ProhibitedScrollData.data_get_constant["scroll_talent_consume"].val
        local item_cfg =  Config.ItemData.data_get_data(base_cfg)
        BackpackController:getInstance():openTipsSource(true, item_cfg)
	end, true, 2)
    for i = 1, 3, 1 do
        registerButtonEventListener(self.tab_list[i].btn, function ()
            self:changeTab(i)
            self:setTips(i)
        end, true, 2)
    end
    registerButtonEventListener(self.restet_btn, function ()
        local nowtime = GameNet:getInstance():getTime()
        local reset_time = controller:getModel():getTalentResetCdTime()
        if nowtime < reset_time then
            message(TI18N("语言_s_3481"))
            return
        end
        local list = controller:getModel():getTalentData()
        if next(list) then
            controller:openRollerResetWindow(true,{type=2})
        else
            message(TI18N("语言_c_7219"))
        end
	end, true, 2)

    if not self.update_event then
        self.update_event = GlobalEvent:getInstance():Bind(RollerEvent.Roller_Talent_Active_Event,function()
            local index = 1
            if self.select_btn then
                index = self.select_btn.index 
            end
            self:setTips(index)

            for i = 1, 3, 1 do
                local lock_status = controller:getModel():getTalentOpenCondition(i)
                if lock_status then
                    self.tab_list[i].lock_panel:setVisible(false)
                else
                    self.tab_list[i].lock_panel:setVisible(true)
                end
            end
            self:updateItemListRedStatus()
        end)
    end
    
    if not self.update_all_event then
        self.update_all_event = GlobalEvent:getInstance():Bind(RollerEvent.Roller_Talent_Update_Event,function()
            local index = 1
            if self.select_btn then 
                index = self.select_btn.index
            end
            self:setTips(index)

            for i = 1, 3, 1 do
                local lock_status = controller:getModel():getTalentOpenCondition(i)
                if lock_status then
                    self.tab_list[i].lock_panel:setVisible(false)
                else
                    self.tab_list[i].lock_panel:setVisible(true)
                end
            end
            self:updateItemListRedStatus()
        end)
    end
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, temp_add)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
				self:updateItemListRedStatus()
            end
        end)
    end
    if not self.del_goods_event then
        self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code, temp_del)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
                self:updateItemListRedStatus()
            end
        end)
    end
    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, temp_list)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
				self:updateItemListRedStatus()
            end
        end)
    end
end

function RollerTalentMainWindow:updateItemListRedStatus()
    local red_1 = controller:getModel():checkTalentPageStatusByIndex(1)
    local red_2 = controller:getModel():checkTalentPageStatusByIndex(2)
    local red_3 = controller:getModel():checkTalentPageStatusByIndex(3)
    addRedPointToNodeByStatus(self.tab_list[1].btn, red_1, 10, 10)
    addRedPointToNodeByStatus(self.tab_list[2].btn, red_2, 10, 10)
    addRedPointToNodeByStatus(self.tab_list[3].btn, red_3, 10, 10)
end


function RollerTalentMainWindow:changeTab(index,force)
    if force then
    else
        if self.select_btn and self.select_btn.index == index then return end
    end
    if self.select_btn then 
        self.select_btn.select_bg:setVisible(false)
    end
    self.select_btn = self.tab_list[index]
    if self.select_btn then 
        self.select_btn.select_bg:setVisible(true)
    end
    -- [101] = {id=101, group=1, attrs={}, skill={739901}, cost={{17352,200}}, limit_cond={}, talent_quality=3, effect_icon="scroll_skill_icon_11", pos={{5,5}}},
    local list = {}
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_talent[index]
    for k, v in pairs(cfg) do
        table.insert(list,deepCopy(v))
    end
    local item_num = tableLen(list)
    for k, v in pairs(self.talent_item_list) do
        v:setVisible(false)
    end
    for i = 1, item_num do
        if not self.talent_item_list[i] then
            local item = RollerTalentItem.new()
            self.aoyi_scroller:addChild(item)
            self.talent_item_list[i] = item
        end
        self.talent_item_list[i]:setVisible(true)
        local data = list[i]
        self.talent_item_list[i]:setData(data)
        local pos = data.pos[1]
        -- print(vardump(pos))
        local posi = pos[1]
        local posj = pos[2]
        local layer = self.square_list[posi.."_"..posj]
        local layer_pos_x = layer:getPositionX() + 38
        local layer_pos_y = layer:getPositionY() + 38
        self.talent_item_list[i]:setPositionX(layer_pos_x)
        self.talent_item_list[i]:setPositionY(layer_pos_y)
    end
    local status,open_condition = controller:getModel():getTalentOpenCondition(index)
    if not status then
        self.collect_label:setVisible(false)
        self.high_collect_label:setVisible(false)
        self.opne_condition:setString(open_condition)
    else
        self.collect_label:setVisible(true)
        self.high_collect_label:setVisible(true)
        self.opne_condition:setString("")
    end
end

function RollerTalentMainWindow:close_callback()
    controller:getModel():mainEnterStatus()
    for k, v in pairs(self.talent_item_list) do
        v:DeleteMe()
    end
    self.talent_item_list = nil

	if self.player_info_panel then
		self.player_info_panel:DeleteMe()
		self.player_info_panel = nil
	end

	if self.add_goods_event then
		GlobalEvent:getInstance():UnBind(self.add_goods_event)
		self.add_goods_event = nil
	end
	if self.del_goods_event then
		GlobalEvent:getInstance():UnBind(self.del_goods_event)
		self.del_goods_event = nil
	end
	if self.modify_goods_event then
		GlobalEvent:getInstance():UnBind(self.modify_goods_event)
		self.modify_goods_event = nil
	end
	if self.update_event then
		GlobalEvent:getInstance():UnBind(self.update_event)
		self.update_event = nil
	end
	if self.update_all_event then
		GlobalEvent:getInstance():UnBind(self.update_all_event)
		self.update_all_event = nil
	end

	controller:openRollerTalentMainWindow(false)
end