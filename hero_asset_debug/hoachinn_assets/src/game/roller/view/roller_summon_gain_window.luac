-- --------------------------------------------------------------------
-- 
-- 
-- (必填, 创建模块的人员)
-- (必填, 后续维护以及修改的人员)
-- @description:
-- 召唤获得界面
-- --------------------------------------------------------------------
RollerSummonGainWindow = RollerSummonGainWindow or BaseClass(BaseView)

local controller = RollerController:getInstance() 
local model = controller:getModel()

function RollerSummonGainWindow:__init(is_call)
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.item_list = {} --物品列表
    self.win_type = WinType.Full
    self.is_action_ing = false
    self.is_call = is_call or TRUE --是否先召唤结算

    self.is_show_title = false
    self.music_info = AudioManager:getInstance():getMusicInfo()
    self.elfin_summon_type = 1 --1:限时精灵召唤  2：常驻精灵召唤
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("partnersummon", "partnersummon"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_12"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg", "txt_cn_bigbg_18"), type = ResourcesType.single },
    }
end

function RollerSummonGainWindow:createRootWnd()
    self.size = cc.size(SCREEN_WIDTH, SCREEN_HEIGHT)
    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2))
    self.root_wnd:setContentSize(self.size)
    showLayoutRect(self.root_wnd,255)

    -- 预加载音效
    AudioManager:getInstance():preLoadEffect(AudioManager.AUDIO_TYPE.COMMON, 'c_get')

    self.source_container = ccui.Layout:create()
    self.source_container:setTouchEnabled(true)
    self.source_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.source_container:setOpacity(255)
    self.source_container:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.source_container:setCascadeOpacityEnabled(true)
    self.source_container:setScale(display.getMaxScale())
    self.source_container:setPosition(cc.p(self.size.width/2, SCREEN_HEIGHT / 2))
    self.root_wnd:addChild(self.source_container)

    self.image_bg = createSprite(nil, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, self.source_container, cc.p(0.5, 0.5), LOADTEXT_TYPE)
    self.image_bg:setVisible(false)
    self.image_bg:setScale(display.getMaxScale())
    
    self.draw_container = ccui.Layout:create()
    self.draw_container:setTouchEnabled(false)
    self.draw_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.draw_container:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.draw_container:setPosition(cc.p(self.size.width/2, SCREEN_HEIGHT / 2))
    self.source_container:addChild(self.draw_container)

    self.image_top_bg = createScale9Sprite(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_12"), SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 55, LOADTEXT_TYPE, self.source_container)
    self.image_top_bg:setAnchorPoint(cc.p(0.5, 0))
    self.image_top_bg:setVisible(false)
    self.image_top_bg:setContentSize(cc.size(SCREEN_WIDTH + 100,220))

    local top_bg_line_1 = createSprite(PathTool.getResFrame("partnersummon", "partnersummon_line"), self.image_top_bg:getContentSize().width/2, self.image_top_bg:getContentSize().height -5, image_top_bg, cc.p(0, 0.5), LOADTEXT_PLIST)
    local top_bg_line_2 = createSprite(PathTool.getResFrame("partnersummon", "partnersummon_line"), self.image_top_bg:getContentSize().width/2,self.image_top_bg:getContentSize().height - 5, image_top_bg, cc.p(0, 0.5), LOADTEXT_PLIST)
    top_bg_line_1:setScaleX(-1)
    self.image_bottom_bg = createScale9Sprite(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_12"),SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 55, LOADTEXT_TYPE, self.source_container)
    self.image_bottom_bg:setContentSize(cc.size(SCREEN_WIDTH + 100, 220))
    self.image_bottom_bg:setScaleY(-1)
    self.image_bottom_bg:setVisible(false)
    self.image_bottom_bg:setAnchorPoint(cc.p(0.5, 0))

    self.title_bg = createSprite(PathTool.getPlistImgForDownLoad("bigbg", "txt_cn_bigbg_18"), SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 525, self.source_container, cc.p(0.5, 0.5), LOADTEXT_TYPE)
    self.title_bg:setVisible(false)
    self.title_bg:setScale(1.5)
  
    self.item_container = ccui.Layout:create()
    self.item_container:setAnchorPoint(cc.p(0.5, 0.5))
    self.item_container:setOpacity(255)
    self.item_container:setContentSize(cc.size(SCREEN_WIDTH, 440))
    self.item_container:setCascadeOpacityEnabled(true)
    self.item_container:setPosition(cc.p(self.size.width / 2, SCREEN_HEIGHT / 2))
    self.item_container:setVisible(false)
    self.root_wnd:addChild(self.item_container)

    if self.is_call == TRUE then
        self.again_btn = createButton(self.item_container,TI18N("语言_c_1914"),165,-55,cc.size(220,77),PathTool.getResFrame("partnersummon","partnersummon_btn_2"))
        self.again_btn:setRichText(TI18N("语言_c_1915"))
        self.item_label = createRichLabel(32, 1, cc.p(0.5, 0.5), cc.p(110,100),0,0,500)
        self.item_label:setString("")
        self.again_btn:addChild(self.item_label)
        self.comfirm_btn = createButton(self.item_container,TI18N("语言_c_63"),560,-55,cc.size(220,77),PathTool.getResFrame("partnersummon","partnersummon_btn"))
        self.comfirm_btn:setRichText(TI18N("语言_c_1916"))
    end
    self:resgiter_event()
end

function RollerSummonGainWindow:openRootWnd(data,is_call)
    self.tiems = data.times
    self.group_id = data.group_id or 0
    self.reward_list = data.rewards
    self.config_data = Config.HolidayProhibitedScrollData.data_summon

    local config = self.config_data[data.group_id]
    if config then
        self.one_icon_item = config.loss_item_once[1][1]
        self.five_icon_item = config.loss_item_ten[1][1]
        self.again_btn:setVisible(true)
        self.comfirm_btn:setPosition(cc.p(560, -55))
        self.one_gold_num =  config.loss_gold_once[1][2]
        self.ten_gold_num =  config.loss_gold_ten[1][2]
        local vip_status = controller:getModel():getRollerPrivilegeStatus()
        if vip_status then --开启特权之后有折扣
            local discount = Config.ProhibitedScrollData.data_get_constant.privilege_reduce_reduce.val
            self.one_gold_num = math.ceil(self.one_gold_num*discount/100)
            self.ten_gold_num = math.ceil(self.ten_gold_num*discount/100)
        end
    else
        self.again_btn:setVisible(false)
        self.comfirm_btn:setPosition(cc.p(self.item_container:getContentSize().width/2, -55))
    end
    self.bg_res_id = PathTool.getPlistImgForDownLoad("bigbg/partnersummon", "partnersummon_call_bg_300", true)
    self.resources_bg_load = loadSpriteTextureFromCDN(self.image_bg, self.bg_res_id, ResourcesType.single, self.resources_bg_load)
    self:callAction(data)
end

function RollerSummonGainWindow:callAction(data)
    self.is_action_ing = true
    self:updateEffectAction()
end

function RollerSummonGainWindow:updateEffectAction()
    local action = PlayerAction.action
    if self.config_data[self.group_id] then
        action = self.config_data[self.group_id].action_name
    end
    self:clickSkilAction()
end
-- 4星立绘的底盘特效
function RollerSummonGainWindow:showDrawEffect1( status )
    if status == true then
        if not tolua.isnull(self.source_container) and self.draw_effect_1 == nil then
            self.draw_effect_1 = createEffectSpine("E00002", cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.draw_container:addChild(self.draw_effect_1)
            self.draw_effect_1:setVisible(true)
            local function eventFunc(event)
                self:showDrawEffect2(true)
            end
            self.draw_effect_1:registerSpineEventHandler(eventFunc, sp.EventType.ANIMATION_COMPLETE)
        end
    else
        if self.draw_effect_1 then
            self.draw_effect_1:clearTracks()
            self.draw_effect_1:removeFromParent()
            self.draw_effect_1 = nil
        end
    end
end
-- 5新特效第二阶段
function RollerSummonGainWindow:showDrawEffect2( status )
    if self.draw_effect_1 then
        self.draw_effect_1:setVisible(false)
    end
    if self.draw_effect_3 then
        self.draw_effect_3:setVisible(false)
    end
    if status == true then
        if not tolua.isnull(self.source_container) and self.draw_effect_2 == nil then
            self.draw_effect_2 = createEffectSpine("E00002", cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), cc.p(0.5, 0.5), true, PlayerAction.action_2)
            self.draw_container:addChild(self.draw_effect_2)
        end
    else
        if self.draw_effect_2 then
            self.draw_effect_2:clearTracks()
            self.draw_effect_2:removeFromParent()
            self.draw_effect_2 = nil
        end
    end
end
-- 五星底盘背景特效
function RollerSummonGainWindow:showDrawEffect3(status)
    if status == true then
        if not tolua.isnull(self.source_container) and self.draw_effect_3 == nil then
            self.draw_effect_3 = createEffectSpine("E00002", cc.p(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.draw_container:addChild(self.draw_effect_3)
            self.draw_effect_3:setVisible(true)
            local function eventFunc(event)
                self:showDrawEffect2(true)
            end
            self.draw_effect_3:registerSpineEventHandler(eventFunc, sp.EventType.ANIMATION_COMPLETE)
        end
    else
        if self.draw_effect_3 then
            self.draw_effect_3:clearTracks()
            self.draw_effect_3:removeFromParent()
            self.draw_effect_3 = nil
        end
    end
end

function RollerSummonGainWindow:clickSkilAction(is_click)
    if self.is_action_ing ==  false then
        return 
    end

    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, item in ipairs(self.item_list) do
            if item and item:getRootWnd() then
                item:getRootWnd():setScale(1)
                item:getRootWnd():stopAllActions()
            end
        end
    end
    if self.title_effect and self.is_show_title == false then
        if self.title_effect then
            self.title_effect:runAction(cc.RemoveSelf:create(true))
            self.title_effect = nil
        end
    end
    if not self.title_effect then
        self.is_show_title = true
        self.title_bg:runAction(cc.Sequence:create(cc.CallFunc:create(function()
            self.title_bg:setVisible(true)
        end), cc.DelayTime:create(0.1), cc.ScaleTo:create(0.1, 1)))
    end
    if self.reward_list and self.is_call == TRUE then
        self:updateItemData(self.reward_list)
    elseif self.is_call == FALSE then
        
    end
end
--更新物品列表
function RollerSummonGainWindow:updateItemData(data)
    self.is_action_ing = false
    self.item_container:setVisible(true)
    self.image_top_bg:setVisible(true)
    self.image_bottom_bg:setVisible(true)
    self.image_bg:setVisible(true)
    self.title_bg:setVisible(true)
    local sum = #data
    local col = 5
    -- 算出最多多少行
    self.row = math.ceil(sum / col)
    self.space = 20
    local max_height = self.space + (self.space + 20 + BackPackItem.Height) * self.row
    self.max_height = math.max(max_height, self.item_container:getContentSize().height)
    self.title_bg:setPosition(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 320)
    if sum >= col then
        sum = col
    end
    local total_width = sum * BackPackItem.Width + (sum - 1) * self.space
    self.start_x = (self.item_container:getContentSize().width - total_width) * 0.5
    -- 只有一行的话
    if self.row == 1 then
        self.start_y = self.max_height * 0.5 + 65
    else
        self.start_y = self.max_height - self.space - BackPackItem.Height * 0.5
    end
    local is_show_effect = false
    for i, v in ipairs(data) do
        local item = BackPackItem.new(false,true)
        item:setAnchorPoint(cc.p(0.5,0.5))
        item:setBaseData(v.base_id,v.num)
        item:setScale(1.2)
        item:setOpacity(0)
        item:setDefaultTip()
        item.config = Config.ItemData.data_get_data(v.base_id)  
        self.item_container:addChild(item)
        local _x = self.start_x + BackPackItem.Width * 0.5 + ((i - 1) % col) * (BackPackItem.Width + self.space)
        local _y = self.start_y - math.floor((i - 1) / col) * (BackPackItem.Height + self.space + 20)
        item:setPosition(cc.p(_x, _y))
        self.item_list[i] = item
    end

    self:showDrawEffect1(true)
    self:showDrawEffect3(false)
    self.bg_res_id = PathTool.getPlistImgForDownLoad("bigbg/partnersummon", "partnersummon_call_bg_300", true)
    self.resources_bg_load = loadSpriteTextureFromCDN(self.image_bg, self.bg_res_id, ResourcesType.single, self.resources_bg_load)
    
    AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON, 'c_get', false)
    delayOnce(function ()
        if self.item_list then
            for i, item in ipairs(self.item_list) do
                if item and item then
                    local fadeIn = cc.FadeIn:create(0.1)
                    local scaleTo = cc.ScaleTo:create(0.1, 1)
                    item:runAction(cc.Sequence:create(cc.DelayTime:create(0.1 * i ),cc.Spawn:create(fadeIn, scaleTo,cc.CallFunc:create(function ()
                        item:playItemSound()  
                        item:showItemEffect(true,156,PlayerAction.action_3,false)
                    end),cc.CallFunc:create(function ()
                        if item.config and BackPackConst.checkIsElfin(item.config.type) and item.config.quality >=BackPackConst.quality.purple then
                            item:showItemEffect(false)
                            local effect_id = 1750
                            local action = PlayerAction.action_1
                            if item.config.quality >= BackPackConst.quality.orange then
                                action = PlayerAction.action_2
                            end
                            item:showItemEffect(true, effect_id, action, true)
                        end
                    end))))
                end
            end
        end
    end,0.2)
 
    if self.is_call == TRUE then
        if self.tiems == 10 and self.item_label and self.five_icon_item then
            self.again_btn:setRichText(TI18N("语言_c_1917"))
            self:updateTenSummon()
        else
            self.again_btn:setRichText(TI18N("语言_c_1918"))
            self:updateSingleSummon()
        end
    else 
    end

end

function RollerSummonGainWindow:updateTenSummon(  )
    local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.five_icon_item)
    local item_icon = Config.ItemData.data_get_data(self.five_icon_item).icon
    if summon_have_num >= self.tiems then
        self._item_enough = true
        self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#35ff14 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
    else
        self._item_enough = false
        self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#e14737 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
        
        --道具不足显示金币
        local have_sum = RoleController:getInstance():getRoleVo().gold + RoleController:getInstance():getRoleVo().red_gold
        local gold_cfg = Config.ItemData.data_get_data(3)
        if self.tiems == 1 then
            local str = "<img src=%s visible=true scale=0.5 /><div fontColor=#35ff14 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"
            if have_sum >= self.one_gold_num then
            else
                str = "<img src=%s visible=true scale=0.5 /><div fontColor=#e14737 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"
            end
            str = string.format(str, PathTool.getItemRes(gold_cfg.icon), have_sum, self.one_gold_num)
            self.item_label:setString(str)
        elseif self.tiems == 10 then
            local str = "<img src=%s visible=true scale=0.5 /><div fontColor=#35ff14 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"
            if have_sum >= self.ten_gold_num then
            else
                str = "<img src=%s visible=true scale=0.5 /><div fontColor=#e14737 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"
            end
            str = string.format(str, PathTool.getItemRes(gold_cfg.icon), have_sum, self.ten_gold_num)
            self.item_label:setString(str)
        end
        
    end
end

function RollerSummonGainWindow:updateSingleSummon()
    if not self.one_icon_item then return end
    local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.one_icon_item)
    local item_cfg = Config.ItemData.data_get_data(self.one_icon_item)
    if not item_cfg then return end
    local item_icon = item_cfg.icon
    if summon_have_num >= self.tiems then
        self._item_enough = true
        self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#35ff14 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
    else
        self._item_enough = false
        self.item_label:setString(string.format(TI18N("<img src=%s visible=true scale=0.5 /><div fontColor=#e14737 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"), PathTool.getItemRes(item_icon), summon_have_num, self.tiems))
        
        --道具不足显示金币
        local have_sum = RoleController:getInstance():getRoleVo().gold + RoleController:getInstance():getRoleVo().red_gold
        local gold_cfg = Config.ItemData.data_get_data(3)
        if self.tiems == 1 then
            local str = "<img src=%s visible=true scale=0.5 /><div fontColor=#35ff14 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"
            if have_sum >= self.one_gold_num then
            else
                str = "<img src=%s visible=true scale=0.5 /><div fontColor=#e14737 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"
            end
            str = string.format(str, PathTool.getItemRes(gold_cfg.icon), have_sum, self.one_gold_num)
            self.item_label:setString(str)
        elseif self.tiems == 10 then
            local str = "<img src=%s visible=true scale=0.5 /><div fontColor=#35ff14 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"
            if have_sum >= self.ten_gold_num then
            else
                str = "<img src=%s visible=true scale=0.5 /><div fontColor=#e14737 outline=2,#000000>%d</div><div fontColor=#ffffff outline=2,#000000>/%d</div>"
            end
            str = string.format(str, PathTool.getItemRes(gold_cfg.icon), have_sum, self.ten_gold_num)
            self.item_label:setString(str)
        end

    end
end


function RollerSummonGainWindow:showAlert(num, item_icon_2, val_str, val_num, call_num,call_back)
    if self.alert then
        self.alert:close()
        self.alert = nil
    end

    local cancle_callback = function()
        if self.alert then
            self.alert:close()
            self.alert = nil
        end
    end

    local vip_status = controller:getModel():getRollerPrivilegeStatus()
	if vip_status then --开启特权之后有折扣
		local discount = Config.ProhibitedScrollData.data_get_constant.privilege_reduce_reduce.val
		num = math.ceil(num*discount/100)
	end

    local have_sum = RoleController:getInstance():getRoleVo().gold + RoleController:getInstance():getRoleVo().red_gold
    local str = string.format(TI18N("语言_c_1919"), PathTool.getItemRes(item_icon_2), num, have_sum)
    local str_ = str .. string.format(TI18N("语言_c_1920"), val_num, val_str, call_num)
    self.alert = CommonAlert.show(str_, TI18N("语言_c_63"), call_back, TI18N("语言_c_62"), nil, CommonAlert.type.rich,nil)
end

function RollerSummonGainWindow:resgiter_event()
    if not tolua.isnull(self.source_container) then
        self.source_container:setTouchEnabled(true)
        self.source_container:addTouchEventListener(function(sender, event_type)    
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if not self.is_action_ing then
                else
                    self:clickSkilAction()
                end
            end
        end)
    end
    if self.again_btn then
        self.again_btn:addTouchEventListener(function(sender, event_type)
            customClickAction_2(sender,event_type)
            if event_type == ccui.TouchEventType.ended then
                if self._item_enough then
                    controller:sender20832( self.tiems, 4 ,true)
                    return
                end
                local config = self.config_data[self.group_id]
                if self.tiems == 1 then
                    local num = config.loss_gold_once[1][2]
                    local call_back = function ()
                        controller:sender20832( 1, 3 ,true)
                    end
                    local item_icon_2 = Config.ItemData.data_get_data(config.loss_gold_once[1][1]).icon
                    local val_str = Config.ItemData.data_get_data(config.gain_once[1][1]).name or ""
                    local val_num = config.gain_once[1][2]
                    local call_num = 1
                    self:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
                else
                    local num = config.loss_gold_ten[1][2]
                    local call_back = function ()
                        controller:sender20832( 10, 3 ,true )
                    end
                    local item_icon_2 = Config.ItemData.data_get_data(config.loss_gold_ten[1][1]).icon
                    local val_str = Config.ItemData.data_get_data(config.gain_ten[1][1]).name or ""
                    local val_num = config.gain_ten[1][2]
                    local call_num = 10
                    self:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
                end
            end
        end)
    end
    if self.comfirm_btn then
        self.comfirm_btn:addTouchEventListener(function(sender, event_type)
            customClickAction_2(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                controller:openRollerSummonGainWindow(false)
            end
        end)
    end
end

function RollerSummonGainWindow:close_callback()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, item in ipairs(self.item_list) do
            if item then
                item:DeleteMe()
            end
        end
        self.item_list = {}
    end
   
    self:showDrawEffect1(false)
    self:showDrawEffect2(false)
    self:showDrawEffect3(false)
    -- self:showDrawEffect4(false)

    if self.resources_bg_load then
        self.resources_bg_load:DeleteMe()
    end
    self.resources_bg_load = nil

    controller:openRollerSummonGainWindow(false)
end
