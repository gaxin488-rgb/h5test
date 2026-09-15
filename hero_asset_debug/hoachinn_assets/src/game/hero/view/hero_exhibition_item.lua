-- --------------------------------------------------------------------
-- 竖版通用伙伴item
-- 
-- (必填, 创建模块的人员)
-- (必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

HeroExhibitionItem = class("HeroExhibitionItem", function() 
    return ccui.Layout:create()
end)

HeroExhibitionItem.Width = 119
HeroExhibitionItem.Height = 119

local expedit_model = HeroExpeditController:getInstance():getModel()

--@can_click 是否能点击
--@click_delay 是否延迟
--@can_effect 能启动点击回弹特效
--@not_swallow 是否吞噬点击
function HeroExhibitionItem:ctor(scale, can_click, click_delay, can_effect, not_swallow)
    self.scale = 1
    if scale and type(scale) == "number" then
        self.scale = scale
    end
    self.can_click = can_click
    if self.can_click == nil then
        self.can_click = true
    end
    if can_effect == nil then
        can_effect = true
    end
    self.resonate_star = 0 --神树星级
    self.can_effect = can_effect 
    self.click_delay = click_delay or 0 -- 点击间隔
    self.last_click_time = 0 -- 最后一次点击的时间

    -- 1 ~ 5星 星星列表
    self.star_list = {}
    -- 6 ~ 9星 星星列表
    self.star_list2 = {}
    -- 10星显示
    self.star10 = nil
    self.star_label = nil
    self.from_type = HeroConst.ExhibitionItemType.eNone

    self.size = cc.size(HeroExhibitionItem.Width,HeroExhibitionItem.Height)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)
    self:setTouchEnabled(true)
    if not_swallow then
        self:setSwallowTouches(false)
    end
    self:setCascadeOpacityEnabled(true)
    if type(self.scale) == "number" and self.scale ~= 1 then
        self:setScale(self.scale)
    end
    local res = PathTool.getResFrame("common","common_1005")

    self.background = createImage(self,res,self.size.width/2,self.size.height/2,cc.p(0.5,0.5),true,1,false)
    
    self.head_icon = createImage(self,nil,self.size.width/2,self.size.height/2,cc.p(0.5,0.5),false,1,false)

    self.num_label =  createLabel(24,Config.ColorData.data_color4[1],Config.ColorData.data_color4[9],107,81,"",self,2, cc.p(1,0))
    self.num_label:setZOrder(3)
    self.num_label:setVisible(false)
    self:initPartnerType()
    
    self.star_con = ccui.Widget:create()
    self.star_con:setZOrder(3)
    self.star_con:setPosition(cc.p(self.size.width * 0.5,20))
    self:addChild(self.star_con)
    self:registerEvent()
end

--@scrollview 使用
function HeroExhibitionItem:setExtendData(extend_info)
    if not extend_info  then return end
    self.scale = extend_info.scale or 1
    self:setScale(self.scale)
    self.can_click = extend_info.can_click
    if self.can_click == nil then
        self.can_click = true
    end
    self:initPartnerType()
    self.from_type = extend_info.from_type or HeroConst.ExhibitionItemType.eNone
    self.boold_type = extend_info.boold_type or nil
    self.click_delay = extend_info.click_delay or 0
    self.hide_star = extend_info.hide_star or false
    self.pos_id = extend_info.pos_id
    self.extend_info = extend_info
end

function HeroExhibitionItem:getExtendData(  )
    return self.extend_info or {}
end

function HeroExhibitionItem:setDefaultClick(can_click)
    self.can_click = can_click
end

--初始化伙伴类型 --现在表示伙伴阵营
function HeroExhibitionItem:initPartnerType()
    if self.partner_type == nil then
        self.partner_type = createSprite(PathTool.getPartnerTypeIcon(hero_type),19, 100, self, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 1)
        self.partner_type:setVisible(false)
        self.partner_type:setScale(0.6)
    end
end

function HeroExhibitionItem:getSize()
    return self.size
end

function HeroExhibitionItem:getData()
    return self.data
end

function HeroExhibitionItem:showFightIcon(bool)
    if not self.data then return end
    if self.data.is_in_form and self.data.is_in_form >0 and bool == true then 
        if not self.form_icon then 
            local res = PathTool.getResFrame("common","txt_cn_common_90001")
            self.form_icon = createImage(self,res,90,85,cc.p(0,0),true,0,false)
        end
    end

    if self.form_icon then 
        local is_show = (self.data.is_in_form>0) and bool
        self.form_icon:setVisible(is_show)
    end
end
--==============================--
--desc:点击回调
--time:2017-07-03 08:02:23
--@callback:
--@return 
--==============================--
function HeroExhibitionItem:addCallBack(callback)
    self.callback = callback
end
function HeroExhibitionItem:clickFun()
    if self.callback then
        self:callback(self.data)
    end
end

--添加长时间点击的回调
function HeroExhibitionItem:addLongTimeTouchCallback(callback)
    --默认有效果
    self:setLongTimeTouchEffect(true)
    self.long_time_callback = callback
end

--设置长时间点击的回调效果 默认是弹出英雄tips
function HeroExhibitionItem:setLongTimeTouchEffect(is_touch)
    self.have_long_time_effect = is_touch
end
--==============================--
--desc:注册相关事件
--time:2017-07-03 01:53:49
--@return 
--==============================--
function HeroExhibitionItem:registerEvent()
    if self.can_click == true then
        self:addTouchEventListener(function(sender, event_type) 
            if self.can_effect then
                customClickAction_2(self, event_type, self.scale)
            end

            if event_type == ccui.TouchEventType.began then
                if self.have_long_time_effect then
                    --有长点击效果
                    self.touch_began = sender:getTouchBeganPosition()
                    doStopAllActions(self.background)
                    self.long_touch_type = LONG_TOUCH_BEGAN_TYPE
                    delayRun(self.background, 0.6, function ()
                        if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                            if self.long_time_callback then
                                self.long_time_callback()
                            else
                                if self.data then
                                    if self.from_type == HeroConst.ExhibitionItemType.ePlanes then -- 位面
                                        if self.data.flag == 1 then -- 雇佣兵
                                            PlanesafkController:getInstance():sender28623(self.data.partner_id)
                                        else
                                            local hero_vo = HeroController:getInstance():getModel():getHeroById(self.data.partner_id)
                                            if hero_vo then
                                                HeroController:getInstance():openHeroTipsPanel(true, hero_vo, nil)
                                            end
                                        end
                                    elseif self.from_type == HeroConst.ExhibitionItemType.eEndLessHero and self.data.is_endless then -- 无尽试炼的
                                        --无尽试炼的雇佣兵
                                        LookController:getInstance():sender11061(self.data.rid, self.data.srv_id, self.data.id)
                                    else
                                        if self.data and self.data.bid then
                                            local ccfg = Config.PartnerData.data_partner_base[self.data.bid]--判断传过来的是不是英雄数据
                                            if ccfg then
                                                HeroController:getInstance():openHeroTipsPanel(true, self.data, nil)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        self.long_touch_type = LONG_TOUCH_END_TYPE
                    end)
                end
            elseif event_type == ccui.TouchEventType.moved then
                if self.have_long_time_effect then
                    if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                        local touch_began = self.touch_began
                        local touch_move = sender:getTouchMovePosition()
                        if touch_began and touch_move and (math.abs(touch_move.x - touch_began.x) > 20 or math.abs(touch_move.y - touch_began.y) > 20) then 
                            --移动大于20了..表示取消长点击效果
                            doStopAllActions(self.background)
                            self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                        end 
                    end
                end
            elseif event_type == ccui.TouchEventType.ended  then
                if self.have_long_time_effect then
                    if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                        doStopAllActions(self.background)
                        self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                    elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
                        --事件触发了就不处理点击事件了
                        return
                    end
                end

                if self:checkItemClickDelayTime() then
                    playButtonSound2()
                    self:clickFun()
                    -- 引导需要
                    if sender.guide_call_back ~= nil then
                        sender.guide_call_back(sender)
                    end
                end
            elseif event_type == ccui.TouchEventType.canceled  then
                if self.have_long_time_effect then
                    if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                        doStopAllActions(self.background)
                        self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                    end
                end
            end
        end)
    end

    -- 退出的时候移除一下吧.要不然可能有些人不会手动移除,就会报错
    self:registerScriptHandler(function(event)
        if "enter" == event then
        elseif "exit" == event then     
           self:unBindEvent()
        end 
    end)
