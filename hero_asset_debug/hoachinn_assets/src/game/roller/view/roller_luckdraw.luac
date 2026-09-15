--**************************
--抽奖
--**************************
RollerLuckdraw = class("RollerLuckdraw", function()
    return ccui.Widget:create()
end)

local controller = RollerController:getInstance()
local string_format = string.format

function RollerLuckdraw:ctor()  
    self._summon_type_1 = 1 	  -- 单抽的抽取类型(1免费 3钻石 4道具)
	self._summon_type_10 = 3 	  -- 十连抽抽取类型(3钻石 4道具)
	self._summon_type = 1		  -- 抽取类型(1单抽 2十连抽)
	self._init_flag = false
	self._init_status = false -- 是否已初始化（up三个道具显示）
	self.award_item_list = {}  -- 奖励item列表
	self.arriveLuckly_label = {}
	self.win_item_list = {}  -- 中奖item列表
	self.show_icon = {}
	self.rewards_info = nil -- 抽奖结果数据
	self.cur_ani_time = 0 -- 当前数字动画滚动了多少秒

	local item_bid_cfg = Config.HolidayProhibitedScrollData.data_const["common_s"]
	if item_bid_cfg then
		self.summon_item_bid = item_bid_cfg.val -- 召唤道具bid
	end

	local limit_cfg = Config.HolidayProhibitedScrollData.data_const["prohibitor_lottery_daily_limit"]
	if limit_cfg then
		self.sprite_lottery_daily_limit = limit_cfg.val -- 单日抽奖次数上限
	end

	self.res_list = {
		{ path = PathTool.getPlistImgForDownLoad("timesummon","timesummon"), type = ResourcesType.plist },
		{ path = PathTool.getPlistImgForDownLoad("elfin","elfin"), type = ResourcesType.plist },
    } 
    self.resources_load = ResourcesLoad.New() 
    self.resources_load:addAllList(self.res_list, function (  )
		if self.loadResListCompleted then
			self:loadResListCompleted()
		end
    end)
end
-- 资源加载完成
function RollerLuckdraw:loadResListCompleted(  )
	self:configUI()
	self:register_event()
	
	self._init_flag = true
	self:setData()
end

