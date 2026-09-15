--卷轴激活相关
RollerChipsTipsWindow = RollerChipsTipsWindow or BaseClass(BaseView)

local _controller = RollerController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert

function RollerChipsTipsWindow:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "roller/roller_tips"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("prohibited_scroll", "scroll_talent"), type = ResourcesType.plist },
    }
	self.show_index = 1
    self.show_skill_index = 1
	self.base_attr_list = {}
	self.skill_list = {}
	self.fumo_attr_list = {}
    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
end

function RollerChipsTipsWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.item = self.root_wnd:getChildByName("item")
    self.container = self.root_wnd:getChildByName("container")

    self.base_panel = self.container:getChildByName("base_panel")
    -- self.get_btn = self.base_panel:getChildByName("get_btn")
    -- self.get_btn:setVisible(false)
    -- self.get_btn_label =  self.get_btn:getChildByName("label")
    self.hero_node = self.base_panel:getChildByName("hero_node")
    self.hero_node:setVisible(false)
    local txt = self.hero_node:getChildByName("txt")
    txt:setString(TI18N("语言_c_7093"))
    self.hero_item = HeroExhibitionItem.new(0.4, false, nil, nil ,true)
    self.hero_item:setPositionX(-70)
    self.hero_node:addChild(self.hero_item)

    self.node_item = self.base_panel:getChildByName("node_item")
    self.equip_type = self.base_panel:getChildByName("equip_type")
    self.score_title = self.base_panel:getChildByName("score_title")
    self.score_title:setString(TI18N("语言_c_1742"))
    self.equip_name = self.base_panel:getChildByName("name")
    self.level = self.base_panel:getChildByName("level")
    self.score = CommonNum.new(1, self.base_panel, 1, -2, cc.p(0, 0.5))
    self.score:setScale(0.66)
    self.score:setPosition(219,30)

    self.btn_panel = self.container:getChildByName("btn_panel")
    local tab_txt = {
        [1] = TI18N("语言_c_7225"),
        [2] = TI18N("语言_c_6416")
    }
    self.pros_btn_list = {}
    for i=1,2 do
        local item = self.btn_panel:getChildByName("tab_btn_"..i)
        item.unselect_bg = item:getChildByName("unselect_bg")
        item.select_bg = item:getChildByName("select_bg")
        if i == 1 then
            item.select_bg:setVisible(true)
            item.unselect_bg:setVisible(false)
        else
            item.select_bg:setVisible(false)
            item.unselect_bg:setVisible(true)
        end
        item.title = item:getChildByName("title")
        item.title:setString(tab_txt[i])
        item.index = i
        self.pros_btn_list[i] = item
    end

    self.scroller_panel = self.container:getChildByName("scroller_panel")
    self.scroller_panel:setScrollBarEnabled(false)
    --基础属性
    self.baseattr_panel = self.scroller_panel:getChildByName("baseattr_panel")
    local label = self.baseattr_panel:getChildByName("label")
    label:setString(TI18N("语言_c_6531"))
    self.baseattr_label = label
    self.base_attr_scroller = createScrollView(630, 90, 0, 2, self.baseattr_panel)
    self.base_attr_scroller:setTouchEnabled(false)
    --卷轴技能
    self.strengattr_panel = self.scroller_panel:getChildByName("strengattr_panel")
    local label = self.strengattr_panel:getChildByName("label")
    label:setString(TI18N("语言_c_7226"))

    self.left_btn = self.strengattr_panel:getChildByName("left_btn")
    self.right_btn = self.strengattr_panel:getChildByName("right_btn")

    --附魔
    self.fumoattr_panel = self.scroller_panel:getChildByName("fumoattr_panel")
    local label = self.fumoattr_panel:getChildByName("label")
    label:setString(TI18N("语言_c_7202"))
    self.fumoattr_label = label
    self.fumoattr_attr_scroller = createScrollView(630, 153, 0, 2, self.fumoattr_panel)
    self.fumoattr_attr_scroller:setTouchEnabled(false)


    self.tab_panel = self.container:getChildByName("tab_panel")
	self.chip_num_bg = self.tab_panel:getChildByName("Image_39")
	self.chip_num = self.tab_panel:getChildByName("chip_num")
	self.hecheng = self.tab_panel:getChildByName("hecheng")
    self.hecheng:getChildByName("label"):setString(TI18N("语言_c_1967"))
	self.xiexia = self.tab_panel:getChildByName("xiexia")
    self.xiexia:getChildByName("label"):setString(TI18N("语言_c_6182"))
	self.qianghua = self.tab_panel:getChildByName("qianghua")
    self.qianghua:getChildByName("label"):setString(TI18N("语言_c_6903"))
	self.tihuan = self.tab_panel:getChildByName("tihuan")
    self.tihuan:getChildByName("label"):setString(TI18N("语言_c_2965"))
    self.equip_tips = self.tab_panel:getChildByName("equip_tips")
    self.equip_tips:setString("")
    self.equip_desc = self.tab_panel:getChildByName("equip_desc")
    setTextMaxWidth(self.equip_desc,600,-6)
    self.equip_desc:setString("")

    self.btn_panel:setVisible(false)
    self.chip_num_bg:setVisible(false)
    self.chip_num:setVisible(false)
    self.hecheng:setVisible(false)
    self.xiexia:setVisible(false)
    self.qianghua:setVisible(false)
    self.tihuan:setVisible(false)

	self.close_btn = self.container:getChildByName("close_btn")