end

-- 判断是否有点击间隔时间的要求
function HeroExhibitionItem:checkItemClickDelayTime(  )
    if self.click_delay and self.click_delay > 0 then
        if math.abs(GameNet:getInstance():getTimeFloat() - self.last_click_time) < self.click_delay then
            return false
        else
            self.last_click_time = GameNet:getInstance():getTimeFloat()
            return true
        end
    else
        return true
    end
end

function HeroExhibitionItem:unBindEvent()
    if self.data then
        if self.item_update_event ~= nil then
            self.data:UnBind(self.item_update_event)
            self.item_update_event = nil
        end
        self.data = nil
    end
end

--==============================--
--desc:根据单位id设置相关现实
--time:2019-01-24 09:05:04
--@id:
--@return 
--==============================--
function HeroExhibitionItem:setUnitData(id)
    id = id or 0
    local config = Config.UnitData.data_unit(id) 
    if config == nil then
        self.head_icon:setVisible(false)
        self.star_con:setVisible(false)
        self.num_label:setString("")
        self:setQualityImg(0)

        if self.partner_type then
            self.partner_type:setVisible(false)
        end
    else
        local monster_id = config.monster3
        if monster_id then
            local monster_config = Config.UnitData.data_unit(monster_id)
            if monster_config then
                -- 设置头像
                self:setHeadImg(monster_config.head_icon)
                -- 设置品质框
                self:setQualityImg(monster_config.star - 1)
                -- 设置阵营
                self:setCampImg(monster_config.camp_type)
                -- 设置星数
                self.star_setting = self:createStar(monster_config.star, self.star_con, self.star_setting) 
                -- 设置等级
                self:setLev(monster_config.lev)
            end
        end
    end
end

function HeroExhibitionItem:findUseSkin(info)
    if info.ext_data then
        local ext = info.ext_data or {}
        for i,v in ipairs(ext) do
            if v.key == 5 then
                return v.val
            end
        end
    end

    if info.ext then
        local ext = info.ext or {}
        for i,v in ipairs(ext) do
            if v.key == 5 then
                return v.val
            end
        end
    end

    if info.use_skin then
        return info.use_skin
    end
    return 0
end

--获取根据key 对应的值.没有返回 nil
function HeroExhibitionItem:findKeyValue(info, key)
    if not info then return end
    if not key then return end
    if info.ext_data then
        local ext = info.ext_data or {}
        for i,v in ipairs(ext) do
            if v.key == key then
                return v.val
            end
        end
    end

    if info.ext then
        local ext = info.ext or {}
        for i,v in ipairs(ext) do
            if v.key == key then
                return v.val
            end
        end
    end
end

--==============================--
--desc:设置数据
--time:2018-05-15 08:12:01
--@data:data类型可以是partnervo，partner表的config，bid
--@return 
--==============================--
function HeroExhibitionItem:setData(data)
    self:unBindEvent()
    self.data = data
    if type(self.scale) == "number" then
        self:setScale(self.scale)
    end
    if data == nil then 
        if self.index then
            self:setName("hero_" .. self.index)
        end
        
        self.head_icon:setVisible(false)
        self.star_con:setVisible(false)
        self.num_label:setVisible(false)
        self:setQualityImg(0)
        self:setChosenImg(0)
        if self.partner_type then
            self.partner_type:setVisible(false)
        end
        doStopAllActions(self)
        self:showResonateImg(false)
        self:showSelfMarkImg(false)
        self:showThirteenEffect(false) --特效清空
        self:showSoulHomologyImg(false)
        self:showCareerEffect(false)
    else
        self.head_icon:setVisible(true)
        self.star_con:setVisible(true)
        self.num_label:setVisible(true)
        self:updateData(data)
    end
end

