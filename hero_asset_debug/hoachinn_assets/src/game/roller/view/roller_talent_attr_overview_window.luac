--****************
--共鸣属性总览
--****************
RollerTalentAttrOverviewWindow = RollerTalentAttrOverviewWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()

local table_insert = table.insert
function RollerTalentAttrOverviewWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.show_skill_list = {}
    self.show_skill_list_1 = {}
    self.show_attr_list = {}
	self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("activity", "activity"), type = ResourcesType.plist},
	}
	self.layout_name = "roller/roller_talent_attr_overview_window"
end

function RollerTalentAttrOverviewWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

    self.item = self.root_wnd:getChildByName("item")

	local main_panel = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(main_panel, 1)

    self.tips1 = main_panel:getChildByName("tips1")
    self.tips1:setString(TI18N("语言_c_2997"))
    self.tips2 = main_panel:getChildByName("tips2")
    self.tips2:setString(TI18N("语言_c_7202"))

	self.baseattr_panel = main_panel:getChildByName("baseattr_panel")
    if not self.base_list_view then
        local scroll_view_size = self.baseattr_panel:getContentSize()
        local setting = {
            start_x = 36,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 5,                    -- 第一个单元的Y起点
            space_y = 5,                   -- y方向的间隔
            col = 1,                         -- 列数，作用于垂直滚动类型
            item_width = 318,               -- 单元的尺寸width
            item_height = 34,              -- 单元的尺寸height
            -- row = 1,                        -- 行数，作用于水平滚动类型
            need_dynamic = true
        }
        self.list_view = CommonScrollViewSingleLayout.new(self.baseattr_panel, cc.p(scroll_view_size.width * 0.5, scroll_view_size.height * 0.5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0.5,0.5))
        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    self.strengattr_panel = main_panel:getChildByName("strengattr_panel")
    if not self.fumo_list_view then
        local scroll_view_size = self.strengattr_panel:getContentSize()
        local setting = {
            start_x = 36,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 5,                    -- 第一个单元的Y起点
            space_y = 5,                   -- y方向的间隔
            col = 1,                         -- 列数，作用于垂直滚动类型
            item_width = 318,               -- 单元的尺寸width
            item_height = 34,              -- 单元的尺寸height
            need_dynamic = true
        }
        self.fumo_list_view = CommonScrollViewSingleLayout.new(self.strengattr_panel, cc.p(scroll_view_size.width * 0.5, scroll_view_size.height * 0.5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0.5,0.5))
        self.fumo_list_view:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.fumo_list_view:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.fumo_list_view:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
end
function RollerTalentAttrOverviewWindow:createNewCell(width, height)
    local cell = RollerTalentAttrOverviewItem.new()
    return cell
end
function RollerTalentAttrOverviewWindow:numberOfCells()
    if not self.base_attr_data then return 0 end
    return #self.base_attr_data
end
function RollerTalentAttrOverviewWindow:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.base_attr_data[index]
    cell:setExtralData(self.item)
    cell:setData(hero_vo)
end
function RollerTalentAttrOverviewWindow:_createNewCell(width, height)
    local cell = RollerTalentAttrOverviewItem.new()
    return cell
end

function RollerTalentAttrOverviewWindow:_numberOfCells()
    if not self.fumo_attr_list then return 0 end
    return #self.fumo_attr_list
end
function RollerTalentAttrOverviewWindow:_updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.fumo_attr_list[index]
    cell:setExtralData(self.item)
    cell:setData(hero_vo)
end

function RollerTalentAttrOverviewWindow:openRootWnd(id)
    self.roller_id = id
    self:setData()
end

