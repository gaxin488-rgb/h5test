
RollerInfoMainWindow = RollerInfoMainWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()

function RollerInfoMainWindow:__init()
    self.is_full_screen = true
	self.win_type = WinType.Full
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.tab_list = {}
    self.layout_name = "roller/roller_info_mian_window"
	self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("prohibitor", "prohibitor"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("prohibited_scroll", "prohibited_scroll"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("ninja_treasure/ninja_treasure", "ninja_treasure"), type = ResourcesType.plist},
	}
    self.tab_name = {
        [1] = TI18N("语言_c_6903"),
        [2] = TI18N("语言_cit_01_6"),
        [3] = TI18N("语言_c_7200"),
    }
end

function RollerInfoMainWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		-- self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_105",false), LOADTEXT_TYPE)
		self.background:setScale(display.getMaxScale())
	end
    self.close_btn = self.root_wnd:getChildByName("close_btn")
	local main_panel = self.root_wnd:getChildByName("main_container")
    self.bottom_bg = main_panel:getChildByName("bottom_bg")
    self.container = main_panel:getChildByName("container")
    local tab_container = main_panel:getChildByName("tab_container")
    self.tab_container = tab_container
    for i = 1, 3 do
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        local tab = {}
        local select_bg = tab_btn:getChildByName("select_bg")
        select_bg:setVisible(false)
        local normal_img = tab_btn:getChildByName("normal_img")
        local select_img = tab_btn:getChildByName("select_img")
        select_img:setVisible(false)
        local label = tab_btn:getChildByName("label")
        label:setString(self.tab_name[i])
        local red_point = tab_btn:getChildByName("red_point")
        red_point:setVisible(false)
        tab.btn = tab_btn
        tab.index = i
        tab.normal_img = normal_img
        tab.select_img = select_img
        tab.select_bg = select_bg
        tab.label = label
        tab.red_point = red_point
        self.tab_list[i] = tab
    end

    self.player_info_panel = PlayerInfoPanel.new()
    main_panel:addChild(self.player_info_panel)
    local top_y = display.getTop()
    self.player_info_panel:setPositionY(top_y)
    self:adaptationScreen()
end

function RollerInfoMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop()
    local bottom_y = display.getBottom()
    self.bottom_bg:setPositionY(bottom_y)
    self.tab_container:setPositionY(bottom_y+5)
    self.close_btn:setPositionY(bottom_y+150)
end

function RollerInfoMainWindow:openRootWnd(index,id)
    self.id = id
    self:changeTab(index)
    self:updateItemListRedStatus()
end

function RollerInfoMainWindow:register_event()
	registerButtonEventListener(self.close_btn, function ()
        controller:openRollerInfoWindow(false)
	end, true, 2)

    for i = 1, 3, 1 do
        registerButtonEventListener(self.tab_list[i].btn, function ()
            self:changeTab(i)
        end, true, 2)
    end

    self:addGlobalEvent(RollerEvent.Update_Roller_Event, function()
        self:updateItemListRedStatus()
    end)

    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code, data_list)
        self:updateItemListRedStatus()
    end)
    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code, data_list)
        self:updateItemListRedStatus()
    end)
    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, data_list)
        self:updateItemListRedStatus()
    end)
end

function RollerInfoMainWindow:updateItemListRedStatus()
    local red_1 = model:checkUpGradeStatusByRollerId(self.id)
    local red_2 = model:checkUpStarStatusByRollerId(self.id)
    local red_3 = model:checkUpFengyinStatusByRollerId(self.id)
    self.tab_list[1].red_point:setVisible(red_1)
    self.tab_list[2].red_point:setVisible(red_2)
    self.tab_list[3].red_point:setVisible(red_3)
end

function RollerInfoMainWindow:changeTab(index)
    if self.select_btn and self.select_btn.index == index then return end
    if self.select_btn then 
        self.select_btn.select_bg:setVisible(false)
        self.select_btn.select_img:setVisible(false)
        self.select_btn.normal_img:setVisible(true)
        self.select_btn.label:setTextColor(cc.c4b(255,255,255,255))
        self.select_btn.label:enableOutline(cc.c4b(0x00,0x00,0x00,0xff), 2)
    end

    self.select_btn = self.tab_list[index]
    if self.select_btn then 
        self.select_btn.select_bg:setVisible(true)
        self.select_btn.select_img:setVisible(true)
        self.select_btn.normal_img:setVisible(false)
        self.select_btn.label:setTextColor(cc.c4b(0xf5,0xd2,0x69,0xff))
        self.select_btn.label:enableOutline(cc.c4b(0x18,0x01,0x01,0xff),2)
    end

    if index == 1 then
        if not self.roller_info_strength_panel then
            self.roller_info_strength_panel = RollerInfoStrengthPanel.new()
            self.roller_info_strength_panel:setData(self.id)
            self.container:addChild(self.roller_info_strength_panel)
        end
        if self.roller_info_strength_panel then
            self.roller_info_strength_panel:setVisibleStatus(true)
        end
        if self.roller_info_upstar_panel then
            self.roller_info_upstar_panel:setVisibleStatus(false)
        end
        if self.roller_info_fengyin_panel then
            self.roller_info_fengyin_panel:setVisibleStatus(false)
        end
    elseif index == 2 then
        if not self.roller_info_upstar_panel then
            self.roller_info_upstar_panel = RollerInfoUpstarPanel.new()
            self.roller_info_upstar_panel:setData(self.id)
            self.container:addChild(self.roller_info_upstar_panel)
        end
        if self.roller_info_upstar_panel then
            self.roller_info_upstar_panel:setVisibleStatus(true)
        end

        if self.roller_info_strength_panel then
            self.roller_info_strength_panel:setVisibleStatus(false)
        end
        if self.roller_info_fengyin_panel then
            self.roller_info_fengyin_panel:setVisibleStatus(false)
        end
    elseif index == 3 then
        if not self.roller_info_fengyin_panel then
            self.roller_info_fengyin_panel = RollerInfoFengyinPanel.new()
            self.roller_info_fengyin_panel:setData(self.id)
            self.container:addChild(self.roller_info_fengyin_panel)
        end
        if self.roller_info_fengyin_panel then
            self.roller_info_fengyin_panel:setVisibleStatus(true)
        end
        if self.roller_info_strength_panel then
            self.roller_info_strength_panel:setVisibleStatus(false)
        end
        if self.roller_info_upstar_panel then
            self.roller_info_upstar_panel:setVisibleStatus(false)
        end
    end

end

function RollerInfoMainWindow:close_callback()
    model:mainEnterStatus()
    if self.roller_info_upstar_panel then
        self.roller_info_upstar_panel:DeleteMe()
        self.roller_info_upstar_panel = nil
    end
    if self.roller_info_fengyin_panel and self.roller_info_fengyin_panel.DeleteMe then
        self.roller_info_fengyin_panel:DeleteMe()
        self.roller_info_fengyin_panel = nil
    end
    if self.roller_info_strength_panel then
        self.roller_info_strength_panel:DeleteMe()
        self.roller_info_strength_panel = nil
    end
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
	controller:openRollerInfoWindow(false)
end