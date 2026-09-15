--------------------------------------------
-- 
-- 
-- @Date    : 2019-09-23 16:49:18
-- @description    : 
-- 禁器调整
---------------------------------
local _controller = JinqiController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _table_remove = table.remove
local _table_sort = table.sort
local _string_format = string.format

RollerTalentMainTips = RollerTalentMainTips or BaseClass(BaseView)

function RollerTalentMainTips:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "jinqi/jinqi_form_window"

	self.jinqi_skill_list = {}
	self.item_rect_list = {}
end

function RollerTalentMainTips:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container, 1)

	local win_title = main_container:getChildByName("win_title")
	win_title:setString(TI18N("语言_c_1985"))
    local image_2 = main_container:getChildByName("imgTitleBg")
    moveTextBg(win_title,image_2,60,image_2:getContentSize().width)

    self.left_btn = main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("语言_c_1924"))

    self.right_btn = main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("语言_c_1986"))

	-- self.save_btn = main_container:getChildByName("save_btn")
	-- self.save_btn:getChildByName("label"):setString(TI18N("语言_c_325"))

	self.tips_txt = createRichLabel(21, 274, cc.p(0.5, 0.5), cc.p(338, 288), -8, nil, 500)
	self.tips_txt:setString(TI18N("语言_c_6899"))
	main_container:addChild(self.tips_txt)

	local lay_scrollview = main_container:getChildByName("lay_scrollview")
	local scroll_view_size = lay_scrollview:getContentSize()
    local list_setting = {
        start_x = 15,
        space_x = 25,
        start_y = 8,
        space_y = 50,
        item_width = BackPackItem.Width,
        item_height = BackPackItem.Height+2,
        row = 0,
        col = 4,
        need_dynamic = true,
        inner_hight_offset = 50
    }
    self.list_view = CommonScrollViewSingleLayout.new(lay_scrollview, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

    self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
end

function RollerTalentMainTips:createNewCell(  )
	local cell = JinqiItem.new(false, false, false)
	cell:setTouchEnabled(true)
	cell:addTouchEventListener(function ( sender, event_type )
		if event_type == ccui.TouchEventType.began then
			self.touch_began = sender:getTouchBeganPosition()
			doStopAllActions(self.main_container)
            self.long_touch_type = LONG_TOUCH_BEGAN_TYPE
            delayRun(self.main_container, 0.6, function ()
                if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                    local jinqi_vo = sender:getData()
                    -- local jinqi_data = 
                    local elfin_cfg = Config.SpriteData.data_elfin_data(jinqi_vo.id)
                    if elfin_cfg then
                        local skill_cfg
                        local str = jinqi_vo.base_id.."_"..jinqi_vo.elfin_order
                        local cfg = Config.SpriteData.data_elfin_dan(str)
                        skill_cfg = Config.SkillData.data_get_skill(cfg.skill)
                		if skill_cfg then
                			TipsManager:getInstance():showSkillTips(skill_cfg, false, false, false,false,false,elfin_vo.elfin_order)
                		end
                    end
                end
                self.long_touch_type = LONG_TOUCH_END_TYPE
            end)
		elseif event_type == ccui.TouchEventType.moved then
			if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                local touch_began = self.touch_began
                local touch_move = sender:getTouchMovePosition()
                if touch_began and touch_move and (math.abs(touch_move.x - touch_began.x) > 20 or math.abs(touch_move.y - touch_began.y) > 20) then 
                    --移动大于20了..表示取消长点击效果
                    doStopAllActions(self.main_container)
                    self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                end 
            end
		elseif event_type == ccui.TouchEventType.canceled then
			if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                doStopAllActions(self.main_container)
                self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
            end
		elseif event_type == ccui.TouchEventType.ended then
			if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                doStopAllActions(self.main_container)
                self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
            elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
                --事件触发了就不处理点击事件了
                return
            end
            self:onCellTouched(sender)
		end
	end)
    return cell
end

function RollerTalentMainTips:numberOfCells(  )
	if not self.all_elfin_data then return 0 end
	return #self.all_elfin_data
end

function RollerTalentMainTips:updateCellByIndex( cell, index )
	cell.index = index
    local item_data = self.all_elfin_data[index]
    if item_data then
    	cell:setData(item_data)
        -- cell:setElfinOrder(item_data.elfin_order)
    	-- cell:showItemQualityName(true)
    	-- cell:setSelfNum(item_data.quantity or 0)
    	if item_data.is_select == true then
    		cell:IsGetStatus(true)
    	else
    		cell:IsGetStatus(false)
    	end
    end
end

function RollerTalentMainTips:onCellTouched( cell )
	if not cell then return end
	local item_vo = cell:getData()
	if not item_vo then return end

	if item_vo.is_select == true then
		item_vo.is_select = false
		cell:IsGetStatus(false)
		for k,v in pairs(self.chose_jinqi_list) do
			if v.item_bid == item_vo.id then
				v.item_bid = 0
				break
			end
		end
		self:updateSkillList()
	else
		-- 先判断是否有空位、同类型的精灵
		local is_have_pos = false
		for k,v in pairs(self.chose_jinqi_list) do
			if v.item_bid == 0 and _model:getPosInfo(v.pos) then
				is_have_pos = true
			end
		end
		if not is_have_pos then
			message(TI18N("语言_c_6900"))
			return
		end
		item_vo.is_select = true
		cell:IsGetStatus(true)
		for i,v in ipairs(self.chose_jinqi_list) do
			if v.item_bid == 0 then
				v.item_bid = item_vo.id
				break
			end
		end
		self:updateSkillList()
	end
end

function RollerTalentMainTips:register_event(  )
	registerButtonEventListener(self.background, function() self:onCloseBtn() end, false, 2)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickSaveBtn), true)
	registerButtonEventListener(self.left_btn, handler(self, self.onClickLeftBtn), true)
