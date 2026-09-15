
RollerInfoFengyinPanel = class("RollerInfoFengyinPanel", function()
    return ccui.Widget:create()
end)

local controller = RollerController:getInstance()
local model = controller:getModel()

function RollerInfoFengyinPanel:ctor() 
	self.star_list = {} 
    self.attr_list = {}
    self:loadResListCompleted()
end
-- 资源加载完成
function RollerInfoFengyinPanel:loadResListCompleted(  )
	self:configUI()
	self:register_event()
	self.select_camp_id = 0
end

function RollerInfoFengyinPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("roller/roller_info_fengyin_panel"))
	self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)

    self.background = self.root_wnd:getChildByName("background")
    self.background2 = self.root_wnd:getChildByName("background2")
    self.background:setLocalZOrder(9)
    self.background2:setLocalZOrder(1)

    local main_container = self.root_wnd:getChildByName("main_container")
    main_container:setLocalZOrder(10)
    self.main_container = main_container
	self.name_bg = main_container:getChildByName("name_bg")
	self.equip_name = main_container:getChildByName("equip_name")
	self.quality_icon = main_container:getChildByName("quality_icon")
    self.eff_node = main_container:getChildByName("eff_node")
    self.equip_icon = self.eff_node:getChildByName("equip_icon")
	self.help_btn = main_container:getChildByName("help_btn")

    self.star_layer = main_container:getChildByName("star_layer")

    self.power_bg = main_container:getChildByName("power_bg")
    self.power_txt = main_container:getChildByName("power_txt")
    self.score = CommonNum.new(23, main_container, 1, -2, cc.p(0, 0.5))
    self.score:setScale(0.85)
    self.score:setPosition(257, 750)

    local ro = {
        [1] = {45,166,145},
        [2] = {25,105,198},
        [3] = {0,6,224},
        [4] = {-25,-86, 207},
        [5] = {-45,-148,167}
    }

	for i = 1, 5, 1 do
        local object = {}
        local node = main_container:getChildByName("Node_" .. i)
        local attr_name = node:getChildByName("attr_name")
        local attr_icon = node:getChildByName("attr_icon")
        local lv_bg = node:getChildByName("lv_bg")
        local cur_lv = node:getChildByName("cur_lv")
        local pro_txt = node:getChildByName("pro_txt")
        local add_lv_bg = node:getChildByName("add_lv_bg")
        add_lv_bg:setVisible(false)
        local add_lv_num = add_lv_bg:getChildByName("add_lv_num")

        local effect_1 = createEffectSpine("E29012", cc.p(ro[i][2], ro[i][3]), cc.p(0.5, 0), false, PlayerAction.action_2)
        effect_1:setVisible(false)
        effect_1:setRotation(ro[i][1])
        node:addChild(effect_1)
        local effect_2 = createEffectSpine("E29012", cc.p(0, 0), cc.p(0.5, 0.5), false, PlayerAction.action_3)
        effect_2:setVisible(false)
        node:addChild(effect_2)

        object.node = node
        object.attr_name = attr_name
        object.attr_icon = attr_icon
        object.lv_bg = lv_bg
        object.cur_lv = cur_lv
        object.pro_txt = pro_txt
        object.add_lv_bg = add_lv_bg
        object.add_lv_num = add_lv_num
        object.effect_1 = effect_1
        object.effect_2 = effect_2
        object.is_playing = false
        self.attr_list[i] = object

        self.attr_list[i].effect_1:registerSpineEventHandler(function(event)
            if self.attr_list[i].is_playing then
                self.attr_list[i].effect_1:setVisible(false)
                if self.attr_list[i].effect_2 then
                    self.attr_list[i].effect_2:setAnimation(0, PlayerAction.action_3, false)
                    self.attr_list[i].effect_2:setVisible(true)
                end 
            end
        end, sp.EventType.ANIMATION_COMPLETE)

        self.attr_list[i].effect_2:registerSpineEventHandler(function(event)
            if self.attr_list[i].is_playing then
                self.attr_list[i].effect_2:setVisible(false)
                self.attr_list[i].is_playing = false
                self:updateSingleItem(i)
            end
        end, sp.EventType.ANIMATION_COMPLETE)

    end

	self.attr_all_btn = main_container:getChildByName("attr_all_btn")
    self.attr_all_btn:getChildByName("label"):setString(TI18N("语言_c_7197"))
	self.progress = main_container:getChildByName("progress")
    self.progress:setScale9Enabled(true)
	self.tips_1 = main_container:getChildByName("tips_1")
    self.tips_1:setString(TI18N("语言_c_7198"))
    self.progress_txt = main_container:getChildByName("progress_txt")
	self.fengyin_btn = main_container:getChildByName("fengyin_btn")
    self.fengyin_btn:getChildByName("label"):setString(TI18N("语言_c_7199"))

    self.rank_num = CommonNum.new(30, self.fengyin_btn, 0, 5, cc.p(0.5, 0.5))
    -- self.rank_num:setScale(0.6)
    self.rank_num:setPosition(46,59)
    self.rank_num:setCallBack(function ()
        local rank_width = self.rank_num:getContentSize().width
        if rank_width > 60 then
            local rank_sale = 60/rank_width
            self.rank_num:setScale(rank_sale)
        else
            self.rank_num:setScale(0.6)
        end
    end)

    self.max_txt = main_container:getChildByName("max_txt")
    self.max_txt:setString(TI18N("语言_c_2176"))
    self.max_txt:setVisible(false)

    self.cond_txt = main_container:getChildByName("cond_txt")
    self.cond_txt:setString("")
    self.strength_btn = main_container:getChildByName("strength_btn")
    self.strength_btn:getChildByName("label"):setString(TI18N("语言_c_7200"))
    self.cost_node = main_container:getChildByName("cost_node")
    self.cost_item = BackPackItem.new(false, true, false, 0.7, true, true)
    self.cost_node:addChild(self.cost_item)
    self.cost_num = main_container:getChildByName("cost_num")
    self.upeff_node = main_container:getChildByName("upeff_node")
    self.tips_icon = self.upeff_node:getChildByName("tips_icon")
    self.tips_icon:setVisible(false)
    self.tips_icon:setLocalZOrder(999)
    self.icon_add =  self.tips_icon:getChildByName("icon_add")
    self.effect = createEffectSpine("E29012", cc.p(0, 50), cc.p(0.5, 0), false, PlayerAction.action_1)
    self.effect:setScale(1.3)
    self.effect:setVisible(false)
    self.upeff_node:addChild(self.effect)
    self.effect:registerSpineEventHandler(function(event)
        if event.eventData.name == "001" then
            if self.is_can_play_start_eff then
                self:startPlayEffect()
            end
        end
    end, sp.EventType.ANIMATION_EVENT)

    self:doEquipIconAction()
    self:addCloudyEff()
    
    self:adaptationScreen()
