--------------------------------------------
-- 
-- 
-- @Date    : 2019-01-16 19:09:44
-- @description    : 
		-- 宝石背包
---------------------------------

GemstoneBagWindow = GemstoneBagWindow or BaseClass(BaseView)

local controller = GemstoneController:getInstance()
local model = controller:getModel()
local back_controller = BackpackController:getInstance()
local back_model = back_controller:getModel()

function GemstoneBagWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Big  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.layout_name = "gemstone/gemstone_bag_window"
	self.cur_pos = -1
	self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("hero", "hero"), type = ResourcesType.plist},
    }
end

function GemstoneBagWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end
	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
	self.goods_con = self.main_container:getChildByName("goods_con")
	if self.item_scrollview == nil then
        local scroll_view_size = self.goods_con:getContentSize()
        local setting = {
            start_x = 5, -- 第一个单元的X起点
            space_x = 5, -- x方向的间隔
            start_y = 0, -- 第一个单元的Y起点
            space_y = 5, -- y方向的间隔
            item_width = BackPackItem.Width, -- 单元的尺寸width
            item_height = BackPackItem.Height, -- 单元的尺寸height
            col = 5, -- 列数，作用于水平滚动类型
            once_num = 1 -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.goods_con, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell) -- 创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells) -- 获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) -- 更新cell
    end
	self.remove_btn = self.main_container:getChildByName("remove_btn")
	self.remove_txt = self.remove_btn:getChildByName("label")
	self.remove_txt:setString(TI18N("语言_c_2958"))
	self.Image_17 = self.main_container:getChildByName("Image_17")
	self.title_label = self.main_container:getChildByName("title_label")
	self.title_label:setString(TI18N("语言_c_7116"))
	autoSizeTitleBg(self.title_label, self.Image_17)
	self.close_btn = self.main_container:getChildByName("close_btn")
	self.item_panel = self.main_container:getChildByName("item_panel")
	self.item_num = self.item_panel:getChildByName("item_num")
	self.item_add = self.item_panel:getChildByName("item_add")
	self.tips = self.main_container:getChildByName("tips")
	self.tips:setChangeScaleOffWidth(68)
	self.tips:setString(TI18N("语言_c_7169"))
	self.checkBox = self.main_container:getChildByName("checkbox")
	self.checktxt = self.checkBox:getChildByName("name")
	self.checktxt:setString(TI18N("语言_c_7168"))
	self.checkBox:setSelected(false)
	self.choose_bg = self.main_container:getChildByName("choose_bg")
	self.select_img = self.choose_bg:getChildByName("select_img")
	self.choose_list = {}
	for i = 0, 6 do
		local item = self.choose_bg:getChildByName("pos_btn_"..i)
		item.index = i
		if i ~= 0 then
			local txt = item:getChildByName("label")
			txt:setString(StringUtil.numToRoman(i).." ")
		end
		self.choose_list[i] = item
	end
end

function GemstoneBagWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), true, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.item_add, handler(self, self._onClickAddBtn), true, 2)
	registerButtonEventListener(self.remove_btn, handler(self, self._onClickRemoveBtn), true, 2)
	for i = 0, 6 do
		registerButtonEventListener(self.choose_list[i], function()
			self:_onClickPos(self.choose_list[i].index)
		end, true, 2)
	end
	self:registerCheckBoxEvent(self.checkBox)
	self:addGlobalEvent(BackpackEvent.UpdateEquipSize, function(type)
		if type == BackPackConst.item_tab_type.GEMSTONE then
			self:updateItemNumPanel()
		end
	end)
	self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code, item_list)
		if bag_code == BackPackConst.item_tab_type.GEMSTONE then
			self:openRootWnd()
		end
	end)
	self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code, item_list)
		if bag_code == BackPackConst.item_tab_type.GEMSTONE then
			self:openRootWnd()
		end
	end)
	self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, item_list)
		if bag_code == BackPackConst.item_tab_type.GEMSTONE then
			local num = 1
			if self.checkBox:isSelected() then
				num = 2
			else
				num = 1
			end
			for key, value in pairs(item_list) do
				for i, v in pairs(self.back_data[num] or {}) do
					if v.id == value.id then
						self.back_data[num][i] = value
					end
				end
				for k, v in pairs(self.show_data) do
					for _k, _v in pairs(v) do
						if _v.id == value.id then
							self.show_data[k][num][_k] = value
						end
					end
				end
			end
			self.item_scrollview:reloadData(nil,nil,true)
		end
	end)
end

--注册选项框事件
function GemstoneBagWindow:registerCheckBoxEvent(btn)
    if not btn then return end
	btn:addEventListener(function(sender,event_type)
	    if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
	        btn:setSelected(true)
			local index = self.cur_pos
			self.cur_pos = -1
			self:_onClickPos(index)
	    elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            btn:setSelected(false)
			local index = self.cur_pos
			self.cur_pos = -1
			self:_onClickPos(index)
	    end
    end)
end
function GemstoneBagWindow:_onClickRemoveBtn()
	controller:openGemstoneRemoveWindow(true)
