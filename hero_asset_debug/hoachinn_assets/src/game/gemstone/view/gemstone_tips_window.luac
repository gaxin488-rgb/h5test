--------------------------------------------
-- 
-- 
-- @Date    : 2019-01-16 19:09:44
-- @description    : 
		-- 宝石tips
---------------------------------

GemstoneTipsWindow = GemstoneTipsWindow or BaseClass(BaseView)

local _controller = GemstoneController:getInstance()
local model = _controller:getModel()

function GemstoneTipsWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Mini  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
	self.btn_list = {} --切换顶部宝石和槽位按钮
	self.page_index = 0
    self.layout_name = "gemstone/gemstone_tips_window"
end

function GemstoneTipsWindow:open_callback(  )
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
	self.score_title = self.base_panel:getChildByName("score_title")
	self.score_title:setString(TI18N("语言_c_6544"))
	self.score_num = CommonNum.new(1, self.base_panel, 1, -2, cc.p(0, 0.5))
	self.score_num:setPosition(cc.p(0,37))
    self.score_num:setNum(0)
    self.score_num:setScale(0.8) 
    setItemXOneByOne({self.score_title,self.score_num})
	self.btn_panel = self.container:getChildByName("btn_panel")
	local title_txt = {
		[1]=TI18N("语言_c_7114"),
		[2]=TI18N("语言_c_7144")
	}
	for i=1,2 do
		local btn = self.btn_panel:getChildByName("tab_btn_"..i)
		btn.unselect_bg = btn:getChildByName("unselect_bg")
		btn.select_bg = btn:getChildByName("select_bg")
		btn.title = btn:getChildByName("title")
		btn.title:setString(title_txt[i])
		btn.index = i
		self.btn_list[i] = btn
	end
	self.posattr_panel = self.container:getChildByName("posattr_panel")
	self.posattr_label = self.posattr_panel:getChildByName("label")
	self.posattr_label:setString(TI18N("语言_c_1282"))
	self.baseattr_panel = self.container:getChildByName("baseattr_panel")
	self.baseattr_panel:setVisible(false)
	self.baseattr_label = self.baseattr_panel:getChildByName("label")
	self.baseattr_label:setString(TI18N("语言_c_1282"))
	self.skill_panel = self.container:getChildByName("skill_panel")
	self.skill_label = self.skill_panel:getChildByName("label")
	self.skill_label:setString(TI18N("语言_c_7141"))
	self.skill_scroll = self.skill_panel:getChildByName("skill_scroll")
	self.skill_scroll:setScrollBarEnabled(false)
	self.no_skill_bg = self.skill_scroll:getChildByName("no_skill_bg")
	self.no_skill_txt = self.skill_scroll:getChildByName("no_skill_txt")
	self.no_skill_txt:setString(TI18N("语言_c_7158"))
	setTextMaxWidth(self.no_skill_txt,500)
	self.no_skill_bg:setVisible(false)
	self.no_skill_txt:setVisible(false)
	self.tab_panel = self.container:getChildByName("tab_panel")
	self.tips_line = self.tab_panel:getChildByName("tips_line")
	self.tab_panel:setVisible(false)
	self.remove_btn = self.tab_panel:getChildByName("tab_btn_1")
	self.remove_txt = self.remove_btn:getChildByName("Text_1")
	self.remove_txt:setString(TI18N("语言_c_2964"))
	self.change_btn = self.tab_panel:getChildByName("tab_btn_2")
	self.change_txt = self.change_btn:getChildByName("Text_2")
	self.change_txt:setString(TI18N("语言_c_1966"))
	self.streng_btn = self.tab_panel:getChildByName("tab_btn_3")
	self.streng_txt = self.streng_btn:getChildByName("Text_3")
	self.streng_txt:setString(TI18N("语言_c_4967"))
	self.succinct_btn = self.tab_panel:getChildByName("tab_btn_4")
	self.succinct_txt = self.succinct_btn:getChildByName("Text_4")
	self.succinct_txt:setString(TI18N("语言_c_763"))
	self.update_panel = self.container:getChildByName("update_panel")
	self.update_panel:setVisible(false)
	self.update_btn = self.update_panel:getChildByName("update_btn")
	self.update_txt = self.update_btn:getChildByName("update_txt")
	self.update_txt:setString(TI18N("语言_c_763"))
	self.source_btn = self.update_panel:getChildByName("source_btn")
	self.source_txt = self.source_btn:getChildByName("source_txt")
	self.source_txt:setString(TI18N("语言_c_6079"))
	self.close_btn = self.container:getChildByName("close_btn")
