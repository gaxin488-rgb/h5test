CommonAttrWindow = CommonAttrWindow or BaseClass(BaseView)

local _controller = RollerController:getInstance()

function CommonAttrWindow:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "common/common_attr_window"
    -- self.res_list = {
    --     { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    -- }
    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
	self.background_mask_enable = true
end

function CommonAttrWindow:open_callback(  )
	self._ui = getAllCsbExportChildren(self.root_wnd)
	self._ui._background:setScale(display.getMaxScale())
	self:playEnterAnimatianByObj(self._ui._mainContainer , 2) 
	self._ui._desc = createRichLabel(22, cc.c3b(0x7c,0x55,0x36), cc.p(0.5,0.5), cc.p(0,0), nil, nil, 630)
	self._ui._descParent:addChild(self._ui._desc)
	self._ui._desc:setString(TI18N("语言_c_7362"))
	self._ui._title:setString(TI18N("语言_c_1508"))
	autoSizeTitleBg(self._ui._title, self._ui._titleImage, 150)
	-- self._ui._titleImage:setContentSize(cc.size(self._ui._title:getContentSize().width + 120,self._ui._titleImage:getContentSize().height))
end

   
function CommonAttrWindow:register_event(  )
	registerButtonEventListener(self._ui._closeBtn, handler(self, self.close), true, 2)
	registerButtonEventListener(self._ui._background, handler(self, self.close), false, 2)
end


function CommonAttrWindow:close_callback(  )

	_controller:openCommonAttrWindow(false)
end


function CommonAttrWindow:openRootWnd(attrList,des_str,type)
	local des_str = des_str or TI18N("语言_c_7362")
	self._ui._desc:setString(des_str)
	local tMap = {}
	local arr = {}
	for k, v in pairs(attrList) do
		if not tMap[v[1]] then
			local id = Config.AttrData.data_key_to_id[v[1]]
			tMap[v[1]] = {v[1], 0, id or 0}
			table.insert(arr, tMap[v[1]])
		end
		tMap[v[1]][2] = tMap[v[1]][2] + v[2]
	end

	table.sort(arr, function (a, b)
		return a[3] < b[3]
	end)
	self._attrList = arr
	self:updateWindow(self._attrList,type)
end


function CommonAttrWindow:updateWindow(attrList,type)
	local ui = self._ui
	local type = type or ""
	for i =1, 10 do
		local attr = attrList[i]
		local attrNode = ui["_attr"..i]
		if attr then
			self._ui["_attr"..i]:setVisible(true)
			local res_id = PathTool.getAttrIconByStr(attr[1])
			local res = PathTool.getResFrame("common",res_id)
			loadSpriteTexture(attrNode:getChildByName("attrIcon"), res, LOADTEXT_TYPE_PLIST)
			local attrLabel = attrNode:getChildByName("attrLabel")
			local attr_add_name = ""
			if type == "Totem" then
				if attr[1] == "atk_per" or attr[1] == "hp_max_per" then
					attr_add_name = TI18N("语言_c_d_285")
				end
			end
			local attrName = attr_add_name ..Config.AttrData.data_key_to_name[attr[1]].." : "
			attrLabel:setTouchEnabled(true)
			transformTextToShortByWidth(attrLabel, attrName, 175)
			if attrLabel then
				addEvt2showAllTextTips(attrLabel,attrName, 10)
			end
			local value = attr[2]
			local is_per = PartnerCalculate.isShowPerByStr(attr[1])
			if is_per then
				value = (value/10).."%"
			end
			attrNode:getChildByName("attrValue"):setString("+"..value)
		else
			attrNode:setVisible(false)
		end
	end
end