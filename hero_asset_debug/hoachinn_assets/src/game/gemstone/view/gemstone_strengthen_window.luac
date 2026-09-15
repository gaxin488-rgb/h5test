--------------------------------------------
-- 
-- 
-- @Date    : 2019-01-16 19:09:44
-- @description    : 
		-- 宝石强化
---------------------------------

GemstoneStrengthenWindow = GemstoneStrengthenWindow or BaseClass(BaseView)

local controller = GemstoneController:getInstance()
local model = controller:getModel()

function GemstoneStrengthenWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Mini  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
	self.select_item_list={}
    self.next_lv_need_exp = 0 --下一等级需要的经验
    self.layout_name = "gemstone/gemstone_strengthen_window"
end

function GemstoneStrengthenWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 2)
	self.top_panel = self.main_panel:getChildByName("top_panel")
	self.left_icon = self.top_panel:getChildByName("left_icon")
	self.left_item = self.left_icon:getChildByName("left_item")
	self.left_star_con = ccui.Widget:create()
	self.left_star_con:setZOrder(3)
	self.left_star_con:setPosition(cc.p(59,10))
	self.left_star_con:setSwallowTouches(false)
	self.left_icon:addChild(self.left_star_con)
	self.left_pos = self.left_icon:getChildByName("left_pos")
	self.right_icon = self.top_panel:getChildByName("right_icon")
	self.right_item = self.right_icon:getChildByName("right_item")
	self.right_star_con = ccui.Widget:create()
	self.right_star_con:setZOrder(3)
	self.right_star_con:setPosition(cc.p(59,10))
	self.right_star_con:setSwallowTouches(false)
	self.right_icon:addChild(self.right_star_con)
	self.right_pos = self.right_icon:getChildByName("right_pos")
	self.bar_bg = self.top_panel:getChildByName("bar_bg")
	self.bar2 = self.top_panel:getChildByName("bar2")
	self.bar2:setScale9Enabled(true)
	self.bar2:setPercent(0)
	self.bar = self.top_panel:getChildByName("bar")
	self.bar:setScale9Enabled(true)
	self.exp_0 = self.top_panel:getChildByName("exp_0")
	self.exp_0:setString(TI18N("语言_c_7029"))
	self.exp = self.top_panel:getChildByName("exp")
	self.add_exp = self.top_panel:getChildByName("add_exp")
	self.add_exp:setString("")
	self.now_lv = self.top_panel:getChildByName("now_lv")
	self.next_lv = self.top_panel:getChildByName("next_lv")
	self.attr_panel = self.main_panel:getChildByName("attr_panel")
	self.base_panel = self.attr_panel:getChildByName("base_panel")
	self.base_title_bg = self.base_panel:getChildByName("base_title_bg")
	self.base_title_txt = self.base_panel:getChildByName("base_title_txt")
	self.base_title_txt:setString(TI18N("语言_c_1282"))
	self.base_scroll = self.base_panel:getChildByName("base_scroll")
	self.base_scroll:setScrollBarEnabled(false)
	self.strong_panel = self.attr_panel:getChildByName("strong_panel")
	self.strong_title_bg = self.strong_panel:getChildByName("strong_title_bg")
	self.strong_title_txt = self.strong_panel:getChildByName("strong_title_txt")
	self.strong_title_txt:setString(TI18N("语言_c_7141"))
	self.strong_scroll = self.strong_panel:getChildByName("strong_scroll")
	self.strong_scroll:setScrollBarEnabled(false)
	self.strong_scroll:setVisible(false)
	self.strong_no_txt = self.strong_panel:getChildByName("strong_no_txt")
	self.strong_no_txt:setString(TI18N("语言_c_6309"))
	self.strong_no_txt:setVisible(false)
	self.break_panel = self.main_panel:getChildByName("break_panel")
	self.break_list = self.break_panel:getChildByName("break_list")
	self.cost_panel = self.main_panel:getChildByName("cost_panel")
	self.tips1 = self.cost_panel:getChildByName("tips1")
	self.tips1:setString(TI18N("语言_c_6790"))
	self.plan_list = self.cost_panel:getChildByName("plan_list")
	self.Image_2 = self.main_panel:getChildByName("Image_2")
	self.title_txt = self.main_panel:getChildByName("title_txt")
	self.title_txt:setString(TI18N("语言_c_7142"))
	autoSizeTitleBg(self.title_txt,self.Image_2)
	self.close_btn = self.main_panel:getChildByName("close_btn")
	self.auto_add = self.main_panel:getChildByName("auto_add")
	self.auto_txt = self.auto_add:getChildByName("auto_txt")
	self.auto_txt:setString(TI18N("语言_c_2305"))
	self.streng_btn = self.main_panel:getChildByName("streng_btn")
	self.streng_txt = self.streng_btn:getChildByName("streng_txt")
	self.streng_txt:setString(TI18N("语言_c_4967"))
	self.break_btn = self.main_panel:getChildByName("break_btn")
	self.break_txt = self.break_btn:getChildByName("break_txt")
	self.break_txt:setString(TI18N("语言_c_7143"))
	self.max_tips = self.main_panel:getChildByName("max_tips")
	self.max_tips:setString(TI18N("语言_c_2176"))
	self.max_tips:setVisible(false)
    local posx = self.streng_btn:getPositionX()
    local posy = self.streng_btn:getPositionY()
    self.cost_gold = createRichLabel(20, cc.c4b(0x7c, 0x55, 0x36, 0xff), cc.p(0.5, 0.5), cc.p(posx,posy-50))
    self.main_panel:addChild(self.cost_gold)