end
function GemstoneTipsWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), true, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.remove_btn, handler(self, self._onClickRemoveBtn), true, 2)
	registerButtonEventListener(self.change_btn, handler(self, self._onClickChangeBtn), true, 2)
	registerButtonEventListener(self.streng_btn, handler(self, self._onClickStrengBtn), true, 2)
	registerButtonEventListener(self.update_btn, handler(self, self._onClickUpdateBtn), true, 2)
	registerButtonEventListener(self.source_btn, handler(self, self._onClickSourceBtn), true, 2)
	registerButtonEventListener(self.succinct_btn, handler(self, self._onClickSuccinctBtn), true, 2)
	for k, object in pairs(self.btn_list) do
		object:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playTabButtonSound()
				self:clickBtn(object.index)
			end
		end)
    end
end

function GemstoneTipsWindow:_onClickRemoveBtn(  )
	if self.pos_list and next(self.pos_list) then
		if model:checkGemBack(1,0,1) then
			_controller:sender22801(self.pid,self.pos_list.item_bid,self.pos_list.pos,0)
        else
            message(TI18N("语言_c_7153"))
        end
	end
end
function GemstoneTipsWindow:_onClickChangeBtn(  )
	_controller:openGemstoneEquipWindow(true,self.pid,self.pos_list.pos)
	self:_onClickCloseBtn()
end
function GemstoneTipsWindow:_onClickSourceBtn(  )
	BackpackController:getInstance():openTipsSource(true, self.cfg_data)
end
function GemstoneTipsWindow:_onClickUpdateBtn(  )
	local lock_status = false
	if self.gem_list and next(self.gem_list) then
		if self.gem_list.checkGemIsLock then
			lock_status = self.gem_list:checkGemIsLock()
		end
	end
	local fun = function()
		local setting = {}
		setting.pid = self.pid
		setting.data = self.data
		setting.gem_list = self.gem_list
		setting.pos_list = self.pos_list
		_controller:openGemstoneRecastPanel(true,setting)
	end
	if lock_status then
		local str = TI18N("语言_c_7145")
        CommonAlert.show( str, TI18N("语言_c_63"), function()
			GemstoneController:getInstance():sender22810(0,0,self.gem_list.id)
            fun()
        end, TI18N("语言_c_62"),nil,nil,nil,{timer=0, timer_for=true, off_y = 10, title = TI18N("语言_c_5014"), extend_aligment = cc.TEXT_ALIGNMENT_CENTER })
	else
		fun()
	end
end
function GemstoneTipsWindow:_onClickSuccinctBtn(  )
	local lock_status = false
	if self.pos_list and next(self.pos_list) and self.pos_list.extra and next(self.pos_list.extra) then
		for k, v in pairs(self.pos_list.extra) do
			if v.extra_k == 1 then
				lock_status = v.extra_v
				break
			end
		end
	end
	local fun = function()
		local setting = {}
		setting.pid = self.pid
		setting.data = self.data
		setting.gem_list = self.gem_list
		setting.pos_list = self.pos_list
		_controller:openGemstoneRecastPanel(true,setting)
	end
	if lock_status then
		local str = TI18N("语言_c_7589")
        CommonAlert.show( str, TI18N("语言_c_63"), function()
			GemstoneController:getInstance():sender22810(self.pid,self.pos_list.pos,0)
            fun()
        end, TI18N("语言_c_62"),nil,nil,nil,{timer=0, timer_for=true, off_y = 10, title = TI18N("语言_c_5014"), extend_aligment = cc.TEXT_ALIGNMENT_CENTER })
	else
		fun()
	end
end
function GemstoneTipsWindow:_onClickStrengBtn(  )
	if self.pid and self.pos_list and next(self.pos_list) then
		local setting = {}
		setting.pid = self.pid
		setting.pos = self.pos_list.pos
		_controller:openGemstoneStrengthenWindow(true,setting)
		self:_onClickCloseBtn()
	end
