--------------------------------------------
-- 
-- 
-- @Date    : 2019-01-16 19:09:44
-- @description    : 
		-- 宝石预览
---------------------------------

GemstonePreviewWindow = GemstonePreviewWindow or BaseClass(BaseView)

local _controller = GemstoneController:getInstance()

function GemstonePreviewWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Big  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.layout_name = "gemstone/gemstone_preview_window"
    self.tab_view_list = {}
	self.cur_index = nil
	self.tab_suit_perfix = {}
	for i = 1, 6 do
		table.insert(self.tab_suit_perfix,i)
	end
    table.sort(self.tab_suit_perfix,function(a,b) return a < b end)
end

function GemstonePreviewWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 
	local Image_17 = self.main_container:getChildByName("title_con"):getChildByName("Image_17")
    local title_label = self.main_container:getChildByName("title_con"):getChildByName("title_label")
	title_label:setChangeScaleOffWidth(-9999)
	title_label:setString(TI18N("语言_c_7129"))
	Image_17:setContentSize(cc.size(title_label:getContentSize().width + 100,63))
    self.item_goods = self.main_container:getChildByName("goods")
	self.close_btn = self.main_container:getChildByName("close_btn")
    local scroll_view_size = self.item_goods:getContentSize()
    local setting = {
        item_class = GemstonePreviewItem,      -- 单元类
        start_x = 5,                    -- 第一个单元的X起点
        space_x = 5,                   -- x方向的间隔
        start_y = 5,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 312,               -- 单元的尺寸width
        item_height = 147,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 2,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.item_goods,cc.p(0, 0),ScrollViewDir.vertical,ScrollViewStartPos.top,scroll_view_size,setting)
    self.item_scrollview:setSwallowTouches(false)
end

function GemstonePreviewWindow:createTabList()
	local tab_view = self.main_container:getChildByName("tab_view")
	tab_view:setScrollBarEnabled(false)
    local count = #self.tab_suit_perfix
    local tab_bg = tab_view:getChildByName("tab_bg")
    tab_bg:setContentSize(cc.size(GemstonePreviewTab.Width*count+10,54))
    tab_view:setInnerContainerSize(cc.size(GemstonePreviewTab.Width*count+10,63))

    for i=1,count do
    	self.tab_view_list[i] = GemstonePreviewTab.new()
    	self.tab_view_list[i]:setPosition(((i-1)*GemstonePreviewTab.Width)+55,31)
		tab_view:addChild(self.tab_view_list[i])
		self.tab_view_list[i]:setData(i,count,self.tab_suit_perfix[i])
		local function func(index)
			self:tabChangeView(index)
		end
		self.tab_view_list[i]:addCallBack(func)
    end
    self:tabChangeView(1)
end
function GemstonePreviewWindow:tabChangeView(index)
	index = index or 1
	if self.cur_index == index then return end
	if not self.tab_view_list[index] then return end

	if self.cur_tab ~= nil then
		self.cur_tab:setNormal(false)
		self.cur_tab:setSelect(true)
		self.cur_tab:setName(cc.c4b(0xcf,0xb5,0x93,0xff))
	end
	self.cur_index = index
	self.cur_tab = self.tab_view_list[self.cur_index]
	if self.cur_tab ~= nil then
		self.cur_tab:setNormal(true)
		self.cur_tab:setSelect(false)
		self.cur_tab:setName(cc.c4b(0xff,0xed,0xd6,0xff))
	end
	
	if self.tab_suit_perfix and self.tab_suit_perfix[index] then
		local list = {}
		for k,v in pairs(self.gem_data) do
			if v.pos == self.tab_suit_perfix[index] then
				local item_config = deepCopy(Config.ItemData.data_get_data(v.id))
				local goodvo = GoodsVo.New(item_config.id)
				goodvo.sort = item_config.quality
				table.insert(list,goodvo)
			end
		end
		if next(list) then
			local sort_func = SortTools.tableUpperSorter({"sort","base_id"})
			table.sort(list, sort_func)
			commonShowEmptyIcon(self.item_goods,false)
		else
			commonShowEmptyIcon(self.item_goods,true)
		end
		self.item_scrollview:setData(list)
	end
	
end
function GemstonePreviewWindow:register_event(  )
	registerButtonEventListener(self.background, function()
        self:_onClickCloseBtn()
    end,false, 2)
	registerButtonEventListener(self.close_btn, function()
        self:_onClickCloseBtn()
    end,true, 2)
end

function GemstonePreviewWindow:_onClickCloseBtn(  )
	_controller:openGemstonePreviewWindow(false)
end


function GemstonePreviewWindow:openRootWnd(  )
	self.gem_data = {}
	local cfg = Config.PartnerGemData.data_base_info
	for k,v in pairs(cfg) do
		if v.pos ~= 0 and not next(v.base_attr) and not next(v.base_skill) and v.show ~= 1 then
			table.insert(self.gem_data,v)
		end
	end
	self:createTabList()