end

function GemstoneStrengthenWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), true, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.break_btn, handler(self, self._onClickBreakBtn), true, 2,nil,nil,0.5)
	registerButtonEventListener(self.streng_btn, handler(self, self.onClickStrengthBtn), true, 2,nil,nil,0.5)
	registerButtonEventListener(self.auto_add, handler(self, self.setOneKeyData), true, 2)
	self:addGlobalEvent(GemstoneEvent.Update_Hero_Info, function ( pid)
    	if self.pid == pid then
			self.data = model:getOneGemstoneInfo(self.pid,self.pos)
			self.select_item_list={}
			self.next_lv_need_exp = 0 --下一等级需要的经验
			self.add_exp:setString("")
			self.bar2:setPercent(0)
			self.next_lev = nil
			self:setData()
			self:countTotalSelectExp()
		end
    end)
	self:addGlobalEvent(GemstoneEvent.Gem_Strong_Select_Event, function(data)
		local item_id = data.item_id
		local num = data.num
		self.select_item_list[item_id] = {item_id=item_id,num=num}
		self:countTotalSelectExp()
		self.item_scrollview:reloadData()
	end)
end

function GemstoneStrengthenWindow:_onClickCloseBtn(  )
	controller:openGemstoneStrengthenWindow(false)
end
function GemstoneStrengthenWindow:_onClickBreakBtn()
	for k, v in pairs(self.cell_data_list) do
		local item_id = v[1]
		local need_num = v[2]
		if not need_num then return end
		local have_num = BackpackController:getInstance():getModel():getItemNumByBid(item_id,BackPackConst.Bag_Code.GEMSTONE)
		if need_num > have_num then
			local cfg = Config.ItemData.data_get_data(item_id)
			BackpackController:getInstance():openTipsSource(true, cfg)
			return
		end
	end
	controller:sender22803(self.pid,self.pos)
end

