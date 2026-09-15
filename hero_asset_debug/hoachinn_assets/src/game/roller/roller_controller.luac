RollerController = RollerController or BaseClass(BaseController)

function RollerController:config()
    self.model = RollerModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function RollerController:getModel()
    return self.model
end

function RollerController:registerEvents()
    -- if self.init_event == nil then
    --     self.init_event = self.dispather:Bind(HeroEvent.Hero_Resonate_Crystal_Info_Event, function()
    --         GlobalEvent:getInstance():UnBind(self.init_event)
    --         self.model:setJinqiRedstatus()
    --     end)
    -- end
    -- RollerController:getInstance():openRollerActiveResultWindow(true,3106)
end

function RollerController:registerProtocals()
    self:RegisterProtocal(20800, "handle20800") --请求卷轴信息
    self:RegisterProtocal(20801, "handle20801") --单个卷轴信息
    self:RegisterProtocal(20802, "handle20802") --卷轴激活
    self:RegisterProtocal(20803, "handle20803") --卷轴强化
    self:RegisterProtocal(20804, "handle20804") --卷轴升星
    self:RegisterProtocal(20805, "handle20805") --卷轴封印
    self:RegisterProtocal(20806, "handle20806") --装备卷轴
    self:RegisterProtocal(20807, "handle20807") --卸下卷轴
    self:RegisterProtocal(20808, "handle20808") --卸下卷轴
    self:RegisterProtocal(20809, "handle20809") --卸下卷轴
    self:RegisterProtocal(20810, "handle20810") --卸下卷轴
    self:RegisterProtocal(20820, "handle20820") --请求卷轴天赋(奥义)信息
    self:RegisterProtocal(20821, "handle20821") --天赋激活
    self:RegisterProtocal(20822, "handle20822") --天赋重置
    self:RegisterProtocal(20823, "handle20823") --卸下卷轴
    self:RegisterProtocal(20824, "handle20824") --图鉴
    self:RegisterProtocal(20825, "handle20825") --激活图鉴
    self:RegisterProtocal(20826, "handle20826") 
    self:RegisterProtocal(20830, "handle20830") --英雄试玩
    self:RegisterProtocal(20831, "handle20831") --请求卷轴抽奖信息
    self:RegisterProtocal(20832, "handle20832") --卷轴抽奖
    self:RegisterProtocal(20833, "handle20833") --领取保底礼包
    self:RegisterProtocal(20834, "handle20834")
    self:RegisterProtocal(20835, "handle20835")
    self:RegisterProtocal(20836, "handle20836")

end
function RollerController:handle20810(data)
    -- print("handle20810+++++++++++++++",vardump(data))
    HeroController:getInstance():getModel():updateHeroVo(data)
    -- GlobalEvent:getInstance():Fire(HeroEvent.Hero_Detail_Data_Update, hero_vo)
end

function RollerController:sender20800()
    local protocal ={}
    self:SendProtocal(20800,protocal)
end
function RollerController:handle20800(data)
    -- print("handle20800",vardump(data))
    self.model:setRollerData(data)
    GlobalEvent:getInstance():Fire(RollerEvent.Update_Roller_Event)
end

function RollerController:sender20801(id)
    local protocal ={}
    protocal.id = id
    self:SendProtocal(20801,protocal)
end
function RollerController:handle20801(data)
    -- print("handle20801",vardump(data))
    self.model:updateSingleRollerData(data)
    GlobalEvent:getInstance():Fire(RollerEvent.Update_Roller_Event)
end

function RollerController:sender20802(id)
    local protocal ={}
    protocal.id = id
    self:SendProtocal(20802,protocal)
end
function RollerController:handle20802( data )
    -- print("handle20802",vardump(data))
    if data.result == 1 then
        self:openRollerActiveResultWindow(true,data.id)
        self:openRollerChipTipsWindow(false)
        GlobalEvent:getInstance():Fire(RollerEvent.Roller_Upstar_Result)
    end