function RollerLuckdraw:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("roller/roller_luckdraw"))
	self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
	
	self.effect_panel = main_container:getChildByName("effect_panel")
	self.eff_node = self.effect_panel:getChildByName("eff_node")
	-- for i=1,4 do
	-- 	local icon = self.effect_panel:getChildByName("eff_img_"..i)
	-- 	self.show_icon[i] = icon
	-- end
	self:doShowIconAction()

	self.win_award_panel = main_container:getChildByName("win_award_panel")
	self.image_bg = main_container:getChildByName("image_bg")
	self.image_bg:setScale(display.getMaxScale())
	-- self.image_bg:loadTexture(PathTool.getResFrame('elfin', "elfin_1005",false),LOADTEXT_TYPE_PLIST)

    self.item_num_txt = main_container:getChildByName("item_num_txt")
    self.item_num_txt:setTextColor(Config.ColorData.data_color4[1])
	self.item_num_txt:enableOutline(Config.ColorData.data_color4[2],2)
	self.item_icon = main_container:getChildByName("item_icon")
	loadSpriteTexture(self.item_icon, PathTool.getItemRes(Config.HolidayProhibitedScrollData.data_const.common_s.val), LOADTEXT_TYPE)
	
	local top_y = display.getTop(main_container)
    local bottom_y = display.getBottom(main_container)
	local add_height = top_y - bottom_y - SCREEN_HEIGHT

	self.sprite1 = main_container:getChildByName("sprite1")
	self.sprite1:setPositionY(self.sprite1:getPositionY()+add_height/2)

	self.wish_bg = main_container:getChildByName("wish_bg")
	self.wish_btn = main_container:getChildByName("wish_btn")
	self.wish_btn1 = main_container:getChildByName("wish_btn1")
	self.wish_tips = main_container:getChildByName("wish_tips")
	self.wish_tips:setString(TI18N("语言_c_7370"))
	self.icon_1 = self.wish_btn:getChildByName("icon_1")
	self.Image_3 = self.wish_btn:getChildByName("Image_3")
	self.Image_3:setZOrder(98)
	-- self.wish_btn:setPositionY(self.wish_btn:getPositionY()+add_height/2)
	-- self.wish_btn_lab = self.wish_btn:getChildByName("lab")
	-- setTextMaxWidth(self.wish_btn_lab,108,-4)
	-- self.wish_btn_lab:setString(TI18N("语言_c_7370"))
	-- self.wish_btn_lab:setScale(1)
	-- self.wish_btn_lab:setZOrder(99)
	
	self.vip_btn = main_container:getChildByName("vip_btn")
	self.vip_btn:setPositionY(self.vip_btn:getPositionY()+add_height/2)
	setTextMaxWidth(self.vip_btn:getChildByName("lab"),108,-4)
	self.vip_btn:getChildByName("lab"):setString(TI18N("语言_c_7368"))

	self.gift_btn = main_container:getChildByName("gift_btn")
	self.gift_btn:setPositionY(self.gift_btn:getPositionY()+add_height/2)
	setTextMaxWidth(self.gift_btn:getChildByName("lab"),108,-4)
	self.gift_btn:getChildByName("lab"):setString(TI18N("语言_c_3435"))

	self.btn_rule = main_container:getChildByName("btn_rule")
	self.btn_rule:setPositionY(self.btn_rule:getPositionY()+add_height/2)
	self.add_btn = main_container:getChildByName("add_btn")
    self.summon_btn_1 = main_container:getChildByName("summon_btn_1")
    self.summon_btn_1:getChildByName("label"):setString(string_format(TI18N("语言_c_6908"),1))

    self.summon_btn_10 = main_container:getChildByName("summon_btn_10")
    self.btn_label_10 = self.summon_btn_10:getChildByName("label")
	self.btn_label_10:setString(string_format(TI18N("语言_c_6908"),10))
	
	self.summon_tips = createRichLabel(20, nil, cc.p(0.5, 0.5), cc.p(132, 103),-6,nil,380)
	self.summon_tips:setHorizontalLayoutType(2)
	self.summon_btn_10:addChild(self.summon_tips)
	self.summon_tips:setString(TI18N("语言_c_7369"))

	self.cur_num_lab = main_container:getChildByName("cur_num_lab")
	self.cur_num_lab:setString("")
	setTextMaxWidth(self.cur_num_lab,380)
	self._tips = createRichLabel(22, nil, cc.p(0.5, 1), cc.p(360, 210),-4,nil,700)
	self._tips:setHorizontalLayoutType(2)
	main_container:addChild(self._tips)
	self._tips:setString(TI18N("语言_c_7376"))
	self._tips:setVisible(false)

	self.progress_panel = main_container:getChildByName("progress_panel")
	self.progress = self.progress_panel:getChildByName("progress")
	self.progress:setScale9Enabled(true)
	self.num_label = self.progress_panel:getChildByName("num_label")
	self.num_label:setString("")

	-- self.mask_bg = createSprite(PathTool.getResFrame("elfin", "elfin_1058"), 35.5, 35.5, nil, cc.p(0.5, 0.5))
	-- self.clipNode = cc.ClippingNode:create(self.mask_bg)
	-- self.clipNode:setAnchorPoint(cc.p(0.5,0.5))
	-- self.clipNode:setContentSize(cc.size(100, 100))
	-- self.clipNode:setCascadeOpacityEnabled(true)
	-- self.clipNode:setPosition(50, 50)
	-- self.clipNode:setAlphaThreshold(0)
	-- self.wish_btn:addChild(self.clipNode, 1)
	
	self.elfin_icon = createImage(self.wish_btn, nil, 50, 50, cc.p(0.5, 0.5), false)
	self.elfin_icon:setScale(0.75)
	self.elfin_icon:setVisible(false)

	self.tips_bg = main_container:getChildByName("tips_bg")
	-- self.tips = createRichLabel(28, cc.c4b(0xfe, 0xfe, 0xfe, 0xff), cc.p(0.5, 0.5), cc.p(200, 31), nil, nil, 500)
	-- self.tips_bg:addChild(self.tips)
	-- self.tips:setString(TI18N("语言_c_6910"))
	-- local _width = self.tips:getContentSize().width
	-- self.tips_bg:setContentSize(cc.size(math.max(455,_width),60))
	-- self.tips:setPositionX(math.max(455,_width)/2)