--@info 数据 可以是
function HeroExhibitionItem:updateData(info)
    if not info then return end
    local data
    if type(info) == "number" then 
        data = Config.PartnerData.data_partner_base[info] 
    else
        if info.data then
            data = info.data
        else
            data = info
        end
    end

    if not data or not data.bid then return end

    local star = data.star or data.init_star or 1


    if data.bid ~= 0 then
        -- 引导需要
        local is_set = true
        local guide_id =  GuideController:getInstance():getModel():getGuideID()
        if guide_id then
            local guilde_list = Config.DramaData.data_const["guide_heavn_id"]
            if guilde_list and guilde_list.val then
                for k,v in pairs(guilde_list.val) do
                    -- 引导需要,这里做修改
                    if v == guide_id and self.index then
                        self:setName("hero_" .. self.index)
                        is_set = false
                        break
                    end
                end
            end
        end
        if is_set == true then
            self:setName("hero_" .. data.bid)
        end
        
        if info.master_head_id ~= nil then
            self:setHeadImg(info.master_head_id)
        else
            local use_skin = self:findUseSkin(info)
            if use_skin and use_skin ~= 0 then
                local skin_config = Config.PartnerSkinData.data_skin_info[use_skin]
                if skin_config then
                    self:setHeadImg(skin_config.head_id)
                end
            else
                local key = getNorKey(data.bid, star)
                local star_config = Config.PartnerData.data_partner_star(key)
                if star_config then
                    self.head_icon:setVisible(true)
                    self:setHeadImg(star_config.head_id)
                else
                    self.head_icon:setVisible(false)
                end
            end
        end

        if self.up_img then
            local partner_cfg = Config.PartnerData.data_partner_const
            local partner_buffed = partner_cfg["partner_buffed"].val
            if table.indexof(partner_buffed,data.bid) then
                self.up_img:setVisible(true)
            else
                self.up_img:setVisible(false)
            end
        end

        if self.sp_insignia_icon then
            local partner_cfg = Config.PartnerData.data_partner_const
            local partner_buffed = partner_cfg["sp_insignia"].val
            if table.indexof(partner_buffed,data.bid) then
                self.sp_insignia_icon:setVisible(true)
            else
                self.sp_insignia_icon:setVisible(false)
            end
        end
    end
    --背景框
    local score = HeroController:getInstance():getModel():heroBidScore(data.bid)
    if score and type(score)=="number" and score >= 11 then
        self:setQualityImg(16)
    elseif score and type(score)=="number" and score >= 10 then
        self:setQualityImg(15)
    else
        self:setQualityImg(star-1)
    end
    --阵营图标
    local camp_type = data.camp_type
    if camp_type == nil or camp_type == 0 then
        local config = Config.PartnerData.data_partner_base[data.bid] 
        if config then
            camp_type = config.camp_type
        end
    end 
    self:setCampImg(camp_type)
    
    if data.teamNum and data.teamNum>0 then
        self:setChosenImg(data.teamNum)
    else
        self:setChosenImg(0)
    end
    --星星
    if not self.hide_star then
        local setting = {}
        local eff_id
        if data.engraved_lev ~= nil then
            local keyin_lv = data.engraved_lev
            local e_cfg = Config.PartnerEngravedData.data_constant.sun_order.val
            local star1 = e_cfg[1]
            local star2 = e_cfg[2]
            local star3 = e_cfg[3]
            local res,res_bg
            if keyin_lv < star1 then
            elseif keyin_lv >= star1 and keyin_lv < star2 then
                res_bg = PathTool.getResFrame("common","common_90076_1")
                res = PathTool.getResFrame("common","common_90073_2")
                eff_id = "E27806"
                if star >= 16 and star < 25 then
                    eff_id = "E27812"
                elseif star >= 17 then
                    eff_id = "E27816"
                end
            elseif keyin_lv >= star2 and keyin_lv < star3 then
                res_bg = PathTool.getResFrame("common","common_90076_2")
                res = PathTool.getResFrame("common","common_90073_3")
                eff_id = "E27807"
                if star >= 16 and star < 25 then
                    eff_id = "E27813"
                elseif star >= 25 then
                    eff_id = "E27817"
                end
            elseif keyin_lv >= star3 then
                res_bg = PathTool.getResFrame("common","common_90076_3")
                res = PathTool.getResFrame("common","common_90073_4")
                eff_id = "E27808"
                if star >= 16 and star < 25 then
                    eff_id = "E27814"
                elseif star >= 25 then
                    eff_id = "E27818"
                end
            end
            setting = {res=res,res_bg=res_bg}
        end
        self.star_setting  = self:createStar(star, self.star_con, self.star_setting, setting)
        --13星专有特效
        if star >= 13 then
            self:showThirteenEffect(true,eff_id,star)
        else
            self:showThirteenEffect(false)
        end
    else
        self:showThirteenEffect(false)
    end
    
    --赋能的英雄 和后端协议是  10 表共鸣
    if data.isResonateHero and data:isResonateHero() then
        self:showResonateImg(true)
    else
        local end_time = self:findKeyValue(info, 10)
        if end_time and end_time > 0 then
            self:showResonateImg(true)
        else
            self:showResonateImg(false)    
        end
    end

    --灵魂同调标志
    if data.isLockByLocktype then
        local is_lock, lock_id = data:isLockByLocktype(HeroConst.LockType.eHeroSoulCoverLock)
        self:showSoulHomologyImg(is_lock)
    else
        self:showSoulHomologyImg(false)
    end

    --共鸣水晶上阵的英雄 和后端协议是  11 表共鸣
    local color = nil
    if data.isResonateCrystalHero then
        if data:isResonateCrystalHero() then
            color = cc.c4b(0x4b,0xff,0xe8,0xff)
        else
            color = Config.ColorData.data_color4[1]
        end
    elseif info.resonate_lev then
        if data.resonate_lev > 0 then
            color = cc.c4b(0x4b,0xff,0xe8,0xff)
        else
            color = Config.ColorData.data_color4[1]
        end
    else
        local resonate_lev = self:findKeyValue(info, 11)
        if resonate_lev and resonate_lev > 0 then
            color =  cc.c4b(0x4b,0xff,0xe8,0xff)
        else
            color = Config.ColorData.data_color4[1]
        end
    end
    --等级
    self:setLev(data.lev, color)


    --英雄图鉴显示 变灰逻辑
    if self.from_type == HeroConst.ExhibitionItemType.eHeroBag then --背包
        if HeroCalculate.isCheckHeroRedPointByHeroVo(data) then
            local is_redpoint = HeroCalculate.checkSingleHeroRedPoint(data)
            self:showRedPoint(is_redpoint, 10, 5)
        else
            self:showRedPoint(false)
        end
    elseif self.from_type == HeroConst.ExhibitionItemType.eHeroChange then --英雄转换界面
        --设置锁住状态
        self:showLockIcon(data.is_locked or false, data.lock_str)
        --设置选中状态 
        self:setSelected(data.is_ui_select == true)
    elseif self.from_type == HeroConst.ExhibitionItemType.eFormFight or self.from_type == HeroConst.ExhibitionItemType.eAdventure then --布阵出战
        --设置选中状态 
        self:setSelected(data.is_ui_select == true)
    elseif self.from_type == HeroConst.ExhibitionItemType.eVoyage then --远航
        self:showStrTips(data.in_task, TI18N("语言_c_3106"))
        --设置选中状态 
        self:setSelected(data.is_ui_select == true)
    elseif self.from_type == HeroConst.ExhibitionItemType.eStronger then --变强        
        --设置选中状态 
        self:setBoxSelected(data.is_ui_select == true)
    elseif self.from_type == HeroConst.ExhibitionItemType.eExpeditFight then --远征
        --血条
        local blood = 100
        if self.boold_type == true then
            blood = expedit_model:getHeroBloodById(data.partner_id, data.rid, data.srv_id)
            local status = false
            status = expedit_model:getHireHero(data.partner_id, data.rid, data.srv_id)
            if status == true and data.is_used then
                -- self:showHelpImg(true)
                --远征的支援标志......2019.1.28。20:37  晓勤特地叫改回来的
                if not self.hireHero then
                    self.hireHero = createSprite(PathTool.getResFrame("heroexpedit","txt_cn_heroexpedit_1"), 79, -7, self, cc.p(0,0), LOADTEXT_TYPE_PLIST, 1)
                else
                    self.hireHero:setVisible(true)
                    loadSpriteTexture(self.hireHero, PathTool.getResFrame("heroexpedit","txt_cn_heroexpedit_1"))
                end
            else
                -- self:showHelpImg(false)
                if self.hireHero then
                    self.hireHero:setVisible(false)
                end
            end
        else
            blood = data.blood or 0
        end
        self:showProgressbar(blood)
        if blood <= 0 then
            self:showStrTips(true,TI18N("语言_c_70"),{c3b = cc.c3b(255,255,255)})
        else
            self:showStrTips(false)
        end
        --设置选中状态 
        self:setSelected(data.is_ui_select == true)
    elseif self.from_type == HeroConst.ExhibitionItemType.eEndLessHero then --无尽试炼
        --设置选中状态 
        self:setSelected(data.is_ui_select == true)
        --是雇佣兵
        if data.is_endless then
            self:showHelpImg(true)
        else
            self:showHelpImg(false)
        end
        if data.hp_per then
            self:showProgressbar(data.hp_per)
            if data.hp_per <= 0 then
                self:showStrTips(true,TI18N("语言_c_70"),{c3b = cc.c3b(255,255,255)})
            else
                self:showStrTips(false)
            end
        end
    elseif self.from_type == HeroConst.ExhibitionItemType.eMaze then --地下迷宫
        --设置选中状态 
        self:setSelected(data.is_ui_select == true)
        -- --是雇佣兵
        -- if data.is_endless then
        --     self:showHelpImg(true)
        -- else
            self:showHelpImg(false)
        -- end
        if data.hp_per then
            self:showProgressbar(data.hp_per,data.hp_per.."%")
            if data.hp_per <= 0 then
                self:showStrTips(true,TI18N("语言_c_70"),{c3b = cc.c3b(255,255,255)})
            else
                self:showStrTips(false)
            end
        end
    elseif self.from_type == HeroConst.ExhibitionItemType.eLimitExercise then --限时试炼之境
        -- self:showHeroRemainCount(data.count, data.double)
        --设置选中状态 
        self:setSelected(data.is_ui_select == true)
    elseif self.from_type == HeroConst.ExhibitionItemType.ePlanes then --位面
        -- 是否为雇佣兵
        if data.flag == 1 then
            self:showHelpImg(true)
        else
            self:showHelpImg(false)
        end
        -- 剩余血量
        local hp_per = data.hp_per or PlanesafkController:getInstance():getModel():getMyPlanesHeroHpPer(data.partner_id, data.flag)
        if hp_per then
            self:showProgressbar(hp_per)
            if hp_per <= 0 then
                self:showStrTips(true,TI18N("语言_c_70"),{c3b = cc.c3b(255,255,255)})
            else
                self:showStrTips(false)
            end
        end
        --设置选中状态 
        self:setSelected(data.is_ui_select == true)
    end

    self:addVoBindEvent()
end