end

function RollerTalentMainTips:onCloseBtn()
    _controller:openJinqiFormWindow(false)
end

--打开方案管理
function RollerTalentMainTips:onClickLeftBtn(  )
    local setting = {}
    if _model.getElfinTreeData then
        setting.cur_plan_data = _model:getElfinTreeData()
    end
    _controller:openElfinFightPlanPanel(true, setting)
    self:onCloseBtn()
end

function RollerTalentMainTips:onClickSaveBtn(  )
    if self.callback then
        local list = {}
        for k, v in pairs(self.chose_jinqi_list) do
            if v.item_bid and v.item_bid ~= 0 then
                table.insert(list,v)
            end
        end
        self.callback(list)
    end
	_controller:openJinqiFormWindow(false)
end

--setting.from_type 来及类型  1 古树打开  2 
--setting.callback  回调函数 如果无 表示保存古树的 如果有 相应callback
--setting.sprites 当前的已选择的的禁器列表
--setting.dic_filter_item_id 需要过滤 精灵id dic_filter_item_id[item_id] = 数量
function RollerTalentMainTips:openRootWnd(setting)
    --+print("RollerTalentMainTips:openRootWnd",vardump(setting))
    self.setting = setting or {}
    self.from_type = self.setting.from_type or 1
    self.callback = self.setting.callback
    self.sprites = self.setting.sprites or {}
    self.fun_form_type = self.setting.fun_form_type or 0
    self.dic_filter_item_id = self.setting.dic_filter_item_id or {}
    
	self:setData()

    self:updateSkillList()

    if self.from_type ~= 1 then
        self.left_btn:setVisible(false)
        self.right_btn:setPositionX(338)
    end
end

function RollerTalentMainTips:setData(  )
	-- 可用的禁器
	local jinqi_data = _model:getJinqiData()
    -- 当前选择的禁器
    local show_bid_list = self.sprites or {}

	self.chose_jinqi_list = deepCopy(show_bid_list)
	_table_sort(self.chose_jinqi_list, SortTools.KeyLowerSorter("pos"))

    --已选的禁器
    local dic_item_id = {}
    for i,v in ipairs(show_bid_list) do
        if v.item_bid and v.item_bid ~= 0 then
            dic_item_id[v.item_bid] = 1
        end
    end

    self.all_elfin_data = {}
    for _,v in pairs(jinqi_data) do
        local vo = deepCopy(v)
        if self.dic_filter_item_id[vo.id] then --过滤已经使用过的
        else
            local cfg = Config.ProhibitorData.data_get_prohibitor[vo.id]
            if dic_item_id[vo.id] then --设置已选
                vo.is_select = true
            end
            vo.quality = cfg.quality
            _table_insert(self.all_elfin_data, vo)
        end
    end

    if #self.all_elfin_data > 0 then
        local function sortFunc( objA, objB )
            if objA.star ~= objB.star then
                return objA.star > objB.star
            elseif objA.quality ~= objB.quality then
                return objA.quality > objB.quality
            end
        end
        _table_sort(self.all_elfin_data, sortFunc)
        commonShowEmptyIcon(self.list_view, false)
        self.list_view:reloadData()
    else
        commonShowEmptyIcon(self.list_view, true, {text = TI18N("语言_c_6901"),icon_res = "bigbg_6",offset_y=-50})
    end
end

