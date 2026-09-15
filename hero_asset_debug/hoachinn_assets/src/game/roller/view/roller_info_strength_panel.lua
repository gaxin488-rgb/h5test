-- **************************
-- 禁器抽奖
-- **************************
RollerInfoStrengthPanel = class("RollerInfoStrengthPanel", function()
    return ccui.Widget:create()
end)

function RollerInfoStrengthPanel:ctor()
    self.controller = RollerController:getInstance()
    self.model = self.controller:getModel()
    self.strength_attr_list = {} -- 强化属性
    self.star_list = {}
    self.select_skill_id = nil
    self:loadResListCompleted()
end
-- 资源加载完成
function RollerInfoStrengthPanel:loadResListCompleted()
    self:configUI()
    self:register_event()
    self._init_flag = true
end

function RollerInfoStrengthPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("roller/roller_info_strength_panel"))
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
    self.quality_icon = main_container:getChildByName("quality_icon")
    self.eff_node = main_container:getChildByName("eff_node")
    self.equip_icon = self.eff_node:getChildByName("equip_icon")
    self.help_btn = main_container:getChildByName("help_btn")
    self.help_btn:setTouchEnabled(true)
    self.reset_btn = main_container:getChildByName("reset_btn")
    local reset_btn_label = self.reset_btn:getChildByName("label")
    reset_btn_label:setString(TI18N("语言_maze_02_2"))

    self.star_layer = main_container:getChildByName("star_layer")

    self.up_panel = main_container:getChildByName("up_panel")
    self.plan_list = self.up_panel:getChildByName("plan_list")
    self.strength_attr_scroll_view = createScrollView(self.plan_list:getContentSize().width,self.plan_list:getContentSize().height, 0, 0, self.plan_list, ccui.ScrollViewDir.vertical)
    self.cost_bg = self.up_panel:getChildByName("cost_bg")
    self.cost_num = self.up_panel:getChildByName("cost_num")
    self.cost_icon = self.up_panel:getChildByName("cost_icon")
    self.max_txt = self.up_panel:getChildByName("max_txt")
    self.max_txt:setString(TI18N("语言_c_4810"))
    self.power_bg = self.up_panel:getChildByName("power_bg")
    self.power_txt = self.up_panel:getChildByName("power_txt")
    self.score = CommonNum.new(23, self.up_panel, 1, -2, cc.p(0, 0.5))
    self.score:setCallBack(function ()
        local total_width = self.score:getContentSize().width + self.power_txt:getContentSize().width + 10
        local txt_width = self.power_txt:getContentSize().width
        -- local _posx = self.power_txt:getPositionX()
        local posx = 360 - (total_width/2 - txt_width) - txt_width/2
        self.power_txt:setPositionX(posx)
        self.score:setPositionX(posx + txt_width/2+10)
    end)
    self.score:setScale(0.85)
    self.score:setPosition(257, 434)
    self.now_lv = self.up_panel:getChildByName("now_lv")
    self.next_lv = self.up_panel:getChildByName("next_lv")
    
    self.strength_btn = main_container:getChildByName("strength_btn")
    self.strength_btn:getChildByName("label"):setString(TI18N("语言_c_6903"))

    self:adaptationScreen()
end

function RollerInfoStrengthPanel:adaptationScreen()
    -- 对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop()
    local bottom_y = display.getBottom()
    self.background:setPositionY(top_y)
    self.background2:setPositionY(bottom_y)
    self.main_container:setPositionY(bottom_y)
end