function HeroExhibitionItem:showThirteenEffect(status,eff_id,star)
    if status then
        --卡牌扫光
        if self.thirteen_effect == nil then
            self.thirteen_effect = createEffectSpine("E27802", cc.p(self.size.width/2,self.size.height/2), cc.p(0.5, 0.5), true, PlayerAction.action)
            self:addChild(self.thirteen_effect, 1)
        end
        --星级扫光
        if star and star >=16 then
            if self.sixteen_effect then 
                self.sixteen_effect:setVisible(false)
                self.sixteen_effect:removeFromParent()
                self.sixteen_effect = nil
            end
            if self.thirteen_effect2 then 
                self.thirteen_effect2:setVisible(false)
                self.thirteen_effect2:removeFromParent()
                self.thirteen_effect2 = nil
            end
            if self.sixteen_effect == nil then
                if self.star_setting and self.star_setting.star10 then
                    local _eff_id = "E27811"
                    if star >= 25 then
                        _eff_id = "E27815"
                    end
                    if eff_id then
                        _eff_id = eff_id
                    end
                    self.sixteen_effect = createEffectSpine(_eff_id, cc.p(63,27), cc.p(0.5, 0.5), true, PlayerAction.action)
                    self.star_setting.star10:addChild(self.sixteen_effect, 1)
                else
                    local _eff_id = "E27811"
                    if star >= 25 then
                        _eff_id = "E27815"
                    end
                    self.sixteen_effect = createEffectSpine(_eff_id, cc.p(0,-7), cc.p(0.5, 0.5), true, PlayerAction.action)
                    self.star_con:addChild(self.sixteen_effect, 1)
                end
            end
        else
            if self.thirteen_effect2 then 
                self.thirteen_effect2:setVisible(false)
                self.thirteen_effect2:removeFromParent()
                self.thirteen_effect2 = nil
            end
            if self.sixteen_effect then 
                self.sixteen_effect:setVisible(false)
                self.sixteen_effect:removeFromParent()
                self.sixteen_effect = nil
            end
            if self.thirteen_effect2 == nil then
                if self.star_setting and self.star_setting.star10 then
                    local _eff_id = "E27801"
                    if eff_id then
                        _eff_id = eff_id
                    end
                    self.thirteen_effect2 = createEffectSpine(_eff_id, cc.p(63,20), cc.p(0.5, 0.5), true, PlayerAction.action)
                    self.star_setting.star10:addChild(self.thirteen_effect2, 1)
                else
                    self.thirteen_effect2 = createEffectSpine("E27801", cc.p(0,-7), cc.p(0.5, 0.5), true, PlayerAction.action)
                    self.star_con:addChild(self.thirteen_effect2, 1)
                end
            end
        end
    else
        if self.thirteen_effect then 
            self.thirteen_effect:setVisible(false)
            self.thirteen_effect:removeFromParent()
            self.thirteen_effect = nil
        end
        if self.thirteen_effect2 then 
            self.thirteen_effect2:setVisible(false)
            self.thirteen_effect2:removeFromParent()
            self.thirteen_effect2 = nil
        end
        if self.sixteen_effect then 
            self.sixteen_effect:setVisible(false)
            self.sixteen_effect:removeFromParent()
            self.sixteen_effect = nil
        end
    end
end

--==============================--
--desc:设置头像
--time:2019-01-24 09:31:58
--@head_icon:
--@return 
--==============================--
function HeroExhibitionItem:setHeadImg(head_icon)
    if self.record_head_id == nil or self.record_head_id ~= head_icon then
        self.record_head_id = head_icon
        local res = PathTool.getHeadIcon(head_icon)
        self.head_icon:loadTexture( res, LOADTEXT_TYPE)
        if self:existChipSprite() then
            self.chipSprite.icon:loadTexture(res, LOADTEXT_TYPE)
        end
    end
end

--==============================--
--desc:设置羁绊技头像
--time:2019-01-24 09:31:58
--@head_icon:
--@return 
--==============================--
function HeroExhibitionItem:setBondHeadImg(id)
    local data_const = Config.PartnerBondSkillData.data_const
    local need_star = data_const["open_star_condition"].val
    local need_lev = data_const["open_tree_lev_condition"].val
    local status = false
    if self.data and need_star and self.data.star and self.data.star >= need_star and HeroController:getInstance():getModel():checkEnoughResLev(need_lev) then
        status = true
    end
    local cfg = deepCopy(Config.PartnerBondSkillData.data_base_info[id])
    if cfg and status then
        if not self.bond_par then
            self.bond_par = createSprite(PathTool.getResFrame("bondskill","bondskill_16",false,"bondskill"), -10, 0, self, cc.p(0,0))
            self.bond_par:setZOrder(99)
        end
        self.bond_par:setVisible(true)
        if not self.bond_cir then
            self.bond_cir = createSprite(PathTool.getResFrame("bondskill","bondskill_32",false,"bondskill"), -10, 0, self, cc.p(0,0))
            self.bond_cir:setZOrder(99)
        end
        self.bond_cir:setVisible(true)
        local bid = cfg[1].partner_id
        self.mask = createSprite(PathTool.getResFrame("bondskill","bondskill_14",false,"bondskill"), 22, 22, nil, cc.p(0.5, 0.5),LOADTEXT_TYPE_PLIST)--模板
        self.mask:setScale(1)
        if not self.clipNode then
            self.clipNode = cc.ClippingNode:create(self.mask)
            self.clipNode:setAnchorPoint(cc.p(0.5,0.5))
            self.clipNode:setContentSize(self.bond_par:getContentSize())
            self.clipNode:setCascadeOpacityEnabled(true)
            self.clipNode:setPosition(22,22)
            self.clipNode:setAlphaThreshold(0)
            self.bond_par:addChild(self.clipNode,2)
        end
        
        if not self.icon then
            self.icon = ccui.ImageView:create()
            self.icon:setCascadeOpacityEnabled(true)
            self.icon:setAnchorPoint(0.5,0.5)
            self.icon:setPosition(22,22)--底板
            self.clipNode:addChild(self.icon,3)
        end
        self.icon:loadTexture(PathTool.getHeadIcon(bid), LOADTEXT_TYPE)
        self.icon:setScale(0.5)
    else
        if self.bond_par then
            self.bond_par:setVisible(false)
        end
        if self.bond_cir then
            self.bond_cir:setVisible(false)
        end
    end
end

function HeroExhibitionItem:setBondHeadGrey(status)
    if self.bond_par then
        setChildUnEnabled(status,self.bond_par)
    end
    if self.bond_cir then
        setChildUnEnabled(status,self.bond_cir)
    end
end

--==============================--
--desc:品质框
--time:2019-01-24 09:25:27
--@quality:
--@return 
--==============================--
function HeroExhibitionItem:setQualityImg(quality)
    local cur_quailty = quality
    if quality <= 5 then
    elseif quality < 14 then
        cur_quailty = 5
    elseif quality < 15 then
        cur_quailty = 6
    elseif quality < 16 then
        cur_quailty = 7
    else
        cur_quailty = 8
    end
    local res_id = PathTool.getQualityBg(cur_quailty)
    if self.record_res_id == nil or self.record_res_id ~= res_id then
        self.record_res_id = res_id
        self.background:loadTexture( res_id, LOADTEXT_TYPE_PLIST)
    end
end

--显示队伍标志
function HeroExhibitionItem:setChosenImg(num)
    if num >0 then
        if tolua.isnull(self.chosen_bg) then
            self.chosen_bg = createSprite(PathTool.getResFrame("War_tolerance", "War_tolerance30"),self.size.width/2,self.size.height,self,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST, 1)
            self.num_txt = createLabel(18, Config.ColorData.data_color4[2], nil, self.size.width/2-3,self.size.height,"", self, nil, cc.p(0.5, 0.5))
            self.chosen_bg:setZOrder(4)
            self.num_txt:setZOrder(5)
        end
        self.chosen_bg:setVisible(true)
        self.num_txt:setVisible(true)
        self.num_txt:setString(num)
    else
        if not tolua.isnull(self.chosen_bg) then
            self.chosen_bg:setVisible(false)
            self.num_txt:setVisible(false)
        end
    end
end

--==============================--
--desc:设置阵营
--time:2019-01-24 09:26:37
--@camp:
--@return 
--==============================-- 
function HeroExhibitionItem:setCampImg(camp_type)
    if not camp_type then return end
    --0表示全阵营..这里不显示
    if self.sp then
        self.sp:setVisible(false)
    end
    if camp_type == 0 then
        self.partner_type:setVisible(false)
    else
        if self.partner_type then
            local type_res = PathTool.getHeroCampTypeIcon(camp_type)
            if type_res ~= self.type_res then
                self.type_res = type_res 
                loadSpriteTexture(self.partner_type, type_res, LOADTEXT_TYPE_PLIST)
            end
            if self.data and self.data.bid then
                local score = HeroController:getInstance():getModel():heroBidScore(self.data.bid)
                if score == 9 then
                    if not self.sp then
						self.sp = createSprite("",self.partner_type:getContentSize().width*0.5,self.partner_type:getContentSize().height*0.5, self.partner_type, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 3)
					end
                    loadSpriteTexture(self.sp, PathTool.getResFrame("hero/special_hero","special_hero_006"), LOADTEXT_TYPE_PLIST)
                    self.sp:setVisible(true)
                elseif score == 10 then
                    if not self.sp then
                        self.sp = createSprite("",self.partner_type:getContentSize().width*0.5,self.partner_type:getContentSize().height*0.5, self.partner_type, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 3)
                    end
                    loadSpriteTexture(self.sp, PathTool.getResFrame("hero/ultra_hero","ultra_hero_4"), LOADTEXT_TYPE_PLIST)
                    self.sp:setVisible(true)
                elseif score == 11 then
                    if not self.sp then
                        self.sp = createSprite("",self.partner_type:getContentSize().width*0.5,self.partner_type:getContentSize().height*0.5, self.partner_type, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 3)
                    end
                    loadSpriteTexture(self.sp, PathTool.getResFrame("hero/mystery_hero","mystery_hero_1"), LOADTEXT_TYPE_PLIST)
                    self.sp:setVisible(true)
                end
            end
            self.partner_type:setVisible(true)
        end
    end