function GemstoneStrengthenWindow:setOneKeyData()
    local select_data = {}
    local total_exp = self.max_need_exp - self.data.exp-- 到man级所需经验
    if total_exp <= 0 then
        message(TI18N("语言_c_6815"))
        return 
    end
    local need_exp = total_exp
    local cfg = deepCopy(Config.PartnerGemData.data_exp_info)
    local item_id_list = {}
	local _item_id_list = {}
    for k, v in pairs(cfg) do
        local item_id = v.id
        table.insert(item_id_list,item_id)
		table.insert(_item_id_list,{item_id})
    end
    table.sort(item_id_list, function(a, b) return b < a end)
	table.sort(_item_id_list, function(a, b) return a[1] < b[1] end)
	local status = true
	for k, v in ipairs(_item_id_list) do
		local own_num = BackpackController:getInstance():getModel():getItemNumByBid(v[1])
		if own_num > 0 then
			status = false
			break
		end
	end
	if status then
		BackpackController:getInstance():openTipsSource(true, _item_id_list[1][1])
		return
	end
    for k, v in ipairs(item_id_list) do
        local item_num = 0
        local item_id = v
        local add_exp = cfg[item_id].exp
        local own_num = BackpackController:getInstance():getModel():getItemNumByBid(item_id)
        if own_num > 0 then
            for i = 1, own_num, 1 do     
                if need_exp >= add_exp then
                    item_num = item_num + 1 
                    need_exp = need_exp - add_exp
                    select_data[item_id] = {item_id = item_id,num = item_num}
                else
                    break --换下一种道具
                end
            end
        end
    end
    -- --检查道具数量是否选够了
    local temp_exp = 0
    local left_item = {}
    for k, v in pairs(item_id_list) do
        local item_id = v
        local add_exp = cfg[item_id].exp
        local sels_num = 0
        if select_data[item_id] then
            sels_num = select_data[item_id].num
        end
        temp_exp = temp_exp + add_exp * sels_num
        local own_num = BackpackController:getInstance():getModel():getItemNumByBid(item_id)
        local _t = {}
        _t.item_id = item_id
        _t.left_num = own_num - sels_num
        left_item[item_id] = _t
    end
    local sele_data2 = {}
    local left_need_exp = total_exp - temp_exp
    if left_need_exp > 0 then --不够满级 用高价值道具补足
        table.sort(item_id_list, function(a, b) return a < b end)
        for k, v in pairs(item_id_list) do
            local item_id = v 
            local left_num = left_item[item_id].left_num
            if left_num > 0 then
                local item_num = 0
                local add_exp = cfg[item_id].exp
                local need_num = math.ceil(left_need_exp/add_exp)
                if left_num >= need_num then
                    sele_data2[item_id] = {item_id = item_id,num = need_num}
                    left_need_exp = left_need_exp - add_exp * need_num
                    break 
                else
                    left_need_exp = left_need_exp - add_exp * left_num
                    sele_data2[item_id] = {item_id = item_id,num = left_num}
                end
            end
        end
    end
    --数据整合
    local list = {}
    for k, v in pairs(item_id_list) do
        local item_id = v
        local _temp = {item_id = item_id,num = 0}
        if sele_data2[item_id] then
            _temp.num =  _temp.num + sele_data2[item_id].num
        end
        if select_data[item_id] then
            _temp.num =  _temp.num + select_data[item_id].num
        end
        table.insert(list,_temp)
    end
    table.sort(list, SortTools.KeyUpperSorter({"item_id"}))
    --检查是否大浪费
    local __exp = total_exp
    local cost_list = {}
    for k, v in pairs(list) do
        local item_id = v.item_id
        local num = v.num
        local add_exp = cfg[item_id].exp
        if __exp <= 0 then 
            break
        end
        local cost_exp = num * add_exp
        __exp = __exp - cost_exp
        table.insert(cost_list,{item_id = item_id,num = num})
    end
    local item_list = {}
    for k, v in pairs(cost_list) do
        local item_info = v
        if item_info.num > 0 then
            local a = {}
            a.item_id = item_info.item_id
            a.num = item_info.num
            item_list[a.item_id] = a
        end
    end
    table.sort(item_list, SortTools.KeyUpperSorter({"item_id"}))
    --print("item_list",vardump(item_list))
    self.select_item_list = item_list
    self:countTotalSelectExp()
end
-- 强化页面
function GemstoneStrengthenWindow:onClickStrengthBtn()
	if not self.add_exp_num then
		self.add_exp_num = 0
	end
    if self.add_exp_num <= self.max_need_exp then
        if next(self.select_item_list) then
            local xost_list = {}
            for k, v in pairs(self.select_item_list) do
				if v.num > 0 then
					local a = {}
					a.id = v.item_id
					a.num = v.num
					table.insert(xost_list,a)
				end
            end
			if next(xost_list) then
				controller:sender22802(self.pid, self.pos, xost_list)
			else
				message(TI18N("语言_c_6825"))
			end
        else
            message(TI18N("语言_c_6825"))
        end
    else
        local function fun()
            if next(self.select_item_list) then
                local xost_list = {}
                for k, v in pairs(self.select_item_list) do
					if v.num > 0 then
						local a = {}
						a.id = v.item_id
						a.num = v.num
						table.insert( xost_list,a)
					end
                end
				if next(xost_list) then
					controller:sender22802(self.pid, self.pos, xost_list)
				else
					message(TI18N("语言_c_6825"))
				end
            else
                message(TI18N("语言_c_6825"))
            end
        end
        local a = self.add_exp_num - self.max_need_exp
        local str = string.format(TI18N("语言_c_6804"),a)
        CommonAlert.show(str,TI18N("语言_c_63") , fun, TI18N("语言_c_62"), nil, CommonAlert.type.rich, nil, nil, nil, true)
    end
