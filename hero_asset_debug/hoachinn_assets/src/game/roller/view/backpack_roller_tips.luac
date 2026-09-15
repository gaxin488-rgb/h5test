-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
BackpackRollerTips = BackpackRollerTips or BaseClass(BaseView)
local table_insert = table.insert
local jinqi_controller = RollerController:getInstance()

function BackpackRollerTips:__init()
    -- self.btn_junp = 0
    self.ctrl = BackpackController:getInstance()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "roller/backpack_roller_tips"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }
    self.star_list = {}
    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.btn_list = {}
    self.config = Config.CityData.data_base
end

function BackpackRollerTips:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")

    self.container = self.main_panel:getChildByName("container")
    self.container_init_size = self.container:getContentSize()

    -- 基础属性,名字,类型和评分等
    self.base_panel = self.container:getChildByName("base_panel")
    self.goods_item =  BackPackItem.new(true,true,nil,0.95,false)
    self.goods_item:setPosition(cc.p(98,60))
    self.base_panel:addChild(self.goods_item)
    self.name = self.base_panel:getChildByName("name")
    self.name:ignoreContentAdaptWithSize(true)
    -- self.name:setTextAreaSize(cc.size(270, 0))
    -- setTextSpacing(self.name, -8)
    self.equip_type = self.base_panel:getChildByName("equip_type")
    self.equip_type:ignoreContentAdaptWithSize(true)
    -- self.equip_type:setTextAreaSize(cc.size(285, 0))
    -- setTextSpacing(self.equip_type, -8)
    
    self.equip_type = self.base_panel:getChildByName("equip_type")
    self.bar = self.base_panel:getChildByName("bar")
    self.bar:setScale9Enabled(true)
    self.bar_num = self.base_panel:getChildByName("bar_num")
    local star_layer = self.base_panel:getChildByName("star_layer")
    self.star_layer = star_layer

    self.get_path = self.container:getChildByName("get_path")
    local text_2 = self.get_path:getChildByName("Text_2")
    text_2:setString(TI18N("语言_c_970"))
    self.goto_btn = self.get_path:getChildByName("goto")
    self.goto_btn:setPositionX(text_2:getPositionX() + text_2:getContentSize().width + 3 + self.goto_btn:getContentSize().width/2)

    -- 作用描述
    self.usedesc_panel = self.container:getChildByName("usedesc_panel")
    self.use_desc = self.usedesc_panel:getChildByName("desc")
    self.use_desc:ignoreContentAdaptWithSize(true)
    self.use_desc:setTextAreaSize(cc.size(546, 0))
    setTextSpacing(self.use_desc, -6)
    self.usedesc_panel_height = self.usedesc_panel:getContentSize().height

    -- 描述部分
    self.desc_panel = self.container:getChildByName("desc_panel")
    self.desc_panel_size = self.desc_panel:getContentSize()
    self.scroll_view = self.desc_panel:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
    self.scroll_size = self.scroll_view:getContentSize()
    self.desc_label = createRichLabel(22, cc.c4b(0xa1,0x97,0x8b,0xff), cc.p(0, 1), cc.p(20, 100), 8, nil, 540) 
    self.scroll_view:addChild(self.desc_label)

    -- 按钮部分
    self.close_btn = self.main_panel:getChildByName("close_btn")
end
function BackpackRollerTips:register_event()
    if self.background then 
        self.background:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                RollerController:getInstance():openRollerComTipsWindow(false)
            end
        end)
    end
    if self.close_btn then 
        self.close_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                RollerController:getInstance():openRollerComTipsWindow(false)
            end
        end)
    end

    registerButtonEventListener(self.goto_btn, function()
        if self.item_config then
            BackpackController:getInstance():openTipsSource(true, self.item_config)
            RollerController:getInstance():openRollerComTipsWindow(false)
        end
    end, true, 1)
end

