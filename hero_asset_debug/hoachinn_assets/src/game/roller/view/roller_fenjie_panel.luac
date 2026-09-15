RollerFenjiePanel = class("RollerFenjiePanel", function()
    return ccui.Widget:create()
end)
local controller = RollerController:getInstance()
local string_format = string.format

function RollerFenjiePanel:ctor()  
	self:loadResListCompleted()
end
-- 资源加载完成
function RollerFenjiePanel:loadResListCompleted()
    self.fenjie_select_list = {}
	self:configUI()
	self:register_event()
	self._init_flag = true
    self:setData()
    self:changeSelectedTab(1)
end

function RollerFenjiePanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("roller/roller_fenjie"))
	self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)
	
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

    local main_container = self.root_wnd:getChildByName("main_container")
    self.help_btn = main_container:getChildByName("help_btn")

    --分解
	self.up_panel = main_container:getChildByName("up_panel")
    self.up_panel:setVisible(false)
	local right_tips_icon = self.up_panel:getChildByName("right_tips_icon")
	local left_tips_icon = self.up_panel:getChildByName("left_tips_icon")
	local tips = self.up_panel:getChildByName("tips")
	tips:setString(TI18N("语言_c_6929"))
    setLeftRightImg(left_tips_icon, tips, right_tips_icon, 20)
	self.plan_list = self.up_panel:getChildByName("plan_list")
	self.soul_btn = main_container:getChildByName("soul_btn")
	self.soul_btn:getChildByName("label"):setString(TI18N("语言_c_3252"))
	self.onekey_btn = main_container:getChildByName("onekey_btn")
	self.onekey_btn:getChildByName("label"):setString(TI18N("语言_c_6148"))
	self.cancel_btn = main_container:getChildByName("cancel_btn")
	self.cancel_btn:getChildByName("label"):setString(TI18N("语言_c_3253"))
    self.cancel_btn:setVisible(false)
    self.empty_icon = self.up_panel:getChildByName("empty_icon")
    self.empty_tips = self.empty_icon:getChildByName("tips")
    self.empty_tips:setString(TI18N("语言_c_7366"))
    setTextMaxWidth(self.empty_tips,640)
    self.empty_icon:setVisible(false)
	if self.item_scrollview == nil then
        local scroll_view_size = self.plan_list:getContentSize()
        local setting = {
            start_x = 3, -- 第一个单元的X起点
            space_x = 5, -- x方向的间隔
            start_y = 0, -- 第一个单元的Y起点
            space_y = 5, -- y方向的间隔
            item_width = 129, -- 单元的尺寸width
            item_height = 129, -- 单元的尺寸height
            col = 5,
            once_num = 1 -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.plan_list, cc.p(0, 0), ScrollViewDir.vertical,ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell) -- 创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells) -- 获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) -- 更新cell
    end
    --碎片背包
    self.bag_panel = main_container:getChildByName("bag_panel")
    self.bag_panel:setVisible(false)
    local right_tips_icon = self.bag_panel:getChildByName("right_tips_icon")
	local left_tips_icon = self.bag_panel:getChildByName("left_tips_icon")
    local tips = self.bag_panel:getChildByName("tips")
	tips:setString(TI18N("语言_c_6928"))
    setLeftRightImg(left_tips_icon, tips, right_tips_icon, 20)
    self.bag_list = self.bag_panel:getChildByName("plan_list")

    local scroll_view_size = self.bag_list:getContentSize()
    local setting = {
        item_class = BackPackItem,       -- 单元类
        start_x = 3,                     -- 第一个单元的X起点
        space_x = 15,                    -- x方向的间隔
        start_y = 10,                    -- 第一个单元的Y起点
        space_y = 15,                    -- y方向的间隔
        item_width = 119,                -- 单元的尺寸width
        item_height = 119,               -- 单元的尺寸height
        col = 5,                         -- 列数，作用于垂直滚动类型
        scale = 1,
        need_dynamic = true
    }
    self.bag_item_scrollview = CommonScrollViewLayout.new(self.bag_list, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.bag_item_scrollview:addEndCallBack(function()
        local list = self.bag_item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)

    -- 顶部标签页
    self.top_tab_list = {}
	local tab_container = main_container:getChildByName("tab_container")
    local tab_name_list = {
        [1] = TI18N("语言_c_6931"),
        [2] = TI18N("语言_c_3215"),
    }
    for i=1,2 do
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.unselect_bg:setVisible(true)
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            object.lable = tab_btn:getChildByName("title")
            object.lable:setTextColor(cc.c4b(0x92, 0xb1, 0xdc, 0xff))
            object.lable:enableOutline(cc.c4b(0x34, 0x4c, 0x5f, 0xff), 2)
			setTextMaxWidth(object.lable,135,-10)
            object.lable:setString(tab_name_list[i])
            object.lable:setScale(1)
            object.tab_btn = tab_btn
            object.index = i
            self.top_tab_list[i] = object
        end
    end
end

function RollerFenjiePanel:createNewCell(width, height)
    local cell = RollerFenjieItem.new()
    cell:addCallBack(function()
        self:onCellTouched(cell)
    end)
    return cell
end
function RollerFenjiePanel:numberOfCells()
    if not self.cell_data_list then
        return 0
    end
    return #self.cell_data_list
end
function RollerFenjiePanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then
        return
    end
    cell:setData(cell_data)
    cell:setExtendData(self.fenjie_select_list)
end
function RollerFenjiePanel:onCellTouched(cell)
    local data = cell:getData()
    if data then
        local id = data.id
        self.fenjie_select_list[id] = data
    end
    self:checkShowCancelBtn()
end
function RollerFenjiePanel:checkShowCancelBtn()
    for k, v in pairs(self.fenjie_select_list) do
        if v and v.num > 0 then
            self.cancel_btn:setVisible(true)
            return
        end
    end
    self.cancel_btn:setVisible(false)
end
function RollerFenjiePanel:register_event(  )
	if self.help_btn then
        self.help_btn:addTouchEventListener(function( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				local cfg = Config.ProhibitedScrollData.data_get_constant["decompose_desc"]
                local obj = {
                    [1] = { id=1, title=TI18N("语言_c_4152"), desc=cfg.desc or "" },
                }
                MainuiController:getInstance():openCommonExplainView(true, obj)
            end
        end)
    end

    for i,tab_btn in pairs(self.top_tab_list) do
    	registerButtonEventListener(tab_btn.tab_btn, function()
	        self:changeSelectedTab(tab_btn.index)
	    end,false, 3)
    end
    registerButtonEventListener(self.onekey_btn, function()
        self:clickFenjieBtn()
    end,true)
    --一键分解
    registerButtonEventListener(self.soul_btn, function()
        self:clickOneKeyBtn()
    end,true)
    --取消放入
    registerButtonEventListener(self.cancel_btn, function()
        self:cancelClick()
    end,true)

    if not self.update_selelct_event then
        self.update_selelct_event = GlobalEvent:getInstance():Bind(JinqiEvent.JinqiFenjieSelectNumEvent,function(data)
            local item_id = data.item_id
            local id = data.id
            local num = data.num
            self.fenjie_select_list[id] = {id=id,item_id=item_id,num=num}
            self.item_scrollview:reloadData()
            if #self.cell_data_list > 0 then
                -- commonShowEmptyIcon(self.item_scrollview, false)
                self.empty_icon:setVisible(false)
            else
                self.empty_icon:setVisible(true)
                -- commonShowEmptyIcon(self.item_scrollview, true, {text = TI18N("语言_c_6992")})
            end
        end)
    end

    --分解成功
    if not self.fenjie_event then
        self.fenjie_event = GlobalEvent:getInstance():Bind(RollerEvent.RollerFenjieSuccessEvent,function()
            self.fenjie_select_list = {}
            self:setData()
            self.cancel_btn:setVisible(false)
        end)
    end

    -- 物品增加
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, temp_add)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
				self:setData()
            end
        end)
    end
    -- 物品道具删除
    if not self.del_goods_event then
        self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code, temp_del)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
                self:setData()
            end
        end)
    end
    -- 物品道具改变
    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, temp_list)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
				self:setData()
            end
        end)
    end