end
function GemstoneStrengthenWindow:updateBtnRed()
	local status = false
	if self.pid and self.pid ~= 0 and self.pos and self.pos ~= 0 then
		status = model:getGemStrengOneRed(self.pid,self.pos)
	end
	addRedPointToNodeByStatus(self.auto_add,status,10,10)
	addRedPointToNodeByStatus(self.streng_btn,status,10,10)
	addRedPointToNodeByStatus(self.break_btn,status,10,10)
end
--pid 忍者唯一id
--pos 槽位
function GemstoneStrengthenWindow:openRootWnd(setting)
	local setting = setting or {}
	self.pid = setting.pid or 0
	self.pos = setting.pos or 1
	self:setData()
end
function GemstoneStrengthenWindow:setData()
	self.data = model:getOneGemstoneInfo(self.pid,self.pos)
	if not self.left_gem_item then
		self.left_gem_item = BackPackItem.new(true,false)
		self.left_item:addChild(self.left_gem_item)
		self.left_gem_item:setData({self.data.item_bid,1})
		self.left_gem_item:showGemPos(false)
		self.left_gem_item:setEquipJie(false)
	end
	if not self.right_gem_item then
		self.right_gem_item = BackPackItem.new(true,false)
		self.right_item:addChild(self.right_gem_item)
		self.right_gem_item:setData({self.data.item_bid,1})
		self.right_gem_item:showGemPos(false)
		self.right_gem_item:setEquipJie(false)
	end
	if not self.data or not next(self.data) then return end
	local break_cfg = Config.PartnerGemData.data_break[self.pos]
	if break_cfg then
		self.break_cfg = break_cfg[self.data.break_num]
		self.next_break_cfg = break_cfg[self.data.break_num + 1]
	end
	local cfg = Config.PartnerGemData.data_lv_info[self.pos]
	self.now_lev = self.data.lv
	self.max_level = self.break_cfg.enchant_max_lev
	if not self.next_lev then
		self.next_lev = self.data.lv + 1
		if self.next_lev > self.max_level then
			self.next_lev = self.data.lv
		end
	end
	if cfg then
		self.now_cfg = cfg[self.now_lev]
		self.next_cfg = cfg[self.next_lev]
	end
	self.max_need_exp = 0
	for k, v in ipairs(cfg or {}) do
		if v.lv >= self.data.lv and v.lv < self.max_level then
			self.max_need_exp = self.max_need_exp + v.exp
		end
	end
	--道具列表
    self.cell_data_list = {}
    self.cost_id_list = {}
    local exp_cfg = Config.PartnerGemData.data_exp_info
    for k, v in pairs(exp_cfg) do
        local a = deepCopy(v)
        a.max_lv = self.max_level
        a.max_exp = self.max_need_exp
		a.heve_exp = self.data.exp
        table.insert(self.cell_data_list,a)
        table.insert(self.cost_id_list,v.id)
    end
    local sort_func = SortTools.tableCommonSorter({{"exp", false}})
    table.sort(self.cell_data_list,sort_func)
	if not self.break_cfg or not next(self.break_cfg) then return end
	if self.data.lv >= self.break_cfg.enchant_max_lev and self.next_break_cfg then
		self.streng_break = 2 --突破
		self.break_panel:setVisible(true)
		self.cost_panel:setVisible(false)
		self:updateBreakPanel()
		self.auto_add:setVisible(false)
		self.streng_btn:setVisible(false)
		self.break_btn:setVisible(true)
		self.max_tips:setVisible(false)
		self.title_txt:setString(TI18N("语言_c_7171"))
		autoSizeTitleBg(self.title_txt,self.Image_2)
	else
		self.title_txt:setString(TI18N("语言_c_7142"))
		autoSizeTitleBg(self.title_txt,self.Image_2)
		if self.next_cfg.lv > self.now_cfg.lv then
			self.streng_break = 1 --强化
			self.break_panel:setVisible(false)
			self.cost_panel:setVisible(true)
			self:updateCostPanel()
			self.auto_add:setVisible(true)
			self.streng_btn:setVisible(true)
			self.break_btn:setVisible(false)
			self.max_tips:setVisible(false)
		else
			self.streng_break = 3 --满级
			self.break_panel:setVisible(false)
			self.cost_panel:setVisible(true)
			self:updateCostPanel()
			self.auto_add:setVisible(false)
			self.streng_btn:setVisible(false)
			self.break_btn:setVisible(false)
			self.max_tips:setVisible(true)
		end
	end

	self:updateTopPanel()
	self:updateAttrPanel()
	self:updateStrengPanel()
	self:updateBtnRed()
