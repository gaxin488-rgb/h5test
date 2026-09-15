--****************
--共鸣属性总览
--****************
RollerTalentToattrOverview = RollerTalentToattrOverview or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()

local table_insert = table.insert
function RollerTalentToattrOverview:__init()
    self.is_full_screen = true
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG

    self.show_attr_list = {}
	self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("activity", "activity"), type = ResourcesType.plist},
	}
	self.layout_name = "roller/roller_talent_toattr_overview"
end

function RollerTalentToattrOverview:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

    self.item = self.root_wnd:getChildByName("item")

	local main_panel = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(main_panel, 1)

    self.Image_1 = main_panel:getChildByName("Image_1")
    self.Image_2 = main_panel:getChildByName("Image_2")
    self.title = main_panel:getChildByName("title")
    self.title:setString(TI18N("语言_c_7203"))
    self.des = main_panel:getChildByName("des")
    self.tips = main_panel:getChildByName("tips")
    self.tips:setString(TI18N("语言_c_7204"))

	self.baseattr_panel = main_panel:getChildByName("baseattr_panel")
    self.scrollView = self.baseattr_panel:getChildByName("scrollView")
    self.scrollView:setScrollBarEnabled(false)
    -- if not self.list_view then
    --     local scroll_view_size = self.baseattr_panel:getContentSize()
    --     local setting = {
    --         start_x = 24,                  -- 第一个单元的X起点
    --         space_x = 0,                    -- x方向的间隔
    --         start_y = 5,                    -- 第一个单元的Y起点
    --         space_y = 5,                   -- y方向的间隔
    --         col = 1,                         -- 列数，作用于垂直滚动类型
    --         item_width = 522,               -- 单元的尺寸width
    --         item_height = 34,              -- 单元的尺寸height
    --         -- row = 1,                        -- 行数，作用于水平滚动类型
    --         need_dynamic = true
    --     }
    --     self.list_view = CommonScrollViewSingleLayout.new(self.baseattr_panel, cc.p(scroll_view_size.width * 0.5, scroll_view_size.height * 0.5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0.5,0.5))
    --     self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    --     self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    --     self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    -- end
end
function RollerTalentToattrOverview:createNewCell()
    local cell = RollerTalentToattrOverviewItem.new()
    return cell
end

function RollerTalentToattrOverview:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

function RollerTalentToattrOverview:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.show_list[index]
    cell:setExtralData(self.item)
    if self.show_list[index + 1] then
        cell:setNextData(self.show_list[index + 1])
    end
    cell:setData(self.roller_id,hero_vo)
    return cell:getContentSize().height
end

function RollerTalentToattrOverview:openRootWnd(id)
    self.roller_id = id
    self:setData()
end

function RollerTalentToattrOverview:setData()
    --[350] = {level=350, attrs={{'hp_max_per',40},{'atk_per',20},{'def_hp_hurt',10},{'def_atk_hurt',10}}, quality=5},
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal_resonate
    local roller_Cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.roller_id]
    local quality = roller_Cfg.quality

    self.show_list = {}
    for k, v in pairs(cfg[quality]) do
        table.insert(self.show_list,v)
    end
    local function sortFunc( objA, objB )
		return objA.level < objB.level
	end
	table.sort(self.show_list, sortFunc)

    local s_height = 430
    local temp_height = 0
    for i, v in ipairs(self.show_list) do
        local item = self.show_attr_list[i]
        if not item then
            item = self:createNewCell()
            self.scrollView:addChild(item)
            self.show_attr_list[i] = item
        end
        local _height = self:updateCellByIndex(item,i)
        temp_height = temp_height + _height + 5
    end
    local s_height = math.max(temp_height,s_height)
    self.scrollView:setInnerContainerSize(cc.size(570, s_height))

    for i, v in ipairs(self.show_attr_list) do
        v:setPositionX(285)
        v:setPositionY(s_height)
        local _height = v:getContentSize().height
        s_height = s_height - _height - 5
    end

    local total_lv = model:getAllFengyinLvById(self.roller_id)
    local max_lv = model:getMaxFengyinLv(self.roller_id)
    self.des:setString(string.format(TI18N("语言_c_7205"), total_lv,max_lv))
end

