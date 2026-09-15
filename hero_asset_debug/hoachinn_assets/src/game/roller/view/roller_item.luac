-- --------------------------------------------------------------------
-- 背包的通用物品 
-- 
-- (必填, 创建模块的人员)
-- (必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
RollerItem = class("RollerItem", function() 
	return ccui.Layout:create()
end)

RollerItem.Width = 119
RollerItem.Height = 119

local role_vo = RoleController:getInstance():getRoleVo()

function RollerItem:ctor(click, scale, is_show_tips)
	self.click = click or true
	self.scale = scale or 1
	self.swallow_touch = true

	self.root_wnd = createCSBNote(PathTool.getTargetCSB("roller/roller_item"))
	if not self.root_wnd then return end
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	self:setTouchEnabled(self.click)
	self:setCascadeOpacityEnabled(true)
	if self.scale ~= 1 then
		self:setScale(self.scale)
	end

	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width/2, self.size.height/2)
	self:addChild(self.root_wnd)

	self.main_container = self.root_wnd:getChildByName("main_container")
  	self.background = self.main_container:getChildByName("background")
	self.item_icon = self.main_container:getChildByName("icon")
	self.txt_bg = self.main_container:getChildByName("txt_bg")
	self.txt_bg:setVisible(false)
	self.label = self.main_container:getChildByName("label")
	self.label:setTouchEnabled(true)
	self.label:setVisible(false)
	local power_label = self.main_container:getChildByName("power_label")
	self.power_label = createRichLabel(20, cc.c4b(0x7c, 0x55, 0x36, 0xff), cc.p(0.5, 0.5), cc.p(60, -14), nil, -4, 119)
	self.main_container:addChild(self.power_label)

	self.power_icon = self.main_container:getChildByName("power_icon")
	self.power_icon:setVisible(false)
	self.lock_panel = self.main_container:getChildByName("lock_panel")
	self.lock_panel:setVisible(false)
	self.only_panel = self.main_container:getChildByName("only_panel")
	self.only_panel:setVisible(false)
    self.hero_icon = self.only_panel:getChildByName("hero_icon")

	self.background_res_id = PathTool.getQualityBg(0)
	self:registerEvent()
end

function RollerItem:getData()
	return self.data
end

function RollerItem:setswTouchStatus(status)
	self:setSwallowTouches(status)
end

function RollerItem:setSelected(status)
	if not self.select_bg and status == false then return end
	if not self.select_bg then 
		local res= PathTool.getSelectBg()
		self.select_bg = createImage(self.main_container, res, self.size.width/2,self.size.height/2, cc.p(0.5,0.5), true,nil,true)
		self.select_bg:setContentSize(cc.size(self.Width,self.Height))
	end
	self.select_bg:setVisible(status)
end

function RollerItem:addCallBack(callback)
	self.callback = callback
end

--添加长时间点击的回调
function RollerItem:addLongTimeTouchCallback(callback)
    --默认有效果
    self:setLongTimeTouchEffect(true)
    self.long_time_callback = callback
end

--设置长时间点击的回调效果
function RollerItem:setLongTimeTouchEffect(is_touch)
    self.have_long_time_effect = is_touch
end
--==============================--
--desc:注册相关事件
--time:2017-07-03 01:53:49
--@return 
--==============================--
function RollerItem:registerEvent()
	if self.click == true then
		self:setTouchEnabled(true)
		self:addTouchEventListener(function(sender, event_type) 
			if self.effect == true then
				customClickAction_2(self.main_container, event_type)
			end
			if event_type == ccui.TouchEventType.ended then
				if self.have_long_time_effect then
                    if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                        doStopAllActions(self.background)
                        self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
					elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
                        --事件触发了就不处理点击事件了
                        return
                    end
				end
				
				self.touch_end = sender:getTouchEndPosition()
				local is_click = true
				if self.touch_began ~= nil then
					is_click =
						math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
						math.abs(self.touch_end.y - self.touch_began.y) <= 20
				end
				if is_click == true then
					playButtonSound2()
					if self.btn_call_fun then
						self:btn_call_fun()
					else
						if self.callback then
							self:callback(self)
						end
					end
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
			elseif event_type == ccui.TouchEventType.began then
				self.touch_began = sender:getTouchBeganPosition()
				if self.have_long_time_effect then
                    --有长点击效果
                    doStopAllActions(self.background)
                    self.long_touch_type = LONG_TOUCH_BEGAN_TYPE
                    delayRun(self.background, 0.6, function ()
                        if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                            if self.long_time_callback then
                                self.long_time_callback()
                            end
                        end
                        self.long_touch_type = LONG_TOUCH_END_TYPE
                    end)
                end
			elseif event_type == ccui.TouchEventType.canceled then
				if self.have_long_time_effect then
                    if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                        doStopAllActions(self.background)
                        self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                    end
                end
			end
		end)
		if self.swallow_touch == false then
			self:setSwallowTouches(self.swallow_touch)
		end
	end