end

function RollerInfoFengyinPanel:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop()
    local bottom_y = display.getBottom()
    self.background:setPositionY(top_y)
    self.background2:setPositionY(bottom_y)
    self.main_container:setPositionY(bottom_y)
end

function RollerInfoFengyinPanel:register_event(  )
	if self.help_btn then
        self.help_btn:addTouchEventListener(function( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
                local cfg = Config.ProhibitedScrollData.data_get_func_show[3]
                MainuiController:getInstance():openCommonExplainView(true, cfg)
            end
        end)
    end
    --强化
    self.strength_btn:addTouchEventListener(function(sender, event_type)
        customClickAction_2(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            self:clearTimeTicket()
            self.is_long_click = false --标志只点一次btn
            local sequence_action = cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function() 
                self:startTimeTicket()
            end))
            self.sequence_action = self.strength_btn:runAction(sequence_action)
            self.sequence_action:setTag(2)
        elseif event_type == ccui.TouchEventType.moved then
        elseif event_type == ccui.TouchEventType.canceled then
            self:clearTimeTicket()
        elseif event_type == ccui.TouchEventType.ended then
            self:clearTimeTicket()
            if not self.is_long_click then
                playButtonSound2()
                self:onClickLevelUpBtn_1()
            end
        end
    end)

    registerButtonEventListener(self.attr_all_btn, function (  )
        controller:openRollerAllAttrOverviewWindow(true,self.id)
	end, true)
    
    registerButtonEventListener(self.fengyin_btn, function ()
        controller:openRollerTalentToattrOverviewWindow(true,self.id)
	end, true)

    if not self.stop_timer_event then
        self.stop_timer_event = GlobalEvent:getInstance():Bind(RollerEvent.StopFenYinTimerEvent,function()
            self:clearTimeTicket()
        end)
    end
    if not self.update_eff_event then
        self.update_eff_event = GlobalEvent:getInstance():Bind(RollerEvent.Update_Roller_Fengyin_Eff,function(data)
            self:showAddEffect(data)
        end)
    end
    if not self.update_roller_event then
        self.update_roller_event = GlobalEvent:getInstance():Bind(RollerEvent.Update_Roller_Event,function(data)
            -- print("444444444444444444")
            if self and self.setData then
                self:setData(self.id)
            end
        end)
    end
    --道具数量更新
    if not self.update_add_good_event then
        self.update_add_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function(bag_code, data_list)
            if self.updateCostInfo then
                self:updateCostInfo()
            end
        end)
    end
    if not self.update_delete_good_event then
        self.update_delete_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function(bag_code, data_list)          
            if self.updateCostInfo then
                self:updateCostInfo()
            end
        end)
    end
    if not self.update_modify_good_event then
        self.update_modify_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, data_list)
            if self.updateCostInfo then
                self:updateCostInfo()
            end
        end)
    end