end

function GemstoneTipsWindow:_onClickCloseBtn(  )
	_controller:openGemstoneTipsWindow(false)
end

--强化
function GemstoneTipsWindow:updateStrengRed()
	local status = false
	if self.pid and self.pid ~= 0  and self.pos_list and next(self.pos_list) then
		local pos = self.pos_list.pos
		local list = model:getOneGemstoneInfo(self.pid, pos)
		if list and next(list) and list.item_bid and list.item_bid ~= 0 then
			local cfg = Config.PartnerGemData.data_lv_info[pos]
			if cfg and list.lv < tableLen(cfg) then
				status = model:getGemStrengOneRed(self.pid, pos)
			end
		end
	end
	addRedPointToNodeByStatus(self.streng_btn,status,10,10)
end
--更换
function GemstoneTipsWindow:updateChangeRed()
	local status = false
	if self.pid and self.pid ~= 0 and self.pos_list and next(self.pos_list) then
		local cfg = Config.PartnerGemData.data_lv_info
		local hero_vo = HeroController:getInstance():getModel():getHeroById(self.pid)
		local pos = self.pos_list.pos
		if cfg[pos] and cfg[pos][1] and hero_vo.star >= cfg[pos][1].need_star then
            status = model:getGemEquipOneRed(self.pid,pos)
        end
	end
	addRedPointToNodeByStatus(self.change_btn,status,10,10)
end
function GemstoneTipsWindow:openRootWnd(setting)
	setting = setting or {}
	self.data = setting.data or nil --宝石基本信息 --配置表 or 物品id
	self.gem_list = setting.gem_list or {} --宝石属性信息  背包
	self.pos_list = setting.pos_list or {} --槽位基本信息  已装备
	self.pid = setting.pid or 0 --忍者唯一id  已装备
	self.is_equip = setting.is_equip or false --是否已装备
	if not self.data then return end
	if type(self.data) == "table" then
		self.cfg_data = self.data
	else
		self.cfg_data = Config.ItemData.data_get_data(self.data)
	end
	if (self.pos_list and next(self.pos_list)) or (self.gem_list and next(self.gem_list) and self.gem_list.item_attr) then
		self.btn_panel:setVisible(true)
		if self.pos_list and next(self.pos_list) and self.is_equip then
			self.tab_panel:setVisible(true)
			self.update_panel:setVisible(false)
		else
			self.tab_panel:setVisible(false)
			if HeroController:getInstance():getHeroTipsPanelIsOpen() then
				self.update_panel:setVisible(true)
				self.update_btn:setVisible(false)
				self.source_btn:setPositionX(270)
			end
		end
	else
		self.btn_panel:setVisible(false)
		self.tab_panel:setVisible(false)
		self.update_panel:setVisible(true)
		if Config.PartnerGemData.data_refresh[self.cfg_data.id] then
			self.update_btn:setVisible(true)
			self.source_btn:setPositionX(405)
		else
			self.update_btn:setVisible(false)
			self.source_btn:setPositionX(270)
		end
	end

	self.tip_h = 0
	if not self.tips_txt then
		local need_star = 0
		local cfg = Config.PartnerGemData.data_base_info[self.cfg_data.id]
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

	for k, v in pairs(self.btn_list) do
		if v.index == 1 then
			local status = false
			--更换红点
			if self.pid and self.pid ~= 0 and self.pos_list and next(self.pos_list) then
				local cfg = Config.PartnerGemData.data_lv_info
				local hero_vo = HeroController:getInstance():getModel():getHeroById(self.pid)
				local pos = self.pos_list.pos
				if cfg[pos] and cfg[pos][1] and hero_vo.star >= cfg[pos][1].need_star then
					status = model:getGemEquipOneRed(self.pid,pos)
				end
			end
			addRedPointToNodeByStatus(v,status,10,10)
		else
			local status = false
			--更换红点
			if self.pid and self.pid ~= 0 and self.pos_list and next(self.pos_list) then
				local cfg = Config.PartnerGemData.data_lv_info
				local hero_vo = HeroController:getInstance():getModel():getHeroById(self.pid)
				local pos = self.pos_list.pos
				if cfg[pos] and cfg[pos][1] and hero_vo.star >= cfg[pos][1].need_star then
					status = model:getGemEquipOneRed(self.pid,pos)
				end
			end
			if not status then
				if self.pid and self.pid ~= 0  and self.pos_list and next(self.pos_list) then
					local pos = self.pos_list.pos
					local list = model:getOneGemstoneInfo(self.pid, pos)
					if list and next(list) and list.item_bid and list.item_bid ~= 0 then
						local cfg = Config.PartnerGemData.data_lv_info[pos]
						if cfg and list.lv < tableLen(cfg) then
							status = model:getGemStrengOneRed(self.pid, pos)
						end
					end
				end
			end
			local is_try = HeroController:getInstance():getModel():checkIsTryout(self.pid)
			if is_try then
				status = false
			end
			addRedPointToNodeByStatus(v,status,10,10)
		end
	end
	self:updateBasePanel()
	self:updateAttrPanel()
	self:updatePosAttrPanel()
	self:updateSkillPanel()
	self:clickBtn(1)
	self:updateStrengRed()
	self:updateStrengRed()
	self:updateChangeRed()