end

-- 刷新按钮显示状态
function RollerLuckdraw:updateSummonBtnStatus(  )
	if self.data and self.config and self.summon_item_bid then
		local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid)
		-- 单抽
		if not self.summon_txt_1 then
			self.summon_txt_1 = createRichLabel(24, nil, cc.p(0.5, 0.5), cc.p(132.5, 28),-4)
			self.summon_btn_1:addChild(self.summon_txt_1)
		end
		local cur_time = GameNet:getInstance():getTime()
		local txt_str_1 = ""
		local status = false
		if self.data.free_time and self.data.free_time <= cur_time then
			txt_str_1 = TI18N("语言_c_6912")
			self:openSummonFreeTimer(false)
			self._summon_type_1 = 1
			status = true
		elseif summon_have_num >= 1 then
			local item_config = Config.ItemData.data_get_data(self.summon_item_bid)
			if item_config then
				local res = PathTool.getItemRes(item_config.icon)
				txt_str_1 = string.format(TI18N("<img src='%s' scale=0.4 /><div fontcolor=#fff3e1>%d</div>"), res, summon_have_num)
			end
			self:openSummonFreeTimer(false)
			self._summon_type_1 = 4
		elseif self.data.free_time then
			self.left_time = self.data.free_time - cur_time
			txt_str_1 = string.format(TI18N("语言_c_4899"), TimeTool.GetTimeFormat(self.left_time))
			self:openSummonFreeTimer(true)
			self._summon_type_1 = 3
		end
		addRedPointToNodeByStatus(self.summon_btn_1, status, 5, 15)
		self.summon_txt_1:setString(txt_str_1)
		local _width = self.summon_txt_1:getContentSize().width
		if _width > 181 then
			self.summon_txt_1:setScale(181/_width)
		end

		-- 十连抽
		if not self.summon_txt_10 then
			self.summon_txt_10 = createRichLabel(24, nil, cc.p(0.5, 0.5), cc.p(120.5, 28),-4)
			self.summon_btn_10:addChild(self.summon_txt_10)
		end
		local txt_str_10 = ""
		if summon_have_num >= 10 then
			local item_config = Config.ItemData.data_get_data(self.summon_item_bid)
			if item_config then
				local res = PathTool.getItemRes(item_config.icon)
				txt_str_10 = string.format(TI18N("<img src='%s' scale=0.4 /><div fontcolor=#fff3e1>%d</div>"), res, summon_have_num)
			end
			self._summon_type_10 = 4
		else
			local bid = self.config.loss_gold_ten[1][1]
			local num = self.config.loss_gold_ten[1][2]
			local vip_status = controller:getModel():getRollerPrivilegeStatus()
			if vip_status then --开启特权之后有折扣
				local discount = Config.ProhibitedScrollData.data_get_constant.privilege_reduce_reduce.val
				num = math.ceil(num*discount/100)
			end
			txt_str_10 = string.format(TI18N("<img src='%s' scale=0.3 /><div fontcolor=#fff3e1>%d</div>"), PathTool.getItemRes(bid), num)
			self._summon_type_10 = 3
		end
		self.summon_txt_10:setString(txt_str_10)
	end
end

-- 开启免费倒计时
function RollerLuckdraw:openSummonFreeTimer( status )
	if status == true then
		if self.left_time > 0 and self.summon_txt_1 then
			if not self.summon_timer then
                self.summon_timer = GlobalTimeTicket:getInstance():add(function()
					if not self.summon_txt_1 then return end
                    if self.data and (self.data.free_time - GameNet:getInstance():getTime()) > 0 then
                        self.left_time = self.data.free_time - GameNet:getInstance():getTime()
                        self.summon_txt_1:setString(string.format(TI18N("语言_c_4899"), TimeTool.GetTimeFormat(self.left_time)))
                    	self._summon_type_1 = 3
                    else
                        self.summon_txt_1:setString(TI18N("语言_c_6911"))
                        self._summon_type_1 = 1
                        GlobalTimeTicket:getInstance():remove(self.summon_timer)
                        self.summon_timer = nil
                    end
                end, 1)
            end
		else
			if self.summon_timer ~= nil then
	            GlobalTimeTicket:getInstance():remove(self.summon_timer)
	            self.summon_timer = nil
	        end
		end
	else
		if self.summon_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.summon_timer)
            self.summon_timer = nil
        end
	end
