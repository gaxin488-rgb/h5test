
RollerActiveResultWindow = RollerActiveResultWindow or BaseClass(BaseView)

local controller =  RollerController:getInstance()
local string_format = string.format

function RollerActiveResultWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Tips
	self.layout_name = "roller/roller_active_result_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("ninja_treasure/ninja_treasure","ninja_treasure"), type = ResourcesType.plist},
	}
	self.lev_list = {}
	self.star_list = {}
	self.can_touch = false
	self.auto_limit_time = 5
end 

function RollerActiveResultWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	
	self.main_container = self.root_wnd:getChildByName("container")
	self.title_container = self.main_container:getChildByName("title_container")
	self.title_width = self.title_container:getContentSize().width
	self.title_height = self.title_container:getContentSize().height

	self.confirm_btn = self.main_container:getChildByName("confirm_btn")
	self.confirm_btn:ignoreContentAdaptWithSize(true)

	self.active_layer = self.main_container:getChildByName("active_layer")

	self.icon = self.active_layer:getChildByName("icon")
	self.quality_icon = self.active_layer:getChildByName("quality_icon")
	self.equip_name = self.active_layer:getChildByName("equip_name")
	self.name_bg = self.active_layer:getChildByName("name_bg")
	self.tips = self.active_layer:getChildByName("tips") 
	self.attr_bg = self.active_layer:getChildByName("attr_bg")

	self.skill_node = self.active_layer:getChildByName("skill_node")
	self.skill_item1 = SkillItem.new(true, true, true, 0.8, true)
	local res = PathTool.getResFrame("ninja_treasure", "ninja_treasure_37")
	local img2 = createImage(self.skill_item1, res, 5,109, cc.p(0.5, 0.5), true,4)
	self.skill_item1.lv_bg = img2
	local lv = createLabel(24, cc.c4b(0xfe, 0xff, 0x80, 0xff), cc.c4b(0x1e, 0x04, 0x00, 0xff), 13, 18, nil,self.skill_item1.lv_bg,1,cc.p(0.5, 0.5))
	self.skill_item1.lv = lv
	self.skill_node:addChild(self.skill_item1)

	self.skill_name = self.active_layer:getChildByName("skill_name")
	self.desc_scroller = self.active_layer:getChildByName("desc_scroller")
	self.desc_scroller:setScrollBarEnabled(false)
	self.skill_desc = createRichLabel(20, cc.c4b(0xff, 0xee, 0xdd, 0xff), cc.p(0, 1), cc.p(0, -17), -4, nil, 506)
	self.desc_scroller:addChild(self.skill_desc)

	self.star_layer = self.active_layer:getChildByName("star_layer")
end

function RollerActiveResultWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			if self.can_touch  == true then
				self:onClickClose()
			end
		end
	end)
end

function RollerActiveResultWindow:onClickClose()
    controller:openRollerActiveResultWindow(false)
end

