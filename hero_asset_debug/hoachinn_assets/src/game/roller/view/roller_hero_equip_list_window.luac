--****************
--卷轴
--****************
RollerHeroEquipListWindow = RollerHeroEquipListWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local table_sort = table.sort

function RollerHeroEquipListWindow:__init()
    self.is_full_screen = true
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.select_camp = 0
    self.layout_name = "roller/roller_hero_equip_list_window"
end

function RollerHeroEquipListWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end
	local main_panel = self.root_wnd:getChildByName("main_panel")
    self.mainContainer = main_panel
    commonOpenActionLeftMove(self.mainContainer)
    
    self.close_btn = main_panel:getChildByName("close_btn")
    self.title_img = main_panel:getChildByName("Image_1_0")
    self.title_label = main_panel:getChildByName("title_label")
    self.title_label:setString(TI18N("语言_c_7422"))
    autoSizeTitleBg(self.title_label, self.title_img, 120)

    self.camp_panel = main_panel:getChildByName("camp_panel")
    self.camp_bg = self.camp_panel:getChildByName("camp_bg")
    self.camp_select = self.camp_panel:getChildByName("camp_select")
    self.new_camp_btn_list = {}
    self.new_camp_redpoint_list = {}
    self.new_camp_btn_list[0] = self.camp_panel:getChildByName("camp_btn0")
    self.new_camp_btn_list[1] = self.camp_panel:getChildByName("camp_btn1")
    self.new_camp_btn_list[2] = self.camp_panel:getChildByName("camp_btn2")
    self.new_camp_btn_list[3] = self.camp_panel:getChildByName("camp_btn3")
    self.new_camp_btn_list[4] = self.camp_panel:getChildByName("camp_btn4")
    self.new_camp_btn_list[5] = self.camp_panel:getChildByName("camp_btn5")

    self.label = main_panel:getChildByName("label")
    local need_star = Config.ProhibitedScrollData.data_get_constant.scroll_management.val
    self.label:setString(string.format(TI18N("语言_c_7426"),need_star))
    setTextMaxWidth(self.label, 620, -4)

    self.item_list = main_panel:getChildByName("main_container")
    self.empty_icon = self.item_list:getChildByName("empty_icon")
    self.empty_tips = self.empty_icon:getChildByName("tips")
    self.empty_tips:setString(TI18N("语言_c_130"))
    self.empty_icon:setVisible(false)

	local scroll_view_size = self.item_list:getContentSize()
    local setting = {
        start_x = 6,
        space_x = 0,
        start_y = 0,
        space_y = 5,
        item_width = 618,
        item_height = 141,
        row = 0, 
        col = 1,
        need_dynamic = true
    }
    self.list_view = CommonScrollViewSingleLayout.new(self.item_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell)
    self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells)
    self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex)
end

function RollerHeroEquipListWindow:openRootWnd(index)
   index = index or 0
   self:setData(index)
end

function RollerHeroEquipListWindow:setData(select_camp)
    if self.select_camp and self.new_camp_btn_list[select_camp] then
        local x, y = self.new_camp_btn_list[select_camp]:getPosition()
        self.camp_select:setPosition(x - 0.5, y + 1)
    end
    --英雄列表 (默认)
    local need_star = Config.ProhibitedScrollData.data_get_constant.scroll_management.val
    self.hero_bag_list =  HeroController:getInstance():getModel():getAllHeroArray()
    local hero_array = self.hero_bag_list or Array.New()
    local form_list = {}
    local list = {}
    self.select_camp = select_camp
    for j=1,hero_array:GetSize() do
        local hero_vo = hero_array:Get(j-1)
        local equip_status = RollerController:getInstance():getModel():checkEquipOpenStatus(hero_vo.bid)
        if (select_camp == 0 or (select_camp == hero_vo.camp_type)) and hero_vo.star >= need_star and equip_status then
            table_insert(list, hero_vo)
        end
    end
    for i, v in ipairs(list) do
        if v.prohibited_scroll and v.prohibited_scroll[1] and v.prohibited_scroll[1].scroll_id and v.prohibited_scroll[1].scroll_id ~= 0 then
            if v:isFormDrama() then
                v.roller_sort = 1000000
            else
                v.roller_sort = 100000
            end
        else
            if v:isFormDrama() then
                v.roller_sort = 10000
            else
                v.roller_sort = 1000
            end
        end
    end
    local sort_func = SortTools.tableCommonSorter({{"roller_sort", true}, {"power", true}})
    table_sort(list, sort_func)

    local size = #list
    if size > 0 then
        self.show_list = list
        self.empty_icon:setVisible(false)
    else
        self.show_list = {}
        self.empty_icon:setVisible(true)
    end
    self.list_view:reloadData(nil, nil, true)
end

function RollerHeroEquipListWindow:_onClickBtnShowByIndex(index)
    self:setData(index)
end

function RollerHeroEquipListWindow:register_event()
	registerButtonEventListener(self.close_btn, function ()
		controller:openRollerHeroEquipListWindow(false)
	end, true, 2)
	registerButtonEventListener(self.background, function ()
		controller:openRollerHeroEquipListWindow(false)
	end, false, 2)
    --阵营按钮
    for index, v in pairs(self.new_camp_btn_list) do
        registerButtonEventListener(v, function() self:_onClickBtnShowByIndex(index) end ,true, 1)
    end
    self:addGlobalEvent(RollerEvent.Update_Roller_Event, function()
        self.list_view:reloadData(nil, nil, true)
    end)
    self:addGlobalEvent(RollerEvent.Roller_Equip_Event, function()
        self.list_view:reloadData(nil, nil, true)
    end)
    self:addGlobalEvent(HeroEvent.Hero_Data_Update, function()
        self.list_view:reloadData(nil, nil, true)
    end)
end

function RollerHeroEquipListWindow:createNewCell()
	local cell = RollerHeroEquipListItem.new()
    return cell
end

function RollerHeroEquipListWindow:numberOfCells()
	if not self.show_list then return 0 end
    return #self.show_list
end

function RollerHeroEquipListWindow:updateCellByIndex(cell, index)
	if not self.show_list then return end
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
	cell:setData(cell_data)
end

function RollerHeroEquipListWindow:close_callback()
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
	controller:openRollerHeroEquipListWindow(false)
end

