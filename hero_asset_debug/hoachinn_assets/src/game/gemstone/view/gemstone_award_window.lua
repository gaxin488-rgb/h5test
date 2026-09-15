--------------------------------------------
-- 
-- 
-- @Date    : 2019-01-16 19:09:44
-- @description    : 
		-- 符文奖励领取
---------------------------------

GemstoneAwardWindow = GemstoneAwardWindow or BaseClass(BaseView)

local _controller = GemstoneController:getInstance()
local model = _controller:getModel()

function GemstoneAwardWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Mini  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.layout_name = "gemstone/gemstone_award_window"
end

function GemstoneAwardWindow:open_callback(  )
	local background_panel = self.root_wnd:getChildByName("background_panel")
	self.background = background_panel:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(main_panel, 2)
	local main_container  = main_panel:getChildByName("main_container")

	local title_container = main_panel:getChildByName("title_container")
	local Image_1_0 = title_container:getChildByName("Image_1_0")
	local title_label = title_container:getChildByName("title_label")
	title_label:setString(TI18N("语言_c_2285"))
	Image_1_0:setContentSize(cc.size(title_label:getContentSize().width + 120,Image_1_0:getContentSize().height))

	self.close_btn = main_panel:getChildByName("close_btn")
	self.ok_btn = main_panel:getChildByName("ok_btn")
	self.ok_btn_label = self.ok_btn:getChildByName("label")
	self.ok_btn_label:setString(TI18N("语言_c_109"))

	local content_label = main_container:getChildByName("content_label")

	local lucky_cfg = Config.PartnerGemData.data_constant["change_condition"]
	local award_cfg = Config.PartnerGemData.data_constant["change_gift"]
	if lucky_cfg and award_cfg and award_cfg.val and award_cfg.val[1] then
		local bid = award_cfg.val[1][1]
		local num = award_cfg.val[1][2]
		local item_config = Config.ItemData.data_get_data(bid)
		if item_config then
			self.award_item_bid = bid
			content_label:setString(string.format(TI18N("语言_c_2286"), lucky_cfg.val, item_config.name, num))
			if not self.award_item then
				self.award_item = BackPackItem.new(false, true, false, nil, true, true)
				self.award_item:setBaseData(bid, num)
				self.award_item:setPosition(cc.p(290, 80))
				main_container:addChild(self.award_item)
			end
		end
	end
end

function GemstoneAwardWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.ok_btn, handler(self, self._onClickOkBtn), true)
end

function GemstoneAwardWindow:_onClickCloseBtn(  )
	_controller:openGemstoneAwardWindow(false)
end

function GemstoneAwardWindow:_onClickOkBtn(  )
	_controller:sender22808()
	_controller:openGemstoneAwardWindow(false)
end

-- 刷新领取按钮状态
function GemstoneAwardWindow:refreshBtnStatus(  )
	local cur_lucky = model:getGemArtifactNum()
	local max_lucky = 0
	local lucky_cfg = Config.PartnerGemData.data_constant["change_condition"]
	if lucky_cfg and lucky_cfg.val then
		max_lucky = lucky_cfg.val
	end
	if cur_lucky >= max_lucky then
		setChildUnEnabled(false, self.ok_btn)
    	self.ok_btn:setTouchEnabled(true)
	else
		setChildUnEnabled(true, self.ok_btn)
    	self.ok_btn:setTouchEnabled(false)
	    self.ok_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
	end
end

function GemstoneAwardWindow:openRootWnd(  )
	self:refreshBtnStatus()
end

function GemstoneAwardWindow:close_callback(  )
	_controller:openGemstoneAwardWindow(false)
end