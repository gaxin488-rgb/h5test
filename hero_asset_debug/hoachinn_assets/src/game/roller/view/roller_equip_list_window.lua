-- 卷轴的装备情况
RollerEquipListWindow = RollerEquipListWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()
local string_format = string.format

function RollerEquipListWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Tips
    self.layout_name = "roller/roller_equip_list_window"
    self.res_list = {{
        path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"),
        type = ResourcesType.plist
    }}
    self.select_quality = nil
    self.select_item = nil
end

function RollerEquipListWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("main_container")
    commonOpenActionLeftMove(self.main_container)
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.up_panel = self.main_container:getChildByName("up_panel")
    self.roller_btn = self.up_panel:getChildByName("roller_btn")
    self.roller_btn_label = self.roller_btn:getChildByName("label")
    setTextMaxWidth(self.roller_btn_label, 130, -10)
    self.roller_btn_label:setString(TI18N("语言_c_7192"))

    self.name_bg = self.up_panel:getChildByName("name_bg")
    self.equip_name = self.name_bg:getChildByName("equip_name")
    self.equip_name:setString(TI18N("语言_c_7239"))

    self.camp_panel = self.up_panel:getChildByName("camp_panel")
    self.new_camp_btn_list = {}
    self.new_camp_btn_list[0] = self.camp_panel:getChildByName("camp_btn0")
    self.new_camp_btn_list[3] = self.camp_panel:getChildByName("camp_btn1")
    self.new_camp_btn_list[4] = self.camp_panel:getChildByName("camp_btn2")
    self.new_camp_btn_list[5] = self.camp_panel:getChildByName("camp_btn3")
    self.camp_select = self.camp_panel:getChildByName("camp_select")

    self.plan_list = self.up_panel:getChildByName("plan_list")
    if self.item_scrollview == nil then
        local scroll_view_size = self.plan_list:getContentSize()
        local setting = {
            start_x = 0,
            space_x = 0,
            start_y = -5,
            space_y = 5,
            item_width = 150,
            item_height = 170,
            col = 4,
            once_num = 1 -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.plan_list, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell) -- 创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells) -- 获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) -- 更新cell
    end
end

function RollerEquipListWindow:createNewCell(width, height)
    local cell = RollerItem.new()
    cell:addCallBack(function()
        self:onCellTouched(cell)
    end)
    return cell
end
function RollerEquipListWindow:numberOfCells()
    if not self.cell_data_list then
        return 0
    end
    return #self.cell_data_list
end
function RollerEquipListWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then
        return
    end
    cell:setData(cell_data)
    cell:setswTouchStatus(false)
end
function RollerEquipListWindow:onCellTouched(cell)
    if self.select_item then
        local data = cell:getData()
        if data.partner_id ~= 0 and data.partner_id == self.partner_id then
            message(TI18N("语言_c_7237"))
            return
        end
        self.select_item:setSelected(false)
        self.select_item = nil
        self.select_item = cell
        local setting = {roller_id=data.id,partner_id=self.partner_id,open_type=TRUE}
        controller:openRollerChipTipsWindow(true, setting)
    else
        self.select_item = cell
		local data = cell:getData()
        if data.partner_id ~= 0 and data.partner_id == self.partner_id then
            message(TI18N("语言_c_7237"))
            return
        end
        local setting = {roller_id=data.id,partner_id=self.partner_id,open_type=TRUE}
		controller:openRollerChipTipsWindow(true, setting)
    end
end

function RollerEquipListWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:onClickClose()
        end
    end)

    registerButtonEventListener(self.close_btn, function()
        self:onClickClose()
    end, true, 2)

    registerButtonEventListener(self.roller_btn, function()
        controller:openRollerMainWindow(true,1)
        self:onClickClose()
    end, true, 2)

    for index, v in pairs(self.new_camp_btn_list) do
        registerButtonEventListener(v, function()
            self:_onClickBtnShowByIndex(index)
        end, true, 2)
    end

    self:addGlobalEvent(RollerEvent.Roller_Equip_Event, function ()
        self:updateList()
    end)

    self:addGlobalEvent(RollerEvent.Update_Roller_Event, function ()
        self:countListData()
        self:updateList()
    end)
    -- self:addGlobalEvent(RollerEvent.Roller_Upstar_Result, function ()
    --     self:updateList()
    -- end)

end

function RollerEquipListWindow:_onClickBtnShowByIndex(index)
    if index == self.select_quality then
        return
    end
    if self.camp_select and self.new_camp_btn_list[index] then
        local x, y = self.new_camp_btn_list[index]:getPosition()
        self.camp_select:setPosition(x - 0.5, y + 1)
    end
    self.select_quality = index
    self:updateList()
end

function RollerEquipListWindow:onClickClose()
    controller:openRollerEquipListWindow(false)
end

function RollerEquipListWindow:openRootWnd(partner_id)
    self.partner_id = partner_id
    self:countListData()
    -- for k, v in pairs(all_data) do
    --     local roller_id = v.id
    --     local roller_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[roller_id]
    --     local quality = roller_cfg.quality
    --     table.insert(self.roller_list[0], deepCopy(v))
    --     table.insert(self.roller_list[quality], deepCopy(v))
    -- end
    self:_onClickBtnShowByIndex(0)
end
function RollerEquipListWindow:countListData()
    local all_data = model:getAllRollerData()
    self.roller_list = {}
    self.roller_list[0] = {}
    self.roller_list[3] = {}
    self.roller_list[4] = {}
    self.roller_list[5] = {}

    local roller_cfg = Config.ProhibitedScrollData.data_get_proh_scroll
    for k, v in pairs(roller_cfg) do
        local roller_id = v.id
        local roller_data = model:getRollerDataById(roller_id)
        local object = {}
        object.id = roller_id
        object.lev = 0
        object.partner_id = 0
        object.score = v.sort
        object.seal = 0
        object.star = 0
        object.seal_count = 0
        object.seal_list = {}
        object.unlock = true
        if roller_data then
            object.lev = roller_data.lev
            object.partner_id = roller_data.partner_id
            object.score = roller_data.score
            object.seal = roller_data.seal
            object.seal_count = roller_data.seal_count
            object.seal_list = roller_data.seal_list
            object.star = roller_data.star
            object.unlock = false
        end

        object.sort = 0
        if object.unlock == false then
            object.sort = 90000000 + object.sort
        else
            object.sort = 50000000 + object.sort
        end

        if roller_data and roller_data.partner_id and roller_data.partner_id ~= 0 then
            object.sort = 9000000 + object.sort
        else
            object.sort = 5000000 + object.sort
        end
        local quality = v.quality
        object.sort = quality * 1000000 + object.sort
        object.sort = object.sort + object.score

        -- if roller_data then
        --     object.sort = object.sort + 20000
        --     if roller_data.partner_id and roller_data.partner_id ~= 0 then
        --         object.sort = object.sort + 100
        --     else
        --         object.sort = object.sort + 200
        --     end
        -- else
        --     object.sort = object.sort + 10000
        -- end

        table.insert(self.roller_list[0], object)
        table.insert(self.roller_list[quality], object)
    end
end

function RollerEquipListWindow:updateList()
    self.cell_data_list = deepCopy(self.roller_list[self.select_quality])
    local function sortFunc( objA, objB )
        return objA.sort > objB.sort
    end
    table.sort(self.cell_data_list, sortFunc)
    self.item_scrollview:reloadData()
end

function RollerEquipListWindow:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    controller:openRollerEquipListWindow(false)
end
