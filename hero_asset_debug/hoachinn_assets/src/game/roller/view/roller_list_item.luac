RollerListItem = class("RollerListItem", function()
    return ccui.Widget:create()
end)
local controller = RollerController:getInstance()
local model = controller:getModel()
local string_format = string.format

function RollerListItem:ctor(type)
	self.type = type
	self.extral_height = 0
	self:configUI()
end


function RollerListItem:configUI()
	self:setAnchorPoint(cc.p(0.5, 1))
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("roller/roller_list_item"))
	self:addChild(self.root_wnd)
    local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
	self.left_title_bg = main_container:getChildByName("left_title_bg")
	self.title_name = main_container:getChildByName("title_name")
	self.title_name:setString(TI18N("语言_c_7193"))
	self.right_title_bg = main_container:getChildByName("right_title_bg")
	if self.type == 2 then
		self.left_title_bg:setVisible(true)
		self.title_name:setVisible(true)
		self.right_title_bg:setVisible(true)
		setLeftRightImg(self.left_title_bg, self.title_name, self.right_title_bg, 20)
	else
		self.left_title_bg:setVisible(false)
		self.title_name:setVisible(false)
		self.right_title_bg:setVisible(false)
	end

	self.award_list = main_container:getChildByName("award_list")
	
end
function RollerListItem:createNewCell(width, height)
    local cell = RollerListItemItem.new()
    cell:addCallBack(function()
        self:onCellTouched(cell)
    end)
    return cell
end
function RollerListItem:numberOfCells()
    if not self.cell_data_list then
        return 0
    end
    return #self.cell_data_list
end
function RollerListItem:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then
        return
    end
    cell:setData(cell_data)
end
function RollerListItem:onCellTouched(cell)
    local data = cell:getSendData()
    local item_id = data.item_id
    self.select_item_list[item_id] = data
    self:countTotalSelectExp()
end

function RollerListItem:setData(data)
	local add_height = 0
	if self.type == 2 then
		add_height = 46
	end
	local list_height =  math.ceil(#data/3) * (250 + 5)
	local total_height = list_height + add_height
	self:setContentSize(cc.size(720, total_height))
	self.main_container:setContentSize(cc.size(720, total_height))
	self.main_container:setPositionY(total_height)
	self.left_title_bg:setPositionY(total_height - 16)
	self.title_name:setPositionY(total_height-4)
	self.right_title_bg:setPositionY(total_height - 16)
	self.award_list:setContentSize(cc.size(720, total_height - add_height))
	self.award_list:setPositionY(total_height-add_height)
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
    end
	if self.item_scrollview == nil then
        local scroll_view_size = self.award_list:getContentSize()
        local setting = {
            start_x = 30, -- 第一个单元的X起点
            space_x = 15, -- x方向的间隔
            start_y = 0, -- 第一个单元的Y起点
            space_y = 5, -- y方向的间隔
            item_width = 210, -- 单元的尺寸width
            item_height = 250, -- 单元的尺寸height
			col = 3,
            once_num = 1 -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.award_list, cc.p(0, 0), ScrollViewDir.vertical,ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell) -- 创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells) -- 获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) -- 更新cell
		self.item_scrollview:setClickEnabled(false)
		self.item_scrollview:setSwallowTouches(false)
	end

	self.cell_data_list = deepCopy(data)
	for i, v in ipairs(self.cell_data_list) do
		local is_can_act = model:checkActiveStatusById(v.id)
		v.__sort = v.max_score
		if is_can_act then
			v.__sort = 1000000 + v.max_score
		end
	end
	local function sortFunc( objA, objB )
		return objA.__sort > objB.__sort
	end
	table.sort(self.cell_data_list, sortFunc)
	self.item_scrollview:reloadData()
end

function RollerListItem:setVisibleStatus(bool)
    self:setVisible(bool)
end

function RollerListItem:DeleteMe()
	-- for k, v in pairs(self.item_list) do
	-- 	v:DeleteMe()
	-- 	v= nil
	-- end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
	self:removeAllChildren()
    self:removeFromParent()
end


RollerListItemItem = class("RollerListItemItem", function() 
	return ccui.Layout:create()
end)

