-- --------------------------------------------------------------------
RollerTujianNewItem = class("RollerTujianNewItem", function() 
	return ccui.Layout:create()
end)
local string_format = string.format
local controller = RollerController:getInstance()
local model = controller:getModel()

function RollerTujianNewItem:ctor()

    self.attr_list = {}
    self.img_list = {}
    self.icon_list = {}
    self.equip_node_list = {} 
    self.equip_item_list = {}

	self.root_wnd = createCSBNote(PathTool.getTargetCSB("roller/roller_tujian_new_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)

	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width/2, self.size.height/2)
	self:addChild(self.root_wnd)

	self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setSwallowTouches(false)
	self.image_bg = self.main_container:getChildByName("image_bg")

    self.rolle_bg1 = self.main_container:getChildByName("rolle_bg1")
    self.roller_1 = self.rolle_bg1:getChildByName("Panel_1")
    self.roller_1:setSwallowTouches(false)
    self.roller_type_img1 = self.rolle_bg1:getChildByName("quality_icon")
    self.roller_name1 = self.rolle_bg1:getChildByName("equip_name")
    self.roller_name_bg1 = self.rolle_bg1:getChildByName("name_bg")
    self.roller_name_bg1:setLocalZOrder(97)
    self.roller_name1:setLocalZOrder(98)
    self.roller_type_img1:setLocalZOrder(99)
	self.item_node_1 = self.rolle_bg1:getChildByName("item_node_1")
    self.item_node_1.init_y = 120
	self.item_icon1 = self.item_node_1:getChildByName("item_icon1")
	self.star_node1 = self.rolle_bg1:getChildByName("star_node")

    self.rolle_bg2 = self.main_container:getChildByName("rolle_bg2")
    self.roller_2 = self.rolle_bg2:getChildByName("Panel_1")
    self.roller_2:setSwallowTouches(false)
    self.roller_type_img2 = self.rolle_bg2:getChildByName("quality_icon")
    self.roller_name2 = self.rolle_bg2:getChildByName("equip_name")
    self.roller_name_bg2 = self.rolle_bg2:getChildByName("name_bg")
    self.roller_name_bg2:setLocalZOrder(97)
    self.roller_name2:setLocalZOrder(98)
    self.roller_type_img2:setLocalZOrder(99)
	self.item_node_2 = self.rolle_bg2:getChildByName("item_node_2")
    self.item_node_2.init_y = 120
	self.item_icon2 = self.item_node_2:getChildByName("item_icon2")
    self.star_node2 = self.rolle_bg2:getChildByName("star_node")

	self.rich_node = self.main_container:getChildByName("rich_node")
    self.get_label = createRichLabel(22, cc.c4b(0x6d, 0x3c, 0x2d, 0xff), cc.p(0.5, 0.5), cc.p(0, 0))
    self.rich_node:addChild(self.get_label)

	self.equip_name = self.main_container:getChildByName("equip_name")
    self.arrt_node = self.main_container:getChildByName("attr_panel")
    -- self.attr_panel:setScrollBarEnabled(false)

	self.btn_get = self.main_container:getChildByName("btn_get")
    local label = self.btn_get:getChildByName("label")
    label:setString(TI18N("语言_s_78"))
    self.label = label

	self:registerEvent()
end
function RollerTujianNewItem:setData(data)
    self.data = data

    self.equip_name:setString(self.data.name)
    self.get_label:setString(self.data.unlock)

    -- 属性
    for k , v in pairs(self.attr_list) do 
        v:setVisible(false)
    end
    for k , v in pairs(self.img_list) do 
        v:setVisible(false)
    end
    for k , v in pairs(self.icon_list) do 
        v:setVisible(false)
    end

    for i , v in pairs(self.data.attr) do 
        local attr_txt = self.attr_list[i]
        local attr_key = v[1]
        local attr_val = v[2]
        local attr_icon = PathTool.getAttrIconByStr(attr_key) 
        local icon_res = PathTool.getResFrame("common", attr_icon)
        local attr_name = Config.AttrData.data_key_to_name[attr_key] 
        local img_index = i--math.ceil(i/2)
        local img_size = cc.size(300,30)
        -- -- 背景
        if not self.img_list[img_index]  then 
            local open_img = createScale9Sprite(PathTool.getResFrame("common_2","hero_info_31"),0,0,LOADTEXT_TYPE_PLIST)
            open_img:setAnchorPoint(cc.p(0, 1))
            open_img:setContentSize(img_size)

            local _x = 10 + 320 * ((img_index-1)%2)
            local _y = 82 - math.floor((img_index-1)/2)*(30 + 8)

            open_img:setPositionX(_x)
            open_img:setPositionY(_y)
            self.arrt_node:addChild(open_img)
            self.img_list[img_index] = open_img
        end
        if not attr_txt then
            local icon_img = createSprite(icon_res,15,img_size.height/2,LOADTEXT_TYPE_PLIST)
            self.img_list[img_index]:addChild(icon_img)
            self.icon_list[i] = icon_img
            attr_txt = createRichLabel(22, cc.c4b(0x6d,0x3c,0x2d,0xff), cc.p(0, 0.5), nil, nil, nil, 380)
            attr_txt:setAnchorPoint(cc.p(1, 0.5))
            attr_txt:setPosition(290,15)
            self.img_list[img_index]:addChild(attr_txt)
            local attr_name_label = createLabel(22, cc.c4b(0x6d,0x3c,0x2d,0xff), nil,35, 15,"",  self.img_list[img_index], nil)
            attr_name_label:setAnchorPoint(cc.p(0, 0.5))
            attr_txt.attr_name_label = attr_name_label
            self.attr_list[i] = attr_txt
        end       
        local is_per = PartnerCalculate.isShowPerByStr(attr_key)
        if is_per then
            attr_val = (attr_val/10).."%"
        end     
        loadSpriteTexture(self.icon_list[i], icon_res, LOADTEXT_TYPE_PLIST)
        attr_txt:setVisible(true)
        local str = transformTextToShort(attr_name,4)
        attr_txt.attr_name_label:setString(str .. "：")
        addEvt2showAllTextTips(attr_txt.attr_name_label,attr_name,4)
        attr_txt:setString(string.format("<div fontcolor=#0ea80e> %s</div> ","+"..attr_val ))
        attr_txt:setVisible(true)
        self.img_list[img_index]:setVisible(true)
        self.icon_list[i]:setVisible(true)
    end
    self:setRollerInfo()
    self:doShowIconAction()

    local can_lev_up = model:getRollerLibraryCanLevUp(self.data)
    if self.data.is_maxlev then 
        self.label:setString(TI18N("语言_c_2176"))
    elseif self.data.level == 1 and not self.data.is_pre_view then 
        self.label:setString(TI18N("语言_c_2904"))
    else 
        self.label:setString(TI18N("语言_c_766"))
    end
    setChildUnEnabled(not can_lev_up or self.data.is_maxlev, self.btn_get)
    self.btn_get:setTouchEnabled(can_lev_up)
    addRedPointToNodeByStatus(self.btn_get, can_lev_up and not self.data.is_maxlev, 10, 10)
end

function RollerTujianNewItem:setRollerInfo()
    local roller_id_1 = self.data.need_id1
    local roller_cfg1 = Config.ProhibitedScrollData.data_get_proh_scroll[roller_id_1]
    if roller_cfg1 then
        local roller_data1 = model:getRollerDataById(roller_id_1)
        local irem_img = roller_cfg1.show[1]
        local star = 0

        if roller_data1 then
            star = roller_data1.star
        end
        local max_star = model:getMaxStarById(roller_id_1)
        self.star_node1:removeAllChildren()
        self.star_list1 = {}
        self:setStarPanel(star,max_star,self.star_list1,self.star_node1)
        if irem_img then
            if irem_img[1] == 1 then
                local res = PathTool.getRollerIcon(irem_img[2],2)
                self.item_icon1:loadTexture(res, LOADTEXT_TYPE)
                self.item_icon1:setScale(0.45, 0.45)
                self.item_icon1:ignoreContentAdaptWithSize(true)
                if self.icon_eff1 then
                    self.icon_eff1:setVisible(false)
                end
                self.item_icon1:setVisible(true)
            elseif irem_img[1] == 2 then
                self.item_icon1:setVisible(false)
                if self.icon_eff1 then
                    self.icon_eff1:clearTracks()
                    self.icon_eff1:removeFromParent()
                    self.icon_eff1 = nil
                end
                if not self.icon_eff1 then
                    self.icon_eff1 = createEffectSpine(irem_img[2], cc.p(0,0), cc.p(0.5,0.5), true, "action1")
                    self.icon_eff1:setScale(0.45, 0.45)
                    self.item_node_1:addChild(self.icon_eff1)
                end
                local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[roller_id_1][star]
                local show = star_cfg.show[1]
                local action = show[1]
                self.icon_eff1:setAnimation(0, action, true)
            end
        end
        if roller_data1 then
            setChildUnEnabled(false, self.item_node_1)
        else
            setChildUnEnabled(true, self.item_node_1)
        end
        self.rolle_bg1:setVisible(true)

        local name = roller_cfg1.name
        self.roller_name1:setString(transformTextToShort(name,5))
        addEvt2showAllTextTips(self.roller_name1,name,5)
        local quality = roller_cfg1.quality
        loadSpriteTexture(self.roller_type_img1, PathTool.getResFrame("prohibited_scroll",RollerConst.QualityIcon[quality]), LOADTEXT_TYPE_PLIST) 
        self.roller_name_bg1:loadTexture( PathTool.getResFrame("prohibited_scroll",RollerConst.Qualitybg1[quality]), LOADTEXT_TYPE_PLIST)
        self.roller_name1:enableOutline(RollerConst.OutLineQualityColor[quality],2)
    else
        self.rolle_bg1:setVisible(false)
    end


    local roller_id_2 = self.data.need_id2
	local roller_data2 = model:getRollerDataById(roller_id_2)
    local roller_cfg2 = Config.ProhibitedScrollData.data_get_proh_scroll[roller_id_2]
    if roller_cfg2 then
        local irem_img = roller_cfg2.show[1]
        local star = 0
        if roller_data2 then
            star = roller_data2.star
        end
        local max_star = model:getMaxStarById(roller_id_2)
        self.star_node2:removeAllChildren()
        self.star_list2 = {}
        self:setStarPanel(star,max_star,self.star_list2,self.star_node2)
        if irem_img then
            if irem_img[1] == 1 then
                local res = PathTool.getRollerIcon(irem_img[2],2)
                self.item_icon2:loadTexture(res, LOADTEXT_TYPE)
                self.item_icon2:ignoreContentAdaptWithSize(true)
                self.item_icon2:setScale(0.45, 0.45)
                if self.icon_eff2 then
                    self.icon_eff2:setVisible(false)
                end
                self.item_icon2:setVisible(true)
            elseif irem_img[1] == 2 then
                self.item_icon2:setVisible(false)
                if self.icon_eff2 then
                    self.icon_eff2:clearTracks()
                    self.icon_eff2:removeFromParent()
                    self.icon_eff2 = nil
                end
                if not self.icon_eff2 then
                    self.icon_eff2 = createEffectSpine(irem_img[2], cc.p(0,0), cc.p(0.5,0.5), true, "action1")
                    self.icon_eff2:setScale(0.45, 0.45)
                    self.item_node_2:addChild(self.icon_eff2)
                end
                local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[roller_id_2][star]
                local show = star_cfg.show[1]
                local action = show[1]
                self.icon_eff2:setAnimation(0, action, true)
            end
        end
        if roller_data2 then
            setChildUnEnabled(false, self.item_node_2)
        else
            setChildUnEnabled(true, self.item_node_2)
        end
        self.rolle_bg2:setVisible(true)
        self.rolle_bg1:setPositionX(177)
        -- self.item_node_1:setPositionX(177)

        local name = roller_cfg2.name
        self.roller_name2:setString(transformTextToShort(name,5))
        addEvt2showAllTextTips(self.roller_name2,name,5)
        local quality = roller_cfg2.quality
        loadSpriteTexture(self.roller_type_img2, PathTool.getResFrame("prohibited_scroll",RollerConst.QualityIcon[quality]), LOADTEXT_TYPE_PLIST) 
        self.roller_name_bg2:loadTexture( PathTool.getResFrame("prohibited_scroll",RollerConst.Qualitybg1[quality]), LOADTEXT_TYPE_PLIST)
        self.roller_name2:enableOutline(RollerConst.OutLineQualityColor[quality],2)
    else
        self.rolle_bg2:setVisible(false)
        self.rolle_bg1:setPositionX(341)
        -- self.item_node_1:setPositionX(341)
    end

end
-- setChildDarkShader(false, self.compose_panel)
function RollerTujianNewItem:getEffNameByQuality(quality)
    if quality == BackPackConst.quality.blue then
        return "E27004","action1"
    elseif quality == BackPackConst.quality.purple then
        return "E27004","action2"
    elseif quality == BackPackConst.quality.orange then
        return "E27004","action3"
    elseif quality == BackPackConst.quality.red then
        return "E27007","action3"
    elseif quality == BackPackConst.quality.gold then
        return "E27008","action3"
    end
end

function RollerTujianNewItem:getData()
    return self.data
end

function RollerTujianNewItem:registerEvent()
    self.btn_get:addTouchEventListener(function(sender, event_type)
        customClickAction_2(sender, event_type,1)
        if event_type == ccui.TouchEventType.ended then
            if self.data.is_maxlev then
                message(TI18N("语言_c_2176"))
            else
                local can_lev_up = model:getRollerLibraryCanLevUp(self.data)
                if not can_lev_up then
                    message(TI18N(self.data.unlock))
                else
                    local effect_str = PathTool.getEffectRes(185) 
                    local content_size = self.main_container:getContentSize()
                    if not self.treatment_effect then
                        self.treatment_effect = createEffectSpine(effect_str, cc.p(360, 157), cc.p(0, 0), false, PlayerAction.action)
                        self.main_container:addChild(self.treatment_effect)
                    end
                    self.treatment_effect:setAnimation(0, PlayerAction.action, false)
                    controller:sender20825(self.data.id)
                end
            end
        end
    end)
    self.roller_1:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click == true then
                if self.data.need_id1 and  self.data.need_id1 ~= 0 then
                    local setting = {roller_id=self.data.need_id1,open_type=TRUE}
                    RollerController:getInstance():openRollerChipTipsWindow(true, setting)
                end
            end
        elseif event_type == ccui.TouchEventType.moved then
        elseif event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
        end
    end)
    self.roller_2:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click == true then
                if self.data.need_id2 and  self.data.need_id2 ~= 0 then
                    local setting = {roller_id=self.data.need_id2,open_type=TRUE}
                    RollerController:getInstance():openRollerChipTipsWindow(true, setting)
                end
            end
        elseif event_type == ccui.TouchEventType.moved then
        elseif event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
        end
    end)
