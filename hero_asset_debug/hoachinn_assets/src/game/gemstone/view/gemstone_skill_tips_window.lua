--------------------------------------------
-- 
-- 
-- @Date    : 2019-01-16 19:09:44
-- @description    : 
		-- 宝石技能tips
---------------------------------

GemstoneSkillTipsWindow = GemstoneSkillTipsWindow or BaseClass(BaseView)

local _controller = GemstoneController:getInstance()
local _model = _controller:getModel()
local hero_model = HeroController:getInstance():getModel()

function GemstoneSkillTipsWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Mini  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
	self.pos_list = {}
	self.skill_item_list = {}
    self.layout_name = "gemstone/gemstone_skill_tips_window"
end

function GemstoneSkillTipsWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 2)
	self.top_panel = self.main_panel:getChildByName("top_panel")
	self.top_bg = self.top_panel:getChildByName("top_bg")
	self.skill_pos_list = {}
	for i = 1, 4 do
		self.skill_pos_list[i] = self.top_bg:getChildByName("skill_"..i)
		setChildUnEnabled(true,self.skill_pos_list[i])
	end
	self.hero_icon = self.top_panel:getChildByName("hero_icon")
	for i = 1, 6 do
		self.pos_list[i] = self.top_panel:getChildByName("pos_"..i)
		self.pos_list[i]:setVisible(false)
	end
	self.skill_panel = self.main_panel:getChildByName("skill_panel")
	self.line_1 = self.skill_panel:getChildByName("line_1")
	self.skill_title = self.skill_panel:getChildByName("skill_title")
	self.line_2 = self.skill_panel:getChildByName("line_2")
	self.skill_title:setString(TI18N("语言_c_7136"))
	setLeftRightImg(self.line_1,self.skill_title,self.line_2,30)
	self.skill_sroll = self.skill_panel:getChildByName("skill_sroll")
    self.skill_sroll:setScrollBarEnabled(false)
	self.close_btn = self.main_panel:getChildByName("close_btn")

	self.fun_open_panel = self.main_panel:getChildByName("fun_open_panel")
	self.fun_open_panel:setVisible(false)
	self.fun_open_tips = self.fun_open_panel:getChildByName("fun_open_tips")
	self.fun_open_tips:setString(TI18N("语言_c_8001"))
	setTextMaxWidth(self.fun_open_tips,520,-6)
end

function GemstoneSkillTipsWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
end

function GemstoneSkillTipsWindow:_onClickCloseBtn(  )
	_controller:openGemstoneSkillTipsWindow(false)
end

--type 1普通2预览
function GemstoneSkillTipsWindow:openRootWnd(hero_vo,type)
	self.hero_vo = hero_vo
	self.look_type = type or 1
	self:updateHeroIcon()
	self:updatePosList()
	self:updateScroll()
end
--刷新忍者icon
function GemstoneSkillTipsWindow:updateHeroIcon()
	local key = getNorKey(self.hero_vo.bid, self.hero_vo.star)
	local star_config = Config.PartnerData.data_partner_star(key)
	if star_config then
		loadSpriteTexture(self.hero_icon, PathTool.getHeadIcon(star_config.head_id), LOADTEXT_TYPE)
	end
end
--刷新忍者穿戴宝石情况
function GemstoneSkillTipsWindow:updatePosList()
	if self.look_type == 2 then
		self.fun_open_panel:setVisible(true)
		for i = 1, 6 do
			loadSpriteTexture(self.pos_list[i], PathTool.getResFrame("gem", "gem_pic_08_05"), LOADTEXT_TYPE_PLIST)
			self.pos_list[i]:setVisible(true)
		end
	else
		self.fun_open_panel:setVisible(false)
		self.skill_sroll:setContentSize(cc.size(528,635))
		for i = 1, 6 do
			local data = _model:getOneGemstoneInfo(self.hero_vo.partner_id,i)
			if data then
				local cfg = Config.ItemData.data_get_data(data.item_bid)
				if cfg then
					loadSpriteTexture(self.pos_list[i], PathTool.getResFrame("gem", "gem_pic_08_0"..cfg.quality), LOADTEXT_TYPE_PLIST)
					self.pos_list[i]:setVisible(true)
				else
					self.pos_list[i]:setVisible(false)
				end
			else
				self.pos_list[i]:setVisible(false)
			end
		end
	end

