-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
RollerTalentActiveMainWindow = RollerTalentActiveMainWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()

local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function RollerTalentActiveMainWindow:__init()
    self.is_full_screen = true
	self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.tab_list = {}
    self.square_list = {}
    self.talent_item_list = {}
    self.layout_name = "roller/roller_talent_active_main_window"
end

function RollerTalentActiveMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.mainContainer = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.mainContainer , 1)

    self.clsoe_btn = self.mainContainer:getChildByName("clsoe_btn")
    self.up_panel = self.mainContainer:getChildByName("up_panel")

    self.img = self.up_panel:getChildByName("img")
    self.skill_node_1 = self.up_panel:getChildByName("skill_node_1")
    local get_btn = self.skill_node_1:getChildByName("get_btn")
    local lv_bg = get_btn:getChildByName("lv_bg")
    local label = get_btn:getChildByName("label")
    self.skill_node_1.get_btn = get_btn
    self.skill_node_1.lv_bg = lv_bg
    self.skill_node_1.label = label

    self.skill_node_2 = self.up_panel:getChildByName("skill_node_2")
    local get_btn = self.skill_node_2:getChildByName("get_btn")
    local lv_bg = get_btn:getChildByName("lv_bg")
    local label = get_btn:getChildByName("label")
    self.skill_node_2.get_btn = get_btn
    self.skill_node_2.lv_bg = lv_bg
    self.skill_node_2.label = label

    self.img_title = self.up_panel:getChildByName("img_title")
    self.title = self.up_panel:getChildByName("title")
    self.title:setString(TI18N("语言_c_7222"))
    moveTextBg(self.title,self.img_title,80,250)

    self.plan_list = self.up_panel:getChildByName("plan_list")
    self.scroller_view = createScrollView(self.plan_list:getContentSize().width, self.plan_list:getContentSize().height, 0, 0, self.plan_list, ccui.ScrollViewDir.vertical)
    self.desc = createRichLabel(22, cc.c4b(0x7c,0x55,0x36,255), cc.p(0, 1), cc.p(20, 0), -4, nil, 580) 
    self.scroller_view:addChild(self.desc)
   
    self.eff_list = self.up_panel:getChildByName("eff_list")
    local scroll_view_size = self.eff_list:getContentSize()
    local setting = {
        item_class = CostItem, -- 单元类
        start_x = 0, -- 第一个单元的X起点
        space_x = 10, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = 117, -- 单元的尺寸width
        item_height = 140, -- 单元的尺寸height
        row = 1, -- 行数，作用于水平滚动类型
        col = 0, -- 列数，作用于垂直滚动类型
        scale = 0.9,
        -- is_center = true
    }
    if not self.item_scrollview  then
        self.item_scrollview = CommonScrollViewLayout.new(self.eff_list, cc.p(0, 0), ScrollViewDir.horizontal,ScrollViewStartPos.top, scroll_view_size, setting)
    end

    local tip = self.up_panel:getChildByName("tip")
    tip:setString(TI18N("语言_c_7220"))
    self.cancel_btn = self.up_panel:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("语言_c_6305"))
    self.tip1 = self.up_panel:getChildByName("tip1")
    self.tip1:setString(TI18N("语言_c_7221"))
    self.max_tips = self.up_panel:getChildByName("max_tip")
    self.max_tips:setString(TI18N("语言_c_6306"))
    self.max_tips:setVisible(false)

    self.cond_txt = self.up_panel:getChildByName("cond_txt")
    self.cond_txt:setString("")

end

function RollerTalentActiveMainWindow:register_event()
    registerButtonEventListener(self.background, function() self:_onClickBtnClose() end ,false, 2)
    registerButtonEventListener(self.clsoe_btn, function() self:_onClickBtnClose() end ,true, 2)
    registerButtonEventListener(self.cancel_btn, function() self:changeTabIndex() end ,true, 2)

end

function RollerTalentActiveMainWindow:_onClickBtnClose()
    controller:openRollerTalentMainActiveWindow(false)
end
function RollerTalentActiveMainWindow:changeTabIndex()
    local status = model:checkTalentCondition()
    if status then
        controller:sender20821(self.talent_id)
    else
        message(TI18N("语言_c_2128"))
    end
end

