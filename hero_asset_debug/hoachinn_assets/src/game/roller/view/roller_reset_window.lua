RollerResetWindow = RollerResetWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()
local string_format = string.format

function RollerResetWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Tips
	self.layout_name = "roller/roller_reset_window"
end 

function RollerResetWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	self.main_panel = self.root_wnd:getChildByName("main_panel")
	commonOpenActionLeftMove(self.main_panel)
	self.main_container = self.main_panel:getChildByName("main_container")
	self.title_container = self.main_panel:getChildByName("title_container")
	self.title_label = self.title_container:getChildByName("title_label")
	self.title_label:setString(TI18N("语言_c_5330"))
	self.close_btn = self.main_panel:getChildByName("close_btn")
	self.ok_btn = self.main_panel:getChildByName("ok_btn")
	self.ok_btn:getChildByName("label"):setString(TI18N("语言_c_3"))
	self.cancel_btn = self.main_panel:getChildByName("cancel_btn")
	self.cancel_btn:getChildByName("label"):setString(TI18N("语言_c_62"))

	self.tips = createRichLabel(22, cc.c4b(0x7a,0x58,0x32,0xff), cc.p(0.5, 1), cc.p(290, 238), 0, nil, 560)
    self.main_container:addChild(self.tips)

	local scroll_view_size = cc.size(580,120)
    local setting = {
        item_class = BackPackItem,
        start_x = 0,
        space_x = 10,
        start_y = 0,
        space_y = 0,
        item_width = BackPackItem.Width * 0.9,
        item_height = BackPackItem.Width * 0.9,
        row = 1,
        col = 0,
        scale = 0.9,
        is_center = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.main_container, cc.p(0, 0), ScrollViewDir.horizontal,ScrollViewStartPos.top, scroll_view_size, setting)

end

function RollerResetWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			if self.can_touch  == true then
				self:onClickClose()
			end
		end
	end)
	registerButtonEventListener(self.close_btn, function()
        self:onClickClose()
    end, true)
	registerButtonEventListener(self.ok_btn, function()
		if self.data.type == 1 then
			controller:sender20808(self.data.roller_id)
		else
			controller:sender20822()
		end
		controller:openRollerResetWindow(false)
    end, true)
	registerButtonEventListener(self.cancel_btn, function()
        self:onClickClose()
    end, true)
end

function RollerResetWindow:onClickClose()
    controller:openRollerResetWindow(false)
end

function RollerResetWindow:openRootWnd(data)
    playOtherSound("c_get") 
	self.data = data
	if self.data.type == 1 then --强化类型
		local roller_data = model:getRollerDataById(self.data.roller_id)
		local lev = roller_data.lev
		local base_cfg = Config.ProhibitedScrollData.data_get_proh_scroll[self.data.roller_id]
		local quality = base_cfg.quality
		local quality_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_enhance[quality]
		local cost_list = {}
		for i = 0, lev-1 do
			local info = quality_cfg[i]
			local cost = info.cost
			for key, val in ipairs(cost) do
				local cost_id = val[1]
				local cost_num = val[2]
				if cost_list[cost_id] then
					cost_list[cost_id] = cost_list[cost_id] + cost_num
				else
					cost_list[cost_id] = cost_num
				end
			end
		end
		local list = {}
		for k, v in pairs(cost_list) do
			local vo = {}
			vo = deepCopy(Config.ItemData.data_get_data(k))
			vo.num = v
			table.insert(list,vo)
		end

		--封印相关
		local seal_count = roller_data.seal_count
		if seal_count and seal_count > 0 then
			local seal_cost = Config.ProhibitedScrollData.data_get_constant["sealing_consumption"].val 
			local seal_id = seal_cost[1][1]
			local seal_num = seal_cost[1][2]
			local seal_total = seal_count * seal_num
			local vo = {}
			vo = deepCopy(Config.ItemData.data_get_data(seal_id))
			vo.num = seal_total
			table.insert(list,vo)
		end

		self.item_scrollview:setData(list)
		self.item_scrollview:addEndCallBack(function (  )
			local list = self.item_scrollview:getItemList()
			for k,v in pairs(list) do
				v:setDefaultTip()
			end
		end)

		local const_cfg = Config.ProhibitedScrollData.data_get_constant["scroll_resetting_spend"]
		local val = const_cfg.val[1]
		local cost_id = val[1]
		local cost_num = val[2]
		local item_cfg = Config.ItemData.data_get_data(cost_id)
		local res = PathTool.getItemRes(item_cfg.icon)

		local str = ""
		str = string.format(TI18N("语言_c_7223"), item_cfg.icon, cost_num)
		self.tips:setString(str)

	elseif self.data.type == 2 then
		local cost_list = {}
		local talent_list = model:getTalentData()
		for i, v in pairs(talent_list) do
			local talent_id = i
			local talent_cfg = model:getRollerTalentInfo(talent_id)
			local cost = talent_cfg.cost --{id=101, group=1, attrs={}, skill={}, active_skill={731021,732201}, cost={{60,2}}
			for key, val in pairs(cost) do
				table.insert(cost_list, val)
			end
		end
		local temp_list = {}
		for k, v in pairs(cost_list) do
			local cost_id = v[1]
			local cost_num = v[2]
			if temp_list[cost_id] then
				temp_list[cost_id] = temp_list[cost_id] + cost_num
			else
				temp_list[cost_id] = cost_num
			end
		end
		local _list = {}
		for k, v in pairs(temp_list) do
			local vo = {}
			vo = deepCopy(Config.ItemData.data_get_data(k))
			vo.num = v
			table.insert(_list,vo)
		end
		self.item_scrollview:setData(_list)
		self.item_scrollview:addEndCallBack(function (  )
			local ist = self.item_scrollview:getItemList()
			for k,v in pairs(ist) do
				v:setDefaultTip()
			end
		end)

        local basecof = Config.ProhibitedScrollData.data_get_constant.scroll_talent_resetting_spend.val[1]
        local config = Config.ItemData.data_get_data(basecof[1])
        local own_num = BackpackController:getInstance():getModel():getItemNumByBid(basecof[1])
        local str = ""
        str = string.format(TI18N("语言_c_7224"), config.icon,basecof[2])
		self.tips:setString(str)
	end
end

function RollerResetWindow:close_callback()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
    controller:openRollerResetWindow(false)
end