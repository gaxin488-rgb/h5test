--------------------------------------------
---------------------------------
local _controller = RollerController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

RollerTalentItem = class("RollerTalentItem", function()
    return ccui.Widget:create()
end)

RollerTalentItem.Width = 76
RollerTalentItem.Height = 76

function RollerTalentItem:ctor()
    self:configUI()
	self:register_event()
end

function RollerTalentItem:configUI(  )
	self.size = cc.size(RollerTalentItem.Width, RollerTalentItem.Height)
	self:setContentSize(self.size)
	self:setAnchorPoint(cc.p(0.5, 0.5))

	local csbPath = PathTool.getTargetCSB("roller/roller_talent_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

	self.main_container = self.root_wnd:getChildByName("main_container")
    self.icon = self.main_container:getChildByName("icon")
    self.act_icon = self.main_container:getChildByName("act_icon")
    self.act_icon:setVisible(false)
end


function RollerTalentItem:register_event( )
    registerButtonEventListener(self.main_container, handler(self, self.onClickRoleItem), true)
    if not self.update_all_event then
        self.update_all_event = GlobalEvent:getInstance():Bind(RollerEvent.Roller_Talent_Update_Event,function()
            self:updateStatus()
        end)
    end
    if not self.update_event then
        self.update_event = GlobalEvent:getInstance():Bind(RollerEvent.Roller_Talent_Active_Event,function(id)
            if self.data.id == id then
                local talent_quality = self.data.talent_quality
                if talent_quality == 1 then
                    self.role_spine = createEffectSpine("E29010", cc.p(37, 37), cc.p(0.5, 0.5), false, "action1")
                    self.role_spine:setScale(0.7)
                    self.main_container:addChild(self.role_spine)
                elseif talent_quality == 2 or talent_quality == 3 then
                    self.role_spine = createEffectSpine("E29010", cc.p(37, 37), cc.p(0.5, 0.5), false, "action2")
                    self.role_spine:setScale(0.7)
                    self.main_container:addChild(self.role_spine)
                end
            end
        end)
    end
end

function RollerTalentItem:onClickRoleItem(  )
    local talent_quality = self.data.talent_quality
    if talent_quality == 3 or talent_quality == 2 then
        RollerController:getInstance():openRollerTalentMainActiveWindow(true,self.data.id)
    else
        _controller:openRollerTalentNormalActiveWindow(true,self.data.id)
    end
end

function RollerTalentItem:updateStatus()
    local status = _model:getTalentDataById(self.data.id)
    if self.role_spine then
        self.role_spine:removeFromParent()
        self.role_spine = nil
    end
    doStopAllActions(self.act_icon)
    if status then
        setChildUnEnabled(false, self.icon)
        self.act_icon:setVisible(false)
    else
        local lock,str = _model:getTalentOpenConditionById(self.data.id)
        if lock then
            local is_enough = _model:checkTalentActiveStatusById(self.data.id)
            if is_enough then
                self.act_icon:setVisible(true)
                local seq = cc.Sequence:create(cc.FadeOut:create(1.0),cc.FadeIn:create(1.0),cc.DelayTime:create(0.3))
                self.act_icon:runAction(cc.RepeatForever:create(seq))
            else
                self.act_icon:setVisible(false)
            end
        else
            self.act_icon:setVisible(false)
        end
        if self.role_spine then
            self.role_spine:removeFromParent()
            self.role_spine = nil
        end
        setChildUnEnabled(true, self.icon)
    end
end

function RollerTalentItem:setData( data, index )
    -- print(vardump(data))
	if not data then return end
	self.data = data
    local icon_res = data.effect_icon
    loadSpriteTexture(self.icon, PathTool.getResFrame("scroll_talent", icon_res), LOADTEXT_TYPE_PLIST)
    if data.talent_quality == 3 then
        self.act_icon:setScale(0.82)
    else
        self.act_icon:setScale(0.73)
    end

    local status = _model:getTalentDataById(self.data.id)
    if self.role_spine then
        self.role_spine:removeFromParent()
        self.role_spine = nil
    end
    
    doStopAllActions(self.act_icon)
    if status then
        setChildUnEnabled(false, self.icon)
        self.act_icon:setVisible(false)
    else
        local lock,str = _model:getTalentOpenConditionById(self.data.id)
        if lock then
            local is_enough = _model:checkTalentActiveStatusById(self.data.id)
            if is_enough then
                self.act_icon:setVisible(true)
                local seq = cc.Sequence:create(cc.FadeOut:create(1.0),cc.FadeIn:create(1.0),cc.DelayTime:create(0.3))
                self.act_icon:runAction(cc.RepeatForever:create(seq))
            else
                self.act_icon:setVisible(false)
            end
        else
            self.act_icon:setVisible(false)
        end
        setChildUnEnabled(true, self.icon)
    end

end

function RollerTalentItem:DeleteMe()
    doStopAllActions(self.act_icon)
    if self.role_spine then
        self.role_spine:removeFromParent()
        self.role_spine = nil
    end
    if self.update_all_event then
        GlobalEvent:getInstance():UnBind(self.update_all_event)
        self.update_all_event = nil
    end
    if self.update_event then
        GlobalEvent:getInstance():UnBind(self.update_event)
        self.update_event = nil
    end
end