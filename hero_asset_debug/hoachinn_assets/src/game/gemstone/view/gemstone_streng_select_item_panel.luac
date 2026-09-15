-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
GemstoneStrengSelectItemPanel = GemstoneStrengSelectItemPanel or BaseClass(BaseView)

function GemstoneStrengSelectItemPanel:__init()
    self.ctrl = HeroController:getInstance()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "hero/hero_high_equip_select_item_panel"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.cur_number = nil
    self.init_number = 1 --初始化是最少个数
end
local imput_number = 500 --输入最大数量
function GemstoneStrengSelectItemPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    local main_panel = self.root_wnd:getChildByName("main_panel")
    self.text_name = main_panel:getChildByName("text_name")
    self.text_name:setString("")
    self.btn_redu = main_panel:getChildByName("btn_redu")
    self.btn_add = main_panel:getChildByName("btn_add")
    self.comp_num_text = main_panel:getChildByName("comp_num")
    self.comp_num_text:setString("")
    self.btn_comp = main_panel:getChildByName("btn_comp")
    self.btn_comp_label = self.btn_comp:getChildByName("Text_1")
    self.btn_comp_label:setString(TI18N("语言_c_3"))
    self.btn_comp_label:enableOutline(Config.ColorData.data_color4[264], 2)

    main_panel:getChildByName("Text_2"):setString(TI18N("语言_c_1746"))
    --合成数字
    local comp_node = main_panel:getChildByName("comp_node")
    self.comp_number_edit = createEditBox(comp_node, PathTool.getResFrame("common", "common_1021"), cc.size(194, 41), cc.c4b(0x00,0x00,0x00,0xff), 26, cc.c4b(0x00,0x00,0x00,0xff), 26, "", nil, 6, LOADTEXT_TYPE_PLIST)
    self.comp_number_edit:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)

    local function onEditCompNumberEvent(event,sender)
        if not tolua.isnull(self.comp_num_text) then
            if event == "ended" then
                local str = sender:getText()
                sender:setText("")
                self.comp_num_text:setVisible(true)
                if str ~= "" then
                    local num = tonumber(str)
                    if num == nil then 
                        num = 0
                    end
                    if num <= 0 then
                        num = 1
                        self:setTouchEnable_Add(false)
                        self:setTouchEnable_Redu(true)
                    elseif num >= imput_number then
                        self:setTouchEnable_Add(true)
                        self:setTouchEnable_Redu(false)
                    else
                        self:setTouchEnable_Add(false)
                        self:setTouchEnable_Redu(false)
                    end
                    if num >= imput_number then
                        num = imput_number
                    end
                    self.comp_num_text:setString(num)
                    self.cur_number = num
                else
                    message(TI18N("语言_c_4363"))
                    self.comp_num_text:setString("")
                    self.cur_number = nil
                    return
                end
            elseif event == "began" then
                self.comp_num_text:setVisible(false)
            elseif event == "changed" then
            end
        end
    end
    self.comp_number_edit:registerScriptEditBoxHandler(onEditCompNumberEvent)

    self.goods_item =  BackPackItem.new(true,true,nil,1,false)
    self.goods_item:setPosition(cc.p(main_panel:getContentSize().width/2,279))
    main_panel:addChild(self.goods_item)
end

function GemstoneStrengSelectItemPanel:register_event()
    registerButtonEventListener(self.background, function()
        self:close()
    end,false, 2)

    registerButtonEventListener(self.btn_redu, function()
        if self.cur_number then
            self:touch_redu()
        end
    end,true, 1)

    registerButtonEventListener(self.btn_add, function()
        if self.cur_number then
            self:touch_add()
        end
    end,true, 1)

    registerButtonEventListener(self.btn_comp, function()
        if self.cur_number then
            GlobalEvent:getInstance():Fire(GemstoneEvent.Gem_Strong_Select_Event,{item_id = self.item_bid,num = self.cur_number})
            self:close()
        end
    end,true, 1)
end
function GemstoneStrengSelectItemPanel:touch_redu()
    self.cur_number = self.cur_number - 1
    if self.cur_number <= self.init_number then
        self:setTouchEnable_Redu(true)
        self.cur_number = self.init_number
    end
    if self.cur_number < imput_number then
        self:setTouchEnable_Add(false)
    end
    self.comp_num_text:setString(self.cur_number)
end

function GemstoneStrengSelectItemPanel:touch_add()
    self.cur_number = self.cur_number + 1
    if self.cur_number >= imput_number then
        self:setTouchEnable_Add(true)
        self.cur_number = imput_number
    end
    if self.cur_number > self.init_number then
        self:setTouchEnable_Redu(false)
    end
    self.comp_num_text:setString(self.cur_number)
end

function GemstoneStrengSelectItemPanel:setTouchEnable_Add(bool)
    setChildUnEnabled(bool,self.btn_add)
    self.btn_add:setTouchEnabled(not bool)