end

function GemstonePreviewWindow:close_callback(  )
	if self.tab_view_list then
        for i,v in pairs(self.tab_view_list) do
            v:DeleteMe()
        end
        self.tab_view_list = nil
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
	self:_onClickCloseBtn()
end



------------------------------------------
GemstonePreviewTab = class("GemstonePreviewTab", function()
    return ccui.Widget:create()
end)
GemstonePreviewTab.Width = 100
GemstonePreviewTab.Height = 50
function GemstonePreviewTab:ctor()
	self:configUI()
	self:register_event()
end

function GemstonePreviewTab:configUI()
	self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("gemstone/gemstone_preview_tab"))
	self.root_wnd:setContentSize(cc.size(GemstonePreviewTab.Width,GemstonePreviewTab.Height))
    self:addChild(self.root_wnd)
    self:setTouchEnabled(true)

    self:setContentSize(cc.size(GemstonePreviewTab.Width,GemstonePreviewTab.Height))
	
	local main_container = self.root_wnd:getChildByName("main_container")
	
	self.select = main_container:getChildByName("select")
	self.normal = main_container:getChildByName("normal")
    self.normal:setVisible(false)
    self.name = main_container:getChildByName("name")
    self.name:setString("")
end
function GemstonePreviewTab:setSelect(visible)
	if self.select then
		self.select:setVisible(visible)
	end
end
function GemstonePreviewTab:setNormal(visible)
	if self.normal then
		self.normal:setVisible(visible)
	end
end
function GemstonePreviewTab:setName(color)
	if self.name then
		self.name:setTextColor(color)
	end
end

function GemstonePreviewTab:addCallBack(func)
	self.callback = func
end

function GemstonePreviewTab:register_event()
	self:addTouchEventListener(function ( sender, event_type )
		if event_type == ccui.TouchEventType.began then
			self.touch_began = sender:getTouchBeganPosition()
		elseif event_type == ccui.TouchEventType.ended then
			self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click then
            	playTabButtonSound()
            	if self.callback and self.data_index then
            		self.callback(self.data_index)
            	end
            end
		end
	end)
end

function GemstonePreviewTab:setData(index, count,data)
	self.data_index = index
	self.select:setFlippedX(false)
	self.normal:setFlippedX(false)
	if index == 1 then
		self.select:loadTexture(PathTool.getResFrame("common","common_2023"), LOADTEXT_TYPE_PLIST)
		self.select:setFlippedX(true)
		self.normal:loadTexture(PathTool.getResFrame("common","common_2021"), LOADTEXT_TYPE_PLIST)
		self.normal:setFlippedX(true)
	elseif index == count then
		self.select:loadTexture(PathTool.getResFrame("common","common_2023"), LOADTEXT_TYPE_PLIST)
		self.normal:loadTexture(PathTool.getResFrame("common","common_2021"), LOADTEXT_TYPE_PLIST)
	end
	self.select:setCapInsets(cc.rect(3,19,1,1)) 
	self.normal:setCapInsets(cc.rect(3,19,1,1)) 
	if data and data then
		self.name:setString(StringUtil.numToRoman(data))
	end
end

function GemstonePreviewTab:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end

------------------------------------------
GemstonePreviewItem = class("GemstonePreviewItem", function()
    return ccui.Widget:create()
end)
function GemstonePreviewItem:ctor()
	self.goods_item = nil
	self:configUI()
	self:register_event()
end

function GemstonePreviewItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("gemstone/gemstone_preview_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(312,147))

    local main_container = self.root_wnd:getChildByName("main_container")
    self.eqm_name = main_container:getChildByName("eqm_name")
	setTextMaxWidth(self.eqm_name,155)
    self.eqm_name:setString("")

    if not self.goods_item then
	    self.goods_item = BackPackItem.new(nil,true,nil,1,nil,true)
	    main_container:addChild(self.goods_item)
	    self.goods_item:setPosition(cc.p(73, 75))
	    self.goods_item:addCallBack(function ()
	    	if self.data then
		        _controller:openGemstoneTipsWindow(true, self.data, PartnerConst.EqmTips.other)
		    end
	    end)
	end
end

function GemstonePreviewItem:register_event()
end

function GemstonePreviewItem:setData(data)
	if not data then return end
	self.data = data
	if self.goods_item and data.base_id then
		self.goods_item:setData({data.base_id,1})
		local item_config = Config.ItemData.data_get_data(data.base_id)
		if item_config then
			self.eqm_name:setString(item_config.name)
		end
	end
end

function GemstonePreviewItem:DeleteMe()
	if self.goods_item then 
       self.goods_item:DeleteMe()
       self.goods_item = nil
    end

	self:removeAllChildren()
	self:removeFromParent()
end