-- --------------------------------------------------------------------
-- 竖版技能item
-- 
-- (必填, 创建模块的人员)
-- (必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

SkillItem = class("SkillItem", function() 
    return ccui.Layout:create()
end)

SkillItem.Width = 119
SkillItem.Height = 119

function SkillItem:ctor(play_start, click, is_show_tips, scale, show_lev, swallow_touch)
    self.play = play_start
    self.click = click
    self.is_show_tips = is_show_tips or false
    self.scale = scale or 1
    self.can_reset_name = true

    self.size = cc.size(SkillItem.Width, SkillItem.Height)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)
    if self.scale ~= 1 then
        self:setScale(self.scale)
    end

    self:configUI()

    if self.click == true then
        self:setTouchEnabled(true)
        self:registerEvent()
        self:setSwallowTouches(swallow_touch)
    end
end

function SkillItem:setClickInfo(setting)
    setting  = setting or {}
    self.clickScroll = setting.clickScroll or false --是否点击滚动
    self.click = setting.click or false --是否能点击
    if self.click == true then
        self:setTouchEnabled(true)
        self:registerEvent()
    end
    self.swallow_touch = setting.swallow_touch or false --是否吞噬
    if self.swallow_touch == true then
        self:setSwallowTouches(self.swallow_touch)
    end
end

function SkillItem:configUI()
    --背景
    local res = PathTool.getNormalSkillBg()
    self.background = createImage(self, res,  self.size.width/2, self.size.height/2, cc.p(0.5,0.5), true, 0, true)
    self.background:setContentSize(self.size)
    --技能skill -- createSprite(res, x, y, container, anchorPoint, type, zorder)
    self.item_icon = createSprite(nil,  self.size.width/2, self.size.height/2, self, cc.p(0.5,0.5), LOADTEXT_TYPE, 0)

    --技能等级
    if self.show_lev then
        local res = PathTool.getResFrame("common","common_2018")
        self.level_bg = createImage(self, res, 10,108, cc.p(0.5,0.5), true, 1, false)
        self.num_label = createLabel(20,cc.c4b(0x64,0x32,0x23,0xff),nil,8,107,"00",self,1, cc.p(0.5,0.5))
        self.num_label = createLabel(24,cc.c4b(0xff,0xff,0xff,0xff),nil,8,107,"00",self,1, cc.p(0.5,0.5))
        self.num_label:setZOrder(1)
    end
end

function SkillItem:setlvSize(lvNum)
    if self.level_bg then
        self.level_bg:setScale(lvNum)
    end
    if self.num_label then
        self.num_label:setScale(lvNum)
    end
    if self.num_label2 then
        self.num_label2:setScale(lvNum)
        self.num_label2:setVisible(false)
    end
end

function SkillItem:getSize()
    return self.size
end

function SkillItem:resetName(status)
    self.can_reset_name = status
end

function SkillItem:getData()
    return self.data
end
--==============================--
--desc:设置选中状态
--time:2017-07-03 09:07:12
--@status:
--@return 
--==============================--
function SkillItem:setSelected(status)
    if not self.select_bg and status == false then return end

    if not self.select_bg then 
        local res= PathTool.getSelectBg()
        self.select_bg = createImage(self, res, self.size.width/2,self.size.height/2, cc.p(0.5,0.5), true,1,true)
        self.select_bg:setContentSize(self.size)
        self.select_bg:setZOrder(1)
    end
    self.select_bg:setVisible(status)
end


function SkillItem:setTickSelected(status)
    if status then
        if self.lay_select == nil then
            self.lay_select = ccui.Layout:create()
            self.lay_select:setAnchorPoint(cc.p(0.5,0.5))
            self.lay_select:setContentSize(self.size)
            self.lay_select:setPosition(self.size.width/2, self.size.height/2) 
            self.lay_select:setTouchEnabled(false)
            showLayoutRect(self.lay_select, 150)
            local res = PathTool.getResFrame("common","common_1043")
            createImage(self.lay_select,res,self.size.width/2,self.size.height/2,cc.p(0.5,0.5),true,0,false)

            self:addChild(self.lay_select, 1)
        else
            self.lay_select:setVisible(true)
        end
    else
        if self.lay_select then
            self.lay_select:setVisible(false)
        end
    end
end

--==============================--
--desc:点击回调
--time:2017-07-03 08:02:23
--@callback:
--@return 
--==============================--
function SkillItem:addCallBack(callback)
    self.callback = callback
end

-- 特殊技能标识（元素圣殿用到，技能tips界面不显示一些东西）
function SkillItem:setTipsHideFlag( flag )
    self.tips_hide_flag = flag
end

-- 特殊显示技能tips中的释放回合数
function SkillItem:setSkillFirstCd( first_cd )
    self.first_cd = first_cd
end

-- 神器技能tips需要特殊显示
function SkillItem:setHallowsAtkVal( hallows_atk_val )
    self.hallows_atk_val = hallows_atk_val
end

