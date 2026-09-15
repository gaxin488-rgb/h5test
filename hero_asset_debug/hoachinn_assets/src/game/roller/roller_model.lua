RollerModel = RollerModel or BaseClass()

function RollerModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function RollerModel:config()
    self.roller_list = {}
    self.roller_talent_list = {}
end
--装备槽屏蔽相关
function RollerModel:checkEquipOpenStatus(hero_bid)
    local partner_cfg = Config.PartnerData.data_partner_base[hero_bid]
    if not partner_cfg then return false end
    if partner_cfg.scroll_show then
        if partner_cfg.scroll_show == 1 then
        else
            local hero_nohideIds = RoleController:getInstance():getModel():getSeverShowIds("scroll_show")
            if not table.indexof(hero_nohideIds,partner_cfg.bid) then
                return false
            end
        end
    else
        return false
    end
    return true
end

--单个屏蔽
function RollerModel:checkSingleRollerOpenStatus(scroll_id)
    local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("prohibited_scroll_data")
    local partner_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[scroll_id]
    if partner_cfg and partner_cfg.is_show == 0 and not table.indexof(nohideIds,scroll_id) then
        -- 后台配置屏蔽的
        return false
    else
        return true
    end
end

--屏蔽表
function RollerModel:checkRollerHideStatus()
    local nohideIds = RoleController:getInstance():getModel():getSeverShowIds("features_shield")
    local featuresId = Config.ProhibitedScrollData.data_get_constant.open_model.val
    if not table.indexof(nohideIds,featuresId) then
        return false
    end
    return true
end

--卷轴入口是否显示
function RollerModel:checkRollerShowStatus()
    local hide_status = self:checkRollerHideStatus()
    if hide_status then
        local cfg = Config.CrossGroundData.data_prohibitor[4][1]
        local show_cond = cfg.show_cond
        local open_status = MainuiController:getInstance():checkIsOpenByActivate(show_cond,true)
        if open_status then
            return true
        end
    end
    return false
end

function RollerModel:checkRollerFunctionOpenStatus()
    local hide_status = self:checkRollerHideStatus()
    local cfg = Config.CrossGroundData.data_prohibitor[4][1]
    local open_limit = cfg.open_limit
    local open_status = MainuiController:getInstance():checkIsOpenByActivate(open_limit,true)
    -- print(hide_status,open_status)
    if not hide_status or not open_status then
        local tips = cfg.desc2
        return false,tips
    else
        return true
    end
end


function RollerModel:setRollerData(data)
    for k, v in pairs(data.prohibited_scroll) do
        local id = v.id
        v.old_seal = v.seal
        self.roller_list[id] = v
    end
    self:mainEnterStatus()
end

function RollerModel:updateSingleRollerData(data)
    local id = data.id
    if self.roller_list[id] then
        local old_seal = self.roller_list[id].old_seal
        local now_seal = data.seal
        self:checkFengyinTogetherAlert(old_seal,now_seal,id)
    end
    data.old_seal = data.seal
    self.roller_list[id] = data
    self:mainEnterStatus()
    if data.partner_id then
        local hero_vo = HeroController:getInstance():getModel():getHeroById(data.partner_id)
        if HeroCalculate.isCheckHeroRedPointByHeroVo(hero_vo) then
            HeroCalculate.checkAllHeroRedPoint()
        end
    end
end
function RollerModel:checkFengyinTogetherAlert(old_seal,now_seal,id)
    local abse_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[id]
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal_resonate[abse_cfg.quality]
    local list = {}
    for k, v in pairs(cfg) do
        table.insert(list, deepCopy(v))
    end
    table.sort(list, function(a,b) return a.level < b.level end)
    local info
    for i, v in ipairs(list) do
        local data = v
        if data.level > old_seal and data.level <= now_seal then
            info = data
            break
        end 
    end
    if info then
        RollerController:getInstance():openRollerFengyinResultWindow(true,old_seal,now_seal,id)
        GlobalEvent:getInstance():Fire(RollerEvent.StopFenYinTimerEvent)
    end