end

function RollerChipsTipsWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openRollerChipTipsWindow(false)
	end, false, 2)
	registerButtonEventListener(self.close_btn, function (  )
		_controller:openRollerChipTipsWindow(false)
	end, false, 2)
    for k, v in pairs(self.pros_btn_list) do
        registerButtonEventListener(v, function ()
            self.show_index = k
            self:changeSelectedTab()
            self:setSelectIndexData()
        end, false, 2)
    end
	registerButtonEventListener(self.right_btn, function ()
        self:changeleftright(1)
	end, true, 2, nil, 0.9)
	registerButtonEventListener(self.left_btn, function ()
        self:changeleftright(-1)
	end, true, 2, nil, 0.9)
	registerButtonEventListener(self.hecheng, function ()
        local cond_status,tips = _model:checkActiveCondition(self.roller_id)
        if cond_status then
            if self.is_can_active then
                _controller:sender20802(self.roller_id)
            else
                message(TI18N("语言_s_64"))
                local config = Config.ItemData.data_get_data(self.act_item_id)
                BackpackController:getInstance():openTipsSource(true, config)
                _controller:openRollerChipTipsWindow(false)
            end
        else
            message(tips)
        end
	end, false, 2)
	registerButtonEventListener(self.xiexia, function (  )
        _controller:sender20807(self.roller_id,self.partner_id)
	end, false, 2)
	-- registerButtonEventListener(self.get_btn, function (  )
    --     -- _controller:openRollerTalentPreviewWindow(true,1,1)
    --     -- _controller:openRollerChipTipsWindow(false)
	-- end, false, 2)
	registerButtonEventListener(self.qianghua, function (  )
		_controller:openRollerInfoWindow(true,1,self.roller_id)
        _controller:openRollerChipTipsWindow(false)
	end, false, 2)
	registerButtonEventListener(self.tihuan, function ()
        if self.btn_type == 1 then
            RollerController:getInstance():openRollerEquipListWindow(true,self.partner_id)
            _controller:openRollerChipTipsWindow(false)
        else
            if self.roller_id and self.partner_id then
                local equip_status,tips = _model:checkIsCanEquip(self.partner_id,self.roller_id)
                if equip_status then
                    _controller:sender20806(self.roller_id,self.partner_id)
                else
                    message(tips)
                end
            end
        end
	end, false, 2)
end
function RollerChipsTipsWindow:changeleftright(type)
    if self.show_skill_index <= 1 and type == -1 then
        return
    end
    local max_star = _controller:getModel():getMaxStarById(self.roller_id)
    if self.show_skill_index >= (max_star+1) and type == 1 then
        return
    end
    local min_inner_height = 630
    self.show_skill_index = self.show_skill_index + type * 1
    if self.open_type == TRUE then
        local roller_data = _model:getRollerDataById(self.roller_id)
        local star = roller_data.star
        self.height_2 = self:setSkillData(self.show_skill_index,star)
    else
        local star = self.setting.star
        self.height_2 = self:setSkillData(self.show_skill_index,star)
        min_inner_height = 820
    end

    local _scroller_height = math.max(min_inner_height+1,(self.height_1+self.height_2+self.height_3))
    self.scroller_panel:setInnerContainerSize(cc.size(630, _scroller_height))
    self.baseattr_panel:setPositionY(_scroller_height)
    self.fumoattr_panel:setPositionY(_scroller_height-self.height_1)
    self.strengattr_panel:setPositionY(_scroller_height-self.height_1-self.height_3)

    self.right_btn:setVisible(true)
    self.left_btn:setVisible(true)
    if self.show_skill_index <= 1 then
        self.right_btn:setVisible(true)
        self.left_btn:setVisible(false)
    end
    if self.show_skill_index >= (max_star+1) then
        self.right_btn:setVisible(false)
        self.left_btn:setVisible(true)
    end
end

function RollerChipsTipsWindow:changeSelectedTab()
    for i=1,2 do
        local item = self.pros_btn_list[i]
        if i == self.show_index then
            item.select_bg:setVisible(true)
            item.unselect_bg:setVisible(false)
        else
            item.select_bg:setVisible(false)
            item.unselect_bg:setVisible(true)
        end
    end
end