end
--取消放入
function RollerFenjiePanel:cancelClick()
    self.fenjie_select_list = {}
    self.item_scrollview:reloadData()
    self:checkShowCancelBtn()
end
--一键分解指定品质的碎片
function RollerFenjiePanel:clickOneKeyBtn()
    if next(self.cell_data_list) == nil then
        message(TI18N("语言_c_6956"))
        return
    end
    local pinzhi = Config.ProhibitedScrollData.data_get_constant.decomposition_quality.val[1]
    for k, v in pairs(self.cell_data_list) do
        local quality = v.quality
        local id = v.id
        local item_id = v.base_id
        local num = v.quantity
        if table.indexof(pinzhi,quality) then
            self.fenjie_select_list[id] = {id=id,num=num,item_id=item_id}
        end
    end
    self.item_scrollview:reloadData()
    self:checkShowCancelBtn()
end

function RollerFenjiePanel:clickFenjieBtn()
    if not next(self.fenjie_select_list) then
        message(TI18N("语言_c_6930"))
    else
        local list = {}
        for k, v in pairs(self.fenjie_select_list) do
            if v.num > 0 then
                local a = {}
                a.id = v.item_id
                a.num = v.num
                if list[a.id] then
                    list[a.id].num = list[a.id].num + a.num
                else
                    list[a.id] = a
                end
            end
        end
        local _list = {}
        for k, v in pairs(list) do
            table.insert(_list,v)
        end
        if not next(_list) then
            message(TI18N("语言_c_6930"))
            return
        end
        controller:openRollerFenjiePreviewWindow(true,_list)
    end
