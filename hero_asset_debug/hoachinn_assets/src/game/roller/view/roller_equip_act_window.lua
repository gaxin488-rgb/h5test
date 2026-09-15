-- --------------------------------------------------------------------
-- (必填, 创建模块的人员)
-- @description:
--     卷轴装备栏解锁
-- 
-- 
-- --------------------------------------------------------------------
RollerEquipActWindow = RollerEquipActWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()
local hero_controller = HeroController:getInstance()
local hero_model = hero_controller:getModel()

function RollerEquipActWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.layout_name = "roller/roller_equip_act_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("bondskill", "bondskill"), type = ResourcesType.plist}
    }
    self.hero_item_data_list = {}
    self.hero_item_list = {}
end

function RollerEquipActWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setZOrder(2)

    self.info_panel = self.main_container:getChildByName("info_panel")
    self.con_bg = self.info_panel:getChildByName("con_bg")
    self.hero_img = self.con_bg:getChildByName("hero_img")
    self.info_title = self.info_panel:getChildByName("info_title")
    self.info_title:setString(TI18N("语言_c_1996"))
    self.roller_node = self.info_panel:getChildByName("roller_node")

    -- self.lock_panel = self.info_panel:getChildByName("lock_panel")
    self.tip_bg = self.roller_node:getChildByName("tip_bg")
    self.tip = self.roller_node:getChildByName("tip")
    self.tip:setString(TI18N("语言_c_7192"))
    self.tip_bg:setContentSize(cc.size(self.tip:getContentSize().width + 50,30))

    self.cost_card_panel = self.main_container:getChildByName("cost_card_panel")
    self.cost_card_title = self.cost_card_panel:getChildByName("cost_card_title")
    setTextMaxWidth(self.cost_card_title,160)
    self.cost_card_title:setString(TI18N("语言_c_982"))
    self.title_panel = self.main_container:getChildByName("title_panel")
    self.Image_2 = self.title_panel:getChildByName("Image_2")
    self.win_title = self.title_panel:getChildByName("win_title")
    self.win_title:setString(TI18N("语言_c_7192"))
    self.Image_2:setContentSize(cc.size(self.win_title:getContentSize().width+120, self.Image_2:getContentSize().height))
    self.close_btn = self.title_panel:getChildByName("close_btn")
    self.btn_panel = self.main_container:getChildByName("btn_panel")
    self.lock_btn = self.btn_panel:getChildByName("lock_btn")
    self.look_btn = self.btn_panel:getChildByName("look_btn")
    self.look_txt = self.look_btn:getChildByName("look_txt")
    self.look_txt:setChangeScaleOffWidth(-1000)
    setTextMaxWidth(self.look_txt,150,-11)
    self.look_txt:setString(TI18N("语言_c_7192"))
    self.act_btn = self.btn_panel:getChildByName("act_btn")
    self.act_label = self.act_btn:getChildByName("label")
    self.act_label:setString(TI18N("语言_c_2904"))
    self.act_tip = self.btn_panel:getChildByName("tip")
    setTextMaxWidth(self.act_tip,600,-10)
    self.act_tip:setString(TI18N("语言_c_7367"))
end