end

--点击事件
function RollerInfoFengyinPanel:clearTimeTicket()
    if self.sequence_action then
        self.strength_btn:stopActionByTag(2)
        self.sequence_action = nil
    end
    -- self.is_send_level = false
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end 
function RollerInfoFengyinPanel:startTimeTicket()
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
    if self.time_ticket == nil then
        local _callback = function()
            if self.onClickLevelUpBtn_2 then
                self.is_long_click = true
                self:onClickLevelUpBtn_2()
            end
        end
        self.time_ticket = GlobalTimeTicket:getInstance():add(_callback, 20 / display.DEFAULT_FPS)
    end
end
--单击
function RollerInfoFengyinPanel:onClickLevelUpBtn_1()
    if self.is_enough then
        if not self.is_can_play_start_eff then
            controller:sender20805(self.id)
        else
            message(TI18N("语言_c_6444"))
        end
    else
        message(TI18N("语言_c_1539"))
        local config = Config.ItemData.data_get_data(self.cost_id)
        BackpackController:getInstance():openTipsSource(true, config)
    end
end
--长按
function RollerInfoFengyinPanel:onClickLevelUpBtn_2()
    if self.is_enough then
        controller:sender20805(self.id)
    else
        self:clearTimeTicket()
        message(TI18N("语言_c_1539"))
        local config = Config.ItemData.data_get_data(self.cost_id)
        BackpackController:getInstance():openTipsSource(true, config)
    end
end


function RollerInfoFengyinPanel:showAddEffect(data)
    if self.is_long_click then
        self:setData(self.id)
        return
    end
    self.add_data = data

    local total_lv = 0
    for k, v in pairs(self.add_data.seals) do
        local add_levl = v.add_levl
        total_lv = add_levl + total_lv
    end

    doStopAllActions(self.tips_icon)
    self.tips_icon:setVisible(false)
    -- self.tips_icon:setOpacity(0)
    self.tips_icon:setPositionY(-69)
    self.tips_icon:setScale(1)

    local res ,res_1
    if self.atk_num then
        self.atk_num:DeleteMe()
        self.atk_num = nil
    end
    if self.add_data.double_type == 3 then
        res = "txt_cn_battle_baoji"
        res_1 = "type7_add"
        self.atk_num = CommonNum.new(7, self.tips_icon, 44, 60, cc.p(0, 0.5))
        self.atk_num:setPositionY(67)
    elseif self.add_data.double_type == 2 then
        res = "txt_cn_battle_baoji_1"
        res_1 = "type24_add"
        self.atk_num = CommonNum.new(24, self.tips_icon, 44, 60, cc.p(0, 0.5))
        self.atk_num:setPositionY(64)
    elseif self.add_data.double_type == 1 then
        res = "txt_cn_battle_baoji_2"
        res_1 = "type2_add"
        self.atk_num = CommonNum.new(2, self.tips_icon, 44, 60, cc.p(0, 0.5))
        self.atk_num:setPositionY(64)
    end
    loadSpriteTexture(self.tips_icon, PathTool.getResFrame("battle_num",res), LOADTEXT_TYPE_PLIST)
    loadSpriteTexture(self.icon_add, PathTool.getResFrame("battle_num",res_1), LOADTEXT_TYPE_PLIST)
    self.icon_add:setPositionX(self.tips_icon:getContentSize().width+14)
    self.atk_num:setPositionX(self.tips_icon:getContentSize().width+35)
    self.atk_num:setNum(total_lv)
    
    self.is_can_play_start_eff = true
    self.effect:setAnimation(0, PlayerAction.action_1, false)
    self.effect:setVisible(true)
    self.tips_icon:setVisible(true)
    self.tips_icon:setOpacity(255)
    self.tips_icon:setScale(1)
    local hide = cc.FadeOut:create(0.6)
    local move = cc.MoveBy:create(0.6, cc.p(0, 60))
    local bigger = cc.ScaleTo:create(2 / display.DEFAULT_FPS, 2.8)
    local bigger2 = cc.ScaleTo:create(5.6 / display.DEFAULT_FPS, 2)
    local smaller = cc.ScaleTo:create(5.6 / display.DEFAULT_FPS, 1.2)
    local bigger3 = cc.ScaleTo:create(5.6 / display.DEFAULT_FPS, 0.8)
    local delay2 = cc.DelayTime:create(2 / display.DEFAULT_FPS)
    local change = cc.Sequence:create(bigger, bigger2, smaller, bigger3, delay2, cc.Spawn:create(move,hide))
    self.tips_icon:runAction(cc.Sequence:create(change, cc.CallFunc:create(function()
        self.tips_icon:setVisible(false)
        self.tips_icon:setPositionY(-69)
        self.tips_icon:setScale(1)
    end)))

