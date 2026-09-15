----------------------------
-- @Description:宝石羁绊装备主界面
----------------------------
GemstoneEquipPanel = class( "GemstoneEquipPanel",
    function()
        return ccui.Widget:create()
    end
)

local controller = GemstoneController:getInstance()
local model = controller:getModel()
local hero_controller = HeroController:getInstance()
local hero_model = hero_controller:getModel()

function GemstoneEquipPanel:addToParent( status )
	status = status or false
    self:setVisible(status)
end
function GemstoneEquipPanel:ctor(hero_vo)
    self.hero_vo = hero_vo
    self.kuang_list = {} --顶部6个位置边框
    self.quality_list = {} --顶部6个品质球
    self.pos_node_list = {} --顶部6个宝石icon
    self.skill_list = {} --顶部3个宝石技能icon
    self.attr_list = {} --忍者宝石加成

    self:loadResources()
end
function GemstoneEquipPanel:loadResources()
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("engraved", "engraved"), type = ResourcesType.plist},
    }
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(
        self.res_list,
        function()
            if self.configUI then
                self:configUI()
            end
            if self.register_event then
                self:register_event()
            end
        end
    )
end

function GemstoneEquipPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("gemstone/gemstone_equip_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.container_size = self.main_container:getContentSize()
    self.top_bg = self.main_container:getChildByName("top_bg")
    self.remove_btn = self.main_container:getChildByName("remove_btn")
    self.remove_txt = self.remove_btn:getChildByName("label")
    self.remove_txt:setString(TI18N("语言_c_3033"))
    self.pos_banner = self.main_container:getChildByName("pos_banner")
    for i = 1, 6 do
        self.kuang_list[i] = self.pos_banner:getChildByName("kuang_" .. i)
        self.kuang_list[i]:setLocalZOrder(6+i)
        self.kuang_list[i].index = i
        self.kuang_list[i].star_con = ccui.Widget:create()
        self.kuang_list[i].star_con:setZOrder(3)
        self.kuang_list[i].star_con:setPosition(cc.p(59,10))
        self.kuang_list[i].star_con:setSwallowTouches(false)
        self.kuang_list[i]:addChild(self.kuang_list[i].star_con)
        local txt = self.kuang_list[i]:getChildByName("pos_txt")
        txt:setString(StringUtil.numToRoman(i).." ")
        self.quality_list[i] = self.pos_banner:getChildByName("quality_" .. i)
        self.quality_list[i]:setVisible(false)
        self.pos_node_list[i] = BackPackItem.new(false, true, false, 0.8, false)
        self.pos_node_list[i]:setLocalZOrder(i)
        self.pos_node_list[i]:showArtifactLock(true)
        self.pos_banner:addChild(self.pos_node_list[i])
        self.pos_node_list[i]:setPosition(cc.p(self.kuang_list[i]:getPositionX(),self.kuang_list[i]:getPositionY()))
    end
    self.hero_bg = self.pos_banner:getChildByName("hero_bg")
    self.hero_icon = self.pos_banner:getChildByName("hero_icon")
    for i = 1, 4 do
        self.skill_list[i] = self.pos_banner:getChildByName("skill_" .. i)
        setChildUnEnabled(true,self.skill_list[i])
    end
    self.attr_panel = self.main_container:getChildByName("attr_panel")
    self.attr_bg = self.attr_panel:getChildByName("attr_bg")
    self.tip_panel = self.attr_panel:getChildByName("tip_panel")
    self.tip_hero_bg = self.tip_panel:getChildByName("tip_hero_bg")
    self.tip_hero = self.tip_panel:getChildByName("tip_hero")
    self.skill_name = self.tip_panel:getChildByName("skill_name")
    setTextMaxWidth(self.skill_name,200)
    self.skill_name:setString("")
    self.skill_tips = self.tip_panel:getChildByName("skill_tips")
    setTextMaxWidth(self.skill_tips,500,-6)
    self.left_line = self.attr_panel:getChildByName("left_line")
    self.title_bg = self.attr_panel:getChildByName("title_bg")
    self.attr_title = self.attr_panel:getChildByName("attr_title")
    self.attr_title:setString(TI18N("语言_c_7120"))
    self.right_line = self.attr_panel:getChildByName("right_line")
    autoSizeTitleBg(self.attr_title,self.title_bg,60,215)
	setTextTweenBg(self.title_bg,self.left_line,self.right_line,nil,20,true)
    self.no_img = self.attr_panel:getChildByName("no_img")
    self.no_tip_bg = self.attr_panel:getChildByName("no_tip_bg")
    self.no_img:setVisible(false)
    self.no_tip_bg:setVisible(false)
    self.np_tip = self.no_tip_bg:getChildByName("np_tip")
    self.np_tip:setChangeScaleOffWidth(-9999)
    self.np_tip:setString(TI18N("语言_c_7148"))
    local _w = math.max(self.no_tip_bg:getContentSize().width,self.np_tip:getContentSize().width+50)
    local _h = math.max(self.no_tip_bg:getContentSize().height,self.np_tip:getContentSize().height+30)
    self.no_tip_bg:setContentSize(cc.size(_w,_h))
    self.np_tip:setPosition(cc.p(_w/2+10,_h/2))
    self.attr_scroll = self.attr_panel:getChildByName("attr_scroll")
    self.attr_scroll:setScrollBarEnabled(false)
    self.help_btn = self.main_container:getChildByName("help_btn")
    self.resonance_btn = self.main_container:getChildByName("resonance_btn")
    self.resonance_txt = self.resonance_btn:getChildByName("label")
    self.resonance_txt:setChangeScaleOffWidth(-9999)
    setTextMaxWidth(self.resonance_txt,100,-8)
    self.resonance_txt:setString(TI18N("语言_par_gem_help_1_05"))
    self.bag_btn = self.main_container:getChildByName("bag_btn")
    self.bag_txt = self.bag_btn:getChildByName("bag_txt")
    setTextMaxWidth(self.bag_txt,100,-8)
    self.bag_txt:setString(TI18N("语言_c_7116"))
    self.preview_btn = self.main_container:getChildByName("preview_btn")
    self.preview_txt = self.preview_btn:getChildByName("preview_txt")
    setTextMaxWidth(self.preview_txt,100,-8)
    self.preview_txt:setString(TI18N("语言_c_7137"))
    self.reset_btn = self.main_container:getChildByName("reset_btn")
    self.reset_txt = self.reset_btn:getChildByName("reset_txt")
    setTextMaxWidth(self.reset_txt,100,-8)
    self.reset_txt:setString(TI18N("语言_c_5330"))
    self:adaptationScreen()
    self:setData()
end

function GemstoneEquipPanel:updatePageData(hero_vo)
    self.hero_vo = hero_vo
    self:setData()
end

--设置适配屏幕
function GemstoneEquipPanel:adaptationScreen()
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)
    local left_x = display.getLeft(self.main_container)
    local right_x = display.getRight(self.main_container)

    -- local tab_y = self.pos_banner:getPositionY()
    -- self.pos_banner:setPositionY(top_y - (self.container_size.height - tab_y))
    local tab_y = self.help_btn:getPositionY()
    self.help_btn:setPositionY(top_y - (self.container_size.height - tab_y))
    local tab_y = self.bag_btn:getPositionY()
    self.bag_btn:setPositionY(top_y - (self.container_size.height - tab_y))
    local tab_y = self.preview_btn:getPositionY()
    self.preview_btn:setPositionY(top_y - (self.container_size.height - tab_y))
    local tab_y = self.reset_btn:getPositionY()
    self.reset_btn:setPositionY(top_y - (self.container_size.height - tab_y))
    -- local tab_y = self.resonance_btn:getPositionY()
    -- self.resonance_btn:setPositionY(top_y - (self.container_size.height - tab_y))
    -- local tab_y = self.top_bg:getPositionY()
    -- self.top_bg:setPositionY(top_y - (self.container_size.height - tab_y))
    -- local attr_panel_y = self.attr_panel:getPositionY()
    -- self.attr_panel:setPositionY(bottom_y + attr_panel_y)
    local resonance_btn_y = self.resonance_btn:getPositionY()
    self.resonance_btn:setPositionY(bottom_y + resonance_btn_y)