end
function GemstoneStrengSelectItemPanel:setTouchEnable_Redu(bool)
    setChildUnEnabled(bool,self.btn_redu)
    self.btn_redu:setTouchEnabled(not bool)
end

function GemstoneStrengSelectItemPanel:openRootWnd(item_bid, equip_data)
    if not item_bid then return end
    self.equip_data = equip_data
    self.item_bid = item_bid
    local config = Config.ItemData.data_get_data(item_bid)
    self.item_config = config
    self:setBaseInfo()
end

function GemstoneStrengSelectItemPanel:setBaseInfo()
    if self.item_config == nil then return end
    self.goods_item:setBaseData(self.item_config.id)
    local quality = 0
    if self.item_config.quality >= 0 and self.item_config.quality <= 6 then
        quality = self.item_config.quality
    end
    local color = BackPackConst.quality_color[quality]
    self.text_name:setTextColor(color) 
    self.text_name:setString(self.item_config.name)

    local item_data = BackpackController:getInstance():getModel():getItemNumByBid(self.item_config.id)
    self:checkFullLvExpStatus()
    if item_data > 0 then
        self.cur_number = 1
    else
        self.cur_number = 0
    end
    if item_data >= self.max_num then
        imput_number = self.max_num
    else
        imput_number = item_data
    end
    self.comp_num_text:setString(self.cur_number)
    if self.cur_number >= imput_number then
        self:setTouchEnable_Add(true)
    else
        self:setTouchEnable_Add(false)
    end
    if self.cur_number <=  self.cur_number then
        self:setTouchEnable_Redu(true)
    else
        self:setTouchEnable_Redu(false)
    end
end

function GemstoneStrengSelectItemPanel:checkFullLvExpStatus()
    self.max_num = BackpackController:getInstance():getModel():getItemNumByBid(self.item_config.id)
	-- self.gold_info = BackpackController:getInstance():getModel():getGoldEquipData(self.equip_data.id)
	-- local eqm_jie = self.gold_info.refine_level
    -- local equip_bid = self.equip_data.config.id
	-- local level = self.gold_info.enchant_level
	-- local enchant_exp = self.gold_info.enchant_exp
    -- local cfg = Config.PartnerGoldeqmData.data_get_eqm_refine(getNorKey(equip_bid, eqm_jie))
    -- local max_level = cfg["enchant_max_lev"]
    -- local need_exp = 0
	-- for i = level, max_level do
	-- 	local cfg_data = Config.PartnerGoldeqmData.data_get_eqm_enchant(getNorKey(equip_bid, i))
	-- 	local exp = cfg_data.exp
	-- 	need_exp = need_exp + exp
	-- end
    -- need_exp = need_exp - enchant_exp
	
    -- local exp_cfg = Config.PartnerGoldeqmData.data_get_eqm_star_exp[self.item_bid]
    -- local per_exp = exp_cfg.exp
    -- self.max_num = math.ceil(need_exp/per_exp)
end

function GemstoneStrengSelectItemPanel:checkFullSoulExpStatus()
    local cfg = Config.PartnerGoldeqmData.data_get_eqm_soul
	self.gold_info = BackpackController:getInstance():getModel():getGoldEquipData(self.equip_data.id)
	local soul_level = self.gold_info.soul_level
	local soul_exp = self.gold_info.soul_exp
    local equip_bid = self.equip_data.config.id
    local star_level = self.gold_info.star_level

    self.max_soul_level = 1
    for i = 0, 10, 1 do
        local key = getNorKey(equip_bid,i)
        local soul_cfg_item = cfg(key)
        if soul_cfg_item then
            if soul_cfg_item.star ~= 0 and soul_cfg_item.star == star_level and soul_cfg_item.lev > (self.max_soul_level) then --
                self.max_soul_level = soul_cfg_item.lev
            end
        else
            break
        end
    end
    self.max_soul_level = self.max_soul_level + 1
    local max_exp = 0
    self.max_soul_lv_cfg = {}
    for i = self.gold_info.soul_level, self.max_soul_level do
        local cfg = Config.PartnerGoldeqmData.data_get_eqm_soul(getNorKey(equip_bid,i))
        max_exp = cfg.exp + max_exp
    end
    max_exp = max_exp - soul_exp
    self.max_exp = max_exp

	local per_exp = Config.PartnerGoldeqmData.data_get_eqm_soul_exp[self.item_bid] 
    if per_exp then
        self.max_num = math.ceil(max_exp/per_exp)
    else
        self.max_num = 0
    end
end

function GemstoneStrengSelectItemPanel:close_callback()
    if self.goods_item then 
        self.goods_item:DeleteMe()
    end
    self.goods_item = nil
    self.ctrl:openHighEquipUpSelectWindow(false)
end