end
--刷新顶部区域 icon 进度条
function GemstoneStrengthenWindow:updateTopPanel()
	self.left_pos:setString(StringUtil.numToRoman(self.pos).." ")
	self.right_pos:setString(StringUtil.numToRoman(self.pos).." ")
	if not self.now_cfg then return end
	if self.streng_break ~= 1 then --满级/突破
		self.right_icon:setVisible(false)
		self.left_icon:setPositionX(325)
		self.next_lv:setVisible(false)
		self.now_lv:setPositionX(325)
		self.next_lv:setString(TI18N("语言_c_7028"))
		self.exp:setString(TI18N("语言_c_7028"))
		self.bar:setPercent(100)
		self.bar:setVisible(false)
		self.bar2:setVisible(true)
		self.bar2:setPercent(100)
	else
        self.next_lv_need_exp = self.now_cfg.exp
		self.right_icon:setVisible(true)
		self.left_icon:setPositionX(162)
		self.next_lv:setVisible(true)
		self.now_lv:setPositionX(162)
		self.right_icon.star_setting = model:createStar(self.next_cfg.star,self.right_star_con,self.right_icon.star_setting)
		self.next_lv:setString(string.format(TI18N("语言_c_4520"), self.next_lev))
        if self.add_exp_num and self.max_need_exp and self.add_exp_num >= self.max_need_exp then
            self.next_lv:setString(string.format(TI18N("语言_c_7026"), self.next_lev))
		end
		self.exp:setString(string.format("%s/%s", self.data.exp,self.now_cfg.exp))
		self.bar:setPercent(self.data.exp/self.now_cfg.exp*100)
		self.bar:setVisible(true)
	end
	self.left_icon.star_setting = model:createStar(self.now_cfg.star,self.left_star_con,self.left_icon.star_setting)
	self.now_lv:setString(string.format(TI18N("语言_c_4520"), self.now_lev))
end