function RollerInfoStrengthPanel:register_event()
    if self.help_btn then
        self.help_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                local cfg = Config.ProhibitedScrollData.data_get_func_show[1]
                MainuiController:getInstance():openCommonExplainView(true, cfg)
            end
        end)
    end
    --强化
    self.strength_btn:addTouchEventListener(function(sender, event_type)
        customClickAction_2(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            self.is_click_btn = false --标志只点一次btn
            local sequence_action = cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function() 
                self:startTimeTicket()
            end))
            self.sequence_action = self.strength_btn:runAction(sequence_action)
            self.sequence_action:setTag(1)
        elseif event_type == ccui.TouchEventType.moved then
        elseif event_type == ccui.TouchEventType.canceled then
            self:clearTimeTicket()
        elseif event_type == ccui.TouchEventType.ended then
            self:clearTimeTicket()
            if not self.is_click_btn then
                playButtonSound2()
                self:onClickLevelUpBtn()
            end
        end
    end)
    -- 重置
    registerButtonEventListener(self.reset_btn, function()
        if self.is_can_reset then
            self.controller:openRollerResetWindow(true,{type=1,roller_id=self.id})
        else
            message(TI18N("语言_c_7195"))
        end
    end, true)

    -- 数据更新
    if not self.update_event then
        self.update_event = GlobalEvent:getInstance():Bind(RollerEvent.Roller_Strength_Effect, function(data)
            for k, v in pairs(self.strength_attr_list) do
                local item = v
                if not item.up_eff then
					if not item.up_eff then
						local up_eff = createEffectSpine("E29011", cc.p(360, 22.5), cc.p(0.5, 0.5), false, "action")
						up_eff:registerSpineEventHandler(function(event)
							up_eff:setVisible(false)
							self:updateAttrInfo()
						end, sp.EventType.ANIMATION_COMPLETE)
						item.layer:addChild(up_eff)
						item.up_eff = up_eff
					end
				else
                    item.up_eff:setAnimation(0, PlayerAction.action, false)
                    item.up_eff:setVisible(true)
                end
            end
        end)
    end
    --单个数据刷新
    if not self.update_single_event then
        self.update_single_event = GlobalEvent:getInstance():Bind(RollerEvent.Update_Roller_Event, function(data)
            if self:isVisible() then
                self:updateAttrInfo()
            end
        end)
    end
    -- 道具数量更新
    if not self.update_add_good_event then
        self.update_add_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,
            function(bag_code, data_list)
                if data_list == nil or next(data_list) == nil then return end
                for k,v in pairs(data_list) do
                    if v.config then
                        if v.config.id == self.strength_item_id then
                            self:updateCostInfo()
                        end
                    end
                end
            end)
    end
    if not self.update_delete_good_event then
        self.update_delete_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,
            function(bag_code, data_list)
                if data_list == nil or next(data_list) == nil then return end
                for k,v in pairs(data_list) do
                    if v.config then
                        if v.config.id == self.strength_item_id then
                            self:updateCostInfo()
                        end
                    end
                end
            end)
    end
    if not self.update_modify_good_event then
        self.update_modify_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,
            function(bag_code, data_list)
                if data_list == nil or next(data_list) == nil then return end
                for k,v in pairs(data_list) do
                    if v.config then
                        if v.config.id == self.strength_item_id then
                            self:updateCostInfo()
                        end
                    end
                end
            end)
    end
end

--点击事件
function RollerInfoStrengthPanel:clearTimeTicket()
    if self.sequence_action then
        self.strength_btn:stopActionByTag(1)
        self.sequence_action = nil
    end
    self.is_send_level = false
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end 
function RollerInfoStrengthPanel:startTimeTicket()
    if self.time_ticket == nil then
        self.time_idnex = 0
        local _callback = function()
            if self.onClickLevelUpBtn then
                self.is_click_btn = true
                self:onClickLevelUpBtn()
            end
        end
        self.time_ticket = GlobalTimeTicket:getInstance():add(_callback, 20 / display.DEFAULT_FPS)
    end
end
function RollerInfoStrengthPanel:onClickLevelUpBtn()
    if self.is_full_level then
        message(TI18N("语言_c_4810"))
        return
    end
    if self.is_enough then
        self.controller:sender20803(self.id)
    else
        message(TI18N("语言_c_1539"))
        local config = Config.ItemData.data_get_data(self.strength_item_id)
        BackpackController:getInstance():openTipsSource(true, config)
    end
end

function RollerInfoStrengthPanel:setData(id)
    if not id then
        return
    end
    self.id = id
    local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.id]
    local qulality = base_cfg.quality
    loadSpriteTexture(self.quality_icon, PathTool.getResFrame("prohibited_scroll",RollerConst.QualityIcon[qulality]), LOADTEXT_TYPE_PLIST)
    local pic_info = base_cfg.show[1]
    if pic_info then
        if pic_info[1] == 1 then
            local res = PathTool.getRollerIcon(pic_info[2], 2)
            loadSpriteTexture(self.equip_icon, res, LOADTEXT_TYPE)
            self.equip_icon:setVisible(true)
            if self.icon_eff then
                self.icon_eff:setVisible(false)
            end
        elseif pic_info[1] == 2 then
            local eff_id = pic_info[2]
            if not self.icon_eff then
                self.icon_eff = createEffectSpine(eff_id, cc.p(0, 0), cc.p(0.5, 0.5), true, "action")
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
	self:updateAttrInfo()
end