end
function RollerController:sender20803(id)
    local protocal ={}
    protocal.id =id
    self:SendProtocal(20803,protocal)
end
function RollerController:handle20803( data )
    -- print("handle20803",vardump(data))
    if data.result == 1 then
        GlobalEvent:getInstance():Fire(RollerEvent.Roller_Strength_Effect)
    else
        message(data.msg)
    end
end
function RollerController:sender20804(id)
    local protocal ={}
    protocal.id = id
    self:SendProtocal(20804,protocal)
end
function RollerController:handle20804( data )
    -- print("handle20804",vardump(data))
    if data.result == 1 then
        self:openRollerUpstarResultWindow(true,data.id)
        GlobalEvent:getInstance():Fire(RollerEvent.Roller_Upstar_Result)
    end
end
function RollerController:sender20805(id)
    local protocal ={}
    protocal.id = id
    self:SendProtocal(20805,protocal)
end
function RollerController:handle20805( data )
    -- print("handle20805",vardump(data))
    -- self.model:setJinqiData(data)
    if data.result == 1 then
        GlobalEvent:getInstance():Fire(RollerEvent.Update_Roller_Fengyin_Eff,data)
    end
end
function RollerController:sender20806(id,partner_id)
    local protocal ={}
    protocal.id =id
    protocal.partner_id = partner_id
    self:SendProtocal(20806,protocal)
end
function RollerController:handle20806( data )
    -- print("handle20806",vardump(data))
    if data.result == 1 then
        message(TI18N("语言_c_7108"))
        self:openRollerEquipListWindow(false)
        self:openRollerChipTipsWindow(false)
        GlobalEvent:getInstance():Fire(RollerEvent.Roller_Equip_Event)
    end
end
function RollerController:sender20807(id,partner_id)
    local protocal ={}
    protocal.id =id
    protocal.partner_id = partner_id
    self:SendProtocal(20807,protocal)
end
function RollerController:handle20807( data )
    -- self.model:setJinqiData(data)
    if data.result == 1 then
        message(TI18N("语言_c_4558"))
        self:openRollerChipTipsWindow(false)
    end
    -- GlobalEvent:getInstance():Fire(JinqiEvent.UpdateAllData)
end
function RollerController:sender20808(id,partner_id)
    local protocal ={}
    protocal.id = id
    self:SendProtocal(20808,protocal)
end
function RollerController:handle20808( data )
    -- self.model:setJinqiData(data)
    -- GlobalEvent:getInstance():Fire(JinqiEvent.UpdateAllData)
end
function RollerController:sender20809(id,partner_id)
    local protocal ={}
    protocal.id = id
    self:SendProtocal(20809,protocal)
end
function RollerController:handle20809( data )
    -- print("handle20809",vardump(data))
    if data.result == 1 then
        GlobalEvent:getInstance():Fire(RollerEvent.Roller_GetTujianPoint_Event )
    end

    -- self.model:setJinqiData(data)
    -- GlobalEvent:getInstance():Fire(JinqiEvent.UpdateAllData)
end
function RollerController:sender20820(id,partner_id)
    local protocal ={}
    protocal.cli_order = 0
    self:SendProtocal(20820,protocal)
end
function RollerController:handle20820( data )
    -- print("handle20820",vardump(data))
    self.model:setRollerTalentData(data)
    GlobalEvent:getInstance():Fire(RollerEvent.Roller_Talent_Update_Event)
end
function RollerController:sender20821(id)
    local protocal ={}
    protocal.id = id
    self:SendProtocal(20821,protocal)
end
function RollerController:handle20821( data )
    -- print("handle20821",vardump(data))
    -- self.model:setJinqiData(data)
    if data.result == 1 then
        self.model:setSingleRollerTalentData(data)
        local cfg = self.model:getRollerTalentInfo(data.id)
        if cfg.talent_quality == 3 or cfg.talent_quality == 2 then
            self:openRollerTalentActiveResultWindow(true,data.id)
        end
        self:openRollerTalentNormalActiveWindow(false)
        self:openRollerTalentMainActiveWindow(false)
        GlobalEvent:getInstance():Fire(RollerEvent.Roller_Talent_Update_Event)
        GlobalEvent:getInstance():Fire(RollerEvent.Roller_Talent_Active_Event,data.id)
    end
