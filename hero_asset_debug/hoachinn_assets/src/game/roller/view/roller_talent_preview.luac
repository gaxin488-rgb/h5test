--****************
--****************
RollerTalentPreview = RollerTalentPreview or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()

local table_insert = table.insert
function RollerTalentPreview:__init()
    self.is_full_screen = true
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.show_skill_list = {}
    self.show_skill_list_1 = {}
    self.show_attr_list = {}
	self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("prohibited_scroll", "scroll_talent"), type = ResourcesType.plist}
	}
	self.layout_name = "roller/roller_talent_preview"
end

function RollerTalentPreview:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

    self.item_1 = self.root_wnd:getChildByName("item_1")
    self.item_2 = self.root_wnd:getChildByName("item_2")
    self.item = self.root_wnd:getChildByName("item")

	local main_panel = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_panel, 1)

    self.img_title = main_panel:getChildByName("img_title")
    self.title_sp = main_panel:getChildByName("title_sp")
    self.title_sp:setString(TI18N("语言_c_7212"))
    autoSizeTitleBg(self.title_sp, self.img_title, 120)

	self.close_btn = main_panel:getChildByName("close_btn")
	self.strength_btn = main_panel:getChildByName("strength_btn")--前往提升
    self.strength_btn:setVisible(false)
    self.strength_btn:getChildByName("label"):setString(TI18N("语言_lev_up_01_d_54"))

	local tab_container = main_panel:getChildByName("tab_container")
	self.tab_container = tab_container
    local tab_name_list = {
        [1] = TI18N("语言_c_6867"),
        [2] = TI18N("语言_c_7211")
    }
    self.top_tab_list = {}
    for i=1,2 do
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.unselect_bg:setVisible(true)
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            -- object.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
            object.lable = tab_btn:getChildByName("title")
            object.lable:setString(tab_name_list[i])
			setTextSpacing(object.lable,-10)
            object.tab_btn = tab_btn
            object.index = i
            object.tips = tab_btn:getChildByName("tips")
            self.top_tab_list[i] = object
        end
    end
    --技能
    self.attr_panel = main_panel:getChildByName("attr_panel")
    self.attr_skill_node = self.attr_panel:getChildByName("skill_node")
    self.attr_get_btn = self.attr_skill_node:getChildByName("get_btn")
    self.attr_equip_name = self.attr_panel:getChildByName("equip_name")
    local left_tips_icon = self.attr_panel:getChildByName("left_tips_icon")
    local tip = self.attr_panel:getChildByName("_tip")
    tip:setString(TI18N("语言_c_7213"))
    local right_tips_icon = self.attr_panel:getChildByName("right_tips_icon")
    setLeftRightImg(left_tips_icon, tip, right_tips_icon, 20)
    local plan_list = self.attr_panel:getChildByName("plan_list")
    local size = plan_list:getContentSize()
    self.attr_scroller_1 = createScrollView(size.width, size.height, 0, 0, plan_list, ccui.ScrollViewDir.vertical)

    local plan_list_1 = self.attr_panel:getChildByName("plan_list_1")
    local size = plan_list_1:getContentSize()
    self.attr_scroller_2 = createScrollView(size.width, size.height, 0, 0, plan_list_1, ccui.ScrollViewDir.vertical)

    --属性
    self.skill_panel = main_panel:getChildByName("skill_panel")
    self.skill_skill_node = self.skill_panel:getChildByName("skill_node")
    self.skill_get_btn = self.skill_skill_node:getChildByName("get_btn")
    self.skill_equip_name = self.skill_panel:getChildByName("equip_name")
    local title_tips = self.skill_panel:getChildByName("title_tips")
    title_tips:setString(TI18N("语言_c_6180"))
    local _plan_list = self.skill_panel:getChildByName("plan_list")
    local size = _plan_list:getContentSize()
    self.skill_scroller_1 = createScrollView(size.width, size.height, 0, 0, _plan_list, ccui.ScrollViewDir.vertical)
    self._tips = self.skill_panel:getChildByName("tip")
    self.power_label = self.skill_panel:getChildByName("power_label")