end
function RollerInfoFengyinPanel:startPlayEffect()
    for k, v in pairs(self.add_data.seals) do
        local pos = v.pos
        self.attr_list[pos].is_playing = true
        self.attr_list[pos].effect_1:setAnimation(0, PlayerAction.action_2, false)
        self.attr_list[pos].effect_1:setVisible(true)
    end
end
function RollerInfoFengyinPanel:updateSingleItem(index)
    local fengyin_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal
    local _cfg = fengyin_cfg[index]
    local attr_node = self.attr_list[index]
    local fengyin_lv = model:getRollerFengyinLvById(self.id,index)
    if fengyin_lv == 0 then
        local _info = _cfg[1]
        local attr = _info.attrs[1]
        local res, attr_name, now_attr_val = commonGetAttrInfoByKeyValue(attr[1], attr[2])
        attr_node.attr_name:setString(attr_name)
        attr_node.cur_lv:setString(fengyin_lv)
        attr_node.pro_txt:setString(0)
    else
        local _info = _cfg[fengyin_lv]
        local attr = _info.attrs[1]
        local res, attr_name, now_attr_val = commonGetAttrInfoByKeyValue(attr[1], attr[2])
        attr_node.attr_name:setString(attr_name)
        attr_node.cur_lv:setString(fengyin_lv)
        attr_node.pro_txt:setString(now_attr_val)
    end
    local add_num = 0
    doStopAllActions(self.attr_list[index].add_lv_bg)
    self.attr_list[index].add_lv_bg:setVisible(true)
    for i, v in ipairs(self.add_data.seals) do
        local pos = v.pos
        if index == pos then
            add_num =  v.add_levl
        end
    end
    self.attr_list[index].add_lv_num:setString("+"..add_num)
    performWithDelay(self.main_container,function()
        if self.attr_list and self.attr_list[index] then
            self.attr_list[index].add_lv_bg:setVisible(false)
        end
    end,0.8)

    local total_lv = 0
    for k, v in pairs(self.attr_list) do
        if v.is_playing == false then
            total_lv = total_lv + 1
        end 
    end
    -- print("%%%%%%%%%%%%%%%%",index,total_lv)
    if total_lv == 5 then
        self.is_can_play_start_eff = false
        self:setData(self.id)
    end
end


function RollerInfoFengyinPanel:setData( id )
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
    self:updateAttrInfo()
    self:updateCostInfo()
