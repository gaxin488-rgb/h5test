--------------------------------------------
-- 
-- 
-- @Date    : 2019-01-16 19:09:44
-- @description    : 
		-- 宝石buff
---------------------------------

GemstoneBuffView = GemstoneBuffView or BaseClass(BaseView)

local controller = GemstoneController:getInstance()
local model = controller:getModel()
local dun_controller = DungeonAbyssController:getInstance()
local dun_model = dun_controller:getModel()

function GemstoneBuffView:__init()
    self.is_full_screen = false
    self.win_type = WinType.Mini  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.layout_name = "gemstone/gemstone_buff_view"
	self.cur_pos = -1
end

function GemstoneBuffView:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end
	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
	self.image_bg = self.main_container:getChildByName("image_bg")
	self.have_panel = self.main_container:getChildByName("have_panel")
	self.have_panel:setVisible(false)
	self.have_title_bg = self.have_panel:getChildByName("have_title_bg")
	self.have_title_txt = self.have_panel:getChildByName("have_title_txt")
	self.have_title_txt:setString(TI18N("语言_c_1984"))
	autoSizeTitleBg(self.have_title_txt,self.have_title_bg,26,146)
	self.have_scr = self.have_panel:getChildByName("have_scr")
	self.title_bg = self.main_container:getChildByName("title_bg")
	self.title_txt = self.main_container:getChildByName("title_txt")
	self.title_txt:setString(TI18N("语言_c_7170"))
	autoSizeTitleBg(self.title_txt,self.title_bg,26,146)
	self.scrollview = self.main_container:getChildByName("scrollview")
	self.scrollview:setScrollBarEnabled(false)
end

function GemstoneBuffView:register_event(  )
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
end

function GemstoneBuffView:_onClickCloseBtn()
	controller:openGemstoneBuffView(false)
end
--open_type1功能界面 2布阵界面
-- setting.cur_type 1异界 2无限异界
-- setting.group_id 组id
-- setting.lv_id 难度id
-- setting.form_data 上阵忍者列表
function GemstoneBuffView:openRootWnd(open_type,setting)
	self.open_type = open_type or 1
	self.setting = setting or {}
	self.cur_type = self.setting.cur_type or 1
	self.group_id = dun_model:getAdvanceGroupId()
	self.lv_id = dun_model:getAdvanceDiff()
	self.form_data = self.setting.form_data or {}
	self.max_score = 0
	if self.form_data.pos_info and next(self.form_data.pos_info) then
		for i,v in ipairs(self.form_data.pos_info) do
			local hero_data = model:getGemstoneInfo(v.id)
			if hero_data and hero_data.list_info and next(hero_data.list_info) then
				for key,value in ipairs(hero_data.list_info) do
					local num = model:getScore(value)
					self.max_score = self.max_score + num
				end
			end
		end
	end
	-- self.quality_list = {}
	-- self.max_quality = 0
	-- if self.form_data.pos_info and next(self.form_data.pos_info) then
	-- 	for i,v in ipairs(self.form_data.pos_info) do
	-- 		local hero_data = model:getGemstoneInfo(v.id)
	-- 		if hero_data and hero_data.list_info and next(hero_data.list_info) then
	-- 			for key,value in ipairs(hero_data.list_info) do
	-- 				local cfg = Config.ItemData.data_get_data(value.item_bid)
	-- 				if cfg and cfg.quality then
	-- 					self.max_quality = math.max(self.max_quality,cfg.quality)
	-- 					if not self.quality_list[cfg.quality] then
	-- 						self.quality_list[cfg.quality] = 1
	-- 					else
	-- 						self.quality_list[cfg.quality] = self.quality_list[cfg.quality] + 1
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	local data = {}
	if self.cur_type == 1 then
		data = Config.DungeonAbyssCircleData.data_gem1
	else
		local cfg = Config.DungeonAbyssCircleData.data_gem2
		if cfg and cfg[self.group_id] and cfg[self.group_id][self.lv_id] then
			data = cfg[self.group_id][self.lv_id]
		end
	end
	self.item_list = {}
	if data and next(data) then
		local id = self:createIndex(data)
		local status = false
		if self.open_type == 1 then --功能
			status = false
		elseif self.open_type == 2 then --布阵
			if data[id] then
				status = true
			else
				status = false
			end
		end
		if status then
			self.have_panel:setVisible(true)
			self.title_bg:setPositionY(462)
			self.title_txt:setPositionY(463)
			self.scrollview:setContentSize(cc.size(self.scrollview:getContentSize().width,400))
		else
			self.have_panel:setVisible(false)
			self.title_bg:setPositionY(656)
			self.title_txt:setPositionY(657)
			self.scrollview:setContentSize(cc.size(self.scrollview:getContentSize().width,600))
		end
		local _h = 0
		local have_data = nil
		for i,v in ipairs(data) do
			local item = self:createItem(v,id == v.id)
			item:setPositionX(0)
			self.scrollview:addChild(item)
			_h = _h + item:getContentSize().height
			table.insert(self.item_list, item)
			if id == v.id then
				have_data = deepCopy(v)
			end
		end
		_h = math.max(_h,self.scrollview:getContentSize().height)
		self.scrollview:setInnerContainerSize(cc.size(self.scrollview:getContentSize().width, _h))
		if _h > self.scrollview:getContentSize().height then
			self.scrollview:setTouchEnabled(true)
		else
			self.scrollview:setTouchEnabled(false)
		end
		for i,v in ipairs(self.item_list) do
			v:setPositionY(_h)
			_h = _h - v:getContentSize().height
		end

		if have_data then
			local item = self:createItem(have_data,true)
			self.have_scr:addChild(item)
			_h = math.max(item:getContentSize().height,self.have_scr:getContentSize().height)
			self.have_scr:setInnerContainerSize(cc.size(self.have_scr:getContentSize().width, _h))
			if _h > self.have_scr:getContentSize().height then
				self.have_scr:setTouchEnabled(true)
			else
				self.have_scr:setTouchEnabled(false)
			end
			item:setPositionY(_h)
		end
	end