end
function RollerController:sender20822()
    local protocal ={}
    self:SendProtocal(20822,protocal)
end
function RollerController:handle20822( data )
    -- self.model:setJinqiData(data)
    -- GlobalEvent:getInstance():Fire(JinqiEvent.UpdateAllData)
end
function RollerController:sender20830(id)
    local protocal ={}
    protocal.id = id
    self:SendProtocal(20830,protocal)
end
function RollerController:handle20830( data )

end

function RollerController:openRollerMainWindow(bool,index,setting)
    if bool == true then
        if not self.roller_main_window then
            self.roller_main_window = RollerMainWindow.New()
        end
        if self.roller_main_window then
            if self.roller_main_window:isOpen() == false then
                self.roller_main_window:open(index,setting)
            else
                self.roller_main_window:openRootWnd(index)
            end
        end
    else
        if self.roller_main_window then
            self.roller_main_window:close()
            self.roller_main_window = nil
        end
    end
end

function RollerController:openRollerInfoWindow(bool,index,roller_id)
    if bool == true then
        if not self.roller_info_main_window then
            self.roller_info_main_window = RollerInfoMainWindow.New()
        end
        if self.roller_info_main_window and self.roller_info_main_window:isOpen() == false then
            self.roller_info_main_window:open(index,roller_id)
        end
    else
        if self.roller_info_main_window then
            self.roller_info_main_window:close()
            self.roller_info_main_window = nil
        end
    end
end
function RollerController:openRollerUpstarResultWindow(bool)
    if bool == true then
        if not self.roller_upstar_result_window then
            self.roller_upstar_result_window = RollerUpstarResultWindow.New()
        end
        if self.roller_upstar_result_window and self.roller_upstar_result_window:isOpen() == false then
            self.roller_upstar_result_window:open()
        end
    else
        if self.roller_upstar_result_window then
            self.roller_upstar_result_window:close()
            self.roller_upstar_result_window = nil
        end
    end
end
function RollerController:openRollerFengyinResultWindow(bool,old_order,new_order,id)
    if bool == true then
        if not self.roller_fengyin_result_window then
            self.roller_fengyin_result_window = RollerFengyinResultWindow.New()
        end
        if self.roller_fengyin_result_window and self.roller_fengyin_result_window:isOpen() == false then
            self.roller_fengyin_result_window:open(old_order,new_order,id)
        end
    else
        if self.roller_fengyin_result_window then
            self.roller_fengyin_result_window:close()
            self.roller_fengyin_result_window = nil
        end
    end
end
function RollerController:openRollerChipTipsWindow(bool,setting)
    if bool == true then
        if not self.roller_chip_tips_window then
            self.roller_chip_tips_window = RollerChipsTipsWindow.New()
        end
        if self.roller_chip_tips_window and self.roller_chip_tips_window:isOpen() == false then
            self.roller_chip_tips_window:open(setting)--(roller_id,partner_id,type)
        end
    else
        if self.roller_chip_tips_window then
            self.roller_chip_tips_window:close()
            self.roller_chip_tips_window = nil
        end
    end
end

function RollerController:openRollerEquipListWindow(bool,partner_id)
    if bool == true then
        if not self.roller_equip_list_window then
            self.roller_equip_list_window = RollerEquipListWindow.New()
        end
        if self.roller_equip_list_window and self.roller_equip_list_window:isOpen() == false then
            self.roller_equip_list_window:open(partner_id)
        end
    else
        if self.roller_equip_list_window then
            self.roller_equip_list_window:close()
            self.roller_equip_list_window = nil
        end
    end