function RollerChipsTipsWindow:openRootWnd(setting)
    -- local setting = {roller_id=data.id,partner_id=self.partner_id,open_type=TRUE }
    self.setting = setting
    self.roller_id = setting.roller_id
    self.partner_id = setting.partner_id
    self.open_type = setting.open_type
    local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.roller_id]
    local quality = base_cfg.quality
    local background_res = PathTool.getResFrame("common_2", "tips_"..(quality))
    self.base_panel:loadTexture(background_res, LOADTEXT_TYPE_PLIST)
    self.base_panel:setCapInsets(cc.rect(295, 10, 10, 10))

    local color = BackPackConst.getEquipTipsColor(quality)
    self.equip_name:setTextColor(color) 
    self.equip_name:setString(transformTextToShort(base_cfg.name,35) or "")
    self.equip_name:setTouchEnabled(true)
    addEvt2showAllTextTips(self.equip_name,base_cfg.name,35)

    local roller_item = RollerItem.new(false, 1, true, false)
    self.node_item:addChild(roller_item)
    roller_item:setBaseData(self.roller_id)
    self.roller_item = roller_item

    if self.open_type == TRUE then -- my
        local is_active = _model:getRollerDataById(self.roller_id) --是否激活
        if is_active then
            self.btn_panel:setVisible(false)
            self.scroller_panel:setContentSize(cc.size(630, 631))

            self.chip_num:setVisible(false)
            self.chip_num_bg:setVisible(false)
            self.hecheng:setVisible(false)
            if self.partner_id then
                local self_role_data = HeroController:getInstance():getModel():getHeroById(self.partner_id)
                if self_role_data.prohibited_scroll and self_role_data.prohibited_scroll[1] and self_role_data.prohibited_scroll[1].scroll_id then
                    if is_active.partner_id and is_active.partner_id ~= 0 then
                        if is_active.partner_id == self.partner_id then --当前选的和被使用的是同一个
                            self.tihuan:getChildByName("label"):setString(TI18N("语言_c_2965"))
                            self.btn_type = 1
                            self.tihuan:setVisible(true)
                            self.tihuan:setPositionX(320)
                            self.xiexia:setVisible(true)
                        else
                            self.tihuan:getChildByName("label"):setString(TI18N("语言_c_2965"))
                            self.tihuan:setPositionX(500)
                            self.tihuan:setVisible(true)
                            self.xiexia:setVisible(false)
                        end
                    else
                        self.tihuan:getChildByName("label"):setString(TI18N("语言_c_6183"))
                        self.tihuan:setPositionX(500)
                        self.tihuan:setVisible(true)
                        self.xiexia:setVisible(false)
                    end
                else
                    self.tihuan:getChildByName("label"):setString(TI18N("语言_c_6183"))
                    self.xiexia:setVisible(false)
                    self.tihuan:setVisible(true)
                    self.tihuan:setPositionX(500)
                end
                self.qianghua:setVisible(true)
                self.qianghua:setPositionX(140)

                local equip_cond,tips = _model:checkIsCanEquip(self.partner_id,self.roller_id)
                if not equip_cond then
                    self.equip_tips:setString(tips)
                end
            else
                self.qianghua:setVisible(true)
                self.qianghua:setPositionX(320)
                self.xiexia:setVisible(false)
                self.tihuan:setVisible(false)
            end

            if is_active.partner_id and is_active.partner_id ~= 0 then
                local role_data = HeroController:getInstance():getModel():getHeroById(is_active.partner_id)
                self.hero_item:setData(role_data)
                self.hero_node:setVisible(true)
            end

            self:setActiveInfoData()

        else
            self:setSelectIndexData() 
            self.btn_panel:setVisible(true)
            self.chip_num_bg:setVisible(true)
            self.chip_num:setVisible(true)
            self.hecheng:setVisible(true)
            self.xiexia:setVisible(false)
            self.qianghua:setVisible(false)
            self.tihuan:setVisible(false)
            self:setActiveCostData()
        end
        self:checkRedPoint()
    else--other
        self.scroller_panel:setContentSize(cc.size(630, 820))
        self.scroller_panel:setPositionY(17)
        self.btn_panel:setVisible(false)
        self.tab_panel:setVisible(false)
        -- self.get_btn:setVisible(false)
        self:setOtherInfoData(setting)
    end