end
function RollerModel:setRollerTalentData(data)
    self.roller_talent_order = data.order
    self.roller_talent_cd = data.cd_end
    self.roller_talent_socre = data.talent_score
    self.roller_talent_list = {}
    for k, v in pairs(data.talent_list) do
        local id = v.id
        self.roller_talent_list[id] = v
    end
    self:mainEnterStatus()
end

function RollerModel:setSingleRollerTalentData(data)
    self.roller_talent_order = data.order
    self.roller_talent_socre = data.talent_score
    self.roller_talent_list[data.id] = {id = data.id}
end

function RollerModel:getTalentResetCdTime()
    return self.roller_talent_cd 
end

function RollerModel:getTalentOrder()
    return self.roller_talent_order or 0
end

function RollerModel:getTalentPower()
    return self.roller_talent_socre or 0
end

function RollerModel:getAllRollerData()
    return self.roller_list
end

function RollerModel:getRollerDataById(roller_id)
    return self.roller_list[roller_id]
end

function RollerModel:getRollerFengyinLvById(roller_id,fengyin_id)
    local roller_data = self.roller_list[roller_id]
    if roller_data then
        local seal_list = roller_data.seal_list or {}
        for k, v in pairs(seal_list) do
            local pos = v.pos
            if pos == fengyin_id then
                return v.lev
            end
        end
    end
    return 0
end
--已激活封印总等级
function RollerModel:getAllFengyinLvById(roller_id)
    local roller_data = self.roller_list[roller_id]
    local total_lv = 0
    if roller_data then
        local seal_list = roller_data.seal_list or {}
        for k, v in pairs(seal_list) do
            total_lv = total_lv+v.lev
        end
    end
    return total_lv
end
function RollerModel:getMaxFengyinLv(roller_id)
    local max_lv = 0
    local abse_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[roller_id]
    local roller_data = Config.ProhibitedScrollData.data_get_proh_scroll_seal_resonate[abse_cfg.quality]
    if roller_data then
        for k, v in pairs(roller_data) do
            if v.level > max_lv then
                max_lv = v.level
            end
        end
    end
    return max_lv
end
--天赋是否激活
function RollerModel:getTalentDataById(id)
    return self.roller_talent_list[id]
end
function RollerModel:getTalentData()
    return self.roller_talent_list
end

function RollerModel:getTotalStarAndTotalNum()
    local stra = 0
    local num = 0
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll
    num = tableLen(cfg)
    stra = num * 5
    return stra,num
end
function RollerModel:getActiveNumAndStarNum()
    local active_num = 0
    local active_star = 0
    for k, v in pairs(self.roller_list) do
        active_num = active_num + 1
        local star = v.star
        active_star = active_star + star
    end
    return active_num,active_star
end
function RollerModel:getFengYinMaxLv()
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal[1]
    return #cfg
end
function RollerModel:getRollerMaxStarAndMaxLv(roller_id)
    local stra = 0
    local num = 0
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll[roller_id]
    local quality = cfg["quality"]
    local lv_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_enhance[quality]
    local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[roller_id]
    num = tableLen(lv_cfg)
    stra = tableLen(star_cfg)
    return (stra-1),(num-1)
end

function RollerModel:getStepMaxLvByStep(step)
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_talent[step]
    if cfg then
        local lv = 0
        for k, v in pairs(cfg) do
            local talent_quality = v.talent_quality
            if talent_quality > 1 then
                lv = lv + 1
            end
        end
        return lv
    end
    return 0
end
function RollerModel:getRollerTalentInfo(id)
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_talent 
    local info
    for k, v in pairs(cfg) do
        local data = v
        if data[id] then
            info = data[id]
            break
        end
    end
    return info
end
function RollerModel:getActiveTalentTotalAttr()
    local attr_list = {}
    for k, v in pairs(self.roller_talent_list) do
        local id = v.id
        local cfg = self:getRollerTalentInfo(id)
        local attr = cfg.attrs
        for key, val in pairs(attr) do
            table.insert(attr_list,val)
        end
    end
    return attr_list