function RollerEquipActWindow:register_event()
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.act_btn, handler(self, self.onClickBtnAct) ,true, 2)
    if self.lock_btn then
        self.lock_btn:addTouchEventListener(function( sender,event_type )
            customClickAction_2(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				local reward_desc_cfg = Config.ProhibitedScrollData.data_get_constant["unlock_desc"]
				if reward_desc_cfg then
					TipsManager:getInstance():showCommonTips(reward_desc_cfg.desc, sender:getTouchBeganPosition(),nil,nil,400)
				end
            end
        end)
    end
    if self.look_btn then
        self.look_btn:addTouchEventListener(function( sender,event_type )
            customClickAction_2(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				controller:openRollerMainWindow(true,1)
            end
        end)
    end
    --添加英雄选择返回事件
    if self.upgrade_star_select_event == nil then
        self.upgrade_star_select_event = GlobalEvent:getInstance():Bind(HeroEvent.Upgrade_Star_Select_Event, function()
            self:updateHeroItemInfo()
        end)
    end
end
function RollerEquipActWindow:onClickBtnAct()
    local cost_list = self.data.unlock_cost[1]
    local item_id =cost_list[1]
    local need_num = cost_list[2]
    local have_num = BackpackController:getInstance():getModel():getItemNumByBid(item_id)
    if have_num < need_num then
        local item_config = Config.ItemData.data_get_data(item_id)
        BackpackController:getInstance():openTipsSource(true, item_config)
        return
    end
    if tableLen(self.data.unlock_expend1) == 0 and tableLen(self.data.unlock_expend2) == 0 then
        controller:sender20826(self.partner_id, {}, {}, {})
        return
    end
    if self.hero_item_data_list and next(self.hero_item_data_list) ~= nil then
        local hero_list = {}
        local random_list = {}
        local dic_item_expend = {}
        for i,item in ipairs(self.hero_item_data_list) do
            local count = 0
            for k,v in pairs(item.dic_select_list) do
                count = count + 1
            end
            if count < item.count then
                message(TI18N("语言_c_3021"))
                return
            end
            for k,v in pairs(item.dic_select_list) do
                if v.is_hero_hun then --是否英魂 参考 HeroUpgradeStarSelectPanel:initHeroList(dic_other_selected) 里面的定义
                    if v.good_vo then
                        if dic_item_expend[v.good_vo.base_id] == nil then
                            dic_item_expend[v.good_vo.base_id] = 1
                        else
                            dic_item_expend[v.good_vo.base_id] = dic_item_expend[v.good_vo.base_id] + 1
                        end
                    end
                else
                    local data = {}
                    data.partner_id = k
                    if item.bid == 0 then
                        --随机卡
                        table.insert(random_list, data)
                    else
                        --指定卡
                        table.insert(hero_list, data)
                    end
                end
            end
        end
        local item_list = {}
        for item_id, num in pairs(dic_item_expend) do
            local data = {}
            data.item_id = item_id
            data.num = num
            table.insert(item_list, data)
        end
        controller:sender20826(self.partner_id, hero_list, random_list, item_list)
    end

end
function RollerEquipActWindow:onClickBtnClose()
    controller:openRollerEquipLockWindow(false)
end

function RollerEquipActWindow:openRootWnd(id,partner_id)
    self.hero_id = id
    self.partner_id = partner_id --唯一id
    self.hero_vo = hero_model:getHeroById(self.partner_id)
    local bust_id = 0
    if self.hero_vo.use_skin ~= 0 then
        local skin_config = Config.PartnerSkinData.data_skin_info[self.hero_vo.use_skin]
        if skin_config then
            bust_id = skin_config.bustid
        end
    else
        local config = Config.PartnerData.data_partner_base[self.hero_vo.bid]
        if config then
            bust_id = config.bustid
        end
    end
    local res = PathTool.getPartnerBustRes(bust_id)
    loadSpriteTexture(self.hero_img, res, LOADTEXT_TYPE)
    self.data = Config.ProhibitedScrollData.data_get_unlock_info[id]
    --print("id+++++++++++++",id,vardump(self.data))
    self:setData()
end
function RollerEquipActWindow:setData()
    self:setCostPanel()
end
function RollerEquipActWindow:setCostPanel()
    if not self.data then return end
    local cost_list = self.data.unlock_cost[1]
    self.cost_item = BackPackItem.new(true,true,false,0.8,true,true)
    self.cost_card_panel:addChild(self.cost_item)
    self.cost_item:setData(cost_list)
    local need_num =  cost_list[2]
    local have_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_list[1])
    self.cost_item:setNeedNum(need_num,have_num)
    if need_num > have_num then
        self.cost_item:setDefaultTip(true, true)
    else
        self.cost_item:setDefaultTip()
    end
    --{partner_id=10501, unlock_expend1={{10501,5,5}}, unlock_cost={{17602,1000}}, unlock_expend2={{1,5,1}}, back_item={{90501,1}}},
    --红点条件list
    local conditions_list = {}
    local index = 1

    for i,expend in ipairs(self.data.unlock_expend1) do
        self.hero_item_data_list[index] = self:getHeroData(expend[1], expend[2], expend[3])
        conditions_list[index] = {}
        conditions_list[index][expend[1]] = {}
        conditions_list[index][expend[1]][expend[2]] = expend[3]
        index = index + 1
    end
    for i,expend in ipairs(self.data.unlock_expend2) do
        self.hero_item_data_list[index] = self:getHeroData(nil, expend[2], expend[3], expend[1])
        conditions_list[index] = {}
        conditions_list[index][expend[1]] = {}
        conditions_list[index][expend[1]][expend[2]] = expend[3]
        index = index + 1
    end
    for i,hero_vo in ipairs(self.hero_item_data_list) do
        if self.hero_item_list[i] == nil then
            self.hero_item_list[i] = HeroExhibitionItem.new(0.8, true)
            self.hero_item_list[i]:setPosition( (i-0.5) * (HeroExhibitionItem.Width * 0.8 + 10) + 200 , 75)
            self.hero_item_list[i]:addCallBack(function() self:_onClickItemData(i) end)
            self.cost_card_panel:addChild(self.hero_item_list[i])
        end
        self.hero_item_list[i]:setVisible(true)
        if hero_vo.bid == 0 then
            --随机卡的头像id
            local default_head_id = hero_model:getRandomHeroHeadByQuality(hero_vo.star)
            self.hero_item_list[i]:setData(hero_vo)
            self.hero_item_list[i]:setDefaultHead(default_head_id)
            self.hero_item_list[i]:setHeroName(true, string_format(TI18N("语言_c_3022"), hero_vo.star))
        else
            self.hero_item_list[i]:setData(hero_vo)
            self.hero_item_list[i]:setHeroName(false)
        end

        self.hero_item_list[i]:setHeadUnEnabled(true)
    end
    self:initHeroListByMatchInfo(conditions_list)

    local _w = (tableLen(self.hero_item_list)+1)*(HeroExhibitionItem.Width * 0.8 + 10)
    local panel_w = self.cost_card_panel:getContentSize().width
    for i,j in ipairs(self.hero_item_list) do
        j:setPosition( (i-0.5) * (HeroExhibitionItem.Width * 0.8 + 10) + (panel_w - _w)*0.5 , 75)
    end
    self.cost_item:setPosition((tableLen(self.hero_item_list)+0.5)*(HeroExhibitionItem.Width * 0.8 + 10)+ (panel_w - _w)*0.5,75)
    self.cost_card_title:setPositionX((panel_w - _w)*0.5-10)
end
--初始化英雄列表匹配信息
function RollerEquipActWindow:initHeroListByMatchInfo(conditions_list)
    local hero_list = hero_model:getHeroList()
    self.conditions_hero_list = {}
    for k,hero in pairs(hero_list) do
        for i,conditions in ipairs(conditions_list) do
            if self.conditions_hero_list[i] == nil then
                self.conditions_hero_list[i] = {}
            end

            if self.hero_item_data_list[i].bid == 0 then
                --表示随机卡 0表示全部阵营
                if conditions[0] then
                    if conditions[0][hero.star] then
                        table.insert(self.conditions_hero_list[i], hero)
                    end
                else
                    if conditions[hero.camp_type] and conditions[hero.camp_type][hero.star] ~= nil then
                        table.insert(self.conditions_hero_list[i], hero)
                    end
                end
            else
                --指定卡
                if conditions[hero.bid] and conditions[hero.bid][hero.star] then   -- 指定卡要剔除自己
                    if self.hero_vo and self.hero_vo.partner_id ~= hero.partner_id then
                        table.insert(self.conditions_hero_list[i], hero)
                    end
                end
            end
        end
    end
    
    --新加需求.自动填满指定定的位置的英雄
    -- if self.hero_vo and self.hero_vo.red_point[HeroConst.RedPointType.eRPStar] then
        self.dic_other_selected = {}
        if self.hero_vo then
            self.dic_other_selected[self.hero_vo.partner_id] = self.hero_vo
        end
        for i,v in ipairs(self.hero_item_data_list) do
            --策划要求指定才需要填充 
            if v.bid ~= 0 then
                if self.conditions_hero_list[i] and #self.conditions_hero_list[i] > 0 then
                    local sort_func = SortTools.tableCommonSorter({{"lev", false}, {"id", true}}) 
                    table.sort(self.conditions_hero_list[i], sort_func)
                    local count = 0
                    for _,hero_vo in ipairs(self.conditions_hero_list[i]) do
                        if self.dic_other_selected[hero_vo.id] == nil and not hero_vo:checkHeroLockTips(true, nil, true) then
                            v.dic_select_list[hero_vo.id] = hero_vo
                            count = count + 1
                            if count >= v.count then
                                break
                            end
                        end
                    end
                    if count < v.count then
                        --说明不够..就不显示了
                        v.dic_select_list = {}
                    else
                        for k,v in pairs(v.dic_select_list) do
                            self.dic_other_selected[k] = v
                        end
                        v.lev = string.format("%s/%s", count, v.count)
                        if self.hero_item_list[i] then
                            self.hero_item_list[i].num_label:setString(v.lev)
                            if count > 0 then
                                self.hero_item_list[i]:setHeadUnEnabled(false)
                            else
                                self.hero_item_list[i]:setHeadUnEnabled(true)
                            end
                        end      
                    end
                end
            end
        end
    -- end


    local list = BackpackController:getInstance():getModel():getHeroHunList()
    for k, good_vo in pairs(list) do
        if good_vo.config then
            for i,conditions in ipairs(conditions_list) do
                if self.conditions_hero_list[i] == nil then
                    self.conditions_hero_list[i] = {}
                end
                if self.hero_item_data_list[i].bid == 0 then
                    --表示随机卡 0表示全部阵营
                    local camp_type = good_vo.config.camp_type
                    local star = good_vo.config.eqm_jie
                    if conditions[camp_type] and conditions[camp_type][star] ~= nil then
                        for j=1,good_vo.quantity do
                            local data = {}
                            data.id = -(j + camp_type * 10)
                            data.partner_id = data.id
                            data.good_vo = good_vo
                            table.insert(self.conditions_hero_list[i], data)
                        end
                    end
                end
            end
        end
    end

end
--点击材料数据
function RollerEquipActWindow:_onClickItemData(index)
    if not self.hero_item_data_list[index] then return end
    self.hero_vo = hero_model:getHeroById(self.partner_id)
    if not self.hero_vo then return end
    --标志点击了那个
    self.hero_item_data_list[index].is_select = true
    --被其他人选择的列表 [id] = hero_vo 模式
    local dic_other_selected = {}
    --把自己也过滤
    dic_other_selected[self.hero_vo.partner_id] = self.hero_vo
    for i,item in ipairs(self.hero_item_data_list) do
        if i ~= index then
            for k,v in pairs(item.dic_select_list) do
                dic_other_selected[k] = v
            end
        end
    end

    local setting = {}
    if self.hero_item_data_list[index].bid == 0 and self.hero_item_data_list[index].star == 5 then
        -- 表示随机卡
        setting.self_mark_bid = self.hero_vo.bid
    end

    hero_controller:openHeroUpgradeStarSelectPanel(true, self.hero_item_data_list[index], dic_other_selected, HeroConst.SelectHeroType.eUpgradeStar, setting)
end
--@ bid 英雄bid 特殊判断 如果 == nil 说明是随机卡
--@ star 星级
--@ count 数量
--@ camp_type 阵营  如果是随机卡.此一定需要有值
function RollerEquipActWindow:getHeroData(bid, star, count, camp_type)
    --模拟 hero_vo 需要的数据
    local data = {}
    data.star = star or 0
    data.count = count or 0
    data.lev = string_format("%s/%s", 0, count)
    
    if bid == nil then
        data.bid = 0 --表示随机卡
        data.camp_type = camp_type
    else
        local base_config = Config.PartnerData.data_partner_base[bid]
        if base_config then
            data.bid = bid
            data.camp_type = base_config.camp_type
            data.name = base_config.name
        else
            return nil
        end
    end
    --当前选中的英雄列表 [id] == hero_vo 模式
    data.dic_select_list = {}
    return data
end
--更新选中英雄信息
function RollerEquipActWindow:updateHeroItemInfo()
    if not self.hero_item_data_list then return end
    self.dic_other_selected = {}
    --过滤自己
    if self.hero_vo then
        self.dic_other_selected[self.hero_vo.partner_id] = self.hero_vo
    end
    for i,v in ipairs(self.hero_item_data_list) do
        if v.is_select then
            v.is_select = false
            local count = 0
            for k,vo in pairs(v.dic_select_list) do
                count = count + 1
                self.dic_other_selected[k] = vo
            end
            v.lev = string_format("%s/%s", count, v.count)
            if self.hero_item_list[i] then
                self.hero_item_list[i].num_label:setString(v.lev)
                if count > 0 then
                    self.hero_item_list[i]:setHeadUnEnabled(false)
                else
                    self.hero_item_list[i]:setHeadUnEnabled(true)
                end
            end
        else
            for k,vo in pairs(v.dic_select_list) do
                self.dic_other_selected[k] = vo
            end
        end
    end
end

function RollerEquipActWindow:close_callback()
    if self.updateBond then
        self.updateBond = GlobalEvent:getInstance():UnBind(self.updateBond)
        self.updateBond = nil
    end
    
    if self.upgrade_star_select_event then
        GlobalEvent:getInstance():UnBind(self.upgrade_star_select_event)
        self.upgrade_star_select_event = nil
    end
    if self.hero_item_list then
        for i,v in ipairs(self.hero_item_list) do
             v:DeleteMe()
        end
        self.hero_item_list = nil
    end
    controller:openRollerEquipLockWindow(false)
end