end

function RollerItem:setBackgroundRes( res_id )
	if self.background_res_id ~= res_id then
		self.background_res_id = res_id
		self.background:loadTexture(self.background_res_id, LOADTEXT_TYPE_PLIST)
	end
end

function RollerItem:setClickAction(status)
	self.effect = status or false
end
--底图的透明度
function RollerItem:setBackgroundOpacity(num)
	if self.background then
		self.background:setOpacity(num)
	end
end

function RollerItem:setData(data)
	self.data = data
	-- print("$$$$$$$$$$$$",vardump(data))
	local id = self.data.id

	local cfg = Config.ProhibitedScrollData.data_get_proh_scroll[id]
	local icon = cfg.icon
	local equip_name = cfg.name
	local quality = cfg.quality
	local star = data.star or 0
	local power = data.score or 0
	self:setStarCount(true,star)
	loadSpriteTexture(self.item_icon, PathTool.getRollerIcon(icon,1), LOADTEXT_TYPE)

	self.label:setString(transformTextToShort(equip_name,5))
	addEvt2showAllTextTips(self.label,equip_name,5)
	self.label:setTextColor(BackPackConst.getWhiteQualityColorC4B(quality))

	-- self.power_label:setString(power)
	local str = string.format("<img src=%s visible=true scale=0.9 /><div fontcolor=#7C5536 fontsize=20>%s</div>", PathTool.getResFrame("common","common_90001"), MoneyTool.moneyFormat(power))
	self.power_label:setString(str)
	local res_id = PathTool.getQualityBg(quality)
	if self.background_res_id ~= res_id then
		self.background_res_id = res_id
		self.background:loadTexture(self.background_res_id, LOADTEXT_TYPE_PLIST)
	end
	self.background:setVisible(true)

	-- self.txt_bg:setVisible(true)
	-- self.label:setVisible(true)
	self.power_label:setVisible(true)
	-- self.power_icon:setVisible(true)

	if data.partner_id and data.partner_id ~= 0 then
		self:setHeadIcon()
	else
		self.only_panel:setVisible(false)
	end

	if data.unlock then
		self.lock_panel:setVisible(true)
	else
		self.lock_panel:setVisible(false)
	end
end

function RollerItem:setBaseData(bid, num)
	local id = bid
	self.roller_id = id
	local cfg = Config.ProhibitedScrollData.data_get_proh_scroll[id]
	local icon = cfg.icon
	local equip_name = cfg.name
	local quality = cfg.quality
	loadSpriteTexture(self.item_icon, PathTool.getRollerIcon(icon,1), LOADTEXT_TYPE)  
	local res_id = PathTool.getQualityBg(quality)
	if self.background_res_id ~= res_id then
		self.background_res_id = res_id
		self.background:loadTexture(self.background_res_id, LOADTEXT_TYPE_PLIST)
	end
	self.background:setVisible(true)
end