end
--页签按钮点击事件
function GemstoneTipsWindow:clickBtn(index)
	if index == 2 then
		local is_try = HeroController:getInstance():getModel():checkIsTryout(self.pid)
		if is_try then
			message(TI18N("语言_c_7567"))
			return
		end
	end
	if index == self.page_index then return end
	self.page_index = index
	if index == 1 then
		self.posattr_panel:setVisible(false)
		self.baseattr_panel:setVisible(true)
	else
		self.posattr_panel:setVisible(true)
		self.baseattr_panel:setVisible(false)
	end
	for k, v in pairs(self.btn_list) do
		if v.index == index then
			v.unselect_bg:setVisible(false)
			v.select_bg:setVisible(true)
		else
			v.unselect_bg:setVisible(true)
			v.select_bg:setVisible(false)
		end
	end
	if self.page_index == 1 then
		self.tab_panel:setContentSize(cc.size(self.tab_panel:getContentSize().width,107))
		self.streng_btn:setVisible(false)
		self.tips_line:setPositionY(91)
		if Config.PartnerGemData.data_refresh[self.cfg_data.id] then
			self.succinct_btn:setVisible(true)
			self.remove_btn:setPosition(cc.p(108,47))
			self.change_btn:setPosition(cc.p(270,47))
			self.succinct_btn:setPosition(cc.p(432,47))
		else
			self.succinct_btn:setVisible(false)
			self.remove_btn:setPosition(cc.p(135,57))
			self.change_btn:setPosition(cc.p(405,57))
		end
	else
		self.streng_btn:setVisible(true)
		if Config.PartnerGemData.data_refresh[self.cfg_data.id] then
			self.succinct_btn:setVisible(true)
			self.tab_panel:setContentSize(cc.size(self.tab_panel:getContentSize().width,157))
			self.tips_line:setPositionY(141)
			self.remove_btn:setPosition(cc.p(135,107))
			self.change_btn:setPosition(cc.p(405,107))
			self.streng_btn:setPosition(cc.p(135,47))
			self.succinct_btn:setPosition(cc.p(405,47))
		else
			self.succinct_btn:setVisible(false)
			self.tab_panel:setContentSize(cc.size(self.tab_panel:getContentSize().width,107))
			self.tips_line:setPositionY(91)
			self.remove_btn:setPosition(cc.p(108,57))
			self.change_btn:setPosition(cc.p(270,57))
			self.streng_btn:setPosition(cc.p(432,57))
		end
	end
	self:updatePagePanel()