end

--==============================--
--desc:设置等级
--time:2019-01-24 09:30:17
--@lev:
--@return 
--==============================--
function HeroExhibitionItem:setLev(lev, color)    
    if lev ~= nil then
        self.num_label:setVisible(true)
        if color then
            self.num_label:setTextColor(color)    
        end
        self.num_label:setString(lev)
    else
        self.num_label:setVisible(false)
    end
end
function HeroExhibitionItem:setLevPos(ap,pos)
    self.num_label:setAnchorPoint(ap)
    self.num_label:setPosition(pos)
end
function HeroExhibitionItem:setLevOutline(col,num)
    self.num_label:enableOutline(col,num)
end
--==============================--
--desc:增加数据监听
--time:2018-08-01 02:35:23
--@return 
--==============================--
function HeroExhibitionItem:addVoBindEvent()
    doStopAllActions(self)
    -- 直接用数据去监听这样避免了刷新的频繁
    if type(self.data) == "table" and self.data and self.data.id ~= nil and self.data.Bind then
        if self.item_update_event == nil then
            self.item_update_event = self.data:Bind(HeroVo.UPDATE_Partner_ATTR, function(hero_vo) 
                --延迟一秒
                delayRun(self,1,function ()
                    if self and self.updateData then
                        self:updateData(hero_vo)  
                    end
                end)
            end)
        end
    end
end

--设置默认头像
function HeroExhibitionItem:setDefaultHead(default_head_id)
    if default_head_id and self.record_head_id == nil or self.record_head_id ~= default_head_id then
        self.record_head_id = default_head_id
        local res = PathTool.getItemRes(default_head_id)
        self.record_head_icon = res
        self.head_icon:loadTexture( res, LOADTEXT_TYPE)

        if self:existChipSprite() then
            self.chipSprite.icon:loadTexture(res, LOADTEXT_TYPE)
        end
    end
end

--设置默认头像
function HeroExhibitionItem:setDefaultHeadByRes(res,scale,loadtext_type)
    if res and self.record_head_id == nil or self.record_head_id ~= res then
        self.record_head_id = res
        self.record_head_icon = res
        if loadtext_type == nil then
            loadtext_type = LOADTEXT_TYPE_PLIST
        end
        self.head_icon:loadTexture( res, loadtext_type)
        if self:existChipSprite() then
            self.chipSprite.icon:loadTexture(res, loadtext_type)
        end
        if not scale then
            scale = 1
        end
        
        self.head_icon:setScale(scale)
    end
end

--更新星星显示
function HeroExhibitionItem:createStar(num, star_con, star_setting, setting)
    local num = num or 0
    local setting = setting or {}
    local star_setting = star_setting or {}
    if star_setting.star_list == nil then
        star_setting.star_list = {}
    end

    if star_setting.star_list2 == nil then
        star_setting.star_list2 = {}
    end

    for i,v in pairs(star_setting.star_list) do
        v:setVisible(false)
    end
    for i,v in pairs(star_setting.star_list2) do
        v:setVisible(false)
    end
    if star_setting.star10 then
        star_setting.star10:setVisible(false)
    end
    if star_setting.moon then
        star_setting.moon:setVisible(false)
    end
    if star_setting.star16 then
        star_setting.star16:setVisible(false)
    end
    if star_setting.star_icon then
        star_setting.star_icon:setVisible(false)
    end
    local width_s = 12
    local _cStar = function(star_count, res, star_list,moveW,posy)
        local width = 12
        local x = - star_count * width * 0.5 + width * 0.5
        if moveW then 
            x = x + moveW
        end
        posy = posy or 0
        for i=1,star_count do
            if not star_list[i] then 
                local star = createImage(star_con,res,0,posy,cc.p(0.5,0.5),true,1,false)
                star:setScale(1)
                star_list[i] = star
            else
                star_list[i]:loadTexture(res, LOADTEXT_TYPE_PLIST)
            end
            star_list[i]:setVisible(true)
            star_list[i]:setPositionX(x + (i-1) * width)
        end
    end
    local _suncStar = function(star_count, res, star_list,offset_x)
        local width = 20
        local x = - star_count * width * 0.5 + width * 0.5 + (offset_x or 0)
        for i=1,star_count do
            if not star_list[i] then 
                local star = createImage(star_con,res,0,-20,cc.p(0.5,0.5),true,3,false)
                star:setScale(0.7)
                star_list[i] = star
            else
                star_list[i]:loadTexture(res, LOADTEXT_TYPE_PLIST)
            end
            star_list[i]:setVisible(true)
            star_list[i]:setPositionX(x + (i-1) * width)
        end
    end
    local star_res = PathTool.getResFrame("common","common_90074")

    if self.resonate_star and self.resonate_star ~= 0 then
        star_res = PathTool.getResFrame("common","common_90073")
        if num > 15 then
            star_res = PathTool.getResFrame("common","common_90073_01")
        end
    end
    if num > 0 and num <= 5 then
        -- local res = PathTool.getResFrame("common","common_90074")
        _cStar(num, star_res, star_setting.star_list)
    elseif num >= 6 and num <= 9 then
        -- local res = PathTool.getResFrame("common","common_90074")
        local count = num - 5
        _cStar(count, star_res, star_setting.star_list,width_s*0.5)

        local moonres = PathTool.getResFrame("common","common_90075_1")--这个是月亮标记
        if star_setting.moon == nil then 
            local star = createImage(star_con,moonres,0, 0,cc.p(0.5,0.5),true,0,false)
            star_setting.moon = star
            star_setting.moon:setScale(1)--(1.2)
        else
            star_setting.moon:setVisible(true)
        end
        local startmoon = - count * width_s * 0.5 + width_s * 0.5 -width_s*0.5 - 5--8 
        star_setting.moon:setPositionX(startmoon)
    elseif num >= 10 and num <= 15 then
        local new_num = num - 10
        local res_bg
        if new_num > 0 then
            res_bg = PathTool.getResFrame("common","common_90084")
        else
            res_bg = PathTool.getResFrame("common","common_90084")
        end
        if setting and setting.res_bg then
            res_bg = setting.res_bg
        end
        local res = PathTool.getResFrame("common","common_90073_1")--这个是太阳标记
        if setting and setting.res then
            res = setting.res
        end
        if star_setting.star10 == nil then
            star_setting.star10 = createImage(star_con,res_bg,0,-7,cc.p(0.5,0.5),true,0,false)
            star_setting.star10:setZOrder(3)
            local star = createImage(star_setting.star10,res,63, 21,cc.p(0.5,0.5),true,0,false)
            star:setScale(1)
            star_setting.star_icon = star
            star_setting.star_icon:setZOrder(4)
        else
            star_setting.star10:loadTexture(res_bg, LOADTEXT_TYPE_PLIST)
            if not star_setting.star_icon then
                local star = createImage(star_setting.star10,res,63, 21,cc.p(0.5,0.5),true,0,false)
                star:setScale(1)
                star_setting.star_icon = star
                star_setting.star_icon:setZOrder(4)
            else
                star_setting.star_icon:loadTexture(res, LOADTEXT_TYPE_PLIST)
                star_setting.star_icon:setVisible(true)
            end
            star_setting.star10:setVisible(true)
            
        end
       if new_num > 0 then
            if star_setting.star_label == nil then
                local size = star_setting.star_icon:getContentSize()
                star_setting.star_label = createLabel(18,Config.ColorData.data_color4[1],Config.ColorData.data_color4[9],size.width * 0.5 - 2, size.height * 0.5,"10",star_setting.star_icon, 1, cc.p(0.5,0.5))
            else
                star_setting.star_label:setVisible(true)
            end
            star_setting.star_label:setString(new_num)
        else
            if star_setting.star_label then
                star_setting.star_label:setVisible(false)
            end
        end
    elseif num >= 16 then
        --local res_bg = PathTool.getResFrame("common_1","common_1_581")
        local new_num = num - 10
        local res_bg
        if new_num > 0 then
            res_bg = PathTool.getResFrame("common_1","common_1_581")
        else
            res_bg = PathTool.getResFrame("common_1","common_1_581")
        end
        if setting and setting.res_bg then
            res_bg = setting.res_bg
        end
        local res = PathTool.getResFrame("common_1","common_1_580")--这个是太阳标记
        if setting and setting.res then
            res = setting.res
        end
        if star_setting.star10 == nil then
            star_setting.star10 = createImage(star_con,res_bg,0,-7,cc.p(0.5,0.5),true,0,false)
            star_setting.star10:setZOrder(3)
            local star = createImage(star_setting.star10,res,63, 21,cc.p(0.5,0.5),true,0,false)
            star:setScale(1)
            star_setting.star_icon = star
            star_setting.star_icon:setZOrder(4)
        else
            star_setting.star10:loadTexture(res_bg, LOADTEXT_TYPE_PLIST)
            if not star_setting.star_icon then
                local star = createImage(star_setting.star10,res,63, 21,cc.p(0.5,0.5),true,0,false)
                star:setScale(1)
                star_setting.star_icon = star
                star_setting.star_icon:setZOrder(4)
            else
                star_setting.star_icon:loadTexture(res, LOADTEXT_TYPE_PLIST)
                star_setting.star_icon:setVisible(true)
            end
            star_setting.star10:setVisible(true)
            
        end
       if new_num > 0 then
            if star_setting.star_label == nil then
                local size = star_setting.star_icon:getContentSize()
                star_setting.star_label = createLabel(18,Config.ColorData.data_color4[1],Config.ColorData.data_color4[9],size.width * 0.5 - 2, size.height * 0.5,"10",star_setting.star_icon, 1, cc.p(0.5,0.5))
            else
                star_setting.star_label:setVisible(true)
            end
            star_setting.star_label:setString(new_num)
        else
            if star_setting.star_label then
                star_setting.star_label:setVisible(false)
            end
        end
    end
    return star_setting