--==============================--
--desc:注册相关事件
--time:2017-07-03 01:53:49
--@return 
--==============================--
function SkillItem:registerEvent()
    if self.click == true then
        self:addTouchEventListener(function(sender, event_type) 
            customClickAction_2(self, event_type, self.scale)

            if self.clickScroll then
                if event_type == ccui.TouchEventType.began then
                    self.touch_began = sender:getTouchBeganPosition()
                end    
            end
            if event_type == ccui.TouchEventType.ended then

                if self.clickScroll then
                    local touch_began = self.touch_began
                    local touch_end = sender:getTouchEndPosition()
                    if touch_began and touch_end and (math.abs(touch_end.x - touch_began.x) > 20 or math.abs(touch_end.y - touch_began.y) > 20) then 
                        --移动大于20了..表示本点击无效
                        return
                    end 

                end
                playButtonSound2()
                if self.btn_fun and (not self.data) then
                    self:btn_fun(self.add_btn_index)
                else
                    if self.is_show_tips == true then
                        if self.skill_config then
                            TipsManager:getInstance():showSkillTips(self.skill_config, self.is_unabled or false, false, self.tips_hide_flag or false, self.first_cd or 0, self.hallows_atk_val or 0)
                        elseif self.lock_tips then
                            message(self.lock_tips)
                        elseif self.none_tips then
                            message(self.none_tips)
                        end
                    end
                    if sender.guide_call_back ~= nil then
                        sender.guide_call_back(sender)
                    end
                    if self.callback then
                        self:callback()
                    end
                end
            end
        end)
    end
end

--==============================--
--desc:设置数据
--time:2018-05-16 03:21:17
--@data:
--@return 
--==============================--
function SkillItem:setData(data,setting)
    self.data = data
    self.setting = setting or {}
    self:showRedPoint(false)
    local res = PathTool.getNormalSkillBg()
    self.background:loadTexture(res, LOADTEXT_TYPE_PLIST)
    if self.data == nil or not next(self.data) then
        self.skill_config = nil
        self.item_icon:setVisible(false)
        if self.num_label then
            self.num_label:setVisible(false)
        end
        self:showName(false)
        self.background_res_id = PathTool.getQualityBg(0)
        self.background:loadTexture(self.background_res_id, LOADTEXT_TYPE_PLIST)
        if self.skill_eff then
            self.skill_eff:setVisible(false)
        end
        self:setHeroSkillLev(false)
        return
    else
        local id = data.skill_bid or  data.skill_id or data.bid
        local skill_config = Config.SkillData.data_get_skill(id)
        if not skill_config then return end
        self.skill_config = skill_config
        local skill_icon = PathTool.getSkillRes(skill_config.icon, false)
        self.item_icon:setVisible(true)
        loadSpriteTexture(self.item_icon, skill_icon, LOADTEXT_TYPE)

        local background_res_id = PathTool.getQualityBg(0)
        if skill_config.type == "passive_skill" then
            -- background_res_id = PathTool.getQualityBg(skill_config.level-1)
        end

        if self.background_res_id ~= background_res_id then
            self.background_res_id = background_res_id
            self.background:loadTexture(self.background_res_id, LOADTEXT_TYPE_PLIST)
        end
        if self.setting.is_sp then
            local skill_cfg = Config.SkillExtensionData.data_get_skill(id)
            if skill_cfg and skill_cfg.next_id == 0 then
                local res = PathTool.getResFrame("hero/special_hero", "special_hero_003")
                self.background:loadTexture(res, LOADTEXT_TYPE_PLIST)
            end
        end
        if Config.SkillExtensionData.data_get_other then
            local other_cfg = Config.SkillExtensionData.data_get_other[id]
            if other_cfg and other_cfg.resource and other_cfg.resource ~= "" then
                local res = PathTool.getResFrame("common", other_cfg.resource,false,"common_1")
                self:changeBackGround(res)
            end
            if other_cfg and other_cfg.other and other_cfg.other ~= "" then
                local res = PathTool.getResFrame("common", other_cfg.other,false,"common_1")
                self:setSkillSPKuang(true,res)
            else
                self:setSkillSPKuang(false)
            end
        end
        -- 显示等级,现在只有天赋技能显示等级
        if self.show_lev and self.num_label or self.num_label2 then
            if skill_config.client_lev and skill_config.client_lev > 0 then
                self.num_label:setVisible(true)
                self.num_label:setString(skill_config.client_lev)
                if self.num_label2 then
                    self.num_label2:setString(skill_config.client_lev)
                end
            elseif skill_config.level and skill_config.level > 0 then
                self.num_label:setVisible(true)
                self.num_label:setString(skill_config.level)
                if self.num_label2 then
                    self.num_label2:setString(skill_config.level)
                end
            else
                self.num_label:setVisible(false)
            end
        end

        if data and data.is_show_name and data.is_show_name == true then
            self:showName(true,skill_config.name)
        end
        self:showRecommondIcon(false)
        if data and data.is_recommend and data.is_recommend == true then 
            self:showRecommondIcon(true)
        end
        if data and data.is_learn and data.is_learn ==true then 
            self:showRecommondIcon(true,2)
        end

        -- 引导需要
        if data then
            if self.can_reset_name == true then
                self:setName("guidesign_skillitem_"..id)
            end
        end

        --是否觉醒天赋
        if not Config or not Config.PartnerSkillData then
            require("config.partner_skill_data")
        end
        local golden_skill_list = Config.PartnerSkillData.data_partner_skill_const.golden_skill_list.val
        if table.indexof(golden_skill_list,id) then
            --是13星英雄 的觉醒天赋
            self:showGoldTalentSkillIcon(true)
        else
            self:showGoldTalentSkillIcon(false)
        end
        local partner_awakening_skill_config = Config.PartnerSkillData.data_partner_awakening_skill
        if partner_awakening_skill_config and partner_awakening_skill_config[id] then
            --是13星英雄 的觉醒天赋
            self:showAwakeningSkillIcon(true, partner_awakening_skill_config[id])
        else
            self:showAwakeningSkillIcon(false)
        end
        if self.up_img then
            local partner_cfg = Config.PartnerData.data_partner_const
            if partner_cfg["skill_buffed"] then
                local skill_buffed = partner_cfg["skill_buffed"].val
                if table.indexof(skill_buffed,data.group) then
                    self.up_img:setVisible(true)
                else
                    self.up_img:setVisible(false)
                end
            end
        end
        if self.skill_eff then
            self.skill_eff:setVisible(false)
        end
        if skill_config.icon_eff and skill_config.icon_eff ~= "" then
            if not self.skill_eff then
                self.skill_eff = createEffectSpine(skill_config.icon_eff, cc.p(SkillItem.Width/2, SkillItem.Height/2), cc.p(0.5, 0.5),true,"action")
                self.skill_eff:setScale(1.2)
                self:addChild(self.skill_eff,999)
                self.skill_eff:setVisible(true)
            else
                self.skill_eff:setVisible(true)
            end
        end
        self:setHeroSkillLev(true)
    end 
    
    if data and data.is_touch and data.is_touch == true then 
        if self.callback then
            self:callback()
        end
        data.is_touch = false
    end
    if data and data.scale_value and type(data.scale_value) == "number" then 
        self.root_wnd:setScale(data.scale_value)
    end