end
--设置基本信息
function GemstoneTipsWindow:updateBasePanel()
	if not self.cfg_data then return end
	if self.cfg_data and self.cfg_data then
		if not self.back_item then
			self.back_item = BackPackItem.new(true, false)
			self.base_panel:addChild(self.back_item)
			self.back_item:setPosition(cc.p(70, 69))
		end
		self.back_item:setData(self.cfg_data)

		self.base_panel:loadTexture(PathTool.getResFrame("common_2", "tips_"..self.cfg_data.quality), LOADTEXT_TYPE_PLIST)
		self.base_panel:setCapInsets(cc.rect(314, 45, 25, 48))
		self.name:setString(self.cfg_data.name)
		local color = BackPackConst.quality_color[self.cfg_data.quality]
    	self.name:setTextColor(color) 
		if self.pos_list and next(self.pos_list) and self.pos_list.lv then
			self.equip_type:setString(self.cfg_data.type_desc.." "..string.format(TI18N("语言_c_4520"),self.pos_list.lv))
		else
			self.equip_type:setString(TI18N("语言_c_1728")..self.cfg_data.type_desc)
		end
		local score_num = self:getBaseScore()
		self.score_num:setNum(score_num)
	end
end
--计算基础评分
function GemstoneTipsWindow:getBaseScore()
	local attr_list = {}
	if self.gem_list and next(self.gem_list) then
		attr_list = self.gem_list.main_attr or self.gem_list.item_attr or {}
	else
		if self.pos_list and next(self.pos_list) then
			attr_list = self.pos_list.item_attr or {}
		end
	end
	if not attr_list or not next(attr_list) then return 0 end
    local base_attr = {}
	for k, v in pairs(attr_list) do
		local attr_txt = Config.AttrData.data_id_to_key[v.attr_id]
		if not attr_txt then
			attr_txt = Config.AttrExtraData.data_id_to_key[v.attr_id]
		end
		local attr_num = v.attr_val
		table.insert(base_attr, {attr_txt, attr_num})
	end
	--宝石基础属性评分
    local num = model:calculatePower(base_attr)
	local cfg = Config.PartnerGemData.data_base_info[self.cfg_data.id]
	--基础评分
	local base_num = cfg.score
	--槽位评分
	local pos_num = 0
	local pos_lv_cfg = Config.PartnerGemData.data_lv_info[self.pos_list.pos]
	if pos_lv_cfg and pos_lv_cfg[self.pos_list.lv] and pos_lv_cfg[self.pos_list.lv].attr then
		pos_num = pos_num + model:calculatePower(deepCopy(pos_lv_cfg[self.pos_list.lv].attr))
	end
	local break_cfg = Config.PartnerGemData.data_break[self.pos_list.pos]
	if break_cfg and break_cfg[self.pos_list.break_num] and break_cfg[self.pos_list.break_num].attr then
		pos_num = pos_num + model:calculatePower(deepCopy(break_cfg[self.pos_list.break_num].attr))
	end
	--技能评分
	local skill_num = 0
	local skill_list = {}
	if self.gem_list and next(self.gem_list) then
		skill_list = self.gem_list.extra_attr or self.gem_list.item_skill or {}
	elseif self.pos_list and next(self.pos_list) then
		skill_list = self.pos_list.item_skill or {}
	end
	for k, v in pairs(skill_list) do
		local lib = v.lib or v.attr_id
		local skill_id = v.skill_id or v.attr_val
		local cfg = Config.PartnerGemData.data_skill[lib]
		if cfg and cfg[skill_id] then
			skill_num = cfg[skill_id].score
		end
	end
    return base_num + num + pos_num + skill_num
end