end

--@percent 百分比
--@label 进度条中间文字描述
function HeroExhibitionItem:showProgressbar(percent, label)
    self:showProgressbarStatus(true, percent, label)
end
--显示百分比状态
--@percent 百分比
--@label 进度条中间文字描述
--@setting 扩展table对象
function HeroExhibitionItem:showProgressbarStatus(status, percent, label, setting)
    if status then
        if not self.comp_bar then
            local setting = setting or {}
            local y = setting.y or - 10

            local res = PathTool.getResFrame("common","common_90005")
            local res1 = PathTool.getResFrame("common","common_90006")
            local size = cc.size(118, 19)
            local bg,comp_bar = createLoadingBar(res, res1, size, self, cc.p(0.5,0.5), size.width/2, y, true, true)
            self.comp_bar = comp_bar
            self.comp_bar_bg = bg 
        else
            self.comp_bar_bg:setVisible(true)
            self.comp_bar:setVisible(true)    
        end
        self.comp_bar:setPercent(percent)

        if label then
            if not self.comp_bar_label then
                local text_color = cc.c3b(255,255,255)
                local line_color = cc.c3b(0,0,0)
                local size = cc.size(118, 19)
                self.comp_bar_label = createLabel(18, text_color, line_color, size.width/2, size.height/2, "", self.comp_bar, 2, cc.p(0.5, 0.5))
            end
            self.comp_bar_label:setString(label)
        end
    else
        if self.comp_bar then
            self.comp_bar:setVisible(false)
        end
        if self.comp_bar_bg then
            self.comp_bar_bg:setVisible(false)
        end
    end
end

function  HeroExhibitionItem:setBarPosition(x,y)
    -- if self.comp_bar then
    --     if x then
    --         self.comp_bar:setPositionX(x)
    --     end
    --     if y then
    --         self.comp_bar:setPositionY(y)
    --     end
    -- end
    if self.comp_bar_bg then
        if x then
            self.comp_bar_bg:setPositionX(x)
        end
        if y then
            self.comp_bar_bg:setPositionY(y)
        end
    end
end

function HeroExhibitionItem:showChipIcon(status)
    local info = self.data
    local data
    if type(info) == "number" then 
        data = Config.PartnerData.data_partner_base[info] 
    else
        if info.data then
            data = info.data
        else
            data = info
        end
    end
    if not data or not data.bid then return end
    local star = data.star or data.init_star or 1
    if status then
		local res_base,res_frame = PathTool.getChipQualityBg(star - 1)
        if data.score then
            if data.score == 9 then
                res_base = PathTool.getResFrame("common", "common_90055_0_5")
                res_frame = PathTool.getResFrame("common", "common_90055_1_5")
            end
        else
            local hero_cfg = Config.PartnerData.data_partner_base[data.base_id]
            if hero_cfg then
                if hero_cfg.score == 9 then
                    res_base = PathTool.getResFrame("common", "common_90055_0_5")
                    res_frame = PathTool.getResFrame("common", "common_90055_1_5")
                end 
            else
                if data.config then
                    if data.config.effect and data.config.effect[1] and data.config.effect[1].val then
                        local id = data.config.effect[1].val
                        local hero_cfg = Config.PartnerData.data_partner_base[id]
                        if hero_cfg then
                            if hero_cfg.score == 9 then
                                res_base = PathTool.getResFrame("common", "common_90055_0_5")
                                res_frame = PathTool.getResFrame("common", "common_90055_1_5")
                            end     
                        end
                    end
                end
            end
        end
		if not self.chipSprite then
			self.chipSprite = createSprite("", HeroExhibitionItem.Width/2, HeroExhibitionItem.Height/2, self, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST, 1)
			self.chipSprite:setCascadeOpacityEnabled(true)
			local mask_bg = createSprite(PathTool.getResFrame("common", "common_90055_2"), 53, 53, nil, cc.p(0.5, 0.5))
			local icon_clipNode = cc.ClippingNode:create(mask_bg)
			icon_clipNode:setAnchorPoint(cc.p(0.5,0.5))
			icon_clipNode:setContentSize(cc.size(105, 105))
			icon_clipNode:setCascadeOpacityEnabled(true)
			icon_clipNode:setAlphaThreshold(0)
			self.chipSprite:addChild(icon_clipNode)
            self.chipSprite.icon_clipNode = icon_clipNode
            local res = self.record_head_icon or ""
            self.chipSprite.icon = createImage(icon_clipNode, res, 53, 53, cc.p(0.5, 0.5), false)
            self.chipSprite.icon:ignoreContentAdaptWithSize(true)
			self.chipSprite.top_img = createSprite("", 53, 53, self.chipSprite, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST, 1)
		end
		if self.chipSprite then
			self.chipSprite:setVisible(true)
			loadSpriteTexture(self.chipSprite, res_base, LOADTEXT_TYPE_PLIST)
            loadSpriteTexture(self.chipSprite.top_img, res_frame, LOADTEXT_TYPE_PLIST)
            local res = self.record_head_icon or ""
			self.chipSprite.icon:loadTexture(res, LOADTEXT_TYPE)
			local size = self.chipSprite:getContentSize()
			self.chipSprite.icon_clipNode:setPosition(size.width/2, size.height/2)
			self.chipSprite.top_img:setPosition(size.width/2, size.height/2)
        end
        self.head_icon:setVisible(false)
	else
		if self.chipSprite then
			self.chipSprite:setVisible(false)
		end
	end
end

function HeroExhibitionItem:existChipSprite()
	if self.chipSprite and self.chipSprite:isVisible() then
		return true
	end
	return false
end


--设置头像变化  
--@bool  true 变灰  false 原来颜色样子
function HeroExhibitionItem:setHeadUnEnabled(bool)
    if self.head_icon then
        setChildUnEnabled(bool, self.head_icon)
    end
end