end

-- 刷新进度条显示
function RollerLuckdraw:updateProgress(  )
	local award_config = Config.HolidayProhibitedScrollData.data_award[self.data.camp_id]
	local start_y = 105
	local distance_y = 470
	if award_config then
		local offset_y = (distance_y - start_y + 0)/(#award_config-1)
		for i,v in ipairs(award_config) do
			local item = self.award_item_list[i]
			local pos_y = start_y + (i-1)*offset_y
			if item == nil then
				item = RoundItem1.new(true,0.55,0.6)
				self.progress_panel:addChild(item)
				self.award_item_list[i] = item
				if i ~= 1 and i ~= #award_config then
					item:setBaseData(v.reward[1][1], v.reward[1][2],false, 1)
				else
					item:setBaseData(v.reward[1][1], v.reward[1][2],false, i-1)
				end
				item:setPosition(cc.p(pos_y, 16.5))
				item:setVisibleRedPoint(false)
				item:setVisibleRoundBG(false)
				local function func()
					controller:sender20833(v.id)
				end
				item:addCallBack(func)
			end

			if not self.arriveLuckly_label[i] and self.award_item_list[i] then
				self.arriveLuckly_label[i] = createLabel(22,cc.c3b(0xf4,0xee,0xd3),cc.c3b(0x00,0x00,0x00),pos_y,-10,"",self.progress_panel,2, cc.p(0.5,1))
			end
			if self.arriveLuckly_label[i] then
				self.arriveLuckly_label[i]:setString(v.times)
			end
		end

		-- 计算进度条
		local last_times = 0
		local progress_width = 470
		local first_off = start_y-0 -- 0到第一个的距离
		local distance = 0
		for i,v in ipairs(award_config) do
			if i == 1 then
				if self.data.times <= v.times then
					distance = (self.data.times/v.times)*first_off
					break
				else
					distance = first_off
				end
			else
				if self.data.times <= v.times then
					distance = distance + ((self.data.times-last_times)/(v.times-last_times))*offset_y
					break
				else
					distance = distance + offset_y
				end
			end
			last_times = v.times
		end
		self.progress:setPercent(distance/progress_width*100)

		self.num_label:setString(string_format(TI18N("语言_c_1941"),self.data.times))
	end

	self:updateAwardStatus()
end

function RollerLuckdraw:updateAwardStatus()
	local award_config = Config.HolidayProhibitedScrollData.data_award[self.data.camp_id]
	if award_config then
		for i,v in pairs(award_config) do
			local _bool = false
			local _un_enabled = false
			for k,m in pairs(self.data.do_awards) do
				if v.id == m.award_id then
					_un_enabled = true
					break
				end
			end

			if _un_enabled == false and v.times <= self.data.times then
				_bool = true
			end
			
			setChildUnEnabled(false, self.award_item_list[i])
			if self.award_item_list[i] then
				self.award_item_list[i]:setDefaultTip(not _bool)
				self.award_item_list[i]:setVisibleRedPoint(_bool)
				if _bool then
					if not self.award_item_list[i].eff then
						self.award_item_list[i].eff = createEffectSpine("E50104", cc.p(29, 29), cc.p(0.5, 0.5), true, "action1")
						self.award_item_list[i].eff:setScale(0.6)
						self.award_item_list[i]:addChild(self.award_item_list[i].eff)
					end
					self.award_item_list[i].eff:setVisible(true)
				else
					if self.award_item_list[i].eff then
						self.award_item_list[i].eff:setVisible(false)
					end
				end
				if _un_enabled == true then
					setChildUnEnabled(true, self.award_item_list[i])
				end
			end
		end
	end
end

-- 刷新道具数量
function RollerLuckdraw:updateItemNum( bag_code, data_list )
	if self.summon_item_bid then
		if bag_code and data_list then
			if bag_code == BackPackConst.Bag_Code.BACKPACK then
				for i,v in pairs(data_list) do
					if v and v.base_id and self.summon_item_bid == v.base_id then
						local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid)
						self.item_num_txt:setString(summon_have_num)
						-- self.btn_label_10:setString(summon_have_num.."/10")
						self:updateSummonBtnStatus()
						break
					end
				end
			end
		else
			local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid)
			self.item_num_txt:setString(summon_have_num)
		end
	end