end
function RollerTujianNewItem:doShowIconAction()
    doStopAllActions(self.item_node_1)
    self.item_node_1:setPositionY(self.item_node_1.init_y)
    local icon = self.item_node_1
    local pos_y = icon:getPositionY()
    local pos_x = icon:getPositionX()
    local dir = math.random(-1,1)
    -- if dir < 0 then
    --     dir = -1
    -- else
        dir = 1
    -- end
    local move_y = math.random(15,20)
    local move_to = cc.MoveTo:create(2, cc.p(pos_x, pos_y+(20*dir)))
    local move_back = cc.MoveTo:create(2, cc.p(pos_x, pos_y))
    icon:runAction(cc.RepeatForever:create(cc.Sequence:create(move_to,move_back)))

    doStopAllActions(self.item_node_2)
    self.item_node_2:setPositionY(self.item_node_2.init_y)
    local icon2 = self.item_node_2
    local pos_y = icon2:getPositionY()
    local pos_x = icon2:getPositionX()
    local dir = math.random(-1,1)
    -- if dir < 0 then
    --     dir = -1
    -- else
        dir = 1
    -- end
    local move_y = math.random(15,20)
    local move_to = cc.MoveTo:create(2, cc.p(pos_x, pos_y+(20*dir)))
    local move_back = cc.MoveTo:create(2, cc.p(pos_x, pos_y))
    icon2:runAction(cc.RepeatForever:create(cc.Sequence:create(move_to,move_back)))
