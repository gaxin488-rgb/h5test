RollerFengyinResultWindow = RollerFengyinResultWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local string_format = string.format

function RollerFengyinResultWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Tips
	self.layout_name = "roller/roller_fengyin_result"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
	}

	self.lev_list = {}
	self.item_list = {}
	self.can_touch = false
	self.auto_limit_time = 5
end 

function RollerFengyinResultWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	self.main_container = self.root_wnd:getChildByName("container")

	self.title_container = self.root_wnd:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

	self.tips2 = self.main_container:getChildByName("tips2")
	-- 升级奖励
	self.upstar_layer = self.main_container:getChildByName("upstar_layer")
	self.equip_img1 = self.upstar_layer:getChildByName("equip_img1")
	self.equip_name = self.upstar_layer:getChildByName("equip_name")
	self.tips1 = self.upstar_layer:getChildByName("tips1")
	self.tips = self.upstar_layer:getChildByName("tips")
	self.tips1:setString(TI18N("语言_halm_01_25"))
	self.tips:setString(TI18N("语言_c_6198"))

	self.scroller_list = self.upstar_layer:getChildByName("list")
	for i = 1,11,1 do
		local attr_item = self.scroller_list:getChildByName("atrr_"..i)
		attr_item:setVisible(false)
		local attr1 = attr_item:getChildByName("attr1")
		local attr2 = attr_item:getChildByName("attr2")
		local object = {}
		object.attr_item = attr_item
		object.attr1 = attr1
		object.attr2 = attr2
		self.lev_list[i] = object
	end
	local lv_attr = self.upstar_layer:getChildByName("lv_atrr")
	self.old_lv = lv_attr:getChildByName("attr1")
	self.new_lv = lv_attr:getChildByName("attr2")

end

function RollerFengyinResultWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			if self.can_touch  == true then
				self:onClickClose()
			end
		end
	end)
end

function RollerFengyinResultWindow:onClickClose()
    controller:openRollerFengyinResultWindow(false)
end

function RollerFengyinResultWindow:openRootWnd(old_seal,now_seal,id)
    playOtherSound("c_get") 
	self:handleEffect(true)
	self:starTimeTicket()
	local basecfg = Config.ProhibitedScrollData.data_get_proh_scroll[id]
	local pic_info = basecfg.show[1]
	if pic_info then
		if pic_info[1] == 1 then
			local res = PathTool.getRollerIcon(pic_info[2],2)
			loadSpriteTexture(self.equip_img1, res, LOADTEXT_TYPE)
		elseif pic_info[1] == 2 then
			local eff_id = pic_info[2]
			if not self.icon_eff then
				self.icon_eff = createEffectSpine( eff_id, cc.p(0, 0), cc.p(0.5, 0.5), true, "action1")
				self.equip_img1:addChild(self.icon_eff)
			end
		end
	end
    self.equip_name:setString(basecfg.name)

	local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal_resonate[basecfg.quality]
    local list = {}
    for k, v in pairs(cfg) do
        table.insert(list, deepCopy(v))
    end
    table.sort(list, function(a,b) return a.level < b.level end)
    local info,index
    for i, v in ipairs(list) do
        local data = v
        if data.level > old_seal and data.level <= now_seal then
            info = data
			index = i
            break
        end 
    end
	local old_cfg = list[index-1]
	if old_cfg then
		local now_attr = info.attrs
		local old_attr = old_cfg.attrs
		local num = math.max(#now_attr,#old_attr)
		local s_height =  math.max(num * 42,145)
		self.scroller_list:setInnerContainerSize(cc.size(640,s_height))

		for i, v in ipairs(self.lev_list) do
			local _attr_name = ""
			if now_attr[i] then
				local now_attr_key = now_attr[i][1]
				local now_attr_val = now_attr[i][2]
				local res, now_attr_name, now_attr_ = commonGetAttrInfoByKeyValue(now_attr_key, now_attr_val)
				v.attr2:setString(now_attr_)
				self.lev_list[i].attr_item:setVisible(true)
				_attr_name = now_attr_name
				self.lev_list[i].attr_item:setPositionX(320)
				self.lev_list[i].attr_item:setPositionY(s_height - (i-1)*42)
			end
			if old_attr[i] then
				local old_attr_key = old_attr[i][1]
				local old_attr_val = old_attr[i][2]
				local res, old_attr_name, old_attr_ = commonGetAttrInfoByKeyValue(old_attr_key, old_attr_val)
				v.attr1:setString(old_attr_name..":"..old_attr_)
			else
				v.attr1:setString(_attr_name..":"..0)
			end
		end
		self.old_lv:setString(string.format(TI18N("语言_c_4520"),old_cfg.level)) -- "Lv."..old_cfg.level
	else
		local now_attr = info.attrs
		local num = #now_attr
		local s_height =  math.max(num * 42,145) 
		self.scroller_list:setInnerContainerSize(cc.size(640,s_height))

		for i, v in ipairs(self.lev_list) do
			if now_attr[i] then
				local now_attr_key = now_attr[i][1]
				local now_attr_val = now_attr[i][2]
				local res, now_attr_name, now_attr_ = commonGetAttrInfoByKeyValue(now_attr_key, now_attr_val)
				v.attr1:setString(now_attr_name..":0")
				v.attr2:setString(now_attr_)
				v.attr_item:setVisible(true)
				v.attr_item:setPositionX(320)
				v.attr_item:setPositionY(s_height - (i-1)*42)
			end
		end

		self.old_lv:setString(string.format(TI18N("语言_c_4520"),0))--"Lv.0")
	end
	self.new_lv:setString(string.format(TI18N("语言_c_4520"),info.level))--"Lv."..info.level)
	self.tips2:setString(string.format(TI18N("语言_c_7233"),info.level)) 
end

function RollerFengyinResultWindow:starTimeTicket()
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

function RollerFengyinResultWindow:clearTimeticket()
	if self.time_ticket then
		GlobalTimeTicket:getInstance():remove(self.time_ticket)
		self.time_ticket = nil
	end
end

function RollerFengyinResultWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
		local effect_id = 274
		local action = PlayerAction.action_5
		if not tolua.isnull(self.title_container) and self.play_effect == nil then
			self.play_effect = createEffectSpine("E24304", cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, action)
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end

function RollerFengyinResultWindow:close_callback()
	self:handleEffect(false)
	if self.res_load then
		self.res_load:DeleteMe()
	end
	self.res_load = nil
	self:clearTimeticket()
    controller:openRollerFengyinResultWindow(false)
end