--==============================--
--desc:设置选中状态
--time:2017-07-03 09:07:12
--@status:
--@return 
--==============================--
function HeroExhibitionItem:setSelected(status)
    if status then
        if self.lay_select == nil then
            self.lay_select = ccui.Layout:create()
            self.lay_select:setAnchorPoint(cc.p(0.5,0.5))
            self.lay_select:setContentSize(self.size)
            self.lay_select:setPosition(self.size.width/2, self.size.height/2) 
            self.lay_select:setTouchEnabled(false)
            showLayoutRect(self.lay_select, 150)
            local res = PathTool.getResFrame("common","common_1043")
            createImage(self.lay_select,res,self.size.width/2,self.size.height/2,cc.p(0.5,0.5),true,1,false)

            self:addChild(self.lay_select, 3)
        else
            self.lay_select:setVisible(true)
        end
    else
        if self.lay_select then
            self.lay_select:setVisible(false)
        end
    end
end
--多队选中状态
function HeroExhibitionItem:setTeamSelected(status,team_index)
    if status then
        if self.lay_select_tema == nil then
            self.lay_select_tema = ccui.Layout:create()
            self.lay_select_tema:setAnchorPoint(cc.p(0.5,0.5))
            self.lay_select_tema:setContentSize(self.size)
            self.lay_select_tema:setPosition(self.size.width/2, self.size.height/2) 
            self.lay_select_tema:setTouchEnabled(false)
            showLayoutRect(self.lay_select_tema, 150)
            self:addChild(self.lay_select_tema, 3)
            local res = PathTool.getResFrame("common","common_1043")
            createImage(self.lay_select_tema,res,self.size.width/2,self.size.height/2,cc.p(0.5,0.5),true,1,false)
            local res = PathTool.getResFrame("actionyearmonster_result","actionyearmonster_result_4")
            createImage(self.lay_select_tema,res,self.size.width/2,self.size.height/2+55,cc.p(0.5,0.5),true,2,false)
            if not self.team_lock_label then 
                self.team_lock_label = createLabel(22,Config.ColorData.data_color4[1],Config.ColorData.data_color4[9],self.size.width/2-1,self.size.height/2+57,"",self.lay_select_tema,2, cc.p(0.5,0.5))
                self.team_lock_label:setLocalZOrder(9)
            end
        else
            self.lay_select_tema:setVisible(true)
        end
        self.team_lock_label:setString(team_index or "")
    else
        if self.lay_select_tema then
            self.lay_select_tema:setVisible(false)
        end
    end
end
-- 第二种样式的选中状态
function HeroExhibitionItem:setBoxSelected( status )
    if status then
        if self.box_select == nil then
            local res = PathTool.getResFrame("stronger","stronger_3")
            self.box_select = createImage(self, res, self.size.width/2, self.size.height/2-10, cc.p(0.5, 0.5), true, 1)
            self.box_select:setScale(1.25)
        else
            self.box_select:setVisible(true)
        end
    else
        if self.box_select then
            self.box_select:setVisible(false)
        end
    end
end

-- 第三种样式的选中状态
function HeroExhibitionItem:setBoxSelected2( status )
    if status then
        if self.box_select == nil then
            local res = PathTool.getResFrame("stronger","stronger_3")
            self.box_select = createImage(self, res, self.size.width/2, self.size.height/2-10, cc.p(0.5, 0.5), true, 1)
            self.box_select:setScale(1.25)
        else
            self.box_select:setVisible(true)
        end
    else
        if self.box_select then
            self.box_select:setVisible(false)
        end
    end
end

--设置锁
--setting
--setting.res 锁的路径
--setting.is_unenabled_bg 是否背景也要变灰

function HeroExhibitionItem:showLockIcon(bool, str, setting)
    if bool == false and not self.lock_icon then return end
    local setting = setting or {}
    local res = setting.res
    if not self.lock_icon then 
        local res = res or PathTool.getResFrame("common","common_90009")
        self.lock_icon = createImage(self,res,self.size.width/2,self.size.height/2,cc.p(0.5,0.5),true,1,false)
    else
        if res and self.lock_icon then
            self.lock_icon:loadTexture(res, LOADTEXT_TYPE_PLIST)
        end
    end
    if str ~= nil then 
        if not self.lock_label then 
            self.lock_label = createLabel(22,Config.ColorData.data_color4[1],Config.ColorData.data_color4[9],self.size.width/2,22,"",self,2, cc.p(0.5,0))
        end
        self.lock_label:setString(str)
    end

    self.lock_icon:setVisible(bool)

    -- 锁住的时候某些部分要置灰
    self:setHeadUnEnabled(bool)
    if self.partner_type then
        setChildUnEnabled(bool, self.partner_type)
    end
    if setting.is_unenabled_bg then
        setChildUnEnabled(bool, self.background)
    else
        setChildUnEnabled(false, self.background)
    end

    if self.lock_label then 
        self.lock_label:setVisible(bool)
    end
end

function HeroExhibitionItem:showUnLockIcon()
    self:setHeadUnEnabled(false)
    if self.lock_icon then
        self.lock_icon:setVisible(false)
    end
    if self.lock_label then
        self.lock_label:setVisible(false)
    end
end

--设置出战字
function HeroExhibitionItem:showFightImg(bool)
    if bool == false and not self.fight_img then return end
    if not self.fight_img then 
        local res = PathTool.getResFrame("common","txt_cn_common_90001")
        self.fight_img = createImage(self,res,109,18,cc.p(0.5,0.5),true,3,false)
    end
    self.fight_img:setVisible(bool)
end


function HeroExhibitionItem:showAddIcon(bool, res)
    if bool == false and not self.add_btn then return end
    if not self.add_btn then 
        local res = res or PathTool.getResFrame("common","common_90026")
        self.add_btn = createSprite(res, self.size.width/2, self.size.height/2, self, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 1)
    end
    self.add_btn:setVisible(bool)
end

--带文字的加号
function HeroExhibitionItem:showAddIconII(bool,str)
    if bool == false and not self.add_btn then return end
    if not self.add_btn then 
        local res = PathTool.getResFrame("common","common_90026")
        self.add_btn =createImage(self,res,self.size.width/2,40,cc.p(0.5,0),true,0,false)
        self.add_label = createLabel(22,Config.ColorData.data_color4[1],Config.ColorData.data_color4[9],self.size.width/2,12,"",self,2, cc.p(0.5,0))
        
    end
    str = str or ""
    self.add_btn:setVisible(bool)
    self.add_label :setString(str)
    self.add_label:setVisible(bool)
end

-- 问号
function HeroExhibitionItem:showUnknownIcon( status )
    if status == false and not self.unknow_icon then return end
    if not self.unknow_icon then 
        local res = PathTool.getResFrame("common","common_90086")
        self.unknow_icon = createSprite(res, self.size.width/2, self.size.height/2, self, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 1)
    end
    self.unknow_icon:setVisible(status)
end

--红点 --
--@offset_x 红点偏移量
--@offset_y
function HeroExhibitionItem:showRedPoint(bool, offset_x, offset_y)
    if bool == false and not self.red_point then return end

    if not self.red_point then 
        local offset_x = offset_x or 0
        local offset_y = offset_y or 0
        local res = PathTool.getResFrame("common","common_1014")
        self.red_point = createImage(self,res, 108 + offset_x, 108 + offset_y, cc.p(0.5,0.5),true,10,false)
    end
    self.red_point:setVisible(bool)
end

--显示支援图片
function HeroExhibitionItem:showHelpImg(bool)
    if bool == false and not self.help_img then return end
    if not self.help_img then 
        local res = PathTool.getResFrame("common","txt_cn_common_90014")
        self.help_img = createSprite(res, 10, 16, self, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 3)
    end
    self.help_img:setVisible(bool)
end

--显示是否共鸣英雄图片
function HeroExhibitionItem:showResonateImg(bool)
    if bool == false and not self.resonate_img then return end
    if not self.resonate_img then 
        local res = PathTool.getResFrame("common","common_2036")
        self.resonate_img = createSprite(res, self.size.width * 0.5, self.size.height * 0.5, self, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 1)
    end
    if bool then
        self.resonate_img:setVisible(bool)
        doStopAllActions(self.resonate_img)

        local sequence = cc.Sequence:create(cc.FadeOut:create(0.7), cc.DelayTime:create(0.4), cc.FadeIn:create(0.7),cc.DelayTime:create(0.1))
        self.resonate_img:runAction(cc.RepeatForever:create(sequence))
    else
        doStopAllActions(self.resonate_img)
        self.resonate_img:setVisible(bool)
    end