end
--is_act 是否激活
function GemstoneBuffView:createItem(data,is_act)
	local _w = 417
	local _h = 20
	local item = ccui.Layout:create()
	item:setAnchorPoint(cc.p(0,1))
	item.icon = createSprite(PathTool.getResFrame("common", "common_90032"),15,91,item,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
	item.title = createRichLabel(22,cc.c3b(0x69, 0x5b, 0x50),cc.p(0,1),cc.p(28,107),nil,nil,380)
	item:addChild(item.title)
	item.desc = createRichLabel(22,cc.c3b(0x69, 0x5b, 0x50),cc.p(0,1),cc.p(89,74),nil,nil,300)
	item:addChild(item.desc)
	if is_act then
		-- item.title:setFontColor(cc.c3b(0xe0,0xbf,0x98))
		-- item.desc:setFontColor(cc.c3b(0xe0,0xbf,0x98))
		item.title:setFontColor(cc.c3b(0x1b,0xca,0x0d))
		item.desc:setFontColor(cc.c3b(0x1b,0xca,0x0d))
	end
	-- item.title:setString(LangStringFormat(TI18N("语言_c_7151"),data.num,BackPackConst.quality_name[data.quality] or ""))
	item.title:setString(LangStringFormat(TI18N("语言_c_7188"),data.score or 99999999))
	item.skill_cfg = Config.SkillData.data_get_skill(data.skill_id[1])
	item.desc:setString(item.skill_cfg.des)
	_h = math.max(_h, item.title:getContentSize().height + item.desc:getContentSize().height + 25)
	item:setContentSize(cc.size(_w, _h))
	item.icon:setPositionY(_h-21)
	item.title:setPositionY(_h-3)
	local add_h = math.max(36,item.title:getContentSize().height+5)
	item.desc:setPositionY(_h-add_h)
	return item
end
--获取生效技能id
function GemstoneBuffView:createIndex(data)
	local index = 0
	for i=#data,1,-1 do
		local v = data[i]
		local num = 0
		local _score = v.score
		if not _score then
			_score = 999999999999
		end
		if self.max_score >= _score then
			return v.id
		end
	end
	return index
end
function GemstoneBuffView:close_callback(  )
	self:_onClickCloseBtn()
end