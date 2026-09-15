RollerUpstarResultWindow = RollerUpstarResultWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()

function RollerUpstarResultWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Tips
	self.layout_name = "roller/roller_upstar_result"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("ninja_treasure/ninja_treasure", "ninja_treasure"), type = ResourcesType.plist},
	}
	self.star_list1 = {}
	self.star_list2 = {}
	self.lev_list = {}
	self.item_list = {}
	self.can_touch = false
	self.auto_limit_time = 5
end 

function RollerUpstarResultWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	self.main_container = self.root_wnd:getChildByName("container")

	self.title_container = self.root_wnd:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

	-- 升级奖励
	self.upstar_layer = self.main_container:getChildByName("upstar_layer")
	self.equip_img1 = self.upstar_layer:getChildByName("equip_img1")
	self.equip_img2 = self.upstar_layer:getChildByName("equip_img2")
	self.star_layer1 = self.upstar_layer:getChildByName("star_layer1")
	self.star_layer2 = self.upstar_layer:getChildByName("star_layer2")

	self.tips1 = self.upstar_layer:getChildByName("tips1")
	self.tips1:setString(TI18N("语言_c_2935"))
	self.tips = self.upstar_layer:getChildByName("tips")
	self.tips:setString(TI18N("语言_c_2936"))

	local attr_scroller = self.upstar_layer:getChildByName("attr_scroller")
	attr_scroller:setScrollBarEnabled(false)
	self.attr_scroller = attr_scroller
	for i = 1, 10, 1 do
		local attr_item = attr_scroller:getChildByName("atrr_"..i)
		attr_item:setVisible(false)
		local attr1 = attr_item:getChildByName("attr1")
		local attr2 = attr_item:getChildByName("attr2")
		local object = {}
		object.attr_item = attr_item
		object.attr1 = attr1
		object.attr2 = attr2
		self.lev_list[i] = object
	end

	self.Node_1 = self.upstar_layer:getChildByName("Node_1")
	self.Node_1:setVisible(false)
	self.skill_item1 = SkillItem.new(true, true, true, 0.8, true)
	local res = PathTool.getResFrame("ninja_treasure", "ninja_treasure_37")
	local img2 = createImage(self.skill_item1, res, 5,109, cc.p(0.5, 0.5), true,4)
	self.skill_item1.lv_bg = img2
	local lv = createLabel(24, cc.c4b(0xfe, 0xff, 0x80, 0xff), cc.c4b(0x1e, 0x04, 0x00, 0xff), 13, 18, nil,self.skill_item1.lv_bg,1,cc.p(0.5, 0.5))
	self.skill_item1.lv = lv
	self.Node_1:addChild(self.skill_item1)

	self.Node_2 = self.upstar_layer:getChildByName("Node_2")
	self.Node_2:setVisible(false)
	self.skill_item2 = SkillItem.new(true, true, true, 0.8, true)
	local res = PathTool.getResFrame("ninja_treasure", "ninja_treasure_37")
	local img2 = createImage(self.skill_item2, res, 5,109, cc.p(0.5, 0.5), true,4)
	self.skill_item2.lv_bg = img2
	local lv = createLabel(24, cc.c4b(0xfe, 0xff, 0x80, 0xff), cc.c4b(0x1e, 0x04, 0x00, 0xff), 13, 18, nil,self.skill_item2.lv_bg,1,cc.p(0.5, 0.5))
	self.skill_item2.lv = lv
	self.Node_2:addChild(self.skill_item2)
end

function RollerUpstarResultWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			if self.can_touch  == true then
				self:onClickClose()
			end
		end
	end)
end

function RollerUpstarResultWindow:onClickClose()
    controller:openRollerUpstarResultWindow(false)
end