--设置宝石属性信息
function GemstoneTipsWindow:updateAttrPanel()
	local attr_list = {}
	if self.gem_list and next(self.gem_list) then
		attr_list = deepCopy(self.gem_list.main_attr) or deepCopy(self.gem_list.item_attr) or {}
	elseif self.pos_list and next(self.pos_list) then
		attr_list = deepCopy(self.pos_list.item_attr) or {}
	end
	if tableLen(attr_list) < 3 then
		for i=tableLen(attr_list)+1,3 do
			table.insert(attr_list, {attr_id=0,attr_val=0})
		end
	end
	local _h = math.max(195, #attr_list * 40 + 30)
	self.baseattr_panel:setContentSize(cc.size(self.baseattr_panel:getContentSize().width,_h))
	if self.base_attr_list then
		for k, v in pairs(self.base_attr_list) do
			v:removeFromParent()
			v=nil
		end
		self.base_attr_list = {}
	else
		self.base_attr_list = {}
	end
	for i, v in ipairs(attr_list) do
		local label = createRichLabel(22, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0, 0), cc.p(30, 28), nil, nil, 480)
		self.baseattr_panel:addChild(label)
		self.base_attr_list[i] = label
		local _y = _h - 30 - i * 40
		label:setPositionY(_y)
		local attr_key = Config.AttrData.data_id_to_key[v.attr_id]
		if not attr_key then
			attr_key = Config.AttrExtraData.data_id_to_key[v.attr_id]
		end
        local attr_val = v.attr_val
        local attr_name = Config.AttrData.data_key_to_name[attr_key]
		if not attr_name then
			attr_name = Config.AttrExtraData.data_key_to_name[attr_key]
		end
		if attr_name then
			local icon = PathTool.getAttrIconByStr(attr_key)
			local is_per = PartnerCalculate.isShowPerByStr(attr_key)
			if is_per == true then
				attr_val = (attr_val*0.1).."%"
			end
			local attr_str = string_format("<img src='%s' scale=1 /> <div fontcolor=#c1b7ab> %s：</div><div fontcolor=#ffeedd>%s</div>", PathTool.getResFrame("common", icon), attr_name, attr_val)
			label:setString(attr_str)
		else
			local icon = "common_90021_8"
			local txt = TI18N("语言_c_7163")
			if i == 2 then
				txt = TI18N("语言_c_7163")
			elseif i == 3 then
				txt = TI18N("语言_c_7164")
			end
			local attr_str = string_format("<img src='%s' scale=1 /> <div fontcolor=#c1b7ab> %s</div>", PathTool.getResFrame("common", icon), txt)
			label:setString(attr_str)
		end
	end
end
--设置槽位属性信息
function GemstoneTipsWindow:updatePosAttrPanel()
	local attr_list = {}
	local data = {}
	if self.pos_list and next(self.pos_list) then
		data = self.pos_list
	end
	if data and next(data) then
		local pos_cfg = Config.PartnerGemData.data_lv_info[data.pos]
		if pos_cfg and pos_cfg[data.lv] then
			attr_list = deepCopy(pos_cfg[data.lv].attr)
		end
		if not next(attr_list) then
			if pos_cfg and pos_cfg[data.lv+1] then
				attr_list = deepCopy(pos_cfg[data.lv+1].attr)
			end
			for k, v in pairs(attr_list) do
				v[2] = 0
			end
		end
		local break_cfg = Config.PartnerGemData.data_break[data.pos]
		if break_cfg and break_cfg[data.break_num] then
			local list = deepCopy(break_cfg[data.break_num].attr)
			for key, value in pairs(list) do
				local status = true
				for k, v in pairs(attr_list) do
					if value[1] == v[1] then
						v[2] = v[2] + value[2]
						status = false
					end
				end
				if status then
					table.insert(attr_list, value)
				end
			end
		end
	end
	local _h = math.max(195, #attr_list * 40 + 30)
	self.posattr_panel:setContentSize(cc.size(self.posattr_panel:getContentSize().width,_h))
	if self.pos_attr_list then
		for k, v in pairs(self.pos_attr_list) do
			v:removeFromParent()
			v=nil
		end
		self.pos_attr_list = {}
	else
		self.pos_attr_list = {}
	end
	for i, v in ipairs(attr_list) do
		local label = createRichLabel(22, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0, 0), cc.p(30, 28), nil, nil, 480)
		self.posattr_panel:addChild(label)
		self.pos_attr_list[i] = label
		local _y = _h - 30 - i * 40
		label:setPositionY(_y)
		local attr_key = v[1]
        local attr_val = v[2]
        local attr_name = Config.AttrData.data_key_to_name[attr_key]
		if not attr_name then
			attr_name = Config.AttrExtraData.data_key_to_name[attr_key]
		end
		if attr_name then
			local icon = PathTool.getAttrIconByStr(attr_key)
			local is_per = PartnerCalculate.isShowPerByStr(attr_key)
			if is_per == true then
				attr_val = (attr_val*0.1).."%"
			end
			local attr_str = string_format("<img src='%s' scale=1 /> <div fontcolor=#c1b7ab> %s：</div><div fontcolor=#ffeedd>%s</div>", PathTool.getResFrame("common", icon), attr_name, attr_val)
			label:setString(attr_str)
		end
	end