end

function SkillItem:setGrayStatus(bool)
    local num = 255
    if bool == true then 
        num = 160
    end
    self.item_icon:setOpacity(num)
end

--变灰
function SkillItem:showUnEnabled(bool)
    setChildUnEnabled(bool, self.item_icon)
    setChildUnEnabled(bool, self.background)
    if self.level_bg then
        setChildUnEnabled(bool, self.level_bg)
    end
    self.is_unabled = bool
end
--锁
function SkillItem:showLockIcon(bool,str,tips)
    if bool == false and not self.artifact_lock then return end
    if not self.artifact_lock then 
        local res = PathTool.getResFrame("common","common_90009")
        self.artifact_lock = createImage(self, res, 60,60, cc.p(0.5,0.5), true, 1, false)

        self.lock_label = createLabel(22,cc.c4b(0xd9,0xcc,0xbb,0xff),cc.c4b(0x56,0x25,0x12,0xff),57,12,"",self,1, cc.p(0.5,0))
    end
    str = str or ""
    self.artifact_lock:setVisible(bool)
    self.lock_label:setVisible(bool)
    self.lock_label:setString(str)
    self.lock_tips = tips
end
--推荐标签
function SkillItem:showRecommondIcon(bool,qian_type)
    if bool == false and not self.recommond_icon then return end
    if not self.recommond_icon then 
        local res = PathTool.getResFrame("common","common_90015")

        -- self.recommond_icon = createImage(self,res,34,89,cc.p(0.5,0.5),true,10,true)
        self.recommond_icon = createSprite(res,34,89,self,cc.p(0.5,0.5),nil,2)
        self.recommond_label = createLabel(18,Config.ColorData.data_color4[1],cc.c4b(0x95,0x0f,0x00,0xff),29,25,"",self.recommond_icon,2, cc.p(0.5,0))
        self.recommond_label:setRotation(-45)
        
    end
    if bool == true then
        self.recommond_icon:setVisible(true)
        local qian_type = qian_type or 1
        local str 
        local res 
        if qian_type == 1 then
            str = TI18N("语言_c_1363")
            res = PathTool.getResFrame("common","common_30016") --紫色
            self.recommond_icon:setPosition(31,87)
            self.recommond_label:setPosition(31,37)
            self.recommond_label:enableOutline(cc.c4b(0x5c,0x1b,0x77,0xff), 2)
        elseif qian_type == 2 then
            str = TI18N("语言_c_2930")
            res = PathTool.getResFrame("common","common_30013") --红色
            self.recommond_icon:setPosition(31,87)
            self.recommond_label:setPosition(31,37)
            self.recommond_label:enableOutline(cc.c4b(0x8e,0x2b,0x00,0xff), 2)
        elseif qian_type ==3 then
            str = TI18N("语言_c_2931")
            res = PathTool.getResFrame("common","common_90015") --位置不同的红色
            self.recommond_icon:setPosition(34,89)
            self.recommond_label:setPosition(29,25)
            self.recommond_label:enableOutline(cc.c4b(0x95,0x0f,0x00,0xff), 2)
        elseif qian_type == 4 then
            str = TI18N("语言_c_2932")
            res = PathTool.getResFrame("common","common_90015")--位置不同的红色
            self.recommond_icon:setPosition(34,89)
            self.recommond_label:setPosition(29,25)
            self.recommond_label:enableOutline(cc.c4b(0x95,0x0f,0x00,0xff), 2)
        elseif qian_type == 5 then
            str = TI18N("语言_c_2933")
            res = PathTool.getResFrame("common","common_30015") --蓝色
            self.recommond_icon:setPosition(31,87)
            self.recommond_label:setPosition(31,37)
            self.recommond_label:enableOutline(cc.c4b(0x00,0x55,0x74,0xff), 2)
        else
            --无效类型 自行打印
            self.recommond_icon:setVisible(false)
            return    
        end
        loadSpriteTexture(self.recommond_icon, res, LOADTEXT_TYPE_PLIST)
        self.recommond_label:setString(str)
    else
        self.recommond_icon:setVisible(false)        
    end
    