function RollerTalentAttrOverviewWindow:setData()
    local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.roller_id]
    local roller_data = model:getRollerDataById(self.roller_id)
    local lv = roller_data.lev
    local star = roller_data.star

    local quality = base_cfg.quality
    local strength_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_enhance[quality][lv]
    local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[self.roller_id][star]
    --基础属性（升级和升星）
    local strength_attr = strength_cfg.attr
    local star_attr = star_cfg.attr
    local _arr = {}
    for k, v in pairs(strength_attr) do
        local key = v[1]
        local num = v[2]
        if _arr[key] then
            _arr[key] = _arr[key] + num
        else
            _arr[key] = num
        end
    end
    for k, v in pairs(star_attr) do
        local key = v[1]
        local num = v[2]
        if _arr[key] then
            _arr[key] = _arr[key] + num
        else
            _arr[key] = num
        end
    end
    self.base_attr_data = {}
    for i, v in pairs(_arr) do
        local key_id = Config.AttrData.data_key_to_id[i] or Config.AttrExtraData.data_key_to_id[i]
        local object = {i,v,key_id}
        table.insert(self.base_attr_data,object)
    end
    local function sortFunc( objA, objB )
        return objA[3] < objB[3]
    end
    table.sort(self.base_attr_data,sortFunc)
    self.list_view:reloadData()

    --封印属性
    local __attr = {}
    local fengyin_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal
    for k, v in pairs(fengyin_cfg) do
        local fengyin_lv = model:getRollerFengyinLvById(self.roller_id,k)
        local _data = v[fengyin_lv]
        if _data then
            local attrs = _data.attrs
            for i, val in ipairs(attrs) do
                table.insert(__attr,val)
            end
        else --没有显示0
            local attrs = v[1].attrs
            for i, val in ipairs(attrs) do
                table.insert(__attr,{val[1],0})
            end
        end
    end
    local temp = {}
    for k, v in pairs(__attr) do
        local key = v[1]
        local num = v[2]
        if temp[key] then
            temp[key] = temp[key] + num
        else
            temp[key] = num
        end
    end

    --额外属性
    local extral_attr = model:getExtralFengYinAttrById(self.roller_id)
    if next(extral_attr) then
        for k, v in pairs(extral_attr) do
            local key = v[1]
            local num = v[2]
            if temp[key] then
                temp[key] = temp[key] + num
            else
                temp[key] = num
            end
        end
    end

    local fengyin_attr = {}
    for i, v in pairs(temp) do
        local key_id = Config.AttrData.data_key_to_id[i] or Config.AttrExtraData.data_key_to_id[i]
        local object = {i,v,key_id}
        table.insert(fengyin_attr,object)
    end
    local function sortFunc( objA, objB )
        return objA[3] < objB[3]
    end
    table.sort(fengyin_attr, sortFunc)
    self.fumo_attr_list = fengyin_attr
    self.fumo_list_view:reloadData()
end

function RollerTalentAttrOverviewWindow:register_event()
	registerButtonEventListener(self.background, function ()
		controller:openRollerAllAttrOverviewWindow(false)
	end, false, 2)
end

function RollerTalentAttrOverviewWindow:close_callback()
	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end
	if self.fumo_list_view then
		self.fumo_list_view:DeleteMe()
		self.fumo_list_view = nil
	end
	controller:openRollerAllAttrOverviewWindow(false)
end

-------------------@ item
RollerTalentAttrOverviewItem = class("RollerTalentAttrOverviewItem",function()
    return ccui.Widget:create()
end)

function RollerTalentAttrOverviewItem:ctor()
end

function RollerTalentAttrOverviewItem:registerEvent()
end
function RollerTalentAttrOverviewItem:setExtralData(node)
    if not tolua.isnull(node) and self.root_wnd == nil then
		self.is_completed = true
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)

		self.root_wnd = node:clone()
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5)
		self:addChild(self.root_wnd)
		self.root_wnd:setVisible(true)

        self.attr_icon = self.root_wnd:getChildByName("attr_icon")
        self.attr_icon:ignoreContentAdaptWithSize(true)
        self.attr_name = self.root_wnd:getChildByName("attr_name")
        self.attr_val = self.root_wnd:getChildByName("attr_val")

		self:registerEvent()
	end
end

function RollerTalentAttrOverviewItem:setData(data)
    -- [10] = {level=10, attrs={{'hp_max',1683},{'atk',140}}},
    if not data then
        return
    end
    local next_res, next_attr_name, next_attr_val = commonGetAttrInfoByKeyValue(data[1], data[2])
    self.attr_icon:loadTexture(next_res, LOADTEXT_TYPE_PLIST)
    self.attr_name:setString(next_attr_name)
    self.attr_val:setString(next_attr_val)
end

function RollerTalentAttrOverviewItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end