function RollerTalentActiveMainWindow:openRootWnd(id)
    self.talent_id = id
    local step,talent_cfg
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_talent
    for k, v in pairs(cfg) do
        local _data = v
        for key, val in pairs(_data) do
            if val.id == id then
                step = k
                talent_cfg = val
                break
            end
        end
    end
    if step == 1 then -- 1阶 要特殊处理一下
        -- self.skill_node_1.lv_bg:setVisible(false)
        self.skill_node_1.label:setString(string_format(TI18N("语言_c_7208"),0,0))--("0阶0级")
        self.skill_node_2.label:setString(string_format(TI18N("语言_c_7208"),1,1))
    else
        local last_step = step - 1
        local last_step_max_lv = model:getStepMaxLvByStep(last_step)
        self.skill_node_1.label:setString(string_format(TI18N("语言_c_7208"),last_step,last_step_max_lv))
        self.skill_node_2.label:setString(string_format(TI18N("语言_c_7208"),step,1))
    end
    local skill
    if talent_cfg.talent_quality == 3 then
        skill = talent_cfg.active_skill[1]
    else
        skill = talent_cfg.skill[1]
        --local lv = self.talent_id%100
        -- self.skill_node_1.label:setString(string_format("%s阶%s级",step,lv))
        self.skill_node_1:setPositionX(330)
        self.skill_node_2:setVisible(false)
        self.img:setVisible(false)

        local _temp_data = cfg[step]
        local _temp_cfg = {}
        for k, v in pairs(_temp_data) do
            table.insert(_temp_cfg,deepCopy(v))
        end
        local function sortFunc( objA, objB )
            return objA.id < objB.id
        end
        table.sort(_temp_cfg, sortFunc)
    
        local lv = 0
        for i = 1, #_temp_cfg do
            if _temp_cfg[i] then
                local quality = _temp_cfg[i].talent_quality
                if quality == 2 or quality == 3 then
                    lv = lv + 1
                end
                if _temp_cfg[i].id == self.talent_id then
                    break
                end
            end
        end
        self.skill_node_1.label:setString(string_format(TI18N("语言_c_7208"),step,lv))

    end

    self.skill_node_1.get_btn:loadTexture(PathTool.getResFrame("scroll_talent",RollerConst.TalentIcon[step]), LOADTEXT_TYPE_PLIST)
    self.skill_node_2.get_btn:loadTexture(PathTool.getResFrame("scroll_talent",RollerConst.TalentIcon[step]), LOADTEXT_TYPE_PLIST)
    -- local talent_data = controller:getModel():getTalentData()
    -- local num = tableLen(talent_data)
    -- if num > 0 then
    --     if not self.roller_btn.btn_eff then
    --         self.roller_btn.btn_eff = createEffectSpine("E50104", cc.p(56, 56), cc.p(0.5, 0.5), true, "action1")
    --         self.roller_btn:addChild(self.roller_btn.btn_eff)
    --     end
    --     self.roller_btn.btn_eff:setVisible(true)
    -- else
    --     if self.roller_btn.btn_eff then
    --         self.roller_btn.btn_eff:setVisible(false)
    --     end
    -- end



    local skill_cfg = Config.SkillData.data_get_skill(skill)
    self.desc:setString(skill_cfg.des)

    local label_siez = self.desc:getContentSize()
    local scroller_size = self.scroller_view:getContentSize()
    local max_height = math.max(label_siez.height, scroller_size.height)
    self.scroller_view:setInnerContainerSize(cc.size(scroller_size.width, max_height))
    self.desc:setPositionY(max_height)

    local is_active = model:getTalentDataById(self.talent_id)
    if is_active then
        self.max_tips:setVisible(true)
        self.cancel_btn:setVisible(false)
        self.tip1:setVisible(false)
        self.item_scrollview:setVisible(false)
    else
        local cost = deepCopy(talent_cfg.cost)
        self.item_scrollview:setData(cost)
        self.max_tips:setVisible(false)
        self.item_scrollview:setVisible(true)
        self.cancel_btn:setVisible(true)
        self.tip1:setVisible(true)
    end

    local lock,str = model:getTalentOpenConditionById(self.talent_id)
    if not lock then
        self.cond_txt:setString(str)
        setChildUnEnabled(true,self.cancel_btn)
        self.cancel_btn:setTouchEnabled(false)
    else
        self.cond_txt:setString("")
        setChildUnEnabled(false,self.cancel_btn)
        self.cancel_btn:setTouchEnabled(true)
    end
end

function RollerTalentActiveMainWindow:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    controller:openRollerTalentMainActiveWindow(false)
end