end
function RollerController:openRollerTalentMainWindow(bool,index)
    if bool == true then
        if not self.roller_talent_main_window then
            self.roller_talent_main_window = RollerTalentMainWindow.New()
        end
        if self.roller_talent_main_window and self.roller_talent_main_window:isOpen() == false then
            self.roller_talent_main_window:open(index)
        end
    else
        if self.roller_talent_main_window then
            self.roller_talent_main_window:close()
            self.roller_talent_main_window = nil
        end
    end
end
function RollerController:openRollerTalentMainActiveWindow(bool,index)
    if bool == true then
        if not self.roller_talent_active_main_window then
            self.roller_talent_active_main_window = RollerTalentActiveMainWindow.New()
        end
        self.roller_talent_active_main_window:open(index)
    else
        if self.roller_talent_active_main_window then
            self.roller_talent_active_main_window:close()
            self.roller_talent_active_main_window = nil
        end
    end
end
function RollerController:openRollerTalentNormalActiveWindow(bool,index)
    if bool == true then
        if not self.roller_talent_active_normal_window then
            self.roller_talent_active_normal_window = RollerTalentActiveNormalWindow.New()
        end
        if self.roller_talent_active_normal_window and self.roller_talent_active_normal_window:isOpen() == false then
            self.roller_talent_active_normal_window:open(index)
        end
    else
        if self.roller_talent_active_normal_window then
            self.roller_talent_active_normal_window:close()
            self.roller_talent_active_normal_window = nil
        end
    end
end
function RollerController:openRollerUpstarResultWindow(bool,index)
    if bool == true then
        if not self.roller_upstar_result_window then
            self.roller_upstar_result_window = RollerUpstarResultWindow.New()
        end
        if self.roller_upstar_result_window and self.roller_upstar_result_window:isOpen() == false then
            self.roller_upstar_result_window:open(index)
        end
    else
        if self.roller_upstar_result_window then
            self.roller_upstar_result_window:close()
            self.roller_upstar_result_window = nil
        end
    end
end

function RollerController:openRollerActiveResultWindow(bool,index)
    if bool == true then
        if not self.roller_active_result_window then
            self.roller_active_result_window = RollerActiveResultWindow.New()
        end
        if self.roller_active_result_window and self.roller_active_result_window:isOpen() == false then
            self.roller_active_result_window:open(index)
        end
    else
        if self.roller_active_result_window then
            self.roller_active_result_window:close()
            self.roller_active_result_window = nil
        end
    end
end
function RollerController:openRollerTalentPreviewWindow(bool,index,type)
    if bool == true then
        if not self.roller_talent_preview then
            self.roller_talent_preview = RollerTalentPreview.New()
        end
        if self.roller_talent_preview and self.roller_talent_preview:isOpen() == false then
            self.roller_talent_preview:open(index,type)
        end
    else
        if self.roller_talent_preview then
            self.roller_talent_preview:close()
            self.roller_talent_preview = nil
        end
    end
end
function RollerController:openRollerTalentActiveResultWindow(bool,id)
    if bool == true then
        if not self.roller_talent_active_result_window then
            self.roller_talent_active_result_window = RollerTalentActiveResultWindow.New()
        end
        if self.roller_talent_active_result_window and self.roller_talent_active_result_window:isOpen() == false then
            self.roller_talent_active_result_window:open(id)
        end
    else
        if self.roller_talent_active_result_window then
            self.roller_talent_active_result_window:close()
            self.roller_talent_active_result_window = nil
        end
    end
end
--共鸣预览
function RollerController:openRollerTalentToattrOverviewWindow(bool,id)
    if bool == true then
        if not self.roller_talent_toattr_overview then
            self.roller_talent_toattr_overview = RollerTalentToattrOverview.New()
        end
        if self.roller_talent_toattr_overview and self.roller_talent_toattr_overview:isOpen() == false then
            self.roller_talent_toattr_overview:open(id)
        end
    else
        if self.roller_talent_toattr_overview then
            self.roller_talent_toattr_overview:close()
            self.roller_talent_toattr_overview = nil
        end
    end