function RollerUpstarResultWindow:openRootWnd(id)
    playOtherSound("c_get") 
	self:handleEffect(true)
	self:starTimeTicket()

	self.id = id
	local roller_data = controller:getModel():getRollerDataById(id)
    if not roller_data then return end
	local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[id]
	self.star = roller_data.star
	local old_star = self.star - 1
	local basecfg = Config.ProhibitedScrollData.data_get_proh_scroll[id]
	local pic_info = basecfg.show[1]
	if pic_info then
		if pic_info[1] == 1 then
			local res = PathTool.getRollerIcon(pic_info[2],2)
			loadSpriteTexture(self.equip_img1, res, LOADTEXT_TYPE)  
			loadSpriteTexture(self.equip_img2, res, LOADTEXT_TYPE) 
		elseif pic_info[1] == 2 then
			local eff_id = pic_info[2]
			if not self.icon_eff_1 then
				self.icon_eff_1 = createEffectSpine( eff_id, cc.p(0, 0), cc.p(0.5, 0.5), true, "action1")
				self.equip_img1:addChild(self.icon_eff_1)
			end
			if not self.icon_eff_2 then
				self.icon_eff_2 = createEffectSpine( eff_id, cc.p(0, 0), cc.p(0.5, 0.5), true, "action1")
				self.equip_img2:addChild(self.icon_eff_2)
			end
		end
	end

	local max_star = model:getMaxStarById(id)
	self:setStarPanel1(old_star,max_star)
	self:setStarPanel2(self.star,max_star)

	local new_cfg = cfg[self.star]
	local new_attr = deepCopy(new_cfg.attr)
	if new_cfg.show and next(new_cfg.show) then
        local show = new_cfg.show[1]
        local action = show[1]
        if self.icon_eff_2 then
            self.icon_eff_2:setAnimation(0, action, true)
        end
    end

	local old_cfg = cfg[old_star]
	local old_attr = deepCopy(old_cfg.attr)
	if old_cfg.show and next(old_cfg.show) then
        local show = old_cfg.show[1]
        local action = show[1]
        if self.icon_eff_1 then
            self.icon_eff_1:setAnimation(0, action, true)
        end
    end

	local num = math.max(#new_attr,#old_attr)
	local total_attr_height = math.max(num * 40,228) 
	self.attr_scroller:setInnerContainerSize(cc.size(640,total_attr_height))
	for i = 1, num, 1 do
		local old_data = old_attr[i]
		local new_data = new_attr[i]
		local res, attr_name, attr_val 
		if old_data then
			res, attr_name, attr_val = commonGetAttrInfoByKeyValue(old_data[1], old_data[2])
		end
		local res2, attr_name2, attr_val2 = commonGetAttrInfoByKeyValue(new_data[1], new_data[2])
		attr_name = attr_name or attr_name2
		attr_val = attr_val or 0
		self.lev_list[i].attr1:setString(attr_name..": "..attr_val)
		self.lev_list[i].attr2:setString(attr_val2)
		self.lev_list[i].attr_item:setVisible(true)
		self.lev_list[i].attr_item:setPositionY(total_attr_height-(i-1)*40)
	end

	local old_skill = old_cfg.passive_skill[1]
	local new_skill = new_cfg.passive_skill[1]
	self.skill_item1:setData(Config.SkillData.data_get_skill(old_skill))
	self.skill_item1.lv:setString(Config.SkillData.data_get_skill(old_skill).level)
	self.Node_1:setVisible(true)
	self.skill_item2:setData(Config.SkillData.data_get_skill(new_skill))
	self.skill_item2.lv:setString(Config.SkillData.data_get_skill(new_skill).level)
	self.Node_2:setVisible(true)
end

function RollerUpstarResultWindow:starTimeTicket()
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

function RollerUpstarResultWindow:clearTimeticket()
	if self.time_ticket then
		GlobalTimeTicket:getInstance():remove(self.time_ticket)
		self.time_ticket = nil
	end
end

function RollerUpstarResultWindow:handleEffect(status)
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
			self.play_effect = createEffectSpine("E51020", cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, action)
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end 

function RollerUpstarResultWindow:setStarPanel1(star,max_star)
	self.star_list1 = createOnlyStar(max_star,self.star_layer1,29)
    for i, v in ipairs(self.star_list1) do
        setChildUnEnabled(true, v)
        if i <= star then
            setChildUnEnabled(false, v)
        end
    end
end
function RollerUpstarResultWindow:setStarPanel2(star,max_star)
	self.star_list2 = createOnlyStar(max_star,self.star_layer2,29)
    for i, v in ipairs(self.star_list2) do
        setChildUnEnabled(true, v)
        if i <= star then
            setChildUnEnabled(false, v)
        end
    end
end

function RollerUpstarResultWindow:close_callback()
	self:handleEffect(false)
	if self.skill_item1 then
		self.skill_item1:DeleteMe()
		self.skill_item1 = nil
	end
	if self.skill_item2 then
		self.skill_item2:DeleteMe()
		self.skill_item2 = nil
	end
	self:clearTimeticket()
    controller:openRollerUpstarResultWindow(false)
end