end
function RollerModel:getNowTalentStepLv()
    local order = self.roller_talent_order or 0
    local lv = 0
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_talent[order]
    if cfg then
        for k, v in pairs(cfg) do
            local id = v.id
            local talent_quality = v.talent_quality
            if talent_quality == 2 or talent_quality == 3 then
                local is_act = self:getTalentDataById(id)
                if is_act then
                    lv = lv + 1
                end
            end
        end
    end
    return order,lv
end
function RollerModel:getTotalTalentLvAndHighLvByIndex(index)
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_talent[index]
    local lv = 0
    local high_lv = 0
    for k, v in pairs(cfg) do
        local data = v
        lv = lv + 1
        local quality = v.talent_quality
        if quality == 3 or quality == 2 then
            high_lv = high_lv + 1
        end
    end
    return lv,high_lv
end
function RollerModel:getActiveTotalTalentLvAndHighLvByIndex(index)
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_talent[index]
    local lv = 0
    local high_lv = 0
    for i, v in pairs(cfg) do
        local id = v.id
        local data = self:getTalentDataById(id)
        if data then
            lv = lv + 1
            local quality = v.talent_quality
            if quality == 3 or quality == 2 then
                high_lv = high_lv + 1
            end
        end
    end
    return lv,high_lv
end
--能否装备
function RollerModel:checkIsCanEquip(partner_id,roller_id)
    local roller_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[roller_id]
    local hero_data = HeroController:getInstance():getModel():getHeroById(partner_id)
    local equip_cond = roller_cfg.dress_cond
    local max_val = 0
    for k, v in pairs(equip_cond) do
        local con_mark = v[1]
        local con_num = v[2]
        if con_mark == "partner_star" then
            max_val = hero_data.star
            if con_num > max_val then
                return false, string.format(roller_cfg.dress_cond_desc,con_num)
            end
        end
    end
    return true
end
--能否激活
function RollerModel:checkActiveCondition(roller_id)
    local roller_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[roller_id]
    local unlock_cond = roller_cfg.unlock_cond
    -- {{'partner_num_star',1,5}}
    for k, v in pairs(unlock_cond) do
        local con_mark = v[1]
        if con_mark == "partner_num_star" then
            local need_star = v[3]
            local need_num = v[2]
            local is_enough = HeroController:getInstance():getModel():checkIsEnoughStarNum(need_star,need_num)
            if not is_enough then
                return false , string.format(roller_cfg.unlock_cond_desc,need_num,need_star)
            end
        end
    end
    return true
end
--卷轴天赋开启条件
function RollerModel:checkTalentCondition()
    local base_cfg = Config.ProhibitedScrollData.data_get_constant["scroll_curse_open"]
    local val = base_cfg.val
    local roller_num = tableLen(self.roller_list)
    if roller_num>= val then
        return true
    end
    return false
end
function RollerModel:checkNowTalentActiveStatus()
    local roller_list = self:getTalentData()
    local talent_condition = self:checkTalentCondition()
    if next(roller_list) or talent_condition then
        return true
    end
    return false
end
--封印的额外属性
function RollerModel:getExtralFengYinAttrById(roller_id)
    local roller_data = self:getRollerDataById(roller_id)
    local total_lv = roller_data.seal

    local abse_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[roller_id]
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal_resonate[abse_cfg.quality]
    local show_list = {}
    for k, v in pairs(cfg) do
        table.insert(show_list,v)
    end
    local function sortFunc( objA, objB )
		return objA.level < objB.level
	end
	table.sort(show_list, sortFunc)
    local attr = {}
    for i = 1, #show_list do
        local data = show_list[i] -- level
        local next_data = show_list[i+1]
        if data.level <= total_lv then
            if next_data and data.level > total_lv then
                attr = data.attrs
            else
                attr = data.attrs
            end
        end
    end
    return attr
