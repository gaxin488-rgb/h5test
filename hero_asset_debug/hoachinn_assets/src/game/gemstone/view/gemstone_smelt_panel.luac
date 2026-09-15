----------------------------
-- @Description:宝石羁绊熔炼主界面
----------------------------
GemstoneSmeltPanel = class( "GemstoneSmeltPanel",
    function()
        return ccui.Widget:create()
    end
)

local controller = GemstoneController:getInstance()
local model = controller:getModel()
local back_controller = BackpackController:getInstance()
local back_model = back_controller:getModel()
local hero_controller = HeroController:getInstance()
local hero_model = hero_controller:getModel()
local role_vo = RoleController:getInstance():getRoleVo()

function GemstoneSmeltPanel:addToParent( status )
	status = status or false
    self:setVisible(status)
end
function GemstoneSmeltPanel:ctor(hero_vo)
    self.hero_vo = hero_vo
    self.artifact_items = {}
	self.artifact_type = 0
    self.cur_auto_num = SysEnv:getInstance():getNum(SysEnv.keys.gem_artifact_num, 5)  -- 一键合成时添加的符文数量
	self.auto_add_num = 0 --批量合成选择数量
	self.max_auto_add_num = 0 --批量合成最大选择数量
    self:loadResources()
end
function GemstoneSmeltPanel:loadResources()
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("engraved", "engraved"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("artifact", "artifact"), type = ResourcesType.plist},
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

function GemstoneSmeltPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("gemstone/gemstone_smelt_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.preview_btn = self.main_container:getChildByName("preview_btn")
    self.preview_txt = self.preview_btn:getChildByName("preview_txt")
    setTextMaxWidth(self.preview_txt,100,-8)
    self.preview_txt:setString(TI18N("语言_c_7137"))
    self.bag_btn = self.main_container:getChildByName("bag_btn")
    self.bag_txt = self.bag_btn:getChildByName("bag_txt")
    setTextMaxWidth(self.bag_txt,100,-8)
    self.bag_txt:setString(TI18N("语言_c_7116"))
    self.zhufu_icon = self.main_container:getChildByName("zhufu_icon")
    local gift_cfg = Config.PartnerGemData.data_constant["change_gift"]
	if gift_cfg then
		local bid = gift_cfg.val[1][1]
		if bid then
			loadSpriteTexture(self.zhufu_icon, PathTool.getItemRes(bid), LOADTEXT_TYPE)
		end
	end
    self.get_zhufu = self.main_container:getChildByName("get_zhufu")
    self.explain_btn = self.main_container:getChildByName("explain_btn")
    self.quick_add_btn = self.main_container:getChildByName("quick_add_btn")
    self.quick_add_txt = self.quick_add_btn:getChildByName("label")
    self.quick_add_txt:setString(TI18N("语言_c_2305"))
	self.checkBox = self.main_container:getChildByName("checkbox")
	local name = self.checkBox:getChildByName("name")
    name:setString(TI18N("语言_c_7166"))
	setTextMaxWidth(name,200)
	self:setAutoSacrificeStatus()
    self.compound_btn = self.main_container:getChildByName("compound_btn")
    self.compound_txt = self.compound_btn:getChildByName("label")
    self.compound_txt:setString(TI18N("语言_c_973"))
    self.btn_redu = self.main_container:getChildByName("btn_redu")
    self.btn_add = self.main_container:getChildByName("btn_add")
    self.progress_panel = self.main_container:getChildByName("progress_panel")
    self.progress_bar = cc.ProgressTimer:create(createSprite(PathTool.getResFrame("artifact","artifact_1002"), 0, 0, nil, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST))
    self.progress_bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.progress_bar:setMidpoint(cc.p(0.5, 0))
    self.progress_bar:setBarChangeRate(cc.p(0, 1))
    self.progress_bar:setAnchorPoint(cc.p(0, 0))
    self.progress_bar:setPosition(cc.p(0, 0))
    self.progress_bar:setPercentage(0)
    self.progress_panel:addChild(self.progress_bar)
    self:handleProgressEffect(true)
    self.num_bg = self.main_container:getChildByName("num_bg")
    self.rate_txt = self.main_container:getChildByName("rate_txt")
    self.level_txt = self.main_container:getChildByName("level_txt")
    self.zhufu_title = self.main_container:getChildByName("zhufu_title")
	setTextSpacing(self.zhufu_title,-10)
	self.zhufu_title:setString(TI18N("语言_c_2307"))
    self.zhufu_txt = self.main_container:getChildByName("zhufu_txt")
    self.zhufu_tips = self.main_container:getChildByName("zhufu_tips")
    self.tips_txt = self.main_container:getChildByName("tips_txt")
    self.tips_txt:setString(TI18N("语言_c_7138"))
    self.num_txt = self.main_container:getChildByName("num_txt")
	self.num_txt:setString(self.cur_auto_num)
    if self.cur_auto_num <= 2 then
		self.btn_redu:setTouchEnabled(false)
		setChildUnEnabled(true, self.btn_redu)
	elseif self.cur_auto_num >= 5 then
		self.btn_add:setTouchEnabled(false)
		setChildUnEnabled(true, self.btn_add)
	end
    self.turntable_btn = self.main_container:getChildByName("turntable_btn")
    self.turntable_txt = self.turntable_btn:getChildByName("turntable_txt")
	setTextSpacing(self.turntable_txt,-8)
    self.turntable_txt:setString(TI18N("语言_c_7115"))
    self.pos_node = self.main_container:getChildByName("pos_node")
    doStopAllActions(self.main_container)
	for i=1,5 do
		delayRun(self.main_container, i*4/60, function ()
			local pos_node = self.main_container:getChildByName("pos_node_" .. i)
			local item = BackPackItem.new(false, true, false, nil, true, false)
			item:addCallBack(handler(self, self._onClickItemCallBack))
			item:showAddIcon(true)
			item:setIsShowBackground(false)
			pos_node:addChild(item)
			self.artifact_items[i] = item
		end)
	end
    -- 消耗材料显示
	local temp_pos_x = self.rate_txt:getPositionX()
	local temp_pos_y = self.rate_txt:getPositionY() 
	self.cost_txt = createRichLabel(20, cc.c4b(241,226,199,255), cc.p(0.5, 1), cc.p(temp_pos_x, temp_pos_y - 16))
	self.main_container:addChild(self.cost_txt) 
	self.pos_node:setVisible(false)
	self.rate_txt:setVisible(false)
	self.level_txt:setVisible(false)
	self.cost_txt:setVisible(false)
	
	self.auto_panel = self.main_container:getChildByName("auto_panel")
	self.auto_panel:setVisible(model:getAutoHide())
	self.auto_bg = self.auto_panel:getChildByName("auto_bg")
	self.auto_num_bg = self.auto_panel:getChildByName("auto_num_bg")
	self.auto_add = self.auto_panel:getChildByName("auto_add")
	self.auto_down = self.auto_panel:getChildByName("auto_down")
	self.auto_tip = self.auto_panel:getChildByName("auto_tip")
	if transformTextToShortByWidth(self.auto_tip,TI18N("语言_c_7731"),self.auto_panel:getContentSize().width) then
		addEvt2showAllTextTips(self.auto_tip,TI18N("语言_c_7731"),0)
	else
		addEvt2showAllTextTips(self.auto_tip,"",0) 
	end
	self.text_Field = self.auto_panel:getChildByName("text_Field")
	self.text_Field:setPlaceHolder(TI18N("语言_c_5890"))
    self.text_Field:setTextColor(cc.c3b(0x5c,0x27,0x05))
    self.text_Field:setPlaceHolderColor(cc.c3b(0x5c,0x27,0x05))
    self.text_Field:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.text_Field:setString(self.auto_add_num)

    self:setData()
end
--设置适配屏幕
function GemstoneSmeltPanel:adaptationScreen()
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)
    local left_x = display.getLeft(self.main_container)
    local right_x = display.getRight(self.main_container)

    local tab_y = self.explain_btn:getPositionY()
    self.explain_btn:setPositionY(top_y - (self.container_size.height - tab_y))
    local tab_y = self.preview_btn:getPositionY()
    self.preview_btn:setPositionY(top_y - (self.container_size.height - tab_y))
    local tab_y = self.bag_btn:getPositionY()
    self.bag_btn:setPositionY(top_y - (self.container_size.height - tab_y))
    local tab_y = self.turntable_btn:getPositionY()
    self.turntable_btn:setPositionY(top_y - (self.container_size.height - tab_y))
end

