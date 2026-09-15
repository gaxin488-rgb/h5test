--------------------------------------------
-- 
-- 
-- @Date    : 2019-01-16 19:09:44
-- @description    : 
		-- 宝石装备选择
---------------------------------

GemstoneEquipWindow = GemstoneEquipWindow or BaseClass(BaseView)

local controller = GemstoneController:getInstance()
local model = controller:getModel()

local hero_ctr = HeroController:getInstance()
local hero_model = hero_ctr:getModel()

function GemstoneEquipWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Big  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("hero","hero"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("stronger","stronger"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3"), type = ResourcesType.single },
    }
    self.layout_name = "gemstone/gemstone_equip_window"
	self.click_pos = 0
    self.click_quality = 0
end

function GemstoneEquipWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
	self.img_title_bg = self.main_container:getChildByName("img_title_bg")
	self.image_bg_2 = self.main_container:getChildByName("image_bg_2")
	self.image_bg_3 = self.main_container:getChildByName("image_bg_3")
	self.Image_22 = self.main_container:getChildByName("Image_22")
	self.image_bg_1 = self.main_container:getChildByName("image_bg_1")
	self.plan_list = self.main_container:getChildByName("plan_list")
	self.cur_panel = self.main_container:getChildByName("cur_panel")--头像
	self.click_bg = self.cur_panel:getChildByName("click_bg")--头像
    if not self.cur_hero_head then
        self.cur_hero_head = HeroExhibitionItem.new(1, true, 0, false)
        self.cur_hero_head:setPosition(cc.p(530, 192))
        self.cur_panel:addChild(self.cur_hero_head)
    end
	self.pos_item_list = {}
	for i = 1, 6 do
		local item = BackPackItem.new(false,true,nil,0.75,false)
		item.index = i
		item:setPosition(cc.p(50 + (i-1)*99, 50))
		item:addCallBack(function() self:selectPosByIndex(i) end)
		item:showAddIcon(true)
		item:showGemPos(true,i)
		self.cur_panel:addChild(item)
		self.pos_item_list[i] = item
	end
	self.wnd_title = self.main_container:getChildByName("wnd_title")
	self.wnd_title:setString(TI18N("语言_c_7121"))
	autoSizeTitleBg(self.wnd_title,self.img_title_bg)
	self.name_lab = self.main_container:getChildByName("name_lab")
	self.name_lab:setString(TI18N("语言_c_7136"))
    self.show_scroll = self.main_container:getChildByName("show_scroll")
    self.show_scroll:setScrollBarEnabled(false)
    self.show_scroll_list = {}
	-- self.show_txt = createRichLabel(22,cc.c3b(0x64,0x32,0x23),cc.p(0,1),cc.p(0,0),-4,nil,400)
	-- self.show_scroll:addChild(self.show_txt)
	self.zone_btn = self.main_container:getChildByName("zone_btn")
	self.panel_bg = self.zone_btn:getChildByName("panel_bg")
	self.arrow_btn = self.zone_btn:getChildByName("arrow_btn")
	self.arrow = self.arrow_btn:getChildByName("arrow")
	self.zone_name = self.zone_btn:getChildByName("zone_name")
	self.filter_panel = self.main_container:getChildByName("filter_panel")
    self.filter_panel:setVisible(false)
	self.close_btn = self.main_container:getChildByName("close_btn")
    self.source_btn = self.main_container:getChildByName("source_btn")
    self.source_txt = self.source_btn:getChildByName("label")
    setTextSpacing(self.source_txt,-8)
    self.source_txt:setString(TI18N("语言_c_970"))
    autoSizeTitleBg(self.source_txt,self.source_btn,10,200)
    self.source_txt:setPositionX(self.source_btn:getContentSize().width*0.5)
	self.combobox_panel = self.main_container:getChildByName("combobox_panel")
    self.combobox_panel:setVisible(false)
    self.combobox_max_size = self.combobox_panel:getContentSize()
	self.combobox_bg = self.combobox_panel:getChildByName("bg")
    self.combobox_bg_size = self.combobox_bg:getContentSize()
end

function GemstoneEquipWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), true, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
    registerButtonEventListener(self.zone_btn, function() self:_onClickArrowBtn() end, true, 2)
    registerButtonEventListener(self.source_btn, function() self:_onClickSourceBtn() end, true, 2)
    registerButtonEventListener(self.filter_panel, function()
        self.filter_panel:setVisible(false)
        self.combobox_panel:setVisible(false)
    end, false, 2)
    self:addGlobalEvent(GemstoneEvent.Update_Hero_Info, function ( pid )
    	if self.hero_id == pid then
            self.total_show_list = nil
            self.first_pos = self.click_pos
            self.click_pos = 0
			self:setData()
		end
    end)