--刷新属性
function GemstoneStrengthenWindow:updateAttrPanel()
	if not self.now_cfg then return end
	if not self.attr_item_list then
		self.attr_item_list = {}
	end
	for i,v in pairs(self.attr_item_list) do
		v:removeFromParent()
		v=nil
	end
	self.attr_item_list = {}
	local atr_list = {}
	if self.streng_break == 1 or self.streng_break == 3 then --强化/满级
		for i,v in ipairs(self.now_cfg.attr) do
			local a = deepCopy(v)
			table.insert(atr_list,a)
		end
		if self.next_cfg then
			for key,value in ipairs(self.next_cfg.attr) do
				local status = true
				for k,v in ipairs(atr_list) do
					if value[1] == v[1] then
						atr_list[k][3] = value[2]
						status = false
					end
				end
				if status then
					table.insert(atr_list,{value[1],0,value[2]})
				end
			end
		end
	else --突破
		for i,v in ipairs(self.break_cfg.attr) do
			local a = deepCopy(v)
			for key,value in ipairs(self.now_cfg.attr) do
				if a[1] == value[1] then
					a[2] = a[2] + value[2]
				end
			end
			table.insert(atr_list,a)
		end
		if self.next_break_cfg then
			for key,value in ipairs(self.next_break_cfg.attr) do
				local status = true
				for k,v in ipairs(atr_list) do
					if value[1] == v[1] then
						atr_list[k][3] = value[2]
						for _k,_v in ipairs(self.now_cfg.attr) do
							if value[1] == _v[1] then
								atr_list[k][3] = value[2] + _v[2]
							end
						end
						status = false
					end
				end
				if status then
					local num = 0
					for _k,_v in ipairs(self.now_cfg.attr) do
						if value[1] == _v[1] then
							num = _v[2]
						end
					end
					table.insert(atr_list,{value[1],num,value[2]+num})
				end
			end
			table.insert(atr_list,{"lv_max",self.break_cfg.enchant_max_lev,self.next_break_cfg.enchant_max_lev})
		else
			table.insert(atr_list,{"lv_max",self.break_cfg.enchant_max_lev})
		end
	end
	local _h = math.max(self.base_scroll:getContentSize().height,tableLen(atr_list)*40)
	self.base_scroll:setInnerContainerSize(cc.size(self.base_scroll:getContentSize().width,_h))
	if tableLen(atr_list) >= 4 then
		self.base_scroll:setTouchEnabled(true)
	else
		self.base_scroll:setTouchEnabled(false)
	end
	for i,v in ipairs(atr_list) do
		local item = ccui.Layout:create()
		item:setContentSize(cc.size(self.base_scroll:getContentSize().width,40))
		item:setAnchorPoint(cc.p(0,0))
		item:setPosition(cc.p(0,_h-i*40))
		self.base_scroll:addChild(item)
		table.insert(self.attr_item_list,item)
		--属性背景
		if i%2 == 0 then
			item.bg = createImage(item,PathTool.getResFrame("common", "common_90018"),0,0,cc.p(0,0),true,nil,true)
			item.bg:setContentSize(cc.size(self.base_scroll:getContentSize().width,40))
		end
		--属性图标
		if PathTool.AttrIcon[v[1]] then
			local res = PathTool.getResFrame("common", PathTool.getAttrIconByStr(v[1]))
			item.icon = createSprite(res,25,20,item,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
		end
		--属性名称
		local attr_name = Config.AttrData.data_key_to_name[v[1]]
		if not attr_name then
			attr_name = Config.AttrExtraData.data_key_to_name[v[1]]
		end
		local name_x = 55
		if v[1] == "lv_max" then
			attr_name = TI18N("语言_c_6824")
			name_x = 10
		end
		local num = 20
		if judgingLanguage() then
			num = 10
		end
		item.name = createLabel(22,cc.c3b(0x7c,0x55,0x36),nil,name_x,20,transformTextToShort(attr_name,num)..":",item,nil,cc.p(0,0.5))
		addEvt2showAllTextTips(item.name,attr_name,num,nil,nil,nil,nil,true)
		local is_per = PartnerCalculate.isShowPerByStr(v[1])-- 是否为千分比
		local value = v[2]
		if is_per then
			value = (value/10).."%"
		end
		if v[3] then --未满级
			--当前属性
			item.num = createLabel(22,cc.c3b(0x7c,0x55,0x36),nil,300,20,value,item,nil,cc.p(0,0.5))
			--箭头
			item.icon = createSprite(PathTool.getResFrame("common", "common_1001"),400,20,item,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
			item.icon:setRotation(-90)
			--下级属性
			local _value = v[3]
			if is_per then
				_value = (_value/10).."%"
			end
			item.num = createLabel(22,cc.c3b(0x0e,0xa8,0x0e),nil,500,20,_value,item,nil,cc.p(0,0.5))
		else --已满级
			--当前属性
			item.num = createLabel(22,cc.c3b(0x7c,0x55,0x36),nil,300,20,value,item,nil,cc.p(0,0.5))
		end
	end
end

--刷新强化属性
function GemstoneStrengthenWindow:updateStrengPanel()
	if not self.streng_item_list then
		self.streng_item_list = {}
	end
	for i,v in pairs(self.streng_item_list) do
		v:removeFromParent()
		v=nil
	end
	self.streng_item_list = {}
	local skill_list = {}
	local cfg = Config.PartnerGemData.data_skill
	for i,v in pairs(self.data.item_skill) do
		local desc = ""
		local need_lv = 0
		local status = false
		local skill_cfg = Config.SkillData.data_get_skill(v.skill_id)
		if skill_cfg then
			desc = skill_cfg.des
		end
		if cfg[v.lib] and cfg[v.lib][v.skill_id] then
			if cfg[v.lib][v.skill_id].desc and cfg[v.lib][v.skill_id].desc ~= "" then
				desc = cfg[v.lib][v.skill_id].desc
			end
			need_lv = cfg[v.lib][v.skill_id].need_lv
			status = self.data.lv >= need_lv
		end
		if desc ~= "" then
			table.insert(skill_list,{desc=desc,need_lv=need_lv,status=status})
		end
	end
	table.sort(skill_list,function(a,b) return a.need_lv < b.need_lv end)
	if next(skill_list) then
		self.strong_scroll:setVisible(true)
		self.strong_no_txt:setVisible(false)
		-- local _h = math.max(self.base_scroll:getContentSize().height,tableLen(atr_list)*40)
		-- self.base_scroll:setInnerContainerSize(cc.size(self.base_scroll:getContentSize().width,_h))
		local _h = 0
		for i,v in ipairs(skill_list) do
			local item = ccui.Layout:create()
			item:setAnchorPoint(cc.p(0,1))
			self.strong_scroll:addChild(item)
			local item_h = 0
			local res = ""
			local txt = ""
			if v.status then
				res = PathTool.getResFrame("common", "common_1043")
				if v.need_lv ~= 0 then
					txt = "<div fontcolor=#7c5536>%s</div><div fontcolor=#0ea80e>(%s)</div>"
				else
					txt = "<div fontcolor=#7c5536>%s</div>"
				end
			else
				res = PathTool.getResFrame("common", "common_90009_1")
				if v.need_lv ~= 0 then
					txt = "<div fontcolor=#7c5536>%s</div><div fontcolor=#ff1515>(%s)</div>"
				else
					txt = "<div fontcolor=#7c5536>%s</div>"
				end
			end
			item.icon = createSprite(res,20,20,item,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
			item.desc = createRichLabel(22,cc.c3b(0x7c,0x55,0x36),cc.p(0,1),cc.p(50,50),-4,nil,580)
			item:addChild(item.desc)			
			if v.need_lv ~= 0 then
				item.desc:setString(string.format(txt,v.desc,string.format(TI18N("语言_c_7156"),v.need_lv)))
			else
				item.desc:setString(string.format(txt,v.desc))
			end
			item_h = math.max(50,item.desc:getContentSize().height+5)
			item.icon:setPositionY(item_h - 20)
			item.desc:setPositionY(item_h-2)
			item:setContentSize(cc.size(self.strong_scroll:getContentSize().width,item_h))
			_h = _h + item_h
			table.insert(self.streng_item_list,item)
		end
		_h = math.max(_h,self.strong_scroll:getContentSize().height)
		self.strong_scroll:setInnerContainerSize(cc.size(self.strong_scroll:getContentSize().width,_h))
		for i,v in ipairs(self.streng_item_list) do
			v:setPositionY(_h)
			_h = _h - v:getContentSize().height
		end
	else
		self.strong_scroll:setVisible(false)
		self.strong_no_txt:setVisible(true)
	end
end

function GemstoneStrengthenWindow:createNewCell2(width, height)
    local cell = CostItem.new()
    return cell
end
 --获取数据数量
function GemstoneStrengthenWindow:numberOfCells2()
    if not self.cell_data_list then return 0 end
    return #self.cell_data_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function GemstoneStrengthenWindow:updateCellByIndex2(cell, index)
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end
--突破
function GemstoneStrengthenWindow:updateBreakPanel()
	local break_cfg = Config.PartnerGemData.data_break
	if break_cfg and break_cfg[self.data.pos] and break_cfg[self.data.pos][self.data.break_num] then
		self.cell_data_list = break_cfg[self.data.pos][self.data.break_num].cost
		if self.break_scrollview == nil then
			local scroll_view_size = self.break_list:getContentSize()
			local setting = {
				start_x = 0, -- 第一个单元的X起点
				space_x = 10, -- x方向的间隔
				start_y = 0, -- 第一个单元的Y起点
				space_y = 0, -- y方向的间隔
				item_width = 130, -- 单元的尺寸width
				item_height = 155, -- 单元的尺寸height
				row = 1, -- 行数，作用于水平滚动类型
				col = 4, -- 列数，作用于垂直滚动类型s
				once_num = 1 -- 每次创建的数量
			}
			self.break_scrollview = CommonScrollViewSingleLayout.new(self.break_list, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))
			self.break_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell2), ScrollViewFuncType.CreateNewCell) --创建cell
			self.break_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells2), ScrollViewFuncType.NumberOfCells) --获取数量
			self.break_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex2), ScrollViewFuncType.UpdateCellByIndex) --更新cell
		end
		
        self.break_scrollview:reloadData()
	end