end
--好友的卷轴
function RollerChipsTipsWindow:setOtherInfoData(setting)
    local lv = setting.lev
    local star = setting.star
    local score = setting.score
    local roller_seal_list = setting.roller_seal_list

    local max_star,max_lv = _controller:getModel():getRollerMaxStarAndMaxLv(self.roller_id)
    local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.roller_id]
    self.score:setNum(score)
    self.level:setString(_string_format(TI18N("语言_c_3389"),lv.."/"..max_lv))
    self.equip_type:setString("")
    self.show_skill_index = star + 1
    local height_1 = self:setBaseAttrView(lv,star)
    self.height_1 = height_1
    local height_2 = self:setSkillView(star)
    self.height_2 = height_2

    self.right_btn:setVisible(true)
    self.left_btn:setVisible(true)
    if self.show_skill_index <= 1 then
        self.right_btn:setVisible(true)
        self.left_btn:setVisible(false)
    end
    if self.show_skill_index >= (max_star+1) then
        self.right_btn:setVisible(false)
        self.left_btn:setVisible(true)
    end

    --封印属性
    local __attr = {}
    local fengyin_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal
    for k, v in pairs(fengyin_cfg) do
        local fengyin_lv = self:getinof(k,roller_seal_list)
        local _data = v[fengyin_lv]
        if _data then
            local attrs = _data.attrs
            for i, val in ipairs(attrs) do
                table.insert(__attr,val)
            end
        else --没有显示0
            local attrs = v[1].attrs
            for i, val in ipairs(attrs) do
                table.insert(__attr,{val[1],0})
            end
        end
    end
    local temp = {}
    for k, v in pairs(__attr) do
        local key = v[1]
        local num = v[2]
        if temp[key] then
            temp[key] = temp[key] + num
        else
            temp[key] = num
        end
    end

    --额外属性
    local to_lv = self:gettoof(roller_seal_list)
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal_resonate[base_cfg.quality]
    local show_list = {}
    for k, v in pairs(cfg) do
        table.insert(show_list,v)
    end
    local function sortFunc( objA, objB )
		return objA.level < objB.level
	end
	table.sort(show_list, sortFunc)
    local attr_ex = {}
    for i = 1, #show_list do
        local data = show_list[i] -- level
        local next_data = show_list[i+1]
        if data.level <= to_lv then
            if next_data and data.level > to_lv then
                attr_ex = data.attrs
            else
                attr_ex = data.attrs
            end
        end
    end

    if next(attr_ex) then
        for k, v in pairs(attr_ex) do
            local key = v[1]
            local num = v[2]
            if temp[key] then
                temp[key] = temp[key] + num
            else
                temp[key] = num
            end
        end
    end

    local height_3 = self:setFenYinAttr(temp)
    self.height_3 = height_3

    local scroller_height = math.max(height_1+height_2+height_3,820)
    self.scroller_panel:setInnerContainerSize(cc.size(630, scroller_height))
    self.baseattr_panel:setPositionY(scroller_height)
    self.fumoattr_panel:setPositionY(scroller_height-height_1)
    self.strengattr_panel:setPositionY(scroller_height-height_1-height_3)
end
function RollerChipsTipsWindow:gettoof(list)
    local lv = 0
    for k, v in pairs(list) do
        lv = lv + v.lev
    end
    return lv
end
function RollerChipsTipsWindow:getinof(pos,list)
    for k, v in pairs(list) do
        if v.pos == pos then
            return v.lev
        end
    end
    return
