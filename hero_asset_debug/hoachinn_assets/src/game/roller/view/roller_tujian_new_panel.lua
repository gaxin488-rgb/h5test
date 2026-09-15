--**************************
--**************************
RollerTujianNewPanel = class("RollerTujianNewPanel", function()
    return ccui.Widget:create()
end)

local controller = RollerController:getInstance()
local model = controller:getModel()
local string_format = string.format

function RollerTujianNewPanel:ctor()  
	self:loadResListCompleted()
end
-- 资源加载完成
function RollerTujianNewPanel:loadResListCompleted()
    self.select_quality = nil
	self:configUI()
	self:register_event()
    self:setData(true)
end

function RollerTujianNewPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("roller/roller_tujian_new_panel"))
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

    self.lis_bottom_bg = main_container:getChildByName("lis_bottom_bg")
    self.lis_bottom_bg:setPositionY(bottom_y+177)

	self.up_panel = main_container:getChildByName("up_panel")
    self.up_panel:setPositionY(top_y - 40)
    self.help_btn = self.up_panel:getChildByName("help_btn")
    self.title_bg = self.up_panel:getChildByName("title_bg")
    self.title_name = self.title_bg:getChildByName("title_name")
    self.title_name:setString(TI18N("语言_c_7360"))
    self.talent_btn = self.up_panel:getChildByName("talent_btn")
    self.talent_btn.text_bg = self.talent_btn:getChildByName("text_bg")
    self.talent_btn.label = self.talent_btn:getChildByName("label")
    setTextMaxWidth(self.talent_btn.label, 103, -4)
    self.talent_btn.label:setString(TI18N("语言_c_2112"))
    self.collect_label = createRichLabel(20, cc.c4b(0xff, 0xff, 0xff, 0xff), cc.p(0.5, 0), cc.p(360, 14))
    self.up_panel:addChild(self.collect_label)
    self.collect_label:setString(TI18N("语言_c_7361"))

	self.plan_list = main_container:getChildByName("plan_list")
    local _list_size = self.plan_list:getContentSize()
    self.plan_list:setContentSize(cc.size(_list_size.width, _list_size.height+add_height))
	if self.item_scrollview == nil then
        local scroll_view_size = self.plan_list:getContentSize()
        local setting = {
            start_x = 19,       -- 第一个单元的X起点
            space_x = 0,        -- x方向的间隔
            start_y = 0,        -- 第一个单元的Y起点
            space_y = 15,       -- y方向的间隔
            item_width = 682,   -- 单元的尺寸width
            item_height = 539,  -- 单元的尺寸height
            col = 1,
            once_num = 1 -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.plan_list, cc.p(0, 0), ScrollViewDir.vertical,ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell) -- 创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells) -- 获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) -- 更新cell
    end

end

function RollerTujianNewPanel:createNewCell(width, height)
    local cell = RollerTujianNewItem.new()
    -- cell:addCallBack(function()
    --     self:onCellTouched(cell)
    -- end)
    return cell
end
function RollerTujianNewPanel:numberOfCells()
    if not self.cell_data_list then
        return 0
    end
    return #self.cell_data_list
end
function RollerTujianNewPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then
        return
    end
    cell:setData(cell_data)
    -- cell:setExtendData(self.fenjie_select_list)
end
-- function RollerTujianNewPanel:onCellTouched(cell)
--     local data = cell:getData()
--     if data then
--         local id = data.id
--         local roller_data = model:getRollerDataById(id)
--         if roller_data then
--             if roller_data.star_awards and next(roller_data.star_awards) then
--                 controller:sender20809(id)
--             else
--                 message(TI18N("语言_c_2523"))
--             end 
--         -- else
--         --     message("激活后可领取")
--         end
--     end
-- end

function RollerTujianNewPanel:register_event()
	if self.help_btn then
        self.help_btn:addTouchEventListener(function( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                local cfg = Config.ProhibitedScrollData.data_get_constant["atlas_desc"]
                -- MainuiController:getInstance():openCommonExplainView(true, cfg)
                local obj = {
                    [1] = { id=1, title=TI18N("语言_pro_sc_13_4"), desc=cfg.desc or "" },
                }
                MainuiController:getInstance():openCommonExplainView(true, obj)
            end
        end)
    end

    registerButtonEventListener(self.talent_btn, function()
        local data = {}
        local sort_data = {}
        local activation_data = model:getRollerLibraryData()
        for i = 1 , Config.ProhibitedScrollData.data_get_scroll_hand_book_length do 
            local config =Config.ProhibitedScrollData.data_get_scroll_hand_book(i)
            if activation_data and activation_data[config.id] then 
                local add_data = {}
                for k , v in pairs(config.attr3) do 
                    table.insert(add_data,v)
                end     
                for k , v in pairs(config.attr4) do  
                    table.insert(add_data,v)
                end  
                data[config.group] = add_data   
            end     
        end     
        for group ,add_data in pairs(data) do 
            for k , v in pairs(add_data) do  
                table.insert(sort_data,v)  
            end 
        end
        controller:openCommonAttrWindow(true, sort_data)
    end,true)

    if not self.update_event then
        self.update_event = GlobalEvent:getInstance():Bind(RollerEvent.UpdateRollerLibraryRedStatus, function()
            self:setData()
        end)
    end

    if not self.updat_event then
        self.updat_event = GlobalEvent:getInstance():Bind(RollerEvent.Update_Roller_Event, function()
            self:setData()
        end)
    end

end

function RollerTujianNewPanel:setData(reset)
    local activation_data = model:getRollerLibraryData()
    local group_data = model:getRollerGroupData()
    self.cell_data_list = {} 
    local jump_index = nil
    for group , tab in pairs(group_data) do 
        local show_data = nil
        for k, v in pairs( tab ) do 
            local data = clone(v)
            if not activation_data[data.id] then
                if not show_data then
                    data.is_maxlev = false
                    show_data = data 
                else
                    data.attr = clone(show_data.attr)   
                    show_data = data
                end
                break
            elseif activation_data[data.id] then  
                data.is_maxlev = k == #tab
                data.is_pre_view = true 
                show_data = data  
            end    
        end    
        if not show_data then 
            tab[1].is_maxlev = true
            show_data = tab[1]
        end 
        table.insert(self.cell_data_list,show_data)  
    end  
    table.sort(self.cell_data_list, function (a, b)
        return a.proh_hand_book_sort < b.proh_hand_book_sort
    end)
    if reset then
        self.item_scrollview:reloadData()
    else
        self.item_scrollview:resetCurrentItems()
    end
    -- for k, v in pairs(self.data_list) do
    --     if not activation_data[v.id] then
    --         local can_lev_up = model:getJinqiLibraryCanLevUp(v)
    --         if can_lev_up then 
    --             jump_index = k 
    --             break
    --         end   
    --     end
    -- end
end

function RollerTujianNewPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

function RollerTujianNewPanel:DeleteMe()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.update_event then
        GlobalEvent:getInstance():UnBind(self.update_event)
        self.update_event = nil
    end
    if self.updat_event then
        GlobalEvent:getInstance():UnBind(self.updat_event)
        self.updat_event = nil
    end
    -- if self.update_roller_event then
    --     GlobalEvent:getInstance():UnBind(self.update_roller_event)
    --     self.update_roller_event = nil
    -- end
	self:removeAllChildren()
    self:removeFromParent()
end
