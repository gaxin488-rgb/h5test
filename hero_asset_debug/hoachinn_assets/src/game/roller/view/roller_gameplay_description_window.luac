
RollerGameplayDescriptionWindow = RollerGameplayDescriptionWindow or BaseClass(BaseView)

local controller = RollerController :getInstance()
local model = controller:getModel()

local tab_name = {
    [1] = TI18N("语言_c_7420"),
    [2] = TI18N("语言_c_7421"),
    [3] = TI18N("语言_c_7422"),
}
local tab_desc = {
    [1] = TI18N("语言_c_7423"),
    [2] = TI18N("语言_c_7424"),
    [3] = TI18N("语言_c_7425"),
}

function RollerGameplayDescriptionWindow:__init()
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "roller/roller_gameplay_description_window"
end

function RollerGameplayDescriptionWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.btn_close = self.root_wnd:getChildByName("_close_btn")
    -- self:playEnterAnimatianByObj(self.main_container, 1)

    self._desc_scroller = self.main_container:getChildByName("_desc_scroller")
    self._desc_scroller:setScrollBarEnabled(false)
    self.desc = createRichLabel(22, cc.c4b(0x7c, 0x55, 0x36, 0xff), cc.p(0,1), cc.p(0, 0), -4, nil, 540)
    self._desc_scroller:addChild(self.desc)

    self._container = self.main_container:getChildByName("_container")
    self._progress = self._container:getChildByName("_progress")
    self._progress:setScale9Enabled(true)

    self._container = self.main_container:getChildByName("_container")
    self._progress = self._container:getChildByName("_progress")

    self.container1 = self.main_container:getChildByName("container1")
    self._tltle_label = self.container1:getChildByName("_tltle_label")
    self._tltle_label:setString(TI18N("语言_c_6945"))
    
    self.container2 = self.main_container:getChildByName("container2")
    self._equip_name = self.container2:getChildByName("_equip_name")
    self._equip_name:setString(TI18N("语言_c_7417"))
    self._equip_desc = self.container2:getChildByName("_equip_desc")
    self._equip_desc:getVirtualRenderer():setLineSpacing(-14)
    -- setTextMaxWidth(self._equip_desc,248,-14)
    self._equip_desc:setString(TI18N("语言_c_7418"))
    self._equip_btn_label = self.container2:getChildByName("_equip_btn_label")
    self._equip_btn_label:setString(TI18N("语言_c_976"))
    
    self.container3 = self.main_container:getChildByName("container3")
    self.Node_1 = self.container3:getChildByName("Node_1")
    self._switch_label = self.container3:getChildByName("_switch_label")
    self._switch_label:setString(TI18N("语言_c_5455"))
    self._hero_name = self.container3:getChildByName("_hero_name")
    self._hero_name:setString(TI18N("语言_c_7419"))
    self.star_setting = createStar(15, self.Node_1, self.star_setting)

    self.object_list = {}
    for i = 1, 3, 1 do
        local sprite = self.main_container:getChildByName("Sprite_"..i)
        sprite:setVisible(false)
        local container = self["container"..i]
        container:setVisible(false)
        local tab_btn = self._container:getChildByName("tab_btn_"..i)
        tab_btn:getChildByName("select_bg"):setVisible(false)
        tab_btn:getChildByName("select_img"):setVisible(false)
        tab_btn:getChildByName("label"):setString(tab_name[i])
        local obj = {sprite=sprite,container=container,tab_btn=tab_btn,index=i}
        self.object_list[i] = obj
    end
end

function RollerGameplayDescriptionWindow:register_event(  )
    registerButtonEventListener(self.btn_close, handler(self, self.onClickCloseBtn), true, 2)
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
    for i = 1, 3, 1 do
        registerButtonEventListener(self.object_list[i].tab_btn, function ()
            self:onClickTabBtn(i)
        end, true, 2)
    end
end
function RollerGameplayDescriptionWindow:onClickTabBtn(index)
    self:setActionImg(index)
end
-- 关闭
function RollerGameplayDescriptionWindow:onClickCloseBtn(  )
    controller:openRollerGameplayDescriptionWindow(false)
end

function RollerGameplayDescriptionWindow:openRootWnd(index)
    index = index or 1
    self:setActionImg(index)
end

function RollerGameplayDescriptionWindow:setActionImg(index)
    if self.select_btn and self.select_btn.index == index then return end
    if self.select_btn then 
        self.select_btn.tab_btn:getChildByName("select_bg"):setVisible(false)
        self.select_btn.tab_btn:getChildByName("select_img"):setVisible(false)
        self.select_btn.tab_btn:getChildByName("normal_img"):setVisible(true)
        self.select_btn.tab_btn:getChildByName("label"):setTextColor(cc.c4b(255,255,255,255))
        self.select_btn.tab_btn:getChildByName("label"):enableOutline(cc.c4b(0x00,0x00,0x00,0xff), 2)
        self.select_btn.sprite:setVisible(false)
        self.select_btn.container:setVisible(false)
        self.select_btn = nil
    end

    self.select_btn = self.object_list[index]

    self.select_btn.tab_btn:getChildByName("select_bg"):setVisible(true)
    self.select_btn.tab_btn:getChildByName("select_img"):setVisible(true)
    self.select_btn.tab_btn:getChildByName("normal_img"):setVisible(false)
    self.select_btn.tab_btn:getChildByName("label"):setTextColor(cc.c4b(0xf5,0xd2,0x69,0xff))
    self.select_btn.tab_btn:getChildByName("label"):enableOutline(cc.c4b(0x18,0x01,0x01,0xff),2)
    self.select_btn.sprite:setVisible(true)
    self.select_btn.container:setVisible(true)

    self.click_index = index

    if index == 1 then
        self._progress:setPercent(0)
        self.desc:setString(tab_desc[index])
    elseif index == 2 then
        self._progress:setPercent(50)
        self.desc:setString(tab_desc[index])
    elseif index == 3 then
        self._progress:setPercent(100)
        self.desc:setString(tab_desc[index])
    end
    local desc_height = self.desc:getContentSize().height
    local scroller_height = math.min(desc_height, 177)
    local inner_height = math.max(scroller_height, 177)
    self._desc_scroller:setContentSize(cc.size(540, scroller_height))
    self._desc_scroller:setInnerContainerSize(cc.size(540, inner_height))
    self.desc:setPositionY(inner_height)
end

function RollerGameplayDescriptionWindow:close_callback()
    controller:openRollerGameplayDescriptionWindow(false)
end