end
--基础属性
function RollerChipsTipsWindow:setBaseAttrView(lv,star)
    local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.roller_id]
    local quality = base_cfg.quality
    local strength_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_enhance[quality][lv]
    local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[self.roller_id][star]

    --基础属性（升级和升星）
    local strength_attr = strength_cfg.attr
    local star_attr = star_cfg.attr
    local _arr = {}
    for k, v in pairs(strength_attr) do
        local key = v[1]
        local num = v[2]
        if _arr[key] then
            _arr[key] = _arr[key] + num
        else
            _arr[key] = num
        end
    end
    for k, v in pairs(star_attr) do
        local key = v[1]
        local num = v[2]
        if _arr[key] then
            _arr[key] = _arr[key] + num
        else
            _arr[key] = num
        end
    end
    local attr = {}
    for i, v in pairs(_arr) do
        local key_id = Config.AttrData.data_key_to_id[i] or Config.AttrExtraData.data_key_to_id[i]
        local object = {i,v,key_id}
        table.insert(attr,object)
    end
    local function sortFunc( objA, objB )
        return objA[3] < objB[3]
    end
	table.sort(attr, sortFunc)

    local _line_num = math.ceil(#attr/2)
    local scroller_height = (_line_num * 35 + 8)--math.max((_line_num * 35 + 8),80)
    self.base_attr_scroller:setContentSize(cc.size(630, scroller_height))
    self.base_attr_scroller:setInnerContainerSize(cc.size(630, scroller_height))
    for k, v in pairs(attr) do
        if self.base_attr_list[k] == nil then
            self.base_attr_list[k] = createRichLabel(20, cc.c4b(0xff, 0xff, 0xff, 0xff), cc.p(0, 1), cc.p(0,0))
            self.base_attr_scroller:addChild(self.base_attr_list[k])
        end
        local res, attr_name, attr_val = commonGetAttrInfoByKeyValue(v[1], v[2])
        local str = string.format("<img src='%s' scale=1 /> <div fontcolor=#c1b7ab> %s：</div><div fontcolor=#ffeedd>%s</div>", res, attr_name, attr_val)
        self.base_attr_list[k]:setString(str)
        local _x = 35 + 300 * ((k-1)%2)
        local _y = scroller_height - 5 - math.floor((k-1)/2)*35
        self.base_attr_list[k]:setPosition(cc.p(_x,_y))
        -- local _y = scroller_height - (k-1)*35 - 8s
        -- label:setPosition(cc.p(_x,_y))
    end
    local height_1 = scroller_height + 41
    self.baseattr_panel:setContentSize(cc.size(630,height_1))
    self.baseattr_label:setPositionY(height_1-5)
    self.base_attr_scroller:setPositionY(0)
    return height_1
end
--技能
function RollerChipsTipsWindow:setSkillData(index,now_star)
    local max_star = _controller:getModel():getMaxStarById(self.roller_id)

        local v = self._skill_data[index]
        if self._skill_item == nil then
            self._skill_item = self:createStrengthEffectItem(self.strengattr_panel)
        end
        local skill_id = v.skill_id
        local lev = v.lev
        if not self._skill_item.skill_item  then
            local skill_item = SkillItem.new(true, true, true, 0.9, true)
            skill_item:setPositionX(52)
            skill_item:setPositionY(-1)
            self._skill_item.skill_node:addChild(skill_item)
            skill_item:setSwallowTouches(true)
            self._skill_item.skill_item = skill_item
        end
        local skill_cfg = Config.SkillData.data_get_skill(skill_id)
        if skill_cfg then
            self._skill_item.skill_item:setData(skill_cfg)
        end
        self._skill_item.skill_name:setString(skill_cfg.name)

        local total_star_width = max_star * 29
        self._skill_item.star_layer:setPositionX(130 + total_star_width/2)
        self._skill_item.star_list = createOnlyStar(max_star, self._skill_item.star_layer,29)
        for i, v in ipairs(self._skill_item.star_list) do
            setChildUnEnabled(true, v)
            if i <= lev then
                setChildUnEnabled(false, v)
            end
        end

        if now_star == v.lev then
            self._skill_item.current_txt:setString(TI18N("语言_c_1294"))
            self._skill_item.current_img:setVisible(true)
            self._skill_item.current_txt:setVisible(true)
        else
            self._skill_item.current_img:setVisible(false)
            self._skill_item.current_txt:setVisible(false)
        end
        
        local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.roller_id]
        local num = 20
        if judgingLanguage() then
            num = 10
        end
        self._skill_item.type_txt:setString(transformTextToShort(base_cfg.pos_text,num))
        addEvt2showAllTextTips(self._skill_item.type_txt, base_cfg.pos_text,num)
        local res = PathTool.getPlistImgForDownLoad("prohibitor/prohibitor_setting", base_cfg.pos_icon)
        self._skill_item.type_icon:loadTexture(res,LOADTEXT_TYPE)
        local buff_desc_str = ""
        if skill_cfg.buff_des ~= nil and skill_cfg.buff_des[1] and next(skill_cfg.buff_des[1]) then
            local buff_config = Config.SkillData.data_get_buff 
            for i, v in ipairs(skill_cfg.buff_des[1]) do
                local config = buff_config[v]
                if config then
                    if buff_desc_str ~= "" then
                        buff_desc_str = buff_desc_str.."<div fontcolor=#a1978b>\n</div>"
                    end
                    local buff_desc = string_format("<div fontcolor=#c1b7ab>【%s】</div><div fontcolor=#c1b7ab>\n%s</div>", config.name, config.desc)
                    buff_desc_str = buff_desc_str..buff_desc
                end
            end
        end
        local newDes = string.gsub(skill_cfg.des.."\n"..buff_desc_str, "([%d%.]+%%)", "<div fontcolor=009f00 >%1</div>")
        local desc_str = string.format("<div>%s</div>",newDes)
        self._skill_item.skill_desc:setString(desc_str)
        local skill_desc_height = 87
        local ___height = self._skill_item.skill_desc:getContentSize().height
        skill_desc_height = ___height
        self._skill_item.layer:setPosition(cc.p(0,245))

        local height_2 = 245 + (skill_desc_height - 87) + 31
        return height_2
