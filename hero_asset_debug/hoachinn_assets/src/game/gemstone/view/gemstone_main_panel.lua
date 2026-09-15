----------------------------
-- @Description:宝石羁绊主界面
----------------------------
GemstoneMainPanel = class( "GemstoneMainPanel",
    function()
        return ccui.Widget:create()
    end
)

local controller = GemstoneController:getInstance()
local model = controller:getModel()
local hero_controller = HeroController:getInstance()
local hero_model = hero_controller:getModel()

function GemstoneMainPanel:ctor(hero_vo)
    self.hero_vo = hero_vo
    self.panel_list = {}
    self.tab_list = {}
    self.click_index = 0
    self:loadResources()
    if model:getGemStoneRed() then
        ActionController:getInstance():sender16809(ActionStorageBool.gemStoneRed, 1 ,"")
    end
end
function GemstoneMainPanel:loadResources()
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("gem", "gem"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("gem", "gem_bg_01"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("gem", "gem_bg_02"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("gem", "gem_bg_03"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("gem", "gem_bg_04"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("gem", "gem_bigbg_01"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("gem", "gem_bigbg_02"), type = ResourcesType.single},
    }
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(
        self.res_list,
        function()
            if self.configUI then
                self:configUI()
            end
            if self.register_event then
                self:register_event()
            end
        end
    )
end

function GemstoneMainPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("gemstone/gemstone_main_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.container_size = self.main_container:getContentSize()
    self.title_panel = self.root_wnd:getChildByName("title_panel")
    self.title_txt_list = {
        [1] = TI18N("语言_c_7114"),
        [2] = TI18N("语言_c_7124"),
    }
    for i = 1, #self.title_txt_list do
        local list = {}
        list.btn = self.title_panel:getChildByName("title_"..i)
        list.unclick_bg = list.btn:getChildByName("unclick_bg")
        list.click_bg = list.btn:getChildByName("click_bg")
        list.title = list.btn:getChildByName("title")
        list.title:setString(self.title_txt_list[i])
        list.red_point = list.btn:getChildByName("red_point")
        list.red_point:setVisible(false)
        self.tab_list[i] = list
    end
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)

    local tab_y = self.title_panel:getPositionY()
    self.title_panel:setPositionY(top_y - (self.container_size.height - tab_y))
    self:setData()
end

function GemstoneMainPanel:updatePageData(hero_vo)
    self.hero_vo = hero_vo
    self.click_index = 0
    self:setData()
end
function GemstoneMainPanel:setData()
    self:changeTabType(1)
    for i=1, #self.tab_list do
        self:updateTabRed(i)
    end
end
function GemstoneMainPanel:updateTabRed(index)
    local status = false
    if index == 1 then
        status = model:getGemEquipRed(self.hero_vo.partner_id) or model:getGemStrengRed(self.hero_vo.partner_id)
    elseif index == 2 then
        status = model:getGemArtifactRed() or ActionController:getInstance():getModel():getLucklyTabRedPoint(ActionTreasureType.Gemstone)
    end
    self.tab_list[index].red_point:setVisible(status)
end
function GemstoneMainPanel:register_event()
    for index, tab_btn in ipairs(self.tab_list) do
        registerButtonEventListener(tab_btn.btn, function() self:changeTabType(index) end ,false, 1)
    end
    if self.update_hero_info == nil then
        self.update_hero_info = GlobalEvent:getInstance():Bind(GemstoneEvent.Update_Hero_Info, function(pid)
            if pid == self.hero_vo.partner_id then
                self:updateTabRed(1)
            end
        end)
    end
    if self.artifact_lucky_event == nil then
        self.artifact_lucky_event = GlobalEvent:getInstance():Bind(GemstoneEvent.Artifact_Lucky_Event, function()
            self:updateTabRed(2)
        end)
    end
end

function GemstoneMainPanel:changeTabType(index)
    if index == 0 then index = 1 end
    if self.click_index == index then return end
    self.click_index = index
    for i = 1, 2 do
        if i == index then
            self.tab_list[i].click_bg:setVisible(true)
            self.tab_list[i].unclick_bg:setVisible(false)
        else
            self.tab_list[i].click_bg:setVisible(false)
            self.tab_list[i].unclick_bg:setVisible(true)
        end
    end
    if self.select_panel then
		self.select_panel:addToParent(false)
		self.select_panel = nil
	end
	self.select_panel = self.panel_list[index]
	if self.select_panel == nil then
		if index == 1 then
			self.select_panel = GemstoneEquipPanel.new(self.hero_vo)
		elseif index == 2 then
			self.select_panel = GemstoneSmeltPanel.new(self.hero_vo)
		end
		if self.select_panel then
			self.main_container:addChild(self.select_panel)
			self.panel_list[index] = self.select_panel
		end
    else
        self.select_panel:updatePageData(self.hero_vo)
	end
	if self.select_panel then
		self.select_panel:addToParent(true)
	end
end

function GemstoneMainPanel:DeleteMe()
    for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
	if self.update_hero_info then
        GlobalEvent:getInstance():UnBind(self.update_hero_info)
        self.update_hero_info = nil
    end
	if self.artifact_lucky_event then
        GlobalEvent:getInstance():UnBind(self.artifact_lucky_event)
        self.artifact_lucky_event = nil
    end
    self.panel_list = nil
end