end

function RollerTalentPreview:openRootWnd( index, type )
    self:setData()
    local power = controller:getModel():getTalentPower()
    self.power_label:setString(MoneyTool.moneyFormat(power))
    if type == 1 then
        self.strength_btn:setVisible(true)
        self.tab_container:setVisible(false)
        self:tabChangeView(2)
    else
        self.strength_btn:setVisible(false)
        self.tab_container:setVisible(true)
        self:tabChangeView(index or 1)
    end
end

function RollerTalentPreview:setData()
    local talent_step = model:getTalentOrder()
    self.skill_get_btn:loadTexture(PathTool.getResFrame("scroll_talent",RollerConst.TalentIcon[talent_step]), LOADTEXT_TYPE_PLIST)
    self.attr_get_btn:loadTexture(PathTool.getResFrame("scroll_talent",RollerConst.TalentIcon[talent_step]), LOADTEXT_TYPE_PLIST)

    local list = {}
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_talent
    for k, v in pairs(cfg) do
        local data = v
        for key, val in pairs(data) do
            local talent_quality = val.talent_quality
            if talent_quality == 3 then
                table.insert(list,val)
            end
        end
    end
    local __skill_id
    for i, v in ipairs(list) do
        local group = v.group
        local order,lv = model:getNowTalentStepLv()
        if group <= order then
            __skill_id = v.active_skill[1]
        end
    end
    if not __skill_id then
        __skill_id = list[1].active_skill[1]
    end
    local __skill_cfg = Config.SkillData.data_get_skill(__skill_id)
    if __skill_cfg then
        self.attr_equip_name:setString(__skill_cfg.name)
        self.skill_equip_name:setString(__skill_cfg.name)
    end

    local roller_list = model:getTalentData()
    local extral_list = {}
    local attr_list = {}
    for k, v in pairs(roller_list) do
        local id = v.id
        local _cfg = model:getRollerTalentInfo(id)
        if _cfg.talent_quality == 2 then
            table.insert(extral_list,_cfg)
        elseif _cfg.talent_quality == 1 then
            table.insert(attr_list,_cfg)
        end
    end

    local total_scroller_height = 0
    for i, v in pairs(list) do
        if self.show_skill_list[i] == nil then
            self.show_skill_list[i] = self:createStrengthEffectItem(self.attr_scroller_1)
            local skill_lv = createLabel(22, cc.c4b(0xff, 0xff, 0xdb, 0xff), cc.c4b(0x7e, 0x2e, 0x09, 0xff), 8, 0, "", self.show_skill_list[i].layer, 2, cc.p(0, 1))
            self.show_skill_list[i].skill_lv = skill_lv
            local skill_desc = createRichLabel(20, cc.c4b(0x8f, 0x5a, 0x31, 0xff), cc.p(0.5, 1), cc.p(310,0), 0, nil, 600)
            self.show_skill_list[i].layer:addChild(skill_desc)
            self.show_skill_list[i].skill_desc = skill_desc
            local skill_tips = createLabel(18, cc.c4b(0xff, 0x15, 0x15, 0xff), nil, 600, 0, "", self.show_skill_list[i].layer, 0, cc.p(1, 0))
            self.show_skill_list[i].skill_tips = skill_tips
            local buff_desc = createRichLabel(20, cc.c4b(0x8f, 0x5a, 0x31, 0xff), cc.p(0, 1), cc.p(10,0), 0, nil, 600)
            self.show_skill_list[i].layer:addChild(buff_desc)
            self.show_skill_list[i].buff_desc = buff_desc
        end
        local skill_id = v.active_skill[1]
        local skill_cfg = Config.SkillData.data_get_skill(skill_id)
        if skill_cfg then
            self.show_skill_list[i].skill_desc:setString(skill_cfg.des)
        end
        local group = v.group
        local order,lv = model:getNowTalentStepLv()
        if group <= order then
            self.show_skill_list[i].skill_lv:setString(string.format(TI18N("语言_c_7043"), v.group))--(v.group.."阶")
            autoSizeTitleBg(self.show_skill_list[i].skill_lv, self.show_skill_list[i].title_bg, 50, 150)
            setChildUnEnabled(false, self.show_skill_list[i].skill_lv)
            setChildUnEnabled(false, self.show_skill_list[i].title_bg)
            setChildUnEnabled(false, self.show_skill_list[i].bg)
        else
            self.show_skill_list[i].skill_lv:setString(string.format(TI18N("语言_c_7214"), v.group))--(v.group.."阶[未解锁]")
            self.show_skill_list[i].skill_lv:enableOutline(cc.c4b(0x5c, 0x5c, 0x5c, 0xff), 2)
            autoSizeTitleBg(self.show_skill_list[i].skill_lv, self.show_skill_list[i].title_bg, 50, 150)
            setChildUnEnabled(true, self.show_skill_list[i].skill_lv)
            setChildUnEnabled(true, self.show_skill_list[i].title_bg)
            setChildUnEnabled(true, self.show_skill_list[i].bg)
        end

        if group == order then
            self.show_skill_list[i].current_txt:setString(TI18N("语言_halm_01_23"))
            self.show_skill_list[i].current_txt:setVisible(true)
            self.show_skill_list[i].current_img:setVisible(true)
        else
            self.show_skill_list[i].current_txt:setVisible(false)
            self.show_skill_list[i].current_img:setVisible(false)
        end

        if skill_cfg.buff_des ~= nil and skill_cfg.buff_des[1] and next(skill_cfg.buff_des[1]) then
            local buff_config = Config.SkillData.data_get_buff 
            local buff_desc_str = ""
            for i, v in ipairs(skill_cfg.buff_des[1]) do
                local config = buff_config[v]
                if config then
                    if buff_desc_str ~= "" then
                        buff_desc_str = buff_desc_str.."<div fontcolor=#a1978b>\n</div>"
                    end
                    local buff_desc = string_format("<div fontcolor=#653825>【%s】</div><div fontcolor=#8f5a31>\n%s</div>", config.name, config.desc)
                    buff_desc_str = buff_desc_str..buff_desc
                end
            end
            self.show_skill_list[i].buff_desc:setString(buff_desc_str)
        end
        local hight = 150
        local hight1 = self.show_skill_list[i].skill_lv:getContentSize().height
        local hight2 = self.show_skill_list[i].skill_desc:getContentSize().height
        local hight3 = self.show_skill_list[i].skill_tips:getContentSize().height
        local hight4 = self.show_skill_list[i].buff_desc:getContentSize().height
        local total_height = math.max(hight,(hight1+hight2+hight3+25+hight4))
        self.show_skill_list[i].layer:setContentSize(cc.size(620, total_height))
        self.show_skill_list[i].bg:setContentSize(cc.size(620, total_height))
        self.show_skill_list[i].skill_item:setContentSize(cc.size(620, total_height))
        self.show_skill_list[i].skill_item:setPositionY(total_height)
        self.show_skill_list[i].bg:setPositionY(total_height/2)
        self.show_skill_list[i].title_bg:setPositionY(total_height+3)
        self.show_skill_list[i].current_img:setPositionY(total_height+3)
        self.show_skill_list[i].current_txt:setPositionY(total_height+3)
        self.show_skill_list[i].skill_lv:setPositionY(total_height+5)
        self.show_skill_list[i].skill_desc:setPositionY(total_height-hight1)
        self.show_skill_list[i].buff_desc:setPositionY(total_height-5-hight1-5-hight2-5)
        self.show_skill_list[i].skill_tips:setPositionY(10)
        total_scroller_height = total_scroller_height + total_height + 10
    end
    self.attr_scroller_1:setInnerContainerSize(cc.size(630, total_scroller_height))
    for k, v in pairs(self.show_skill_list) do
        local height = v.layer:getContentSize().height
        v.layer:setPositionY(total_scroller_height - height - 10)
        total_scroller_height = total_scroller_height - height - 10
    end

    local total_scroller_height = 0
    if not next(extral_list) then
        commonShowEmptyIcon(self.attr_scroller_2, true, {text=TI18N("语言_c_7215"),font_size=22,offset_y=15})
    else
        commonShowEmptyIcon(self.attr_scroller_2, false)
    end
    for i, v in pairs(extral_list) do
        if self.show_skill_list_1[i] == nil then
            self.show_skill_list_1[i] = self:createSkillItem(self.attr_scroller_2)
            local skill_desc = createRichLabel(20, cc.c4b(0x8f, 0x5a, 0x31, 0xff), cc.p(0.5, 0.5), cc.p(310,0), 0, nil, 600)
            self.show_skill_list_1[i].layer:addChild(skill_desc)
            self.show_skill_list_1[i].skill_desc = skill_desc
        end

        local skill_id = v.skill[1]
        local skill_cfg = Config.SkillData.data_get_skill(skill_id)
        local str = ""
        if skill_cfg then
            str = skill_cfg.des
            self.show_skill_list_1[i].skill_desc:setString(str)
        end
        local hight = 46
        local hight1 = self.show_skill_list_1[i].skill_desc:getContentSize().height
        local total_height = math.max(hight,(hight1+20))
        self.show_skill_list_1[i].layer:setContentSize(cc.size(620, total_height))
        self.show_skill_list_1[i].skill_item:setContentSize(cc.size(620, total_height))
        self.show_skill_list_1[i].attr_bg:setContentSize(cc.size(620, total_height))
        self.show_skill_list_1[i].layer:setPositionX(315)
        self.show_skill_list_1[i].skill_desc:setPositionY(total_height/2)
        self.show_skill_list_1[i].attr_bg:setPositionY(total_height/2)
        self.show_skill_list_1[i].skill_item:setPositionY(total_height/2)
        total_scroller_height = total_scroller_height + total_height + 10
    end
    total_scroller_height = math.max(total_scroller_height,184)
    self.attr_scroller_2:setInnerContainerSize(cc.size(630, total_scroller_height))
    for k, v in pairs(self.show_skill_list_1) do
        local height = v.layer:getContentSize().height
        v.layer:setPositionY(total_scroller_height - height - 10)
        total_scroller_height = total_scroller_height - height - 10
    end

    --属性
    -- print("--属性",vardump(attr_list))
    if not next(attr_list) then
        commonShowEmptyIcon(self.skill_scroller_1, true, {text=TI18N("语言_c_7216")})
        -- return 
    else
        commonShowEmptyIcon(self.skill_scroller_1, false)
    end
    local attr_ = {}
    for k, v in pairs(attr_list) do
        local attrs = v.attrs
        for i, val in ipairs(attrs) do
            table.insert(attr_,val)
        end
    end
    local _now_list = {}
    for k, v in pairs(attr_) do
        local key = v[1]
        local num = v[2]
        if _now_list[key] then
            _now_list[key] = _now_list[key] + num
        else
            _now_list[key] = num
        end
    end
    local now_list = {}
    for i, v in pairs(_now_list) do
        table.insert(now_list, {i,v})
    end
    local attr_num = #now_list
    local scroller_size = self.skill_scroller_1:getContentSize()
    local total_height = math.max(55*attr_num, scroller_size.height)
    for i = 1, attr_num do
        if self.show_attr_list[i] == nil then
            self.show_attr_list[i] = self:createAttrItem(self.skill_scroller_1)
        end
        local now_res, now_attr_name, now_attr_val
        if now_list[i] and next(now_list[i]) then
            now_res, now_attr_name, now_attr_val = commonGetAttrInfoByKeyValue(now_list[i][1], now_list[i][2])
        end

        local res = now_res
        local attr_name = now_attr_name
        now_attr_val = now_attr_val or 0
        self.show_attr_list[i].attr_img1:loadTexture(res, LOADTEXT_TYPE_PLIST)
        self.show_attr_list[i].attr1:setString(attr_name)
        self.show_attr_list[i].attr2:setString(now_attr_val)

        if i%2==1 then
            self.show_attr_list[i].attr_bg:setVisible(true)
        else
            self.show_attr_list[i].attr_bg:setVisible(false)
        end

        local _x = 310
        local _y = total_height - (i-1)*55
        self.show_attr_list[i].layer:setPosition(cc.p(_x,_y))
    end
