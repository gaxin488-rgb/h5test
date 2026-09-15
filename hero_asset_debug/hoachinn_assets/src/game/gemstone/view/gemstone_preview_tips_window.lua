--------------------------------------------
-- 
-- 
-- @Date    : 2019-01-16 19:09:44
-- @description    : 
		-- 宝石预览tips
---------------------------------

GemstonePreviewTipsWindow = GemstonePreviewTipsWindow or BaseClass(BaseView)

local _controller = GemstoneController:getInstance()

function GemstonePreviewTipsWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Mini  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
	self.page_index = 0
    self.layout_name = "gemstone/gemstone_preview_tips_window"
end

function GemstonePreviewTipsWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 2)
	self.container = self.main_panel:getChildByName("container")
	self.base_panel = self.container:getChildByName("base_panel")
	self.name = self.base_panel:getChildByName("name")
	self.equip_type = self.base_panel:getChildByName("equip_type")
	self.baseattr_panel = self.container:getChildByName("baseattr_panel")
	self.baseattr_label = self.baseattr_panel:getChildByName("label")
	self.baseattr_label:setString(TI18N("语言_c_7125"))
	self.skill_panel = self.container:getChildByName("skill_panel")
	self.skill_label = self.skill_panel:getChildByName("label")
	self.skill_label:setString(TI18N("语言_c_7126"))
	self.skill_scroll = self.skill_panel:getChildByName("skill_scroll")
	self.skill_scroll:setScrollBarEnabled(false)
	self.no_skill_txt = self.skill_panel:getChildByName("no_skill_txt")
	self.no_skill_txt:setString(TI18N("语言_c_7158"))
	setTextMaxWidth(self.no_skill_txt,400)
	self.no_skill_bg = self.skill_panel:getChildByName("no_skill_bg")
	self.no_skill_txt:setVisible(false)
	self.no_skill_bg:setVisible(false)
	self.close_btn = self.container:getChildByName("close_btn")
	self.item = self.root_wnd:getChildByName("item")
end

function GemstonePreviewTipsWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
end

function GemstonePreviewTipsWindow:_onClickCloseBtn(  )
	_controller:openGemstonePreviewTipsWindow(false)
end

function GemstonePreviewTipsWindow:openRootWnd(setting)
	setting = setting or {}
	self.data = setting.data or nil --宝石基本信息 --配置表 or 物品id
	self.gem_list = setting.gem_list or {} --宝石属性信息  背包
	if not self.data then return end
	if type(self.data) == "table" then
		self.item_id = self.data.bid or self.data.id or self.data[1]
	else
		self.item_id = self.data
	end
	local cfg = Config.PartnerGemData.data_base_info[self.item_id]
	if cfg and cfg.base_skill and next(cfg.base_skill) then
		self.main_panel:setContentSize(cc.size(555, self.main_panel:getContentSize().height))
		self.container:setContentSize(cc.size(555, self.container:getContentSize().height))
		self.base_panel:setContentSize(cc.size(555, self.base_panel:getContentSize().height))
		self.baseattr_panel:setContentSize(cc.size(555, self.baseattr_panel:getContentSize().height))
		self.skill_panel:setContentSize(cc.size(555, self.skill_panel:getContentSize().height))
		self.close_btn:setPositionX(543)
	else
		self.main_panel:setContentSize(cc.size(447, self.main_panel:getContentSize().height))
		self.container:setContentSize(cc.size(447, self.container:getContentSize().height))
		self.base_panel:setContentSize(cc.size(447, self.base_panel:getContentSize().height))
		self.baseattr_panel:setContentSize(cc.size(447, self.baseattr_panel:getContentSize().height))
		self.skill_panel:setContentSize(cc.size(447, self.skill_panel:getContentSize().height))
		self.close_btn:setPositionX(429)
	end	
	
	self.tip_h = 0
	if not self.tips_txt then
		local need_star = 0
		local cfg = Config.PartnerGemData.data_base_info[self.item_id]
		if cfg and cfg.pos ~= 0 then
			local config = Config.PartnerGemData.data_lv_info[cfg.pos]
			if config and config[1] then
				need_star = config[1].need_star
			end
		end
		if need_star ~= 0 then
			local txt = string.format(TI18N("语言_c_7172"),need_star)
			self.tips_txt = createLabel(22,cc.c3b(0xff,0x00,0x00),nil,self.container:getContentSize().width*0.5,70,txt,self.container,nil,cc.p(0.5,1))
			self.tips_txt:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
			self.tips_txt:setWidth(self.container:getContentSize().width - 20)
			self.tip_h = math.max(30,self.tips_txt:getContentSize().height+10)
		end
	end
	self:updateBasePanel()
	self:updateAttrPanel()
	self:updateSkillPanel()
	self:updatePagePanel()
