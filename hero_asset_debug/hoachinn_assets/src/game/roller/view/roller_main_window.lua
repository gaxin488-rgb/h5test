--****************
--卷轴主界面
--****************
RollerMainWindow = RollerMainWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()
local table_insert = table.insert

function RollerMainWindow:__init()
    self.is_full_screen = true
	self.win_type = WinType.Full
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.tab_list = {}
    self.layout_name = "roller/roller_main_window"
	self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("prohibitor", "prohibitor"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("prohibited_scroll", "prohibited_scroll"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("ninja_treasure/ninja_treasure","ninja_treasure"), type = ResourcesType.plist },
	}
    self.tab_name = {
        [1] = TI18N("语言_c_7192"),
        [2] = TI18N("语言_c_329"),
        [3] = TI18N("语言_c_6931"),
        [4] = TI18N("语言_c_6932"),
    }
end

function RollerMainWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end
    self.close_btn = self.root_wnd:getChildByName("close_btn")
	local main_panel = self.root_wnd:getChildByName("main_container")
    self.mainContainer = main_panel
    commonOpenActionLeftMove(self.mainContainer)
    self.bottom_bg = main_panel:getChildByName("bottom_bg")
    self.container = main_panel:getChildByName("container")
    local tab_container = main_panel:getChildByName("tab_container")
    self.tab_container = tab_container

    for i = 1, 4 do
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        local tab = {}
        local select_bg = tab_btn:getChildByName("select_bg")
        select_bg:setVisible(false)
        local normal_img = tab_btn:getChildByName("normal_img")
        local select_img = tab_btn:getChildByName("select_img")
        select_img:setVisible(false)
        local label = tab_btn:getChildByName("label")
        setTextMaxWidth(label, 146, -20)
        label:setString(self.tab_name[i])
        local red_point = tab_btn:getChildByName("red_point")
        red_point:setVisible(false)

        tab.btn = tab_btn
        tab.select_bg = select_bg
        tab.normal_img = normal_img
        tab.select_img = select_img
        tab.label = label
        tab.red_point = red_point
        tab_btn.index = i
        self.tab_list[i] = tab
    end

    self.player_info_panel = PlayerInfoPanel.new()
    main_panel:addChild(self.player_info_panel)
    local top_y = display.getTop(self.mainContainer)
    self.player_info_panel:setPositionY(top_y)

    self:adaptationScreen()

    local sys_ctrl = SysController:getInstance()
    if sys_ctrl:newCheckProtocalIsCanRequest(26) then
        controller:sender20800()
        controller:sender20820()
        sys_ctrl:setProtocalIsCanRequest(26)
    end
end

function RollerMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.mainContainer)
    local bottom_y = display.getBottom(self.mainContainer)
    self.bottom_bg:setPositionY(bottom_y)
    self.tab_container:setPositionY(bottom_y+5)
    self.close_btn:setPositionY(bottom_y+150)
end

function RollerMainWindow:openRootWnd(index,setting)
    self.select_index = index or 1
    self:setData()
    self:updateItemListRedStatus()
    if setting and setting.show_rule then
        controller:openRollerGameplayDescriptionWindow(true)
    end
end

function RollerMainWindow:setData()
    self:changeTab(self.select_index)
end