end
--强化
function GemstoneStrengthenWindow:updateCostPanel()
	if self.item_scrollview == nil then
        local scroll_view_size = self.plan_list:getContentSize()
        local setting = {
            start_x = 0, -- 第一个单元的X起点
            space_x = 10, -- x方向的间隔
            start_y = 0, -- 第一个单元的Y起点
            space_y = 0, -- y方向的间隔
            item_width = 130, -- 单元的尺寸width
            item_height = 155, -- 单元的尺寸height
            row = 1, -- 行数，作用于水平滚动类型
            once_num = 1 -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.plan_list, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell) -- 创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells) -- 获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) -- 更新cell
    end
    self.item_scrollview:reloadData()
end

function GemstoneStrengthenWindow:createNewCell(width, height)
    local cell = GemstoneStrengthenItem.new()
    cell:addCallBack(function()
        self:onCellTouched(cell)
    end)
    return cell
end

function GemstoneStrengthenWindow:numberOfCells()
    if not self.cell_data_list then
        return 0
    end
    return #self.cell_data_list
end
-- 更新cell(拖动的时候.刷新数据时候会执行次方法)
-- cell :createNewCell的返回的对象
-- index :数据的索引
function GemstoneStrengthenWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then
        return
    end
    cell:setData(cell_data)
    cell:setExtend(self.select_item_list,self.data)