end

-- 稀有标识
function SkillItem:showUnusualIcon( status ,type)--type 1：稀有  2：强力
    if status == false and not self.unusual_icon then return end
    if not self.unusual_icon then  
        self.unusual_icon = createSprite(nil,-6,123,self,cc.p(0,1),nil,2)
    end

    if status == true then
        local res = PathTool.getResFrame("common","txt_cn_common_unusual")
        if type and type == 2 then
            res = PathTool.getResFrame("common","txt_cn_common_unusual_2")
        end
        loadSpriteTexture(self.unusual_icon, res, LOADTEXT_TYPE_PLIST)
    end
    
    self.unusual_icon:setVisible(status)
end
-- 显示13星觉醒技能标志
function SkillItem:showAwakeningSkillIcon( status , partner_awakening_skill_config)
    if status == false and not self.awakening_icon then return end
    if not self.awakening_icon then  
        self.awakening_icon = createSprite(PathTool.getResFrame("common","common_1108"),60,127,self,cc.p(0.5,1),nil,2)
    end
    self.awakening_icon:setVisible(status)
    if partner_awakening_skill_config then
        if status then
            if self.skill_profession_icon == nil then
                self.skill_profession_icon = createSprite(nil,102,36,self,cc.p(0.5,1),nil,2)
                local res = PathTool.getPlistImgForDownLoad("bigbg/hero", "talent_profession")
                self.skill_profession_icon_item_load = loadSpriteTextureFromCDN(self.skill_profession_icon, res, ResourcesType.single, self.skill_profession_icon_item_load)
            end
            if self.skill_profession_label == nil then
                self.skill_profession_label = createLabel(20,cc.c3b(0xff,0xf6,0xcc),nil,14.5,17,"",self.skill_profession_icon,1, cc.p(0.5,0.5))
            end
            local limit_career = partner_awakening_skill_config.limit_career or {}
            local profession_name
            if limit_career and next(limit_career) ~= nil then
                --目前只有一个职业拿第一个
                profession_name = HeroConst.CareerName2[limit_career[1][1]] or TI18N("语言_c_2934")
            else
                profession_name = TI18N("语言_c_2934")
            end
            self.skill_profession_label:setString(profession_name)  
        end
    end
    if self.skill_profession_icon then
        self.skill_profession_icon:setVisible(status)
    end
end

--显示下方的名字
function SkillItem:showName(bool,name,pos,fontSize, is_bg,fontColor,res_img,res_size,maxChar)
    if bool == false and not self.name then return end
    if not self.name then 
        if is_bg and self.name_bg == nil then
            local res = res_img or PathTool.getResFrame("common","common_2028")
            local resSize = res_size or cc.size(108,30)
            self.name_bg = createImage(self, res, 60,-32, cc.p(0.5,0), true, 0, true)
            self.name_bg:setContentSize(resSize)
            self.name_bg:setCapInsets(cc.rect(10, 14, 1, 1))
        end
        fontSize = fontSize or 24
        fontColor = fontColor or Config.ColorData.data_color4[156]
        self.name = createLabel(fontSize,fontColor,nil,54,0,"",self.name_bg,1, cc.p(0.5,0))
        
    end
    name = name or ""
    local maxChar = maxChar or 0
    if maxChar ~= 0 then
        self.name:setString(transformTextToShort(name,maxChar))
        addEvt2showAllTextTips(self.name,name,maxChar,nil,nil,nil,true,true)
    else
        self.name:setString(name)
    end
    
    self.name:setVisible(bool)
    if self.name_bg then
        self.name_bg:setVisible(bool)
        self.name_bg:setContentSize(cc.size(self.name:getContentSize().width + 20,self.name_bg:getContentSize().height))
        self.name:setPositionX(self.name_bg:getContentSize().width/2)
    end
    if pos then 
        self.name:setPosition(pos)
        if self.name_bg then
            self.name_bg:setPosition(cc.p(pos.x,pos.y -2))
        end
    end
