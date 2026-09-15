RollerInfoUpstarPanel = class("RollerInfoUpstarPanel", function()
    return ccui.Widget:create()
end)

local controller = RollerController:getInstance()
local model = controller:getModel()
local string_format = string.format

function RollerInfoUpstarPanel:ctor() 
	self.star_list = {} 
    self.attr_list = {}
    self:loadResListCompleted()
end
-- 资源加载完成
function RollerInfoUpstarPanel:loadResListCompleted(  )
	self:configUI()
	self:register_event()
	self._init_flag = true
end

function RollerInfoUpstarPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("roller/roller_info_up_star_panel"))
	self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)

    self.background = self.root_wnd:getChildByName("background")
    self.background2 = self.root_wnd:getChildByName("background2")
    self.background:setLocalZOrder(9)
    self.background2:setLocalZOrder(1)
    self.item = self.root_wnd:getChildByName("item")

    local main_container = self.root_wnd:getChildByName("main_container")
    main_container:setLocalZOrder(10)
    self.main_container = main_container

	self.name_bg = main_container:getChildByName("name_bg")
	self.equip_name = main_container:getChildByName("equip_name")
    self.eff_node = main_container:getChildByName("eff_node")
    self.equip_icon = self.eff_node:getChildByName("equip_icon")
	self.quality_icon = main_container:getChildByName("quality_icon")
	self.help_btn = main_container:getChildByName("help_btn")

    self.battle_btn = main_container:getChildByName("battle_btn")
    local battle_lab = self.battle_btn:getChildByName("label")
    battle_lab:setString(TI18N("语言_c_6263"))
    battle_lab:setScale(1)
    setTextMaxWidth(battle_lab, 105, -4)

    self.show_battle_btn = main_container:getChildByName("show_battle_btn")
    local battle_lab = self.show_battle_btn:getChildByName("label")
    battle_lab:setString(TI18N("语言_c_6457"))
    battle_lab:setScale(1)
    setTextMaxWidth(battle_lab, 105, -4)
    self.show_battle_btn:setVisible(false)

    self.reset_btn = main_container:getChildByName("reset_btn")
    local reset_btn_label = self.reset_btn:getChildByName("label")
    reset_btn_label:setString(TI18N("语言_c_7196"))
    reset_btn_label:setScale(1)
    setTextMaxWidth(reset_btn_label, 105, -4)

    self.star_layer = main_container:getChildByName("star_layer")

	self.strength_btn = main_container:getChildByName("strength_btn")
    self.strength_btn:getChildByName("label"):setString(TI18N("语言_c_6754"))
	
	self.up_panel = main_container:getChildByName("up_panel")
    
	self.Image_jiantou1 = self.up_panel:getChildByName("Image_jiantou1")
	self.skill_1 = self.up_panel:getChildByName("Node_1")
    local skill_name1 = self.skill_1:getChildByName("skill_name")
    local star_layer = self.skill_1:getChildByName("star_layer")
    star_layer:setLocalZOrder(99)
    if not self.skill_item1 then
        self.skill_item1 = SkillItem.new(true, true, true, 0.85, true)
        self.skill_item1:addCallBack(function() 
        end)
        local res = PathTool.getResFrame("ninja_treasure", "ninja_treasure_37")
        local img2 = createImage(self.skill_item1, res, 5,109, cc.p(0.5, 0.5), true,4)
        self.skill_item1.lv_bg = img2
        local img3 = createImage(self.skill_item1, PathTool.getResFrame("common", "common_zbjiantou"),116,105, cc.p(0.5, 0.5), true,4)
        self.skill_item1.up_img = img3
        local lv = createLabel(24, cc.c4b(0xfe, 0xff, 0x80, 0xff), cc.c4b(0x1e, 0x04, 0x00, 0xff), 13, 18, nil,self.skill_item1.lv_bg,1,cc.p(0.5, 0.5))
        self.skill_item1.lv = lv
        self.skill_1:addChild(self.skill_item1)
    end
    self.skill_item1.skill_name = skill_name1
    self.skill_item1.star_layer = star_layer

	self.skill_2 = self.up_panel:getChildByName("Node_2")
    local skill_name2 = self.skill_2:getChildByName("skill_name")
    local star_layer2 = self.skill_2:getChildByName("star_layer")
    star_layer2:setLocalZOrder(99)
    if not self.skill_item2 then
        self.skill_item2 = SkillItem.new(true, true, true, 0.85, true)
        self.skill_item2:addCallBack(function() 
        end)
        local res = PathTool.getResFrame("ninja_treasure", "ninja_treasure_37")
        local img2 = createImage(self.skill_item2, res, 5,109, cc.p(0.5, 0.5), true,4)
        self.skill_item2.lv_bg = img2
        local img3 = createImage(self.skill_item2, PathTool.getResFrame("common", "common_zbjiantou"), 116,105, cc.p(0.5, 0.5), true,4)
        self.skill_item2.up_img = img3
        local lv = createLabel(24, cc.c4b(0xfe, 0xff, 0x80, 0xff), cc.c4b(0x1e, 0x04, 0x00, 0xff), 13, 18, nil,self.skill_item2.lv_bg,1,cc.p(0.5, 0.5))
        self.skill_item2.lv = lv
        self.skill_2:addChild(self.skill_item2)
    end
    self.skill_item2.skill_name = skill_name2
    self.skill_item2.star_layer = star_layer2

    self.arrow_img = self.up_panel:getChildByName("Image_jiantou1")

    self.plan_list = self.up_panel:getChildByName("plan_list")
	self.scroll_view = createScrollView(self.plan_list:getContentSize().width,self.plan_list:getContentSize().height,0,0,self.plan_list,ccui.ScrollViewDir.vertical)

    self.cost_node = self.up_panel:getChildByName("Node_5")
    self.cost_node:setVisible(false)
    self.cost_item = BackPackItem.new(false, true, false, 0.7, true, true)
    self.cost_node:addChild(self.cost_item)

	self.cur_num_lab = self.up_panel:getChildByName("cur_num_lab")
	self.cur_num_lab:setString("")
    self.cur_num_lab:setVisible(false)
	self.max_txt = self.up_panel:getChildByName("max_txt")
    self.max_txt:setString(TI18N("语言_s_61"))
    self.max_txt:setVisible(false)
    self.power_bg = self.up_panel:getChildByName("power_bg")
    self.power_txt = self.up_panel:getChildByName("power_txt")
    self.score = CommonNum.new(23, self.up_panel, 1, -2, cc.p(0, 0.5))
    self.score:setScale(0.85)
    self.score:setPosition(257,562)

    self:adaptationScreen()
