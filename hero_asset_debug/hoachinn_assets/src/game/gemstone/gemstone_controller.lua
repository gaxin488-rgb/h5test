-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- (必填, 创建模块的人员)
-- (必填, 后续维护以及修改的人员)
-- @description:
--     羁绊宝石
-- <br/>Create: 2017-02-28
-- --------------------------------------------------------------------
GemstoneController = GemstoneController or BaseClass(BaseController)

function GemstoneController:config()
    self.model = GemstoneModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function GemstoneController:getModel()
    return self.model
end

function GemstoneController:registerEvents()
    if self.init_role_event == nil then
		self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
			GlobalEvent:getInstance():UnBind(self.init_role_event)
			self.init_role_event = nil
			self:needRequireData()
		end)
	end
	
	-- 断线重连的时候要请求一下全部的活动图标,最好要关闭掉所有打开的 活动面板,并且把活动数据全清掉
	if self.re_link_game_event == nil then
		self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
			self:needRequireData(true)
		end)
	end
end

--- 断线重连或者0点更新或者初始化需要请求的
function GemstoneController:needRequireData(force)
	ActionController:getInstance():sender16808(ActionStorageBool.gemIsSkipSmelt)
end
function GemstoneController:registerProtocals()
    self:RegisterProtocal(22800, "handle22800")     --基础信息
    self:RegisterProtocal(22801, "handle22801")     --装备卸下宝石 
    self:RegisterProtocal(22802, "handle22802")     --位置升级
    self:RegisterProtocal(22803, "handle22803")     --位置突破
    self:RegisterProtocal(22804, "handle22804")     --合成
    self:RegisterProtocal(22805, "handle22805")     --分解
    self:RegisterProtocal(22807, "handle22807")     --熔炼值
    self:RegisterProtocal(22808, "handle22808")     --熔炼值奖励领取
    self:RegisterProtocal(22809, "handle22809")     --宝石锁定
    self:RegisterProtocal(22810, "handle22810")     --宝石解锁
    self:RegisterProtocal(22811, "handle22811")     --重铸
    self:RegisterProtocal(22812, "handle22812")     --重铸保存
    self:RegisterProtocal(22813, "handle22813")     --查看他人宝石信息
    self:RegisterProtocal(22814, "handle22814")     --宝石槽位回退
    self:RegisterProtocal(22815, "handle22815")     --宝石槽位回退预览
end

--根据列表请求伙伴宝石所有详细信息
function GemstoneController:sender22800(list)
    local protocal ={}
    protocal.list = list
    self:SendProtocal(22800,protocal)
end

function GemstoneController:handle22800(data)
    self.model:updateGemstoneList(data)
end
--装备卸下宝石 type0卸下 1穿戴 3卸下全部
function GemstoneController:sender22801(pid,item_id,pos,type)
    local protocal ={}
    protocal.pid = pid
    protocal.item_id = item_id
    protocal.pos = pos
    protocal.type = type
    self:SendProtocal(22801,protocal)
end

function GemstoneController:handle22801(data)
    message(data.msg)
    self:openGemstoneTipsWindow(false)
end
--位置升级
function GemstoneController:sender22802(pid,pos,items)
    local protocal ={}
    protocal.pid = pid
    protocal.pos = pos
    protocal.items = items
    self:SendProtocal(22802,protocal)
end

function GemstoneController:handle22802(data)
    message(data.msg)    
end
--位置突破
function GemstoneController:sender22803(pid,pos)
    local protocal ={}
    protocal.pid = pid
    protocal.pos = pos
    self:SendProtocal(22803,protocal)
end

function GemstoneController:handle22803(data)
    message(data.msg)
end
--合成
function GemstoneController:sender22804(type,list,item_num)
    local protocal ={}
    protocal.type = type
    protocal.list = list
    protocal.item_num = item_num or 1
    self:SendProtocal(22804,protocal)
end

