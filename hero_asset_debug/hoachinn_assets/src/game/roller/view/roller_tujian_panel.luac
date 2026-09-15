--**************************
--**************************
RollerTujianPanel = class("RollerTujianPanel", function()
    return ccui.Widget:create()
end)

local controller = RollerController:getInstance()
local model = controller:getModel()
local string_format = string.format

function RollerTujianPanel:ctor()  
	self:loadResListCompleted()
end
-- 资源加载完成
function RollerTujianPanel:loadResListCompleted()
    self.select_quality = nil
	self:configUI()
	self:register_event()
    self:setData()
end

function RollerTujianPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("roller/roller_tujian_panel"))
	self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)
	
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container

    local top_y = display.getTop(main_container)
    local bottom_y = display.getBottom(main_container)
	local add_height = top_y - bottom_y - SCREEN_HEIGHT

    self.help_btn = self.main_container:getChildByName("help_btn")
    self.help_btn:setPositionY(bottom_y + 215)

	self.up_panel = main_container:getChildByName("up_panel")
    self.up_panel:setPositionY(top_y - 190)

    self.title_bg = self.up_panel:getChildByName("title_bg")
    self.title_name = self.title_bg:getChildByName("title_name")
    self.title_name:setString(TI18N("语言_c_329"))
    self.talent_btn = self.up_panel:getChildByName("talent_btn")
    self.talent_btn.text_bg = self.talent_btn:getChildByName("text_bg")
    self.talent_btn.label = self.talent_btn:getChildByName("label")

    self.own_layer = self.up_panel:getChildByName("own_layer")
    self.own_icon = self.own_layer:getChildByName("icon")
    self.own_txt = self.own_layer:getChildByName("own_txt")
    self.power_label = self.up_panel:getChildByName("power_label")

    self.collect_label = createRichLabel(20, cc.c4b(0xff, 0xff, 0xff, 0xff), cc.p(0.5, 0), cc.p(360, 38))
    self.up_panel:addChild(self.collect_label)
    self.total_star_label = createRichLabel(20, cc.c4b(0xff, 0xff, 0xff, 0xff), cc.p(0.5, 1), cc.p(360, 38))
    self.up_panel:addChild(self.total_star_label)

	self.lis_bottom_bg = main_container:getChildByName("lis_bottom_bg")
    self.lis_bottom_bg:setPositionY(bottom_y + 270)
	self.quality_select_bg = main_container:getChildByName("quality_select_bg")
    self.quality_select_bg:setPositionY(bottom_y + 215)
	self.camp_panel = main_container:getChildByName("camp_panel")
    self.camp_panel:setPositionY(bottom_y + 215)
	self.new_camp_btn_list = {}
    self.new_camp_btn_list[0] = self.camp_panel:getChildByName("camp_btn0")
    self.new_camp_btn_list[1] = self.camp_panel:getChildByName("camp_btn1")
    self.new_camp_btn_list[2] = self.camp_panel:getChildByName("camp_btn2")
    self.new_camp_btn_list[3] = self.camp_panel:getChildByName("camp_btn3")
	self.camp_select = self.camp_panel:getChildByName("camp_select")

	self.plan_list = main_container:getChildByName("plan_list")
    local _list_size = self.plan_list:getContentSize()
    self.plan_list:setContentSize(cc.size(_list_size.width, _list_size.height+add_height))
	if self.item_scrollview == nil then
        local scroll_view_size = self.plan_list:getContentSize()
        local setting = {
            start_x = 30, -- 第一个单元的X起点
            space_x = 15, -- x方向的间隔
            start_y = 0, -- 第一个单元的Y起点
            space_y = 5, -- y方向的间隔
            item_width = 210, -- 单元的尺寸width
            item_height = 325, -- 单元的尺寸height
            col = 3,
            once_num = 1 -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.plan_list, cc.p(0, 0), ScrollViewDir.vertical,ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell) -- 创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells) -- 获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) -- 更新cell
    end

end

function RollerTujianPanel:createNewCell(width, height)
    local cell = RollerTujianItem.new()
    cell:addCallBack(function()
        self:onCellTouched(cell)
    end)
    return cell
end
function RollerTujianPanel:numberOfCells()
    if not self.cell_data_list then
        return 0
    end
    return #self.cell_data_list
end
function RollerTujianPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then
        return
    end
    cell:setData(cell_data)
    -- cell:setExtendData(self.fenjie_select_list)
end
function RollerTujianPanel:onCellTouched(cell)
    local data = cell:getData()
    if data then
        local id = data.id
        local roller_data = model:getRollerDataById(id)
        if roller_data then
            if roller_data.star_awards and next(roller_data.star_awards) then
                controller:sender20809(id)
            else
                message(TI18N("语言_c_2523"))
            end 
        -- else
        --     message("激活后可领取")
        end
    end
end

