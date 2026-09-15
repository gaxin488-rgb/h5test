--**************************
--卷轴列表
--**************************
RollerListPanel = class("RollerListPanel", function()
    return ccui.Widget:create()
end)
local controller = RollerController:getInstance()
local model = controller:getModel()
local string_format = string.format

function RollerListPanel:ctor()  
	self:loadResListCompleted()
end

-- 资源加载完成
function RollerListPanel:loadResListCompleted(  )
	self.item_list = {}
	self:configUI()
	self:register_event()
	self._init_flag = true
	self.select_quality = 0
	self:setData()
end

function RollerListPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("roller/roller_list_panel"))
	self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)

	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

    local main_container = self.root_wnd:getChildByName("main_container")
	self.img_title = main_container:getChildByName("img_title")
	self.tiel = main_container:getChildByName("tiel")
	self.tiel:setString(TI18N("语言_c_7192"))
	local top_y = display.getTop(main_container)
    local bottom_y = display.getBottom(main_container)
	local add_height = top_y - bottom_y - SCREEN_HEIGHT
	self.img_title:setPositionY(top_y - 50)
	self.tiel:setPositionY(top_y - 92)

	self._list = main_container:getChildByName("list")
	local _list_size = self._list:getContentSize()
	self._list:setContentSize(cc.size(_list_size.width, _list_size.height+add_height))
	self.scroll_view = createScrollView(self._list:getContentSize().width,self._list:getContentSize().height,0,0,self._list,ccui.ScrollViewDir.vertical)

    self.help_btn = main_container:getChildByName("help_btn")
	self.help_btn:setPositionY(top_y - 110)
	self.jump_btn = main_container:getChildByName("jump_btn")
	self.jump_btn:setPositionY(top_y - 110)
	self.jump_btn:setVisible(false)
	self.jump_btn_label = self.jump_btn:getChildByName("label")
	setTextMaxWidth(self.jump_btn_label, 100, -4)
	self.jump_btn_label:setString(TI18N("语言_cro_gr_05_3"))
	if SealNewtowerController:getInstance():getModel():isHide() then
		self.jump_btn:setVisible(true)
	end

	self.lis_bottom_bg = main_container:getChildByName("lis_bottom_bg")
	self.lis_bottom_bg:setPositionY(bottom_y + 270)
	self.quality_select_bg = main_container:getChildByName("quality_select_bg")
	self.quality_select_bg:setPositionY(bottom_y + 215)
	self.equip_btn = main_container:getChildByName("equip_btn")
	self.equip_btn_label = self.equip_btn:getChildByName("label")
	setTextMaxWidth(self.equip_btn_label, 100, -4)
	self.equip_btn_label:setString(TI18N("语言_c_7422"))
	self.equip_btn:setPositionY(bottom_y + 215)
	self.camp_panel = main_container:getChildByName("camp_panel")
	self.camp_panel:setPositionY(bottom_y + 215)
	self.new_camp_btn_list = {}
    self.new_camp_btn_list[0] = self.camp_panel:getChildByName("camp_btn0")
    self.new_camp_btn_list[3] = self.camp_panel:getChildByName("camp_btn1")
    self.new_camp_btn_list[4] = self.camp_panel:getChildByName("camp_btn2")
    self.new_camp_btn_list[5] = self.camp_panel:getChildByName("camp_btn3")
	self.camp_select = self.camp_panel:getChildByName("camp_select")
end


function RollerListPanel:register_event(  )
	if self.help_btn then
        self.help_btn:addTouchEventListener(function( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				controller:openRollerGameplayDescriptionWindow(true,1)
            end
        end)
    end
	registerButtonEventListener(self.jump_btn, function() self:_onClickJumpBtn() end ,true, 1)

    for index, v in pairs(self.new_camp_btn_list) do
        registerButtonEventListener(v, function() self:_onClickBtnShowByIndex(index) end ,true, 1)
    end
	registerButtonEventListener(self.equip_btn, function() self:_onClickEquipBtn() end ,true, 1)

    if not self.roller_update_event then
        self.roller_update_event = GlobalEvent:getInstance():Bind(RollerEvent.Update_Roller_Event,function()
			self:setData()
			self:updateEquipBtnStatus()
        end)
    end

	-- 物品道具增加 
	if not self.add_goods_event then
		self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, temp_add)
			if bag_code == BackPackConst.Bag_Code.BACKPACK then
				self:setData()
			end
		end)
	end
	-- 物品道具删除
	if not self.del_goods_event then
		self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code, temp_del)
			if bag_code == BackPackConst.Bag_Code.BACKPACK then
				self:setData()
			end
		end)
	end
	-- 物品道具改变
	if not self.modify_goods_event then
		self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, temp_list)
			if bag_code == BackPackConst.Bag_Code.BACKPACK then
				self:setData()
			end
		end)
	end