end

function RollerLuckdraw:register_event(  )
	if self.btn_rule then
        self.btn_rule:addTouchEventListener(function( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				local action_cfg = Config.HolidayProhibitedScrollData.data_action[self.data.camp_id]
				if action_cfg and action_cfg.group_id then
					TimesummonController:getInstance():openTimeSummonAwardView(true, action_cfg.group_id, self.data,TimesummonConst.ActonInfoType.Roller_1)
				end
            end
        end)
    end

	registerButtonEventListener(self.add_btn, function (  )
		if self.summon_item_bid then
			BackpackController:getInstance():openTipsSource(true, self.summon_item_bid)
		end
	end, true)

	registerButtonEventListener(self.wish_btn, function (  )
		local vip_status = controller:getModel():getRollerPrivilegeStatus()
		if vip_status then
			controller:openRollerWishWindow(true)
		else
			controller:openRollerPrivilegeWindow(true)
			message(TI18N("语言_c_6913"))
		end
	end, true,1,nil,1.2)
	registerButtonEventListener(self.wish_btn1, function (  )
		local vip_status = controller:getModel():getRollerPrivilegeStatus()
		if vip_status then
			controller:openRollerWishWindow(true)
		else
			controller:openRollerPrivilegeWindow(true)
			message(TI18N("语言_c_6913"))
		end
	end, true,1)--,nil,1.5)
	registerButtonEventListener(self.vip_btn, function (  )
		controller:openRollerPrivilegeWindow(true)
	end, true)
	registerButtonEventListener(self.gift_btn, function (  )
		JumpController:getInstance():jumpViewByEvtData({114,10})
	end, true)
	-- 召唤1次
	registerButtonEventListener(self.summon_btn_1, function (  )
		if self._summon_type_1 == 3 and self.config then
			local vip_status = controller:getModel():getRollerPrivilegeStatus()
			local add_num = 0 
			if vip_status then
				add_num = Config.ProhibitedScrollData.data_get_constant.privilege_call_num.val
			end
			if self.data and self.data.day_count >= (self.sprite_lottery_daily_limit+add_num) then
				message(TI18N("语言_c_6914"))
				local item_config = Config.ItemData.data_get_data(self.summon_item_bid)
				BackpackController:getInstance():openTipsSource(true, item_config)
				return
			end
			local num = self.config.loss_gold_once[1][2]
			local call_back = function ()
				self._summon_type = 1
                controller:sender20832( 1, self._summon_type_1 ,false)
            end
            local item_icon_2 = Config.ItemData.data_get_data(self.config.loss_gold_once[1][1]).icon
            local val_str = Config.ItemData.data_get_data(self.config.gain_once[1][1]).name or ""
            local val_num = self.config.gain_once[1][2]
            local call_num = 1
            self:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
		else
			self._summon_type = 1
			controller:sender20832( 1, self._summon_type_1 ,false)
		end
	end, true)
	-- 召唤10次
	registerButtonEventListener(self.summon_btn_10, function (  )
		if self._summon_type_10 == 3 and self.config then
			local vip_status = controller:getModel():getRollerPrivilegeStatus()
			local add_num = 0 
			if vip_status then
				add_num = Config.ProhibitedScrollData.data_get_constant.privilege_call_num.val
			end
			if self.data and self.data.day_count >= (self.sprite_lottery_daily_limit+add_num) then
				message(TI18N("语言_c_6914"))
				local item_config = Config.ItemData.data_get_data(self.summon_item_bid)
				BackpackController:getInstance():openTipsSource(true, item_config)
				return
			end
			local num = self.config.loss_gold_ten[1][2]
			local call_back = function ()
				self._summon_type = 2
                controller:sender20832( 10, self._summon_type_10 ,false)
            end
            local item_icon_2 = Config.ItemData.data_get_data(self.config.loss_gold_ten[1][1]).icon
            local val_str = Config.ItemData.data_get_data(self.config.gain_ten[1][1]).name or ""
            local val_num = self.config.gain_ten[1][2]
            local call_num = 10
            self:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
		else
			self._summon_type = 2
			controller:sender20832( 10, self._summon_type_10 ,false)
		end
	end, true)

	-- 召唤数据更新
	if not self.update_summon_data_event then
        self.update_summon_data_event = GlobalEvent:getInstance():Bind(RollerEvent.UpdateSummonData,function (data)
			if self.setData then
				self:setData()
			end
        end)
	end

	-- -- 抽奖结果更新
	-- if not self.update_summon_rewards_data_event then
	-- 	self.update_summon_rewards_data_event = GlobalEvent:getInstance():Bind(ElfinEvent.Update_Elfin_Summon_Rewards_Data_Event,function (data)
	-- 		self.rewards_info = data
    --         -- self:startEffectAwardShow()
    --     end)
	-- end
	-- -- 抽奖结果item更新
	-- if not self.update_elfin_item_event then
	-- 	self.update_elfin_item_event = GlobalEvent:getInstance():Bind(ElfinEvent.Update_Elfin_Item_Event,function (data)
	-- 		self.rewards_info = data
    --         -- self:updateAwardItmes(false)
    --     end)
	-- end
	
    -- 数量更新
    if not self.update_add_good_event then
        self.update_add_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function(bag_code, data_list)
			if self.updateItemNum then
				self:updateItemNum(bag_code,data_list)
			end
        end)
    end
    if not self.update_delete_good_event then
        self.update_delete_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function(bag_code, data_list)
			if self.updateItemNum then
				self:updateItemNum(bag_code,data_list)
			end
        end)
    end
    if not self.update_modify_good_event then
        self.update_modify_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, data_list)
			if self.updateItemNum then
				self:updateItemNum(bag_code,data_list)
			end
        end)
    end
	--特权更新
	if not self.update_vip_event then
		self.update_vip_event = GlobalEvent:getInstance():Bind(RollerEvent.UpdatePrivilegeVipData,function (data)
			self:setData()
        end)
	end
	