end

function RollerInfoUpstarPanel:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop()
    local bottom_y = display.getBottom()
    self.background:setPositionY(top_y)
    self.background2:setPositionY(bottom_y)
    self.main_container:setPositionY(bottom_y)
end

function RollerInfoUpstarPanel:register_event(  )
	if self.help_btn then
        self.help_btn:addTouchEventListener(function( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                local cfg = Config.ProhibitedScrollData.data_get_func_show[2]
                MainuiController:getInstance():openCommonExplainView(true, cfg)
            end
        end)
    end

	registerButtonEventListener(self.strength_btn, function (  )
        if self.is_enough then
            controller:sender20804(self.id)
        else
            message(TI18N("语言_s_64"))
            local config = Config.ItemData.data_get_data(self.cost_id)
            BackpackController:getInstance():openTipsSource(true, config)
        end
	end, true)

	registerButtonEventListener(self.battle_btn, function (  )
        controller:openRollerInfoWindow(false)
        controller:openRollerMainWindow(true,2)
	end, true)

	registerButtonEventListener(self.show_battle_btn , function (  )
        controller:sender20830(self.id)
	end, true)

	registerButtonEventListener(self.reset_btn, function (  )
        controller:openUpstarPreviewWindow(true,self.id)
	end, true)

    if not self.upstar_result_event then
        self.upstar_result_event = GlobalEvent:getInstance():Bind(RollerEvent.Roller_Upstar_Result,function()
            self:upDateInfo()
        end)
    end
    -- 道具数量更新
    if not self.update_add_good_event then
        self.update_add_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function(bag_code, data_list)
            self:upUpStarCostInfo()
        end)
    end
    if not self.update_delete_good_event then
        self.update_delete_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function(bag_code, data_list)
            self:upUpStarCostInfo()
        end)
    end
    if not self.update_modify_good_event then
        self.update_modify_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, data_list)
            self:upUpStarCostInfo()
        end)
    end

end

