--------------------------------------------
-- 
-- 
-- @Date    : 2019-01-16 19:09:44
-- @description    : 
		-- 宝石洗练
---------------------------------

GemstoneRecastPanel = GemstoneRecastPanel or BaseClass(BaseView)

local _controller = GemstoneController:getInstance()
local model = _controller:getModel()

function GemstoneRecastPanel:__init()
    self.is_full_screen = false
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.layout_name = "gemstone/gemstone_recast_panel"
	self.cost_item_list = {}
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("artifact", "artifact"), type = ResourcesType.plist},
	}
end

function GemstoneRecastPanel:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
	self.Image_2 = self.main_container:getChildByName("Image_2")
	self.win_title = self.main_container:getChildByName("win_title")
	self.win_title:setString(TI18N("语言_c_7130"))
	autoSizeTitleBg(self.win_title,self.Image_2)
	self.container = self.main_container:getChildByName("container")
	self.pos_item = self.container:getChildByName("pos_item")
	self.item_bg_bottom = self.container:getChildByName("item_bg_bottom")
	self.name_txt = self.container:getChildByName("name_txt")
	self.cost_panel = self.container:getChildByName("cost_panel")
	for i = 1, 2 do
		local item = self.cost_panel:getChildByName("cost_bg_"..i)
		item.cost_icon = item:getChildByName("cost_icon_"..i)
		item.cost_txt = item:getChildByName("cost_txt_"..i)
		self.cost_item_list[i] = item
	end
	self.left_bg = self.container:getChildByName("left_bg")
	self.left_attr_bg = self.left_bg:getChildByName("left_attr_bg")
	self.left_attr_scroll = self.left_bg:getChildByName("left_attr_scroll")
	self.left_attr_scroll:setScrollBarEnabled(false)
	self.left_skill_bg = self.left_bg:getChildByName("left_skill_bg")
	self.left_skill_scroll = self.left_bg:getChildByName("left_skill_scroll")
	self.left_skill_scroll:setScrollBarEnabled(false)
	self.right_bg = self.container:getChildByName("right_bg")
	self.right_attr_bg = self.right_bg:getChildByName("right_attr_bg")
	self.right_attr_scroll = self.right_bg:getChildByName("right_attr_scroll")
	self.right_attr_scroll:setScrollBarEnabled(false)
	self.right_skill_bg = self.right_bg:getChildByName("right_skill_bg")
	self.right_skill_scroll = self.right_bg:getChildByName("right_skill_scroll")
	self.right_skill_scroll:setScrollBarEnabled(false)
	self.base_title_1 = self.container:getChildByName("base_title_1")
	self.base_title_1:setString(TI18N("语言_c_6075"))
	self.base_title_2 = self.container:getChildByName("base_title_2")
	self.base_title_2:setString(TI18N("语言_c_6075"))
	self.base_title_3 = self.container:getChildByName("base_title_3")
	self.base_title_3:setString(TI18N("语言_c_7141"))
	self.base_title_4 = self.container:getChildByName("base_title_4")
	self.base_title_4:setString(TI18N("语言_c_7141"))
	self.close_btn = self.main_container:getChildByName("close_btn")
	self.save_btn = self.container:getChildByName("save_btn")
	self.save_txt = self.save_btn:getChildByName("label")
	self.save_txt:setString(TI18N("语言_c_325"))
	self.cancel_btn = self.container:getChildByName("cancel_btn")
	self.cancel_txt = self.cancel_btn:getChildByName("label")
	self.cancel_txt:setString(TI18N("语言_c_763"))
	self.progress_bg = self.container:getChildByName("progress_bg")
	self.progress = self.progress_bg:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    self.progress:setPercent(0)
	self.progress_label = self.progress_bg:getChildByName("progress_label")
    self.progress_label:setString(0)
	self.update_tips = createRichLabel(22, nil, cc.p(0.5, 0.5), cc.p(340, 245), -8, nil, 660)
	self.main_container:addChild(self.update_tips)
end