function RollerInfoStrengthPanel:updateAttrInfo()
	local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.id]
    local qulality = base_cfg.quality
    -- 属性
    local star = 0
    local now_lv = 0
    local score = 0
    local roller_data = self.model:getRollerDataById(self.id)
    if roller_data then
        now_lv = roller_data.lev
        star = roller_data.star
        score = roller_data.score
    end
    if now_lv == 0 then
        self.is_can_reset = false
    else
        self.is_can_reset = true
    end

    self.score:setNum(score)
    local max_star = self.model:getMaxStarById(self.id)
    self:setStarPanel(star,max_star)

    local next_lv = now_lv + 1
    local strength_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_enhance[qulality]
    local attr_cfg = strength_cfg[now_lv]
    local next_attr_cfg = strength_cfg[next_lv]
    local attr_num = 0
    local now_num = #attr_cfg.attr
    local next_num = 0
    if next_attr_cfg then
        next_num = #next_attr_cfg.attr
        self.is_full_level = false
    else
        self.is_full_level = true
    end
    attr_num = math.max(next_num, now_num)
    self.now_lv:setString(string.format(TI18N("语言_c_4712"),now_lv))--("Lv."..now_lv)
    self.next_lv:setString(string.format(TI18N("语言_c_4712"),next_lv))---("Lv."..next_lv)

    local scroller_height = math.max(attr_num * 60, 130)
    self.strength_attr_scroll_view:setContentSize(cc.size(720, scroller_height))
    self.strength_attr_scroll_view:setInnerContainerSize(cc.size(720, scroller_height))

    for i = 1, attr_num do
        if self.strength_attr_list[i] == nil then
            self.strength_attr_list[i] = self:createStrengthAttrItem(self.strength_attr_scroll_view)
        end
        local res, attr_name
        local now_attr_val = 0
        local next_attr_val = 0

        local now_attr = attr_cfg.attr[i]
        if now_attr then
            res, attr_name, now_attr_val = commonGetAttrInfoByKeyValue(now_attr[1], now_attr[2])
        end
        if next_attr_cfg and next_attr_cfg.attr and next_attr_cfg.attr[i] then
            local next_attr = next_attr_cfg.attr[i]
            res, attr_name, next_attr_val = commonGetAttrInfoByKeyValue(next_attr[1], next_attr[2])
        end
        local str = "<img src=\'%s\' scale=1 />   %s: %s"
        self.strength_attr_list[i].attr1:setString(string.format(str, res, attr_name, now_attr_val)) -- (attr_name..":"..now_attr_val)
        self.strength_attr_list[i].attr2:setString(string.format(str, res, attr_name, next_attr_val)) -- (attr_name..":"..next_attr_val)

        if not self.is_full_level then -- 未满级
            -- self.strength_attr_list[i].attr2:setVisible(true)
        else
            self.strength_attr_list[i].attr2:setString(TI18N("语言_c_4543"))
        end
        local _x = 360
        local _y = scroller_height - (i - 1) * 60
        self.strength_attr_list[i].layer:setPosition(cc.p(_x, _y))
    end

    if not self.is_full_level then
        local cost_data = attr_cfg.cost
        if cost_data and next(cost_data) then
            local _data = cost_data[1]
            local cost_id = _data[1]
            local cost_num = _data[2]
            self.strength_item_id = cost_id
            local item_cfg = Config.ItemData.data_get_data(cost_id)
            local icon = item_cfg.icon
            loadSpriteTexture(self.cost_icon, PathTool.getItemRes(icon), LOADTEXT_TYPE)
            local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
            self.cost_num:setString(own_num .. "/" .. cost_num)
            if own_num < cost_num then
                self.is_enough = false
                self.cost_num:setTextColor(cc.c4b(0xff,0x15,0x15,0xff))
                addRedPointToNodeByStatus(self.strength_btn, false) 
            else
                self.is_enough = true
                self.cost_num:setTextColor(cc.c4b(0x00, 0xff, 0x00, 0xff))
                addRedPointToNodeByStatus(self.strength_btn, true,10,10) 
            end
        end
        self.cost_bg:setVisible(true)
        self.cost_num:setVisible(true)
        self.cost_icon:setVisible(true)
        self.strength_btn:setVisible(true)
        self.max_txt:setVisible(false)
        self.next_lv:setVisible(true)
    else
        self.next_lv:setString("Max")
        self.cost_bg:setVisible(false)
        self.cost_num:setVisible(false)
        self.cost_icon:setVisible(false)
        self.strength_btn:setVisible(false)
        self.max_txt:setVisible(true)
    end

    local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[self.id][star]
    if star_cfg.show and next(star_cfg.show) then
        local show = star_cfg.show[1]
        local action = show[1]
        if self.icon_eff then
            self.icon_eff:setAnimation(0, action, true)
        end
    end