end

--显示下方的使用率
function SkillItem:showProbability(bool,probability,pos,fontSize, is_bg,fontColor,res_img,res_size)
    if bool == false and not self.probability then return end
    if not self.probability then 
        if is_bg and self.probability_bg == nil then
            local res = res_img or PathTool.getResFrame("common","common_2028")
            local resSize = res_size or cc.size(108,30)
            self.probability_bg = createImage(self, res, 60,-72, cc.p(0.5,0), true, 0, true)
            self.probability_bg:setContentSize(resSize)
            self.probability_bg:setCapInsets(cc.rect(10, 14, 1, 1))
        end
        fontSize = fontSize or 24
        fontColor = fontColor or Config.ColorData.data_color4[156]
        self.probability = createLabel(fontSize,fontColor,nil,60,-70,"",self,1, cc.p(0.5,0))
    end
    probability = probability or ""
    local prob = probability.."%"
    local str = string.format(TI18N("使用率%s"),prob)
    self.probability:setString(str)
    self.probability:setVisible(bool)
    if self.probability_bg then
        self.probability_bg:setVisible(bool)
    end
    if pos then 
        self.probability:setPosition(pos)
        if self.probability_bg then
            self.probability_bg:setPosition(cc.p(pos.x,pos.y -2))
        end
    end
end

-- 修改名字颜色
function SkillItem:setNameColor( nameColor, outlineColor, outlineSize )
    if self.name then
        if nameColor then
            self.name:setTextColor(nameColor)
        end
        if outlineColor and outlineSize then
            self.name:enableOutline(outlineColor, outlineSize)
        end
    end