end
--根据星级判断封印最高等级
function RollerModel:getFengyinMaxLvByStar(quality,lv)
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_seal_total[quality]
    local data 
    for k, v in pairs(cfg) do
        local min_lv = v.level_min
        local max_lv = v.level_max
        if min_lv <= lv and max_lv >= lv then
            return v.next_star
        end
    end
    return
end

--天赋能否激活
function RollerModel:getTalentOpenCondition(index)
    if index == 2 then
        local lv,high_lv = self:getTotalTalentLvAndHighLvByIndex(1)
        local act_lv,act_high_lv = self:getActiveTotalTalentLvAndHighLvByIndex(1)
        if high_lv > act_high_lv then
            return false,string.format(TI18N("语言_c_7231"),high_lv)
        end
    elseif index == 3 then
        local lv,high_lv = self:getTotalTalentLvAndHighLvByIndex(2)
        local act_lv,act_high_lv = self:getActiveTotalTalentLvAndHighLvByIndex(2)
        if high_lv > act_high_lv then
            return false,string.format(TI18N("语言_c_7232"),high_lv)
        end
    end
    return true
end
--天赋能否激活
function RollerModel:getTalentOpenConditionById(talent_id)
    local cfg = self:getRollerTalentInfo(talent_id)
    local limit_cond = cfg.limit_cond[1]
    local str = ""
    local lock = true
    if limit_cond then
        local cond_key = limit_cond[1]
        if cond_key == 'pre_scroll_talent_total_lv' then
            local cond_list = limit_cond[2]
            for k, v in pairs(cond_list) do
                local t_id = v
                local _cfg = self:getRollerTalentInfo(t_id)
                local t_data = self:getTalentDataById(t_id)
                if not t_data then
                    lock = false
                end
                str = TI18N("语言_c_7230")--str..string_format("%s阶%s级",_cfg.group,lv)
            end
        elseif cond_key == 'scroll_talent_order' then
            local cond_ = limit_cond[2]
            local cond_num = limit_cond[3]
            local _cfg = Config.ProhibitedScrollData.data_get_proh_scroll_talent[cond_]
            local num = 0
            for k, v in pairs(_cfg) do
                if v.talent_quality == 2 or v.talent_quality == 3 then
                    local t_id = v.id
                    local t_data = self:getTalentDataById(t_id)
                    if t_data then
                        num = num + 1
                    end
                end
            end
            if num < cond_num then
                lock = false
                str = TI18N("语言_c_7229")--string_format("%s阶%s个高级阵位",cond_,cond_num)
            end
        end
    end
    return lock,str
end
function RollerModel:getMaxStarById(id)
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll[id]
    local max_star = cfg.max_star
    return max_star
end
--获取某阶天赋等级
function RollerModel:getTalentInfoLevelById(step)
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_talent[step]
    local num = 0
    local max_num = 0
    for k, v in pairs(cfg) do
        local id = v.id
        if v.talent_quality == 3 or v.talent_quality == 2 then
            local t_data = self:getTalentDataById(id)
            if t_data then
                num = num + 1
            end
            max_num = max_num + 1
        end
    end
    return num, max_num
end





--红点
function RollerModel:checkActiveStatusById(roller_id) --激活
    local unlock_status = self:checkActiveCondition(roller_id)
    if unlock_status then
        local roller_data = self:getRollerDataById(roller_id)
        if roller_data then
            return false
        end
        local cfg = Config.ProhibitedScrollData.data_get_proh_scroll[roller_id]
        local cost = cfg.cost[1]
        local cost_id = cost[1]
        local cost_num = cost[2]
        local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
        if own_num >= cost_num then
            return true
        end
    end
    return false
end
function RollerModel:checkUpStarStatusByRollerId(roller_id) --升星
    local roller_data = self:getRollerDataById(roller_id)
    if roller_data then
        local star = roller_data.star
        local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[roller_id]
        local star_cfg = cfg[star]
        local cost = star_cfg["cost"][1]
        if cost then
            local cost_id = cost[1]
            local cost_num = cost[2]
            local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
            if own_num >= cost_num then
                return true
            end
        end
    end
    return false
