--------------------------------------------
-- 
-- 
---------------------------------
local _controller = RollerController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

RollerUpstarPreviewItem = class("RollerUpstarPreviewItem", function()
    return ccui.Widget:create()
end)

RollerUpstarPreviewItem.Width = 640
RollerUpstarPreviewItem.Height = 390

function RollerUpstarPreviewItem:ctor()
    self.star_list = {}
    self:configUI()
	self:register_event()
end

function RollerUpstarPreviewItem:configUI(  )
	self.size = cc.size(RollerUpstarPreviewItem.Width, RollerUpstarPreviewItem.Height)
	self:setContentSize(self.size)
	self:setAnchorPoint(cc.p(0.5, 0))

	local csbPath = PathTool.getTargetCSB("roller/roller_upstar_preview_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.item = self.root_wnd:getChildByName("item")

	self.main_container = self.root_wnd:getChildByName("main_container")
    self.up_panel = self.main_container:getChildByName("up_panel")
    self.list_bg2 = self.up_panel:getChildByName("list_bg2")
    self.list_bg2:setVisible(false)
    self.current_img = self.up_panel:getChildByName("current_img")
    self.current_img:setVisible(false)
    self.current_txt = self.up_panel:getChildByName("current_txt")
    self.current_txt:setString(TI18N("语言_c_1294"))
    self.current_txt:setVisible(false)

    self.equip_img = self.up_panel:getChildByName("equip_img")
    self.star_layer = self.up_panel:getChildByName("star_layer")
    -- for i=1,5 do 
    --     local star = self.star_layer:getChildByName("star_"..i)
    --     table.insert(self.star_list,star)
    -- end
    self.equip_name = self.up_panel:getChildByName("equip_name")
    local left_tips_icon = self.up_panel:getChildByName("left_tips_icon")
    local tips1 = self.up_panel:getChildByName("tips1")
    tips1:setString(TI18N("语言_c_7207"))
    local right_tips_icon = self.up_panel:getChildByName("right_tips_icon")
    setLeftRightImg(left_tips_icon, tips1, right_tips_icon, 20)

    self.type_icon = self.up_panel:getChildByName("type_icon")
    self.type_txt = self.up_panel:getChildByName("type_txt")
    self.skill_node = self.up_panel:getChildByName("skill_node")
    if not self.skill_item then
        self.skill_item = SkillItem.new(true, true, true, 0.7, true)
        local res = PathTool.getResFrame("ninja_treasure", "ninja_treasure_37")
        local img2 = createImage(self.skill_item, res, 5,109, cc.p(0.5, 0.5), true)
        img2:setScale(1.35)
        self.skill_item.lv_bg = img2
        local lv = createLabel(24, cc.c4b(0xfe, 0xff, 0x80, 0xff), cc.c4b(0x1e, 0x04, 0x00, 0xff), 13, 18, nil,self.skill_item.lv_bg,1,cc.p(0.5, 0.5))
        self.skill_item.lv = lv
        self.skill_node:addChild(self.skill_item)
    end
    self.up_img = self.skill_node:getChildByName("arrow_img")
    self.up_img:setLocalZOrder(99)

    self.skill_name = self.up_panel:getChildByName("skill_name")
    self.skill_lv = self.up_panel:getChildByName("skill_lv")

    self.plan_list = self.up_panel:getChildByName("list")
    if not self.base_list_view then
        local size = self.plan_list:getContentSize()
        local setting = {
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 5,                   -- y方向的间隔
            col = 1,                         -- 列数，作用于垂直滚动类型
            item_width = 400,               -- 单元的尺寸width
            item_height = 32,              -- 单元的尺寸height
            -- row = 1,                        -- 行数，作用于水平滚动类型
            need_dynamic = true
        }
        self.list_view = CommonScrollViewSingleLayout.new(self.plan_list, cc.p(size.width * 0.5, size.height * 0.5) , ScrollViewDir.vertical, ScrollViewStartPos.top, size, setting, cc.p(0.5,0.5))
        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.list_view:setClickEnabled(false)
    end
end
function RollerUpstarPreviewItem:createNewCell(width, height)
    local cell = RollerTalentAttrOverviewItemItem.new()
    return cell
end
function RollerUpstarPreviewItem:numberOfCells()
    if not self.star_list_data then return 0 end
    return #self.star_list_data
end
function RollerUpstarPreviewItem:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.star_list_data[index]
    cell:setExtralData(self.item)
    cell:setData(hero_vo)
    if index%2 == 0 then
        cell:hideBg(true)
    else
        cell:hideBg(false)
    end
end

function RollerUpstarPreviewItem:register_event()
end

function RollerUpstarPreviewItem:setData(data)
    -- [0] = {id=1101, lev=0, attr={{'hp_max',1683},{'atk',140}}, passive_skill={731021}, cost={{131001,50}}, award={{45,10}}},
	if not data then return end
	self.data = data

	local basecfg = Config.ProhibitedScrollData.data_get_proh_scroll[data.id]

	local pic_info = basecfg.show[1]
	if pic_info then
		if pic_info[1] == 1 then
			local res = PathTool.getRollerIcon(pic_info[2],2)
			loadSpriteTexture(self.equip_img, res, LOADTEXT_TYPE)
		elseif pic_info[1] == 2 then
			local eff_id = pic_info[2]
			if not self.icon_eff_1 then
				self.icon_eff = createEffectSpine( eff_id, cc.p(0, 0), cc.p(0.5, 0.5), true, "action")
				self.equip_img:addChild(self.icon_eff)
			end
		end
	end
    local num = 20
    if judgingLanguage() then
        num = 10
    end
    self.type_txt:setString(transformTextToShort(basecfg.pos_text,num))
    addEvt2showAllTextTips(self.type_txt, basecfg.pos_text,num)
    local res = PathTool.getPlistImgForDownLoad("prohibitor/prohibitor_setting", basecfg.pos_icon)
    self.type_icon:loadTexture(res,LOADTEXT_TYPE)
    local roller_data = _model:getRollerDataById(data.id)
    if roller_data then
        local now_star = roller_data.star
        if now_star == data.lev then
            self.list_bg2:setVisible(true)
            self.current_img:setVisible(true)
            self.current_txt:setVisible(true)
        else
            self.list_bg2:setVisible(false)
            self.current_img:setVisible(false)
            self.current_txt:setVisible(false)
        end
    else
        self.list_bg2:setVisible(false)
        self.current_img:setVisible(false)
        self.current_txt:setVisible(false)
    end

    local max_star = _model:getMaxStarById(data.id)
    self:setStarPanel(data.lev,max_star)
    self.equip_name:setString(string.format(TI18N("语言_c_6876"),data.lev))

    local star_arrow_cfg = Config.ProhibitedScrollData.data_get_constant["star_arrow"].val
    local is_show = false
    for i, v in ipairs(star_arrow_cfg) do
        if v == data.lev then
            is_show = true
            break
        end
    end
    if is_show then
        self.up_img:setVisible(true)
    else
        self.up_img:setVisible(false)
    end
    -- if not table.indexof(star_arrow_cfg,data.lev) then
    --     self.skill_item.up_img:setVisible(false)
    -- else
    --     self.skill_item.up_img:setVisible(true)
    -- end

    if data.show and next(data.show) then
        local show = data.show[1]
        local action = show[1]
        if self.icon_eff then
            self.icon_eff:setAnimation(0, action, true)
        end
    end

    local quality = basecfg.quality
    local star_cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[data.id][data.lev]
    --基础属性
    local star_attr = star_cfg.attr
    local _arr = {}
    for k, v in pairs(star_attr) do
        local key = v[1]
        local num = v[2]
        if _arr[key] then
            _arr[key] = _arr[key] + num
        else
            _arr[key] = num
        end
    end
    self.star_list_data = {}
    for i, v in pairs(_arr) do
        local key_id = Config.AttrData.data_key_to_id[i] or Config.AttrExtraData.data_key_to_id[i]
        local object = {i,v,key_id}
        table.insert(self.star_list_data,object)
    end
    local function sortFunc( objA, objB )
        return objA[3] < objB[3]
    end
    table.sort(self.star_list_data, sortFunc)
    self.list_view:reloadData()

	local old_skill = data.passive_skill[1]
    local skill_cfg = Config.SkillData.data_get_skill(old_skill)
	self.skill_item:setData(skill_cfg)
	self.skill_item.lv:setString(skill_cfg.level)
    self.skill_name:setString(skill_cfg.name)
    self.skill_lv:setString(string.format(TI18N("语言_c_4712"),skill_cfg.level))
end

function RollerUpstarPreviewItem:setStarPanel(star,max_star)
    if not next(self.star_list) then
        self.star_list = createOnlyStar(max_star,self.star_layer,20)
    end
    for i, v in ipairs(self.star_list) do
        setChildUnEnabled(true, v)
        if i <= star then
            setChildUnEnabled(false, v)
        end
    end
    -- local max_width = max_star * 29 + (max_star-1)*3
    -- local total_width = 160
    -- local start_x = 1.5+(160-max_width)/2 + 29/2
    -- for i, v in ipairs(self.star_list) do
    --     if i <= max_star then
    --         v:setVisible(true)
    --     else
    --         v:setVisible(false)
    --     end
    --     v:setPositionX(start_x + (i-1)*29)
    -- end
    -- for i, v in ipairs(self.star_list) do
    --     setChildUnEnabled(true, v)
    --     if i <= star then
    --         setChildUnEnabled(false, v)
    --     end
    -- end
end

function RollerUpstarPreviewItem:DeleteMe()
    if self.icon_eff then
        self.icon_eff:removeFromParent()
        self.icon_eff = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end

-------------------@ item
RollerTalentAttrOverviewItemItem = class("RollerTalentAttrOverviewItemItem",function()
    return ccui.Widget:create()
end)

function RollerTalentAttrOverviewItemItem:ctor()
end

function RollerTalentAttrOverviewItemItem:setExtralData(node)
    if not tolua.isnull(node) and self.root_wnd == nil then
		self.is_completed = true
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)

		self.root_wnd = node:clone()
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5)
		self:addChild(self.root_wnd)
		self.root_wnd:setVisible(true)

        self.item_bg = self.root_wnd:getChildByName("item_bg")
        self.attr_icon = self.root_wnd:getChildByName("attr_icon")
        self.attr_icon:ignoreContentAdaptWithSize(true)
        self.attr_name = self.root_wnd:getChildByName("attr_name")
        self.attr_val = self.root_wnd:getChildByName("attr_val")
	end
end

function RollerTalentAttrOverviewItemItem:setData(data)
    -- print(vardump(data))
    -- [10] = {level=10, attrs={{'hp_max',1683},{'atk',140}}},
    if not data then
        return
    end
    local next_res, next_attr_name, next_attr_val = commonGetAttrInfoByKeyValue(data[1],data[2])
    self.attr_icon:loadTexture(next_res, LOADTEXT_TYPE_PLIST)
    self.attr_name:setString(next_attr_name)
    self.attr_val:setString(next_attr_val)
end

function RollerTalentAttrOverviewItemItem:hideBg(status)
    self.item_bg:setVisible(status)
end

function RollerTalentAttrOverviewItemItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end