end
--设置基本信息
function GemstonePreviewTipsWindow:updateBasePanel()
	self.cfg_data = Config.ItemData.data_get_data(self.data)
	if self.cfg_data and self.cfg_data then
		if not self.back_item then
			self.back_item = BackPackItem.new(true, false)
			self.base_panel:addChild(self.back_item)
			self.back_item:setPosition(cc.p(70, 69))
		end
		self.back_item:setData(self.cfg_data)
		self.base_panel:loadTexture(PathTool.getResFrame("common_2", "tips_"..self.cfg_data.quality), LOADTEXT_TYPE_PLIST)
		self.name:setString(self.cfg_data.name)
		self.equip_type:setString(TI18N("语言_c_1728")..self.cfg_data.type_desc)
	end
end
--设置宝石属性信息
function GemstonePreviewTipsWindow:updateAttrPanel()
	local attr_list = {}
	local list = {}
	local cfg = Config.PartnerGemData.data_base_info[self.item_id]
	if cfg and cfg.base_attr and next(cfg.base_attr) then
		for k, v in pairs(cfg.base_attr) do
			list[v[1]] = v
		end
	elseif cfg and cfg.rand_attr then
		list = cfg.rand_attr
		if tableLen(list) < 3 then
			for i=tableLen(list)+1,3 do
				table.insert(list, 0)
			end
		end
	end
	for k, v in pairs(list or {}) do
		table.insert(attr_list, v)
	end
	local txt_h = math.max(30,self.baseattr_label:getContentSize().height)
	if self.base_attr_list then
		for k, v in pairs(self.base_attr_list) do
			v:removeFromParent()
			v=nil
		end
		self.base_attr_list = {}
	else
		self.base_attr_list = {}
	end
	local need_h = 0
	for i, v in ipairs(attr_list) do
		local label = createRichLabel(22, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0, 0), cc.p(30, 28), nil, nil, 400)
		self.baseattr_panel:addChild(label)
		self.base_attr_list[i] = label
		if type(v) == "table" then
			local attr_val = v[2]
			local attr_val2 = v[3]
			local attr_name = Config.AttrData.data_key_to_name[v[1]]
			if not attr_name then
				attr_name = Config.AttrExtraData.data_key_to_name[v[1]]
			end
			if attr_name then
				local icon = PathTool.getAttrIconByStr(v[1])
				local is_per = PartnerCalculate.isShowPerByStr(v[1])
				if is_per == true then
					attr_val = (attr_val*0.1).."%"
					if attr_val2 then
						attr_val2 = (attr_val2*0.1).."%"
					end
				end
				local attr_str = TI18N("语言_c_6180")..i..": "..string_format("<img src='%s' scale=1 /> <div fontcolor=#c1b7ab> %s </div><div fontcolor=#ffeedd>%s</div>", PathTool.getResFrame("common", icon), attr_name, attr_val)
				label:setString(attr_str)
			end
		else
			local cfg = Config.PartnerGemData.data_attr[v]
			if cfg then
				local attr_str = TI18N("语言_c_6180")..i..": "
				label:setString(attr_str)
				local item = ccui.Layout:create()
				item:setAnchorPoint(cc.p(0, 0.5))
				item:setContentSize(cc.size(self.baseattr_panel:getContentSize().width - label:getContentSize().width-50,40))
				label:addChild(item)
				item:setPosition(cc.p(label:getContentSize().width,label:getContentSize().height*0.5))
				item:setTouchEnabled(true)
				local look_btn = createImage(item,PathTool.getResFrame("common", "common_1093"),30,20,cc.p(0.5,0.5),true)
				local look_txt = createLabel(22,cc.c3b(0xc1,0xb7,0xab),nil,60,20,TI18N("语言_c_2942"),item,nil,cc.p(0,0.5))
				registerButtonEventListener(item, function()
					local cfg = Config.PartnerGemData.data_attr[v]
					local txt = TI18N("语言_c_7149")
					for key, value in ipairs(cfg or {}) do
						for _k, _v in pairs(value) do
							local _txt = ""
							local attr_val = _v.min
							local attr_val2 = _v.max
							local attr_name = Config.AttrData.data_key_to_name[_v.type]
							if not attr_name then
								attr_name = Config.AttrExtraData.data_key_to_name[_v.type]
							end
							if attr_name then
								local icon = PathTool.getAttrIconByStr(_v.type)
								local is_per = PartnerCalculate.isShowPerByStr(_v.type)
								if is_per == true then
									attr_val = (attr_val*0.1).."%"
									if attr_val2 then
										attr_val2 = (attr_val2*0.1).."%"
									end
								end
								_txt = attr_name..": "..attr_val .. "~" .. attr_val2
								txt = txt .. "\n".._txt
							end
						end
					end
					TipsManager:getInstance():showCommonTips(txt, item:getTouchBeganPosition(),nil,nil)
				end, false, 1)
			else
				local attr_str = ""
				if i == 2 then
					attr_str = TI18N("语言_c_6180")..i..": "..TI18N("语言_c_7163")
				elseif i == 3 then
					attr_str = TI18N("语言_c_6180")..i..": "..TI18N("语言_c_7164")
				end
				label:setString(attr_str)
			end
		end
		need_h = need_h + math.max(40,label:getContentSize().height+5)
		-- else
		-- 	if v[1] == 0 then
		-- 		local icon = "common_90021_8"
		-- 		local txt = ""
		-- 		if i == 2 then
		-- 			txt = TI18N("语言_c_7163")
		-- 		elseif i == 3 then
		-- 			txt = TI18N("语言_c_7164")
		-- 		end
		-- 		local attr_str = string_format("<img src='%s' scale=1 /> <div fontcolor=#c1b7ab> %s：</div><div fontcolor=#ffeedd>%s</div>", PathTool.getResFrame("common", icon),txt)
		-- 		label:setString(attr_str)
			-- end
	end
	local _h = math.max(197, need_h + txt_h)
	self.baseattr_panel:setContentSize(cc.size(self.baseattr_panel:getContentSize().width,_h))
	self.baseattr_label:setPositionY(_h-7)
	_h = _h - txt_h
	for i, v in ipairs(self.base_attr_list) do
		local _y = _h - math.max(v:getContentSize().height+3,40)
		v:setPositionY(_y)
		_h = _h - math.max(v:getContentSize().height+3,40)
	end
