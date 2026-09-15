--------------------------------------------
-- 
-- 
-- @Date    : 2018-11-12 20:45:58
-- @description    : 
		-- 宝石熔炼选择
---------------------------------
GemstoneChoseWindow = GemstoneChoseWindow or BaseClass(BaseView)

local controller = GemstoneController:getInstance()
local model = controller:getModel()
local back_controller = BackpackController:getInstance()
local back_model = back_controller:getModel()

function GemstoneChoseWindow:__init(  )
	self.win_type = WinType.Mini
	self.is_full_screen = false
    self.view_tag = ViewMgrTag.DIALOGUE_TAG

	self.layout_name = "gemstone/gemstone_chose_window"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad('bigbg', 'bigbg_3'), type = ResourcesType.single},
    }

	self.chose_num = 0
end

function GemstoneChoseWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container , 2) 

    local title_con = main_container:getChildByName("title_con")
    local title_label = title_con:getChildByName("title_label")
    title_label:setString(TI18N("语言_c_7117"))

    self.chose_label = main_container:getChildByName("chose_label")
    self.chose_label:setString(string.format(TI18N("语言_c_2972"), self.chose_num))
    self.ok_btn = main_container:getChildByName("ok_btn")
    local ok_btn_label = self.ok_btn:getChildByName("label")
    ok_btn_label:setString(TI18N("语言_c_63"))
    self.close_btn = main_container:getChildByName("close_btn")

    self.goods_con = main_container:getChildByName("goods_con")
    local bgSize = self.goods_con:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height-10)
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 15,                  -- 第一个单元的X起点
        space_x = 20,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = BackPackItem.Width,               -- 单元的尺寸width
        item_height = BackPackItem.Height,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 4,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.goods_con, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function GemstoneChoseWindow:setData( data )
	self.artifact_bid = data.type -- 合成的材料宝石品质（0表示暂无）
    self.open_max_num = data.max_num or 0
	-- self.max_num = self.open_max_num
    local max_num = 0
    local cfg = Config.PartnerGemData.data_comp[self.artifact_bid]
    if cfg then
        for key,value in pairs(cfg) do
            max_num = math.max(max_num,key)
        end
    else
        max_num = self.open_max_num
    end
    self.max_num = max_num
	self.chose_list = data.chose_list or {}
    local back_item_num = 0
    local back_id = 0
    for i,v in pairs(self.chose_list) do
        for key,value in pairs(self.chose_list) do
            if v == value and i ~= key then
                back_item_num = back_item_num + 1
                back_id = v
                break
            end
        end
    end
    if back_id == 0 then
        for key,value in pairs(self.chose_list) do
            local list = back_model:getGamPackItemById(value)
            if list and list.config.type == BackPackConst.item_type.GEMSTONE_DEBRIS then
                back_item_num = 1
                back_id = value
                break
            end
        end
    end
	self.chose_num = #self.chose_list
	self.chose_label:setString(string.format(TI18N("语言_c_2973"), self.chose_num, self.max_num))
    local list = {}
    local index = 1
    local cost_list = {}
    local all_list = {}
    local item_data = BackpackController:getInstance():getModel():getBagItemList(BackPackConst.Bag_Code.GEMSTONE)
    for k,v in pairs(item_data) do
        table.insert(all_list, v)
    end
    -- local back_data = BackpackController:getInstance():getModel():getBagItemList(BackPackConst.Bag_Code.BACKPACK)
    -- for k,v in pairs(back_data) do
    --     if v.config.type == BackPackConst.item_type.GEMSTONE_DEBRIS then
    --         table.insert(all_list, v)
    --     end
    -- end
    local cfg = Config.PartnerGemData.data_base_info
    local comp_cfg = Config.PartnerGemData.data_comp
    for key,value in pairs(comp_cfg) do
        for k,v in pairs(value) do
            for _,_v in pairs(v) do
                for _,item_id in pairs(_v.costs) do
                    table.insert(cost_list, item_id)
                end
                break
            end
            break
        end
    end
    for k,v in pairs(all_list) do
        if table.indexof(cost_list,v.config.id) then
            if cfg[v.config.id] then
                local artifact_cfg = cfg[v.config.id]
                local is_select = false
                for _,n in pairs(self.chose_list) do
                    if n == v.id then
                        if v.id == back_id then
                            if back_item_num > 0 then
                                back_item_num = back_item_num - 1
                                is_select = true
                            end
                        else
                            is_select = true
                        end
                        break
                    end
                end
                v.pos = artifact_cfg.pos
                if v.checkGemIsLock then
                    if v:checkGemIsLock() then
                        v:setGoodsAttr("showSellStatus", {status = false, select = false})
                        v:setGoodsAttr("showGemLockStatus", {status = true, select = true,fun = function()
                            message(TI18N("语言_c_7118"))
                        end})
                        v.lock_status = 0
                    else
                        v:setGoodsAttr("showSellStatus", {status = true, select = is_select})
                        v:setGoodsAttr("showGemLockStatus", {status = false, select = false})
                        v.lock_status = 1
                    end
                else
                    v:setGoodsAttr("showSellStatus", {status = true, select = is_select})
                    v:setGoodsAttr("showGemLockStatus", {status = false, select = false})
                    v.lock_status = 1
                end
                list[index] = v
                index = index+1
            else
                for i=1,v.quantity do
                    local is_select = false
                    for _,n in pairs(self.chose_list) do
                        if n == v.id then
                            if v.id == back_id then
                                if back_item_num > 0 then
                                    back_item_num = back_item_num - 1
                                    is_select = true
                                end
                            else
                                is_select = true
                            end
                            break
                        end
                    end
                    local good_vo = deepCopy(v)
                    good_vo.quantity = 1
                    good_vo.pos = 0
                    good_vo.lock_status = 1
                    good_vo:setGoodsAttr("showSellStatus", {status = true, select = is_select})
                    good_vo:setGoodsAttr("showGemLockStatus", {status = false, select = false})
                    list[index] = good_vo
                    index = index+1
                end
            end
        end
    end
    -- 品质低的放前面
    table.sort(list, SortTools.tableLowerSorter({"lock_status","quality","pos", "id"}))
    self.item_data = list
    self.item_scrollview:setData(list, nil ,nil,{showCheckBox=true, checkBoxClickCallBack = handler(self, self._onCheckBoxCallBack), adjustCheckBoxPos=cc.p(BackPackItem.Width-24, BackPackItem.Height-25)})
    if next(list) ~= nil then
        self.item_scrollview:addEndCallBack(function (  )
            local item_list = self.item_scrollview:getItemList()
            for k,item in pairs(item_list) do
                local function onClickItemCallBack(  )
					local data = item:getData()
                    if data.config.type == BackPackConst.item_type.GEMSTONE then
                        local bid = data.bid or data.base_id or data.id or data[1]
                        local setting = {}
                        setting.data = bid
                        setting.gem_list = data
                        if data.main_attr and next(data.main_attr) then
                            controller:openGemstoneTipsWindow(true,setting)
                        end
                    else
                        TipsManager:getInstance():showGoodsTips(data.config)
                    end
                end
                item:addCallBack(onClickItemCallBack)
            end
        end)
        commonShowEmptyIcon(self.main_container, false)
    else
        local setting = {}
        setting.text = TI18N("语言_c_7119")
        setting.label_color = Config.ColorData.data_color4[175]
        setting.pos = cc.p(self.main_container:getContentSize().width/2, self.main_container:getContentSize().height/2+30)
        setting.offset_y = 0
        setting.font_size = 24
        commonShowEmptyIcon(self.main_container, true, setting)
    end