end

-- 钻石召唤时的提示
function RollerLuckdraw:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
    if self.alert then
        self.alert:close()
        self.alert = nil
    end

    local cancle_callback = function ()
        if self.alert then
            self.alert:close()
            self.alert = nil
        end
    end
	local vip_status = controller:getModel():getRollerPrivilegeStatus()
	if vip_status then --开启特权之后有折扣
		local discount = Config.ProhibitedScrollData.data_get_constant.privilege_reduce_reduce.val
		num = math.ceil(num*discount/100)
	end
    local have_sum = RoleController:getInstance():getRoleVo().gold + RoleController:getInstance():getRoleVo().red_gold
    local str = string.format(TI18N("语言_c_1906"),PathTool.getItemRes(item_icon_2),num,have_sum)
	
	local sss = TI18N("语言_c_6915")
    local str_ = str..string.format(sss,val_num,val_str,call_num)
    if not self.alert then
        self.alert = CommonAlert.show(str_, TI18N("语言_c_63"), call_back, TI18N("语言_c_62"), nil, CommonAlert.type.rich)
    end
end

function RollerLuckdraw:setData()
	self.data = controller:getModel():getRollerSummonData()
	if not self.data then controller:sender20831() return end
	local action_cfg = Config.HolidayProhibitorData.data_action[self.data.camp_id]
	if action_cfg and action_cfg.group_id then
		self.config = Config.HolidayProhibitorData.data_summon[action_cfg.group_id]
	end

	if self._init_status == false then
		self._init_status = true
	end
	local vip_status = controller:getModel():getRollerPrivilegeStatus()
	local add_num = 0 
	if vip_status then
		add_num = Config.ProhibitedScrollData.data_get_constant.privilege_call_num.val
		-- setChildUnEnabled(false, self.Image_3)
		self._tips:setVisible(false)
	else
		-- setChildUnEnabled(true, self.Image_3)
		self._tips:setVisible(true)
	end

	self.cur_num_lab:setString(string.format(TI18N("语言_c_6916"),self.data.day_count,self.sprite_lottery_daily_limit+add_num))

	self:updateSummonBtnStatus()
	self:updateProgress()
	if self.updateItemNum then
		self:updateItemNum()
	end

	local item_id = nil
	if self.data.lucky_ids ~= nil and next(self.data.lucky_ids) ~= nil then
		for k,v in pairs(self.data.lucky_ids) do
			item_id = v.lucky_prohs_bid
			break
		end
	end

	if item_id then
		local config = Config.ItemData.data_get_data(item_id)
		if config then
			self.elfin_icon_load = loadImageTextureFromCDN(self.elfin_icon, PathTool.getItemRes(config.icon), ResourcesType.single, self.elfin_icon_load)
		end
		-- self.icon_1:setVisible(false)
		self.Image_3:setVisible(false)
		self.elfin_icon:setVisible(true)
		addRedPointToNodeByStatus(self.wish_btn, false, 0, 0)
	else
		self.Image_3:setVisible(true)
		self.elfin_icon:setVisible(false)
		local vip_status = controller:getModel():getRollerPrivilegeStatus()
		if vip_status then
			addRedPointToNodeByStatus(self.wish_btn, true, 0, 0)
		end
	end
