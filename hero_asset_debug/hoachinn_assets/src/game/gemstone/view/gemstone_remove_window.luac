--------------------------------------------
-- 
-- 
-- @Date    : 2019-01-16 19:09:44
-- @description    : 
		-- 宝石分解
---------------------------------

GemstoneRemoveWindow = GemstoneRemoveWindow or BaseClass(BaseView)

local controller = GemstoneController:getInstance()
local model = controller:getModel()
local back_controller = BackpackController:getInstance()
local back_model = back_controller:getModel()

function GemstoneRemoveWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Big  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.layout_name = "gemstone/gemstone_remove_window"
	self.cur_pos = -1
	self.click_list = {}
	self.click_num = 0
	self.remove_max = Config.PartnerGemData.data_constant.break_down_limit.val
	self.auto_max_quality = Config.PartnerGemData.data_constant.break_down_quality.val
	ActionController:getInstance():sender16808({
		ActionStorageBool.gemAutoRemove,
		ActionStorageBool.gemIsAutoRemove
	})
end

function GemstoneRemoveWindow:open_callback(  )
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
	self.auto_btn = self.main_container:getChildByName("auto_btn")
	self.auto_txt = self.auto_btn:getChildByName("label")
	self.auto_txt:setString(TI18N("语言_c_6104"))
	self.remove_btn = self.main_container:getChildByName("remove_btn")
	self.remove_txt = self.remove_btn:getChildByName("label")
	self.remove_txt:setString(TI18N("语言_c_2958"))
	self.choose_txt = self.main_container:getChildByName("choose_txt")
	self.choose_txt:setString(string.format(TI18N("语言_c_2973"),self.click_num,self.remove_max))
	self.Image_17 = self.main_container:getChildByName("Image_17")
	self.title_label = self.main_container:getChildByName("title_label")
	self.title_label:setString(TI18N("语言_c_2958"))
	autoSizeTitleBg(self.title_label, self.Image_17)
	self.close_btn = self.main_container:getChildByName("close_btn")
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
	
    --拥有宝石数量
    self.lab_have_count = self.main_container:getChildByName("lab_have_count")
	--自动献祭
    self.checkBox = self.main_container:getChildByName("checkbox")
    self.select_lay = self.main_container:getChildByName("select_lay")
    self.select_btn = self.select_lay:getChildByName("select_btn")
    self.scroll = self.select_lay:getChildByName("scroll")
	self:setAutoSacrificeStatus()
    self:createSelectList()

end

--自动献祭状态
function GemstoneRemoveWindow:setAutoSacrificeStatus()
    local status = model:getGemIsSacrifice()
    if status then
        self.checkBox:setSelected(true)
        self.temp_select = status
    else
        self.checkBox:setSelected(false)
    end
end

--生成选项框
function GemstoneRemoveWindow:createSelectList()
    local nowStatus = model:getHeroSacrificeNum()
    self.temp_auto_select = nowStatus
    local cfg = Config.PartnerGemData.data_constant.gem_select
    local desc = cfg.desc
    local diffItem = cfg.val[self.temp_auto_select] or cfg.val[1]
	local quality_name = BackPackConst.quality_name[diffItem[1]]
    self.checkBox:getChildByName("name"):setString(string.format(TI18N(desc),diffItem[2], quality_name))
    self.scroll:setContentSize(354,95)
    self.scroll:setVisible(false)
    if not self.selectList then
        self.selectList = {}
    end
    local _y = 0
    local _x = 0
    for i = 1, tableLen(cfg.val) do
        if not self.selectList[i] then
            self.selectList[i] = GemstoneRemoveItem.new()
            self.scroll:addChild(self.selectList[i])
            if self.selectList[i] then
                self.selectList[i]:setData(i)
            end
        end
        local height = self.selectList[i]:getRootHeight()
        self.selectList[i]:setPosition(_x, _y)
        _y = _y + height + 2
    end
    self.scroll:setContentSize(cc.size(375,_y))
    local ps = self.select_lay:getChildByName("Image_2"):getPositionY()
    self.scroll:setPositionY(ps - _y - 40)
end
--点击展开选项框
function GemstoneRemoveWindow:onClickBtnSelect()
    self.select_open_status = not self.select_open_status
    if self.select_open_status == true then
        self.select_btn:setRotation(180)
        local sh = self.scroll:getContentSize().height
        self.select_lay:getChildByName("Image_2"):setContentSize(cc.size(375,sh + 48))
    else
        self.select_btn:setRotation(0)
        self.select_lay:getChildByName("Image_2"):setContentSize(cc.size(375,41))
    end
    self.scroll:setVisible(self.select_open_status)
    if self.temp_auto_select == 0 then
        local nowStatus = model:getHeroSacrificeNum()
        self.temp_auto_select = nowStatus or 1
    end
    for index, value in ipairs(self.selectList) do
        if value then
            value:updateSelect()
            value:setnowselect(false)
        end
        if index == self.temp_auto_select and value then
            value:setnowselect(true)
        end
    end