end
function RollerChipsTipsWindow:setSkillView( now_star )
    local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[self.roller_id]
    local skill_data = {}
    for k, v in pairs(star_cfg) do
        local skill_id = v.passive_skill[1]
        local lev = v.lev
        local object = {skill_id=skill_id,lev=lev}
        table.insert(skill_data,object)
    end
    table.sort(skill_data, function(a,b) return a.lev < b.lev end)
    self._skill_data = skill_data
    local skill_desc_height = 87
    local max_star = _controller:getModel():getMaxStarById(self.roller_id)

    skill_desc_height = self:setSkillData(self.show_skill_index,now_star)
    -- for k, v in pairs(skill_data) do
    --     if self.skill_list[k] == nil then
    --         self.skill_list[k] = self:createStrengthEffectItem(self.strengattr_panel)
    --     end
    --     local skill_id = v.skill_id
    --     local lev = v.lev
    --     if not self.skill_list[k].skill_item  then
    --         local skill_item = SkillItem.new(true, true, true, 0.9, true)
    --         skill_item:setPositionX(52)
    --         skill_item:setPositionY(-1)
    --         self.skill_list[k].skill_node:addChild(skill_item)
    --         skill_item:setSwallowTouches(true)
    --         self.skill_list[k].skill_item = skill_item
    --     end
    --     local skill_cfg = Config.SkillData.data_get_skill(skill_id)
    --     if skill_cfg then
    --         self.skill_list[k].skill_item:setData(skill_cfg)
    --     end
    --     self.skill_list[k].skill_name:setString(skill_cfg.name)

    --     local total_star_width = max_star * 29
    --     self.skill_list[k].star_layer:setPositionX(130 + total_star_width/2)
    --     self.skill_list[k].star_list = createOnlyStar(max_star, self.skill_list[k].star_layer,29)
    --     for i, v in ipairs(self.skill_list[k].star_list) do
    --         setChildUnEnabled(true, v)
    --         if i <= lev then
    --             setChildUnEnabled(false, v)
    --         end
    --     end

    --     if now_star == v.lev then
    --         self.skill_list[k].current_txt:setString(TI18N("语言_c_1294"))
    --         self.skill_list[k].current_img:setVisible(true)
    --     else
    --         self.skill_list[k].current_img:setVisible(false)
    --     end
        
    --     local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.roller_id]
    --     local num = 20
    --     if judgingLanguage() then
    --         num = 10
    --     end
    --     self.skill_list[k].type_txt:setString(transformTextToShort(base_cfg.pos_text,num))
    --     addEvt2showAllTextTips(self.skill_list[k].type_txt, base_cfg.pos_text,num)
    --     local res = PathTool.getPlistImgForDownLoad("prohibitor/prohibitor_setting", base_cfg.pos_icon)
    --     self.skill_list[k].type_icon:loadTexture(res,LOADTEXT_TYPE)
    --     local buff_desc_str = ""
    --     if skill_cfg.buff_des ~= nil and skill_cfg.buff_des[1] and next(skill_cfg.buff_des[1]) then
    --         local buff_config = Config.SkillData.data_get_buff 
    --         for i, v in ipairs(skill_cfg.buff_des[1]) do
    --             local config = buff_config[v]
    --             if config then
    --                 if buff_desc_str ~= "" then
    --                     buff_desc_str = buff_desc_str.."<div fontcolor=#a1978b>\n</div>"
    --                 end
    --                 local buff_desc = string_format("<div fontcolor=#c1b7ab>【%s】</div><div fontcolor=#c1b7ab>\n%s</div>", config.name, config.desc)
    --                 buff_desc_str = buff_desc_str..buff_desc
    --             end
    --         end
    --     end
    --     local newDes = string.gsub(skill_cfg.des.."\n"..buff_desc_str, "([%d%.]+%%)", "<div fontcolor=009f00 >%1</div>")
    --     local desc_str = string.format("<div>%s</div>",newDes)
    --     self.skill_list[k].skill_desc:setString(desc_str)
    --     -- self.skill_list[k].skill_desc:setString(skill_cfg.des.."\n"..buff_desc_str)

    --     local ___height = self.skill_list[k].skill_desc:getContentSize().height
    --     if  ___height > skill_desc_height then
    --         skill_desc_height = ___height
    --     end
    --     local posx = 630 * (k-1)
    --     self.skill_list[k].layer:setPosition(cc.p(posx,245))
    --     self.skill_list[k].index = k
    --     self.skill_list[k].initPos = cc.p(posx,245)
    -- end

    if self.show_skill_index <= 1 then
        self.right_btn:setVisible(true)
        self.left_btn:setVisible(false)
    end
    if self.show_skill_index >= (max_star+1) then
        self.right_btn:setVisible(false)
        self.left_btn:setVisible(true)
    end
    -- local height_2 = 245 + (skill_desc_height - 87) + 31
    return skill_desc_height
