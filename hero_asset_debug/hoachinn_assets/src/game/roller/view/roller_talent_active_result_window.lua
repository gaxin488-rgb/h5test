------------------------------------------------------------------
RollerTalentActiveResultWindow = RollerTalentActiveResultWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()
local string_format = string.format

function RollerTalentActiveResultWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Tips
	self.layout_name = "roller/roller_talent_up_result_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
	}
	self.lev_list = {}
	self.item_list = {}
	self.can_touch = false
	self.auto_limit_time = 5
end 

function RollerTalentActiveResultWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	self.title_container = self.root_wnd:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

	self.main_container = self.root_wnd:getChildByName("container")
	self.upstar_layer = self.main_container:getChildByName("upstar_layer")
	self.confirm_btn = self.main_container:getChildByName("confirm_btn")
	self.get_btn_old = self.upstar_layer:getChildByName("get_btn_old")
	self.get_btn_old_label = self.get_btn_old:getChildByName("label")
	self.get_btn_new = self.upstar_layer:getChildByName("get_btn_new")
	self.get_btn_new_label = self.get_btn_new:getChildByName("label")
	self.tips1 = self.upstar_layer:getChildByName("tips1")
	setTextMaxWidth(self.tips1, 600, -4)
	local tips = self.upstar_layer:getChildByName("tips")
	local posx = tips:getPositionX()
	local posy = tips:getPositionY()
	self.tips = createRichLabel(24, cc.c4b(0xe1, 0xcb, 0x8e, 0xff), cc.p(0.5, 0.5), cc.p(posx, posy), -4, nil, 600)
	self.upstar_layer:addChild(self.tips)
end

function RollerTalentActiveResultWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			if self.can_touch  == true then
				self:onClickClose()
			end
		end
	end)
end

function RollerTalentActiveResultWindow:onClickClose()
    controller:openRollerTalentActiveResultWindow(false)
end

function RollerTalentActiveResultWindow:openRootWnd(id)
    playOtherSound("c_get") 
	self:handleEffect(true)
	self:starTimeTicket()
	self.id = id

	local cfg = model:getRollerTalentInfo(id)
	local step = cfg.group
	local talent_quality = cfg.talent_quality
	if talent_quality == 3 then
		self.get_btn_new_label:setString(string_format(TI18N("语言_c_7208"),step,1))
		local last_step = step - 1
		local last_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_talent[last_step]
		if last_cfg then
			local last_max_lv = tableLen(last_cfg)
			self.get_btn_old_label:setString(string_format(TI18N("语言_c_7208"),last_step,last_max_lv))
		else
			self.get_btn_old_label:setString(string_format(TI18N("语言_c_7208"),0,0))
		end
		local skill = cfg.active_skill[1]
		local skill_cfg = Config.SkillData.data_get_skill(skill)
		self.tips:setString(skill_cfg.des)
		self.tips1:setString(skill_cfg.name)
		self.get_btn_old:loadTexture(PathTool.getResFrame("scroll_talent",RollerConst.TalentIcon[last_step]), LOADTEXT_TYPE_PLIST)
		self.get_btn_new:loadTexture(PathTool.getResFrame("scroll_talent",RollerConst.TalentIcon[step]), LOADTEXT_TYPE_PLIST)
	elseif talent_quality == 2 then
		local num, max_num = model:getTalentInfoLevelById(step)
		self.get_btn_new_label:setString(string_format(TI18N("语言_c_7208"),step,num))
		self.get_btn_old_label:setString(string_format(TI18N("语言_c_7208"),step,num-1))
		self.tips1:setString(TI18N("语言_c_7228"))
		local skill = cfg.skill[1]
		local skill_cfg = Config.SkillData.data_get_skill(skill)
		self.tips:setString(skill_cfg.des)
		self.get_btn_old:loadTexture(PathTool.getResFrame("scroll_talent",RollerConst.TalentIcon[step]), LOADTEXT_TYPE_PLIST)
		self.get_btn_new:loadTexture(PathTool.getResFrame("scroll_talent",RollerConst.TalentIcon[step]), LOADTEXT_TYPE_PLIST)
	end

end

function RollerTalentActiveResultWindow:starTimeTicket()
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

function RollerTalentActiveResultWindow:clearTimeticket()
	if self.time_ticket then
		GlobalTimeTicket:getInstance():remove(self.time_ticket)
		self.time_ticket = nil
	end
end

function RollerTalentActiveResultWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
		local action = PlayerAction.action
		if not tolua.isnull(self.title_container) and self.play_effect == nil then
			self.play_effect = createEffectSpine("E51009", cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, action)
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end 

function RollerTalentActiveResultWindow:close_callback()
	self:handleEffect(false)
	self:clearTimeticket()
    controller:openRollerTalentActiveResultWindow(false)
end