function GemstoneController:handle22804(data)
    message(data.msg)
    if data.result == 1 then
        GlobalEvent:getInstance():Fire(GemstoneEvent.Artifact_Compound_Event)
    end
end
--分解
function GemstoneController:sender22805(list)
    local protocal ={}
    protocal.list = list
    self:SendProtocal(22805,protocal)
end

function GemstoneController:handle22805(data)
    message(data.msg)
end
--熔炼值
function GemstoneController:sender22807()
    local protocal ={}
    self:SendProtocal(22807,protocal)
end

function GemstoneController:handle22807(data)
    if data and data.val then
        self.model:setGemArtifactNum(data.val)
    end
    GlobalEvent:getInstance():Fire(GemstoneEvent.Artifact_Lucky_Event)
end
--熔炼值奖励领取
function GemstoneController:sender22808()
    local protocal ={}
    self:SendProtocal(22808,protocal)
end

function GemstoneController:handle22808(data)
    message(data.msg)
end
--宝石锁定
function GemstoneController:sender22809(p_id,pos,item_id)
    local protocal ={}
    protocal.p_id = p_id
    protocal.pos = pos
    protocal.item_id = item_id
    self:SendProtocal(22809,protocal)
end

function GemstoneController:handle22809(data)
    message(data.msg)
end
--宝石解锁
function GemstoneController:sender22810(p_id,pos,item_id)
    local protocal ={}
    protocal.p_id = p_id
    protocal.pos = pos
    protocal.item_id = item_id
    self:SendProtocal(22810,protocal)
end

function GemstoneController:handle22810(data)
    message(data.msg)
end
--宝石重铸
function GemstoneController:sender22811(p_id,pos,item_id)
    local protocal ={}
    protocal.p_id = p_id
    protocal.pos = pos
    protocal.item_id = item_id
    self:SendProtocal(22811,protocal)
end
function GemstoneController:handle22811(data)
    message(data.msg)
end

--宝石重铸保存
function GemstoneController:sender22812(p_id,pos,item_id)
    local protocal ={}
    protocal.p_id = p_id
    protocal.pos = pos
    protocal.item_id = item_id
    self:SendProtocal(22812,protocal)
end
function GemstoneController:handle22812(data)
    message(data.msg)
end
--宝石重铸保存
function GemstoneController:sender22813(r_rid,r_srvid,partner_id)
    local protocal ={}
    protocal.r_rid = r_rid
    protocal.r_srvid = r_srvid
    protocal.partner_id = partner_id
    self:SendProtocal(22813,protocal)
end
function GemstoneController:handle22813(data)
    local list = {}
    for k, v in pairs(data.list_info) do
        list[v.pos] = v
    end
    data.list_info = list
    GlobalEvent:getInstance():Fire(GemstoneEvent.Show_Gem_Info_Event,data)
end
--宝石槽位回退
function GemstoneController:sender22814(p_id)
    local protocal ={}
    protocal.p_id = p_id
    self:SendProtocal(22814,protocal)
end
function GemstoneController:handle22814(data)
    message(data.msg)
end
--宝石槽位回退预览
function GemstoneController:sender22815(p_id)
    local protocal ={}
    protocal.p_id = p_id
    self:SendProtocal(22815,protocal)
end
function GemstoneController:handle22815(data)
    GlobalEvent:getInstance():Fire(GemstoneEvent.Gem_Reset_Offer_Event ,data)
end

--打开宝石羁绊熔炼值奖励领取
function GemstoneController:openGemstoneAwardWindow(status)
    if status then
        if not self.gemstone_award_window then
            self.gemstone_award_window = GemstoneAwardWindow.New()
        end
        self.gemstone_award_window:open()
    else
        if self.gemstone_award_window then 
            self.gemstone_award_window:close()
            self.gemstone_award_window = nil
        end
    end
