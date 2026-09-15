--------------------------------------------
-- 
-- 
-- @Date    : 2019-01-16 19:09:44
-- @description    : 
		-- 宝石技能预览
---------------------------------

GemstonePreviewSkillWindow = GemstonePreviewSkillWindow or BaseClass(BaseView)

local _controller = GemstoneController:getInstance()

function GemstonePreviewSkillWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Mini  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.layout_name = "gemstone/gemstone_preview_skill_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("common", "common_2"), type = ResourcesType.plist},
    }
end

function GemstonePreviewSkillWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)
	local Image_17 = self.main_container:getChildByName("title_con"):getChildByName("Image_17")
    local title_label = self.main_container:getChildByName("title_con"):getChildByName("title_label")
	title_label:setChangeScaleOffWidth(-9999)
	title_label:setString(TI18N("语言_c_2287"))
	Image_17:setContentSize(cc.size(title_label:getContentSize().width + 100,63))
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.item = self.root_wnd:getChildByName("item")
    self.item_goods = self.main_container:getChildByName("goods")
    local setting = {
        start_x = 0, -- 第一个单元的X起点
        space_x = 0, -- x方向的间隔
        start_y = 5, -- 第一个单元的Y起点
        space_y = 5, -- y方向的间隔
        item_width = self.item:getContentSize().width, -- 单元的尺寸width
        item_height = self.item:getContentSize().height, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 2, -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(self.item_goods, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, self.item_goods:getContentSize(), setting)
    -- self.item_scrollview:setClickEnabled(false)
    self.item_scrollview:registerScriptHandlerSingle(handler(self, self.createTaskCell), ScrollViewFuncType.CreateNewCell) -- 创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfTaskCells), ScrollViewFuncType.NumberOfCells) -- 获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self, self.updateTaskCellByIndex), ScrollViewFuncType.UpdateCellByIndex) -- 更新cell
    
end

-- 奖励列表
function GemstonePreviewSkillWindow:createTaskCell()
    local cell = self.item:clone()
    cell.skill = SkillItem.new(true,true,true,0.9)
    cell:addChild(cell.skill)
    cell.skill:setPosition(64, cell:getContentSize().height*0.5)
    cell.name = cell:getChildByName("title")
    setTextMaxWidth(cell.name,150)
    cell.open_txt = createRichLabel(20,cc.c3b(0x64,0x32,0x23),cc.p(0,0),cc.p(130,8),-8,nil,150)
    cell:addChild(cell.open_txt)
    cell.open_bg = cell:getChildByName("open_bg")
    return cell
end

function GemstonePreviewSkillWindow:numberOfTaskCells()
    if not self.reward_list then
        return 0
    end
    return #self.reward_list
end

function GemstonePreviewSkillWindow:updateTaskCellByIndex(cell, index)
    if not self.reward_list then
        return
    end
    local cell_data = self.reward_list[index]
    if not cell_data then
        return
    end
    cell.skill:setData(cell_data)
    cell.name:setString(cell_data.name)
    if cell_data.need_lv and cell_data.need_lv ~= 0 then
        cell.open_txt:setString(string.format(TI18N("语言_c_7127"),cell_data.need_lv))
        cell.open_bg:setVisible(true)
        local _w = math.max(cell.open_txt:getContentSize().width+8,cell.open_bg:getContentSize().width)
        cell.open_bg:setContentSize(cc.size(_w,cell.open_txt:getContentSize().height+4))
    else
        cell.open_txt:setString("")
        cell.open_bg:setVisible(false)
    end
end

function GemstonePreviewSkillWindow:register_event(  )
	registerButtonEventListener(self.background, function()
        self:_onClickCloseBtn()
    end,false, 2)
    registerButtonEventListener(self.close_btn, function()
        self:_onClickCloseBtn()
    end,true, 2)
end

function GemstonePreviewSkillWindow:_onClickCloseBtn(  )
	_controller:openGemstonePreviewSkillWindow(false)
end


function GemstonePreviewSkillWindow:openRootWnd(item_id,type)
    self.type = type or 1
	self.reward_list = {}
    if self.type == 1 then
        local cfg = Config.PartnerGemData.data_base_info[item_id]
        if cfg and cfg.rand_skill and next(cfg.rand_skill) then
            for key, value in pairs(cfg.rand_skill) do
                local config = Config.PartnerGemData.data_skill[value]
                if config and next(config) then
                    for k, v in pairs(config) do
                        local skill_cfg = deepCopy(Config.SkillData.data_get_skill(v.skill_id))
                        if skill_cfg then
                            skill_cfg.need_lv = v.need_lv
                            table.insert(self.reward_list, skill_cfg)
                        end
                    end
                end
            end
        end
    else
        local cfg = Config.PartnerGemData.data_refresh[item_id]
        if cfg and cfg.skill and next(cfg.skill) then
            for key, value in pairs(cfg.skill) do
                local config = Config.PartnerGemData.data_skill[value]
                if config and next(config) then
                    for k, v in pairs(config) do
                        local skill_cfg = deepCopy(Config.SkillData.data_get_skill(v.skill_id))
                        if skill_cfg then
                            skill_cfg.need_lv = v.need_lv
                            table.insert(self.reward_list, skill_cfg)
                        end
                    end
                end
            end
        end
    end
    commonShowEmptyIcon(self.item_goods,not next(self.reward_list))
    table.sort(self.reward_list,function(a,b) return a.bid < b.bid end)
	self.item_scrollview:reloadData()
end

function GemstonePreviewSkillWindow:close_callback(  )
	if self.tab_view_list then
        for i,v in pairs(self.tab_view_list) do
            v:DeleteMe()
        end
        self.tab_view_list = nil
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
	self:_onClickCloseBtn()
end