end

function GemstoneEquipWindow:_onClickCloseBtn(  )
	controller:openGemstoneEquipWindow(false)
end

function GemstoneEquipWindow:updateSuitFilterList()
    if self.dic_suit_list == nil then
        local config_list = BackPackConst.quality_name

        self.dic_suit_list = {}
        for i,v in pairs(config_list) do
            if i > 1 and i < 6 then
                local data = {}
                data.id = i
                data.name = v
                data.is_select = false
                table.insert(self.dic_suit_list, data)
            end
        end
        local data = {}
        data.id = 0
        data.name = TI18N("语言_c_6701")
        data.is_select = true
        table.insert(self.dic_suit_list, data)
        table.sort(self.dic_suit_list, function(a, b) return a.id < b.id end)
    else
        for i,v in ipairs(self.dic_suit_list) do
            if v.id == 0 then
                v.is_select = true
            else
                v.is_select = false
            end
        end
    end

    if self.zone_name  then
        self.zone_name:setString(transformTextToShort(self.dic_suit_list[1].name,10))
        addEvt2showAllTextTips(self.zone_name,self.dic_suit_list[1].name,10)
    end
end
function GemstoneEquipWindow:_onClickArrowBtn()
    if not self.show_list then return end
    self.filter_panel:setVisible(true)
    self.combobox_panel:setVisible(true)
    self:updateComboboxList2(self.dic_suit_list)
end
function GemstoneEquipWindow:_onClickSourceBtn()
    local data = {
        source=Config.PartnerGemData.data_constant.gem_source.val
    }
    BackpackController:getInstance():openTipsOnlySource(true, data)