end

--显示是否共鸣水晶 时间
function HeroExhibitionItem:showResonateCrystalTime(bool, time_str)
    if bool == false and not self.resonate_crystal_img then return end
    if not self.resonate_crystal_img then 
        local res = PathTool.getResFrame("common","common_2036")
        self.resonate_crystal_img = createSprite(res, self.size.width * 0.5, 70, self, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 1)
        self.resonate_crystal_img:setScale(0.7)
        self.resonate_crystal_time = createLabel(24,cc.c4b(0xff,0xf8,0xbf,0xff),nil,18, -25,"",self.resonate_crystal_img,2,cc.p(0.5, 0.5))
    end
    if bool then
        self.resonate_crystal_img:setVisible(true)
        if time_str then
            self.resonate_crystal_time:setString(time_str)
        end
    else
        self.resonate_crystal_img:setVisible(false)
    end
    return self.resonate_crystal_time
end

--显示是否本体标记
function HeroExhibitionItem:showSelfMarkImg(bool)
    if bool == false and not self.selfmark_img then return end
    if not self.selfmark_img then 
        local res = PathTool.getPlistImgForDownLoad("hero","txt_cn_hero_temp_01")
        self.selfmark_img = createSprite(res, self.size.width * 0.5, self.size.height * 0.5, self, cc.p(0.5, 0.5), LOADTEXT_TYPE, 1)
    end
    if bool then
        self.selfmark_img:setVisible(bool)
        doStopAllActions(self.selfmark_img)

        local sequence = cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5),cc.DelayTime:create(0.7))
        self.selfmark_img:runAction(cc.RepeatForever:create(sequence))
    else
        doStopAllActions(self.selfmark_img)
        self.selfmark_img:setVisible(bool)
    end
end

--显示防守中
function HeroExhibitionItem:showDefImg(bool)
    if bool == false and not self.help_img then return end
    if not self.help_img then 
        local res = PathTool.getResFrame("common","txt_cn_common_30016")
        self.help_img = createSprite(res, 34, 63, self, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 1)
    end
    self.help_img:setVisible(bool)
end

--显示灵魂同调标志
function HeroExhibitionItem:showSoulHomologyImg(bool)
    if bool == false and not self.soul_homology_effect then return end
    if not self.soul_homology_effect then 
        local effect = createSpineByName("E30007")
        effect:setAnimation(0, PlayerAction.action, true)
        effect:setPosition(cc.p(self.size.width/2, self.size.height/2 + 10))
        self:addChild(effect, 100)
        self.soul_homology_effect = effect
    end
    self.soul_homology_effect:setVisible(bool)
end

--阵容界面如果有限制条件 职业闪烁出现
function HeroExhibitionItem:showCareerEffect(bool, tartget_career)
    if bool == false and not self.career_img and self.data and self.data.type and tartget_career ~= self.data.type then return end
    if not bool then
        if self.career_img then
            self.career_img:stopAllActions()
            self.career_img:setVisible(bool)
            self.partner_type:stopAllActions()
        end
        return
    end
    local hero_type = self.data.type or 4
    local res = PathTool.getPartnerTypeIcon(hero_type)
    if not self.career_img then 
        self.career_img = createSprite(res, 19, 100, self, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 1)
    end
    self.career_img:stopAllActions()
    loadSpriteTexture(self.career_img, res, LOADTEXT_TYPE_PLIST)
    self.partner_type:stopAllActions()
    if bool then
        local fadein = cc.FadeIn:create(1)
        local fadeout = cc.FadeOut:create(1)
        self.career_img:runAction(cc.RepeatForever:create(cc.Sequence:create(fadein, fadeout)))

        local fadein = cc.FadeIn:create(1)
        local fadeout = cc.FadeOut:create(1) 
        self.partner_type:runAction(cc.RepeatForever:create(cc.Sequence:create(fadeout, fadein)))
    end
    self.career_img:setVisible(bool)
end

--==============================--
--desc:下方显示额外的战力(暂时没做处理)
--time:2018-07-02 07:55:16
--@status:
--@power:
--@return 
--==============================--
function HeroExhibitionItem:shwoExtendPower(status, power)
    if status == false then
        if self.extend_power then
            self.extend_pwer:setVisible(false)
        end
    else
        power = power or 0
        if self.extend_power == nil then
            self.extend_power = createRichLabel(24, 175, cc.p(0.5, 1), cc.p(self.size.width*0.5, -2))
            self:addChild(self.extend_power, 1)
        end
        self.extend_power:setString(string.format("<div><img src='%s' scale=1 />%s</div>", PathTool.getResFrame("common","common_90002"), MoneyTool.moneyFormat(power)))
    end
end

--试炼之境中英雄显示可用次数
function HeroExhibitionItem:showHeroRemainCount(current, totle)
    if not self.remain_text then
        local bg = createImage(self, PathTool.getResFrame("limitexercise", "limitexercise_22"), 61, -10, cc.p(0.5, 0.5), true, 1, true)
        bg:setContentSize(cc.size(120, 21))
        bg:setCapInsets(cc.rect(3, 3, 6, 6))
        self.remain_text = createLabel(20,cc.c4b(0xff,0xff,0xff,0xff),cc.c4b(0x00,0x00,0x00,0xff),bg:getContentSize().width/2, bg:getContentSize().height/2,"",bg,2,cc.p(0.5, 0.5))
    end
    self.remain_text:setString(current.."/"..totle)
end

-- 显示文字提示
function HeroExhibitionItem:showStrTips( status, str, color ,font_size)
    if status then
        if self.lay_tips == nil then
            self.lay_tips = ccui.Layout:create()
            self.lay_tips:setAnchorPoint(cc.p(0.5,0.5))
            self.lay_tips:setContentSize(self.size)
            self.lay_tips:setPosition(self.size.width/2, self.size.height/2) 
            self.lay_tips:setTouchEnabled(false)
            showLayoutRect(self.lay_tips, 150)
            local c3b = cc.c3b(255,255,255)
            local enable = cc.c3b(132,0,0)
            if color then
                c3b = color.c3b or c3b
                enable = color.enable or enable
            end
            font_size = font_size or 26
            local tips_text = createLabel(font_size,c3b,enable,self.size.width/2,self.size.height/2,str,self.lay_tips,nil,cc.p(0.5, 0.5))

            self:addChild(self.lay_tips, 3)
        else
            self.lay_tips:setVisible(true)
        end
    else
        if self.lay_tips then
            self.lay_tips:setVisible(false)
        end
    end
end

--显示名字 
--setting table 谁用到谁加对应参数
function HeroExhibitionItem:setHeroName(status, hero_name,  setting)
    if status then
        if not hero_name then return end
        if self.hero_name_label == nil then
            local setting = setting or {}
            local color  = setting.color or cc.c4b(0x64,0x32,0x23,0xff)
            local font_size  = setting.font_size or 22
            self.hero_name_label = createLabel(font_size,color,nil,self.size.width/2, -20, hero_name, self,nil,cc.p(0.5, 0.5))
        else
            self.hero_name_label:setVisible(true)
            self.hero_name_label:setString(hero_name)
        end
    else
        if self.hero_name_label then
            self.hero_name_label:setVisible(false)
        end
    end
end

--设置背景透明度 
function HeroExhibitionItem:setBgOpacity(opacity)
    local opacity = opacity or 0
    if opacity < 0 then opacity = 0 end
    if opacity > 255 then opacity = 255 end
    self.background:setOpacity(opacity)
end

function HeroExhibitionItem:DeleteMe()
    -- 清空可能缓存修改的数据
    -- if self.data and self.data.is_ui_select ~= nil then
    --     self.data.is_ui_select = nil
    -- end
    -- 移除在 HeroExhibitionItem:addVoBindEvent() 里面添加的定时器

    if self.soul_homology_effect then
        self.soul_homology_effect:removeFromParent()
        self.soul_homology_effect = nil
    end

    doStopAllActions(self)
    self:showThirteenEffect(false)

    self:unBindEvent()
    self:removeAllChildren()
    self:removeFromParent()
end