end
--封印
function RollerChipsTipsWindow:setFenYinAttr(temp)
    local fengyin_attr = {}
    for i, v in pairs(temp) do
        local key_id = Config.AttrData.data_key_to_id[i] or Config.AttrExtraData.data_key_to_id[i]
        local object = {i,v,key_id}
        table.insert(fengyin_attr,object)
    end
    local function sortFunc( objA, objB )
        return objA[3] < objB[3]
    end
	table.sort(fengyin_attr, sortFunc)

    local line_num = math.ceil(#fengyin_attr/2)
    local scroller_height = line_num * 35 + 8
    self.fumoattr_attr_scroller:setContentSize(cc.size(630, scroller_height))
    self.fumoattr_attr_scroller:setInnerContainerSize(cc.size(630, scroller_height))
    for k, v in pairs(fengyin_attr) do
        if self.fumo_attr_list[k] == nil then
            self.fumo_attr_list[k] = createRichLabel(20, cc.c4b(0xff, 0xff, 0xff, 0xff), cc.p(0, 1), cc.p(0,0))
            self.fumoattr_attr_scroller:addChild(self.fumo_attr_list[k])
        end
        local res, attr_name, attr_val = commonGetAttrInfoByKeyValue(v[1], v[2])
        local str = string.format("<img src='%s' scale=1 /> <div fontcolor=#3d9e38> %s:  %s</div>", res, attr_name, attr_val)
        self.fumo_attr_list[k]:setString(str)
        local _x = 35 + 300 * ((k-1)%2)
        local _y = scroller_height - 5 - math.floor((k-1)/2)*35
        self.fumo_attr_list[k]:setPosition(cc.p(_x,_y))
    end
    local height_3 = scroller_height + 41
    self.fumoattr_panel:setContentSize(cc.size(630, height_3))
    self.fumoattr_label:setPositionY(height_3-5)
    self.fumoattr_attr_scroller:setPositionY(0)
    return height_3
end

function RollerChipsTipsWindow:setActiveInfoData()
    local roller_data = _model:getRollerDataById(self.roller_id)
    local lv = roller_data.lev
    local star = roller_data.star
    local seal_list = roller_data.seal_list
    local score = roller_data.score
    self.roller_item:setStarCount(true,star)
    local max_star,max_lv = _controller:getModel():getRollerMaxStarAndMaxLv(self.roller_id)
    local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.roller_id]
    self.score:setNum(score)
    self.level:setString(_string_format(_string_format(TI18N("语言_c_3389"),lv.."/"..max_lv)))
    local cost = base_cfg.cost[1]
    local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost[1])
    self.equip_type:setString(_string_format(TI18N("语言_c_7227"),own_num,cost[2]))

    self.equip_desc:setString(transformTextToShort(base_cfg.tips_desc,200) or "")
    self.equip_desc:setTouchEnabled(true)
    addEvt2showAllTextTips(self.equip_desc,base_cfg.tips_desc,200)

    local quality = base_cfg.quality
    local strength_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_enhance[quality][lv]
    local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[self.roller_id][star]
    local up_star_cost = star_cfg.cost
    if up_star_cost and next(up_star_cost) then
        local cost_id = up_star_cost[1][1]
        local need_num = up_star_cost[1][2]
        local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
        self.equip_type:setString(string.format(TI18N("语言_c_7227"),own_num,need_num))
    else
        self.equip_type:setString("")
    end

    self.show_skill_index = star + 1
    --基础属性（升级和升星）
    local height_1 = self:setBaseAttrView(lv,star)
    self.height_1 = height_1
    local height_2 = self:setSkillView(star)
    self.height_2 = height_2

    self.right_btn:setVisible(true)
    self.left_btn:setVisible(true)
    if self.show_skill_index <= 1 then
        self.right_btn:setVisible(true)
        self.left_btn:setVisible(false)
    end
    if self.show_skill_index >= (max_star+1) then
        self.right_btn:setVisible(false)
        self.left_btn:setVisible(true)
    end

    --封印属性
    local __attr = {}
    local fengyin_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal
    for k, v in pairs(fengyin_cfg) do
        local fengyin_lv = _model:getRollerFengyinLvById(self.roller_id,k)
        local _data = v[fengyin_lv]
        if _data then
            local attrs = _data.attrs
            for i, val in ipairs(attrs) do
                table.insert(__attr,val)
            end
        else --没有显示0
            local attrs = v[1].attrs
            for i, val in ipairs(attrs) do
                table.insert(__attr,{val[1],0})
            end
        end
    end
    local temp = {}
    for k, v in pairs(__attr) do
        local key = v[1]
        local num = v[2]
        if temp[key] then
            temp[key] = temp[key] + num
        else
            temp[key] = num
        end
    end
    --额外属性
    local extral_attr = _model:getExtralFengYinAttrById(self.roller_id)
    if next(extral_attr) then
        for k, v in pairs(extral_attr) do
            local key = v[1]
            local num = v[2]
            if temp[key] then
                temp[key] = temp[key] + num
            else
                temp[key] = num
            end
        end
    end
    local height_3 = self:setFenYinAttr(temp)
    self.height_3 = height_3

    local _scroller_height = math.max(631,(height_1+height_2+height_3))
    self.scroller_panel:setInnerContainerSize(cc.size(630, _scroller_height))

    self.baseattr_panel:setPositionY(_scroller_height)
    self.fumoattr_panel:setPositionY(_scroller_height-height_1)
    self.strengattr_panel:setPositionY(_scroller_height-height_1-height_3)
end
function RollerChipsTipsWindow:setActiveCostData()
    local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.roller_id]
    local cost = base_cfg.cost[1]
    local cost_id = cost[1]
    local need_num = cost[2]
    local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
    self.chip_num:setString(string.format(TI18N("语言_c_7227"),own_num,need_num))
    self.is_can_active = false
    self.act_item_id = cost_id
    if own_num >= need_num then
        self.is_can_active = true
    end
    local cond_status,tips = _model:checkActiveCondition(self.roller_id)
    if not cond_status then
        self.equip_tips:setString(tips)
        setChildUnEnabled(true,self.hecheng)
    else
        setChildUnEnabled(false,self.hecheng)
    end
end