end
function RollerModel:checkUpGradeStatusByRollerId(roller_id) --升级
    local roller_data = self:getRollerDataById(roller_id)
    if roller_data then
        local lev = roller_data.lev
        local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[roller_id]
        local quality = base_cfg.quality
        local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_enhance[quality]
        local up_cfg = cfg[lev]
        local cost = up_cfg["cost"][1]
        if cost then
            local cost_id = cost[1]
            local cost_num = cost[2]
            local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
            if own_num >= cost_num then
                return true
            end
        end
    end
    return false
end
function RollerModel:checkUpFengyinStatusByRollerId(roller_id) --附魔
    local roller_data = self:getRollerDataById(roller_id)
    if roller_data then
        local seal = roller_data.seal
        local star = roller_data.star

        local max_lv = self:getMaxFengyinLv(roller_id)
        if seal >= max_lv then
            return false
        end

        local const_cfg = Config.ProhibitedScrollData.data_get_constant.sealing_consumption
        local cost_info = const_cfg.val[1]
        local cost_id = cost_info[1]
        local cost_num = cost_info[2]

        local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
        if own_num >= cost_num then
            local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[roller_id]
            local quality = base_cfg.quality
            local need_star = self:getFengyinMaxLvByStar(quality,seal)
            if star >= need_star then
                return true
            end
        end
    end
    return false
end

function RollerModel:checkTujianStatus() --图鉴
    local rolle_list = self.roller_list
    for k, v in pairs(rolle_list) do
        local star_reward = v.star_awards
        if tableLen(star_reward) > 0 then
            return true
        end
    end
    return false
end

function RollerModel:checkTalentActiveStatusById(id) --天赋
    local is_active = self:getTalentDataById(id)
    if is_active then
    else
        local lock = self:getTalentOpenConditionById(id)
        if lock then
            local talent_cfg = self:getRollerTalentInfo(id)
            local cost = talent_cfg.cost[1]
            local cost_id = cost[1]
            local cost_num = cost[2]
            local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
            if own_num >= cost_num then
                return true
            end
        end
    end
    return false
end

function RollerModel:checkTalentPageStatusByIndex(index)
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_talent[index]
    for k, v in pairs(cfg) do
        local id = v.id
        local status = self:checkTalentActiveStatusById(id)
        if status then
            return true
        end
    end
    return false
end

function RollerModel:mainEnterStatus()
    local open_status = self:checkRollerFunctionOpenStatus()
    if open_status then
        local red_1 = false
        -- local red_1 = self:checkTujianStatus()
        -- if red_1 then
        --     self:setRedStatus(true)
        --     return
        -- end
    
        local red_2 = self:CheckAllRollerStatus()
        if red_2 then
            self:setRedStatus(true)
            return
        end
    
        local red_3 = false
        -- local talent_open = self:checkTalentCondition()
        -- if talent_open then
        --     red_3 = self:CheckAllTalentStatus()
        -- end
        -- if red_3 then
        --     self:setRedStatus(true)
        --     return
        -- end
        
        local red_4 = self:getRollerLibraryRedPoint()
        if red_4 then
            self:setRedStatus(true)
            return
        end

        local red_5 = self:getRollerChoujiangRedStatus()
        if red_5 then
            self:setRedStatus(red_5)
            return
        end

        local status = red_1 or red_2 or red_3 or red_4
        self:setRedStatus(status)
    else
        self:setRedStatus(false)
    end
end

function RollerModel:CheckAllRollerStatus()
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll
    local red_2 = false
    for i, v in pairs(cfg) do
        local roller_id = v.id
        local roller_data = self:getRollerDataById(roller_id)
        if roller_data then
            local _is_upgrade = self:checkUpGradeStatusByRollerId(roller_id)
            if _is_upgrade then
                red_2 = true
                break
            end
            local _is_upstar = self:checkUpStarStatusByRollerId(roller_id)
            if _is_upstar then
                red_2 = true
                break
            end
            local _is_upfengyin = self:checkUpFengyinStatusByRollerId(roller_id)
            if _is_upfengyin then
                red_2 = true
                break
            end
        else
            local _is_act = self:checkActiveStatusById(roller_id)
            if _is_act then
                red_2 = true
                break
            end
        end
    end
    if red_2 then
        return true
    end
    return false