end

function RollerFenjiePanel:changeSelectedTab( index )
	if self.tab_object ~= nil and self.tab_object.index == index then return end

    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object.lable:setTextColor(cc.c4b(0x92, 0xb1, 0xdc, 0xff))
        self.tab_object.lable:enableOutline(cc.c4b(0x34, 0x4c, 0x5f, 0xff), 2)
        self.tab_object = nil
    end
    self.tab_object = self.top_tab_list[index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        self.tab_object.lable:setTextColor(cc.c4b(0xf8, 0xef, 0x76, 0xff))
        self.tab_object.lable:enableOutline(cc.c4b(0x5c, 0x27, 0x05, 0xff), 2)
    end

	if index == 1 then
        self.bag_panel:setVisible(true)
        self.up_panel:setVisible(false)
        self.soul_btn:setVisible(false)
	    self.onekey_btn:setVisible(false)
	    self.cancel_btn:setVisible(false)
	elseif index == 2 then
        self.bag_panel:setVisible(false)
        self.up_panel:setVisible(true)
        self.soul_btn:setVisible(true)
	    self.onekey_btn:setVisible(true)
	    self:checkShowCancelBtn()
	end
end

function RollerFenjiePanel:setData()
    --背包数据
    self.treasure_list = {}
    self.cell_data_list = {}
    local data =  BackpackController:getInstance():getModel():getAllBackPackArray(BackPackConst.item_tab_type.HERO)

    local fenjie_cfg = Config.ProhibitedScrollData.data_get_decompose

    for k, v in pairs(data) do
        local item_id = v.config.id
        if v.config and v.config.type and v.config.type == BackPackConst.item_type.ROLLER_CHIP then
            local config = v.config
            local list = {}
            list.id = v.id
            list.bid = 0 
            list.base_id = config.id
            list.quantity = v.quantity
            list.quality = v.quality
            list.config = config
            table.insert(self.treasure_list,list)
            local rolle_id = controller:getModel():getRollerIdByChipId(item_id)
            local roller_max_star = controller:getModel():getMaxStarById(rolle_id)
            local roller_data = controller:getModel():getRollerDataById(rolle_id)
            if roller_data and roller_data.star >= roller_max_star and fenjie_cfg[config.id] then -- and fenjie_cfg[config.id]
                table.insert(self.cell_data_list,list)
            end

        end
    end

    local sort_func = SortTools.tableUpperSorter({"quality","id"})
    local sort_func_low = SortTools.tableLowerSorter({"quality"})
    table.sort(self.treasure_list,sort_func)
    table.sort(self.cell_data_list,sort_func_low)
    self.bag_item_scrollview:setData(self.treasure_list)
    
    self.item_scrollview:reloadData()
    if #self.cell_data_list > 0 then
        self.empty_icon:setVisible(false)
    else
        self.empty_icon:setVisible(true)
    end

end

function RollerFenjiePanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

function RollerFenjiePanel:DeleteMe()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.bag_item_scrollview then
        self.bag_item_scrollview:DeleteMe()
        self.bag_item_scrollview = nil
    end
    if self.update_selelct_event then
        GlobalEvent:getInstance():UnBind(self.update_selelct_event)
        self.update_selelct_event = nil
    end
    if self.fenjie_event then
        GlobalEvent:getInstance():UnBind(self.fenjie_event)
        self.fenjie_event = nil
    end
    if self.modify_goods_event then
        GlobalEvent:getInstance():UnBind(self.modify_goods_event)
        self.modify_goods_event = nil
    end
    if self.add_goods_event then
        GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
    end
    if self.del_goods_event then
        GlobalEvent:getInstance():UnBind(self.del_goods_event)
        self.del_goods_event = nil
    end
	self:removeAllChildren()
    self:removeFromParent()
end

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
RollerFenjieItem = class("RollerFenjieItem", function() 
	return ccui.Layout:create()
end)

function RollerFenjieItem:ctor(click, scale, effect, is_show_tips, swallow_touch)
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("roller/roller_fenjie_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)

	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width/2, self.size.height/2)
	self:addChild(self.root_wnd)

	self.main_container = self.root_wnd:getChildByName("main_container")
	self.item_node = self.main_container:getChildByName("item_node")
    self.select_btn = self.main_container:getChildByName("select_btn")
    self.select_btn:setSwallowTouches(false)
	self.dele_btn = self.main_container:getChildByName("dele_btn")
	self.dele_btn:setVisible(false)
	self.select_num_bg = self.main_container:getChildByName("select_num_bg")
	self.select_num = self.select_num_bg:getChildByName("select_num")
	self.select_num_bg:setVisible(false)

    if not self.item then
        self.item = BackPackItem.new(false, false, false, 1)
        self.item_node:addChild(self.item)
    end

	self:registerEvent()
end

function RollerFenjieItem:addCallBack(callback)
	self.callback = callback
end

function RollerFenjieItem:setData(data)
	self.data = data
    self.num = 0
	-- local item_id = self.data.id
    -- local num = self.data.num
    self.item:setData(self.data)
end
function RollerFenjieItem:setExtendData(data)
	for k, v in pairs(data) do
        if v.id == self.data.id then
            self.num = v.num
            break
        end
    end

    self.select_num:setString(self.num)
    self.select_num:setScale(1)
    local width = self.select_num:getContentSize().width
    local height = self.select_num:getContentSize().height
    self.select_num_bg:setContentSize(cc.size(math.max(width+10,33), self.select_num_bg:getContentSize().height))
    self.select_num:setPositionX(math.max(width+10,33)/2-2)

    if self.num <= 0 then
        self.select_num_bg:setVisible(false)
        self.dele_btn:setVisible(false)
    else
        self.select_num_bg:setVisible(true)
        self.dele_btn:setVisible(true)
    end
end

function RollerFenjieItem:getData()
	return self.send_data or {}
end

function RollerFenjieItem:registerEvent()
    self.select_btn:addTouchEventListener(function(sender, event_type)
        customClickAction_2(sender, event_type,1)
        if event_type == ccui.TouchEventType.began then
            self.is_click_btn = false --标志只点一次btn
            self.dele_btn:setTouchEnabled(false)
            local sequence_action = cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function() 
                self:startTimeTicket()
            end))
            self.sequence_action = self.select_btn:runAction(sequence_action)
            self.sequence_action:setTag(1)
        elseif event_type == ccui.TouchEventType.moved then

        elseif event_type == ccui.TouchEventType.canceled then
            self.dele_btn:setTouchEnabled(true)
            self:clearTimeTicket()
        elseif event_type == ccui.TouchEventType.ended then
            self.dele_btn:setTouchEnabled(true)
            self:clearTimeTicket()
            if not self.is_click_btn then
                playButtonSound2()
                self:onClickBtnAdd()
            end
            self.is_click_btn = false --标志只点一次btn
        end
    end)
    self.dele_btn:addTouchEventListener(function(sender, event_type)
        customClickAction_2(sender, event_type,1)
        if event_type == ccui.TouchEventType.began then
            self.is_click_btn1 = false --标志只点一次btn
            self.select_btn:setTouchEnabled(false)
            local sequence_action = cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function() 
                self:startTimeTicket1()
            end))
            self.sequence_action1 = self.dele_btn:runAction(sequence_action)
            self.sequence_action1:setTag(1)
        elseif event_type == ccui.TouchEventType.moved then
            
        elseif event_type == ccui.TouchEventType.canceled then
            self.select_btn:setTouchEnabled(true)
            self:clearTimeTicket1()
        elseif event_type == ccui.TouchEventType.ended then
            self.select_btn:setTouchEnabled(true)
            self:clearTimeTicket1()
            if not self.is_click_btn1 then
                playButtonSound2()
                self:onClickBtnMin()
            end
            self.is_click_btn1 = false --标志只点一次btn
        end
    end)