end
--刷新顶部6个槽位红点
function GemstoneEquipPanel:updatePosRed()
    local config = Config.PartnerGemData.data_lv_info
    for k, v in pairs(self.kuang_list) do
        local pos = v.index
        local status = false
        if config and config[pos] and config[pos][1] and self.hero_vo.star >= config[pos][1].need_star then
            status = model:getGemEquipOneRed(self.hero_vo.partner_id, pos)
        end
        if not status then
            local list = model:getOneGemstoneInfo(self.hero_vo.partner_id, pos)
            if list and next(list) and list.item_bid and list.item_bid ~= 0 then
                local cfg = Config.PartnerGemData.data_lv_info[pos]
                if cfg and list.lv < tableLen(cfg) then
                    status = model:getGemStrengOneRed(self.hero_vo.partner_id, pos)
                end
            end
        end
        addRedPointToNodeByStatus(v,status,8,8)
    end
end
function GemstoneEquipPanel:setData()
    self:updatePosIcon()
    self:updateResonance()
    self:updateAttrPanel()
    self:updatePosRed()
end
--刷新顶部6个槽位
function GemstoneEquipPanel:updatePosIcon()
    for k, v in pairs(self.quality_list) do
        v:setVisible(false)
    end
    for key, value in ipairs(self.pos_node_list) do
        self.kuang_list[key].star_setting = model:createStar(0,self.kuang_list[key].star_con,self.kuang_list[key].star_setting)
        local _type = 0 --0未解锁 1未装备 2已装备
        local cfg = Config.PartnerGemData.data_lv_info[key]
        if cfg then
            if self.hero_vo.star >= cfg[1].need_star then--已解锁
                value:showArtifactLock(false)
                local data = model:getOneGemstoneInfo(self.hero_vo.partner_id, key)
                if data then --已装备
                    local item_cfg = Config.ItemData.data_get_data(data.item_bid)
                    if data.lv then
                        local pos_cfg = cfg[data.lv]
                        if pos_cfg then
                            local eqm_star = 0
                            local gem_cfg = Config.PartnerGemData.data_base_info[data.item_bid]
                            if gem_cfg and gem_cfg.star and gem_cfg.star ~= 0 then
                                eqm_star = gem_cfg.star
                            end
                            self.kuang_list[key].star_setting = model:createStar(eqm_star,self.kuang_list[key].star_con,self.kuang_list[key].star_setting)
                        end
                    end
                    if item_cfg then
                        value:setData(item_cfg)
                        value:showGemPos(false)
                        value:showAddIcon(false)
                        value:setEquipJie(false)
                        local lock_status = false
                        if data.extra and next(data.extra) then
                            for k, v in pairs(data.extra) do
                                if v.extra_k == 1 then
                                    lock_status = v.extra_v == 1
                                    break
                                end
                            end
                        end
                        if lock_status then
                            value:showGemLockStatus(true,true,function()
                                GemstoneController:getInstance():sender22810(self.hero_vo.partner_id,data.pos,0)
                            end,cc.p(25,95))
                        else
                            value:showGemLockStatus(false)
                        end
                        loadSpriteTexture(self.quality_list[key], PathTool.getResFrame("gem", "gem_pic_07_0"..item_cfg.quality), LOADTEXT_TYPE_PLIST)
                        self.quality_list[key]:setVisible(true)
                        _type = 2
                    else
                        value:setData()
                        value:showAddIcon(true)
                        value:showGemLockStatus(false)
                        _type = 1
                    end
                else--未装备
                    value:setData()
                    value:showAddIcon(true)
                    value:showGemLockStatus(false)
                    _type = 1
                end
            else --未解锁
                value:setData()
                value:showAddIcon(false)
                value:showArtifactLock(true)
                value:showGemLockStatus(false)
                _type = 0
            end
        else
            value:setData()
            value:showAddIcon(false)
            value:showArtifactLock(true)
            value:showGemLockStatus(false)
            _type = 0
        end
        local back = function()
            if _type == 0 then --未解锁
                if cfg then
                    message(string.format(TI18N("语言_c_6318"),cfg[1].need_star))
                else
                    message(TI18N("语言_c_1891"))
                end
            elseif _type == 1 then --未装备
                controller:openGemstoneEquipWindow(true,self.hero_vo.partner_id,key)
            elseif _type == 2 then --已装备
                local setting = {}
                local data = model:getOneGemstoneInfo(self.hero_vo.partner_id, key)
                setting.data = data.item_bid
                setting.pos_list = data
                setting.pid = self.hero_vo.partner_id
                setting.is_equip = true
                controller:openGemstoneTipsWindow(true,setting)
            end
        end
        value:addCallBack(back)
    end
    