function RollerTujianPanel:register_event(  )
	if self.help_btn then
        self.help_btn:addTouchEventListener(function( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                local cfg = Config.ProhibitedScrollData.data_get_func_show[4]
                MainuiController:getInstance():openCommonExplainView(true, cfg)
            end
        end)
    end

    for index, v in pairs(self.new_camp_btn_list) do
        registerButtonEventListener(v, function() self:_onClickBtnShowByIndex(index) end ,true, 2)
    end

    registerButtonEventListener(self.talent_btn, function()
        local talent_cond = controller:getModel():checkTalentCondition()
        if talent_cond then
            controller:openRollerTalentMainWindow(true,1)
        else
            local base_cfg = Config.ProhibitedScrollData.data_get_constant["scroll_curse_open"]
            local val = base_cfg.val
            message(string.format(TI18N("语言_c_7238"), val))
        end
    end,true)

    if not self.update_event then
        self.update_event = GlobalEvent:getInstance():Bind(RollerEvent.Roller_GetTujianPoint_Event, function()
            self:updateList()
            self:updateTalentRedStatus()
            local talent_data = controller:getModel():getTalentData()
            local num = tableLen(talent_data)
            if num > 0 then
                if not self.talent_btn.btn_eff then
                    self.talent_btn.btn_eff = createEffectSpine("E50104", cc.p(56, 56), cc.p(0.5, 0.5), true, "action1")
                    self.talent_btn:addChild(self.talent_btn.btn_eff)
                end
                self.talent_btn.btn_eff:setVisible(true)
            else
                if self.talent_btn.btn_eff then
                    self.talent_btn.btn_eff:setVisible(false)
                end
            end

            local const_cfg = Config.ProhibitedScrollData.data_get_constant
            local money_id = const_cfg.scroll_talent_consume.val
            local money_cfg = Config.ItemData.data_get_data(money_id)
            local own_num = BackpackController:getInstance():getModel():getItemNumByBid(money_id)
            loadSpriteTexture(self.own_icon, PathTool.getItemRes(money_cfg.icon), LOADTEXT_TYPE) 
            self.own_txt:setString(own_num)
        end)
    end
    if not self.update_roller_event then
        self.update_roller_event = GlobalEvent:getInstance():Bind(RollerEvent.Update_Roller_Event, function()
            self:updateList()
            self:updateTalentRedStatus()
            local talent_data = controller:getModel():getTalentData()
            local num = tableLen(talent_data)
            if num > 0 then
                if not self.talent_btn.btn_eff then
                    self.talent_btn.btn_eff = createEffectSpine("E50104", cc.p(56, 56), cc.p(0.5, 0.5), true, "action1")
                    self.talent_btn:addChild(self.talent_btn.btn_eff)
                end
                self.talent_btn.btn_eff:setVisible(true)
            else
                if self.talent_btn.btn_eff then
                    self.talent_btn.btn_eff:setVisible(false)
                end
            end

            local const_cfg = Config.ProhibitedScrollData.data_get_constant
            local money_id = const_cfg.scroll_talent_consume.val
            local money_cfg = Config.ItemData.data_get_data(money_id)
            local own_num = BackpackController:getInstance():getModel():getItemNumByBid(money_id)
            loadSpriteTexture(self.own_icon, PathTool.getItemRes(money_cfg.icon), LOADTEXT_TYPE) 
            self.own_txt:setString(own_num)
        end)
    end

    if not self.update_talent_event then
        self.update_talent_event = GlobalEvent:getInstance():Bind(RollerEvent.Roller_Talent_Update_Event , function()
            local step,lv = controller:getModel():getNowTalentStepLv()
            self.talent_btn.label:setString(string.format(TI18N("语言_c_7208"), step,lv))

            local const_cfg = Config.ProhibitedScrollData.data_get_constant
            local money_id = const_cfg.scroll_talent_consume.val
            local money_cfg = Config.ItemData.data_get_data(money_id)
            local own_num = BackpackController:getInstance():getModel():getItemNumByBid(money_id)
            loadSpriteTexture(self.own_icon, PathTool.getItemRes(money_cfg.icon), LOADTEXT_TYPE) 
            self.own_txt:setString(own_num)

            local power = controller:getModel():getTalentPower()
            self.power_label:setString(MoneyTool.moneyFormat(power))
            self:updateTalentRedStatus()
            
            local talent_data = controller:getModel():getTalentData()
            local num = tableLen(talent_data)
            if num > 0 then
                if not self.talent_btn.btn_eff then
                    self.talent_btn.btn_eff = createEffectSpine("E50104", cc.p(56, 56), cc.p(0.5, 0.5), true, "action1")
                    self.talent_btn:addChild(self.talent_btn.btn_eff)
                end
                self.talent_btn.btn_eff:setVisible(true)
            else
                if self.talent_btn.btn_eff then
                    self.talent_btn.btn_eff:setVisible(false)
                end
            end
        end)
    end

    -- -- 物品道具删除
    -- if not self.del_goods_event then
    --     self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code, temp_del)
    --         if bag_code == BackPackConst.Bag_Code.BACKPACK then
    --             self:setData()
    --         end
    --     end)
    -- end
    -- -- 物品道具改变
    -- if not self.modify_goods_event then
    --     self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, temp_list)
    --         if bag_code == BackPackConst.Bag_Code.BACKPACK then
	-- 			self:setData()
    --         end
    --     end)
    -- end