function RollerActiveResultWindow:openRootWnd(id)
    playOtherSound("c_get") 
	self:handleEffect(true)
	self:starTimeTicket()
	-- self.tips:setString(TI18N("语言_c_790"))
	local basecfg = Config.ProhibitedScrollData.data_get_proh_scroll[id]
	local pic_info = basecfg.show[1]
	if pic_info then
		if pic_info[1] == 1 then
			local res = PathTool.getRollerIcon(pic_info[2],2)
			loadSpriteTexture(self.icon, res, LOADTEXT_TYPE)
			self.icon:setVisible(true)
		elseif pic_info[1] == 2 then
			local eff_id = pic_info[2]
			if not self.icon_eff then
				self.icon_eff = createEffectSpine( eff_id, cc.p(0, 0), cc.p(0.5, 0.5), true, "action1")
				self.icon:addChild(self.icon_eff)
			end
		end
	end

    self.equip_name:setString(basecfg.name)
    local name_width = self.equip_name:getContentSize().width
    if name_width > 130 then
        local total_width = name_width + 52 + 64
        self.name_bg:setContentSize(cc.size(total_width/0.8, 82))
        self.quality_icon:setPositionX(360-total_width/2 + 40)
    end

	local qulality = basecfg.quality
    loadSpriteTexture(self.quality_icon, PathTool.getResFrame("prohibited_scroll", RollerConst.QualityIcon[qulality]), LOADTEXT_TYPE_PLIST)

	local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[id]
	local lv_cfg= Config.ProhibitedScrollData.data_get_proh_scroll_enhance[qulality]
	local roller_data = controller:getModel():getRollerDataById(id)
    if not roller_data then return end
    local star = roller_data.star
	local lv = roller_data.lev

	local data = star_cfg[star]
	local data2 = lv_cfg[lv]
	local attr = deepCopy(data.attr)
	local now_attr2 = data2["attr"]
	if now_attr2 and next(now_attr2) then
		for k, v in pairs(now_attr2) do
			table.insert(attr,v)
		end
	end
	local temp = {}
    for k, v in pairs(attr) do
        local key = v[1]
        local num = v[2]
        if temp[key] then
            temp[key] = temp[key] + num
        else
            temp[key] = num
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
	local line_num = math.ceil(#fengyin_attr/2)
	local _hei = 96/line_num
	for i, v in ipairs(fengyin_attr) do
		local res, attr_name, attr_val = commonGetAttrInfoByKeyValue(v[1], v[2])
		local attr_txt = createRichLabel(20, cc.c4b(0xe5, 0xcf, 0x91, 0xff), cc.p(0,0.5), cc.p(0, 21))
		self.attr_bg:addChild(attr_txt)
		attr_txt:setString(string.format("<div fontcolor=#e5cf91>%s:  </div><div fontcolor=#fffdf7>+%s</div>",attr_name,attr_val))

		local itemX = ((i-1)%2)*360 + 60
		attr_txt:setPositionX(itemX)
		local itemY = 96 - math.floor((i-1)/2)*_hei - _hei/2
		attr_txt:setPositionY(itemY)
	end

	local skill_id = data.passive_skill[1]
	local skill_cfg = Config.SkillData.data_get_skill(skill_id)
	self.skill_item1:setData(skill_cfg)
	self.skill_item1.lv:setString(skill_cfg.level)
	self.skill_name:setString(skill_cfg.name)
	self.skill_desc:setString(skill_cfg.des)
	self.skill_desc:setPositionY(80)
	local desc_height = self.skill_desc:getContentSize().height
	if desc_height > 80 then
		self.desc_scroller:setInnerContainerSize(cc.size(506, desc_height))
		self.skill_desc:setPositionY(desc_height)
	end

	local max_star = controller:getModel():getMaxStarById(id)
	self:setStarPanel(max_star)
end

function RollerActiveResultWindow:setStarPanel(max_star)
	self.star_list = createOnlyStar(max_star,self.star_layer,29)
    for i, v in ipairs(self.star_list) do
        setChildUnEnabled(true, v)
        if i <= 0 then
            setChildUnEnabled(false, v)
        end
    end
end

function RollerActiveResultWindow:starTimeTicket()
	self.cut_time = 0
	if self.time_ticket == nil then
		self.time_ticket = GlobalTimeTicket:getInstance():add(function() 
			self.cut_time = self.cut_time + 0.5
			if self.cut_time > 0.5 then
				self.can_touch = true
			end
			if self.cut_time >= self.auto_limit_time then
				self:onClickClose()
			end
		end, 0.5)
	end
end

function RollerActiveResultWindow:clearTimeticket()
	if self.time_ticket then
		GlobalTimeTicket:getInstance():remove(self.time_ticket)
		self.time_ticket = nil
	end
end

function RollerActiveResultWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
		local action = PlayerAction.action_1
		if not tolua.isnull(self.title_container) and self.play_effect == nil then
			self.play_effect = createEffectSpine("E24303", cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, action)
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end 

function RollerActiveResultWindow:close_callback()
	self:handleEffect(false)
	self:clearTimeticket()
    controller:openRollerActiveResultWindow(false)
end