-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
GemstoneStrengthenItem = class("GemstoneStrengthenItem", function() 
	return ccui.Layout:create()
end)

--==============================--
--desc:创建物品对象
--time:2018-06-05 04:41:34
--@click:是否可点击
--@scale:缩放值
--@effect:点击时候是否要处理回弹效果
--@is_show_tips:是否显示tips
--@tips_data:tips参数 is_book是否是图鉴 is_btn是否显示底部按钮 
--@return 
--==============================--
function GemstoneStrengthenItem:ctor(click, scale, effect, is_show_tips, swallow_touch)

	self.root_wnd = createCSBNote(PathTool.getTargetCSB("gemstone/gemstone_strengthen_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	-- self:setTouchEnabled(self.click)
	-- self:setCascadeOpacityEnabled(true)
	-- if self.scale ~= 1 then
	-- 	self:setScale(self.scale)
	-- end
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width/2, self.size.height/2)
	self:addChild(self.root_wnd)

	self.main_container = self.root_wnd:getChildByName("main_container")
	self.item_node = self.main_container:getChildByName("item_node")
    self.select_btn = self.main_container:getChildByName("select_btn")
    self.select_btn:setSwallowTouches(false)
	self.add_btn = self.main_container:getChildByName("add_btn")
    self.add_btn:setVisible(false)
	local desc = self.main_container:getChildByName("desc")
    desc:setVisible(false)
    local posx = desc:getPositionX()
    local posy = desc:getPositionY()
    self.desc = createRichLabel(20, cc.c4b(0x64, 0x32, 0x23, 0xff), cc.p(0.5, 0.5), cc.p(posx, posy))
    self.main_container:addChild(self.desc)
	self.select_num_bg = self.main_container:getChildByName("select_num_bg")
	self.select_num = self.select_num_bg:getChildByName("select_num")
	self.select_num_bg:setVisible(false)
	self.dele_btn = self.main_container:getChildByName("dele_btn")
	self.dele_btn:setVisible(false)
	self:registerEvent()
end

function GemstoneStrengthenItem:getData()
	return self.data
end
function GemstoneStrengthenItem:getSendData()
    return self.send_data
end
function GemstoneStrengthenItem:addCallBack(callback)
	self.callback = callback
end

function GemstoneStrengthenItem:setData(data)
	self.data = data
	local item_id = self.data.id
	local exp = self.data.exp

    self.num = 0
    self.select_num:setString(self.num)
    local str = 'EXP+<div fontcolor=#26952f>%s</div>'
    self.desc:setString(string.format(str, exp))
    local own_num =  BackpackController:getInstance():getModel():getItemNumByBid(item_id)
    if not self.item then
        self.item = BackPackItem.new(false, false, false, 0.9)
        self.item_node:addChild(self.item)
        local function func()
            GemstoneController:getInstance():openGemstoneStrengSelectItemPanel(true,self.data.id,self.equip_data)
        end
        if self.item then
            self.item:addLongTimeTouchCallback(func)
        end
    end
    self.item:setBaseData(item_id, own_num)
    -- self.item:resetNumPos()
    if own_num == 0 then
        setChildUnEnabled(true, self.item)
        self.add_btn:setVisible(true)
    else
        setChildUnEnabled(false, self.item)
        self.add_btn:setVisible(false)
    end
    if self.num <= 0 then
        self.select_num_bg:setVisible(false)
        self.dele_btn:setVisible(false)
    else
        self.select_num_bg:setVisible(true)
        self.dele_btn:setVisible(true)
    end
end

function GemstoneStrengthenItem:setExtend(extend_data,equip)
    if not extend_data then return end
    self.extend_data = extend_data
	if equip then
		self.equip_data = equip
	end
    local item_id = self.data.id
    local item_info = self.extend_data[item_id]
    if not item_info then 
        self.num = 0
        self.select_num_bg:setVisible(false)
        self.dele_btn:setVisible(false)
        return
    end
    if item_id == item_info.item_id then
        self.num = item_info.num
        self.select_num:setString(self.num)
        self.select_num:setScale(1)
        local width = self.select_num:getContentSize().width
        local height = self.select_num:getContentSize().height
        self.select_num_bg:setContentSize(cc.size(width+10, self.select_num_bg:getContentSize().height))
        self.select_num:setPositionX(width/2+5)
    end
    if self.num <= 0 then
        self.select_num_bg:setVisible(false)
        self.dele_btn:setVisible(false)
    else
        self.select_num_bg:setVisible(true)
        self.dele_btn:setVisible(true)
    end
end

function GemstoneStrengthenItem:registerEvent()
    self.add_btn:addTouchEventListener(function(sender, event_type)
        customClickAction_2(sender, event_type,1)
        local type = Config.ItemData.data_get_data(self.data.id).type
        if BackPackConst.checkIsEquip(type) then
           HeroController:getInstance():openEquipTips(true, self.data)
        else
            local config = Config.ItemData.data_get_data(self.data.id)
            BackpackController:getInstance():openTipsSource(true, config) 
        end
    end)
    self.select_btn:addTouchEventListener(function(sender, event_type)
        customClickAction_2(sender, event_type,1)
        if event_type == ccui.TouchEventType.began then
            self.is_click_btn = false --标志只点一次btn
            self.dele_btn:setTouchEnabled(false)
            local sequence_action = cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function() 
                self:startTimeTicket()
            end))
            self.sequence_action = self.select_btn:runAction(sequence_action)
            self.sequence_action:setTag(1)
        elseif event_type == ccui.TouchEventType.moved then

        elseif event_type == ccui.TouchEventType.canceled then
            self.dele_btn:setTouchEnabled(true)
            self:clearTimeTicket()
        elseif event_type == ccui.TouchEventType.ended then
            self.dele_btn:setTouchEnabled(true)
            self:clearTimeTicket()
            if not self.is_click_btn then
                playButtonSound2()
                self:onClickBtnAdd()
            end
        end
    end)
    self.dele_btn:addTouchEventListener(function(sender, event_type)
        customClickAction_2(sender, event_type,1)
        if event_type == ccui.TouchEventType.began then
            self.is_click_btn1 = false --标志只点一次btn
            self.select_btn:setTouchEnabled(false)
            local sequence_action = cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function() 
                self:startTimeTicket1()
            end))
            self.sequence_action1 = self.dele_btn:runAction(sequence_action)
            self.sequence_action1:setTag(1)
        elseif event_type == ccui.TouchEventType.moved then
            
        elseif event_type == ccui.TouchEventType.canceled then
            self.select_btn:setTouchEnabled(true)
            self:clearTimeTicket1()
        elseif event_type == ccui.TouchEventType.ended then
            self.select_btn:setTouchEnabled(true)
            self:clearTimeTicket1()
            if not self.is_click_btn1 then
                playButtonSound2()
                self:onClickBtnMin()
            end
        end
    end)
    