function GemstoneSmeltPanel:setAutoSacrificeStatus()
    local status = GemstoneController:getInstance():getModel():getSkipSmelt()
    if status ~= 0 then
        self.checkBox:setSelected(true)
    else
        self.checkBox:setSelected(false)
    end
end
-- 进度条特效
function GemstoneSmeltPanel:handleProgressEffect( status )
	if status == false then
        if self.progress_effect then
            self.progress_effect:clearTracks()
            self.progress_effect:removeFromParent()
            self.progress_effect = nil
        end
    else
        if not tolua.isnull(self.progress_panel) and self.progress_effect == nil then
            self.progress_effect = createEffectSpine(Config.EffectData.data_effect_info[660], cc.p(24.5, 0), cc.p(0, 1), true, PlayerAction.action)
            self.progress_panel:addChild(self.progress_effect)
        end
    end
end
function GemstoneSmeltPanel:updatePageData(hero_vo)
    self.hero_vo = hero_vo
    self:setData()
end

-- 祝福值刷新
function GemstoneSmeltPanel:updataZhufuInfo(  )
	local cur_lucky = model:getGemArtifactNum()
	local max_lucky = 0
	local lucky_cfg = Config.PartnerGemData.data_constant["change_condition"]
	if lucky_cfg and lucky_cfg.val then
		max_lucky = lucky_cfg.val
	end
	local percent = cur_lucky/max_lucky*100
	if self.progress_bar then
		self.progress_bar:setPercentage(percent)
	end
	self.zhufu_txt:setString(cur_lucky)

	local red_status = model:getGemArtifactRed()
	self.zhufu_tips:setVisible(red_status)

	-- 特效位置
	if self.progress_effect then
		local pos_y = percent/100*324
		if pos_y < 3 then
			pos_y = 3
		end
		self.progress_effect:setPositionY(pos_y)
	end
	local status = ActionController:getInstance():getModel():getLucklyTabRedPoint(ActionTreasureType.Gemstone)
	addRedPointToNodeByStatus(self.turntable_btn, status)
end

function GemstoneSmeltPanel:setData()
    self:updataZhufuInfo()
end

function GemstoneSmeltPanel:_onClickItemCallBack(  )
	local param = {}
	param.type = self.artifact_type
    param.max_num = 5
    param.chose_list = self.chose_item_list or {}
    controller:openGemstoneChoseWindow(true, param)