function GemstoneRecastPanel:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), true, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.cancel_btn, handler(self, self._onClickCancelBtn), true, 2)
	registerButtonEventListener(self.save_btn, handler(self, self._onClickSaveBtn), true, 2)
	
	self:addGlobalEvent(GemstoneEvent.Update_Hero_Info, function(pid)
		if pid and pid == self.pid then
			self.pos_list = model:getOneGemstoneInfo(self.pid, self.pos_list.pos)
			self:setData()
		end
	end)
	self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code, item_list)
		self:updateItem(bag_code, item_list)
	end)
	self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code, item_list)
		self:updateItem(bag_code, item_list)
	end)
	self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, item_list)
		self:updateItem(bag_code, item_list)
	end)

end
function GemstoneRecastPanel:updateItem(bag_code, item_list)
	for i, v in pairs(item_list) do
		if v.base_id == self.cfg_data.id then
			self.gem_list = v
			self:setData()
		else
			if self.cost_id_list and next(self.cost_id_list) then
				if table.indexof(self.cost_id_list,v.base_id) then
					self:updateCostPanel()
				end
			end
		end
	end
end
function GemstoneRecastPanel:_onClickCloseBtn(  )
	_controller:openGemstoneRecastPanel(false)
end

function GemstoneRecastPanel:_onClickCancelBtn(  )
	local cfg = Config.PartnerGemData.data_refresh[self.cfg_data.id]
	for i, v in pairs(cfg.cost1 or {}) do
		local have_num = BackpackController:getInstance():getModel():getItemNumByBid(v[1],BackPackConst.Bag_Code.GEMSTONE)
		if have_num == 0 then
			have_num = BackpackController:getInstance():getModel():getItemNumByBid(v[1])
		end
		if have_num < v[2] then
			BackpackController:getInstance():openTipsSource(true, v[1])
			return
		end
	end
	for i, v in pairs(cfg.cost2 or {}) do
		local have_num = BackpackController:getInstance():getModel():getItemNumByBid(v[1])
		if have_num < v[2] then
			BackpackController:getInstance():openTipsSource(true, v[1])
			return
		end
	end
	if self.pid and self.pid ~= 0 then
		_controller:sender22811(self.pid,self.pos_list.pos,0)
	else
		_controller:sender22811(0,0,self.gem_list.id)
	end
end
function GemstoneRecastPanel:_onClickSaveBtn(  )
	if self.pid and self.pid ~= 0 then
		_controller:sender22812(self.pid,self.pos_list.pos,0)
	else
		_controller:sender22812(0,0,self.gem_list.id)
	end
end

function GemstoneRecastPanel:openRootWnd(setting)
	setting = setting or {}
	self.data = setting.data or nil --宝石基本信息 --配置表 or 物品id
	self.gem_list = setting.gem_list or {} --宝石属性信息  背包
	self.pos_list = setting.pos_list or {} --槽位基本信息  已装备
	self.pid = setting.pid or 0 --忍者唯一id  已装备
	if not self.data then return end
	if type(self.data) == "table" then
		self.cfg_data = self.data
	else
		self.cfg_data = Config.ItemData.data_get_data(self.data)
	end
	if not self.gem_item then
		self.gem_item = BackPackItem.new(true, false)
		self.gem_item:setPositionY(15)
		self.pos_item:addChild(self.gem_item)
	end
	self.gem_item:setData(self.cfg_data)
	self.name_txt:setString(self.cfg_data.name)
	local color = BackPackConst.quality_color[self.cfg_data.quality]
	self.name_txt:setTextColor(color)
	autoSizeTitleBg(self.name_txt,self.item_bg_bottom,40,167)
	self:setData()
end
function GemstoneRecastPanel:setData()
	self:updateAttrPanel()
	self:updateSkillPanel()
	self:updateBaoDiPanel()
	self:updateCostPanel()
	self:updateBtnPanel()