function RollerInfoUpstarPanel:setData( id )
	self.id = id
    local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.id]
    local qulality = base_cfg.quality
    loadSpriteTexture(self.quality_icon, PathTool.getResFrame("prohibited_scroll",RollerConst.QualityIcon[qulality]), LOADTEXT_TYPE_PLIST)
    local pic_info = base_cfg.show[1]
	if pic_info then
		if pic_info[1] == 1 then
			local res = PathTool.getRollerIcon(pic_info[2],2)
			loadSpriteTexture(self.equip_icon, res, LOADTEXT_TYPE)
			self.equip_icon:setVisible(true)
			if self.icon_eff then
				self.icon_eff:setVisible(false)
			end
		elseif pic_info[1] == 2 then
			local eff_id = pic_info[2]
			if not self.icon_eff then
				self.icon_eff = createEffectSpine( eff_id, cc.p(0, 0), cc.p(0.5, 0.5), true, "action")
				self.eff_node:addChild(self.icon_eff)
			end
			self.equip_icon:setVisible(false)
			self.icon_eff:setVisible(true)
		end
	end
    self.equip_name:setString(base_cfg.name)

    local name_width = self.equip_name:getContentSize().width
    if name_width > 130 then
        local total_width = name_width + 52 + 64
        self.name_bg:setContentSize(cc.size(total_width/0.8, 82))
        self.quality_icon:setPositionX(360-total_width/2 + 40)
    end
    self:doEquipIconAction()
    self:addCloudyEff()
    self:upDateInfo()
end