function RollerListItemItem:ctor()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("roller/roller_list_item_item"))
    self.size = cc.size(210,250)
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)

	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width/2, self.size.height/2)
	self:addChild(self.root_wnd)

	self.main_container = self.root_wnd:getChildByName("main_container")
	self.main_container:setSwallowTouches(false)
	self.eff_node = self.main_container:getChildByName("eff_node")
	self.eff_node.init_pos = cc.p(105, 117)
	self.item_bg = self.main_container:getChildByName("item_bg")
	self.item_icon = self.main_container:getChildByName("item_icon")
	self.item_icon.init_pos = cc.p(105, 124)
	self.equip_name = self.main_container:getChildByName("equip_name")
	setTextMaxWidth(self.equip_name, 150)
	self.equip_name:setTouchEnabled(true)
	self.quality_icon = self.main_container:getChildByName("quality_icon")
	self.quality_bg = self.main_container:getChildByName("quality_bg")
	self.name_bg = self.main_container:getChildByName("name_bg")

	self.up_panel = self.main_container:getChildByName("up_panel")
	self.lv_bg = self.up_panel:getChildByName("lv_bg")
	self.lv_txt = self.up_panel:getChildByName("lv_txt")
	self.star_layer = self.up_panel:getChildByName("star_layer")
	
	self.compose_panel = self.root_wnd:getChildByName("compose_panel")
	self.progress = self.compose_panel:getChildByName("progress")
	self.progress:setScale9Enabled(true)
	self.progress_txt = self.compose_panel:getChildByName("progress_txt")

	self.only_panel = self.main_container:getChildByName("only_panel")
	self.only_panel:setVisible(false)
    self.hero_icon = self.only_panel:getChildByName("hero_icon")

	self.red_point = self.root_wnd:getChildByName("red_point")
	self.red_point:setVisible(false)

	self:registerEvent()
end

function RollerListItemItem:setData(data)
	-- print("RollerListItemItem--------------------",vardump(data))
	self.data = data
	local name = data.name
	self.equip_name:setString(transformTextToShort(name,5))
	addEvt2showAllTextTips(self.equip_name,name,5)
	local quality = data.quality
	loadSpriteTexture(self.quality_icon, PathTool.getResFrame("prohibited_scroll",RollerConst.QualityIcon[quality]), LOADTEXT_TYPE_PLIST) 
	self.name_bg:loadTexture( PathTool.getResFrame("prohibited_scroll",RollerConst.Qualitybg1[quality]), LOADTEXT_TYPE_PLIST)
	self.quality_bg:loadTexture( PathTool.getResFrame("prohibited_scroll",RollerConst.Qualitybg2[quality]), LOADTEXT_TYPE_PLIST)
	self.equip_name:enableOutline(RollerConst.OutLineQualityColor[quality],2)

	local star = 0
	local roller_data = model:getRollerDataById(data.id)
	if roller_data then
		setChildDarkShader(false, self.compose_panel)
		star = roller_data.star
		local lev = roller_data.lev
		self.lv_txt:setString(lev)
		local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[data.id][star]
		if star_cfg.cost and next(star_cfg.cost) then
			local cost = star_cfg.cost[1]
			local cost_id = cost[1]
			local need_num = cost[2]
			local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
			self.progress:setPercent(own_num/need_num*100)
			self.progress_txt:setString(own_num.."/"..need_num)
		else
			self.progress:setPercent(100)
			self.progress_txt:setString("max")
		end
		if roller_data.partner_id and roller_data.partner_id ~= 0 then
			self.partner_id = roller_data.partner_id
			self:setHeadIcon()
			self.only_panel:setVisible(true)
		else
			self.only_panel:setVisible(false)
		end
		self.lv_bg:setVisible(true)
		self.lv_txt:setVisible(true)
		-- self.star_layer:setPositionX(122)

	else--未激活
		local cost = data.cost[1]
		local cost_id = cost[1]
		local need_num = cost[2]
		local own_num = BackpackController:getInstance():getModel():getItemNumByBid(cost_id)
		self.progress:setPercent(own_num/need_num*100)
		self.progress_txt:setString(own_num.."/"..need_num)
		if own_num >= need_num then
			setChildDarkShader(false, self.compose_panel)
		else
			setChildDarkShader(true, self.compose_panel)
		end
		
		self.only_panel:setVisible(false)
		self.lv_bg:setVisible(false)
		self.lv_txt:setVisible(false)
		-- self.star_layer:setPositionX(105)
	end

	local irem_img = data.show[1]
	local pos_info = data.scale[1]
	local _scale = 0.45
	local off_x = 0
	local off_y = 0
	if pos_info then
		_scale = pos_info[1]
		off_x = pos_info[2]
		off_y = pos_info[3]
	end
	if irem_img then
		if irem_img[1] == 1 then
			local res = PathTool.getRollerIcon(irem_img[2],2)
			self.item_icon:loadTexture(res, LOADTEXT_TYPE)
			self.item_icon:ignoreContentAdaptWithSize(true)
			self.item_icon:setScale(_scale)
			self.item_icon:setPositionX(self.item_icon.init_pos.x + off_x)
			self.item_icon:setPositionY(self.item_icon.init_pos.y + off_y)

			if self.icon_eff then
				self.icon_eff:setVisible(false)
			end
		elseif irem_img[1] == 2 then
			if not self.icon_eff then
				self.icon_eff = createEffectSpine(irem_img[2], cc.p(self.item_icon:getContentSize().width/2, self.item_icon:getContentSize().height/2), cc.p(0.5,0.5), true, "action1")
				self.icon_eff:setScale(0.45, 0.45)
				self.eff_node:addChild(self.icon_eff)
			end
			local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[data.id][star]
			local show = star_cfg.show[1]
			local action = show[1]
			self.icon_eff:setAnimation(0, action, true)
			self.icon_eff:setScale(_scale)
			self.icon_eff:setPositionX(self.item_icon.init_pos.x + off_x)
			self.icon_eff:setPositionY(self.item_icon.init_pos.y + off_y)
			
			self.item_icon:setVisible(false)
		end
	end

	if roller_data then
		setChildDarkShader(false, self.main_container)
	else
		setChildDarkShader(true, self.main_container)
	end

	local max_star = model:getMaxStarById(data.id)
	self:setStarPanel(star,max_star)

	self:checkRedPointStatus()
