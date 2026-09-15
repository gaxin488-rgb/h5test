--****************
--禁器特权
--****************
RollerPrivilegeWindow = RollerPrivilegeWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local table_insert = table.insert

function RollerPrivilegeWindow:__init()
    self.is_full_screen = true
	self.win_type = WinType.Full
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.tab_list = {}
    self.layout_name = "roller/roller_privilege_window"
	self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("prohibited_scroll", "prohibited_scroll"), type = ResourcesType.plist}
	}
end

function RollerPrivilegeWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

    self.bottom_bg = self.root_wnd:getChildByName("bottom_bg")
    self.close_btn = self.root_wnd:getChildByName("close_btn")
    local bottom_y = display.getBottom()
    self.bottom_bg:setPositionY(bottom_y + 20)
    self.close_btn:setPositionY(bottom_y + 100)

	local main_panel = self.root_wnd:getChildByName("main_container")
    self.confirm_btn = main_panel:getChildByName("confirm_btn")
    self.btn_change_label = self.confirm_btn:getChildByName("label")
    
    self.title_bg = main_panel:getChildByName("title_bg")
	self.title_name = self.title_bg:getChildByName("title_name")
	self.title_name:setString(TI18N("语言_c_7368"))
	local top_y = display.getTop(main_panel)
	local bottom_y = display.getBottom(main_panel)
	local add_height = top_y - bottom_y - SCREEN_HEIGHT
	self.title_bg:setPositionY(top_y - 76)

    self.up_panel = main_panel:getChildByName("up_panel")
    local left_tips_icon = self.up_panel:getChildByName("left_tips_icon")
    local tip = self.up_panel:getChildByName("tip")
    tip:setString(TI18N("语言_c_6939"))
    local right_tips_icon = self.up_panel:getChildByName("right_tips_icon")
    setLeftRightImg(left_tips_icon,tip,right_tips_icon,20)
    self.desc_list = self.up_panel:getChildByName("desc_list")
    self.desc_scroller = createScrollView(self.desc_list:getContentSize().width, self.desc_list:getContentSize().height, 0, 0, self.desc_list, ccui.ScrollViewDir.vertical)
    self.desc = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0, 1), cc.p(5,0), 0, nil, 600)
    self.desc_scroller:addChild(self.desc)
    self.plan_list = self.up_panel:getChildByName("plan_list")
    controller:sender20836()
    
    self.act_txt = self.up_panel:getChildByName("act_txt")
    self.act_txt:setVisible(false)

    self.player_info_panel = PlayerInfoPanel.new()
    main_panel:addChild(self.player_info_panel)
    local top_y = display.getTop(self.mainContainer)
    self.player_info_panel:setPositionY(top_y)

end

function RollerPrivilegeWindow:openRootWnd()
    self:setData()
end

function RollerPrivilegeWindow:setData()
    local const_cfg = Config.ProhibitedScrollData.data_get_constant
    local desc = const_cfg.privilege_ui_text.desc
    self.desc:setString(desc)
    local desc_height =  self.desc:getContentSize().height
    local sc_height = math.max(desc_height, 170)
    self.desc_scroller:setInnerContainerSize(cc.size(610, sc_height))
    self.desc:setPositionY(sc_height)
    local get_immediately = const_cfg.privilege_reward.val
    self.cell_data_list = get_immediately
    self:createCostScroll(#get_immediately)
    self:updateStatus()
end

function RollerPrivilegeWindow:updateStatus()
    local vip_data = controller:getModel():getRollerPrivilegeData()
    if vip_data then
        local buy_time = vip_data.buy_time
        if buy_time and buy_time > 0 then
            self.confirm_btn:setVisible(false)
            local last_day = Config.ProhibitedScrollData.data_get_constant.privilege_day.val
            local end_time = buy_time
            local start_time = buy_time + (last_day-1) * 86400
            local start_day = TimeTool.getMD2(start_time)
            local end_day = TimeTool.getMD2(end_time)
            local str = string.format(TI18N("语言_c_6940"),end_day,start_day) --"特权已激活\n"..end_day.."-"..start_day
            self.act_txt:setString(str)
            self.act_txt:setVisible(true)
        else
            local chargeId = Config.ProhibitedScrollData.data_get_constant.privilege_recharge_id.val
            local cdata = Config.ChargeData.data_charge_data[chargeId]
            -- local val = 198
            -- if cdata then
            --     val = GetMoneyNum(cdata,"val")
            -- end
            local price = GetMoneyNumForSDK("val",chargeId)
            self.btn_change_label:setString(price)--(string.format(TI18N("语言_c_4440"),val))
            self.confirm_btn:setVisible(true)
            self.act_txt:setVisible(false)
        end
    else
        local chargeId = Config.ProhibitedScrollData.data_get_constant.privilege_recharge_id.val
        local cdata = Config.ChargeData.data_charge_data[chargeId]
        -- local val = 198
        -- if cdata then
        --     val = GetMoneyNum(cdata,"val")
        -- end
        local price = GetMoneyNumForSDK("val",chargeId)
        self.btn_change_label:setString(price)--(string.format(TI18N("语言_c_4440"),val))
        self.confirm_btn:setVisible(true)
        self.act_txt:setVisible(false)
    end
end

function RollerPrivilegeWindow:createCostScroll(num)
    local _width =(120 + 10) * num
    self.plan_list:setContentSize(cc.size(_width, 119))
    if self.item_scrollview == nil then
        local scroll_view_size = self.plan_list:getContentSize()
        local setting = {
            start_x = 0, -- 第一个单元的X起点
            space_x = 10, -- x方向的间隔
            start_y = 0, -- 第一个单元的Y起点
            space_y = 0, -- y方向的间隔
            item_width = 119, -- 单元的尺寸width
            item_height = 119, -- 单元的尺寸height
            row = 1, -- 行数，作用于水平滚动类型
            once_num = 1 -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.plan_list, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.item_scrollview:reloadData()
end

function RollerPrivilegeWindow:createNewCell(width, height)
    local cell = BackPackItem.new(false, true, false, 1, false, true)
    return cell
end
 --获取数据数量
function RollerPrivilegeWindow:numberOfCells()
    if not self.cell_data_list then return 0 end
    return #self.cell_data_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function RollerPrivilegeWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function RollerPrivilegeWindow:register_event()
	registerButtonEventListener(self.close_btn, function ()
		controller:openRollerPrivilegeWindow(false)
	end, true, 2)

	registerButtonEventListener(self.confirm_btn, function ()
        local chargeId = Config.ProhibitedScrollData.data_get_constant.privilege_recharge_id.val
        local cdata = Config.ChargeData.data_charge_data[chargeId]
        sdkOnPay(cdata.val, nil, cdata.id, cdata.name)
	end, true, 2)

    self:addGlobalEvent(RollerEvent.UpdatePrivilegeVipData, function(bag_code, data_list)
        self:updateStatus()
    end)
end

function RollerPrivilegeWindow:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.player_info_panel then
        self.player_info_panel:DeleteMe()
        self.player_info_panel = nil
    end
	controller:openRollerPrivilegeWindow(false)
end