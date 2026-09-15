-- --------------------------------------------------------------------
-- (必填, 创建模块的人员)
-- @description: 禁器强化页面
-- --------------------------------------------------------------------
RollerTalentActiveNormalWindow = RollerTalentActiveNormalWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()

local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function RollerTalentActiveNormalWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.attr_list = {}
    self.layout_name = "roller/roller_talent_active_normal_window"
end

function RollerTalentActiveNormalWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.mainContainer = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.mainContainer , 1)

    self.item = self.root_wnd:getChildByName("item")

    self.clsoe_btn = self.mainContainer:getChildByName("clsoe_btn")
    self.up_panel = self.mainContainer:getChildByName("up_panel")

    self.skill_node = self.up_panel:getChildByName("skill_node")
    local get_btn = self.skill_node:getChildByName("get_btn")
    local lv_bg = get_btn:getChildByName("Image")
    local label = get_btn:getChildByName("label")
    self.skill_node.get_btn = get_btn
    self.skill_node.lv_bg = lv_bg
    self.skill_node.label = label

    self.img_title = self.up_panel:getChildByName("img_title")
    self.title = self.up_panel:getChildByName("title")
    self.title:setString(TI18N("语言_c_6903"))
    moveTextBg(self.title,self.img_title,80,250)

    self.max_tips = self.up_panel:getChildByName("max_tip")
    self.max_tips:setString(TI18N("语言_c_1984"))
    self.max_tips:setVisible(false)

    self.cond_txt = self.up_panel:getChildByName("cond_txt")
    self.cond_txt:setString("")

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
        item_width = 130, -- 单元的尺寸width
        item_height = 155, -- 单元的尺寸height
        row = 1, -- 行数，作用于水平滚动类型
        col = 0, -- 列数，作用于垂直滚动类型
        scale = 0.9,
        -- is_center = true
    }
    if not self.item_scrollview  then
        self.item_scrollview = CommonScrollViewLayout.new(self.eff_list, cc.p(0, 0), ScrollViewDir.horizontal,ScrollViewStartPos.top, scroll_view_size, setting)
    end

    local tip = self.up_panel:getChildByName("tip1")
    tip:setString(TI18N("语言_c_7220"))
    self.cancel_btn = self.up_panel:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("语言_c_2904"))
    self.tip1 = self.up_panel:getChildByName("tip2")
    self.tip1:setString(TI18N("语言_c_7221"))
end

function RollerTalentActiveNormalWindow:register_event()
    registerButtonEventListener(self.background, function() self:_onClickBtnClose() end ,false, 2)
    registerButtonEventListener(self.clsoe_btn, function() self:_onClickBtnClose() end ,true, 2)
    registerButtonEventListener(self.cancel_btn, function() self:changeTabIndex() end ,true, 2)
end

function RollerTalentActiveNormalWindow:_onClickBtnClose()
    controller:openRollerTalentNormalActiveWindow(false)
end
function RollerTalentActiveNormalWindow:changeTabIndex()
    controller:sender20821(self.talent_id)
end

function RollerTalentActiveNormalWindow:openRootWnd(id)
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

    self.skill_node.label:setString(string_format(TI18N("语言_c_7208"),step,lv))
    self.skill_node.get_btn:loadTexture(PathTool.getResFrame("scroll_talent",RollerConst.TalentIcon[step]), LOADTEXT_TYPE_PLIST)

    local attrs = talent_cfg.attrs
    local _next_list = {}
    for k, v in pairs(attrs) do
        local key = v[1]
        local num = v[2]
        if _next_list[key] then
            _next_list[key] = _next_list[key] + num
        else
            _next_list[key] = num
        end
    end
    local next_list = {}
    for i, v in pairs(_next_list) do
        table.insert(next_list, {i,v})
    end

    local attr_num = #next_list
    local scroller_size = self.scroller_view:getContentSize()
    local total_height = math.max(55*attr_num, scroller_size.height)
    for i = 1, attr_num do
        if self.attr_list[i] == nil then
            self.attr_list[i] = self:createAttrItem(self.scroller_view)
        end
        local next_res, next_attr_name, next_attr_val
        if next_list[i] and next(next_list[i]) then
            next_res, next_attr_name, next_attr_val = commonGetAttrInfoByKeyValue(next_list[i][1], next_list[i][2])
        end
        local res = next_res
        local attr_name = next_attr_name
        self.attr_list[i].attr_img1:loadTexture(res, LOADTEXT_TYPE_PLIST)
        self.attr_list[i].attr1:setString(attr_name)
        self.attr_list[i].attr2:setString(next_attr_val)

        local _x = 310
        local _y = total_height - (i-1)*55
        self.attr_list[i].layer:setPosition(cc.p(_x,_y))
    end

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

function RollerTalentActiveNormalWindow:createAttrItem(parent)
    local item = {}
	local layer = ccui.Layout:create()
    layer:setAnchorPoint(cc.p(0.5, 1))
    layer:setContentSize(cc.size(620,40))
    parent:addChild(layer)

	local skill_item = self.item:clone()
    layer:addChild(skill_item)
    skill_item:setPositionX(305)
    skill_item:setPositionY(20)

    local attr_img1 = skill_item:getChildByName("attr_img1")
    local attr1 = skill_item:getChildByName("attr1")
    local attr2 = skill_item:getChildByName("attr2")

    item.layer = layer
    item.attr_img1 = attr_img1
    item.attr1 = attr1
    item.attr2 = attr2
    return item
end

function RollerTalentActiveNormalWindow:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    controller:openRollerTalentNormalActiveWindow(false)
end