end
--更新下拉列表 
function GemstoneEquipWindow:updateComboboxList2(data_list)
    if not data_list then return end
    local item_height = 55
    if self.combobox_scrollview2 == nil then
        local setting = {
            start_x = 2,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 230,                -- 单元的尺寸width
            item_height = item_height,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.combobox_scrollview2 = CommonScrollViewSingleLayout.new(self.combobox_panel, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, self.combobox_max_size, setting, cc.p(0, 0))

        self.combobox_scrollview2:registerScriptHandlerSingle(handler(self,self.createNewCellCombobox2), ScrollViewFuncType.CreateNewCell) --创建cell
        self.combobox_scrollview2:registerScriptHandlerSingle(handler(self,self.numberOfCellsCombobox2), ScrollViewFuncType.NumberOfCells) --获取数量
        self.combobox_scrollview2:registerScriptHandlerSingle(handler(self,self.updateCellByIndexCombobox2), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    if next(data_list) ~= nil then 
        local count = #data_list
        self.combobox_scrollview2:setClickEnabled(true)
        self.combobox_bg:setContentSize(self.combobox_bg_size)
        self.comboboxshow_list2 = data_list
        local select_index = nil

        self.combobox_scrollview2:reloadData(select_index)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function GemstoneEquipWindow:createNewCellCombobox2(width, height)
    local cell = ccui.Layout:create()
    cell:setAnchorPoint(0.5,0.5)
    cell:setContentSize(cc.size(width, height))

    cell.root_wnd = createCSBNote(PathTool.getTargetCSB("hero/hero_holy_equip_filter_item2"))
    cell:addChild(cell.root_wnd)
    local container = cell.root_wnd:getChildByName("container")
    cell.name = container:getChildByName("name")
    cell.name:setSwallowTouches(false)
    cell.checkbox = container:getChildByName("checkbox")

    cell.checkbox:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.began then
                cell.check_box_status = cell.checkbox:isSelected()
            elseif event_type == ccui.TouchEventType.ended then
                self:setCellTouchedCombobox2(cell)
            elseif event_type == ccui.TouchEventType.canceled then
                cell.checkbox:setSelected(cell.check_box_status or false)
            end
        end
    )
    return cell
end

--获取数据数量
function GemstoneEquipWindow:numberOfCellsCombobox2()
    if not self.comboboxshow_list2 then return 0 end
    return #self.comboboxshow_list2
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function GemstoneEquipWindow:updateCellByIndexCombobox2(cell, index)
    cell.index = index
    local data = self.comboboxshow_list2[index]
    if not data then return end
    cell.name:setString(transformTextToShort(data.name,8))
    addEvt2showAllTextTips(cell.name,data.name,8)
    if data.is_select then
        cell.checkbox:setSelected(true)
    else
        cell.checkbox:setSelected(false)
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function GemstoneEquipWindow:setCellTouchedCombobox2(cell)
    local index = cell.index
    local data = self.comboboxshow_list2[index]
    self.click_quality = data.id
    if not data then return end
    if data.is_select == true then
        cell.checkbox:setSelected(true)
        return
    end
    local is_select = cell.checkbox:isSelected()
    data.is_select = is_select

    --过滤条件
    for i,v in ipairs(self.comboboxshow_list2) do
        v.is_select = false
    end

    local is_select = cell.checkbox:isSelected()
    data.is_select = is_select
    self.combobox_scrollview2:resetCurrentItems()

    --过滤条件
    if self.zone_name then
        self.zone_name:setString(transformTextToShort(data.name,10))
        addEvt2showAllTextTips(self.zone_name,data.name,10)
    end
    self:updateEquipList()
end

function GemstoneEquipWindow:openRootWnd(hero_id,pos)
	self.hero_id = hero_id or 1
    self.first_pos = pos or 1
    self:updateSuitFilterList()
	self:setData()
end

function GemstoneEquipWindow:setData()
	self.data = model:getGemstoneInfo(self.hero_id)
	self.hero_vo = hero_model:getHeroById(self.hero_id)
	if self.hero_vo then
        self.cur_hero_head:setData(self.hero_vo)
        self.cur_hero_head:showStrTips(false)
    else
        self.cur_hero_head:showStrTips(true, TI18N("语言_c_3248"),nil,22)
    end
	self:updateShowTxt()
	self:updatePosItem()
    self:selectPosByIndex(self.first_pos)
    self:updatePosRed()
end
function GemstoneEquipWindow:updatePosRed()
    local cfg = Config.PartnerGemData.data_lv_info
    for i=1,#self.pos_item_list do
        local item = self.pos_item_list[i]
        local pos = item.index
        local status = false
        if cfg[pos] and cfg[pos][1] and self.hero_vo.star >= cfg[pos][1].need_star then
            status = model:getGemEquipOneRed(self.hero_id,pos)
        end
        addRedPointToNodeByStatus(item,status,10,10)
    end
end
--刷新当前装备品质数量
function GemstoneEquipWindow:updateShowTxt()
    if not self.show_scroll_list then
        self.show_scroll_list = {}
    end
    for i,v in ipairs(self.show_scroll_list) do
        v:removeFromParent()
        v=nil
    end
    self.show_scroll_list = {}
    self.skill_cfg = Config.PartnerGemData.data_skill2[hero_model:getSelfConvertStaBid(self.hero_vo.bid)] or {}
	self.skill_list = {}
	for i,v in pairs(self.skill_cfg) do
		table.insert(self.skill_list, v)
	end
	local sort_func = SortTools.tableCommonSorter({{"quality", false},{"num", false}})
	table.sort(self.skill_list, sort_func)
    local scroll_h = 0
    local list = {}
    local h_list = {}
    local num = 0
	for k, v in ipairs(self.skill_list) do
		local item,_h,status = self:getSkillItem(v)
        if status then
            num = k
        end
        h_list[k] = _h
		list[k] = item
	end
    local str_num = 30
    if judgingLanguage() then
        str_num = 15
    end
    local name_lab_txt = ""
    if num == 0 then
        if list[1] then
            table.insert(self.show_scroll_list,list[1])
            scroll_h = h_list[1]
            name_lab_txt = list[1].name_txt
        end
    else
        if list[num] and list[num+1] then
            table.insert(self.show_scroll_list,list[num])
            table.insert(self.show_scroll_list,list[num+1])
            scroll_h = h_list[num] + h_list[num+1] + 5
            name_lab_txt = list[num].name_txt
        elseif list[num] then
            table.insert(self.show_scroll_list,list[num])
            scroll_h = h_list[num]
            name_lab_txt = list[num].name_txt
        end
    end
    self.name_lab:setString(transformTextToShort(name_lab_txt,str_num))
    addEvt2showAllTextTips(self.name_lab,name_lab_txt,str_num)
    local _h = math.max(self.show_scroll:getContentSize().height,scroll_h)
    self.show_scroll:setInnerContainerSize(cc.size(self.show_scroll:getContentSize().width,_h))
    for k, v in ipairs(self.show_scroll_list) do
        self.show_scroll:addChild(v)
		v:setPosition(cc.p(0, _h))
		_h = _h - v:getContentSize().height - 5
	end
end

function GemstoneEquipWindow:getSkillItem(data)
	local item = ccui.Layout:create()
    item:setAnchorPoint(cc.p(0, 1))
	local _w = 400
	local _h = 30
	item:setContentSize(cc.size(_w, _h))
    local status = false
	local skill_cfg = Config.SkillData.data_get_skill(data.desc)
	if skill_cfg then
		if data.desc and data.desc ~= 0 and Config.SkillData.data_get_skill(data.desc) then
			skill_cfg = Config.SkillData.data_get_skill(data.desc)
		end
		local name_txt = skill_cfg.name
        item.name_txt = name_txt
		item.skill_name = createLabel(22,cc.c3b(0xfe,0xee,0xba),nil,30,0,"",item,-4,cc.p(0,1))
		item.skill_name:setWidth(370)
		local quality_name = BackPackConst.quality_name[data.quality]
        local level = skill_cfg.level or 1
        if skill_cfg.client_lev and skill_cfg.client_lev>0 then
            level = skill_cfg.client_lev
        end
        local lev_txt = string.format(TI18N("语言_c_4712"),level)
        item.skill_name:setString(lev_txt.." "..LangStringFormat(data.desc3,data.num,quality_name))
		item.lock_icon = createSprite(PathTool.getResFrame("common", "common_1043"),20,50,item,cc.p(0.5,0.5),LOADTEXT_TYPE)
		item.lock_icon:setScale(0.5)
        status = model:getResonanceIsOpen(self.hero_vo.partner_id,data.desc)
		if status then
			item.skill_name:setTextColor(cc.c3b(0x0e,0xa8,0x0e))
			loadSpriteTexture(item.lock_icon, PathTool.getResFrame("common", "common_1043"), LOADTEXT_TYPE_PLIST)
		else
			item.skill_name:setTextColor(cc.c3b(0xff,0x15,0x15))
			loadSpriteTexture(item.lock_icon, PathTool.getResFrame("common", "common_90009_1"), LOADTEXT_TYPE_PLIST)
		end
		local need_h = math.max(item.lock_icon:getContentSize().height*item.lock_icon:getScale(),item.skill_name:getContentSize().height)
		_h = math.max(_h, need_h)
		item:setContentSize(cc.size(_w, _h))
		item.skill_name:setPositionY(_h)
		item.lock_icon:setPositionY(_h - 15)
	end

    return item,_h,status
end
--刷新6个装备槽位
function GemstoneEquipWindow:updatePosItem()
	if not self.hero_vo then return end
	for i=1,6 do
		local item = self.pos_item_list[i]
		if Config.PartnerGemData.data_lv_info[i] then
			local pos_cfg = Config.PartnerGemData.data_lv_info[i][1]
			if pos_cfg then
				if pos_cfg.need_star and self.hero_vo.star >= pos_cfg.need_star then--已经解锁
					local pos_data = model:getOneGemstoneInfo(self.hero_id,i)
					if pos_data and pos_data.item_bid ~= 0 and Config.ItemData.data_get_data(pos_data.item_bid) then--已装备
						local item_cfg = Config.ItemData.data_get_data(pos_data.item_bid)
						item:setData(item_cfg)
						item:showAddIcon(false)
						item:showArtifactLock(false)
                        local lock_status = false
                        if pos_data.extra and next(pos_data.extra) then
                            for k, v in pairs(pos_data.extra) do
                                if v.extra_k == 1 then
                                    lock_status = v.extra_v == 1
                                    break
                                end
                            end
                        end
                        if lock_status then
                            item:showGemLockStatus(true,true,function()
                                -- GemstoneController:getInstance():sender22810(self.info.pid,self.info.pos,0)
                            end)
                        else
                            item:showGemLockStatus(false)
                        end
					else--未装备
						item:setData()
						item:showAddIcon(true)
						item:showArtifactLock(false)
                        item:showGemLockStatus(false)
					end
				else--未解锁
					item:setData()
					item:showAddIcon(false)
					item:showArtifactLock(true)
                    item:showGemLockStatus(false)
				end
			else
				item:setData()
				item:showAddIcon(false)
				item:showArtifactLock(true)
                item:showGemLockStatus(false)
			end
		else
			item:setData()
			item:showAddIcon(false)
			item:showArtifactLock(true)
            item:showGemLockStatus(false)
		end
	end
end
--点击槽位
function GemstoneEquipWindow:selectPosByIndex(index)
	if self.click_pos == index then return end
    if Config.PartnerGemData.data_lv_info[index] and Config.PartnerGemData.data_lv_info[index][1] then
        local pos_cfg = Config.PartnerGemData.data_lv_info[index][1]
        if self.hero_vo.star >= pos_cfg.need_star then--已经解锁
            self.click_pos = index
            self.click_bg:setPositionX(self.pos_item_list[index]:getPositionX())
            self:updateEquipList()
        else
            message(string.format(TI18N("语言_c_3035"),pos_cfg.need_star))
        end
    end
end
function GemstoneEquipWindow:updateEquipList()
	if self.list_view == nil then
        local scroll_view_size = self.plan_list:getContentSize()
        local setting = {
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 2,                   -- y方向的间隔
            item_width = 595,               -- 单元的尺寸width
            item_height = 141,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 1,                        -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.list_view = CommonScrollViewSingleLayout.new(self.plan_list, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    
    if self.total_show_list == nil then
        self.total_show_list = self:initEquipData()
    end
    self.show_list = self:filterCondition()

    if self.show_list == nil then return end
    if #self.show_list > 0 then
        local sort_func = SortTools.tableCommonSorter({{"sort", true}, {"quality", true}, {"score", true}, {"skill_num", true}, {"id", true}})
        table.sort(self.show_list, sort_func)
    end
    if next(self.show_list) == nil then 
        commonShowEmptyIcon(self.plan_list,true,{text=TI18N("语言_c_7146")})
    else
        commonShowEmptyIcon(self.plan_list,false)
    end

    self.list_view:reloadData()
end

function GemstoneEquipWindow:filterCondition()
    local show_list = self.total_show_list or {}
    local list = {}
    if self.click_quality == 0 then
        for i,v in ipairs(show_list) do
            if v.pos == self.click_pos then
                table.insert(list, v)
            end
        end
    else
        for i,v in ipairs(show_list) do
            if v.quality == self.click_quality and v.pos == self.click_pos then
                table.insert(list, v)
            end
        end
    end

    return list
end
--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function GemstoneEquipWindow:createNewCell(width, height)
    local cell = GemstoneEquipItem.new()
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function GemstoneEquipWindow:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function GemstoneEquipWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function GemstoneEquipWindow:onCellTouched(cell)
    local index = cell.index
    local cell_data = self.show_list[index]
    self:clickFun(cell_data)
end

function GemstoneEquipWindow:clickFun(info)
    if not info or not info.data then
        return
    end

    local vo = info.data
    if vo and vo.config then
        controller:sender22801(self.hero_id, vo.id,self.click_pos, 1) --穿戴
    else
        if model:checkGemBack(1,0,1) then
            controller:sender22801(self.hero_id, 0,self.click_pos, 0) --卸下
        else
            message(TI18N("语言_c_7153"))
        end
    end
end

function GemstoneEquipWindow:initEquipData()
    local click_pos = self.click_pos or 1
    --有穿戴的要创建穿戴的
    local show_list = {}
    local pos_data = model:getGemstoneInfo(self.hero_id)
    if pos_data and next(pos_data) ~=nil then 
        for k, v in pairs(pos_data.list_info) do
            local back_cfg = Config.ItemData.data_get_data(v.item_bid)
            if back_cfg then
                local skill_num = 0
                if v.item_skill and next(v.item_skill) then
                    skill_num = tableLen(v.item_skill)
                end
                table.insert(show_list, {data = v,sort = 1, quality=back_cfg.quality,id=v.item_bid,pos=v.pos,pid=self.hero_id,skill_num=skill_num,score=model:getScore(v)})
            end
        end
    end

    --背包的装备
    local list = BackpackController:getInstance():getModel():getBagItemList(BackPackConst.Bag_Code.GEMSTONE) or {}
    for i,v in pairs(list) do
        if v and v.config then
            local cfg = Config.PartnerGemData.data_base_info[v.config.id]
            if cfg then
                local skill_num = 0
                if v.extra_attr and next(v.extra_attr) then
                    skill_num = tableLen(v.extra_attr)
                end
                table.insert(show_list, {data = v,sort = 0, quality=v.config.quality,id=v.config.id,pos=cfg.pos,pid=self.hero_id,skill_num=skill_num,score=model:getScore(v)})
            end
        end
    end
    return show_list
end
function GemstoneEquipWindow:close_callback(  )
    if self.combobox_scrollview2 then
        self.combobox_scrollview2:DeleteMe()
        self.combobox_scrollview2 = nil
    end
    if self.list_view then
        self.list_view:DeleteMe()
        self.list_view = nil
    end
	self:_onClickCloseBtn()
end


-- --------------------------------------------------------------------
-- 宝石装备选择子项
-- 
-- (必填, 创建模块的人员)
-- (必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-2-27
-- --------------------------------------------------------------------
GemstoneEquipItem = class("GemstoneEquipItem", function()
    return ccui.Widget:create()
end)

function GemstoneEquipItem:ctor(open_type)  
    self.open_type = open_type or 1
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function GemstoneEquipItem:setExtendData(pid)
    self.pid = pid
end

function GemstoneEquipItem:config()
    self.size = cc.size(595.00,141)
    self:setContentSize(self.size)
    self.attr_list = {}
end
function GemstoneEquipItem:layoutUI()
    local csbPath = PathTool.getTargetCSB("gemstone/gemstone_equip_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.equip_item = BackPackItem.new(false,true,nil,1)
    self.equip_item:setPosition(cc.p(70,self.size.height/2))
    self.main_panel:addChild(self.equip_item)

    self.bg = self.main_panel:getChildByName("bg")
   
    self.cloth_btn = self.main_panel:getChildByName("lev_btn")
    self.cloth_txt = self.cloth_btn:getChildByName("label")
    self.cloth_txt:setString(TI18N("语言_c_2959"))
    
    --装备名字
    self.equip_name = createLabel(24,cc.c4b(0x64,0x32,0x23,0xff),nil,146,98,"",self.main_panel,0, cc.p(0,0))
end
function GemstoneEquipItem:updateBtnRed()
    local status = false
    local pid = 0
    if self.info and self.info.pid and self.info.pid ~= 0 then
        pid = self.info.pid
    end
    local pos = 0
    if self.info and self.info.pos and self.info.pos ~= 0 then
        pos = self.info.pos
    end
    if pid ~= 0 and pos ~= 0 then
        local list = model:getOneGemstoneInfo(pid,pos)
        if list and next(list) ~= nil then
            local item_id = list.item_bid
            if item_id ~= 0 then
                local cfg = Config.ItemData.data_get_data(item_id)
                if self.item_cfg.quality > cfg.quality then
                    status = true
                end
            else
                status = true
            end
        else
            status = true
        end
    end
    addRedPointToNodeByStatus(self.cloth_btn, status,10,10)
end
function GemstoneEquipItem:setData(info)
    if not info then return end
    if not info.data or not info.id then return end
    self.info = info
    self.item_cfg = {}
    self.back_data = {}
    local lock_status = false
    local skill_list = {}
    if info.data.config then --背包
        self.item_cfg = info.data.config
        self.cloth_btn:loadTexture(PathTool.getResFrame("common", "common_1027"), LOADTEXT_TYPE_PLIST)
        self.cloth_txt:setString(TI18N("语言_c_2959"))
        self.cloth_txt:setTextColor(cc.c3b(0xf8,0xef,0x76))
        self.cloth_txt:enableOutline(cc.c4b(0x5c,0x27,0x05,0xff),2)
        self.back_data = info.data
        local back = function()
            local setting = {}
            local data = info.data
            setting.data = info.id
            setting.gem_list = data
            setting.pid = self.pid
            controller:openGemstoneTipsWindow(true,setting)
        end
        self.equip_item:addCallBack(back)
        if self.info.data and self.info.data.extra and next(self.info.data.extra) then
            for k, v in pairs(self.info.data.extra) do
                if v.extra_k == 1 then
                    lock_status = v.extra_v == 1
                    break
                end
            end
        end
        if lock_status then
            self.equip_item:showGemLockStatus(true,true,function()
                -- GemstoneController:getInstance():sender22810(0,0,info.data.id)
            end)
        else
            self.equip_item:showGemLockStatus(false)
        end
        skill_list = self.info.data.extra_attr or self.gem_list.item_skill or {}
    else --忍者
        local cfg = Config.ItemData.data_get_data(info.id)
        if cfg then
            self.item_cfg = cfg
        end
        self.cloth_btn:loadTexture(PathTool.getResFrame("common", "common_1098"), LOADTEXT_TYPE_PLIST)
        self.cloth_txt:setString(TI18N("语言_c_2964"))
        self.cloth_txt:setTextColor(cc.c3b(0xff,0xff,0xff))
        self.cloth_txt:enableOutline(cc.c4b(0x18,0x31,0x5b,0xff),2)
        local back = function()
            local setting = {}
            local data = info.data
            setting.data = data.item_bid
            setting.pos_list = data
            setting.pid = self.pid
            controller:openGemstoneTipsWindow(true,setting)
        end
        self.equip_item:addCallBack(back)
        
        if self.info.data and self.info.data.extra and next(self.info.data.extra) then
            for k, v in pairs(self.info.data.extra) do
                if v.extra_k == 1 then
                    lock_status = v.extra_v == 1
                    break
                end
            end
        end
        if lock_status then
            self.equip_item:showGemLockStatus(true,true,function()
                -- GemstoneController:getInstance():sender22810(self.info.pid,self.info.pos,0)
            end)
        else
            self.equip_item:showGemLockStatus(false)
        end
        skill_list = self.info.data.item_skill
    end
    if not self.item_cfg or not next(self.item_cfg) then return end
    self.equip_name:setString(self.item_cfg.name)
    self.equip_item:setData(self.item_cfg)
    self.equip_item:showGemPos(true,info.pos)
    if not self.skill_list then
        self.skill_list = {}
    end
    for k, v in pairs(self.skill_list) do
        v:setVisible(false)
    end
    for k, v in pairs(skill_list) do
        local skill_id = v.skill_id or v.attr_val
        local cfg = Config.SkillData.data_get_skill(skill_id)
        if cfg then
            if not self.skill_list[k] then
                local item = SkillItem.new(true,true,true,0.3, true,true)
                item:setPosition(cc.p(32*k,32))
                item.background:setVisible(false)
                self.main_panel:addChild(item)
                self.skill_list[k] = item
            end
            self.skill_list[k]:setVisible(true)
            self.skill_list[k]:setData(cfg)
        end
    end
    self:updateHolyEquipInfo()
    self:updateBtnRed()
end


function GemstoneEquipItem:updateHolyEquipInfo()
    --基本属性的位置
    local label_x = 146
    local label_y = 76
    --属性值的x位置 y 位置和 label 一样
    local attr_x = 210
    local attr_y = 76


    if self.holy_base_label == nil then
        self.holy_base_label = createLabel(20, cc.c4b(0x64,0x32,0x23,0xff), nil, label_x, label_y, "", self.main_panel, 0, cc.p(0,0.5))
        self.holy_base_label:setString(TI18N("语言_c_851"))
    end
    attr_x = label_x + self.holy_base_label:getContentSize().width + 10
    for k, v in pairs(self.attr_list) do
        v:setVisible(false)
    end
    local attr_list = {}
    if self.info.data.item_attr then
        attr_list = self.info.data.item_attr
    else
        attr_list = self.info.data.main_attr
    end
    if attr_list and next(attr_list) ~= nil then
        for k,v in ipairs(attr_list) do
            local main_attr = v or {}
            local res, attr_name, attr_val = commonGetAttrInfoByIDValue(main_attr.attr_id, main_attr.attr_val)
    
            if res then
                if self.attr_list[k] == nil then
                    self.attr_list[k] = createRichLabel(20, cc.c4b(0x95,0x53,0x22,0xff), cc.p(0, 0.5), cc.p(attr_x, attr_y-(k-1)*21), nil, nil, 380)
                    self.main_panel:addChild(self.attr_list[k])
                end
                self.attr_list[k]:setVisible(true)
                local attr_str = string.format("<div fontcolor=#955322> %s %s </div>", attr_name, attr_val)
                self.attr_list[k]:setString(attr_str)
            end
        end
    end
end
--事件
function GemstoneEquipItem:registerEvents()
    registerButtonEventListener(self.cloth_btn, function()  --皮肤预览按钮屏蔽
		if self.call_fun then 
            self:call_fun(self.data)
        end
	end, true, 2)
    
end
function GemstoneEquipItem:clickHandler()
    if self.call_fun then 
        self:call_fun(self.data)
    end
end
function GemstoneEquipItem:addCallBack(call_fun)
    self.call_fun =call_fun
end

function GemstoneEquipItem:setVisibleStatus(bool)
    self:setVisible(bool)
end

function GemstoneEquipItem:DeleteMe()
    if self.equip_item then 
        self.equip_item:DeleteMe()
        self.equip_item = nil
    end
    self.data = nil
    self:removeFromParent()
end