end
function RollerModel:CheckAllTalentStatus()
    local red_3 = false
    local talent_open = self:checkTalentCondition()
    if talent_open then
        local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_talent
        for k, v in pairs(cfg) do
            local _list = v
            for key, val in pairs(_list) do
                local id = val.id
                local _si_talent = self:checkTalentActiveStatusById(id)
                if _si_talent then
                    red_3 = true
                    break
                end
            end
        end
    end
    if red_3 then
        return true
    end
    return false
end

function RollerModel:getBackpackRedStatus()
    local cfg = Config.ProhibitedScrollData.data_get_patch
    local status = false
    for k, v in pairs(cfg) do
        local roller_id = v.scroll_id
        local roller_data = RollerController:getInstance():getModel():getRollerDataById(roller_id)
        if roller_data then
            local star = roller_data.star
            local _cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[roller_id]
            local star_cfg = _cfg[star]
            local cost = star_cfg.cost
            if next(cost) then
                local cost_info = cost[1]
                local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_info[1])
                if own_num >= cost_info[2] then
                    status = true
                    break
                end
            end
        else
            local cfg = Config.ProhibitedScrollData.data_get_proh_scroll[roller_id]
            local cost_data = cfg.cost[1]
            local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_data[1])
            if own_num >= cost_data[2] then
                status = true
                break
            end
        end
    end
    return status
end

function RollerModel:setRedStatus(status)
    -- if status ~= self.red_status then
        self.red_status = status or false
        MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.treasure, { bid = JinqiConst.Red_Type.roller, status = self.red_status })
        GlobalEvent:getInstance():Fire(RollerEvent.UpdateRedStatus)
    -- end
end
function RollerModel:getRedStatus()
    return self.red_status
end

function RollerModel:getRollerIdByChipId(chip_id)
    local cfg = Config.ProhibitedScrollData.data_get_patch[chip_id]
    local scroller_id = cfg.scroll_id
    return scroller_id
end

----------------------------------新版图鉴----------------------------------------------------
function RollerModel:setRollerLibraryData( data )
    self.roller_library_data = {}
    if data and data.books then 
        for k , v in pairs(data.books) do 
            self.roller_library_data[v.book_id] = true 
        end  
    end
    self:mainEnterStatus()
end 

function RollerModel:getRollerLibraryData( ) 
    return self.roller_library_data or {}
end 

function RollerModel:getRollerGroupData( )
    if not self.group_list then 
        self.group_list = {}
        for i = 1, Config.ProhibitedScrollData.data_get_scroll_hand_book_length do 
            local data = Config.ProhibitedScrollData.data_get_scroll_hand_book(i)
            if not self.group_list[data.group] then 
                self.group_list[data.group] = {}
            end
            data.attr = {}
            for k , v in pairs(data.attr3) do 
                table.insert(data.attr,v) 
            end  
            for k , v in pairs(data.attr4) do 
                table.insert(data.attr,v)
            end 
            
            table.insert(self.group_list[data.group],data) 
        end   
    end 
    return self.group_list
end
function RollerModel:getRollerLibraryCanLevUp( data )
    for i = 1 ,2 do 
        local need_id = data["need_id"..i]
        if need_id ~= 0 then
            local need_star = data["need_star"..i]
            local roller_data = self:getRollerDataById(need_id) 
            if roller_data then 
                if roller_data.star < need_star  then 
                    return false 
                end 
            else 
                return false 
            end
        end
    end  
    return true 
end

function RollerModel:getRollerLibraryRedPoint( )
    local activation_data = self:getRollerLibraryData()
    for index = 1, Config.ProhibitedScrollData.data_get_scroll_hand_book_length do 
        local config = Config.ProhibitedScrollData.data_get_scroll_hand_book(index)
        if not activation_data[config.id] then
            local canLevUp = self:getRollerLibraryCanLevUp(config)
            if canLevUp then
                return true
            end
        end
    end
    return false