end
--设置宝石技能信息
function GemstonePreviewTipsWindow:updateSkillPanel()
	local cfg = Config.PartnerGemData.data_base_info[self.item_id]
	if cfg and cfg.base_skill and next(cfg.base_skill) then
		local skill_list = cfg.base_skill
		self.skill_panel:setContentSize(cc.size(self.skill_panel:getContentSize().width,351))
		self.skill_label:setPositionY(345)
		self.skill_scroll:setVisible(true)
		if not self.skill_item then
			self.skill_item = {}
		end
		local need_h = 0
		for k, v in pairs(skill_list) do
			local skill_id = v[2]
			local lib = v[1]
			local config = Config.SkillData.data_get_skill(skill_id)
			if config and Config.PartnerGemData.data_skill[lib] and Config.PartnerGemData.data_skill[lib][skill_id] then
				local skill_cfg = Config.PartnerGemData.data_skill[lib][skill_id]
				if self.skill_item[k] == nil then
					self.skill_item[k] = self:createSkillItem(self.skill_scroll)
				end
				self.skill_item[k].skill:showLockIcon(false)
				if skill_cfg.icon and skill_cfg.icon ~= "" then
					self.skill_item[k].node:loadTexture(PathTool.getSkillRes(skill_cfg.icon), LOADTEXT_TYPE)
					self.skill_item[k].skill:setVisible(false)
				else
					self.skill_item[k].skill:setVisible(true)
					self.skill_item[k].skill:setData(config)
				end
				local name_txt = ""
				if skill_cfg.name and skill_cfg.name ~= "" then
					name_txt = skill_cfg.name
				else
					name_txt = config.name
				end
				self.skill_item[k].name:setString(name_txt or "")--transformTextToShort(config.des, 60)
				local temp_str = TI18N("语言_c_7127")
				local num = 60
				if judgingLanguage() then
					num = 20
				end
				if skill_cfg.need_lv ~= 0 then
					self.skill_item[k].tips:setVisible(true)
					self.skill_item[k].lock_icon:setVisible(true)
				else	
					self.skill_item[k].tips:setVisible(false)
					self.skill_item[k].lock_icon:setVisible(false)
				end
				self.skill_item[k].tips:setString(string.format(temp_str,skill_cfg.need_lv))
				if self.pos_list and self.pos_list.lv and tonumber(self.pos_list.lv) >= tonumber(skill_cfg.need_lv) then
					self.skill_item[k].tips:setColor(cc.c4b(0x1b,0xca,0x0d))
					loadSpriteTexture(self.skill_item[k].lock_icon, PathTool.getResFrame("common", "common_1043"), LOADTEXT_TYPE_PLIST)
				else
					self.skill_item[k].tips:setColor(cc.c4b(0xff,0xee,0xdd))
					loadSpriteTexture(self.skill_item[k].lock_icon, PathTool.getResFrame("common", "common_90009_1"), LOADTEXT_TYPE_PLIST)
				end
				local des_txt = ""
				if skill_cfg.desc and skill_cfg.desc ~= "" then
					des_txt = skill_cfg.desc
				else
					des_txt = config.des
				end
				self.skill_item[k].desc:setString(des_txt or "")
				self.skill_item[k].layer:setPositionX(271)
				local add_h = 140 + self.skill_item[k].desc:getContentSize().height - 20
				need_h = need_h + add_h
				self.skill_item[k].add_h = add_h
			end
		end
		local _h = math.max(312, need_h)
		self.skill_scroll:setInnerContainerSize(cc.size(self.skill_scroll:getContentSize().width,_h))
		for k, v in pairs(self.skill_item) do
			v.layer:setPositionY(_h)
			_h = _h - v.add_h
		end
	else
		self.skill_scroll:setVisible(false)
		if cfg and cfg.rand_skill and next(cfg.rand_skill) then
			self.skill_panel:setContentSize(cc.size(self.skill_panel:getContentSize().width,170))
			self.skill_label:setPositionY(165)
			if not self.skill_tips then
				self.skill_tips = createRichLabel(22,cc.c3b(0x1b,0xca,0x0d),cc.p(0.5,0.5),cc.p(220,74),-4,nil,400)
				self.skill_panel:addChild(self.skill_tips)
				self.skill_tips:setString(TI18N("语言_c_7128"))
				local function clickLinkCallBack( type, value )
					if type == "href" then
						_controller:openGemstonePreviewSkillWindow(true,self.item_id)
					end
				end
				self.skill_tips:addTouchLinkListener(clickLinkCallBack,{"href"})
			end
			self.no_skill_txt:setVisible(false)
			self.no_skill_bg:setVisible(false)			
		else
			if self.skill_tips then
				self.skill_tips:setVisible(false)
			end
			self.no_skill_txt:setVisible(true)
			self.no_skill_bg:setVisible(true)
			self.skill_panel:setContentSize(cc.size(self.skill_panel:getContentSize().width,272))
			self.skill_label:setPositionY(270)
			self.no_skill_txt:setPosition(cc.p(self.skill_panel:getContentSize().width*0.5,110))
			self.no_skill_bg:setPosition(cc.p(self.skill_panel:getContentSize().width*0.5,136))
		end
	end