end
function RollerController:openRollerAllAttrOverviewWindow(bool,id)
    if bool == true then
        if not self.roller_talent_attr_overview_window then
            self.roller_talent_attr_overview_window = RollerTalentAttrOverviewWindow.New()
        end
        if self.roller_talent_attr_overview_window and self.roller_talent_attr_overview_window:isOpen() == false then
            self.roller_talent_attr_overview_window:open(id)
        end
    else
        if self.roller_talent_attr_overview_window then
            self.roller_talent_attr_overview_window:close()
            self.roller_talent_attr_overview_window = nil
        end
    end
end
function RollerController:openUpstarPreviewWindow(bool,id)
    if bool == true then
        if not self.roller_upstar_preview then
            self.roller_upstar_preview = RollerUpstarPreviewWindow.New()
        end
        if self.roller_upstar_preview and self.roller_upstar_preview:isOpen() == false then
            self.roller_upstar_preview:open(id)
        end
    else
        if self.roller_upstar_preview then
            self.roller_upstar_preview:close()
            self.roller_upstar_preview = nil
        end
    end
end
function RollerController:openRollerResetWindow(bool,data)
    if bool == true then
        if not self.roller_reset_window then
            self.roller_reset_window = RollerResetWindow.New()
        end
        if self.roller_reset_window and self.roller_reset_window:isOpen() == false then
            self.roller_reset_window:open(data)
        end
    else
        if self.roller_reset_window then
            self.roller_reset_window:close()
            self.roller_reset_window = nil
        end
    end
end
function RollerController:openRollerComTipsWindow(bool,data,setting)
    if bool == true then
        if not self.backpack_roller_tips then
            self.backpack_roller_tips = BackpackRollerTips.New()
        end
        if self.backpack_roller_tips and self.backpack_roller_tips:isOpen() == false then
            self.backpack_roller_tips:open(data,setting)
        end
    else
        if self.backpack_roller_tips then
            self.backpack_roller_tips:close()
            self.backpack_roller_tips = nil
        end
    end
end

function RollerController:sender20823(arr)
    local protocal ={}
    protocal.items = arr
    self:SendProtocal(20823,protocal)
end
function RollerController:handle20823( data )
 --   print("handle20823+++++",vardump(data))
    GlobalEvent:getInstance():Fire(RollerEvent.RollerFenjieSuccessEvent)
end

function RollerController:openJinqiFenjieSelectNumWindow(bool,id)
    if bool == true then
        if not self.jinqi_fenjie_selelct_window then
            self.jinqi_fenjie_selelct_window = JinqiDecomposeSelectWindow.New()
        end
        if self.jinqi_fenjie_selelct_window and self.jinqi_fenjie_selelct_window:isOpen() == false then
            self.jinqi_fenjie_selelct_window:open(id)
        end
    else
        if self.jinqi_fenjie_selelct_window then
            self.jinqi_fenjie_selelct_window:close()
            self.jinqi_fenjie_selelct_window = nil
        end
    end
end

function RollerController:openRollerFenjiePreviewWindow(bool,data)
    if bool == true then
        if not self.jinqi_fenjie_preview_window then
            self.jinqi_fenjie_preview_window = RollerDecomposeWindow.New()
        end
        if self.jinqi_fenjie_preview_window and self.jinqi_fenjie_preview_window:isOpen() == false then
            self.jinqi_fenjie_preview_window:open(data)
        end
    else
        if self.jinqi_fenjie_preview_window then
            self.jinqi_fenjie_preview_window:close()
            self.jinqi_fenjie_preview_window = nil
        end
    end
end