end
function GemstoneRemoveWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), true, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
    registerButtonEventListener(self.select_lay, handler(self, self.onClickBtnSelect) ,false)
	registerButtonEventListener(self.remove_btn, handler(self, self.onClickBtnRemove) ,true)
	registerButtonEventListener(self.auto_btn, handler(self, self.onClickBtnAuto) ,true)
	for i = 0, 6 do
		registerButtonEventListener(self.choose_list[i], function()
			self:_onClickPos(self.choose_list[i].index)
		end, true, 2)
	end
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
			self:openRootWnd()
		end
	end)
    --自动分解相关
	self:addGlobalEvent(GemstoneEvent.Auto_Sacrifice_Event, function(sele)
		local nowStatus = model:getHeroSacrificeNum()
		self.temp_auto_select = sele
		local cfg = Config.PartnerGemData.data_constant.gem_select
		local desc = cfg.desc
		local diffItem = cfg.val[sele] or cfg.val[1]
		local quality_name = BackPackConst.quality_name[diffItem[1]]
		self.checkBox:getChildByName("name"):setString(string.format(TI18N(desc),diffItem[2], quality_name))
		if sele ~= 0 then
			if nowStatus ~= 0 then --说明已经勾选选项框
				model:setHeroSacrificelist(self.temp_auto_select)
			end
		end
		self:onClickBtnSelect()
	end)
	self:addGlobalEvent(GemstoneEvent.Gem_Sacrifice_Event, function()
		self:setAutoSacrificeStatus()
		self.scroll:setVisible(false)
	end)
    self:registerCheckBoxEvent(self.checkBox)
end

--注册选项框事件
function GemstoneRemoveWindow:registerCheckBoxEvent(btn)
    if not btn then return end
	btn:addEventListener(function(sender,event_type)
	    if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
			if self.temp_auto_select == 0 then
				self.temp_auto_select = 1
				model:setHeroSacrificelist(self.temp_auto_select)
			end
			ActionController:getInstance():sender16809(ActionStorageBool.gemIsAutoRemove,1)
	        btn:setSelected(true)
	    elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
			ActionController:getInstance():sender16809(ActionStorageBool.gemIsAutoRemove,0)
            btn:setSelected(false)
	    end
    end)
end
function GemstoneRemoveWindow:_onClickCloseBtn()
	controller:openGemstoneRemoveWindow(false)
end
function GemstoneRemoveWindow:onClickBtnAuto()
	if self.show_list and next(self.show_list) then
		for k, v in pairs(self.show_list) do
			if self.click_num >= self.remove_max then
				break
			end
			if not self.click_list[v.id] and v.quality <= self.auto_max_quality then
				self.click_num = self.click_num + 1
				self.click_list[v.id] = true
			end
		end
		if self.click_num == 0 then
			message(TI18N("语言_c_7167"))
		end
		self.choose_txt:setString(string.format(TI18N("语言_c_2973"),self.click_num,self.remove_max))
		self.item_scrollview:reloadData(nil,nil,true)
	end
end
function GemstoneRemoveWindow:onClickBtnRemove()
	local is_show_tips = false
	local item_count = 0
	local sell_equip_list = {}
	for k, v in pairs(self.click_list) do
		if v then
			item_count = item_count + 1
			local base_id = 0
			local good_vo = back_model:getGamPackItemById(k)
			if good_vo then
				base_id = good_vo.base_id
				local cfg = Config.ItemData.data_get_data(base_id)
				table.insert(sell_equip_list, {id=k,bid=cfg.id,num=1})
				if not is_show_tips and cfg.quality >= BackPackConst.quality.orange then
					is_show_tips = true
				end
			end
		end
	end
	-- controller:sender22805(list)
	if next(sell_equip_list) ~= nil then
		--请求售出获得
		back_controller:sender10521(BackPackConst.Bag_Code.GEMSTONE, sell_equip_list)
		back_controller:openSellConfirmWindow(true, function()
            --售出装备
            back_controller:sender10522(BackPackConst.Bag_Code.GEMSTONE, sell_equip_list)
        end, BackPackConst.Bag_Code.GEMSTONE, is_show_tips, item_count)
		-- self:_onClickCloseBtn()
    else
    	message(TI18N("语言_c_3442"))
	end
