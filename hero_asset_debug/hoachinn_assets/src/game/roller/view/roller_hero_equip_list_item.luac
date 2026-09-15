
-----------------------@ item
RollerHeroEquipListItem = class('RollerHeroEquipListItem',function()
	return ccui.Layout:create()
end)

function RollerHeroEquipListItem:ctor()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self:configUI()
	self:registerEvent()
end

function RollerHeroEquipListItem:configUI()
	self.size = cc.size(618, 141)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("roller/roller_hero_equip_list_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

	self.hero_node = self.root_wnd:getChildByName("hero_node")
	self.roller_node = self.root_wnd:getChildByName("roller_node")
	self.roller_item_node = self.roller_node:getChildByName("roller_item")
	self.roller_lock = self.roller_node:getChildByName("roller_lock")
	self.skill_node = self.root_wnd:getChildByName("skill_node")
	self.no_label = self.skill_node:getChildByName("no_label")
	self.no_label:setString(TI18N("语言_c_273"))
	self.no_label:setVisible(false)
	self.no_label:setLocalZOrder(9)

	self.lv_bg = self.root_wnd:getChildByName("lv_bg")
	self.label = self.root_wnd:getChildByName("label")
	self.label:setString("")
end

function RollerHeroEquipListItem:registerEvent()
	registerButtonEventListener(self.roller_lock, function() self:onClickRollerLockBtn() end ,true)
	registerButtonEventListener(self.roller_item_node, function() self:onClickRollerItem() end ,true)
end
-- 卷轴解锁
function RollerHeroEquipListItem:onClickRollerLockBtn()
    local open_star = Config.ProhibitedScrollData.data_get_constant["open_star_condition"].val
    if self.data.star < open_star then --星级未到
        message(string.format(TI18N("语言_c_6318"),open_star))
    else
        RollerController:getInstance():openRollerEquipLockWindow(true,self.data.bid,self.data.partner_id)
    end
end
function RollerHeroEquipListItem:onClickRollerItem()
	if self.data.prohibited_scroll and self.data.prohibited_scroll[1] and self.data.prohibited_scroll[1].scroll_id then
		local setting = {roller_id=self.data.prohibited_scroll[1].scroll_id,partner_id=self.data.partner_id,open_type=TRUE}
		RollerController:getInstance():openRollerChipTipsWindow(true, setting)
	else
		RollerController:getInstance():openRollerEquipListWindow(true,self.data.partner_id)
	end
end

function RollerHeroEquipListItem:setData(data)
	self.data = data
	self:updateHeroInfo()
	self:updateRollerInfo()
	self:updateRollerSkillInfo()
end
function RollerHeroEquipListItem:updateHeroInfo()
	if not self.hero_item then
		self.hero_item = HeroExhibitionItem.new(1, true)
        self.hero_node:addChild(self.hero_item )
        self.hero_item:addCallBack(function(_, data)
			LookController:getInstance():sender10352(self.role_vo.rid, self.role_vo.srv_id, self.data.bid)
			HeroController:getInstance():openHeroTipsPanel(true, self.data, {is_show_form_btn = true,is_self = true})
        end)
	end
	self.hero_item:setData(self.data)
	-- self.hero_item:showFightIcon(true)
	if self.data:isFormDrama() then
		self.hero_item:showFightImg(true)
	else
		self.hero_item:showFightImg(false)
	end
end
function RollerHeroEquipListItem:updateRollerInfo()
        local is_lock = self.data.dic_locks and self.data.dic_locks[11] or 0
        if is_lock == 1 then
            self.roller_lock:setVisible(false)
            self.roller_item_node:setVisible(true)
			local equip_red = HeroCalculate.checkSingleHeroHaveRollerEquipRedPoint(self.data)
			addRedPointToNodeByStatus(self.roller_node, equip_red, 45, 45)
        else
            self.roller_lock:setVisible(true)
            self.roller_item_node:setVisible(false)
            self:setStarCount(false)
			addRedPointToNodeByStatus(self.roller_node, false, 45, 45)
            local open_star = Config.ProhibitedScrollData.data_get_constant["open_star_condition"].val
            if self.data.star < open_star then --星级未到
                setChildUnEnabled(true,self.roller_lock)
                return
            else
                setChildUnEnabled(false,self.roller_lock)
            end
			local unluck_red = HeroCalculate.checkSingleHeroRollerRedPoint(self.data)
			addRedPointToNodeByStatus(self.roller_node, unluck_red, 45, 45)
            return
        end

        if not self.roller_mask then
            self.roller_mask = createSprite(PathTool.getResFrame("common_1", "common_1_511"), 45, 45, nil, cc.p(0.5, 0.5))--模板
            self.roller_mask:setScale(1.2)
        end
        if not self.roller_clipNode then
            self.roller_clipNode = cc.ClippingNode:create(self.roller_mask)
            self.roller_clipNode:setAnchorPoint(cc.p(0.5,0.5))
            self.roller_clipNode:setContentSize(cc.size(90,90))
            self.roller_clipNode:setCascadeOpacityEnabled(true)
            self.roller_clipNode:setPosition(45,45)
            self.roller_clipNode:setAlphaThreshold(0)
            self.roller_item_node:addChild(self.roller_clipNode)
        end

        if not self.roller_item then
            self.roller_item = RollerItem.new(false,1)
            self.roller_clipNode:addChild(self.roller_item)
            self.roller_item:setPosition(45,45)
        end

        if self.data.prohibited_scroll and self.data.prohibited_scroll[1] then
            local roller_id = self.data.prohibited_scroll[1].scroll_id
            if roller_id and roller_id ~= 0 then
                local obj = {id = roller_id,star=self.data.prohibited_scroll[1].scroll_star}
                self.roller_item:setData(obj)
                self.roller_item:hideExtralInfo()
                self.roller_item:hideStar()
                self:setStarCount(true, obj.star,roller_id)
            else
                self.roller_item:hideBackGround()
                self:setStarCount(false)
            end
        else
            self.roller_item:hideBackGround()
            self:setStarCount(false)
        end
        self.roller_item:setswTouchStatus(false)

end
function RollerHeroEquipListItem:updateRollerSkillInfo()
	if not self.skill_item then
		self.skill_item = SkillItem.new(true, true, true, 0.7)
		self.skill_node:addChild(self.skill_item)
	end
	if self.data.prohibited_scroll and self.data.prohibited_scroll[1] then
		local roller_id = self.data.prohibited_scroll[1].scroll_id
		if roller_id and roller_id ~= 0 then
			local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[roller_id]
			local roller_data =  RollerController:getInstance():getModel():getRollerDataById(roller_id)
			local star = roller_data.star
			local star_cfg = cfg[star]
			local skill_id = star_cfg.passive_skill[1]
			local skill_cfg = Config.SkillData.data_get_skill(skill_id)
			self.skill_item:setData(skill_cfg)
			self.skill_item:setTouchEnabled(true)
			self.label:setString(string.format(TI18N("语言_c_4712"), skill_cfg.level))
			self.no_label:setVisible(false)
		else
			self.skill_item:setData(nil)
			self.no_label:setVisible(true)
			self.label:setString("")
			self.skill_item:setTouchEnabled(false)
		end
	else
		self.skill_item:setData(nil)
		self.skill_item:setTouchEnabled(false)
		self.no_label:setVisible(true)
		self.label:setString("")
	end
end

function RollerHeroEquipListItem:setStarCount(status, count,roller_id)
	if self.equip_star_list then
		for i,v in ipairs(self.equip_star_list) do
			setChildUnEnabled(true, v)
            v:setVisible(false)
		end
	end

	if status then
		if self.equip_star_list == nil then
			self.equip_star_list = {}
		end

		local width = 12
	    local max_star = RollerController:getInstance():getModel():getMaxStarById(roller_id)
	    local x = 0 - max_star * width * 0.5 + width * 0.5
	    for i=1,max_star do
	        if not self.equip_star_list[i] then 
	        	local res = PathTool.getResFrame("common","common_90074")
	            local star = createImage(self.roller_node,res,0,0,cc.p(0.5,0.5),true,1,false)
	            star:setScale(0.8)
	            self.equip_star_list[i] = star
	        end
            self.equip_star_list[i]:setVisible(true)
			setChildUnEnabled(true, self.equip_star_list[i])
	        self.equip_star_list[i]:setPosition(x + (i-1) * width, -30)
	    end

		for i=1,count do
			setChildUnEnabled(false, self.equip_star_list[i])
		end
	end
end

function RollerHeroEquipListItem:DeleteMe()
	if self.card_load then
		self.card_load:DeleteMe()
		self.card_load = nil
	end
	for k,item in pairs(self.item_list) do
		item:DeleteMe()
		item = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end