-- 显示背景为 common_90010 ，颜色为品质色的物品名称
function RollerItem:showItemQualityName( status,equip_name,quality )
	if status == true then
		if not self.quality_name_bg then 
			local res = PathTool.getResFrame("common","common_90010")
			self.quality_name_bg = createImage(self.main_container, res, self.size.width*0.5, -2, cc.p(0.5, 1), true, nil, true)
			self.quality_name_bg:setContentSize(cc.size(128, 37))
			self.quality_name_txt = createLabel(20, 1, nil, 128*0.5, 37*0.5, "", self.quality_name_bg, nil, cc.p(0.5, 0.5))
		end
		-- if self.item_config then
		self.quality_name_txt:setString(equip_name)
		self.quality_name_txt:setTextColor(BackPackConst.getWhiteQualityColorC4B(quality))
		-- end
	else
		if self.quality_name_bg then
			self.quality_name_bg:setVisible(false)
		end
	end
end

function RollerItem:setHeadIcon()
	local hero_data = HeroController:getInstance():getModel():getHeroById(self.data.partner_id)
	-- print("...",vardump(hero_data))
    if hero_data.bid and hero_data.bid ~= 0 then
        if not self.head_panel then
            local vSize = cc.size(40,40)
            local mask_res = PathTool.getResFrame("ninja_treasure","ninja_treasure_66",false,"ninja_treasure")
            self.head_panel = ccui.Widget:create()
            self.head_panel:setAnchorPoint(cc.p(0.5,0.5))
            self.head_panel:setContentSize(vSize)
            self.head_panel:setTouchEnabled(false)
            -- self.head_panel:setPosition(vSize.width/2, vSize.height/2)
            self.head_panel:setCascadeOpacityEnabled(true)
            self.hero_icon:addChild(self.head_panel)
            self.mark_bg = createSprite(mask_res, vSize.width/2, vSize.height/2, self.head_panel, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 1)
            self.mask = createSprite(mask_res, vSize.width/2, vSize.height/2, nil, cc.p(0.5, 0.5))--模板
            self.clipNode = cc.ClippingNode:create(self.mask)
            self.clipNode:setAnchorPoint(cc.p(0.5,0.5))
            self.clipNode:setContentSize(vSize)
            self.clipNode:setCascadeOpacityEnabled(true)
            self.clipNode:setPosition(vSize.width/2,vSize.height/2)
            self.clipNode:setAlphaThreshold(0)
            self.head_panel:addChild(self.clipNode,2)

            self.only_icon = ccui.ImageView:create()
            self.only_icon:setCascadeOpacityEnabled(true)
            self.only_icon:setAnchorPoint(0.5,0.5)
            self.only_icon:setPosition(vSize.width/2,vSize.height/2+2)--底板
            self.only_icon:setScale(0.6)
            self.clipNode:addChild(self.only_icon,3)
        end
        self.only_icon:loadTexture(PathTool.getHeadIcon(hero_data.bid), LOADTEXT_TYPE)
        self.only_panel:setVisible(true)
    else
        self.only_panel:setVisible(false)
    end
end

function RollerItem:IsGetStatus(bool,opacity,res)
	opacity = opacity or 150
	if bool == false and not self.is_get_select then return end
	if not self.is_get_select then
		self.is_get_select = ccui.Layout:create()
        self.is_get_select:setAnchorPoint(cc.p(0.5,0.5))
        self.is_get_select:setContentSize(self.size)
        self.is_get_select:setPosition(self.size.width/2, self.size.height/2) 
        self.is_get_select:setTouchEnabled(false)
        showLayoutRect(self.is_get_select, opacity)
		local temp_res = res or PathTool.getResFrame("common","common_1043")
		createSprite(temp_res, 60,60, self.is_get_select, cc.p(0.5,0.5))
		self:addChild(self.is_get_select)
	end
	self.is_get_select:setVisible(bool)
end

-- 锁定状态
function RollerItem:setLockStatus( item_type )
	local lock_status = false
	if item_type == BackPackConst.item_type.ARTIFACTCHIPS then
		
	end

	if lock_status == true then
		if not self.lock_icon then
			self.lock_icon = createSprite(PathTool.getResFrame("common","common_lock"), self.size.width-5, self.size.height-5, self.main_container, cc.p(1, 1), LOADTEXT_TYPE_PLIST)
		end
		if self.lock_icon then
			self.lock_icon:setVisible(true)
		end
	elseif self.lock_icon then
		self.lock_icon:setVisible(false)
	end
end