end

---------------------------卷轴抽奖----------------------------------------------------------
function RollerModel:setRollerSummonData(data)
	self.roller_summon_data = data
    self:getRollerChoujiangRedStatus()
end
function RollerModel:getRollerSummonData()
	return self.roller_summon_data
end
function RollerModel:setRollerPrivilegeData(data)
	self.roller_privilege_data = data
end
function RollerModel:getRollerPrivilegeData()
	return self.roller_privilege_data
end
function RollerModel:getRollerPrivilegeStatus()
    local data = self:getRollerPrivilegeData()
    if data then
        if data.buy_time and data.buy_time > 0 then
            return true
        else
            return false
        end
    end
    return false
end
--召唤红点
function RollerModel:getRollerChoujiangRedStatus()
    -- local const_cfg = Config.ProhibitedScrollData.data_get_constant
    local data = self:getRollerSummonData()
    if not data then return false end
    local cur_time = GameNet:getInstance():getTime()
    local status = false
    if data.free_time and data.free_time <= cur_time then
        self:setRedStatus(true)
        status = true
        return true
    end
    local item_id = nil
	if data.lucky_ids ~= nil and next(data.lucky_ids) ~= nil then
		for k,v in pairs(data.lucky_ids) do
			item_id = v.lucky_prohs_bid
			break
		end
	end
	if item_id then
	else
		local vip_status = self:getRollerPrivilegeStatus()
		if vip_status then
            self:setRedStatus(true)
			status = true
		end
	end
    return status
end

function RollerModel:getRollerSkillAct(id)
    local cfg = deepCopy(Config.ProhibitedScrollData.data_get_unlock_info[id])
    if cfg then
        local cost_list = cfg.unlock_cost
        for key, value in pairs(cost_list) do
            local num = BackpackController:getInstance():getModel():getItemNumByBid(value[1])
            if num < value[2] then
                return false
            end
        end
        if not self:checkSingleStarFuseRedPointByStarConfig(cfg) then
            return false
        end
    else
        return false
    end
    return true
end

function RollerModel:checkSingleStarFuseRedPointByStarConfig(star_config)
    if not star_config then return false end
    --特定条件数据 结构 dic_the_conditions[bid][星级] = 数量
    local dic_the_conditions = {}
    --随机条件 dic_random_conditions[阵营][星级] = 数量
    local dic_random_conditions = {}
    --标志已用
    local dic_hero_id = {}
    local need_count = 0
    if next(star_config.unlock_expend2) then
        for i,expend in ipairs(star_config.unlock_expend2) do
            --指定的 {10402,4,1} : 10402: 表示bid, 4: 表示星级 1:表示数量
            local bid, star, count = expend[1], expend[2], expend[3]
            if dic_the_conditions[bid] == nil then
                dic_the_conditions[bid] = {}
            end
            if dic_the_conditions[bid][star] == nil then
                dic_the_conditions[bid][star] = count
            else
                dic_the_conditions[bid][star] = dic_the_conditions[bid][star] + count
            end
            need_count = need_count + count
        end
    end
    -- --随机的 {1,4,2} : 1 表示阵营  4: 表示星级 2表示数量
    -- for i,expend in ipairs(star_config.lev_up_expend3) do
    --     local camp, star, count = expend[1], expend[2], expend[3]
    --     if dic_random_conditions[camp] == nil then
    --         dic_random_conditions[camp] = {}
    --     end
    --     if dic_random_conditions[camp][star] == nil then
    --         dic_random_conditions[camp][star] = count
    --     else
    --         dic_random_conditions[camp][star] = dic_random_conditions[camp][star] + count
    --     end
    --     need_count = need_count + count
    -- end
    --获取列表
    local total_count =  HeroController:getInstance():getModel():getHeroListByMatchInfo(dic_the_conditions, dic_random_conditions, dic_hero_id)
    return total_count >= need_count, need_count, total_count
end
function RollerModel:__delete()
end