end

function RollerTujianNewItem:setStarPanel(star,max_star,star_list,node)
	if not star_list or not next(star_list) then
        star_list = createOnlyStar(max_star,node,17)
    end
    for i, v in ipairs(star_list) do
        setChildUnEnabled(true, v)
        if i <= star then
            setChildUnEnabled(false, v)
        end
    end
end

function RollerTujianNewItem:DeleteMe()
    doStopAllActions( self.item_node_1)
    doStopAllActions( self.item_node_2)
    if self.treatment_effect then
        self.treatment_effect:clearTracks()
        self.treatment_effect:removeFromParent()
        self.treatment_effect = nil
    end
    if self.roller_eff1 then
        self.roller_eff1:clearTracks()
        self.roller_eff1:removeFromParent()
        self.roller_eff1 = nil
    end
    if self.icon_eff2 then
        self.icon_eff2:clearTracks()
        self.icon_eff2:removeFromParent()
        self.icon_eff2 = nil
    end
    if self.icon_eff2 then
        self.icon_eff2:clearTracks()
        self.icon_eff2:removeFromParent()
        self.icon_eff2 = nil
    end
    if self.icon_eff1 then
        self.icon_eff1:clearTracks()
        self.icon_eff1:removeFromParent()
        self.icon_eff1 = nil
    end
	self:removeAllChildren()
    self:removeFromParent()
end