end
--打开宝石背包
function GemstoneController:openGemstoneBagWindow(status)
    if status then
        if not self.gemstone_bag_window then
            self.gemstone_bag_window = GemstoneBagWindow.New()
        end
        self.gemstone_bag_window:open()
    else
        if self.gemstone_bag_window then 
            self.gemstone_bag_window:close()
            self.gemstone_bag_window = nil
        end
    end
end
--打开宝石分解
function GemstoneController:openGemstoneRemoveWindow(status)
    if status then
        if not self.gemstone_remove_window then
            self.gemstone_remove_window = GemstoneRemoveWindow.New()
        end
        self.gemstone_remove_window:open()
    else
        if self.gemstone_remove_window then 
            self.gemstone_remove_window:close()
            self.gemstone_remove_window = nil
        end
    end
end
--宝石熔炼选择
function GemstoneController:openGemstoneChoseWindow(status,data)
    if status then
        if not self.gemstone_chose_window then
            self.gemstone_chose_window = GemstoneChoseWindow.New()
        end
        self.gemstone_chose_window:open(data)
    else
        if self.gemstone_chose_window then 
            self.gemstone_chose_window:close()
            self.gemstone_chose_window = nil
        end
    end
end
--宝石装备选择
function GemstoneController:openGemstoneEquipWindow(status,hero_id,pos)
    if status then
        if not self.gemstone_equip_window then
            self.gemstone_equip_window = GemstoneEquipWindow.New()
        end
        self.gemstone_equip_window:open(hero_id,pos)
    else
        if self.gemstone_equip_window then 
            self.gemstone_equip_window:close()
            self.gemstone_equip_window = nil
        end
    end
end
--宝石预览
function GemstoneController:openGemstonePreviewWindow(status)
    if status then
        if not self.gemstone_preview_window then
            self.gemstone_preview_window = GemstonePreviewWindow.New()
        end
        self.gemstone_preview_window:open()
    else
        if self.gemstone_preview_window then 
            self.gemstone_preview_window:close()
            self.gemstone_preview_window = nil
        end
    end
end
--宝石预览 type 1技能预览 2保底技能预览
function GemstoneController:openGemstonePreviewSkillWindow(status,item_id,type)
    if status then
        if not self.gemstone_preview_skill_window then
            self.gemstone_preview_skill_window = GemstonePreviewSkillWindow.New()
        end
        self.gemstone_preview_skill_window:open(item_id,type)
    else
        if self.gemstone_preview_skill_window then 
            self.gemstone_preview_skill_window:close()
            self.gemstone_preview_skill_window = nil
        end
    end
end
--宝石共鸣
function GemstoneController:openGemstoneResonanceWindow(status)
    if status then
        if not self.gemstone_resonance_window then
            self.gemstone_resonance_window = GemstoneResonanceWindow.New()
        end
        self.gemstone_resonance_window:open()
    else
        if self.gemstone_resonance_window then 
            self.gemstone_resonance_window:close()
            self.gemstone_resonance_window = nil
        end
    end
end
--宝石技能tips type 1普通2预览
function GemstoneController:openGemstoneSkillTipsWindow(status,hero_vo,type)
    if status then
        if not self.gemstone_skill_tips_window then
            self.gemstone_skill_tips_window = GemstoneSkillTipsWindow.New()
        end
        self.gemstone_skill_tips_window:open(hero_vo,type)
    else
        if self.gemstone_skill_tips_window then 
            self.gemstone_skill_tips_window:close()
            self.gemstone_skill_tips_window = nil
        end
    end
end
--宝石强化
--pid 忍者唯一id
--pos 槽位
function GemstoneController:openGemstoneStrengthenWindow(status,setting)
    if status then
        if not self.gemstone_strengthen_window then
            self.gemstone_strengthen_window = GemstoneStrengthenWindow.New()
        end
        self.gemstone_strengthen_window:open(setting)
    else
        if self.gemstone_strengthen_window then 
            self.gemstone_strengthen_window:close()
            self.gemstone_strengthen_window = nil
        end
    end