end
--加号
function SkillItem:showAddIcon(bool,index)
    if bool == false and not self.add_btn then return end
    self.add_btn_index = index
    if not self.add_btn then 
        local res = PathTool.getResFrame("common","common_90026")
        self.add_btn = createSprite(res, 60, 60, self, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
        -- self.add_btn = createButton(self.root_wnd, "", 60,60, nil, res)
        -- self.add_btn:addTouchEventListener(function(sender, event_type) 
        --  if event_type == ccui.TouchEventType.ended then
        --      playButtonSound2()
        --      if self.btn_fun then
        --          self:btn_fun(index)
        --      end
        --  end
        -- end)
    end
    self.add_btn:setVisible(bool)
end

function SkillItem:showLevel( status )
    self.show_lev = status
    if status == true then
        if not self.level_bg then
            self.level_bg = createImage(self, PathTool.getResFrame("common","common_2018"), 10,108, cc.p(0.5,0.5), true, 1, true)
            self.level_bg:setContentSize(cc.size(35, 35))
        end
        if not self.num_label then
            self.num_label = createLabel(20,cc.c4b(0x64,0x32,0x23,0xff),nil,8,107,"00",self,1, cc.p(0.5,0.5))
            self.num_label:setZOrder(1)
        end
        if not self.num_label2 then
            self.num_label2 = createLabel(24,cc.c4b(0xff,0xff,0xff,0xff),cc.c4b(0x00,0x00,0x00,0xff),0,115,"00",self,1, cc.p(0.5,0.5))
            self.num_label2:setZOrder(1)
        end
        self.level_bg:setVisible(true)
        self.num_label:setVisible(true)
        self.num_label2:setVisible(false)
    else
        if self.level_bg then
            self.level_bg:setVisible(false)
        end
        if self.num_label then
            self.num_label:setVisible(false)
        end
        if self.num_label2 then
            self.num_label2:setVisible(false)
        end
    end
end
function SkillItem:showLevelBg( status )
    self.level_bg:setVisible(status)
    self.num_label:setVisible(status)
    self.num_label2:setVisible(false)
end
-- 显示“无”
function SkillItem:showNoneText( status, none_tips )
    if status == true then
        if not self.none_txt then
            self.none_txt = createLabel(32, cc.c4b(255,236,178,255), nil, self.size.width/2, self.size.height/2, TI18N("语言_c_2103"), self, nil, cc.p(0.5, 0.5))
        end
        self.none_txt:setVisible(true)
    elseif self.none_txt then
        self.none_txt:setVisible(false)
    end
    self.none_tips = none_tips
end

--红点
function SkillItem:showRedPoint(bool)
    if self.skill_config and self.skill_config.next_id ==0 then 
        bool = false
    end
    if bool == false and not self.red_point then return end
    if not self.red_point then 
        local res = PathTool.getResFrame("common","common_1014")
        self.red_point = createImage(self,res,107,107,cc.p(0.5,0.5),true,10,false)
        self.red_point:setScale(0.7)
    end
    self.red_point:setVisible(bool)
end

-- 箭头红点红点
function SkillItem:showArrowRedPoint(bool)
    if bool == false and not self.arrow_red_point then return end
    if not self.arrow_red_point then 
        local res = PathTool.getResFrame("common","common_1086")
        self.arrow_red_point = createImage(self,res,103,100,cc.p(0.5,0.5),true,10,false)
        -- self.arrow_red_point:setScale(0.7)
    end
    self.arrow_red_point:setVisible(bool)
end
function SkillItem:setAddBtnFun(btn_fun)
    self.btn_fun = btn_fun
end

function SkillItem:isHaveData()
    if not self.data or next(self.data) ==nil then return false end

    return true
end

function SkillItem:getSkillConfig()
    return self.skill_config
end
function SkillItem:setSpSkillSubscript(status,_type)  --忍术1，体术2
    if status then
        if not self.sp_skill_icon then
            self.sp_skill_icon = createSprite(nil,109,109,self.item_icon,cc.p(1,1),LOADTEXT_TYPE,999)
        end
        self.sp_skill_icon:setVisible(true)
        local res = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_sp_nin")
        if _type == 1 then
            res = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_sp_nin")
        elseif _type == 2 then
            res = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_sp_tai")
        elseif _type == 3 then
            res = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_ur_nin")
        elseif _type == 4 then
            res = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_ur_tai")
        elseif _type == 5 then
            res = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_mr_nin")
        elseif _type == 6 then
            res = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_mr_tai")
        end
        loadSpriteTexture(self.sp_skill_icon, res, LOADTEXT_TYPE)
    else
        if self.sp_skill_icon then
            self.sp_skill_icon:setVisible(false)
        end
    end
    if MAKELIFEBETTER_NEW then
        if self.sp_skill_icon then
            self.sp_skill_icon:setVisible(false)
        end
    end
end
function SkillItem:setSkillSubscript(_type)  --忍术1，体术2
    if self.skill_config.type == "active_skill" then --主动技能
        if not self.skill_icon then
            self.skill_icon = createSprite(nil,109,-4,self.item_icon,cc.p(1,0),LOADTEXT_TYPE,999)
        end
        self.skill_icon:setVisible(true)
        local res = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_skill_nin")
        if _type == 1 then
            res = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_skill_nin")
        elseif _type == 2 then
            res = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_skill_tai")
        end
        loadSpriteTexture(self.skill_icon, res, LOADTEXT_TYPE)
    else
        if self.skill_icon then
            self.skill_icon:setVisible(false)
        end
    end
    if MAKELIFEBETTER_NEW then
        if self.skill_icon then
            self.skill_icon:setVisible(false)
        end
    end
end
function SkillItem:setSkillLevel(skill_level)
    self.skill_level = skill_level or 0
end


function SkillItem:setSupportItem(status,elfin_id)
    if status then
        if not self.support_item then
            self.support_item = SkillItem.new(true, false, false, 0.5, true)
            self:addChild(self.support_item)
            self.support_item:setAnchorPoint(cc.p(1,0))
            self.support_item:setPosition(cc.p(SkillItem.Width,0))
        end
        self.support_item:setVisible(true)
        local cfg = Config.SpriteData.data_elfin_data(elfin_id)
        if cfg then
            local skill_config = Config.SkillData.data_get_skill(cfg.support_skill_id)
            if skill_config then
                self.support_item:setData(skill_config)
            end
        else
            if self.support_item then
                self.support_item:setVisible(false)
            end    
        end
    else
        if self.support_item then
            self.support_item:setVisible(false)
        end
    end
end

function SkillItem:changeBackGround(res)
    if self.background then
        self.background:loadTexture(res, LOADTEXT_TYPE_PLIST)
    end
end
--改变背景框显示
function SkillItem:setBgVisible(bool)
    if self.background then
        self.background:setVisible(bool)
    end
end
function SkillItem:setSkillSPKuang(status,res)
    if status then
        local res = res or PathTool.getResFrame("common", "common_1_537",false,"common_1")
        if not self.sp_skill_kuang then
            self.sp_skill_kuang = createSprite(res,SkillItem.Width*0.5,SkillItem.Height*0.5,self,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
        end
        loadSpriteTexture(self.sp_skill_kuang, res, LOADTEXT_TYPE_PLIST)
        self.sp_skill_kuang:setVisible(true)
    else
        if self.sp_skill_kuang then
            self.sp_skill_kuang:setVisible(false)
        end
    end
    if MAKELIFEBETTER_NEW then
        if self.sp_skill_kuang then
            self.sp_skill_kuang:setVisible(false)
        end
    end
end
-- 显示金色秘术技能标志
function SkillItem:showGoldTalentSkillIcon(status)
    if status == false and not self.gold_talent_icon then return end
    if not self.gold_talent_icon then  
        self.gold_talent_icon = createSprite(PathTool.getResFrame("common_1","common_1_584"),60,127,self,cc.p(0.5,1),nil,2)
    end
    self.gold_talent_icon:setVisible(status)
    if status then
        if self.skill_gold_talent_icon == nil then
            local res = PathTool.getResFrame("common_1","common_1_585")
            self.skill_gold_talent_icon = createSprite(res,97,39,self,cc.p(0.5,1),nil,2)
        end
    end
    if self.skill_gold_talent_icon then
        self.skill_gold_talent_icon:setVisible(status)
    end
end

-- 忍者技能等级展示
function SkillItem:setHeroSkillLev(status)
    if status then
        if not Config.PartnerData.data_partner_skill_lev or not Config.PartnerData.data_partner_skill_lev[self.skill_config.group] or Config.PartnerData.data_partner_skill_lev[self.skill_config.group] == 0 then
            status = false
        end
    end
    if status then
        local res = PathTool.getResFrame("common", "common_1_555",false,"common_1")
        if not self.hero_skill_lev then
            self.hero_skill_lev = createSprite(res,15,106,self,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST,1000)
        end
        if self.hero_skill_lev then
            self.hero_skill_lev:setVisible(true)
        end
        if not self.hero_skill_txt then
            self.hero_skill_txt = createLabel(30,cc.c3b(0xff, 0xff, 0xff),cc.c3b(0x30, 0x00, 0x00),21,26,0,self.hero_skill_lev,2,cc.p(0.5,0.5))
        end
        if self.hero_skill_txt then
            local level = self.skill_config.level or 1
            if self.skill_config.client_lev and self.skill_config.client_lev>0 then
                level = self.skill_config.client_lev
            end
            self.hero_skill_txt:setString(level)
            self.hero_skill_txt:setVisible(true)
        end
    else
        if self.hero_skill_lev then
            self.hero_skill_lev:setVisible(false)
        end
        if self.hero_skill_txt then
            self.hero_skill_txt:setVisible(false)
        end
    end
    if MAKELIFEBETTER_NEW then
        if self.hero_skill_lev then
            self.hero_skill_lev:setVisible(false)
        end
        if self.hero_skill_txt then
            self.hero_skill_txt:setVisible(false)
        end
    end
end

function SkillItem:getSizeByScale()
	return cc.size(self.size.width * self.scale, self.size.height * self.scale)
end
--特殊显示等级
function SkillItem:setShowLevel(status,scale,x,y)
    if status then
        if not self.speil_level_bg then
            local res = PathTool.getResFrame("common", "common_1_555",false,"common_1")
            self.speil_level_bg = createImage(self, res, 22,104, cc.p(0.5,0.5), true, 1, false)
            local size = self.speil_level_bg:getContentSize()
            self.speil_level_txt = createLabel(24,cc.c3b(0xff,0xff,0xff),cc.c3b(0x00,0x00,0x00),size.width*0.5-2,size.height*0.5+1,self.skill_config.level,self.speil_level_bg,2,cc.p(0.5,0.5))
        end
        self.speil_level_bg:setVisible(true)
        self.speil_level_txt:setVisible(true)
        self.speil_level_txt:setString(self.skill_config.level)
        self.speil_level_bg:setScale(scale or 1)
        if x and y then
            self.speil_level_bg:setPosition(cc.p(x,y))
        end
    else
        if self.speil_level_bg then
            self.speil_level_bg:setVisible(false)
            self.speil_level_txt:setVisible(false)
        end
    end
end
--显示装属技能装备忍者
function SkillItem:setHeroHead(status,pid)
    if status then
        if not self.hero_bg then
            local res = PathTool.getResFrame("bondskill", "bondskill_16")
            self.hero_bg = createSprite(res,100,20,self,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
            local mask = createSprite(PathTool.getResFrame("bondskill","bondskill_14",false,"bondskill"), 22, 22, nil, cc.p(0.5, 0.5),LOADTEXT_TYPE_PLIST)--模板
            mask:setScale(1)
            local clipNode = cc.ClippingNode:create(mask)
            clipNode:setAnchorPoint(cc.p(0.5,0.5))
            clipNode:setContentSize(self.hero_bg:getContentSize())
            clipNode:setCascadeOpacityEnabled(true)
            clipNode:setPosition(22,22)
            clipNode:setAlphaThreshold(0)
            self.hero_bg:addChild(clipNode,2)

            self.hero_icon = ccui.ImageView:create()
            self.hero_icon:setCascadeOpacityEnabled(true)
            self.hero_icon:setAnchorPoint(0.5,0.5)
            self.hero_icon:setPosition(22,22)--底板
            clipNode:addChild(self.hero_icon,3)
            self.hero_icon:setScale(0.5)
            local res2 = PathTool.getResFrame("bondskill", "bondskill_32")
            self.hero_cir = createSprite(res2,100,20,self,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
        end
        local hero_vo = HeroController:getInstance():getModel():getHeroById(pid)
        if hero_vo and next(hero_vo) then
            local bid = HeroController:getInstance():getModel():getSelfConvertStaBid(hero_vo.bid)
            self.hero_icon:loadTexture(PathTool.getHeadIcon(bid), LOADTEXT_TYPE)
            self.hero_bg:setVisible(true)
            self.hero_cir:setVisible(true)
        end
    else
        if self.hero_bg then
            self.hero_bg:setVisible(false)
            self.hero_cir:setVisible(false)
        end
    end 
end
function SkillItem:setStarNum(status,num)
    if status and num > 0 then
        if not self.star_con then
            self.star_con = ccui.Widget:create()
            self.star_con:setZOrder(3)
            self.star_con:setPosition(cc.p(self.size.width * 0.5,2))
            self:addChild(self.star_con)
        end
        self.star_con:setVisible(true)
        self.star_setting = self:createStar(num, self.star_con, self.star_setting,16) 
    else
        if self.star_con then
            self.star_con:setVisible(false)
        end
    end
end

function SkillItem:createStar(num, star_con, star_setting, star_width)
    local num = num or 0
    local star_setting = star_setting or {}
    if star_setting.star_list == nil then
        star_setting.star_list = {}
    end

    if star_setting.star_list2 == nil then
        star_setting.star_list2 = {}
    end

    for i,v in pairs(star_setting.star_list) do
        if v and not tolua.isnull(v) then
            v:setVisible(false)
        end
    end
    for i,v in pairs(star_setting.star_list2) do
        if v and not tolua.isnull(v) then
            v:setVisible(false)
        end
    end
    if star_setting.star10 and not tolua.isnull(star_setting.star10) then
        star_setting.star10:setVisible(false)
    end

    if star_setting.moon and not tolua.isnull(star_setting.moon) then
        star_setting.moon:setVisible(false)
    end

    local width_s = star_width or (29 + 3)
    local _cStar = function(star_count, res, star_list,moveW)
        local width = star_width or (29 + 3)
        local x = - star_count * width * 0.5 + width * 0.5
        if moveW then 
            x = x + moveW
        end
        for i=1,star_count do
            if not star_list[i] or tolua.isnull(star_list[i]) then 
                local star = createImage(star_con,res,0,0,cc.p(0.5,0.5),true,1,false)
                star:setScale(1)
                star_list[i] = star
            end
            star_list[i]:setVisible(true)
            star_list[i]:setPositionX(x + (i-1) * width)
        end
    end
    if num > 0 and num <= 5 then
        local res = PathTool.getResFrame("common","common_1_604",false,"common_1")
        _cStar(num, res, star_setting.star_list)
    elseif num >= 6 and num <= 9 then
        local res = PathTool.getResFrame("common","common_90074")
        local moonres = PathTool.getResFrame("common","common_90075_1")
        if star_setting.moon == nil or tolua.isnull(star_setting.moon) then 
            local star = createImage(star_con,moonres,0, 0,cc.p(0.5,0.5),true,0,false)
            star_setting.moon = star
            star_setting.moon:setScale(1.2)
        else
            star_setting.moon:setVisible(true)
        end
        local count = num - 5
        _cStar(count, res, star_setting.star_list,width_s*0.5)

        local startmoon = - count * width_s * 0.5 + width_s * 0.5 -width_s*0.5
        star_setting.moon:setPositionX(startmoon)
    elseif num >= 10 then
        local new_num  = num - 10
        local res = PathTool.getResFrame("common","common_90073_1")
        if star_setting.star10 == nil or tolua.isnull(star_setting.star10) then 
            local star = createImage(star_con,res,0, 0,cc.p(0.5,0.5),true,0,false)
            star:setScale(1.2)
            star:setCascadeOpacityEnabled(true)
            star_setting.star10 = star
        else
            star_setting.star10:setVisible(true)
        end

        local res = PathTool.getResFrame("common","common_90074")
        _cStar(new_num, res, star_setting.star_list,width_s*0.5+4)
        local startsun = - new_num * width_s * 0.5 + width_s * 0.5 -width_s*0.5
        star_setting.star10:setPositionX(startsun)
    end
    return star_setting
end
-- 显示是否被金色秘卷装备
function SkillItem:showGoldArtifactSkillIcon(status,icon)
    if status == false and not self.gold_artifact_icon then return end
    if not self.gold_artifact_icon then  
        self.gold_artifact_bg = createSprite(PathTool.getResFrame("common","common_427"),SkillItem.Width,0,self,cc.p(1,0),LOADTEXT_TYPE_PLIST)
        self.gold_artifact_bg:setScale(0.4)
        self.gold_artifact_icon = createSprite(PathTool.getResFrame("artifact_golden", icon),SkillItem.Width*0.5,SkillItem.Height*0.5,self.gold_artifact_bg,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
        self.gold_artifact_icon:setScale(0.6)
    end
    self.gold_artifact_icon:setVisible(status)
end
function SkillItem:DeleteMe()
    if self.skill_eff then
        self.skill_eff:removeFromParent()
        self.skill_eff = nil
    end
    if self.skill_profession_icon_item_load_bg then
        self.skill_profession_icon_item_load_bg:DeleteMe()
        self.skill_profession_icon_item_load_bg = nil
    end
    if self.star_con then
        self.star_con:removeFromParent()
        self.star_con = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end