end

function RollerFenjieItem:onClickBtnMin()
    local item_id = self.data.id
    local own_num = self.data.quantity
    if own_num == 0 then
        self.num = 0
        return
    end
    self.num = self.num - 1
    if self.num < 0 then 
        self.num = 0
    end
    self.select_num:setString(self.num)
    self.select_num:setScale(1)
    local width = self.select_num:getContentSize().width
    local height = self.select_num:getContentSize().height
    self.select_num_bg:setContentSize(cc.size(math.max(width+10,33), self.select_num_bg:getContentSize().height))
    self.select_num:setPositionX(math.max(width+10,33)/2-2)

    if self.num <= 0 then
        self.select_num_bg:setVisible(false)
        self.dele_btn:setVisible(false)
    else
        self.select_num_bg:setVisible(true)
        self.dele_btn:setVisible(true)
    end
    local send_data = {}
    send_data.id = item_id --唯一id
    send_data.item_id = self.data.base_id --道具id
    send_data.num = self.num
    self.send_data = send_data
    if self.callback then
        self.callback()
    end
end

function RollerFenjieItem:onClickBtnAdd()
    local item_id = self.data.id
    local own_num = self.data.quantity
    if own_num == 0 then
        self.num = 0
        local item_config = Config.ItemData.data_get_data(item_id)
        if item_config then
            BackpackController:getInstance():openTipsSource(true, item_id)
        end
        return
    end
    self.num = self.num + 1
    if self.num > own_num then 
        self.num = own_num
        -- message(TI18N("语言_c_280"))
    end
    self.select_num:setString(self.num)
    self.select_num:setScale(1)
    local width = self.select_num:getContentSize().width
    local height = self.select_num:getContentSize().height
    self.select_num_bg:setContentSize(cc.size(math.max(width+10,33), self.select_num_bg:getContentSize().height))
    self.select_num:setPositionX(math.max(width+10,33)/2-2)
    if self.num <= 0 then
        self.select_num_bg:setVisible(false)
        self.dele_btn:setVisible(false)
    else
        self.select_num_bg:setVisible(true)
        self.dele_btn:setVisible(true)
    end
    local send_data = {}
    send_data.id = item_id
    send_data.item_id = self.data.base_id
    send_data.num = self.num
    self.send_data = send_data
    if self.callback then
        self.callback()
    end