end

function GemstoneChoseWindow:_onCheckBoxCallBack( flag, itemnode )
    local item_vo = itemnode:getData()
    if flag == true then
        if not self:checkItemIsCanChose(item_vo.config.id) then
            item_vo:setGoodsAttr("showSellStatus", {status = true, select = false})
            itemnode:setData(item_vo)
            message(TI18N("语言_c_7186"))
            return
        elseif self.chose_num >= self.max_num then
            item_vo:setGoodsAttr("showSellStatus", {status = true, select = false})
            itemnode:setData(item_vo)
            message(TI18N("语言_c_2976"))
            return
        end
    end

	if flag == true then
		self.chose_num = self.chose_num + 1
        local cfg = Config.PartnerGemData.data_comp
        if cfg then
            for key,value in pairs(cfg) do
                for _,_value in pairs(value) do
                    for _,v in pairs(_value) do
                        for _,_v in pairs(v.costs) do
                            if item_vo.config.id == _v then
                                self.artifact_bid = v.type
                            end
                        end
                        break
                    end
                    break
                end
            end
        end
	else
		self.chose_num = self.chose_num - 1
        if self.chose_num <= 0 then
            self.artifact_bid = 0
        end
	end
    local max_num = 0
    local cfg = Config.PartnerGemData.data_comp[self.artifact_bid]
    if cfg then
        for key,value in pairs(cfg) do
            max_num = math.max(max_num,key)
        end
    else
        max_num = self.open_max_num
    end
    self.max_num = max_num
	self.chose_label:setString(string.format(TI18N("语言_c_2973"), self.chose_num, self.max_num))
end

-- 检测是否可以选择
function GemstoneChoseWindow:checkItemIsCanChose( bid )
    local is_can_chose = false
    if self.artifact_bid and self.artifact_bid ~= 0 then
        local cfg = Config.PartnerGemData.data_comp[self.artifact_bid]
        if cfg then
            for key,value in pairs(cfg) do
                for k,v in pairs(value) do
                    for _,_v in pairs(v.costs) do
                        if bid == _v then
                            is_can_chose = true
                        end
                    end
                    break
                end
                break
            end
        end
    else
        is_can_chose = true
    end
    return is_can_chose
end

function GemstoneChoseWindow:register_event(  )
    registerButtonEventListener(self.background, handler(self, self._onClickBtnClose), false, 2)
	registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose), false, 2)
	registerButtonEventListener(self.ok_btn, handler(self, self._onClickBtnOk))
end

function GemstoneChoseWindow:_onClickBtnClose(  )
	controller:openGemstoneChoseWindow(false)
end

function GemstoneChoseWindow:_onClickBtnOk(  )
	local item_list = {}
	for k,v in pairs(self.item_data) do
		if v.showSellStatus ~= nil and v.showSellStatus.select == true then
            table.insert(item_list, v.id)
        end
	end
    local function sureToChoseFunc(  )
        GlobalEvent:getInstance():Fire(GemstoneEvent.Artifact_Chose_Event,self.artifact_bid, item_list)
        controller:openGemstoneChoseWindow(false)
    end
    sureToChoseFunc()
end

function GemstoneChoseWindow:openRootWnd( data )
	self:setData(data)
end

function GemstoneChoseWindow:close_callback(  )
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.item_data and next(self.item_data) ~= nil then
        for i,v in pairs(self.item_data) do
            v:setGoodsAttr("showSellStatus", {status = false, select = false})
            v:setGoodsAttr("showGemLockStatus", {status = false, select = false})
        end
    end
	controller:openGemstoneChoseWindow(false)
end