end
--宝石tips
-- setting.data 宝石基本信息 --配置表 or 物品id
-- setting.gem_list 宝石属性信息  背包
-- setting.pos_list 槽位基本信息  已装备
-- setting.pid 忍者唯一id  已装备
function GemstoneController:openGemstoneTipsWindow(status,setting)
    if status then
        if not self.gemstone_tips_window then
            self.gemstone_tips_window = GemstoneTipsWindow.New()
        end
        self.gemstone_tips_window:open(setting)
    else
        if self.gemstone_tips_window then 
            self.gemstone_tips_window:close()
            self.gemstone_tips_window = nil
        end
    end
end
--宝石预览tips
-- setting.data 宝石基本信息 --配置表 or 物品id
-- setting.gem_list 宝石属性信息
function GemstoneController:openGemstonePreviewTipsWindow(status,setting)
    if status then
        if not self.gemstone_tips_window then
            self.gemstone_tips_window = GemstonePreviewTipsWindow.New()
        end
        self.gemstone_tips_window:open(setting)
    else
        if self.gemstone_tips_window then 
            self.gemstone_tips_window:close()
            self.gemstone_tips_window = nil
        end
    end
end
--宝石洗练
-- setting.data 宝石基本信息 --配置表 or 物品id
-- setting.gem_list 宝石属性信息  背包
-- setting.pos_list 槽位基本信息  已装备
-- setting.pid 忍者唯一id  已装备
function GemstoneController:openGemstoneRecastPanel(status,setting)
    if status then
        if not self.gemstone_recast_panel then
            self.gemstone_recast_panel = GemstoneRecastPanel.New()
        end
        self.gemstone_recast_panel:open(setting)
    else
        if self.gemstone_recast_panel then 
            self.gemstone_recast_panel:close()
            self.gemstone_recast_panel = nil
        end
    end
end
--宝石装备强化批量选择
function GemstoneController:openGemstoneStrengSelectItemPanel(status,item_bid,data)
    if status == true then
        if not self.gemstone_streng_select_item_panel then
            self.gemstone_streng_select_item_panel = GemstoneStrengSelectItemPanel.New()
        end
        self.gemstone_streng_select_item_panel:open(item_bid,data)
    else
        if self.gemstone_streng_select_item_panel then 
            self.gemstone_streng_select_item_panel:close()
            self.gemstone_streng_select_item_panel = nil
        end
    end
end
--宝石buff预览  open_type1功能界面 2布阵界面
function GemstoneController:openGemstoneBuffView(status,open_type,setting)
    if status == true then
        if not self.gemstone_buff_view then
            self.gemstone_buff_view = GemstoneBuffView.New()
        end
        self.gemstone_buff_view:open(open_type,setting)
    else
        if self.gemstone_buff_view then 
            self.gemstone_buff_view:close()
            self.gemstone_buff_view = nil
        end
    end
end
--宝石buff预览  open_type1功能界面 2布阵界面
function GemstoneController:openGemstoneResetOfferPanel(bool,data,call_back)
    if bool == true then
        if not self.gemstone_reset_offer_panel then
            self.gemstone_reset_offer_panel = GemstoneResetOfferPanel.New()
        end
        self.gemstone_reset_offer_panel:open(data,call_back)
    else
        if self.gemstone_reset_offer_panel then 
            self.gemstone_reset_offer_panel:close()
            self.gemstone_reset_offer_panel = nil
        end
    end
end
--宝石成就解锁
function GemstoneController:openGemstoneKeyPanel(bool)
    if bool == true then
        if not self.gemstone_key_panel then
            self.gemstone_key_panel = GemstoneKeyPanel.New()
        end
        self.gemstone_key_panel:open()
    else
        if self.gemstone_key_panel then 
            self.gemstone_key_panel:close()
            self.gemstone_key_panel = nil
        end
    end
end