function RollerInfoUpstarPanel:upDateInfo()
    local star = 0
	local now_lv = 0
	local score = 0
	local roller_data = model:getRollerDataById(self.id)
	if roller_data then
		now_lv = roller_data.lev
		star = roller_data.star
		score = roller_data.score
	end
	self.score:setNum(score)
    
    local total_width = self.score:getContentSize().width + self.power_txt:getContentSize().width + 10
    local txt_width = self.power_txt:getContentSize().width
    -- local _posx = self.power_txt:getPositionX()
    local posx = 360 - (total_width/2 - txt_width) - txt_width/2
    self.power_txt:setPositionX(posx)
    self.score:setPositionX(self.power_txt:getPositionX()+txt_width/2+10)

    local max_star = model:getMaxStarById(self.id)
    self:setStarPanel(star,max_star)

    local next_star = star + 1
    local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[self.id]
    local now_star_cfg = star_cfg[star]
    local next_star_cfg = star_cfg[next_star]
    if next_star_cfg then
        self.is_full_star = false
    else
        self.is_full_star = true
    end

    local skill_id = now_star_cfg.passive_skill[1]
    local skill_cfg = Config.SkillData.data_get_skill(skill_id)
    local star_arrow_cfg = Config.ProhibitedScrollData.data_get_constant["star_arrow"].val or {}
    if skill_cfg then
        self.skill_item1:setData(skill_cfg)
        self.skill_item1.lv:setString(skill_cfg.level)
        self.skill_item1.skill_name:setString(skill_cfg.name)

        if table.indexof(star_arrow_cfg,star) then
            self.skill_item1.up_img:setVisible(true)
        else
            self.skill_item1.up_img:setVisible(false)
        end

        self.skill_item1.star_list = createOnlyStar(max_star,self.skill_item1.star_layer,19)
        for i, v in ipairs(self.skill_item1.star_list) do
            setChildUnEnabled(true, v)
            if i <= star then
                setChildUnEnabled(false, v)
            end
        end

    end

    if self.is_full_star then
        self.skill_1:setPositionX(360)
        self.skill_2:setVisible(false)
        self.arrow_img:setVisible(false)
    else
        self.skill_1:setPositionX(198)
        self.skill_2:setVisible(true)
        self.arrow_img:setVisible(true)

        local skill_id = next_star_cfg.passive_skill[1]
        local skill_cfg = Config.SkillData.data_get_skill(skill_id)
        if skill_cfg then
            self.skill_item2:setData(skill_cfg)
            self.skill_item2.lv:setString(skill_cfg.level)
            self.skill_item2.skill_name:setString(skill_cfg.name)

            if table.indexof(star_arrow_cfg,next_star) then
                self.skill_item2.up_img:setVisible(true)
            else
                self.skill_item2.up_img:setVisible(false)
            end

            self.skill_item2.star_list = createOnlyStar(max_star,self.skill_item2.star_layer,19)
            for i, v in ipairs(self.skill_item2.star_list) do
                setChildUnEnabled(true, v)
                if i <= next_star then
                    setChildUnEnabled(false, v)
                end
            end

        end
    end

    --设置属性
    local now_num = #now_star_cfg.attr
    local next_num = 0
    if not self.is_full_star then
        next_num = #next_star_cfg.attr
    end
    local attr_num = math.max(now_num,next_num)
    local scroller_height = math.max(attr_num * 45,225)
	-- self.scroll_view:setContentSize(cc.size(720, scroller_height))
	self.scroll_view:setInnerContainerSize(cc.size(720, scroller_height))
    for i = 1, attr_num do
        if self.attr_list[i] == nil then
			self.attr_list[i] = self:createStrengthAttrItem(self.scroll_view)
		end
        local attr = now_star_cfg.attr[i]
        local res,attr_name
        local now_attr_val = 0
        local next_attr_val = 0
        if attr then
            res, attr_name, now_attr_val = commonGetAttrInfoByKeyValue(attr[1], attr[2])
        end
        if next_star_cfg and next_star_cfg.attr and next_star_cfg.attr[i] then
            local next_attr = next_star_cfg.attr[i]
            res, attr_name, next_attr_val = commonGetAttrInfoByKeyValue(next_attr[1], next_attr[2])
        end
        local str = "<img src=\'%s\' scale=1 />   %s: %s"
        self.attr_list[i].attr1:setString(string.format(str,res,attr_name,now_attr_val))--(attr_name..":"..now_attr_val)
        self.attr_list[i].attr2:setString(string.format(str,res,attr_name,next_attr_val))--(attr_name..":"..next_attr_val)
        if self.is_full_star then
            self.attr_list[i].attr1:setPositionX(77)
            self.attr_list[i].attr2:setString("max")
        else
            self.attr_list[i].attr1:setPositionX(77)
        end
        if i%2 == 0 then
            self.attr_list[i].bg:setVisible(false)
        else
            self.attr_list[i].bg:setVisible(true)
        end
        local _x = 360
		local _y = scroller_height - (i-1)*45
		self.attr_list[i].layer:setPosition(cc.p(_x,_y))
    end

    --设置升星消耗
    if not self.is_full_star then
		local cost_data = now_star_cfg.cost
		if cost_data and next(cost_data) then
			local _data = cost_data[1]
			local cost_id = _data[1]
			local cost_num = _data[2]
            self.cost_id = cost_id
			local item_cfg = Config.ItemData.data_get_data(cost_id)
			local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
			self.cur_num_lab:setString(own_num.."/"..cost_num)
            self.cost_item:setData(item_cfg)
            if own_num >= cost_num then
                self.is_enough = true
                self.cur_num_lab:setTextColor(cc.c4b(0x00, 0xff, 0x00, 0xff))
                addRedPointToNodeByStatus(self.strength_btn, true,10,10)
            else
                self.is_enough = false
                self.cur_num_lab:setTextColor(cc.c4b(0xff,0x15,0x15,0xff))
                addRedPointToNodeByStatus(self.strength_btn, false)
            end
            self.cost_node:setVisible(true)
            self.cur_num_lab:setVisible(true)
            self.strength_btn:setVisible(true)
            self.max_txt:setVisible(false)
		end
    else
        self.cost_node:setVisible(false)
        self.cur_num_lab:setVisible(false)
        self.strength_btn:setVisible(false)
        self.max_txt:setVisible(true)
	end

    if now_star_cfg.show and next(now_star_cfg.show) then
        local show = now_star_cfg.show[1]
        local action = show[1]
        if self.icon_eff then
            self.icon_eff:setAnimation(0, action, true)
        end
    end
end

function RollerInfoUpstarPanel:upUpStarCostInfo()
    local star = 0
	local roller_data = model:getRollerDataById(self.id)
	if roller_data then
		star = roller_data.star
	end

    local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[self.id]
    local now_star_cfg = star_cfg[star]

    local next_star = star + 1
    local next_star_cfg = star_cfg[next_star]
    if next_star_cfg then
        self.is_full_star = false
    else
        self.is_full_star = true
    end

    --设置升星消耗
    if not self.is_full_star then
		local cost_data = now_star_cfg.cost
		if cost_data and next(cost_data) then
			local _data = cost_data[1]
			local cost_id = _data[1]
			local cost_num = _data[2]
            self.cost_id = cost_id
			local item_cfg = Config.ItemData.data_get_data(cost_id)
			local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
			self.cur_num_lab:setString(own_num.."/"..cost_num)
            self.cost_item:setData(item_cfg)
            if own_num >= cost_num then
                self.is_enough = true
                self.cur_num_lab:setTextColor(cc.c4b(0x00, 0xff, 0x00, 0xff))
                addRedPointToNodeByStatus(self.strength_btn, true,10,10) 
            else
                self.is_enough = false
                self.cur_num_lab:setTextColor(cc.c4b(0xff,0x15,0x15,0xff))
                addRedPointToNodeByStatus(self.strength_btn, false) 
            end
            self.cost_node:setVisible(true)
            self.cur_num_lab:setVisible(true)
            self.strength_btn:setVisible(true)
            self.max_txt:setVisible(false)
		end
    else
        self.cost_node:setVisible(false)
        self.cur_num_lab:setVisible(false)
        self.strength_btn:setVisible(false)
        self.max_txt:setVisible(true)
	end