end
function RollerInfoStrengthPanel:updateCostInfo()
    local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.id]
    local qulality = base_cfg.quality
    local now_lv = 0
    local roller_data = self.model:getRollerDataById(self.id)
    if roller_data then
        now_lv = roller_data.lev
    end
    local strength_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_enhance[qulality]
    local attr_cfg = strength_cfg[now_lv]
    if not self.is_full_level then
        local cost_data = attr_cfg.cost
        if cost_data and next(cost_data) then
            local _data = cost_data[1]
            local cost_id = _data[1]
            local cost_num = _data[2]
            self.strength_item_id = cost_id
            local item_cfg = Config.ItemData.data_get_data(cost_id)
            local icon = item_cfg.icon
            loadSpriteTexture(self.cost_icon, PathTool.getItemRes(icon), LOADTEXT_TYPE)
            local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
            self.cost_num:setString(own_num .. "/" .. cost_num)
            if own_num < cost_num then
                self.is_enough = false
                self.cost_num:setTextColor(cc.c4b(0xff,0x15,0x15,0xff))
                addRedPointToNodeByStatus(self.strength_btn, false) 
            else
                self.is_enough = true
                self.cost_num:setTextColor(cc.c4b(0x00, 0xff, 0x00, 0xff))
                addRedPointToNodeByStatus(self.strength_btn, true,10,10) 
            end
        end
    end
end

function RollerInfoStrengthPanel:createStrengthAttrItem(parent)
    local item = {}
    local layer = ccui.Layout:create()
    layer:setAnchorPoint(cc.p(0.5, 1))
    layer:setContentSize(cc.size(720, 45))
    parent:addChild(layer)

    local skill_item = self.item:clone()
    layer:addChild(skill_item)
    skill_item:setPositionX(360)
    skill_item:setPositionY(22.5)

    local bg = skill_item:getChildByName("bg")
    local attr1 = skill_item:getChildByName("attr1")
    local posx = attr1:getPositionX()
    local posy = attr1:getPositionY()
    local _attr = createRichLabel(22, 1, cc.p(0, 0.5), cc.p(posx, posy))
    skill_item:addChild(_attr)
    local arrow_img = skill_item:getChildByName("fuck_img")
    local attr2 = skill_item:getChildByName("attr2")
    local posx = attr2:getPositionX()
    local posy = attr2:getPositionY()
    local _attr2 = createRichLabel(22, 1, cc.p(0, 0.5), cc.p(posx, posy))
    skill_item:addChild(_attr2)

    item.layer = layer
    item.bg = bg
    item.attr1 = _attr
    item.arrow_img = arrow_img
    item.attr2 = _attr2
    return item
end
function RollerInfoStrengthPanel:addCloudyEff()
    self.cloudy_eff = createEffectSpine("E24915", cc.p(360, 1135), cc.p(0.5, 0.5), true, "action2")
    self.root_wnd:addChild(self.cloudy_eff,2)
end
function RollerInfoStrengthPanel:doEquipIconAction()
    doStopAllActions(self.eff_node)
    local action = cc.Sequence:create(cc.MoveTo:create(1.5, cc.p(360, 893)),cc.MoveTo:create(1.5, cc.p(360, 903)),cc.MoveTo:create(1.5, cc.p(360, 913)),cc.MoveTo:create(1.5, cc.p(360, 903)))
    self.eff_node:runAction(cc.RepeatForever:create(action))
end

function RollerInfoStrengthPanel:setVisibleStatus(bool)
    self:setVisible(bool)
    if bool then
        commonOpenActionLeftMove(self.main_container)
        self:updateAttrInfo()
    else
        self:clearTimeTicket()
    end
end

function RollerInfoStrengthPanel:setStarPanel(star,max_star)
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

function RollerInfoStrengthPanel:DeleteMe()
    doStopAllActions(self.eff_node)
    if self.update_event then
        GlobalEvent:getInstance():UnBind(self.update_event)
        self.update_event = nil
    end
    if self.update_single_event then
        GlobalEvent:getInstance():UnBind(self.update_single_event)
        self.update_single_event = nil
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
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    self:removeAllChildren()
    self:removeFromParent()
end