end
function GemstoneRecastPanel:updateAttrPanel()
	local attr_list = {}
	if self.pid and self.pid ~= 0 then
		attr_list = self.pos_list.item_attr
	else
		attr_list = self.gem_list.main_attr
	end
	if not self.left_attr_list then
		self.left_attr_list = {}
	end
	for i, v in pairs(self.left_attr_list) do
		v:removeFromParent()
		v=nil
	end
	self.left_attr_list = {}
	local _h = math.max(self.left_attr_scroll:getContentSize().height, 40*tableLen(attr_list))
	self.left_attr_scroll:setInnerContainerSize(cc.size(self.left_attr_scroll:getContentSize().width, _h))
	self.left_attr_scroll:setTouchEnabled(_h > 93)
	for k, v in pairs(attr_list or {}) do
		local item = self:createAttrItem(v)
		table.insert(self.left_attr_list, item)
		self.left_attr_scroll:addChild(item)
		item:setPosition(cc.p(0, _h - item:getContentSize().height*k))
	end

	local right_attr_list = {}
	if self.pid and self.pid ~= 0 then
		right_attr_list = self.pos_list.attr
	else
		right_attr_list = self.gem_list.attr
	end
	if not next(right_attr_list) then
		for k, v in pairs(attr_list) do
			table.insert(right_attr_list, {attr_id=0,attr_val=0})
		end
	end
	if not self.right_attr_list then
		self.right_attr_list = {}
	end
	for i, v in pairs(self.right_attr_list) do
		v:removeFromParent()
		v=nil
	end
	self.right_attr_list = {}
	local _h = math.max(self.right_attr_scroll:getContentSize().height, 40*tableLen(right_attr_list))
	self.right_attr_scroll:setInnerContainerSize(cc.size(self.right_attr_scroll:getContentSize().width, _h))
	self.right_attr_scroll:setTouchEnabled(_h > 93)
	for k, v in pairs(right_attr_list or {}) do
		local item = self:createAttrItem(v)
		table.insert(self.right_attr_list, item)
		self.right_attr_scroll:addChild(item)
		item:setPosition(cc.p(0, _h - item:getContentSize().height*k))
	end
end
function GemstoneRecastPanel:createAttrItem(data)
	local item = ccui.Layout:create()
	item:setContentSize(cc.size(290, 40))
	item:setAnchorPoint(cc.p(0,0))
	if data.attr_id == 0 then
		item.tip = createLabel(24,cc.c3b(104,69,42),nil,30,20,TI18N("语言_c_2942"),item,nil,cc.p(0,0.5))
	else
		local attr_key = Config.AttrData.data_id_to_key[data.attr_id]
		if not attr_key then
			attr_key = Config.AttrExtraData.data_id_to_key[data.attr_id]
		end
		local icon = PathTool.getAttrIconByStr(attr_key)
		item.icon = createSprite(PathTool.getResFrame("common", icon),30,20,item,cc.p(0,0.5),LOADTEXT_TYPE_PLIST)
		local num = 20
		if judgingLanguage() then
			num = 8
		end
		local attr_name = Config.AttrData.data_key_to_name[attr_key]
		if not attr_name then
			attr_name = Config.AttrExtraData.data_key_to_name[attr_key]
		end
		item.name_txt = createLabel(24,cc.c3b(104,69,42),nil,70,20,transformTextToShort(attr_name,num)..":",item,nil,cc.p(0,0.5))
		addEvt2showAllTextTips(item.name_txt,attr_name,num,nil,nil,nil,true)
		local attr_val = data.attr_val
		local is_per = PartnerCalculate.isShowPerByStr(attr_key)
		if is_per == true then
			attr_val = (attr_val/10).."%"
		end
		local _x = item.name_txt:getPositionX() + item.name_txt:getContentSize().width + 5
		item.num_txt = createLabel(24,cc.c3b(104,69,42),nil,_x,20,attr_val,item,nil,cc.p(0,0.5))
	end
	return item