end

function RollerInfoUpstarPanel:createStrengthAttrItem(parent)
    local item = {}
	local layer = ccui.Layout:create()
    layer:setAnchorPoint(cc.p(0.5, 1))
    layer:setContentSize(cc.size(720,45))
    parent:addChild(layer)

	local skill_item = self.item:clone()
    layer:addChild(skill_item)
    skill_item:setPositionX(360)
    skill_item:setPositionY(22.5)

    local bg = skill_item:getChildByName("bg")
    local attr1 = skill_item:getChildByName("attr1")
	local posx = attr1:getPositionX()
	local posy = attr1:getPositionY()
	local _attr = createRichLabel(22, 1, cc.p(0,0.5), cc.p(posx, posy))
	skill_item:addChild(_attr)
    local arrow_img = skill_item:getChildByName("fuck_img")
    local attr2 = skill_item:getChildByName("attr2")
	local posx = attr2:getPositionX()
	local posy = attr2:getPositionY()
	local _attr2 = createRichLabel(22, 1, cc.p(0,0.5), cc.p(posx, posy))
	skill_item:addChild(_attr2)

    item.layer = layer
    item.bg = bg
    item.attr1 = _attr
    item.arrow_img = arrow_img
    item.attr2 = _attr2
    return item
end

function RollerInfoUpstarPanel:setVisibleStatus(bool)
    self:setVisible(bool)
    if bool then
        commonOpenActionLeftMove(self.main_container)
    else
    end
end

function RollerInfoUpstarPanel:setStarPanel(star,max_star)
    if not next(self.star_list) then
        self.star_list = createOnlyStar(max_star,self.star_layer,29)
    end
    for i, v in ipairs(self.star_list) do
        setChildUnEnabled(true, v)
        if i <= star then
            setChildUnEnabled(false, v)
        end
    end
end

function RollerInfoUpstarPanel:addCloudyEff()
    self.cloudy_eff = createEffectSpine("E24915", cc.p(360, 1135), cc.p(0.5, 0.5), true, "action2")
    self.root_wnd:addChild(self.cloudy_eff,1)
end
function RollerInfoUpstarPanel:doEquipIconAction()
    doStopAllActions(self.eff_node)
    local action = cc.Sequence:create(cc.MoveTo:create(1.5, cc.p(360, 940)),cc.MoveTo:create(1.5, cc.p(360, 930)),cc.MoveTo:create(1.5, cc.p(360, 920)),cc.MoveTo:create(1.5, cc.p(360, 930)))
    self.eff_node:runAction(cc.RepeatForever:create(action))
end

function RollerInfoUpstarPanel:DeleteMe()
    doStopAllActions(self.eff_node)
	if self.upstar_result_event then
		GlobalEvent:getInstance():UnBind(self.upstar_result_event)
		self.upstar_result_event = nil
	end
	if self.update_add_good_event then
		GlobalEvent:getInstance():UnBind(self.update_add_good_event)
		self.update_add_good_event = nil
	end
	if self.update_delete_good_event then
		GlobalEvent:getInstance():UnBind(self.update_delete_good_event)
		self.update_delete_good_event = nil
	end
	if self.update_modify_good_event then
		GlobalEvent:getInstance():UnBind(self.update_modify_good_event)
		self.update_modify_good_event = nil
	end
    if self.scroll_view then
        self.scroll_view:removeAllChildren()
        self.scroll_view:removeFromParent()
        self.scroll_view = nil
    end
    if self.cost_item then
        self.cost_item:DeleteMe()
        self.cost_item = nil
    end
    if self.skill_item1 then
        self.skill_item1:DeleteMe()
        self.skill_item1 = nil
    end
    if self.skill_item2 then
        self.skill_item2:DeleteMe()
        self.skill_item2 = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end