--引入 setting 
--setting.is_market_place 是否宝库显示
function BackpackRollerTips:openRootWnd(item_bid,setting)
    if not item_bid then return end
    self.setting = setting or {}
    if type(item_bid) == "number" then
        local config = Config.ItemData.data_get_data(item_bid)
        if not config then return end
        self.data = config
        self.item_config = config
    else
        self.data = item_bid
        if self.data.config then
            self.item_config = self.data.config
        else
            self.item_config = item_bid
        end
    end

    --详情按钮
    local pos = self.main_panel:getContentSize().width/2
    local btn = createButton(self.main_panel,TI18N("语言_c_976"),pos,55,cc.size(129,60),PathTool.getResFrame("common","common_1017"),24,Config.ColorData.data_color4[1])
    btn:setName("show_btn")
    btn:setRichText(TI18N("语言_c_1727"))
    btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            local star,lv = jinqi_controller:getModel():getRollerMaxStarAndMaxLv(self.roller_id)
            local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.roller_id]
            local score = base_cfg.init_score
            local roller_seal_list = self:setSelectIndexData()
            local setting = {roller_id=self.roller_id,id=self.roller_id,star=star,score=score,lev=lv,roller_seal_list=roller_seal_list,open_type=FALSE}
            RollerController:getInstance():openRollerChipsTipsPreviewWindow(true, setting)
        end
    end)
    self.btn_2 = btn

    self:setBaseInfo()
end

function BackpackRollerTips:setSelectIndexData()
    local __attr = {}
    local fengyin_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal
    for k, v in pairs(fengyin_cfg) do
        local _data = {}
        _data.pos = k
        _data.lev = #v
        table.insert(__attr,_data)
    end
    return __attr
end

function BackpackRollerTips:showBtn(num)
    if self.setting.is_backpack == true then
        local pos = self.main_panel:getContentSize().width/2
        local btn = createButton(self.main_panel,TI18N("语言_c_976"),pos,55,cc.size(129,60),PathTool.getResFrame("common","common_1017"),24,Config.ColorData.data_color4[1])
        btn:setName("com_btn")
        btn:setRichText(TI18N("语言_c_1726"))
        btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                local open_status = RollerController:getInstance():getModel():checkRollerFunctionOpenStatus()
                local single_status = RollerController:getInstance():getModel():checkSingleRollerOpenStatus(self.roller_id)
                if open_status and single_status then
                    if self.is_full_lv then
                        RollerController:getInstance():openRollerMainWindow(true,1)
                    else
                        if self.is_enough then
                            RollerController:getInstance():openRollerInfoWindow(false)
                            local jinqi_data = jinqi_controller:getModel():getRollerDataById(self.roller_id)
                            if jinqi_data then
                                RollerController:getInstance():openRollerInfoWindow(true,2,self.roller_id)
                            else
                                RollerController:getInstance():sender20802(self.roller_id)
                                RollerController:getInstance():openRollerInfoWindow(true,1,self.roller_id)
                            end
                            RollerController:getInstance():openRollerComTipsWindow(false)
                        else
                            BackpackController:getInstance():openTipsSource(true, self.item_config)
                            RollerController:getInstance():openRollerComTipsWindow(false)
                        end
                    end
                else
                    message(TI18N("语言_c_1668"))
                end

            end
        end)
        self.btn_1 = btn

        if self.btn_2 then
            self.btn_1:setPositionX(424)
            self.btn_2:setPositionX(164)
        end
    end