end

function GemstoneStrengthenItem:onClickBtnMin()
    if not tolua.isnull(self.select_num) then
        local item_id = self.data.id
        local add_exp = self.data.exp
        local own_num =  BackpackController:getInstance():getModel():getItemNumByBid(item_id)
        if own_num == 0 then
            self.num = 0
            return
        end
        self.num = self.num - 1
        if self.num < 0 then 
            self.num = 0
        end
        self.select_num:setString(self.num)
        self.select_num:setScale(1)
        local width = self.select_num:getContentSize().width
        local height = self.select_num:getContentSize().height
        self.select_num_bg:setContentSize(cc.size(width+10, self.select_num_bg:getContentSize().height))
        self.select_num:setPositionX(width/2+5)
        
        if self.num <= 0 then
            self.select_num_bg:setVisible(false)
            self.dele_btn:setVisible(false)
        else
            self.select_num_bg:setVisible(true)
            self.dele_btn:setVisible(true)
        end
    
        local send_data = {}
        send_data.item_id = item_id
        send_data.num = self.num
        self.send_data = send_data
        if self.callback then
            self.callback()
        end
    end
end

function GemstoneStrengthenItem:onClickBtnAdd()
    if not tolua.isnull(self.select_num) then
        local item_id = self.data.id
        local add_exp = self.data.exp
        local own_num =  BackpackController:getInstance():getModel():getItemNumByBid(item_id)
        if own_num == 0 then
            self.num = 0
            local item_config = Config.ItemData.data_get_data(item_id)
            if item_config then
                BackpackController:getInstance():openTipsSource(true, item_id)
            end
            return
        end
        local is_full = self:checkFullExpStatus()
        if is_full then
            message(TI18N("语言_c_6815"))
            return 
        end
        self.num = self.num + 1
        if self.num > own_num then 
            self.num = own_num
            message(TI18N("语言_c_280"))
        end
        self.select_num:setString(self.num)
        self.select_num:setScale(1)
        local width = self.select_num:getContentSize().width
        local height = self.select_num:getContentSize().height
        self.select_num_bg:setContentSize(cc.size(width+10, self.select_num_bg:getContentSize().height))
        self.select_num:setPositionX(width/2+5)
        if self.num <= 0 then
            self.select_num_bg:setVisible(false)
            self.dele_btn:setVisible(false)
        else
            self.select_num_bg:setVisible(true)
            self.dele_btn:setVisible(true)
        end
    
        local send_data = {}
        send_data.item_id = item_id
        send_data.num = self.num
        self.send_data = send_data
        if self.callback then
            self.callback()
        end
    end