function RollerItem:hideExtralInfo()
	self.txt_bg:setVisible(false)
	self.label:setVisible(false)
	self.power_label:setVisible(false)
	-- self.power_icon:setVisible(false)
	self.only_panel:setVisible(false)
end

function RollerItem:setStarCount(status, count)
	if self.equip_star_list then
		for i,v in ipairs(self.equip_star_list) do
			setChildUnEnabled(true, v)
		end
	end

	if status then
		if self.equip_star_list == nil then
			self.equip_star_list = {}
		end

		local width = 12
		if not self.size then
			self.size = self.root_wnd:getContentSize()
		end
		local roller_id
		if self.data then
			roller_id = self.data.id
		end
	    local max_star = RollerController:getInstance():getModel():getMaxStarById(roller_id or self.roller_id)
	    local x = self.size.width * 0.5 - max_star * width * 0.5 + width * 0.5
	    for i=1,max_star do
	        if not self.equip_star_list[i] then 
	        	local res = PathTool.getResFrame("common","common_90074")
	            local star = createImage(self.main_container,res,0,0,cc.p(0.5,0.5),true,1,false)
	            star:setScale(1)
	            self.equip_star_list[i] = star
	        end
			setChildUnEnabled(true, self.equip_star_list[i])
	        self.equip_star_list[i]:setPosition(x + (i-1) * width, 15)
	    end
		for i=1,count do
			setChildUnEnabled(false, self.equip_star_list[i])
		end
	end
end
function RollerItem:hideStar()
	if self.equip_star_list then
		for i,v in ipairs(self.equip_star_list) do
			v:setVisible(false)
		end
	end
end
function RollerItem:hideBackGround()
	if self.background then
		self.background:setVisible(false)
	end
	if self.item_icon then
		loadSpriteTexture(self.item_icon, PathTool.getResFrame("common_1","common_1_510",false,"common_1"), LOADTEXT_TYPE_PLIST)
	end
end

function RollerItem:addBtnCallBack(call_fun)
	self.btn_call_fun = call_fun
end

function RollerItem:clearInfo()
	self:suspendAllActions()
	self:removeFromParent()
end

function RollerItem:suspendAllActions()
	if self.data then
		if self.item_update_event ~= nil then
			self.data:UnBind(self.item_update_event)
			self.item_update_event = nil
		end
	end
	if self.use_ponit and not tolua.isnull(self.use_ponit) then
		self.use_ponit:removeAllChildren()
		self.use_ponit:removeFromParent()
		self.use_ponit = nil
	end

	self:showRedPoint(false)
	self:showAddIcon(false)
	self:setEnchantLev(0)
	self:setEquipJie(false)
	self:setElfinStep(false)
	self:showUseTag(false)
	self:showWeekCardTag(false)
	self:setSelfBackground(0)
	self:setMagicIcon(false)
	self:showItemQualityName(false)
	-- self.chips_icon:setVisible(false)
	self.num_label:setVisible(false)
	self.num_bg:setVisible(false)
	self.item_icon:setVisible(false)
	-- if self.artifact_container then
	-- 	self.artifact_container:setVisible(false)
	-- end
	if self.chipSprite then
		self.chipSprite:setVisible(false)
	end
	if self.camp_icom then
		self.camp_icom:setVisible(false)
	end
	if self.compLayer then
		self.compLayer:setVisible(false)
	end
	if self.gold_equip_mark then
		self.gold_equip_mark:setVisible(false)
	end
	self:setGodHolyEquipmentUI(false)
	self:setSuitShopStar(false)

	self:clearPlayEffect()
	self:setCheckBoxStatus(false, false)
	self.data = nil
end

function RollerItem:DeleteMe()
	if self.data then
		if self.item_update_event ~= nil then
			self.data:UnBind(self.item_update_event)
			self.item_update_event = nil
		end
		self.data = nil
	end
	
	if self.honor_spine then
		self.honor_spine:clearTracks()
		self.honor_spine:removeFromParent()
		self.honor_spine = nil
	end
	if self.common_1_load then
        self.common_1_load:DeleteMe()
		self.common_1_load = nil
    end
	self:removeAllChildren()
    self:removeFromParent()
end