end
function GemstoneSmeltPanel:register_event()   
	self.explain_btn:addTouchEventListener(function( sender,event_type )
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            MainuiController:getInstance():openCommonExplainView(true, Config.PartnerGemData.data_explain[2])
        end
    end) 
    registerButtonEventListener(self.bag_btn, function()
        controller:openGemstoneBagWindow(true)
    end, true, 1)
    registerButtonEventListener(self.preview_btn, function()
        controller:openGemstonePreviewWindow(true)
    end, true, 1)
    registerButtonEventListener(self.turntable_btn, function()
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene)
        ActionController:getInstance():openLuckyTreasureWin(true,3)
    end, true, 1)
    registerButtonEventListener(self.btn_redu, function (  )
		self:onChangeAutoForgeNum(1)
	end, true)

	registerButtonEventListener(self.btn_add, function (  )
		self:onChangeAutoForgeNum(2)
	end, true)
	
	local function textFieldEvent(sender, eventType)
        if eventType == ccui.TextFiledEventType.attach_with_ime then
        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
        	if self.text_Field:getString() == "" then
        		message(TI18N("语言_c_4363"))
        		self.auto_add_num = 0
        		return
        	else
	        	if not tolua.isnull(self.text_Field) then
					if self.artifact_type ~= 0 then
						local num = tonumber(self.text_Field:getString())
						if num > self.max_auto_add_num then
							num = self.max_auto_add_num
						end
						local config = Config.PartnerGemData.data_comp[self.artifact_type]
						if config then
							if config[#self.chose_item_list] then
								if not self.max_auto_add_num or not num then return end
								for k, v in pairs(config[#self.chose_item_list]) do
									if role_vo.lev >= v.need and role_vo.lev <= v.need_max then
										local rate = v.pro or 0
										if rate/10 < 100 then
											num = 1
											message(TI18N("语言_c_7727"))
										else
											if num > self.max_auto_add_num then
												num = self.max_auto_add_num
											elseif num < 1 then
												num = 1
											end
										end
										self.auto_add_num = num
										self.text_Field:setString(num)
										self:updateAutoPanel()
									end
								end
							else
								message(TI18N("语言_c_7727"))
							end
						end
					end
				end
	        end
        elseif eventType == ccui.TextFiledEventType.insert_text then
        elseif eventType == ccui.TextFiledEventType.delete_backward then
        end
    end
    self.text_Field:addEventListener(textFieldEvent)
	
	registerButtonEventListener(self.auto_add, function (  )
		if self.auto_add_num + 1 <= self.max_auto_add_num then
			self.auto_add_num = self.auto_add_num + 1
			self:updateAutoPanel()
		end
	end, true)
	registerButtonEventListener(self.auto_down, function (  )
		if self.auto_add_num - 1 > 0 then
			self.auto_add_num = self.auto_add_num - 1
			self:updateAutoPanel()
		end
	end, true)
    registerButtonEventListener(self.get_zhufu, handler(self, self._onClickGetZhufu))
	registerButtonEventListener(self.quick_add_btn, handler(self, self._onClickQuickAddBtn))
	--合成
	registerButtonEventListener(self.compound_btn, function ()
		if self.is_show_effect == true then return end
		if self.artifact_type == 0 or next(self.chose_item_list) == nil then
			message(TI18N("语言_c_2311"))
		else
			local config = Config.PartnerGemData.data_comp[self.artifact_type]
			if config then
				if config[#self.chose_item_list] then
					for k, v in pairs(config[#self.chose_item_list]) do
						if role_vo.lev >= v.need and role_vo.lev <= v.need_max then
							if model:getSkipSmelt() == 1 then
								self:requestCompoundArtifact()
							else
								self:handleComEffect(true)
							end
						end
					end
				else
					local need_num = 0
					for k, v in pairs(config) do
						if need_num == 0 then
							need_num = k
						else
							need_num = math.min(need_num, k)
						end
					end
					message(string.format(TI18N("语言_c_7139"),need_num))
				end
			else
				message(TI18N("语言_c_2311"))
			end
		end
	end, true)
	self:registerCheckBoxEvent(self.checkBox)
	-- 祝福值更新
	if not self.lucky_update_evt then
        self.lucky_update_evt = GlobalEvent:getInstance():Bind(GemstoneEvent.Artifact_Lucky_Event, function( )
            self:updataZhufuInfo()
        end)
    end
    -- 选择符文返回
    if not self.chose_update_evt then
    	self.chose_update_evt = GlobalEvent:getInstance():Bind(GemstoneEvent.Artifact_Chose_Event, function (artifact_type,item_list )
    		self.chose_item_list = item_list
			self.artifact_type = artifact_type
			self:updateChoseArtifactItems()
    	end)
    end
	-- 合成操作成功
    if not self.compound_update_evt then
    	self.compound_update_evt = GlobalEvent:getInstance():Bind(GemstoneEvent.Artifact_Compound_Event, function( flag )
            self.artifact_type = 0 
			self.chose_item_list = {}
			self:updateChoseArtifactItems()
        end)
    end
end
--注册选项框事件
function GemstoneSmeltPanel:registerCheckBoxEvent(btn)
    if not btn then return end
	btn:addEventListener(function(sender,event_type)
	    if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            model:setSkipSmelt(1)
	        btn:setSelected(true)
	    elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            model:setSkipSmelt(0)
            btn:setSelected(false)
	    end
    end)
end
-- 请求合成协议(特效播放完毕)
function GemstoneSmeltPanel:requestCompoundArtifact(  )
	local cfg = Config.PartnerGemData.data_comp[self.artifact_type]
	local min_num = 0
	if cfg then
		for i,value in pairs(cfg) do
			if min_num == 0 then
				min_num = i
			else
				min_num = math.min(min_num,i)
			end
		end
	end
	local expends = {}
	for k,id in pairs(self.chose_item_list) do
		local temp = {}
		temp.item_id = id
		local back_data = back_model:getGamPackItemById(id)
		local status = true
		if back_data then
			for i,value in ipairs(back_data.extra) do
				if value and value.extra_k and value.extra_k == 1 and value.extra_v == 1 then
					status = false
					message(TI18N("语言_c_7184"))
					return
				end
			end
		end
		if status then
			table.insert(expends, temp)
		end
	end
	if tableLen(expends) < min_num then
		message(string.format(TI18N("语言_c_7139"),min_num))
		return
	end
	if self.auto_add_num > 1 then
		local cfg = Config.PartnerGemData.data_comp
		if self.artifact_type ~= 0 then
			local config = cfg[self.artifact_type]
			if config then
				if config[#self.chose_item_list] then
					self.pos_node:setVisible(true)
					for k, v in pairs(config[#self.chose_item_list]) do
						if role_vo.lev >= v.need and role_vo.lev <= v.need_max then
							local one_num = v.num
							local need_num = (self.auto_add_num - 1) * one_num
							local materials = v.costs
							for _k,_v in ipairs(materials or {}) do
								local back_list = back_model:getGemItemIdListByBid(_v)
								for key,value in ipairs(back_list or {}) do
									if need_num > 0 then
										local item_vo = back_model:getGamPackItemById(value)
										local have_num = deepCopy(item_vo.quantity)
										local choose_num = 0
										for k,id in pairs(self.chose_item_list) do
											if id == item_vo.id then
												choose_num = choose_num + 1
											end
										end
										have_num = have_num - choose_num
										for i=1,have_num do
											if need_num > 0 then
												local temp = {}
												temp.item_id = item_vo.id
												table.insert(expends, temp)
												need_num = need_num - 1
											else
												break
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if self.auto_add_num == 0 then
		self.auto_add_num = 1
	end
	controller:sender22804(self.artifact_type, expends, self.auto_add_num)
	self.is_show_effect = false
end
-- 合成成功的特效
function GemstoneSmeltPanel:handleComEffect( status )
	if status == true then
		-- AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON, "c_equipment_forging")
		self.is_show_effect = true
		if not tolua.isnull(self.pos_node) and self.com_effect == nil then
            self.com_effect = createEffectSpine(Config.EffectData.data_effect_info[661], cc.p(0, 0), cc.p(0.5, 0.5), false, PlayerAction.action, handler(self, self.requestCompoundArtifact))
            self.pos_node:addChild(self.com_effect)
        elseif self.com_effect then
        	self.com_effect:setToSetupPose()
        	self.com_effect:setAnimation(0, PlayerAction.action, false)
        end
	else
		if self.com_effect then
            self.com_effect:clearTracks()
            self.com_effect:removeFromParent()
            self.com_effect = nil
        end
	end
end
function GemstoneSmeltPanel:updateAddDownBtn()
	if self.auto_add_num >= self.max_auto_add_num then
		self.auto_add:setTouchEnabled(false)
		setChildUnEnabled(true,self.auto_add)
	else
		self.auto_add:setTouchEnabled(true)
		setChildUnEnabled(false,self.auto_add)
	end
	if self.auto_add_num <= 1 then
		self.auto_down:setTouchEnabled(false)
		setChildUnEnabled(true,self.auto_down)
	else
		self.auto_down:setTouchEnabled(true)
		setChildUnEnabled(false,self.auto_down)
	end
end
function GemstoneSmeltPanel:updateAutoPanel()
	if not model:getAutoHide() then return end
	self.text_Field:setString(self.auto_add_num)

	local cfg = Config.PartnerGemData.data_comp
	if self.artifact_type ~= 0 then
		local config = cfg[self.artifact_type]
		if config then
			if config[#self.chose_item_list] then
				for k, v in pairs(config[#self.chose_item_list]) do
					if role_vo.lev >= v.need and role_vo.lev <= v.need_max then
						-- 设置消耗
						local list = deepCopy(v.cost)
						if list and next(list) then
							for k,v in ipairs(list) do
								v[2] = v[2] * self.auto_add_num
							end
						end
						self:updateCostInfo(list)
						self:updateAddDownBtn()
						break
					end
				end
			end
		end
	end
end
function GemstoneSmeltPanel:setAutoPanel()
	if not model:getAutoHide() then return end
	local cfg = Config.PartnerGemData.data_comp
	if self.artifact_type ~= 0 then
		local config = cfg[self.artifact_type]
		if config then
			if config[#self.chose_item_list] then
				for k, v in pairs(config[#self.chose_item_list]) do
					if role_vo.lev >= v.need and role_vo.lev <= v.need_max then
						local rate = v.pro or 0
						if rate/10 == 100 then
							local materials = v.costs
							local cost_num = v.num
							local have_num = 0
							for i,bid in ipairs(materials) do
								local num = back_model:getItemNumByBid(bid,BackPackConst.Bag_Code.GEMSTONE)
								have_num = have_num + num
							end
							self.max_auto_add_num = math.min(math.floor(have_num / cost_num),Config.PartnerGemData.data_constant.batch_limit.val)
							self.auto_add_num = self.max_auto_add_num
						else
							self.auto_add_num = 1
							self.max_auto_add_num = 1
						end
					end
				end
			else
				self.auto_add_num = 0
				self.max_auto_add_num = 0
			end
		end
	end
	self.text_Field:setString(self.auto_add_num)
	self:updateAddDownBtn()
end

-- 增加/减少一键添加的数量 flag:1减少 否则增加
function GemstoneSmeltPanel:onChangeAutoForgeNum( flag )
	if flag == 1 then
		self.cur_auto_num = self.cur_auto_num - 1
		self.num_txt:setString(self.cur_auto_num)
	else
		self.cur_auto_num = self.cur_auto_num + 1
		self.num_txt:setString(self.cur_auto_num)
	end
	if self.cur_auto_num <= 2 then
		self.btn_redu:setTouchEnabled(false)
		setChildUnEnabled(true, self.btn_redu)
	elseif self.cur_auto_num >= 5 then
		self.btn_add:setTouchEnabled(false)
		setChildUnEnabled(true, self.btn_add)
	else
		self.btn_redu:setTouchEnabled(true)
		setChildUnEnabled(false, self.btn_redu)
		self.btn_add:setTouchEnabled(true)
		setChildUnEnabled(false, self.btn_add)
	end
end
-- 领取祝福奖励
function GemstoneSmeltPanel:_onClickGetZhufu(  )
	controller:openGemstoneAwardWindow(true)
end

-- 刷新选择的符文
function GemstoneSmeltPanel:updateChoseArtifactItems(  )
	self.artifact_type = 0
	local cfg = Config.PartnerGemData.data_comp
	for i,item in ipairs(self.artifact_items) do
		local id = self.chose_item_list[i]
		if id then
			local item_data = back_model:getGamPackItemById(id)
			if not item_data then
				item_data = back_model:getBackPackItemById(id)
			end
			if item_data then
				if self.artifact_type == 0 then
					if cfg then
						for key,value in pairs(cfg) do
							for _,_value in pairs(value) do
								for _,v in pairs(_value) do
									for _,_v in pairs(v.costs) do
										if item_data.config.id == _v then
											self.artifact_type = v.type
										end
									end
									break
								end
								break
							end
						end
					end
				end
				local good_vo = deepCopy(item_data)
				good_vo.quantity = 1
				item:setData(good_vo)
				if not item.chose_effect then
					item.chose_effect = createEffectSpine(Config.EffectData.data_effect_info[662], cc.p(BackPackItem.Width/2, BackPackItem.Height/2), cc.p(0.5, 0.5), true, PlayerAction.action)
					item:addChild(item.chose_effect)
				end
				item.chose_effect:setVisible(true)
				item:showAddIcon(false)
				item:setIsShowBackground(true)
				item:showGemLockStatus(false)
			else
				item:setData({})
				item:showAddIcon(true)
				item:setIsShowBackground(false)
				if item.chose_effect then
					item.chose_effect:setVisible(false)
				end
				item:showGemLockStatus(false)
			end
		else
			item:setData({})
			item:showAddIcon(true)
			item:setIsShowBackground(false)
			if item.chose_effect then
				item.chose_effect:setVisible(false)
			end
			item:showGemLockStatus(false)
		end
	end

	-- 目标符文
	if not self.target_item then
		self.target_item = BackPackItem.new(false, false, false, nil, true, false)
		-- self.target_item:addCallBack(handler(self, self._onClickTargetCallBack))
		self.target_item:setIsShowBackground(false)
		self.pos_node:addChild(self.target_item)
	end
	if self.artifact_type ~= 0 then
		local config = cfg[self.artifact_type]
		if config then
			if config[#self.chose_item_list] then
				self.pos_node:setVisible(true)
				local status = true
				for k, v in pairs(config[#self.chose_item_list]) do
					if role_vo.lev >= v.need and role_vo.lev <= v.need_max then
						status = false
						local rate = v.pro or 0
						self.rate_txt:setString(TI18N("语言_c_45") .. rate/10 .. "%")
						self.rate_txt:setTextColor(cc.c3b(112, 206, 50))
						self.rate_txt:setVisible(true)

						-- 设置消耗
						self:updateCostInfo(v.cost)
						self.target_item:setData({v.show_id,1})
						self.target_item:setIsShowBackground(true)
					end
				end
				if status then
					local need_lev = 0
					for k, v in pairs(config[#self.chose_item_list]) do
						if need_lev == 0 then
							need_lev = k
						else
							need_lev = math.min(need_lev, k)
						end
					end	
					self.level_txt:setString(string.format(TI18N("语言_c_2309"), need_lev))
					self.level_txt:setVisible(true)
					self.cost_txt:setVisible(false)
				else
					self.level_txt:setVisible(false)
				end
			else
				self.rate_txt:setTextColor(cc.c3b(206, 164, 120))
				local need_num = 0
				for k, v in pairs(config) do
					if need_num == 0 then
						need_num = k
					else
						need_num = math.min(need_num, k)
					end
				end
				self.rate_txt:setString(string.format(TI18N("语言_c_7139"),need_num))
				self.rate_txt:setVisible(true)
				self.cost_txt:setVisible(false)
				self.pos_node:setVisible(false)
			end
		end
	else
        self.pos_node:setVisible(false)
		self.rate_txt:setVisible(false)
		self.level_txt:setVisible(false)
		self.cost_txt:setVisible(false)
	end
	self:setAutoPanel()
	self:updateAutoPanel()
end
function GemstoneSmeltPanel:updateCostInfo(expend)
	if expend == nil or next(expend) == nil then return end
	self.cost_txt:setVisible(true)
	local str = ""
	for i,v in ipairs(expend) do
		local bid = v[1]
		local num = v[2]
		local item_config = Config.ItemData.data_get_data(bid)
		if item_config then
			if str ~= "" then
				str = str..","
			end
			str = string.format("<div outline=2,#5c2705>%s<img src='%s' scale=0.3 />%s</div>", str, PathTool.getItemRes(item_config.icon), MoneyTool.GetMoneyString(num))
		end
	end
	self.cost_txt:setString(TI18N("语言_c_46")..str)
end

-- 一键添加
function GemstoneSmeltPanel:_onClickQuickAddBtn(  )
	local all_item_data = {}
    local all_list = {}
    local item_data = BackpackController:getInstance():getModel():getBagItemList(BackPackConst.Bag_Code.GEMSTONE)
    for k,v in pairs(item_data) do
        table.insert(all_list, v)
    end
    -- local back_data = BackpackController:getInstance():getModel():getBagItemList(BackPackConst.Bag_Code.BACKPACK)
    -- for k,v in pairs(back_data) do
    --     if v.config.type == BackPackConst.item_type.GEMSTONE_DEBRIS then
    --         table.insert(all_list, v)
    --     end
    -- end
	local cfg = Config.PartnerGemData.data_base_info
	local config = Config.PartnerGemData.data_comp
	local cost_list = {}
	for key,value in pairs(config) do
        for k,v in pairs(value) do
            for _,_v in pairs(v) do
                for _,item_id in pairs(_v.costs) do
                    table.insert(cost_list, item_id)
                end
                break
            end
            break
        end
    end
	for k,v in pairs(all_list) do
		if table.indexof(cost_list,v.config.id) then
			local artifact_cfg = cfg[v.config.id]
			if artifact_cfg then
				v.pos = artifact_cfg.pos
				if v.checkGemIsLock then
					if not v:checkGemIsLock() then
						table.insert(all_item_data,v)
					end
				end
			else
				for i=1,v.quantity do
					local good_vo = deepCopy(v)
					good_vo.quantity = 1
					good_vo.pos = 999
					table.insert(all_item_data,v)
				end
			end
		end
    end
	-- 按照品质从低到高排序
	table.sort(all_item_data, SortTools.tableLowerSorter({"quality", "pos","id"}))
	local qua_item_list = {} -- 按照类型
	for i, vo in pairs(all_item_data) do
		local item_type = 0
		for key,value in pairs(config) do
			for k,v in pairs(value) do
				for _,_v in pairs(v) do
					for _,item_id in pairs(_v.costs) do
						if item_id == vo.config.id then
							item_type = _v.type
						end
					end
					break
				end
				break
			end
		end
		if not qua_item_list[item_type] then
			qua_item_list[item_type] = {}
		end
		if not qua_item_list[item_type][vo.config.id] then
			qua_item_list[item_type][vo.config.id] = {}
		end
		if item_type and vo.config.id then
			qua_item_list[item_type][vo.config.id].type = item_type
			qua_item_list[item_type][vo.config.id].bid = vo.config.id
		end
	end
	local add_flag = false
	for i = 1, #config do
		if config[i] then
			local max_num = 1
			local limit_num = 0
			for k, v in pairs(config[i]) do
				for key, value in pairs(v) do
					if role_vo.lev >= value.need and role_vo.lev <= value.need_max then
						max_num = math.max(max_num,value.num)
						if limit_num == 0  then
							limit_num = value.num
						else
							if limit_num > value.num then
								limit_num = value.num
							end
						end
					end
				end
			end
			local item_type = i
			if qua_item_list[item_type] then
				local all_use_item = {}
				local have_num = 0
				for quality, id_list in pairs(qua_item_list[item_type]) do
					local bid = id_list.bid
					local item_cfg = Config.ItemData.data_get_data(bid)
					if item_cfg then
						-- if item_cfg.type == BackPackConst.item_type.GEMSTONE then
							local back_list = back_model:getGemItemIdListByBid(bid)
							have_num = have_num + back_model:getPackItemNumByBid(BackPackConst.Bag_Code.GEMSTONE,bid)
							if back_list and next(back_list) then
								for k, v in pairs(back_list) do
									local item_vo = back_model:getGamPackItemById(v)
									if Config.PartnerGemData.data_base_info[item_vo.config.id] then
										if item_vo.checkGemIsLock and not item_vo:checkGemIsLock() then
											table.insert(all_use_item,item_vo.id)
										end
									else
										for i=1,item_vo.quantity do
											table.insert(all_use_item,item_vo.id)
										end
									end
								end
							end
						-- elseif item_cfg.type == BackPackConst.item_type.GEMSTONE_DEBRIS then
						-- 	local back_list = back_model:getBackPackItemIdListByBid(bid)
						-- 	have_num = have_num + back_model:getPackItemNumByBid(BackPackConst.Bag_Code.BACKPACK,bid)
						-- 	if back_list and next(back_list) then
						-- 		for k, v in pairs(back_list) do
						-- 			local item_vo = back_model:getBackPackItemById(v)
						-- 			for i=1,item_vo.quantity do
						-- 				table.insert(all_use_item,item_vo.id)
						-- 			end
						-- 		end
						-- 	end
						-- end
					end
				end
				if have_num < limit_num then
					all_use_item ={}
				end
				if not add_flag then -- 把最低品质的满足最低合成条件的保存一下，可能出现所有品质都不满足玩家选择数量的情况，这时选择最低品质满足最低合成条件的
					add_flag = true
					self.chose_item_list = {}
					for i=1, #all_use_item do
						if i <= max_num then
							table.insert(self.chose_item_list, all_use_item[i])
						end
					end
				end
				-- 大于等于玩家选择的数量
				local num = math.min(max_num, self.cur_auto_num)
				if tableLen(all_use_item) >= num then
					self.chose_item_list = {}
					if tableLen(all_use_item) > num then
						for i,id in ipairs(all_use_item) do
							if i <= num then
								table.insert(self.chose_item_list, id)
							else
								break
							end
						end
					else
						self.chose_item_list = all_use_item
					end
					break
				end
			end
		end
	end

	if not self.chose_item_list or next(self.chose_item_list) == nil then
		message(TI18N("语言_c_7140"))
	else
		self:updateChoseArtifactItems()
	end
end
function GemstoneSmeltPanel:DeleteMe()
    -- 与本地缓存不一致时才写入本地
	if SysEnv:getInstance():getNum(SysEnv.keys.gem_artifact_num) ~= self.cur_auto_num then
		SysEnv:getInstance():set(SysEnv.keys.gem_artifact_num, self.cur_auto_num)
	end
	if self.lucky_update_evt then
		GlobalEvent:getInstance():UnBind(self.lucky_update_evt)
        self.lucky_update_evt = nil
	end    
	if self.chose_update_evt then
		GlobalEvent:getInstance():UnBind(self.chose_update_evt)
		self.chose_update_evt = nil
	end
	if self.compound_update_evt then
		GlobalEvent:getInstance():UnBind(self.compound_update_evt)
		self.compound_update_evt = nil
	end
	self:handleComEffect(false)
    doStopAllActions(self.main_container)
end