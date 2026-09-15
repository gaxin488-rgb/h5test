--------------------------------------------
-- 
-- 
-- @Date    : 2019-01-16 19:09:44
-- @description    : 
		-- 宝石共鸣
---------------------------------

GemstoneResonanceWindow = GemstoneResonanceWindow or BaseClass(BaseView)

local _controller = GemstoneController:getInstance()
local _model = _controller:getModel()

function GemstoneResonanceWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Mini  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
	self.career_list = {}
	self.attr_list = {}
	self.hero_list = {}
	self.all_status = {}
	self.all_num_list = {}
	self.all_hero_list = {}
	self.click_index = 1
    self.layout_name = "gemstone/gemstone_resonance_window"
end

function GemstoneResonanceWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 2)
	self.Image_2 = self.main_panel:getChildByName("Image_2")
	self.title_txt = self.main_panel:getChildByName("title_txt")
	self.title_txt:setString(TI18N("语言_par_gem_help_1_05"))
	autoSizeTitleBg(self.title_txt,self.Image_2)
	self.top_panel = self.main_panel:getChildByName("top_panel")
	for i = 2, 5 do
		self.career_list[i] = self.top_panel:getChildByName("career_"..i)
	end
	self.click_img = self.top_panel:getChildByName("click_img")
	self.resonance_panel = self.main_panel:getChildByName("resonance_panel")
	self.line_2 = self.resonance_panel:getChildByName("line_2")
	self.resonance_title = self.resonance_panel:getChildByName("resonance_title")
	self.resonance_title:setString(TI18N("语言_par_gem_help_1_05"))
	self.line_1 = self.resonance_panel:getChildByName("line_1")
	setTextTweenBg(self.resonance_title,self.line_1,self.line_2,nil,20,true)
	self.resonance_scroll = self.resonance_panel:getChildByName("resonance_scroll")
	self.resonance_scroll:setScrollBarEnabled(false)
	self.hero_panel = self.main_panel:getChildByName("hero_panel")
	self.line_4 = self.hero_panel:getChildByName("line_4")
	self.hero_title = self.hero_panel:getChildByName("hero_title")
	self.hero_title:setString(TI18N("语言_c_7135"))
	self.line_3 = self.hero_panel:getChildByName("line_3")
	setTextTweenBg(self.hero_title,self.line_3,self.line_4,nil,20,true)
	self.hero_scroll = self.hero_panel:getChildByName("hero_scroll")
	if self.scroll_view == nil then
        local scroll_view_size = self.hero_scroll:getContentSize()
        local list_setting = {
            start_x = 20,
            space_x = 0,
            start_y = 0,
            space_y = 0,
            item_width = 120,
            item_height = 150,
            row = 1,
            col = 5,
            need_dynamic = true
        }
        self.scroll_view = CommonScrollViewSingleLayout.new(self.hero_scroll, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

        self.scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
	self.close_btn = self.main_panel:getChildByName("close_btn")
end

function GemstoneResonanceWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
	for k, v in pairs(self.career_list) do
		registerButtonEventListener(v, function()
			self:clickCareerList(k)
		end, false, 2)
	end
end

function GemstoneResonanceWindow:_onClickCloseBtn(  )
	_controller:openGemstoneResonanceWindow(false)
end


function GemstoneResonanceWindow:openRootWnd(  )
	self.data_fetter = Config.PartnerGemData.data_fetter
	self:updateData()
	self:updateCareerSkill()
	self:clickCareerList(2)
end
--获取每个技能的激活情况
function GemstoneResonanceWindow:updateData()
	for key,value in pairs(self.data_fetter) do
		for k,v in pairs(value) do
			local status,hero_list,num = _model:getTrammelsIsOpenForScore(v.need_type,v.score)
			if not self.all_status[v.need_type] then
				self.all_status[v.need_type] = {}
			end
			if not self.all_num_list[v.need_type] then
				self.all_num_list[v.need_type] = {}
			end
			self.all_status[v.need_type][v.sort] = status
			self.all_num_list[v.need_type][v.sort] = num
			self.all_hero_list[v.need_type] = hero_list
		end
	end
end
--设置顶部技能激活情况
function GemstoneResonanceWindow:updateCareerSkill()
	for k,v in pairs(self.career_list) do
		if not v.img_list then
			v.img_list = {}
		end
		local status_list = self.all_status[k]
		if status_list and next(status_list) then
			local num = 0
			for key,value in pairs(status_list) do
				if value then
					num = num + 1
				end
			end
			if num > 0 then
				local start_x = 16-(num-1)*6
				for i=1,num do
					local img = createImage(v,PathTool.getResFrame("common", "common_90032"),start_x + (i-1)*12,-10,cc.p(0.5,0.5),true)
					img:setScale(0.5)
				end
			end
		end
	end
end
--点击顶部图标
function GemstoneResonanceWindow:clickCareerList(index)
	if self.click_index == index then return end
	if index < 2 or index > 5 then return end
	self.resonance_title:setString(PartnerConst.Hero_Type[index]..TI18N("语言_par_gem_help_1_05"))
	self.line_1 = self.resonance_panel:getChildByName("line_1")
	setTextTweenBg(self.resonance_title,self.line_1,self.line_2,nil,20,true)
	self.click_index = index
	self.click_img:setPositionX(self.career_list[self.click_index]:getPositionX())
	self:setAttrData()
	self:setHeroScroll()
end
function GemstoneResonanceWindow:setAttrData()
	self.cfg = self.data_fetter[self.click_index]
	if not self.attr_list then
		self.attr_list = {}
	end
	for i,v in ipairs(self.attr_list) do
		v:setVisible(false)
	end
	local scroll_h = 0
	local num = 20
	if judgingLanguage() then
		num = 8
	end
	for i,v in ipairs(self.cfg) do
		if not self.attr_list[i] then
			local item = ccui.Layout:create()
			item:setAnchorPoint(cc.p(0, 1))
			item.icon = createSprite(PathTool.getResFrame("common", "common_90032"),12,52,item,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
			item.attr_layout = ccui.Layout:create()
			item.attr_layout:setAnchorPoint(cc.p(0, 1))
			item.attr_layout:setContentSize(cc.size(550,40))
			item.attr_layout:setPositionX(30)
			item:addChild(item.attr_layout)
			item.attr_list = {}
			item.skill_des = createRichLabel(22,cc.c3b(0x7c, 0x55, 0x36),cc.p(0,1),cc.p(30,67),-4,nil,550)
			item:addChild(item.skill_des)
			item.lock_txt = createRichLabel(22,cc.c3b(0x7c, 0x55, 0x36),cc.p(0,1),cc.p(30,67),-4,nil,550)
			item:addChild(item.lock_txt)
			self.resonance_scroll:addChild(item)
			self.attr_list[i] = item
		end
		local item = self.attr_list[i]
		local top_h = 0
		item:setVisible(true)
		if v.attr and next(v.attr) then
			item.attr_layout:setVisible(true)
			item.skill_des:setVisible(false)
			if next(item.attr_list) then
				for key,value in ipairs(item.attr_list) do
					value:setVisible(false)
				end
			end
			local _h = math.ceil(tableLen(v.attr)/2)*40
			item.attr_layout:setContentSize(cc.size(item.attr_layout:getContentSize().width,_h))
			for key,value in ipairs(v.attr) do
				if not item.attr_list[key] then
					local layout = ccui.Layout:create()
					layout:setContentSize(cc.size(275,40))
					layout:setAnchorPoint(cc.p(0, 1))
					layout:setPosition(cc.p((key-1)%2*275,_h - math.floor((key-1)/2)*40))
					item.attr_layout:addChild(layout)
					layout.icon = createSprite(PathTool.getResFrame("common", "common_90021_9"),20,20,layout,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
					layout.name = createLabel(22,cc.c3b(0x7c, 0x55, 0x36),nil,40,20,"",layout,nil,cc.p(0,0.5))
					layout.value = createLabel(22,cc.c3b(0x7c, 0x55, 0x36),nil,50,20,"",layout,nil,cc.p(0,0.5))
					item.attr_list[key] = layout
				end
				local layout = item.attr_list[key]
				layout:setVisible(true)
				local attr_key = value[1]
				loadSpriteTexture(layout.icon, PathTool.getResFrame("common", PathTool.getAttrIconByStr(attr_key)), LOADTEXT_TYPE_PLIST)
				local attr_name = Config.AttrData.data_key_to_name[attr_key]
				if not attr_name then
					attr_name = Config.AttrExtraData.data_key_to_name[attr_key]
				end
				layout.name:setString(transformTextToShort(attr_name,num).." :")
				addEvt2showAllTextTips(layout.name,attr_name,num,nil,nil,nil,true)
				local attr_value = value[2]
				local is_per = PartnerCalculate.isShowPerByStr(attr_key)
				if is_per == true then
					attr_value = (attr_value*0.1).."%"
				end
				layout.value:setString(attr_value)
				layout.value:setPositionX(layout.name:getPositionX() + layout.name:getContentSize().width + 10)
			end
			top_h = item.attr_layout:getContentSize().height
		elseif v.effect and next(v.effect) then
			item.attr_layout:setVisible(false)
			item.skill_des:setVisible(true)
			local _txt = ""
			for key,value in ipairs(v.effect) do
				local skill_cfg = Config.SkillData.data_get_skill(value)
				if skill_cfg then
					if _txt == "" then
						_txt = skill_cfg.des
					else
						_txt = _txt .. "\n" ..skill_cfg.des
					end
				end
			end
			item.skill_des:setString(_txt)
			top_h = item.skill_des:getContentSize().height
		end

		-- local status = false
		-- local hero_list = {}
		-- if (not self.all_status[self.click_index] or not self.all_status[self.click_index][v.sort]) or (not self.all_hero_list[self.click_index] or not next(self.all_hero_list[self.click_index])) then
		-- 	if not self.all_status[self.click_index] then
		-- 		self.all_status[self.click_index] = {}
		-- 	end
		-- 	if not self.all_num_list[self.click_index] then
		-- 		self.all_num_list[self.click_index] = {}
		-- 	end
		-- 	status,hero_list,num = _model:getTrammelsIsOpenForScore(v.need_type,v.limit[1][1],v.limit[1][2])
		-- 	self.all_status[self.click_index][v.sort] = status
		-- 	self.all_num_list[self.click_index][v.sort] = num
		-- 	self.all_hero_list[self.click_index] = hero_list
		-- end
		local status = self.all_status[self.click_index][v.sort]
		self.hero_list = self.all_hero_list[self.click_index]
		if status then
			item.lock_txt:setFontColor(cc.c3b(0x0e,0xa8,0x0e))
		else
			item.lock_txt:setFontColor(cc.c3b(0xff,0x15,0x15))
		end
		local num = 0
		if self.all_num_list[self.click_index][v.sort] then
			num = self.all_num_list[self.click_index][v.sort]
		end
		local txt = string.format("(%s/%s)",num,v.score)
		if status then
			txt = string.format("(%s/%s)",v.score,v.score)
		end
		item.lock_txt:setString(LangStringFormat(v.desc2,v.score,txt))

		local _h = top_h + item.lock_txt:getContentSize().height + 10
		_h = math.max(_h, 70)
		item:setContentSize(cc.size(586, _h))
		item.icon:setPositionY(_h-18)
		item.skill_des:setPositionY(_h-3)
		item.attr_layout:setPositionY(_h-3)
		item.lock_txt:setPositionY(_h - top_h - 3)
		scroll_h = scroll_h + _h
	end
	scroll_h = math.max(scroll_h,self.resonance_scroll:getContentSize().height)
	self.resonance_scroll:setInnerContainerSize(cc.size(self.resonance_scroll:getContentSize().width, scroll_h))
	for i,v in ipairs(self.attr_list) do
		v:setPositionY(scroll_h)
		scroll_h = scroll_h - v:getContentSize().height
	end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function GemstoneResonanceWindow:createNewCell(width, height)
    local cell = GemstoneResonanceItem.new(width, height)
    return cell
end
--获取数据数量
function GemstoneResonanceWindow:numberOfCells()
    if not self.hero_list then return 0 end
    return #self.hero_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function GemstoneResonanceWindow:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.hero_list[index]
    cell:setData(hero_vo)
end

--点击cell .需要在 createNewCell 设置点击事件
function GemstoneResonanceWindow:onCellTouched(cell)
    local index = cell.index
    local hero_vo = self.hero_list[index]
    
end
function GemstoneResonanceWindow:setHeroScroll()
	self.scroll_view:reloadData()
    if #self.hero_list == 0 then
        commonShowEmptyIcon(self.scroll_view, true, {font_size = 22,scale = 1, offset_y = 0, text = TI18N("语言_c_6221")})
    else
        commonShowEmptyIcon(self.scroll_view, false)
    end
end
function GemstoneResonanceWindow:close_callback(  )
	for i,v in ipairs(self.attr_list) do
		v:removeFromParent()
		v=nil
	end
	self.attr_list = {}
	if self.scroll_view then 
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
	self:_onClickCloseBtn()
end




------------------------------------------
-- 功勋子项
GemstoneResonanceItem = class("GemstoneResonanceItem", function()
    return ccui.Widget:create()
end)

function GemstoneResonanceItem:ctor()
    self.size = cc.size(120, 150)
    self:configUI()
    self:register_event()
end

function GemstoneResonanceItem:configUI()
    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(self.size)
    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self:addChild(self.root_wnd)
    self.hero_item = HeroExhibitionItem.new(0.9, true)
    self.root_wnd:addChild(self.hero_item)
    self.hero_item:setPosition(cc.p(60,90))
    self.hero_item:addCallBack(function()
        local role_vo = RoleController:getInstance():getRoleVo()
        LookController:getInstance():sender11061(role_vo.rid, role_vo.srv_id, self.data.partner_id)
    end)
end

function GemstoneResonanceItem:register_event()

end
function GemstoneResonanceItem:setData(data)
    if not data then
        return
    end
    self.data = data
    self.hero_item:setData(self.data)
    local list_info = _model:getGemstoneInfo(self.data.partner_id)
    local num = 0
    if list_info and list_info.list_info and next(list_info.list_info) then
		for k, v in pairs(list_info.list_info) do
			num = num + _model:getScore(v)
		end
    end
	self.hero_item:setHeroName(true,num)
end

function GemstoneResonanceItem:DeleteMe()
    if self.hero_item then
        self.hero_item:DeleteMe()
        self.hero_item = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end