function RollerController:openCommonAttrWindow(status, attrList, des_str, type)
    if status == false then
        if self.common_attr_window ~= nil then
            self.common_attr_window:close()
            self.common_attr_window = nil
        end
    else
        if attrList and #attrList > 0 then
            if self.common_attr_window == nil then
                self.common_attr_window = CommonAttrWindow.New()
            end
            self.common_attr_window:open(attrList, des_str, type)
        else
            message(TI18N("语言_clo_01_5"))
        end
    end
end
-----------------------图鉴信息-----------------------------------------
function RollerController:sender20824()
    local protocal ={}
    self:SendProtocal(20824,protocal)
end
function RollerController:handle20824(data)
    self.model:setRollerLibraryData(data)
    GlobalEvent:getInstance():Fire(RollerEvent.UpdateRollerLibraryRedStatus)
end
function RollerController:sender20825(id)
    local protocal ={}
    protocal.id = id
    self:SendProtocal(20825,protocal)
end
function RollerController:handle20825(data)
    if data.flag == 1 then
        -- message(TI18N("语言_s_1785"))
    end
    GlobalEvent:getInstance():Fire(RollerEvent.UpdateRollerLibraryRedStatus)
end
function RollerController:openCommonAttrWindow(status, attrList, des_str, type)
    if status == false then
        if self.common_attr_window ~= nil then
            self.common_attr_window:close()
            self.common_attr_window = nil
        end
    else
        if attrList and #attrList > 0 then
            if self.common_attr_window == nil then
                self.common_attr_window = CommonAttrWindow.New()
            end
            self.common_attr_window:open(attrList, des_str, type)
        else
            message(TI18N("语言_clo_01_5"))
        end
    end
end
-----------------------------抽奖--------------------------------------------------------
function RollerController:sender20831()
    local protocal ={}
    self:SendProtocal(20831,protocal)
end
function RollerController:handle20831(data)
   -- print("handle20831",vardump(data))
    self.model:setRollerSummonData(data) 
    GlobalEvent:getInstance():Fire(RollerEvent.UpdateSummonData)
end
function RollerController:sender20832(times,recruit_type)
    local protocal ={}
    protocal.recruit_type = recruit_type
    protocal.times = times
    self:SendProtocal(20832,protocal)
end
function RollerController:handle20832(data)
   -- print("handle20832",vardump(data))
end
function RollerController:sender20833(id)
    local protocal ={}
    protocal.id = id
    self:SendProtocal(20833,protocal)
end
function RollerController:handle20833(data)
    -- GlobalEvent:getInstance():Fire(RollerEvent.UpdateRollerLibraryRedStatus)
end
function RollerController:sender20834()
    local protocal ={}
    self:SendProtocal(20834,protocal)
end
function RollerController:handle20834(data)
    self:openRollerSummonGainWindow(false)
	self:openRollerSummonGainWindow(true,data,TRUE)
end
function RollerController:sender20835(lucky_ids)
    local protocal ={}
    protocal.lucky_ids = lucky_ids
    self:SendProtocal(20835,protocal)
end
function RollerController:handle20835(data)
    -- GlobalEvent:getInstance():Fire(RollerEvent.UpdateRollerLibraryRedStatus)
end
function RollerController:sender20836()
    local protocal ={}
    self:SendProtocal(20836,protocal)
end
function RollerController:handle20836(data)
    self.model:setRollerPrivilegeData(data)
    GlobalEvent:getInstance():Fire(RollerEvent.UpdatePrivilegeVipData)
end
function RollerController:sender20826(partner_id,expend1,expend2,item_expend)
    local protocal ={}
    protocal.partner_id = partner_id
    protocal.expend1 = expend1
    protocal.expend2 = expend2
    protocal.item_expend = item_expend
    self:SendProtocal(20826,protocal)
end
function RollerController:handle20826(data)
    if data.code == 1 then
        message(TI18N("语言_c_7363"))
        self:openRollerEquipLockWindow(false)
    end