-- 更新底部四个精灵技能图标
function RollerTalentMainTips:updateSkillList(  )
	local cd_order = 0
	for i=1,4 do
		local jinqi_id = self:getJinqiBidByPos(i)
        -- print("...+++++++++++++++",jinqi_id)
		local skill_item = self.jinqi_skill_list[i]

        if not skill_item then
            skill_item = SkillItem.new(true, false, true, 0.9, true)
            skill_item:setTouchEnabled(true)
            skill_item.jinqi_pos = i
            self.main_container:addChild(skill_item)
            skill_item:setPosition(cc.p(126+(i-1)*139, 202))
            self.jinqi_skill_list[i] = skill_item

            -- 记录一下解锁的技能icon的区域
            if jinqi_id then
            	local world_pos = skill_item:convertToWorldSpace(cc.p(0, 0))
	            local node_pos = self.main_container:convertToNodeSpace(world_pos)
	            self.item_rect_list[i] = cc.rect( node_pos.x, node_pos.y, SkillItem.Width*0.9, SkillItem.Height*0.9)

	            skill_item:addTouchEventListener(function ( sender, event_type)
                    self:onClickSkillItem(sender, event_type)
	            end)
            else
                skill_item:setClickInfo({click = true})
            end
        end

        local id = _model:getPosInfo(i) --当前位置是否已经解锁
 
        if id then
            jinqi_id = jinqi_id or 0
			skill_item.jinqi_id = jinqi_id
            skill_item:showLockIcon(false)

            local jinqi_cfg = Config.ProhibitorData.data_get_proh_star[jinqi_id]
            if jinqi_id == 0 or not jinqi_cfg then -- 已解锁，但未放置
                skill_item.cd_order = 0
                skill_item:setData()
                skill_item:showLevel(false)
                skill_item:showName(false)
                skill_item:setSkillLevel(0)
            else
                local jinqi_data = _model:getJinqiDataById(jinqi_id)
                if jinqi_data then
                    local skill_id = jinqi_cfg[jinqi_data.star].active_skill[1]
                    local skill_cfg = Config.SkillData.data_get_skill(skill_id)
                    skill_item:setSkillLevel(jinqi_data.star)
                    if skill_cfg then
                        skill_item:showLevel(true)
                        skill_item:showLevelBg(true)
                        skill_item:setData(skill_cfg)
                        -- skill_item:showName(true,skill_cfg.name,nil,20,true,cc.c4b(0xff,0xf0,0xd2,0xff),PathTool.getResFrame("elfin","elfin_1022"),cc.size(110,26))
                        if skill_cfg.type == "active_skill" then -- 主动技能
                            cd_order = cd_order + 1
                            skill_item.cd_order = cd_order
                        end
                    end
                end
            end
        else
            -- 未解锁精灵位置
            skill_item.jinqi_id = 0
            skill_item.cd_order = 0
            skill_item:setData()
            skill_item:showLevel(false)
            skill_item:showName(false)
            skill_item:showLockIcon(true)
        end
	end
end

function RollerTalentMainTips:onClickSkillItem( sender, event_type)
	if self.is_show_act then return end
	if event_type == ccui.TouchEventType.began then
		self.cur_touch_skill_pos = sender.jinqi_pos
		self.touch_move = false
		self.touch_began = sender:getTouchBeganPosition()
		local skill_data = sender:getData()
		if skill_data and next(skill_data) ~= nil then
			self.is_can_move = true
			-- 长按
			doStopAllActions(self.main_container)
	        self.long_touch_type = LONG_TOUCH_BEGAN_TYPE
	        delayRun(self.main_container, 0.6, function ()
	            if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
	                local skill_cfg = sender:getData()
	                if skill_cfg and next(skill_cfg) ~= nil then
	                	TipsManager:getInstance():showSkillTips(skill_cfg, false, false, false, sender.cd_order or 0,false)
	                end
	            end
	            self.long_touch_type = LONG_TOUCH_END_TYPE
	        end)
		else
			self.is_can_move = false
		end
	elseif event_type == ccui.TouchEventType.moved then
		self.touch_move = true
		self:onClickSkillItemMove(sender)
		if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
            local touch_began = self.touch_began
            local touch_move = sender:getTouchMovePosition()
            if touch_began and touch_move and (math.abs(touch_move.x - touch_began.x) > 20 or math.abs(touch_move.y - touch_began.y) > 20) then 
                --移动大于20了..表示取消长点击效果
                doStopAllActions(self.main_container)
                self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
            end 
        end
	elseif event_type == ccui.TouchEventType.canceled then
		self:onClickSkillItemCanceled(sender)
		if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
            doStopAllActions(self.main_container)
            self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
        end
	elseif event_type == ccui.TouchEventType.ended then
		if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
            doStopAllActions(self.main_container)
            self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
        elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
        	if self.move_skill_item and self.move_skill_item:isVisible() then
        		self.move_skill_item:setVisible(false)
        	end
        	self:updateSkillList()
        	return
        end

		self.touch_end = sender:getTouchEndPosition()
        local is_click = true
        if self.touch_began ~= nil then
            is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
        end
                    
        if self.touch_move and not is_click then
        	self:onClickSkillItemEnd(sender)
        else
        	if self.move_skill_item and self.move_skill_item:isVisible() then
        		self.move_skill_item:setVisible(false)
        	end
        	if sender.jinqi_pos then
        		for k,v in pairs(self.chose_jinqi_list) do
                	if v.pos == sender.jinqi_pos then
                		for _,vo in pairs(self.all_elfin_data) do
		        			if vo.id == v.item_bid then
		        				vo.is_select = false
		        				break
		        			end
		        		end
                		v.item_bid = 0
                		break
                	end
                end
        		self.list_view:reloadData(nil, nil, true)
        		self:updateSkillList()
        	end
        end
	end