end
--刷新技能列表
function GemstoneSkillTipsWindow:updateScroll()
	self.skill_cfg = Config.PartnerGemData.data_skill2[hero_model:getSelfConvertStaBid(self.hero_vo.bid)] or {}
	self.skill_list = {}
	for i,v in pairs(self.skill_cfg) do
		table.insert(self.skill_list, v)
	end
	local sort_func = SortTools.tableCommonSorter({{"quality", false},{"num", false}})
	table.sort(self.skill_list, sort_func)
	local scroll_h = 0
	local max_id = 0
	for k, v in ipairs(self.skill_list) do
		local item,_h,status = self:getSkillItem(v,k)
		if status then
			max_id = v.desc
		end
		self.skill_sroll:addChild(item)
		scroll_h = scroll_h + _h + 10
		self.skill_item_list[k] = item
	end
	if self.skill_cfg and self.skill_cfg[max_id] and self.skill_cfg[max_id].bg and self.skill_cfg[max_id].bg ~= "" then
		local res_path = PathTool.getPlistImgForDownLoad("gem", self.skill_cfg[max_id].bg)
		self.res_load = loadSpriteTextureFromCDN(self.top_bg, res_path, ResourcesType.single, self.res_load)
	end
	local _h = math.max(self.skill_sroll:getContentSize().height, scroll_h)
	local _w = self.skill_sroll:getContentSize().width
	self.skill_sroll:setInnerContainerSize(cc.size(_w,_h))
	for k, v in ipairs(self.skill_item_list) do
		v:setPosition(cc.p(0, _h))
		_h = _h - v:getContentSize().height - 10
	end
end

function GemstoneSkillTipsWindow:getSkillItem(data,k)
	local item = ccui.Layout:create()
    item:setAnchorPoint(cc.p(0, 1))
	local _w = 528
	local _h = 140
	item:setContentSize(cc.size(_w, _h))
	item.skill_item = SkillItem.new(true, true, true, 0.8)
	item.skill_item:setPositionX(52)
	item:addChild(item.skill_item)
	local skill_cfg = Config.SkillData.data_get_skill(data.desc)
	local status = false
	if skill_cfg then
		-- if data.desc and data.desc ~= 0 and Config.SkillData.data_get_skill(data.desc) then
		-- 	skill_cfg = Config.SkillData.data_get_skill(data.desc)
		-- end
		item.skill_item:setData(skill_cfg)
		local name_txt = skill_cfg.name
		item.skill_name = createLabel(22,cc.c3b(0xfe,0xee,0xba),nil,109,0,"",item,nil,cc.p(0,1))
		item.skill_name:setWidth(400)
		item.skill_name:setLineSpacing(-8)
		item.skill_name:setString(name_txt)
		item.lock_icon = createSprite(PathTool.getResFrame("common", "common_1043"),122,50,item,cc.p(0.5,0.5),LOADTEXT_TYPE)
		item.lock_icon:setScale(0.5)
		item.unlock_desc = createLabel(20,cc.c3b(0xc1,0xb7,0xab),nil,140,0,"",item,nil,cc.p(0,0))
		item.unlock_desc:setWidth(380)
		item.unlock_desc:setLineSpacing(-8)
		local quality_name = BackPackConst.quality_name[data.quality]
		item.unlock_desc:setString(LangStringFormat(data.desc3,data.num,quality_name))
		if self.look_type == 2 or _model:getResonanceIsOpen(self.hero_vo.partner_id,data.desc) then
			item.unlock_desc:setTextColor(cc.c3b(0x1b,0xca,0x0d))
			loadSpriteTexture(item.lock_icon, PathTool.getResFrame("common", "common_1043"), LOADTEXT_TYPE_PLIST)
			setChildUnEnabled(false,self.skill_pos_list[k])
			status = true
		else
			item.unlock_desc:setTextColor(cc.c3b(0xff,0x15,0x15))
			loadSpriteTexture(item.lock_icon, PathTool.getResFrame("common", "common_90009_1"), LOADTEXT_TYPE_PLIST)
			setChildUnEnabled(true,self.skill_pos_list[k])
			status = false
		end
		item.desc = createRichLabel(20,cc.c3b(0xc1,0xb7,0xab),cc.p(0,1),cc.p(10,0),-6,nil,510)
		local desc_txt = skill_cfg.des
		item.desc:setString(desc_txt)
		item:addChild(item.desc)
		
		local need_h = 0
		need_h = need_h + item.desc:getContentSize().height + 105
		_h = math.max(_h, need_h)
		item:setContentSize(cc.size(_w, _h))
		item.skill_item:setPositionY(_h - 53)
		item.skill_name:setPositionY(_h - 10)
		item.lock_icon:setPositionY(_h - 83)
		item.unlock_desc:setPositionY(_h-98)
		item.desc:setPositionY(_h - 101)
	end

    return item,_h,status
end
function GemstoneSkillTipsWindow:close_callback(  )
	for i,v in ipairs(self.skill_item_list) do
		v:removeFromParent()
		v=nil
	end
	if self.res_load then 
        self.res_load:DeleteMe()
        self.res_load = nil
    end
	self.skill_item_list={}
	self:_onClickCloseBtn()
end