--未激活预览
function RollerChipsTipsWindow:setSelectIndexData()
    local lv = 0
    local star = 0
    local fengyin_lv = 1
    local max_star,max_lv = _controller:getModel():getRollerMaxStarAndMaxLv(self.roller_id)
    local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.roller_id]
    local cost = base_cfg.cost[1]
    local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost[1])
    self.equip_type:setString(_string_format(TI18N("语言_c_7227"),own_num,cost[2]))
    local score = base_cfg.sort
    if self.show_index == 1 then
        star = 0
        lv = 0
        self.show_skill_index = 1
    else
        star,lv = _controller:getModel():getRollerMaxStarAndMaxLv(self.roller_id)
        fengyin_lv = -1 -- _controller:getModel():getFengYinMaxLv()
        score = base_cfg.init_score
        self.show_skill_index = star + 1
    end
    self.score:setNum(score)
    self.level:setString(_string_format(TI18N("语言_c_3389"),lv.."/"..max_lv))
    self.roller_item:setStarCount(true,star)
    self.equip_desc:setString(transformTextToShort(base_cfg.tips_desc,200) or "")
    self.equip_desc:setTouchEnabled(true)
    addEvt2showAllTextTips(self.equip_desc,base_cfg.tips_desc,200)

    local height_1 = self:setBaseAttrView(lv,star)
    self.height_1 = height_1
    local height_2 = self:setSkillView()
    self.height_2 = height_2

    self.right_btn:setVisible(false)
    self.left_btn:setVisible(false)

    --封印属性
    local __attr = {}
    local fengyin_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal
    for k, v in pairs(fengyin_cfg) do
        local _data
        if fengyin_lv == -1 then
            _data = v[#v]
        else
            _data = v[fengyin_lv]
        end
        -- local _data = v[fengyin_lv]
        local attrs = _data.attrs
        for i, v in ipairs(attrs) do
            table.insert(__attr,v)
        end
    end
    local temp = {}
    for k, v in pairs(__attr) do
        local key = v[1]
        local num = v[2]
        if fengyin_lv == -1 then
            if temp[key] then
                temp[key] = temp[key] + num
            else
                temp[key] = num
            end
        else
            temp[key] = 0
        end
    end
    local height_3 = self:setFenYinAttr(temp)
    self.height_3 = height_3

    local _scroller_height = math.max((height_1+height_2+height_3),595)
    self.scroller_panel:setInnerContainerSize(cc.size(630, height_1+height_2+height_3))

    self.baseattr_panel:setPositionY(_scroller_height)
    self.fumoattr_panel:setPositionY(_scroller_height-height_1)
    self.strengattr_panel:setPositionY(_scroller_height-height_1-height_3)
end

function RollerChipsTipsWindow:createStrengthEffectItem(parent)
    local item = {}
	local layer = ccui.Layout:create()
    layer:setAnchorPoint(cc.p(0, 1))
    layer:setContentSize(cc.size(630,245))
    parent:addChild(layer)

	local skill_item = self.item:clone()
    layer:addChild(skill_item)
    skill_item:setPositionX(315)
    skill_item:setPositionY(245)

    local star_layer = skill_item:getChildByName("star_layer")
    local skill_name = skill_item:getChildByName("skill_name")
    local skill_node = skill_item:getChildByName("skill_node")
    local video_btn = skill_item:getChildByName("video_btn")
    local current_img = skill_item:getChildByName("current_img")
    local type_icon = skill_item:getChildByName("type_icon")
    local type_txt = skill_item:getChildByName("type_txt")
    type_txt:setString("")
    local current_txt = skill_item:getChildByName("current_txt")
    current_txt:setString("")
    -- local skill_desc = createLabel(20, cc.c4b(0xff,0xee,0xdd,0xff), nil, 35, 67, "", skill_item, -4, cc.p(0,1)) 
    -- skill_desc:setWidth(560)
    local skill_desc = createRichLabel(20, cc.c4b(0xff,0xee,0xdd,0xff), cc.p(0,1), cc.p(35,67), nil, -4, 560)
    skill_item:addChild(skill_desc)

    item.layer = layer
    item.current_txt = current_txt
    item.type_icon = type_icon
    item.type_txt = type_txt
    item.current_img = current_img
    item.star_layer = star_layer
    item.skill_name = skill_name
    item.skill_node = skill_node
    item.skill_desc = skill_desc
    item.video_btn = video_btn
    return item
end

function RollerChipsTipsWindow:checkRedPoint()
    local roller_data = _model:getRollerDataById(self.roller_id)
    if roller_data then
        local _is_upgrade = _model:checkUpGradeStatusByRollerId(self.roller_id)
        if _is_upgrade then
            addRedPointToNodeByStatus(self.qianghua, true,10,10)
            return
        end
        local _is_upstar = _model:checkUpStarStatusByRollerId(self.roller_id)
        if _is_upstar then
            addRedPointToNodeByStatus(self.qianghua, true,10,10)
            return
        end
        local _is_upfengyin = _model:checkUpFengyinStatusByRollerId(self.roller_id)
        if _is_upfengyin then
            addRedPointToNodeByStatus(self.qianghua, true,10,10)
            return
        end
        addRedPointToNodeByStatus(self.qianghua, false)
    else
        local _is_act = _model:checkActiveStatusById(self.roller_id)
        if _is_act then
            addRedPointToNodeByStatus(self.hecheng, true,10,10)
            return
        end
        addRedPointToNodeByStatus(self.hecheng, false)
    end
end

function RollerChipsTipsWindow:close_callback()
	_controller:openRollerChipTipsWindow(false)
end