end
function GemstoneBagWindow:_onClickAddBtn()
	local item_id = Config.PackageData.data_backpack_cost["bag_need"].val[1][1] or 3
	local count = Config.PackageData.data_backpack_cost["bag_need"].val[1][2] or 100
	local add_num = Config.PackageData.data_backpack_cost["gem_bag_vol_open_def"].val or 10
	local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
	local str = LangStringFormat(TI18N("语言_c_7154"), iconsrc, count, add_num)
	local call_back = function()
		BackpackController:getInstance():sender10526(BackPackConst.item_tab_type.GEMSTONE)
	end
	CommonAlert.show(str, TI18N("语言_c_63"), call_back, TI18N("语言_c_62"), nil, CommonAlert.type.rich)
end

function GemstoneBagWindow:_onClickCloseBtn()
	controller:openGemstoneBagWindow(false)
end
--点击筛选
function GemstoneBagWindow:_onClickPos(index)
	if self.cur_pos == index then return end
	self.cur_pos = index
	self.select_img:setPositionX(self.choose_list[index]:getPositionX())
	local num = 1
	if self.checkBox:isSelected() then
		num = 2
	else
		num = 1
	end
	if index == 0 then
		self.show_list = self.back_data[num] or {}
	else
		self.show_list = {}
		if self.show_data[index] and self.show_data[index][num] then
			self.show_list = self.show_data[index][num]
		end
	end
	self.item_scrollview:reloadData(nil,nil,true)
	if self.show_list and next(self.show_list) then
		commonShowEmptyIcon(self.item_scrollview,false)
	else
		commonShowEmptyIcon(self.item_scrollview,true,{text=TI18N("语言_c_7146")})
	end
end

function GemstoneBagWindow:createNewCell(width, height)
    local cell = BackPackItem.new(false,true,nil,0.9,nil,true)
    return cell
end

function GemstoneBagWindow:numberOfCells()
    if not self.show_list then
        return 0
    end
    return #self.show_list
end
-- 更新cell(拖动的时候.刷新数据时候会执行次方法)
-- cell :createNewCell的返回的对象
-- index :数据的索引
function GemstoneBagWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then
        return
    end
    cell:setData(cell_data)
	if Config.PartnerGemData.data_base_info[cell_data.base_id] then
		if cell_data["checkGemIsLock"] then
			cell:showGemLockStatus(true,cell_data:checkGemIsLock())
		else
			cell:showGemLockStatus(true,false)
		end
	else
		cell:showGemLockStatus(false,false)
	end
end
function GemstoneBagWindow:updateItemNumPanel()
	local data = back_model:getExpansionInfo(BackPackConst.Bag_Code.GEMSTONE)
	local max_num = 0
	if data and data.volume then
		max_num = data.volume
	end
	self.item_num:setString(string.format("%s/%s",#self.back_data[1],max_num))
	if max_num >= Config.PackageData.data_backpack_cost.gem_bag_vol_max.val then
		self.item_add:setVisible(false)
	else
		self.item_add:setVisible(true)
	end
end
function GemstoneBagWindow:openRootWnd()
	self.show_data = {}
	self.back_data = {[1]={},[2]={}} --1全部2可重铸
	local data = back_model:getBagItemList(BackPackConst.item_tab_type.GEMSTONE)
	for i, v in pairs(data) do
		local cfg = Config.PartnerGemData.data_base_info[v.base_id]
		if cfg then
			v.gem_pos = cfg.pos
			if v.checkGemIsLock then
				v.lock_status = v:checkGemIsLock() and 1 or 0
			else
				v.lock_status = 0
			end
			if not self.show_data[cfg.pos] then
				self.show_data[cfg.pos] = {[1]={},[2]={}}
			end
			table.insert(self.show_data[cfg.pos][1], v)
			table.insert(self.back_data[1], v)
			if Config.PartnerGemData.data_refresh[v.base_id] then
				table.insert(self.back_data[2], v)
				table.insert(self.show_data[cfg.pos][2], v)
			end
		else
			if v.checkGemIsLock then
				v.lock_status = v:checkGemIsLock() and 1 or 0
			else
				v.lock_status = 0
			end
			v.gem_pos = 0
			table.insert(self.back_data[1], v)
		end
	end
	for i, v in pairs(self.back_data) do
		local sort_func = SortTools.tableCommonSorter({{"lock_status",true},{"quality",true},{"gem_pos",false},{"base_id",true}})
		table.sort(v, sort_func)
	end
	for key, value in pairs(self.show_data) do
		for k, v in pairs(value) do
			local sort_func = SortTools.tableCommonSorter({{"lock_status",true},{"quality",true},{"gem_pos",false},{"base_id",true}})
			table.sort(v, sort_func)
		end
	end
	if self.cur_pos == -1 then
		self:_onClickPos(0)
	else
		local index = self.cur_pos
		self.cur_pos = -1
		self:_onClickPos(index)
	end
	self:updateItemNumPanel()
end

function GemstoneBagWindow:close_callback(  )
	self:_onClickCloseBtn()
end