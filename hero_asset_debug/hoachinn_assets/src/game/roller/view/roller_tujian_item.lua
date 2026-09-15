-- --------------------------------------------------------------------
RollerTujianItem = class("RollerTujianItem", function() 
	return ccui.Layout:create()
end)
local string_format = string.format
local controller = RollerController:getInstance()
local model = controller:getModel()

function RollerTujianItem:ctor()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("roller/roller_tujian_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)

	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width/2, self.size.height/2)
	self:addChild(self.root_wnd)

	self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setSwallowTouches(false)
	self.image_bg = self.main_container:getChildByName("image_bg")
	self.item_node = self.main_container:getChildByName("item_node")
	self.icon = self.item_node:getChildByName("icon")
    self.quality_icon = self.main_container:getChildByName("quality_icon")
	self.equip_name = self.main_container:getChildByName("equip_name")

    self.quality_bg = self.main_container:getChildByName("quality_bg")
    self.name_bg = self.main_container:getChildByName("name_bg")

	self.star_layer = self.main_container:getChildByName("star_layer")
	self.star_list = {}
	for i = 1, 5, 1 do
        local star = self.star_layer:getChildByName("star_" .. i)
        self.star_list[i] = star
    end

	self.btn_get = self.main_container:getChildByName("btn_get")
    local label = self.btn_get:getChildByName("label")
    local pox = label:getPositionX()
    local poy = label:getPositionY()
    self.get_label = createRichLabel(24, cc.c4b(0xf8, 0xef, 0x76, 0xff), cc.p(0.5, 0.5), cc.p(pox, poy))
    self.btn_get:addChild(self.get_label)

	self:registerEvent()
end
function RollerTujianItem:setData(data)
    self.data = data
    local show_info = data.show[1]
    if self.icon_eff then
        self.icon_eff:removeFromParent()
        self.icon_eff=nil
    end
    if show_info[1] == 1 then
        local pic_res = show_info[2]
        local res = PathTool.getRollerIcon(pic_res)
        loadSpriteTexture(self.icon, res, LOADTEXT_TYPE)
        self.icon:setVisible(true)
    else
        if self.icon_eff then
            self.icon_eff:clearTracks()
            self.icon_eff:removeFromParent()
            self.icon_eff = nil
        end
        if not self.icon_eff then
            self.icon_eff = createEffectSpine(show_info[2], cc.p(0, 0),  cc.p(0, 0), true, "action1")
            self.icon_eff:setScale(0.45, 0.45)
            self.item_node:addChild(self.icon_eff)
        end
        self.icon:setVisible(false)
    end

    local quality = data.quality
    self.quality_icon:loadTexture(PathTool.getResFrame("prohibited_scroll",RollerConst.QualityIcon[quality]), LOADTEXT_TYPE_PLIST)
    self.equip_name:setString(transformTextToShort(data.name,5))
	addEvt2showAllTextTips(self.equip_name,data.name,5)
    self.name_bg:loadTexture( PathTool.getResFrame("prohibited_scroll",RollerConst.Qualitybg1[quality]), LOADTEXT_TYPE_PLIST)
	self.quality_bg:loadTexture( PathTool.getResFrame("prohibited_scroll",RollerConst.Qualitybg2[quality]), LOADTEXT_TYPE_PLIST)
	self.equip_name:enableOutline(RollerConst.OutLineQualityColor[quality],2)

    local roller_data = model:getRollerDataById(data.id)
    local star = 0
    if roller_data then
        star = roller_data.star
        setChildDarkShader(false, self.item_node)
        setChildDarkShader(false, self.image_bg)
        local rward_data = roller_data.star_awards[1]
        if rward_data then
            local tujian_award = rward_data.bid
            local item_cfg = Config.ItemData.data_get_data(tujian_award)
            local str = "<img src=\'resource/item/%s.png\' scale=0.38 /><div fontcolor=#F8EF76 outline=2,#5C2705>+%s</div>"
            self.get_label:setString(string_format(str,item_cfg.icon,rward_data.num))
            setChildUnEnabled(false, self.btn_get)
            self.btn_get:setTouchEnabled(true)
        else
            local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[data.id]
            local next_star = star + 1
            local temp_cfg = star_cfg[next_star]
            if temp_cfg then
                local award = temp_cfg.award[1]
                local item_cfg = Config.ItemData.data_get_data(award[1])
                local str = "<img src=\'resource/item/%s.png\' scale=0.38 /><div fontcolor=#FFFFFF outline=2,#5c5c5c>+%s</div>"
                self.get_label:setString(string_format(str,item_cfg.icon,award[2]))
            else
                self.get_label:setString(string_format("<div fontcolor=#FFFFFF outline=2,#5c5c5c>%s</div>",TI18N("语言_s_4")))
            end
            setChildUnEnabled(true, self.btn_get)
            self.btn_get:setTouchEnabled(false)
        end
    else
        setChildDarkShader(true, self.item_node)
        setChildDarkShader(true, self.image_bg)
        local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[data.id]
        local cfg_info = star_cfg[star]
        local tujian_award = cfg_info.award[1]
        local item_cfg = Config.ItemData.data_get_data(tujian_award[1])
        local str = "<img src=\'resource/item/%s.png\' scale=0.38 /><div fontcolor=#FFFFFF outline=2,#5c5c5c>+%s</div>"
        self.get_label:setString(string_format(str,item_cfg.icon,tujian_award[2]))
        setChildUnEnabled(true, self.btn_get)
        self.btn_get:setTouchEnabled(false)
    end
    
    local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[data.id][star]
    local show = star_cfg.show[1]
    if show then
        local action = show[1]
        if self.icon_eff then
            self.icon_eff:setAnimation(0, action, true)
        end
    end

    local max_star = model:getMaxStarById(data.id)
    self:setStarPanel(star,max_star)
end

function RollerTujianItem:getData()
    return self.data
end
function RollerTujianItem:addCallBack(callback)
	self.callback = callback
end
function RollerTujianItem:registerEvent()
    self.btn_get:addTouchEventListener(function(sender, event_type)
        customClickAction_2(sender, event_type,1)
        if event_type == ccui.TouchEventType.ended then
            self.callback()
        end
    end)
    self.main_container:addTouchEventListener(function(sender, event_type)
        customClickAction_2(sender, event_type,1)
        if event_type == ccui.TouchEventType.ended then
            local is_click = true
            self.touch_end = sender:getTouchEndPosition()
            if self.touch_began ~= nil then
                is_click =  math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click then
                local setting = {roller_id=self.data.id,partner_id=nil,open_type=TRUE}
                controller:openRollerChipTipsWindow(true,setting)
            end
        elseif event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
        end
    end)

end

function RollerTujianItem:setStarPanel(star,max_star)
    local max_width = max_star * 29 + (max_star-1)*3
    local total_width = 160
    local start_x = 1.5+(160-max_width)/2 + 29/2
    for i, v in ipairs(self.star_list) do
        if i <= max_star then
            v:setVisible(true)
        else
            v:setVisible(false)
        end
        v:setPositionX(start_x + (i-1)*29)
    end
    for i, v in ipairs(self.star_list) do
        setChildUnEnabled(true, v)
        if i <= star then
            setChildUnEnabled(false, v)
        end
    end
end
function RollerTujianItem:DeleteMe()
	self:removeAllChildren()
    self:removeFromParent()
end