end

function RollerTalentPreview:createSkillItem(parent)
    local item = {}
	local layer = ccui.Layout:create()
    layer:setAnchorPoint(cc.p(0.5, 0))
    layer:setContentSize(cc.size(620,46))
    parent:addChild(layer)

	local skill_item = self.item_2:clone()
    layer:addChild(skill_item)
    skill_item:setPositionX(305)
    skill_item:setPositionY(23)

    local attr_bg = skill_item:getChildByName("attr_bg")
    item.layer = layer
    item.skill_item = skill_item
    item.attr_bg = attr_bg
    return item
end

function RollerTalentPreview:createAttrItem(parent)
    local item = {}
	local layer = ccui.Layout:create()
    layer:setAnchorPoint(cc.p(0.5, 1))
    layer:setContentSize(cc.size(620,40))
    parent:addChild(layer)

	local skill_item = self.item:clone()
    layer:addChild(skill_item)
    skill_item:setPositionX(305)
    skill_item:setPositionY(20)

    local attr_bg = skill_item:getChildByName("attr_bg")
    local attr_img1 = skill_item:getChildByName("attr_img1")
    local attr1 = skill_item:getChildByName("attr1")
    local attr2 = skill_item:getChildByName("attr2")

    item.layer = layer
    item.attr_img1 = attr_img1
    item.attr_bg = attr_bg
    item.attr1 = attr1
    item.attr2 = attr2
    return item