end

-- 移动技能item
function RollerTalentMainTips:onClickSkillItemMove( sender)
	if not self.is_can_move then return end

    if not self.move_skill_item then
        self.move_skill_item = SkillItem.new(true, true, true, 0.9, true)
        self.main_container:addChild(self.move_skill_item)
    end
    self.move_skill_item:setVisible(true)
    self.move_skill_item:showLevel(true)

    local skill_data = sender:getData()
    if skill_data and next(skill_data) ~= nil then
    	self.move_skill_item:setData(skill_data)
    	self.move_skill_item.jinqi_id = sender.jinqi_id
    end

    sender:setData()
    sender:showLevel(false)
    sender.jinqi_id = 0
    local touch_pos = sender:getTouchMovePosition()
    local target_pos = self.main_container:convertToNodeSpace(touch_pos)
    self.move_skill_item:setPosition(target_pos)
end

function RollerTalentMainTips:onClickSkillItemCanceled( sender )
	if not self.is_can_move or not self.move_skill_item then return end

	local touch_pos = sender:getTouchMovePosition()
    local target_pos = self.main_container:convertToNodeSpace(touch_pos) 

    local is_have = false
    for index,rect in pairs(self.item_rect_list) do
    	if cc.rectContainsPoint( rect, target_pos ) then
    		local skill_item = self.jinqi_skill_list[index]
    		if skill_item then
    			self.is_show_act = true
    			local world_pos = skill_item:convertToWorldSpace(cc.p(0, 0))
                local item_pos = self.main_container:convertToNodeSpace(world_pos)
                local act_1 = cc.MoveTo:create(0.1, cc.p(item_pos.x+53.5, item_pos.y+53.5))
                local call_back = function (  )
                    self.move_skill_item:setVisible(false)
                    local new_jinqi_id = self.move_skill_item.jinqi_id
                    local old_jinqi_id = skill_item.jinqi_id
                    for k,v in pairs(self.chose_jinqi_list) do
                    	if sender and v.pos == sender.jinqi_pos then
                    		v.item_bid = old_jinqi_id or 0
                    	elseif v.pos == index and new_jinqi_id then
                    		v.item_bid = new_jinqi_id
                    	end
                    end
                    self:updateSkillList()
                    self.is_show_act = false
                end
                self.move_skill_item:runAction(cc.Sequence:create(act_1, cc.CallFunc:create(call_back)))
    			is_have = true
    		end
    		break
    	end
    end

    if not is_have then
    	self:onClickSkillItemEnd(sender)
    end
end

function RollerTalentMainTips:onClickSkillItemEnd(sender)
	if self.move_skill_item then
        self.is_show_act = true
        local world_pos = sender:convertToWorldSpace(cc.p(0, 0))
        local target_pos = self.main_container:convertToNodeSpace(world_pos) 
        local act_1 = cc.MoveTo:create(0.1, cc.p(target_pos.x+53.5, target_pos.y+53.5))
        local call_back = function (  )
            self.move_skill_item:setVisible(false)
            self:updateSkillList()
            self.is_show_act = false
        end
        self.move_skill_item:runAction(cc.Sequence:create(act_1, cc.CallFunc:create(call_back)))
    end
end

-- 根据位置获取对应禁器的id
function RollerTalentMainTips:getJinqiBidByPos( pos )
    if not self.chose_jinqi_list then return end
    local jinqi_id = 0
    for k,v in pairs(self.chose_jinqi_list) do
        if v.pos == pos then
            jinqi_id = v.item_bid
            break
        end
    end
    return jinqi_id
end

function RollerTalentMainTips:close_callback(  )
	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end
	for k,item in pairs(self.jinqi_skill_list) do
		item:DeleteMe()
		item = nil
	end
	if self.move_skill_item then
		self.move_skill_item:DeleteMe()
		self.move_skill_item = nil
	end
	_controller:openJinqiFormWindow(false)
end