-- --------------------------------------------------------------------
-- (必填, 创建模块的人员)
-- @description: 禁器技能预览页面
-- --------------------------------------------------------------------
RollerUpstarPreviewWindow = RollerUpstarPreviewWindow or BaseClass(BaseView)

local controller = RollerController:getInstance()
local model = controller:getModel()

local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function RollerUpstarPreviewWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.strength_attr_list = {}
    self.strength_effect_list = {}
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("ninja_treasure/ninja_treasure", "ninja_treasure"), type = ResourcesType.plist},
	}
    self.layout_name = "roller/roller_upstar_preview_window"
end

function RollerUpstarPreviewWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.mainContainer = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.mainContainer , 1)

    self.close_btn = self.mainContainer:getChildByName("close_btn")
    self.img_title = self.mainContainer:getChildByName("img_title")
    self.title = self.mainContainer:getChildByName("title")
    self.title:setString(TI18N("语言_c_7206"))
    autoSizeTitleBg(self.title,  self.img_title, 140)
    
    self.plan_list = self.mainContainer:getChildByName("plan_list")
    if not self.base_list_view then
        local size = self.plan_list:getContentSize()
        local setting = {
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 5,                    -- 第一个单元的Y起点
            space_y = 5,                   -- y方向的间隔
            col = 1,                         -- 列数，作用于垂直滚动类型
            item_width = 640,               -- 单元的尺寸width
            item_height = 390,              -- 单元的尺寸height
            -- row = 1,                        -- 行数，作用于水平滚动类型
            need_dynamic = true
        }
        self.list_view = CommonScrollViewSingleLayout.new(self.plan_list, cc.p(size.width * 0.5, size.height * 0.5) , ScrollViewDir.vertical, ScrollViewStartPos.top, size, setting, cc.p(0.5,0.5))
        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
end
function RollerUpstarPreviewWindow:createNewCell(width, height)
    local cell = RollerUpstarPreviewItem.new()
    return cell
end
function RollerUpstarPreviewWindow:numberOfCells()
    if not self.star_list then return 0 end
    return #self.star_list
end
function RollerUpstarPreviewWindow:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.star_list[index]
    cell:setData(hero_vo)
end


function RollerUpstarPreviewWindow:register_event()
    registerButtonEventListener(self.background, function() self:_onClickBtnClose() end ,false, 2)
    registerButtonEventListener(self.close_btn, function() self:_onClickBtnClose() end ,true, 2) 
end

function RollerUpstarPreviewWindow:_onClickBtnClose()
    controller:openUpstarPreviewWindow(false)
end

function RollerUpstarPreviewWindow:openRootWnd(jinqi_id)
    self.roller_id = jinqi_id
    self.star_list = {}
    local cfg = Config.ProhibitedScrollData.data_get_proh_scroll_star[self.roller_id]
    for k, v in pairs(cfg) do
        table.insert(self.star_list, v)
    end
    local sort_func = SortTools.tableCommonSorter({{"lev", false}})
    table_sort(self.star_list, sort_func)
    self.list_view:reloadData()
end

function RollerUpstarPreviewWindow:close_callback()
    if self.list_view then
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    controller:openUpstarPreviewWindow(false)
end