end
--设置宝石技能信息
function GemstoneTipsWindow:updateSkillPanel()
	local skill_list = {}
	if self.gem_list and next(self.gem_list) then
		skill_list = self.gem_list.extra_attr or self.gem_list.item_skill or {}
	elseif self.pos_list and next(self.pos_list) then
		skill_list = self.pos_list.item_skill or {}
	end
	if not self.skill_item then
		self.skill_item = {}
	end
	local need_h = 0
	for k, v in pairs(skill_list) do
		local skill_id = v.skill_id or v.attr_val
		local lib = v.lib or v.attr_id
		if Config.PartnerGemData.data_skill[lib] and Config.PartnerGemData.data_skill[lib][skill_id] then
			v.need_lv = Config.PartnerGemData.data_skill[lib][skill_id].need_lv
		end
	end
	table.sort(skill_list, function(a, b) return a.need_lv < b.need_lv end)
	for k, v in pairs(skill_list) do
		local skill_id = v.skill_id or v.attr_val
		local lib = v.lib or v.attr_id
		local config = Config.SkillData.data_get_skill(skill_id)
		if config and Config.PartnerGemData.data_skill[lib] and Config.PartnerGemData.data_skill[lib][skill_id] then
			local skill_cfg = Config.PartnerGemData.data_skill[lib][skill_id]
			if self.skill_item[k] == nil then
				self.skill_item[k] = self:createSkillItem(self.skill_scroll)
			end
			self.skill_item[k].skill:showLockIcon(false)
			if skill_cfg.icon and skill_cfg.icon ~= "" then
				self.skill_item[k].skill_icon:loadTexture(PathTool.getSkillRes(skill_cfg.icon), LOADTEXT_TYPE)
				self.skill_item[k].skill:setVisible(false)
			else
				self.skill_item[k].skill:setVisible(true)
				self.skill_item[k].skill:setData(config)
			end
			loadSpriteTexture(self.skill_item[k].care_type, PathTool.getPartnerTypeIcon(skill_cfg.need_type), LOADTEXT_TYPE_PLIST)
			if skill_cfg.need_type ~= 0 then
				self.skill_item[k].care_type:setVisible(true)
				self.skill_item[k].name:setPositionX(170)
			else
				self.skill_item[k].care_type:setVisible(false)
				self.skill_item[k].name:setPositionX(130)
			end
			local name_txt = ""
			if skill_cfg.name and skill_cfg.name ~= "" then
				name_txt = skill_cfg.name
			else
				name_txt = config.name
			end
			self.skill_item[k].name:setString(name_txt or "")--transformTextToShort(config.des, 60)
			local temp_str = TI18N("语言_c_7127")
			if skill_cfg.need_lv ~= 0 then
				self.skill_item[k].tips:setVisible(true)
				self.skill_item[k].lock_icon:setVisible(true)
			else	
				self.skill_item[k].tips:setVisible(false)
				self.skill_item[k].lock_icon:setVisible(false)
			end
			self.skill_item[k].tips:setString(string.format(temp_str,skill_cfg.need_lv))
			if self.pos_list and self.pos_list.lv and tonumber(self.pos_list.lv) >= tonumber(skill_cfg.need_lv) then
				self.skill_item[k].tips:setColor(cc.c3b(0x08,0xe9,0x08))
				loadSpriteTexture(self.skill_item[k].lock_icon, PathTool.getResFrame("common", "common_1043"), LOADTEXT_TYPE_PLIST)
			else
				self.skill_item[k].tips:setColor(cc.c3b(0xff,0xee,0xdd))
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
			-- self.skill_item[k].layer:setPositionY(_h - (k-1)*140 - 70)
		end
	end
	local _h = math.max(262, need_h)
	if self.skill_item and next(self.skill_item) then
		self.no_skill_bg:setVisible(false)
		self.no_skill_txt:setVisible(false)
		self.is_add_h = false
	else
		self.no_skill_bg:setVisible(true)
		self.no_skill_txt:setVisible(true)
		self.is_add_h = true
	end
	self.skill_scroll:setInnerContainerSize(cc.size(self.skill_scroll:getContentSize().width,_h))
	for k, v in pairs(self.skill_item) do
		v.layer:setPositionY(_h)
		_h = _h - v.add_h
	end