end
function GemstoneRecastPanel:updateSkillPanel()
	local skill_list = {}
	if self.pid and self.pid ~= 0 then
		skill_list = self.pos_list.item_skill
	else
		skill_list = self.gem_list.extra_attr
	end
	if not self.left_skill_list then
		self.left_skill_list = {}
	end
	for i, v in pairs(self.left_skill_list) do
		v:removeFromParent()
		v=nil
	end
	self.left_skill_list = {}
	local _h = math.max(self.left_skill_scroll:getContentSize().height, 40*tableLen(skill_list))
	self.left_skill_scroll:setInnerContainerSize(cc.size(self.left_skill_scroll:getContentSize().width, _h))
	self.left_skill_scroll:setTouchEnabled(_h > 240)
	if next(skill_list) then
		commonShowEmptyIcon(self.left_skill_scroll,false)
	else
		commonShowEmptyIcon(self.left_skill_scroll,true,{text=TI18N("语言_c_6309")})
	end
	for k, v in pairs(skill_list or {}) do
		local item = self:createSkillItem(v)
		table.insert(self.left_skill_list, item)
		self.left_skill_scroll:addChild(item)
		item:setPosition(cc.p(0, _h - item:getContentSize().height*k))
	end

	local right_skill_list = {}
	if self.pid and self.pid ~= 0 then
		right_skill_list = self.pos_list.holy_color_attr
	else
		right_skill_list = self.gem_list.holy_color_attr
	end
	if not next(right_skill_list) then
		local cfg = Config.PartnerGemData.data_base_info[self.cfg_data.id]
		if cfg and cfg.rand_skill and next(cfg.rand_skill) then
			for k, v in pairs(cfg.rand_skill) do
				table.insert(right_skill_list, {pos=0,color=0})
			end
		end
	end
	if not self.right_skill_list then
		self.right_skill_list = {}
	end
	for i, v in pairs(self.right_skill_list) do
		v:removeFromParent()
		v=nil
	end
	self.right_skill_list = {}
	local _h = math.max(self.right_skill_scroll:getContentSize().height, 40*tableLen(right_skill_list))
	self.right_skill_scroll:setInnerContainerSize(cc.size(self.right_skill_scroll:getContentSize().width, _h))
	self.right_skill_scroll:setTouchEnabled(_h > 240)
	for k, v in pairs(right_skill_list or {}) do
		local item = self:createSkillItem(v)
		table.insert(self.right_skill_list, item)
		self.right_skill_scroll:addChild(item)
		item:setPosition(cc.p(0, _h - item:getContentSize().height*k))
	end
end