end

function RollerListItemItem:setHeadIcon()
	local hero_data = HeroController:getInstance():getModel():getHeroById(self.partner_id)
	local hero_id = hero_data.bid
    if hero_id and hero_id ~= 0 then
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
        self.only_icon:loadTexture(PathTool.getHeadIcon(hero_id), LOADTEXT_TYPE)
        self.only_panel:setVisible(true)
    else
        self.only_panel:setVisible(false)
    end
end

function RollerListItemItem:setStarPanel(star,max_star)
	if not self.star_list or not next(self.star_list) then
        self.star_list = createOnlyStar(max_star,self.star_layer,17)
    end
    for i, v in ipairs(self.star_list) do
        setChildUnEnabled(true, v)
        if i <= star then
            setChildUnEnabled(false, v)
        end
    end
end

function RollerListItemItem:registerEvent()
	self.main_container:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
        elseif event_type == ccui.TouchEventType.moved then
        elseif event_type == ccui.TouchEventType.ended then
			self.touch_end = sender:getTouchEndPosition()
			local is_click = true
			if self.touch_began ~= nil then
				is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
			end
			if is_click then
				playButtonSound2()
				local setting = {roller_id=self.data.id,partner_id=nil,open_type=TRUE}
				controller:openRollerChipTipsWindow(true,setting)
			end
        end
    end)

end

function RollerListItemItem:addCallBack()
end

function RollerListItemItem:checkRedPointStatus()
	local roller_data = model:getRollerDataById(self.data.id)
	local red_1, red_2,red_3,red_4
	if roller_data then
		red_1 = model:checkUpGradeStatusByRollerId(self.data.id)
		red_2 = model:checkUpStarStatusByRollerId(self.data.id)
		red_3 = model:checkUpFengyinStatusByRollerId(self.data.id)
	else
		red_4 = model:checkActiveStatusById(self.data.id)
	end

	local status = red_1 or red_2 or red_3 or red_4
	if status then
		self.red_point:setVisible(true)
	else
		self.red_point:setVisible(false)
	end
end

function RollerListItemItem:DeleteMe()
	if self.update_event then
        GlobalEvent:getInstance():UnBind(self.update_event)
        self.update_event = nil
    end

	self:removeAllChildren()
    self:removeFromParent()
end