end
function RollerListPanel:_onClickEquipBtn()
	controller:openRollerHeroEquipListWindow(true)
end
function RollerListPanel:_onClickJumpBtn()
	local is_open = SealtowerController:getInstance():checkIsOpen()
	local index = SealtowerController:getInstance():getModel():getSealTowerIsOpen()
	if is_open and index ~= 0 and SealNewtowerController:getInstance():getModel():isHide() then
		SealNewtowerController:getInstance():openSealTowerWindow(true)
	else
		message(TI18N("语言_c_7462"))
	end
end
function RollerListPanel:_onClickBtnShowByIndex(index)
	if self.select_quality == index then
		return
	end
	self.select_quality = index
	self:setData()
end
function RollerListPanel:setData()
	local list_cfg = Config.ProhibitedScrollData.data_get_proh_scroll
	local own_list = {}
	local not_list = {}
	for k, v in pairs(list_cfg) do
		local id = v.id
		local is_open = model:checkSingleRollerOpenStatus(id)
		if is_open then
			local is_own = model:getRollerDataById(id)
			if is_own then
				if not own_list[0] then
					own_list[0] = {}
				end
				table.insert(own_list[0],v)
				if not own_list[v.quality] then
					own_list[v.quality] = {}
				end
				table.insert(own_list[v.quality],v)
			else
				if not not_list[0] then
					not_list[0] = {}
				end
				table.insert(not_list[0],v)
				if not not_list[v.quality] then
					not_list[v.quality] = {}
				end
				table.insert(not_list[v.quality],v)
			end
		end
	end
	local show_own_list = own_list[self.select_quality]
	local show_not_list = not_list[self.select_quality]

	local total_height = 0
	local own_height = 0
	local lose_height = 0
	if show_own_list and next(show_own_list) then
		own_height = math.ceil(#show_own_list/3) * (250 + 5) + 50
		total_height = total_height + own_height
	end
	if show_not_list and next(show_not_list) then
		lose_height = math.ceil(#show_not_list/3) * (250 + 5) + 70
		total_height = total_height + lose_height
	end
	total_height = math.max(self._list:getContentSize().height,total_height)
	self.scroll_view:setInnerContainerSize(cc.size(720, total_height))
	
	if show_own_list and next(show_own_list) then
		if not self.own_item then
			self.own_item = RollerListItem.new(1)
			self.scroll_view:addChild(self.own_item)
		end
		self.own_item:setData(show_own_list)
		self.own_item:setPositionX(360)
		self.own_item:setPositionY(total_height)
		self.own_item:setVisible(true)
	else
		if self.own_item then
			self.own_item:setVisible(false)
		end
	end

	if show_not_list and next(show_not_list) then
		if not self.lose_item then
			self.lose_item = RollerListItem.new(2)
			self.scroll_view:addChild(self.lose_item)
		end
		self.lose_item:setData(show_not_list)
		self.lose_item:setPositionX(360)
		self.lose_item:setPositionY(total_height-own_height)
		self.lose_item:setVisible(true)
	else
		if self.lose_item then
			self.lose_item:setVisible(false)
		end
	end

	if self.camp_select and self.new_camp_btn_list[self.select_quality] then
        local x, y = self.new_camp_btn_list[self.select_quality]:getPosition()
        self.camp_select:setPosition(x - 0.5, y + 1)
    end

	self:updateEquipBtnStatus()
end

function RollerListPanel:updateEquipBtnStatus()
	local status = HeroController:getInstance():getModel():checkHeroRollerRed()
	addRedPointToNodeByStatus(self.equip_btn, status, 5, 5)
end

function RollerListPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

function RollerListPanel:DeleteMe()
    if self.own_item then
        self.own_item:DeleteMe()
    end
    self.own_item = nil
    if self.lose_item then
        self.lose_item:DeleteMe()
    end
    self.lose_item = nil
	
	if self.roller_update_event then
        GlobalEvent:getInstance():UnBind(self.roller_update_event)
        self.roller_update_event = nil
    end
	if self.add_goods_event then
        GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
    end
	if self.del_goods_event then
        GlobalEvent:getInstance():UnBind(self.del_goods_event)
        self.del_goods_event = nil
    end
	if self.modify_goods_event then
        GlobalEvent:getInstance():UnBind(self.modify_goods_event)
        self.modify_goods_event = nil
    end
	self:removeAllChildren()
    self:removeFromParent()
end