end

--点击筛选
function GemstoneRemoveWindow:_onClickPos(index)
	if self.cur_pos == index then return end
	self.cur_pos = index
	self.select_img:setPositionX(self.choose_list[index]:getPositionX())
	if index == 0 then
		self.show_list = self.back_data
	else
		self.show_list = self.show_data[index]
	end
	self.click_list = {}
	self.click_num = 0
	self.choose_txt:setString(string.format(TI18N("语言_c_2973"),self.click_num,self.remove_max))
	self.item_scrollview:reloadData()
	if self.show_list and next(self.show_list) then
		commonShowEmptyIcon(self.item_scrollview,false)
	else
		commonShowEmptyIcon(self.item_scrollview,true)
	end
end

function GemstoneRemoveWindow:createNewCell(width, height)
    local cell = BackPackItem.new(false,true,nil,0.9)
	local fun = function()
		local data = cell:getData()
		if data.checkGemIsLock then
			if data:checkGemIsLock() then
				message(TI18N("语言_c_7131"))
				return
			end
		end
		if self.click_num >= self.remove_max then
			message(string.format(TI18N("语言_c_7132"),self.remove_max))
		else
			local id = data.id
			if not self.click_list[id] then
				self.click_list[id] = true
				cell:setCommonStatus(true)
				self.click_num = self.click_num + 1
			else
				self.click_list[id] = false
				cell:setCommonStatus(false)
				self.click_num = self.click_num - 1
			end
			self.choose_txt:setString(string.format(TI18N("语言_c_2973"),self.click_num,self.remove_max))
		end
	end
	cell:addCallBack(fun)
	local long_fun = function()
		local data = cell:getData()
		local bid = data.bid or data.base_id or data.id or data[1]
		local setting = {}
		setting.data = bid
		setting.gem_list = data
		if data.main_attr and next(data.main_attr) then
			GemstoneController:getInstance():openGemstoneTipsWindow(true,setting)
		end
	end
	cell:addLongTimeTouchCallback(long_fun)
    return cell
end

function GemstoneRemoveWindow:numberOfCells()
    if not self.show_list then
        return 0
    end
    return #self.show_list
end
-- 更新cell(拖动的时候.刷新数据时候会执行次方法)
-- cell :createNewCell的返回的对象
-- index :数据的索引
function GemstoneRemoveWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then
        return
    end
    cell:setData(cell_data)
	if self.click_list[cell_data.id] then
		cell:setCommonStatus(true)
	else
		cell:setCommonStatus(false)
	end
	if cell_data.checkGemIsLock then
		if cell_data:checkGemIsLock() then
			cell:showGemLockStatus(true,true,function()
				message(TI18N("语言_c_7590"))
			end)
		else
			cell:showGemLockStatus(false,false)
		end
	else
		cell:showGemLockStatus(false,false)
	end
end
function GemstoneRemoveWindow:openRootWnd()
	self.show_data = {}
	self.back_data = {}
	local data = back_model:getBagItemList(BackPackConst.item_tab_type.GEMSTONE)
	for i, v in pairs(data) do
		local cfg = Config.PartnerGemData.data_base_info[v.base_id]
		if cfg then
			v.gem_pos = cfg.pos
			if not self.show_data[cfg.pos] then
				self.show_data[cfg.pos] = {}
			end
			if v.checkGemIsLock then
				if v:checkGemIsLock() then
					v.lock_status = 1
				else
					v.lock_status = 0
				end
			else
				v.lock_status = 0
			end
			table.insert(self.show_data[cfg.pos], v)
			table.insert(self.back_data, v)
		end
	end
	local sort_func = SortTools.tableCommonSorter({{"lock_status",false},{"quality",true},{"gem_pos",true},{"base_id",true}})
	table.sort(self.back_data, sort_func)
	for i, v in pairs(self.show_data) do
		local sort_func = SortTools.tableCommonSorter({{"lock_status",false},{"quality",true},{"gem_pos",true},{"base_id",true}})
		table.sort(v, sort_func)
	end
	if self.cur_pos == -1 then
		self:_onClickPos(0)
	else
		local index = self.cur_pos
		self.cur_pos = -1
		self:_onClickPos(index)
	end
	self.lab_have_count:setString(string.format(TI18N("语言_c_7133"),#self.back_data))
end

function GemstoneRemoveWindow:close_callback(  )
	model:autoSacrifice()
	self:_onClickCloseBtn()
end