function RollerTalentToattrOverview:register_event()
	registerButtonEventListener(self.background, function ()
		controller:openRollerTalentToattrOverviewWindow(false)
	end, false, 2)
end

function RollerTalentToattrOverview:close_callback()
	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end
	controller:openRollerTalentToattrOverviewWindow(false)
end

-------------------@ item
RollerTalentToattrOverviewItem =
    class(
    "RollerTalentToattrOverviewItem",
    function()
        return ccui.Widget:create()
    end
)

function RollerTalentToattrOverviewItem:ctor()
    self.attr_item = {}
end

function RollerTalentToattrOverviewItem:registerEvent()
end
function RollerTalentToattrOverviewItem:setExtralData(node)
    if not tolua.isnull(node) and self.root_wnd == nil then
		self.is_completed = true
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)

		self.root_wnd = node:clone()
		self.root_wnd:setAnchorPoint(0.5, 0)
		self.root_wnd:setPosition(size.width * 0.5, 0)
		self:addChild(self.root_wnd)
		self.root_wnd:setVisible(true)

        self.Image_19 = self.root_wnd:getChildByName("Image_19")
        self.lv = self.root_wnd:getChildByName("lv")
        self.attr_icon1 = self.root_wnd:getChildByName("attr_icon1")
        self.attr_icon1:ignoreContentAdaptWithSize(true)
        self.attr_icon2 = self.root_wnd:getChildByName("attr_icon2")
        self.attr_icon2:ignoreContentAdaptWithSize(true)
        self.attr1 = self.root_wnd:getChildByName("attr1")
        self.attr2 = self.root_wnd:getChildByName("attr2")

		self:registerEvent()
	end
end

function RollerTalentToattrOverviewItem:setData(roller_id,data)
    -- [10] = {level=10, attrs={{'hp_max',1683},{'atk',140}}},
    if not data or not roller_id then
        return
    end
    local roller_data = model:getRollerDataById(roller_id)
    local seal = roller_data.seal
    local lv = data.level
    local font_color =  cc.c3b(0xba,0xb0,0xa5)
    if lv <= seal then
        if self.next_data then
            if self.next_data.level > seal then
                self.lv:setTextColor(cc.c4b(0x00,0x9f,0x00,0xff))
                font_color =cc.c3b(0x00,0x9f,0x00)
            end
        else
            self.lv:setTextColor(cc.c4b(0x00,0x9f,0x00,0xff))
            font_color =cc.c3b(0x00,0x9f,0x00)
        end
    else
        self.lv:setTextColor(cc.c4b(0xba,0xb0,0xa5,0xff))
        font_color = cc.c3b(0xba,0xb0,0xa5)
    end
    self.lv:setString(string.format(TI18N("语言_c_465"), lv))

    local line_num = math.ceil(#data.attrs/1)
    local size = cc.size(522, line_num * 36)
    self:setAnchorPoint(cc.p(0.5, 1))
    self:setContentSize(size)
    self.Image_19:setContentSize(size)
    self.root_wnd:setPosition(size.width * 0.5, 0)
    self.lv:setPositionY(size.height - 18)

    if self.attr_item and next(self.attr_item) then
        for i, v in ipairs(self.attr_item) do
            v:setVisible(false)
        end
    end
    for i, v in ipairs(data.attrs) do
        if not self.attr_item[i] then
            self.attr_item[i] = createRichLabel(22, cc.c4b(0xba, 0xb0, 0xa5, 0xff), cc.p(0,0.5), cc.p(160, 17))
            self.root_wnd:addChild(self.attr_item[i])
        end
        local next_res, next_attr_name, next_attr_val = commonGetAttrInfoByKeyValue(v[1], v[2])
        local str = string.format("<img src=%s visible=true scale=1 /> %s %s",next_res,next_attr_name,next_attr_val) 
        self.attr_item[i]:setFontColor(font_color)
        self.attr_item[i]:setString(str)
        local posx = 160 --+ (i-1)%2 * 180
        local posy = size.height - 18 - (i-1)*36 --math.floor((i-1)/2)*36
        self.attr_item[i]:setPosition(posx, posy)
    end
end

function RollerTalentToattrOverviewItem:setNextData(data)
    self.next_data = data
end
function RollerTalentToattrOverviewItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end