end
--设置中间忍者资源
function GemstoneEquipPanel:updateHeroIcon()
    local cfg = Config.PartnerGemData.data_skill2[hero_model:getSelfConvertStaBid(self.hero_vo.bid)] or {}
    local icon_img = ""
    for k, v in pairs(cfg) do
        icon_img = v.icon1
        break
    end
    local res = PathTool.getPlistImgForDownLoad("gem", icon_img ,false)
    loadSpriteTexture(self.hero_icon, res, LOADTEXT_TYPE)
end
--刷新忍者共鸣技能显示
function GemstoneEquipPanel:updateResonance()
    self:updateHeroIcon()
    for i=1,#self.skill_list do
        setChildUnEnabled(true,self.skill_list[i])
    end
    local cfg = Config.PartnerGemData.data_skill2[hero_model:getSelfConvertStaBid(self.hero_vo.bid)] or {}
    self.resonance_cfg = {}
	for i,v in pairs(cfg) do
		table.insert(self.resonance_cfg, v)
	end
    local sort_func = SortTools.tableCommonSorter({{"quality", false},{"num", false}})
	table.sort(self.resonance_cfg, sort_func)
    local num = 0
    for i=1,#self.resonance_cfg do
        local status = model:getResonanceIsOpen(self.hero_vo.partner_id,self.resonance_cfg[i].desc)
        setChildUnEnabled(not status,self.skill_list[i])
        if status then
            num = i
        end
    end
    if self.resonance_cfg[num+1] then
        self.tip_panel:setVisible(true)
        local icon_img = self.resonance_cfg[num+1].icon1
        local res = PathTool.getPlistImgForDownLoad("gem", icon_img ,false)
        loadSpriteTexture(self.tip_hero, res, LOADTEXT_TYPE)
        local quality_name = BackPackConst.quality_name[self.resonance_cfg[num+1].quality]
        self.skill_tips:setString(LangStringFormat(self.resonance_cfg[num+1].desc3,self.resonance_cfg[num+1].num,quality_name))
        local skill_cfg = Config.SkillData.data_get_skill(self.resonance_cfg[num+1].desc)
        if skill_cfg then
            self.skill_cfg = skill_cfg
            self.skill_name:setString(skill_cfg.name)
        end
    else
        self.tip_panel:setVisible(false)
    end