function RollerMainWindow:register_event()
	registerButtonEventListener(self.close_btn, function ()
		controller:openRollerMainWindow(false)
	end, true, 2)

    for i = 1, 4, 1 do
        registerButtonEventListener(self.tab_list[i].btn, function ()
            self:changeTab(i)
        end, true, 1)
    end

    -- self:addGlobalEvent(RollerEvent.Roller_GetTujianPoint_Event, function()
    --     self:updateItemListRedStatus()
    -- end)
    self:addGlobalEvent(RollerEvent.UpdateRollerLibraryRedStatus, function()
        self:updateItemListRedStatus()
    end)
    self:addGlobalEvent(RollerEvent.Update_Roller_Event, function()
        self:updateItemListRedStatus()
    end)
    self:addGlobalEvent(RollerEvent.UpdateSummonData, function()
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

function RollerMainWindow:updateItemListRedStatus()
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll
    local red_2 = false
    for i, v in pairs(cfg) do
        local roller_id = v.id
        local roller_data = model:getRollerDataById(roller_id)
        if roller_data then
            local _is_upgrade = model:checkUpGradeStatusByRollerId(roller_id)
            if _is_upgrade then
                red_2 = true
                break
            end
            local _is_upstar = model:checkUpStarStatusByRollerId(roller_id)
            if _is_upstar then
                red_2 = true
                break
            end
            local _is_upfengyin = model:checkUpFengyinStatusByRollerId(roller_id)
            if _is_upfengyin then
                red_2 = true
                break
            end
        else
            local _is_act = model:checkActiveStatusById(roller_id)
            if _is_act then
                red_2 = true
                break
            end
        end
    end
    self.tab_list[1].red_point:setVisible(red_2)

    local red_1 = model:getRollerLibraryRedPoint()
    self.tab_list[2].red_point:setVisible(red_1)

    local red_4 = model:getRollerChoujiangRedStatus()
    self.tab_list[4].red_point:setVisible(red_4)
    -- local red_3 = false
    -- local talent_open = model:checkTalentCondition()
    -- if talent_open then
    --     local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_talent
    --     for k, v in pairs(cfg) do
    --         local _list = v
    --         for key, val in pairs(_list) do
    --             local id = val.id
    --             local _si_talent = model:checkTalentActiveStatusById(id)
    --             if _si_talent then
    --                 red_3 = true
    --                 break
    --             end
    --         end
    --     end
    -- end
    -- if red_3 then
    --     self.tab_list[2].red_point:setVisible(true)
    --     return
    -- end
end

function RollerMainWindow:changeTab(index)
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

    self.select_index = index
    if index == 1 then
        if not self.roller_list_panel then
            self.roller_list_panel = RollerListPanel.new()
            self.container:addChild(self.roller_list_panel)
        end
        self.roller_list_panel:setVisibleStatus(true)

        if self.roller_tujian_panel then
            self.roller_tujian_panel:setVisibleStatus(false)
        end
        if self.roller_fenjie_panel then
            self.roller_fenjie_panel:setVisibleStatus(false)
        end
        if self.roller_luckdraw then
            self.roller_luckdraw:setVisibleStatus(false)
        end
    elseif index == 2 then
        if not self.roller_tujian_panel then
            self.roller_tujian_panel = RollerTujianNewPanel.new()
            self.container:addChild(self.roller_tujian_panel)
        end
        self.roller_tujian_panel:setVisibleStatus(true)

        if self.roller_list_panel then
            self.roller_list_panel:setVisibleStatus(false)
        end
        if self.roller_fenjie_panel then
            self.roller_fenjie_panel:setVisibleStatus(false)
        end
        if self.roller_luckdraw then
            self.roller_luckdraw:setVisibleStatus(false)
        end
    elseif index == 3 then
        if not self.roller_fenjie_panel then
            self.roller_fenjie_panel = RollerFenjiePanel.new()
            self.container:addChild(self.roller_fenjie_panel)
        end
        self.roller_fenjie_panel:setVisibleStatus(true)

        if self.roller_tujian_panel then
            self.roller_tujian_panel:setVisibleStatus(false)
        end
        if self.roller_list_panel then
            self.roller_list_panel:setVisibleStatus(false)
        end
        if self.roller_luckdraw then
            self.roller_luckdraw:setVisibleStatus(false)
        end
    elseif index == 4 then
        if not self.roller_luckdraw then
            self.roller_luckdraw = RollerLuckdraw.new()
            self.container:addChild(self.roller_luckdraw)
        end
        self.roller_luckdraw:setVisibleStatus(true)

        if self.roller_fenjie_panel then
            self.roller_fenjie_panel:setVisibleStatus(false)
        end
        if self.roller_tujian_panel then
            self.roller_tujian_panel:setVisibleStatus(false)
        end
        if self.roller_list_panel then
            self.roller_list_panel:setVisibleStatus(false)
        end
    end
end

function RollerMainWindow:close_callback()
    model:mainEnterStatus()
    if self.player_info_panel then
        self.player_info_panel:DeleteMe()
        self.player_info_panel = nil
    end
    if self.roller_list_panel then
        self.roller_list_panel:DeleteMe()
        self.roller_list_panel = nil
    end
    if self.roller_tujian_panel then
        self.roller_tujian_panel:DeleteMe()
        self.roller_tujian_panel = nil
    end
    if self.roller_fenjie_panel then
        self.roller_fenjie_panel:DeleteMe()
        self.roller_fenjie_panel = nil
    end
    if self.roller_luckdraw then
        self.roller_luckdraw:DeleteMe()
        self.roller_luckdraw = nil
    end
	controller:openRollerMainWindow(false)
end