end

--长按-
function RollerFenjieItem:startTimeTicket1()
    if self.time_ticket1 == nil then
        local _callback = function()
            self.is_click_btn1 = true
            self:onClickBtnMin()
        end
        self.time_ticket1 = GlobalTimeTicket:getInstance():add(_callback, 5 / display.DEFAULT_FPS)
    end
end
function RollerFenjieItem:clearTimeTicket1()
    if self.sequence_action1 then
        self.dele_btn:stopActionByTag(1)
        self.sequence_action1 = nil
    end
    if self.time_ticket1 ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket1)
        self.time_ticket1 = nil
    end
end 
--长按+
function RollerFenjieItem:startTimeTicket()
    if self.time_ticket == nil then
        local _callback = function()
            if self.data.quantity > 0 then
                RollerController:getInstance():openJinqiFenjieSelectNumWindow(true,self.data)
            else
                message(TI18N("语言_c_3781"))
            end
        end
        self.time_ticket = GlobalTimeTicket:getInstance():add(_callback, 5 / display.DEFAULT_FPS)
    end
end
function RollerFenjieItem:clearTimeTicket()
    if self.sequence_action then
        self.select_btn:stopActionByTag(1)
        self.sequence_action = nil
    end
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end 

function RollerFenjieItem:DeleteMe()
	self:removeAllChildren()
    self:removeFromParent()
end