end
--==============================--
--desc:设置基础属性
--time:2018-10-22 10:18:13
--@return 
--==============================--
function BackpackRollerTips:setBaseInfo()
    if self.data == nil or self.item_config == nil then return end
    if self.item_config.type ~= BackPackConst.item_type.ROLLER_CHIP then
        return
    end
    local data = self.data

    self.goods_item:setBaseData(self.item_config.id)

    local quality = 0
    if self.item_config.quality >= 0 and self.item_config.quality <= 6 then
        quality = self.item_config.quality
    end
    local color = BackPackConst.quality_color[quality]
    self.name:setTextColor(color) 
    if self.item_config.name then
        -- self.name:setString(self.item_config.name)
        transformTextToShortByWidth(self.name,self.item_config.name,378)
        addEvt2showAllTextTips(self.name,self.item_config.name, 10)
    end
    if self.item_config.type_desc then
        -- self.equip_type:setString(TI18N("语言_c_1728")..self.item_config.type_desc)
        transformTextToShortByWidth(self.equip_type,self.item_config.type_desc,378)
        addEvt2showAllTextTips(self.equip_type,self.item_config.type_desc, 10)
    end
    self.equip_type:setPositionY(self.name:getPositionY() - self.name:getContentSize().height)
    self.use_desc:setString(self.item_config.use_desc or "")

    -- 描述
    self.desc_label:setString(self.item_config.desc)
    local label_size = self.desc_label:getContentSize() 

    self.item_scrollview_size = cc.size(540,0)
    local item_scrollview_height = 0
    local max_height = math.max(label_size.height+item_scrollview_height, self.scroll_size.height)

    self.scroll_view:setContentSize(cc.size(self.scroll_size.width, math.min(max_height, 120)))
    self.scroll_view:setInnerContainerSize(cc.size(self.scroll_size.width, max_height))
    self.desc_label:setPositionY(max_height)

    self:showBtn(1)
    self:setJinqiStarInfo()
    -- self:adjustContentSizeAndPos()
end

function BackpackRollerTips:setJinqiStarInfo()
    local id = self.item_config.id
    local roller_id = Config.ProhibitedScrollData.data_get_patch[id].scroll_id
    self.roller_id = roller_id
    local jinqi_data = jinqi_controller:getModel():getRollerDataById(roller_id)
    local star = 0
    if jinqi_data then --已激活
        star = jinqi_data.star
        local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[roller_id]
        local cfg = star_cfg[star]
        if cfg and cfg.cost and next(cfg.cost) then
            local cost_id = cfg.cost[1][1]
            self.cost_id = cost_id
            local cost_num = cfg.cost[1][2]
            local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
            self.bar_num:setString(own_num.."/"..cost_num)
            self.bar:setPercent(own_num/cost_num * 100)
            if self.btn_1 then
                self.btn_1:setRichText(string.format("<div fontcolor=#ffffff fontsize=24 outline=2,#6C2B00>%s</div>",TI18N("语言_c_2970")))
            end
            if own_num >= cost_num then
                self.is_enough = true
            end
        else
            self.bar_num:setString(TI18N("语言_c_4543"))
            self.bar:setPercent(100)
            if self.btn_1 then
                self.btn_1:setRichText(string.format("<div fontcolor=#ffffff fontsize=24 outline=2,#6C2B00>%s</div>",TI18N("语言_dun_aby_c_13")))
            end
            self.is_full_lv = true
        end
    else
        local cfg = Config.ProhibitedScrollData.data_get_proh_scroll[roller_id]
        local cost = cfg.cost[1]
        local item_id = cost[1]
        local need_num = cost[2]
        local own_num =  BackpackController:getInstance():getModel():getItemNumByBid(item_id)
        self.bar_num:setString(own_num.."/"..need_num)
        self.bar:setPercent(own_num/need_num * 100)
        if self.btn_1 then
            self.btn_1:setRichText(string.format("<div fontcolor=#ffffff fontsize=24 outline=2,#6C2B00>%s</div>",TI18N("语言_c_2904")))
        end
        if own_num >= need_num then
            self.is_enough = true
        end
    end
    local max_star = jinqi_controller:getModel():getMaxStarById(self.roller_id)
    self:setStarPanel(star,max_star)
end

function BackpackRollerTips:setStarPanel(star,max_star)
    local total_star_width = max_star * 25
    self.star_layer:setPositionX(234 + total_star_width/2)
    self.star_list = createOnlyStar(max_star, self.star_layer, 25, {res=PathTool.getResFrame("common","common_90011")})
    for i, v in ipairs(self.star_list) do
        v:setScale(0.5)
        setChildUnEnabled(true, v)
        if i <= star then
            setChildUnEnabled(false, v)
        end
    end
end

function BackpackRollerTips:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.goods_item then 
        self.goods_item:DeleteMe()
    end
   self.goods_item = nil
end