end
--判断是否选到上限了 true->满了 false->没满
function GemstoneStrengthenItem:checkFullExpStatus()
    local max_level = self.data.max_level
    local need_exp = self.data.max_exp - self.data.heve_exp
    local now_exp = 0
    for k, v in pairs(self.extend_data) do
        local cfg = Config.PartnerGemData.data_exp_info[v.item_id]
        local exp = cfg.exp
        now_exp = exp * v.num + now_exp
     end
	-- local now_exp = self.num * self.data.exp
    if now_exp >= need_exp then
        return true
    end
    return false
end
--长按-
function GemstoneStrengthenItem:startTimeTicket1()
    if self.time_ticket1 == nil then
        local _callback = function()
            self.is_click_btn1 = true
            self:onClickBtnMin()
        end
        self.time_ticket1 = GlobalTimeTicket:getInstance():add(_callback, 5 / display.DEFAULT_FPS)
    end
end
function GemstoneStrengthenItem:clearTimeTicket1()
    if self.sequence_action1 then
        self.dele_btn:stopActionByTag(1)
        self.sequence_action1 = nil
    end
    if self.time_ticket1 ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket1)
        self.time_ticket1 = nil
    end
end 
--长按+
function GemstoneStrengthenItem:startTimeTicket()
    if self.time_ticket == nil then
        local _callback = function()
            self.is_click_btn = true
            local is_full = false
            if self.checkFullExpStatus then
                is_full = self:checkFullExpStatus()
            end
            if is_full then
                message(TI18N("语言_c_6815"))
                return 
            end
            GemstoneController:getInstance():openGemstoneStrengSelectItemPanel(true,self.data.id,self.equip_data)
        end
        self.time_ticket = GlobalTimeTicket:getInstance():add(_callback, 5 / display.DEFAULT_FPS)
    end
end
function GemstoneStrengthenItem:clearTimeTicket()
    if self.sequence_action then
        self.select_btn:stopActionByTag(1)
        self.sequence_action = nil
    end
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end 

function GemstoneStrengthenItem:DeleteMe()
    self:clearTimeTicket()
    self:clearTimeTicket1()
	self:removeAllChildren()
    self:removeFromParent()
end