end

function RollerLuckdraw:doShowIconAction()
	if not self.roller_eff then
		self.roller_eff = createEffectSpine("E70201", cc.p(23, 23), cc.p(0.5,0.5), true, "action3")
		-- self.roller_eff:setScale(0.45, 0.45)
		self.eff_node:addChild(self.roller_eff)
	end
	-- for i, v in ipairs(self.show_icon) do
	-- 	local icon = v
	-- 	local pos_y = icon:getPositionY()
	-- 	local pos_x = icon:getPositionX()
	-- 	local dir = math.random(-1,1)
	-- 	if dir < 0 then
	-- 		dir = -1
	-- 	else
	-- 		dir = 1
	-- 	end
	-- 	local move_y = math.random(15,20)
	-- 	delayRun(icon, 5*i / display.DEFAULT_FPS, function ()
	-- 		local move_to = cc.MoveTo:create(2, cc.p(pos_x, pos_y+(20*dir)))
	-- 		local move_back = cc.MoveTo:create(2, cc.p(pos_x, pos_y))
	-- 		icon:runAction(cc.RepeatForever:create(cc.Sequence:create(move_to,move_back)))
    --     end)
	-- end
end

function RollerLuckdraw:setVisibleStatus(bool)
    self:setVisible(bool)
	if bool == true and self._init_flag == true then
    	controller:sender20831()
	end
end

function RollerLuckdraw:DeleteMe()
	if self.update_summon_data_event then
		GlobalEvent:getInstance():UnBind(self.update_summon_data_event)
		self.update_summon_data_event = nil
	end
	if self.update_vip_event then
		GlobalEvent:getInstance():UnBind(self.update_vip_event)
		self.update_vip_event = nil
	end
	if self.update_summon_rewards_data_event then
		GlobalEvent:getInstance():UnBind(self.update_summon_rewards_data_event)
		self.update_summon_rewards_data_event = nil
	end
	if self.update_elfin_item_event then
		GlobalEvent:getInstance():UnBind(self.update_elfin_item_event)
		self.update_elfin_item_event = nil
	end
	if self.update_add_good_event then
        GlobalEvent:getInstance():UnBind(self.update_add_good_event)
		self.update_add_good_event = nil
    end
    if self.update_delete_good_event then
        GlobalEvent:getInstance():UnBind(self.update_delete_good_event)
		self.update_delete_good_event = nil
    end
    if self.update_modify_good_event then
        GlobalEvent:getInstance():UnBind(self.update_modify_good_event)
		self.update_modify_good_event = nil
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
    end
    if self.bind_updata_event then
        GlobalEvent:getInstance():UnBind(self.bind_updata_event)
        self.bind_updata_event = nil
    end
end