end

--==============================--
--desc:创建技能显示单例
--==============================--
function GemstonePreviewTipsWindow:createSkillItem(parent)
    local item = {}
	local layer = ccui.Layout:create()
    layer:setAnchorPoint(cc.p(0.5, 1))
    layer:setContentSize(cc.size(542,140))
    parent:addChild(layer)
	item.layer = layer

	item.skill_bg = createSprite(PathTool.getResFrame("common", "common_1005"),67,80,layer,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
	item.skill_bg:setScale(0.8)
	item.skill = SkillItem.new(true,true,true,0.8)
    layer:addChild(item.skill)
    item.skill:setPosition(67, 80)
	item.skill_icon = createSprite(PathTool.getResFrame("common", "common_1005"),67,80,layer,cc.p(0.5,0.5),LOADTEXT_TYPE)
	item.skill_icon:setScale(0.8)
	item.lock_icon = createSprite(PathTool.getResFrame("common", "common_1043"),140,50,layer,cc.p(0.5,0.5),LOADTEXT_TYPE)
	item.lock_icon:setScale(0.5)
	item.care_type = createSprite(PathTool.getResFrame("common", "common_90047"),140,112,layer,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
	item.name = createLabel(22,cc.c3b(0xfe,0xee,0xba),nil,170,112,"",layer,nil,cc.p(0,0.5))
	item.name:setLineSpacing(-8)
    item.name:setWidth(350)
	item.tips = createLabel(20,cc.c3b(0xff,0xee,0xdd),nil,160,37,"",layer,nil,cc.p(0,0))
	item.tips:setLineSpacing(-8)
    item.tips:setWidth(380)
    item.desc = createRichLabel(20,cc.c4b(0xff,0xee,0xdd,0xff),cc.p(0,1),cc.p(21, 23),-4,nil,500)
    layer:addChild(item.desc)
    return item
end
--页面自适应
function GemstonePreviewTipsWindow:updatePagePanel()
	local _h = 9
	if self.base_panel:isVisible() then
		self.base_panel_height = self.base_panel:getContentSize().height
	else
		self.base_panel_height = 0
	end
	if self.baseattr_panel:isVisible() then
		self.baseattr_panel_height = self.baseattr_panel:getContentSize().height
	else
		self.baseattr_panel_height = 0
	end
	if self.skill_panel:isVisible() then
		self.skill_panel_height = self.skill_panel:getContentSize().height
	else
		self.skill_panel_height = 0
	end
	_h = _h + self.base_panel_height + self.baseattr_panel_height + self.skill_panel_height + self.tip_h
	self.main_panel:setContentSize(cc.size(self.main_panel:getContentSize().width, _h))
	self.container:setContentSize(cc.size(self.container:getContentSize().width, _h))
	self.container:setPositionY(_h*0.5)
	self.close_btn:setPositionY(_h-10)
	self.base_panel:setPositionY(_h-4)
	self.baseattr_panel:setPositionY(_h-4-self.base_panel_height)
	self.skill_panel:setPositionY(_h-4-self.base_panel_height-self.baseattr_panel_height)
	if self.tips_txt then
		self.tips_txt:setPositionY(_h-4-self.base_panel_height-self.baseattr_panel_height-self.skill_panel_height-5)
	end
end
function GemstonePreviewTipsWindow:close_callback(  )
	self:_onClickCloseBtn()
end