end
function RollerInfoFengyinPanel:updateAttrInfo()
    local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.id]
    local qulality = base_cfg.quality
    local roller_data = model:getRollerDataById(self.id)
    local star = 1
    if roller_data then
        star = roller_data.star
    end
    local max_star = model:getMaxStarById(self.id)
	self:setStarPanel(star,max_star)

    local seal = 0
    if roller_data then
        seal = roller_data.seal
    end
    self.rank_num:setNum(seal)

    local score = 0
    if roller_data then
        score = roller_data.score
    end
    self.score:setNum(score)
    local total_width = self.score:getContentSize().width + self.power_txt:getContentSize().width + 10
    local txt_width = self.power_txt:getContentSize().width
    local posx = 360 - (total_width/2 - txt_width) - txt_width/2
    self.power_txt:setPositionX(posx)
    self.score:setPositionX(self.power_txt:getPositionX()+txt_width/2+10)

    local fengyin_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal
    for i = 1, 5, 1 do
        local attr_node = self.attr_list[i]
        loadSpriteTexture(attr_node.attr_icon, PathTool.getResFrame("prohibited_scroll","prohibited_scroll_attr_"..i), LOADTEXT_TYPE_PLIST)
        local _cfg = fengyin_cfg[i]
        local fengyin_lv = model:getRollerFengyinLvById(self.id,i)
        if fengyin_lv == 0 then
            local _info = _cfg[1]
            local attr = _info.attrs[1]
            local res, attr_name, now_attr_val = commonGetAttrInfoByKeyValue(attr[1], attr[2])
            attr_node.attr_name:setString(attr_name)
            attr_node.cur_lv:setString(fengyin_lv)
            attr_node.pro_txt:setString(0)
        else
            local _info = _cfg[fengyin_lv]
            local attr = _info.attrs[1]
            local res, attr_name, now_attr_val = commonGetAttrInfoByKeyValue(attr[1], attr[2])
            attr_node.attr_name:setString(attr_name)
            attr_node.cur_lv:setString(fengyin_lv)
            attr_node.pro_txt:setString(now_attr_val)
        end
    end

    local now_otgether_lv = model:getAllFengyinLvById(self.id)
    local _arr = {}
    self.rank_num:setNum(now_otgether_lv)

    local fenyin_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal_resonate[qulality]
    for k, v in pairs(fenyin_cfg) do
        if v.level > now_otgether_lv then
            table.insert(_arr,v.level)
        end
    end
    if next(_arr) then
        local min_num = math.min(unpack(_arr))
        self.progress_txt:setString(now_otgether_lv.."/"..min_num)
        self.progress:setPercent(now_otgether_lv/min_num * 100)
    else
        self.progress_txt:setString(TI18N("语言_c_4543"))
        self.progress:setPercent(100)
    end

    -- local max_lv = model:getMaxFengyinLv(self.id)

    -- if max_lv <= seal then
    --     self.cost_node:setVisible(false)
    --     self.cost_num:setVisible(false)
    --     self.strength_btn:setVisible(false)
    --     self.max_txt:setVisible(true)
    -- else
    --     --消耗
    --     local const_cfg = Config.ProhibitedScrollData.data_get_constant.sealing_consumption
    --     local cost_info = const_cfg.val[1]
    --     local cost_id = cost_info[1]
    --     self.cost_id = cost_id
    --     local cost_num = cost_info[2]
    --     local item_cfg = Config.ItemData.data_get_data(cost_id)
    --     local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
    --     self.cost_num:setString(own_num.."/"..cost_num)
    --     self.cost_item:setData(item_cfg)
    --     if own_num >= cost_num then
    --         self.is_enough = true
    --         self.cost_num:setTextColor(cc.c4b(0x00, 0xff, 0x00, 0xff))
    --     else
    --         self.is_enough = false
    --         self.cost_num:setTextColor(cc.c4b(0xff, 0x15, 0x15, 0xff))
    --     end
    --     self.cost_node:setVisible(true)
    --     self.cost_num:setVisible(true)
    --     self.strength_btn:setVisible(true)
    --     self.max_txt:setVisible(false)

    --     local need_star = model:getFengyinMaxLvByStar(qulality,seal)
    --     if star < need_star then
    --         self.cond_txt:setString(string.format(TI18N("语言_c_7201"), need_star))
    --         setChildUnEnabled(true, self.strength_btn)
    --         self.strength_btn:setTouchEnabled(false)
    --         addRedPointToNodeByStatus(self.strength_btn, false)
    --         self:clearTimeTicket()
    --     else
    --         self.cond_txt:setString("")
    --         setChildUnEnabled(false, self.strength_btn)
    --         self.strength_btn:setTouchEnabled(true)
    --         if self.is_enough then
    --             addRedPointToNodeByStatus(self.strength_btn, true,10,10)
    --         else
    --             addRedPointToNodeByStatus(self.strength_btn, false)
    --         end
    --     end
    -- end

    local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[self.id][star]
    if star_cfg.show and next(star_cfg.show) then
        local show = star_cfg.show[1]
        local action = show[1]
        if self.icon_eff then
            self.icon_eff:setAnimation(0, action, true)
        end
    end