end
--抽奖结果
function RollerController:openRollerSummonGainWindow(bool,data,a)
    if bool == true then
        if not self.roller_summon_gain_window then
            self.roller_summon_gain_window = RollerSummonGainWindow.New(TRUE)
        end
        if self.roller_summon_gain_window and self.roller_summon_gain_window:isOpen() == false then
            self.roller_summon_gain_window:open(data)
        end
    else
        if self.roller_summon_gain_window then
            self.roller_summon_gain_window:close()
            self.roller_summon_gain_window = nil
        end
    end
end
function RollerController:openRollerPrivilegeWindow(bool)
    if bool == true then
        if not self.roller_privilege_window then
            self.roller_privilege_window = RollerPrivilegeWindow.New()
        end
        if self.roller_privilege_window and self.roller_privilege_window:isOpen() == false then
            self.roller_privilege_window:open()
        end
    else
        if self.roller_privilege_window then
            self.roller_privilege_window:close()
            self.roller_privilege_window = nil
        end
    end
end
function RollerController:openRollerWishWindow(bool)
    if bool == true then
        if not self.roller_wish_window then
            self.roller_wish_window = RollerWishWindow.New()
        end
        if self.roller_wish_window and self.roller_wish_window:isOpen() == false then
            self.roller_wish_window:open()
        end
    else
        if self.roller_wish_window then
            self.roller_wish_window:close()
            self.roller_wish_window = nil
        end
    end
end
--装备栏解锁
function RollerController:openRollerEquipLockWindow(bool,bid,partner_id)
    if bool == true then
        if not self.roller_equip_act_window then
            self.roller_equip_act_window = RollerEquipActWindow.New()
        end
        if self.roller_equip_act_window and self.roller_equip_act_window:isOpen() == false then
            self.roller_equip_act_window:open(bid,partner_id)
        end
    else
        if self.roller_equip_act_window then
            self.roller_equip_act_window:close()
            self.roller_equip_act_window = nil
        end
    end
end
--卷轴
function RollerController:openRollerKeyPanel(bool)
    if bool == true then
        if not self.roller_key_panel then
            self.roller_key_panel = RollerKeyPanel.New()
        end
        if self.roller_key_panel and self.roller_key_panel:isOpen() == false then
            self.roller_key_panel:open()
        end
    else
        if self.roller_key_panel then
            self.roller_key_panel:close()
            self.roller_key_panel = nil
        end
    end
end
function RollerController:openRollerHeroEquipListWindow(bool)
    if bool == true then
        if not self.roller_hero_equip_list_window then
            self.roller_hero_equip_list_window = RollerHeroEquipListWindow.New()
        end
        if self.roller_hero_equip_list_window and self.roller_hero_equip_list_window:isOpen() == false then
            self.roller_hero_equip_list_window:open()
        end
    else
        if self.roller_hero_equip_list_window then
            self.roller_hero_equip_list_window:close()
            self.roller_hero_equip_list_window = nil
        end
    end
end
function RollerController:openRollerGameplayDescriptionWindow(bool,index)
    if bool == true then
        if not self.roller_gameplay_description_window then
            self.roller_gameplay_description_window = RollerGameplayDescriptionWindow.New()
        end
        if self.roller_gameplay_description_window and self.roller_gameplay_description_window:isOpen() == false then
            self.roller_gameplay_description_window:open(index)
        end
    else
        if self.roller_gameplay_description_window then
            self.roller_gameplay_description_window:close()
            self.roller_gameplay_description_window = nil
        end
    end
end
--满级卷轴预览
function RollerController:openRollerChipsTipsPreviewWindow(bool,data)
    if bool == true then
        if not self.roller_chips_tips_preivew then
            self.roller_chips_tips_preivew = RollerChipsTipsPreviewWindow.New()
        end
        if self.roller_chips_tips_preivew and self.roller_chips_tips_preivew:isOpen() == false then
            self.roller_chips_tips_preivew:open(data)
        end
    else
        if self.roller_chips_tips_preivew then
            self.roller_chips_tips_preivew:close()
            self.roller_chips_tips_preivew = nil
        end
    end
end
function RollerController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end