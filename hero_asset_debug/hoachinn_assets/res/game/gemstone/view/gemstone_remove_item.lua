GemstoneRemoveItem = class("GemstoneRemoveItem", function()
    return ccui.Layout:create()
end)
local string_format = string.format
function GemstoneRemoveItem:ctor()
	self:configUI()
	self:register_event()
end

function GemstoneRemoveItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("hero/hero_sacrifice_item"))
    self:setContentSize(cc.size(687, 214))
    self:addChild(self.root_wnd)
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setSwallowTouches(false)
    self.title = self.main_container:getChildByName("title")
    self.selected = self.main_container:getChildByName("selected")
    self.markImg = self.main_container:getChildByName("mark_img")
    self.selected:setVisible(false)
    self.markImg:setVisible(false)
end

function GemstoneRemoveItem:register_event()
	self.main_container:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			-- self.touch_end = sender:getTouchEndPosition()
            playButtonSound2()
            GlobalEvent:getInstance():Fire(GemstoneEvent.Auto_Sacrifice_Event,self.selectNum)
		elseif event_type == ccui.TouchEventType.began then
			self.touch_began = sender:getTouchBeganPosition()
		elseif event_type == ccui.TouchEventType.moved then
		elseif event_type == ccui.TouchEventType.canceled then
		end
	end)
end

function GemstoneRemoveItem:setData(data)
    self.selectNum = data
    local cfg = Config.PartnerGemData.data_constant.gem_select
    local desc = cfg.desc
    local diffItem = cfg.val[data]
    -- local str =  transformTextToShort(string_format(TI18N(desc),diffItem[2], diffItem[1]),275)
    local quality_name = BackPackConst.quality_name[diffItem[1]]
    self.title:setString(string_format(TI18N(desc),diffItem[2], quality_name))
    self.title:ignoreContentAdaptWithSize(true)
    self.title:setTextAreaSize(cc.size(334,0))
    self.title:getVirtualRenderer():setLineSpacing(-5)
    self:updateSelfSize()
    self:updateSelect()
end

function GemstoneRemoveItem:updateSelfSize()
    -- local tw = self.title:getContentSize().width    
    local th = self.title:getContentSize().height 
    self.main_container:setContentSize(cc.size(375,th + 7))
    local csize = self.main_container:getContentSize()
    self.root_wnd:setContentSize(csize)
    self.main_container:setPositionY(csize.height)
    self.selected = self.main_container:getChildByName("selected")
    self.selected:setContentSize(csize)
    self.selected:setPositionY(csize.height/2)
    self.title:setPositionY(csize.height/2)
    self.markImg:setPositionY(csize.height/2)
end

function GemstoneRemoveItem:getRootHeight()
    local rh = self.root_wnd:getContentSize().height
    return rh or 30
end

function GemstoneRemoveItem:updateSelect()
    self.markImg:setVisible(false)
    local status = GemstoneController:getInstance():getModel():getHeroSacrificeNum()
    if self.selectNum == status then
        -- self.selected:setVisible(true)
        self.markImg:setVisible(true)
    end
end

function GemstoneRemoveItem:setnowselect(status)
    self.selected:setVisible(status)
end

function GemstoneRemoveItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end