-- 创建一个技能item
function GemstoneRecastPanel:createSkillItem(data)
	local item = ccui.Layout:create()
	item:setContentSize(cc.size(290, 110))
	item:setAnchorPoint(cc.p(0,0))
	item.skill = SkillItem.new(true,true,true,0.8)
    item:addChild(item.skill)
	item.skill:setPosition(cc.p(50,60))
	local lib = data.attr_id or data.pos or data.lib
	local skill_id = data.attr_val or data.color or data.skill_id
	if lib~=0 and skill_id~=0 then
		local cfg = {}
		local gem_cfg = {}
		cfg = Config.SkillData.data_get_skill(skill_id)
		if Config.PartnerGemData.data_skill[lib] then
			gem_cfg = Config.PartnerGemData.data_skill[lib][skill_id]
		end
		item.skill:setData(cfg)
		item.name = createLabel(22,cc.c4b(104,69,42,255),nil,100, 110,"",item,1,cc.p(0,1))
		local txt_name = ""
		if gem_cfg and gem_cfg.name and gem_cfg.name ~= "" then
			txt_name = gem_cfg.name
		elseif cfg and cfg.name and cfg.name ~= "" then
			txt_name = cfg.name
		end
		local num = 10
		if judgingLanguage() then
			num = 6
		end
		item.name:setString(transformTextToShort(txt_name,num))
		local color = BackPackConst.quality_color[self.cfg_data.quality]
		item.name:setTextColor(color)
		addEvt2showAllTextTips(item.name,txt_name,num,nil,nil,nil,nil,true)
		item.scroll = createScrollView(180,75,100,5,item,ccui.ScrollViewDir.vertical)
		item.scroll:setBounceEnabled(false)
		item.desc = createRichLabel(20,cc.c4b(104,69,42,255),cc.p(0,1),cc.p(0, 0),-4,nil,175)
		item.scroll:addChild(item.desc)
		if gem_cfg and gem_cfg.desc and gem_cfg.desc ~= "" then
			item.desc:setString(gem_cfg.desc)
		elseif cfg and cfg.des and cfg.des ~= "" then
			item.desc:setString(cfg.des)
		end
		local _h = math.max(item.scroll:getContentSize().height,item.desc:getContentSize().height)
		item.scroll:setInnerContainerSize(cc.size(item.scroll:getContentSize().width,_h))
		item.desc:setPositionY(_h)
	else
		item.skill:setData({})
		local icon_res = PathTool.getResFrame("artifact","artifact_1003")
		item.random_icon = createSprite(icon_res, 50, 60, item, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
		item.random_des = createLabel(24,cc.c4b(104,69,42,255),nil,110, 60,TI18N("语言_c_6309"),item,1,cc.p(0,0.5))
	end
	return item
end
function GemstoneRecastPanel:updateBaoDiPanel()
	local max_num = 0
	local num = 0
	local extra_list = {}
	if self.pid and self.pid ~= 0 then
		extra_list = self.pos_list.extra
	else
		extra_list = self.gem_list.extra
	end
	for i, v in pairs(extra_list) do
		if v.extra_k == 2 then
			num = v.extra_v
		end
	end
	local cfg = Config.PartnerGemData.data_refresh[self.cfg_data.id]
	max_num = cfg and cfg.num or 0
	if max_num ~= 0 then
		num = num % max_num
	end
	local txt = TI18N("语言_c_2986")
	self.update_tips:setString(string.format(txt,max_num - num))
	local function clickLinkCallBack( _type, value )
		if _type == "href" then
			_controller:openGemstonePreviewSkillWindow(true,self.cfg_data.id,2)
		end
	end
	self.update_tips:addTouchLinkListener(clickLinkCallBack,{"href"})
	self.progress:setPercent(num/max_num*100)
	self.progress_label:setString(string.format("%d/%d",num,max_num))
end
function GemstoneRecastPanel:updateCostPanel()
	self.cost_id_list = {}
	local cost_list = {}
	local cfg = Config.PartnerGemData.data_refresh[self.cfg_data.id]
	for i, v in pairs(cfg.cost1 or {}) do
		table.insert(self.cost_id_list,v[1])
		table.insert(cost_list,v)
	end
	for i, v in pairs(cfg.cost2 or {}) do
		table.insert(self.cost_id_list,v[1])
		table.insert(cost_list,v)
	end
	if #cost_list == 1 then
		self.cost_item_list[1]:setPositionX(340)
	else
		self.cost_item_list[1]:setPositionX(204)
	end
	for i=1, tableLen(self.cost_item_list) do
		local item = self.cost_item_list[i]
		local list = cost_list[i]
		if list then
			item:setVisible(true)
			local item_cfg = Config.ItemData.data_get_data(list[1])
			if item_cfg then
				item.cost_icon:loadTexture(PathTool.getItemRes(item_cfg.icon), LOADTEXT_TYPE)
			end
			local have_num = BackpackController:getInstance():getModel():getItemNumByBid(list[1],BackPackConst.Bag_Code.GEMSTONE)
			if have_num == 0 then
				have_num = BackpackController:getInstance():getModel():getItemNumByBid(list[1])
			end
			item.cost_txt:setString(MoneyTool.GetMoneyString(have_num) .. "/" .. list[2])
			if have_num >= list[2] then
				item.cost_txt:setTextColor(cc.c3b(255, 246, 228))
			else
				item.cost_txt:setTextColor(cc.c3b(253, 71, 71))
			end
		else
			item:setVisible(false)
		end
	end
end
function GemstoneRecastPanel:updateBtnPanel()
	local right_attr_list = {}
	if self.pid and self.pid ~= 0 then
		right_attr_list = self.pos_list.attr
	else
		right_attr_list = self.gem_list.attr
	end
	local right_skill_list = {}
	if self.pid and self.pid ~= 0 then
		right_skill_list = self.pos_list.holy_color_attr
	else
		right_skill_list = self.gem_list.holy_color_attr
	end
	local status = false
	for i, v in pairs(right_attr_list or {}) do
		if v.attr_id ~= 0 and v.attr_val ~= 0 then
			status = true
		end
	end
	for i, v in pairs(right_skill_list or {}) do
		if v.color ~= 0 and v.pos ~= 0 then
			status = true
		end
	end
	if not status then
		self.cancel_btn:setPositionX(340)
		self.save_btn:setVisible(false)
	else
		self.cancel_btn:setPositionX(175)
		self.save_btn:setVisible(true)
	end

end

function GemstoneRecastPanel:close_callback(  )
	if self.gem_item then
		self.gem_item:DeleteMe()
		self.gem_item = nil
	end
	for i, v in pairs(self.left_attr_list or {}) do
		v:removeFromParent()
		v=nil
	end
	for i, v in pairs(self.right_attr_list or {}) do
		v:removeFromParent()
		v=nil
	end
	for i, v in pairs(self.left_skill_list or {}) do
		v:removeFromParent()
		v=nil
	end
	for i, v in pairs(self.right_skill_list or {}) do
		v:removeFromParent()
		v=nil
	end
	self:_onClickCloseBtn()
end