end

function RollerInfoFengyinPanel:updateCostInfo()
	local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.id]
    local qulality = base_cfg.quality
    local roller_data = model:getRollerDataById(self.id)
    if not roller_data then
        return
    end
    local star = roller_data.star
    local seal = roller_data.seal

    local max_lv = model:getMaxFengyinLv(self.id)
    if max_lv <= seal then
        self.cost_node:setVisible(false)
        self.cost_num:setVisible(false)
        self.strength_btn:setVisible(false)
        self.max_txt:setVisible(true)
    else
        --消耗
        local const_cfg = Config.ProhibitedScrollData.data_get_constant.sealing_consumption
        local cost_info = const_cfg.val[1]
        local cost_id = cost_info[1]
        self.cost_id = cost_id
        local cost_num = cost_info[2]
        local item_cfg = Config.ItemData.data_get_data(cost_id)
        local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
        self.cost_num:setString(own_num.."/"..cost_num)
        self.cost_item:setData(item_cfg)
        if own_num >= cost_num then
            self.is_enough = true
            self.cost_num:setTextColor(cc.c4b(0x00, 0xff, 0x00, 0xff))
        else
            self.is_enough = false
            self.cost_num:setTextColor(cc.c4b(0xff, 0x15, 0x15, 0xff))
        end
        self.cost_node:setVisible(true)
        self.cost_num:setVisible(true)
        self.strength_btn:setVisible(true)
        self.max_txt:setVisible(false)

        local need_star = model:getFengyinMaxLvByStar(qulality,seal)
        if star < need_star then
            self.cond_txt:setString(string.format(TI18N("语言_c_7201"), need_star))
            setChildUnEnabled(true, self.strength_btn)
            self.strength_btn:setTouchEnabled(false)
            addRedPointToNodeByStatus(self.strength_btn, false)
        else
            self.cond_txt:setString("")
            setChildUnEnabled(false, self.strength_btn)
            self.strength_btn:setTouchEnabled(true)
            if self.is_enough then
                addRedPointToNodeByStatus(self.strength_btn, true,10,10)
            else
                addRedPointToNodeByStatus(self.strength_btn, false)
            end
        end
    end
end


function RollerInfoFengyinPanel:setVisibleStatus(bool)
    self:setVisible(bool)
    if bool then
        commonOpenActionLeftMove(self.main_container)
    else
        self:clearTimeTicket()
    end
end
function RollerInfoFengyinPanel:setStarPanel(star,max_star)
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
function RollerInfoFengyinPanel:addCloudyEff()
    if not self.cloudy_eff  then
        self.cloudy_eff = createEffectSpine("E24915", cc.p(360, 1135), cc.p(0.5, 0.5), true, "action")
        self.root_wnd:addChild(self.cloudy_eff,2)
    end
end
function RollerInfoFengyinPanel:doEquipIconAction()
    doStopAllActions(self.eff_node)
    local action = cc.Sequence:create(cc.MoveTo:create(1.5, cc.p(360, 940)),cc.MoveTo:create(1.5, cc.p(360, 930)),cc.MoveTo:create(1.5, cc.p(360, 920)),cc.MoveTo:create(1.5, cc.p(360, 930)))
    self.eff_node:runAction(cc.RepeatForever:create(action))
end

function RollerInfoFengyinPanel:DeleteMe()
    self:clearTimeTicket()
    doStopAllActions(self.eff_node)
	if self.update_eff_event then
		GlobalEvent:getInstance():UnBind(self.update_eff_event)
		self.update_eff_event = nil
	end
	if self.update_roller_event then
		GlobalEvent:getInstance():UnBind(self.update_roller_event)
		self.update_roller_event = nil
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
	if self.stop_timer_event then
		GlobalEvent:getInstance():UnBind(self.stop_timer_event)
		self.stop_timer_event = nil
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