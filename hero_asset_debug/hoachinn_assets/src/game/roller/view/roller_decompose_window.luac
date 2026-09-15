-- --------------------------------------------------------------------
-- (必填, 创建模块的人员)
-- @description:分解产出页面
-- --------------------------------------------------------------------
RollerDecomposeWindow = RollerDecomposeWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function RollerDecomposeWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self._list = {}
    self.layout_name = "hero/hero_high_equip_decompose_window"
end

function RollerDecomposeWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.mainContainer = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.mainContainer , 1)  

    self.tips = self.mainContainer:getChildByName("tips")
    setTextMaxWidth(self.tips, 580,-6)
    self.tips:setString(TI18N("语言_c_7365"))
    self.close_btn = self.mainContainer:getChildByName("close_btn")
    self.confirm_btn = self.mainContainer:getChildByName("confirm_btn")
    self.confirm_btn:getChildByName("label"):setString(TI18N("语言_c_2"))
    self.cancel_btn = self.mainContainer:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("语言_c_62"))
    local title_container = self.mainContainer:getChildByName("title_container")
    title_container:getChildByName("title_label"):setString(TI18N("语言_c_6148"))
    
    self.item_list = self.mainContainer:getChildByName("item_list")
	local scroll_view_size = self.item_list:getContentSize()
    local setting = {
        item_class = BackPackItem, -- 单元类
        start_x = 15, -- 第一个单元的X起点
        space_x = 30, -- x方向的间隔
        start_y = 20, -- 第一个单元的Y起点
        space_y = 30, -- y方向的间隔
        item_width = BackPackItem.Width*0.95, -- 单元的尺寸width
        item_height = BackPackItem.Height*0.95, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 4, -- 列数，作用于垂直滚动类型
        scale = 0.95
    }

    self.cell_item_scrollview = CommonScrollViewLayout.new(self.item_list,cc.p(0, 0),ScrollViewDir.vertical,ScrollViewStartPos.top,scroll_view_size,setting)
    self.cell_item_scrollview:setSwallowTouches(false)
end

function RollerDecomposeWindow:register_event()
    registerButtonEventListener(self.background, function() self:_onClickBtnClose() end ,false, 2) 
    registerButtonEventListener(self.close_btn, function() self:_onClickBtnClose() end ,true, 2) 
    registerButtonEventListener(self.confirm_btn, function() self:changeTabIndex() end ,true, 2) 
    registerButtonEventListener(self.cancel_btn, function() self:_onClickBtnClose() end ,true, 2) 
end

function RollerDecomposeWindow:_onClickBtnClose()
    controller:openRollerFenjiePreviewWindow(false)
end
function RollerDecomposeWindow:changeTabIndex()
    controller:sender20823(self.list )
    controller:openRollerFenjiePreviewWindow(false)
end

function RollerDecomposeWindow:openRootWnd(data)
    self.list = data
    local cfg = Config.ProhibitedScrollData.data_get_decompose
    local list = {}
    for k, v in pairs(self.list) do
        local id = v.id 
        local num = v.num
        local item_cfg = cfg[id]
        local gain = item_cfg.gain
        for key, val in pairs(gain) do
            local get_itemid = val[1]
            local get_num = val[2] * num
            if list[get_itemid] then
                list[get_itemid] = list[get_itemid] + get_num
            else
                list[get_itemid] = get_num
            end
        end
    end
    local arr = {}
    for k, v in pairs(list) do
        local item_id = k
        local item_num = v
        local item_cfg = Config.ItemData.data_get_data(item_id)
        local over = item_cfg.overlap
        if item_num > over then --判断是否超过堆叠上限
            table.insert(arr,{id=item_id,num=over})
            table.insert(arr,{id=item_id,num=(item_num - over)})
        else
            table.insert(arr,{id=item_id,num=item_num})
        end
    end
    -- table.insert(list,{id=get_itemid,num=get_num})
    self.cell_item_scrollview:setData(arr)
    self.cell_item_scrollview:addEndCallBack(function()
        local list = self.cell_item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)
end

function RollerDecomposeWindow:close_callback()
    if self.list_view then
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    controller:openRollerFenjiePreviewWindow(false)
end