end

--==============================--
--desc:创建技能显示单例
--==============================--
function GemstoneTipsWindow:createSkillItem(parent)
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
	item.name = createLabel(22,cc.c3b(0xfe,0xee,0xba),cc.c3b(0x00,0x00,0x00),170,112,"",layer,nil,cc.p(0,0.5))
	local color = BackPackConst.quality_color[self.cfg_data.quality]
	item.name:setTextColor(color)
	item.name:setLineSpacing(-8)
    item.name:setWidth(350)
	item.tips=createRichLabel(20,cc.c3b(0xff,0xee,0xdd),cc.p(0,0),cc.p(160,37),-9,nil,380)
	layer:addChild(item.tips)
	-- item.tips = createLabel(20,cc.c3b(0xff,0xee,0xdd),nil,160,37,"",layer,nil,cc.p(0,0))
	-- item.tips:setLineSpacing(-8)
    -- item.tips:setWidth(380)
    item.desc = createRichLabel(20,cc.c4b(0xff,0xee,0xdd,0xff),cc.p(0,1),cc.p(21, 23),-4,nil,500)
    layer:addChild(item.desc)
    return item
end
--页面自适应
function GemstoneTipsWindow:updatePagePanel()
	local _h = 9
	if self.base_panel:isVisible() then
		self.base_panel_height = self.base_panel:getContentSize().height
	else
		self.base_panel_height = 0
	end
	if self.btn_panel:isVisible() then
		self.btn_panel_height = self.btn_panel:getContentSize().height
	else
		self.btn_panel_height = 0
	end
	if self.posattr_panel:isVisible() then
		self.posattr_panel_height = self.posattr_panel:getContentSize().height
	else
		self.posattr_panel_height = 0
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
	if self.tab_panel:isVisible() then
		self.tab_panel_height = self.tab_panel:getContentSize().height
	else
		self.tab_panel_height = 0
	end
	if self.update_panel:isVisible() then
		self.update_panel_height = self.update_panel:getContentSize().height
	else
		self.update_panel_height = 0
	end
	_h = _h + self.base_panel_height + self.btn_panel_height + self.posattr_panel_height + self.baseattr_panel_height + self.skill_panel_height + self.tab_panel_height +  self.update_panel_height + self.tip_h
	-- if self.is_add_h and not self.tab_panel:isVisible() then
	-- 	_h = _h + 100
	-- end
	self.main_panel:setContentSize(cc.size(self.main_panel:getContentSize().width, _h))
	self.container:setContentSize(cc.size(self.container:getContentSize().width, _h))
	self.container:setPositionY(_h*0.5)
	self.close_btn:setPositionY(_h-10)
	self.base_panel:setPositionY(_h-4)
	self.btn_panel:setPositionY(_h-4-self.base_panel_height)
	self.posattr_panel:setPositionY(_h-4-self.base_panel_height-self.btn_panel_height)
	self.baseattr_panel:setPositionY(_h-4-self.base_panel_height-self.btn_panel_height)
	self.skill_panel:setPositionY(_h-4-self.base_panel_height-self.btn_panel_height-self.posattr_panel_height-self.baseattr_panel_height)
	if self.tips_txt then
		self.tips_txt:setPositionY(_h-4-self.base_panel_height-self.btn_panel_height-self.posattr_panel_height-self.baseattr_panel_height-self.skill_panel_height-5)
	end
	self.tab_panel:setPositionY(_h-4-self.base_panel_height-self.btn_panel_height-self.posattr_panel_height-self.baseattr_panel_height-self.skill_panel_height-self.tip_h)
	self.update_panel:setPositionY(_h-4-self.base_panel_height-self.btn_panel_height-self.posattr_panel_height-self.baseattr_panel_height-self.skill_panel_height-self.tip_h)
end
function GemstoneTipsWindow:close_callback(  )
	self:_onClickCloseBtn()
end