end

function RollerTujianPanel:_onClickBtnShowByIndex(select_camp)
    if self.camp_select and self.new_camp_btn_list[select_camp] then
        local x, y = self.new_camp_btn_list[select_camp]:getPosition()
        self.camp_select:setPosition(x - 0.5, y + 1)
    end
    self.select_quality = select_camp
    self:updateList()
end

function RollerTujianPanel:setData()
    local step,lv = controller:getModel():getNowTalentStepLv()
    self.talent_btn.label:setString(string.format(TI18N("语言_c_7208"), step,lv))
    self.talent_btn:loadTexture(PathTool.getResFrame("scroll_talent",RollerConst.TalentIcon[step]), LOADTEXT_TYPE_PLIST)
    local talent_cond = controller:getModel():checkTalentCondition()
    if not talent_cond then
        setChildUnEnabled(true, self.talent_btn)
    else
        setChildUnEnabled(false, self.talent_btn)
    end

    local talent_data = controller:getModel():getTalentData()
    local num = tableLen(talent_data)
    if num > 0 then
        if not self.talent_btn.btn_eff then
            self.talent_btn.btn_eff = createEffectSpine("E50104", cc.p(56, 56), cc.p(0.5, 0.5), true, "action1")
            self.talent_btn:addChild(self.talent_btn.btn_eff)
        end
        self.talent_btn.btn_eff:setVisible(true)
    else
        if self.talent_btn.btn_eff then
            self.talent_btn.btn_eff:setVisible(false)
        end
    end

    local const_cfg = Config.ProhibitedScrollData.data_get_constant
    local money_id = const_cfg.scroll_talent_consume.val
    local money_cfg = Config.ItemData.data_get_data(money_id)
    local own_num = BackpackController:getInstance():getModel():getItemNumByBid(money_id)
    loadSpriteTexture(self.own_icon, PathTool.getItemRes(money_cfg.icon), LOADTEXT_TYPE) 
    self.own_txt:setString(own_num)

    local power = controller:getModel():getTalentPower()
    self.power_label:setString(MoneyTool.moneyFormat(power))

    local total_star,collect_num = controller:getModel():getTotalStarAndTotalNum()
    local now_num,now_star = controller:getModel():getActiveNumAndStarNum()
    self.collect_label:setString(string.format(TI18N("语言_c_7209"),now_num,collect_num))
    self.total_star_label:setString(string.format(TI18N("语言_c_7210"),now_star,total_star))
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_book
    local roller_cfg = Config.ProhibitedScrollData.data_get_proh_scroll
    self.data_list = {}
    for i = 0, 3 do
        self.data_list[i] = {}
    end
    for k, v in pairs(cfg) do
        local roller_id = v.id
        local is_open = model:checkSingleRollerOpenStatus(roller_id)
        if is_open then
            local object = deepCopy(v)
            local roller_data = {}
            object.star = 0
            local roller_info = roller_cfg[roller_id]
            local quality = roller_info.quality
            object.quality = quality
            object.name = roller_info.name
    
            -- local roller_data = model:getRollerDataById(roller_id)
            -- if roller_data then
            --     local rward_data = roller_data.star_awards[1]
            --     if rward_data then
            --         object.sort = 100000 + object.sort
            --     else
            --         object.sort = 10000 + object.sort
            --     end
            -- else
            --     object.sort = 1000 + object.sort
            -- end
    
            table.insert(self.data_list[0],object)
            table.insert(self.data_list[quality],object)
        end
    end

    self:_onClickBtnShowByIndex(0)
    self:updateTalentRedStatus()
end

function RollerTujianPanel:updateList()
    self.cell_data_list = deepCopy(self.data_list[self.select_quality])
    local sort_func_low = SortTools.tableLowerSorter({"sort"})
    -- local sort_func_low = SortTools.tableUpperSorter({"sort"})
    table.sort(self.cell_data_list,sort_func_low)
    self.item_scrollview:reloadData()
end

function RollerTujianPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

function RollerTujianPanel:updateTalentRedStatus()
    local red_3 = false
    local talent_open = model:checkTalentCondition()
    if talent_open then
        red_3 = model:CheckAllTalentStatus()
    end
    addRedPointToNodeByStatus(self.talent_btn, red_3,10,10)
end

function RollerTujianPanel:DeleteMe()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.update_event then
        GlobalEvent:getInstance():UnBind(self.update_event)
        self.update_event = nil
    end
    if self.update_talent_event then
        GlobalEvent:getInstance():UnBind(self.update_talent_event)
        self.update_talent_event = nil
    end
    if self.update_roller_event then
        GlobalEvent:getInstance():UnBind(self.update_roller_event)
        self.update_roller_event = nil
    end
	self:removeAllChildren()
    self:removeFromParent()
end