end

function RollerTalentPreview:createStrengthEffectItem(parent)
    local item = {}
	local layer = ccui.Layout:create()
    layer:setTouchEnabled(false)
    layer:setAnchorPoint(cc.p(0.5, 0))
    layer:setContentSize(cc.size(620,36))
    layer:setPositionX(318)
    parent:addChild(layer)

	local skill_item = self.item_1:clone()
    skill_item:setTouchEnabled(false)
    layer:addChild(skill_item)
    skill_item:setPositionX(310)
    local bg = skill_item:getChildByName("bg")
    local title_bg = skill_item:getChildByName("tit")
    local current_img = skill_item:getChildByName("current_img")
    local current_txt = skill_item:getChildByName("current_txt")

    item.bg = bg
    item.skill_item = skill_item
    item.current_txt = current_txt
    item.current_img = current_img
    item.title_bg = title_bg
    item.layer = layer

    return item
end

function RollerTalentPreview:register_event()
    for i,tab_btn in pairs(self.top_tab_list) do
    	registerButtonEventListener(tab_btn.tab_btn, function()
	        self:tabChangeView(tab_btn.index)
	    end,false, 3)
    end

	registerButtonEventListener(self.close_btn, function ()
		controller:openRollerTalentPreviewWindow(false)
	end, true, 2)

	registerButtonEventListener(self.background, function ()
		controller:openRollerTalentPreviewWindow(false)
	end, false, 2)

	registerButtonEventListener(self.strength_btn, function ()
        local talent_cond = controller:getModel():checkTalentCondition()
        if talent_cond then
            controller:openRollerTalentMainWindow(true,1)
            controller:openRollerTalentPreviewWindow(false)
        else
            local base_cfg = Config.ProhibitedScrollData.data_get_constant["scroll_curse_open"]
            local val = base_cfg.val
            message(string.format(TI18N("语言_c_7238"), val))
        end
	end, true, 2)

end

function RollerTalentPreview:tabChangeView(index)
    if self.tab_object ~= nil and self.tab_object.index == index then return end

    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object = nil
    end
    self.tab_object = self.top_tab_list[index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
    end
    
    if index == 1 then
        self.skill_panel:setVisible(true)
        self.attr_panel:setVisible(false)
    elseif index == 2 then
        self.skill_panel:setVisible(false)
        self.attr_panel:setVisible(true)
    end
end


function RollerTalentPreview:close_callback()
	-- if self.item_scrollview then
	-- 	self.item_scrollview:DeleteMe()
	-- 	self.item_scrollview = nil
	-- end
	controller:openRollerTalentPreviewWindow(false)
end