end
--刷新忍者宝石加成
function GemstoneEquipPanel:updateAttrPanel()
    local data = model:getGemstoneInfo(self.hero_vo.partner_id)
    for k, v in pairs(self.attr_list) do
        v:removeFromParent()
        v=nil
    end
    self.attr_list = {}
    if data and data.all_attr and next(data.all_attr) then
        local list = deepCopy(data.all_attr)
        if tableLen(list) < 4 then
            for i=tableLen(list)+1,4 do
                table.insert(list, {attr_id=0,attr_val=0})
            end
        end
        for k, v in pairs(list) do
            local item = ccui.Layout:create()
            item:setAnchorPoint(cc.p(0, 1))
            item:setContentSize(cc.size(250, 40))
            if v.attr_id == 0 then
                item.icon = createSprite(PathTool.getResFrame("common","common_90021_8"),12,20,item,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
                local num = 20
                if judgingLanguage() then
                    num = 8
                end
                local txt = TI18N("语言_c_1586")
                item.txt = createLabel(22,cc.c3b(0xff,0xff,0xff),nil,46,20,transformTextToShort(txt,num),item,nil,cc.p(0,0.5))
                addEvt2showAllTextTips(item.txt,txt,num,nil,nil,nil,nil,true)
            else
                local attr_txt = Config.AttrData.data_id_to_key[v.attr_id]
                if not attr_txt then
                    attr_txt = Config.AttrExtraData.data_id_to_key[v.attr_id]
                end
                local res_id = PathTool.getAttrIconByStr(attr_txt)
                item.icon = createSprite(PathTool.getResFrame("common",res_id),12,20,item,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
                local num = 20
                if judgingLanguage() then
                    num = 8
                end
                local attr_name = Config.AttrData.data_id_to_name[v.attr_id]
                if not attr_name then
                    attr_name = Config.AttrExtraData.data_id_to_name[v.attr_id]
                end
                item.txt = createLabel(22,cc.c3b(0xff,0xff,0xff),nil,46,20,transformTextToShort(attr_name,num)..":",item,nil,cc.p(0,0.5))
                addEvt2showAllTextTips(item.txt,attr_name,num,nil,nil,nil,nil,true)
                local value = v.attr_val or 0
                local is_per = PartnerCalculate.isShowPerByStr(attr_txt)-- 是否为千分比
                if is_per then
                    value = (value/10).."%"
                end
                item.num = createLabel(22,cc.c3b(0xff,0xff,0xff),nil,56,20,value,item,nil,cc.p(0,0.5))
                item.num:setPositionX(item.txt:getPositionX() + item.txt:getContentSize().width + 10)
            end

            self.attr_scroll:addChild(item)

            self.attr_list[k] = item
        end
        local _h = math.max(self.attr_scroll:getContentSize().height,math.ceil(tableLen(data.all_attr)/2)*43)
        self.attr_scroll:setInnerContainerSize(cc.size(self.attr_scroll:getContentSize().width,_h))
        for k, v in ipairs(self.attr_list) do
            v:setPositionX(((k+1)%2)*320+ 57)
            v:setPositionY(_h - math.floor((k-1)/2)*43)
        end
        self.no_img:setVisible(false)
        self.no_tip_bg:setVisible(false)
        self.attr_scroll:setVisible(true)
    else
        self.attr_scroll:setVisible(false)
        self.no_img:setVisible(true)
        self.no_tip_bg:setVisible(true)
    end
end
function GemstoneEquipPanel:_clickResetBtn()
    local status = true
    local data = model:getGemstoneInfo(self.hero_vo.partner_id)
    for k, v in pairs(data.list_info) do
        if v.lv > 1 or v.exp > 0 then
            status = false
            break
        end
    end
    if status then
        message(TI18N("语言_s_3549"))
        return
    end
    controller:openGemstoneResetOfferPanel(true,self.hero_vo.partner_id, function()
        controller:sender22814(self.hero_vo.partner_id)
    end)
end
function GemstoneEquipPanel:register_event()
    registerButtonEventListener(self.help_btn, function()
        MainuiController:getInstance():openCommonExplainView(true, Config.PartnerGemData.data_explain[1])
    end, true, 1)
    registerButtonEventListener(self.remove_btn, function()
        local data = model:getGemstoneInfo(self.hero_vo.partner_id)
        if data and next(data) then
            for k, v in pairs(data.list_info) do
                if v.item_bid ~= 0 then
                    controller:sender22801(self.hero_vo.partner_id,0,0,3)
                    return
                end
            end
        end
        message(TI18N("语言_c_7181"))
    end, true, 1)
    registerButtonEventListener(self.resonance_btn, function()
        controller:openGemstoneResonanceWindow(true)
    end, true, 1)
    registerButtonEventListener(self.hero_bg, function()
        controller:openGemstoneSkillTipsWindow(true,self.hero_vo)
    end, false, 1)
    registerButtonEventListener(self.tip_panel, function()
        if self.skill_cfg then
            TipsManager:getInstance():showSkillTips(self.skill_cfg)
        end
        -- controller:openGemstoneSkillTipsWindow(true,self.hero_vo)
    end, false, 1)
    registerButtonEventListener(self.bag_btn, function()
        controller:openGemstoneBagWindow(true)
    end, true, 1)
    registerButtonEventListener(self.preview_btn, function()
        controller:openGemstonePreviewWindow(true)
    end, true, 1)
    registerButtonEventListener(self.reset_btn, function()
        self:_clickResetBtn()
    end, true, 1)
    -- 数据刷新
    if not self.update_hero_info then
        self.update_hero_info = GlobalEvent:getInstance():Bind(GemstoneEvent.Update_Hero_Info,function (pid)
            if pid == self.hero_vo.partner_id then
                self:setData()
            end
        end)
    end
end

function GemstoneEquipPanel:DeleteMe()
    for k, v in pairs(self.attr_list) do
        v:removeFromParent()
        v=nil
    end
    self.attr_list = {}
    if self.update_hero_info then
        GlobalEvent:getInstance():UnBind(self.update_hero_info)
        self.update_hero_info = nil
    end
end