end
function GemstoneStrengthenWindow:onCellTouched(cell)
    local data = cell:getSendData()
    local item_id = data.item_id
    self.select_item_list[item_id] = data
    self:countTotalSelectExp()
end
function GemstoneStrengthenWindow:countTotalSelectExp()
    local total_exp = 0
    for k, v in pairs(self.select_item_list) do
       local cfg = Config.PartnerGemData.data_exp_info[v.item_id]
       local exp = cfg.exp
       total_exp = exp * v.num + total_exp
    end
    self.add_exp_num = total_exp
    if total_exp == 0 then
        self.add_exp:setString("")
        self.cost_gold:setString("")
        local now_lv = self.data.lv
        local next_key = now_lv + 1
		if next_key > self.max_level then
			next_key = now_lv
		end
        local cfg = Config.PartnerGemData.data_lv_info[self.pos]
		self.now_cfg = cfg[now_lv]
		self.next_cfg = cfg[next_key]
        if self.streng_break ~= 1 then -- 满级/突破
            self.now_lv:setString(string.format(TI18N("语言_c_4520"), now_lv))--("Lv" .. now_lv)
            self.next_lv:setString(string.format(TI18N("语言_c_4520"), (now_lv + 1)))--("Lv" .. (now_lv + 1))
            -- local need_exp = self.now_cfg.exp
			local need_exp = 0
            self.exp:setString(string.format(TI18N("语言_c_7025"), self.data.exp, need_exp))--(exp .. "/" .. need_exp)
            self.bar:setPercent(self.data.exp / need_exp * 100)
            self.bar:loadTexture(PathTool.getResFrame("common_2","goldeqm_4"),LOADTEXT_TYPE_PLIST)
            self.bar:setScale9Enabled(true)
            self.bar2:setPercent(self.data.exp / need_exp * 100)
			self.next_lev = next_key
			self:setData()
		else
			self:setData()
        end
    else
        if total_exp > self.max_need_exp - self.data.exp then
            total_exp = self.max_need_exp - self.data.exp
        end
        self.add_exp_num = total_exp + self.data.exp
        self.add_exp:setString(string.format(TI18N("语言_c_7027"), total_exp))--("EXP+"..total_exp)
        local xishu = Config.PartnerGemData.data_constant.gold_require.val
        local co_id =  Config.PartnerGemData.data_constant.gold_id.val
        local cost_gold = xishu / 1000 * total_exp 
        local own_num = BackpackController:getInstance():getModel():getItemNumByBid(co_id)
        local str = "<img src=\'resource/item/%s.png\' scale=0.3 /><div fontcolor=#7C5536>%s/%s</div>"
        if own_num >= cost_gold then
            str = "<img src=\'resource/item/%s.png\' scale=0.3 /><div fontcolor=#26952f>%s/%s</div>"
        else
            str = "<img src=\'resource/item/%s.png\' scale=0.3 /><div fontcolor=#FF1515>%s/%s</div>"
        end
        self.cost_gold:setString(string.format(str, co_id,cost_gold,own_num))

         --实时计算一下升级结果
        if self.add_exp_num >= self.next_lv_need_exp then
            self.bar2:setPercent(100)
        else
            self.bar2:setPercent((self.add_exp_num)/self.next_lv_need_exp*100)
        end
        --到达的等级
        local _temp_num = self.add_exp_num
        _temp_num = _temp_num
        local final_lv = self.data.lv
        local add_num = 0
		for k, v in ipairs(Config.PartnerGemData.data_lv_info[self.pos]) do
			if v.lv >= final_lv and v.lv < self.max_level then
				add_num = add_num + v.exp
				if add_num <= _temp_num then
					final_lv = v.lv
				else
					break
				end
			end
		end
        --到达的属性
        self.next_lev = math.min(final_lv + 1,self.break_cfg.enchant_max_lev)
		self:setData()

    end
end
function GemstoneStrengthenWindow:close_callback(  )
	if self.break_scrollview then
        self.break_scrollview:DeleteMe()
        self.break_scrollview = nil
    end
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
	for i,v in pairs(self.attr_item_list) do
		v:removeFromParent()
		v=nil
	end
	self.attr_item_list = {}
	self:_onClickCloseBtn()
end