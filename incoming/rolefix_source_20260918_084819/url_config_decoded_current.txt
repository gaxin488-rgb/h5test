UPDATE_TRY_VERSION_MAX = 70
UPDATE_VERSION_MAX = 70

-- if MAIN_VERSION < 102  then
-- 	return
-- end

VerPath = {
}
VerMergePath = {
}
----------------------- 公共函数 ----------
CDN_URL = "http://192.168.1.234:86"
--CDN_URL2 = "http://192.168.1.234:86"
CDN_URL2 = "http://192.168.1.234:86"
CDN_RES_URL = CDN_URL .. "/update/update_allres"
CDN_RES_GY_URL = CDN_URL .. "/update/update_allres"
REG_URL = "http://192.168.1.234:81" 
DOWN_APK_URL = "http://192.168.1.234:82/index.php/ChannelBag/bag"
ZIP_URL = "http://192.168.1.234:81/update/config/sszg/update/"
NEED_CHECK_CLOSE=true -- 客户端检查维护状态
RESOURCES_DOWNLOAD_PRO      = 3                    -- 用于边玩边下闲时下载进程数
RESOURCES_DOWNLOAD_PRO_MAX  = 5
VER_UPDATE_ERR_MAX  = 2000
-- --------------------------------------------------+
-- 非打包热更新处理
-- @author whjing2011@gmail.com
-- --------------------------------------------------*/

-- urlConfig加载完成调用 
function webFunc_urlConfigEnd()
end

-- 加载模块完成 初始化instance调用开始时调用 
function webFunc_initInstanceStart()
end

-- 加载模块完成 初始化instance调用完成时调用 
function webFunc_initInstanceEnd()
end

-- 游戏开时完毕时调用 
function webFunc_GameStart()
end


CDN_PATH_BASE = CDN_URL.."/update/update_android_sszg/zip/"
UPDATE_MODE_BY_INC = true
INC_VER_DOWNLOAD_PRO_MAX = 8
--PLATFORM_NAME               = "dev"
--FINAL_CHANNEL               = "dev"
PLATFORM_NAME               = "local"
FINAL_CHANNEL               = "local"


SHOW_BAIDU_TIEBA            = false                  -- 是否显示百度贴吧
SHOW_SINGLE_INVICODE        = false                  -- 是否显示个人推荐码
SHOW_BIND_PHONE             = false                  -- 是否需要显示手机绑定界面
SHOW_WECHAT_CERTIFY         = false                  -- 是否显示微信公众号
SHOW_GAME_SHARE             = false                  -- 是否显示游戏分享
SHOW_GM                     = false
AUTO_SHOW_NOTICE            = true
SHOW_NOTICE                 = true
DEBUG_MODE                  = false

URL_PATH_ALL = {}
URL_PATH_ALL.other = {   
--update = CDN_URL.."/update/update_android_sszg_apk",
 update = CDN_URL.."/update/update_android_sszg/zip",
    -- update = ZIP_URL,
    register = CDN_URL
	-- register = REG_URL
}
URL_PATH_ALL.get = function(platform)
    local data = URL_PATH_ALL[platform] or URL_PATH_ALL["other"]
    return data
end

function get_servers_url(account, platform, channelid, srvid, start, num)
  --[[
    function sdkOnPay(money, buyNum, prodId, productName, productDesc)

		    local roleVo = RoleController:getInstance():getRoleVo()
			local charge_sum = VipController:getInstance():getChargeSum()
            local gold_acc = roleVo.gold_acc
			local gold_acc12 = 64800 - charge_sum
		    if gold_acc12 < 0 then	
		     gold_acc12 = 0
		    end	
 
	    if charge_sum + money < 64800 then
           Send(10399, {msg="pay "..prodId})
            local str2 = string.format(TI18N('剩余%s肥宅快乐币'), gold_acc12/10)
			message(str2)	   
        else
            local str = string.format(TI18N('充值失败，剩余%s肥宅快乐币'), gold_acc12/10)
			message(str)
        end
--        Send(10399, {msg="pay "..prodId})
   end
   

     代码块  
--]] 
 --[[
   function sdkOnPay(money, buyNum, prodId, productName, productDesc)
    Send(10399, {msg="pay "..prodId})
	
	end
--]]	

function sdkOnPay(money, buyNum, prodId, productName, productDesc)
    -- 游客模式下,且非认证的用户,调用充值,会弹出认证确认面板,如果游客模式允许跳过则不判断,个别渠道允许跳过
--    if NEED_CHECK_VISITIOR_STATUS and DO_NOT_REALNAME_STATUS and (not ALLOW_SKIP_RECHARGE) then 
--        OPEN_SDK_VISITIOR_WINDOW = true
--        callFunc("touristMode", "10")
    if 1 > 2 then 
	   callFunc("touristMode", "10")
    else
        local loginData = LoginController:getInstance():getModel():getLoginData()
        local roleVo = RoleController:getInstance():getRoleVo()
        if not roleVo then return end
--        local productId = string.format("%s.%s", callFunc("package_name"), prodId)
		local productId = string.format("%s",  prodId)
        if PAY_ID_FUNC then
            productId = PAY_ID_FUNC(prodId, money)
        elseif PAY_ID_NORMAL then
            productId = prodId
        end
        local config = Config.ChargeData.data_charge_data[prodId]
        if config and config.val ~= money then return end
        productName = productName or (money * 10)..TI18N("钻石")
        productDesc = productDesc or productName
        local price = money
        if USE_RMB_FEN then
            price = money * 100
        end
        buyNum = buyNum or 1
        local srvData = loginData
        local channel = LoginPlatForm:getInstance():getChannel()
        local gold = roleVo.gold
        local platform, serverId = unpack(Split(roleVo.srv_id, "_"))
        local serverName = srvData.srv_name
        local roleId = roleVo.rid
        local srv_id = roleVo.srv_id		
        local roleName = roleVo.name
        local roleLev = roleVo.lev
        local vip = "vip"..roleVo.vip_lev
        local ext = roleVo.rid.."$$"..platform.."$$"..serverId.."$$"..channel.."$$"..prodId.."$$"..productName
--        local host = "cdn.local.sszg.yangsugame.com"
		local host = srvData.host
        local account_id = account
		--local account_id = LoginController:getInstance():getUId()
		
        local info = table.concat({productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host, channel, account_id}, "#")
        -- 冰鸟的英灵勇士充值的特殊处理
        if IS_IOS_PLATFORM == true and not MAKELIFEBETTER and FINAL_CHANNEL == "bingniao_bnylys" and ICEBIRD_USERID then
				local str = string.format( TI18N("Bạn có chắc chắn nạp tiền?"),  roleName)
		        CommonAlert.show( str, TI18N("Xác nhận"), function()
			    iceBirdOnPay(productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host,srv_id,money,account_id)
    	        end, TI18N("Hủy"))
           -- iceBirdOnPay(productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host,srv_id,money,account_id)
			--RoleController:getInstance():requestThirdCharge(prodId, host, info,roleId,account_id ,srv_id)
        else
          --  local info = table.concat({productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host, channel, account_id}, "#")
            if (IS_IOS_PLATFORM == true and FINAL_CHANNEL == "syios_sszgzssx") or (FINAL_CHANNEL == "release2") then   -- 如果是正式包,可能存在第三方
                --RoleController:getInstance():requestThirdCharge(prodId, host, info,roleId,account_id,srv_id)
			    local str = string.format( TI18N("Bạn có chắc chắn nạp tiền?"),  roleName)
		        CommonAlert.show( str, TI18N("Xác nhận"), function()
			    iceBirdOnPay(productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host,srv_id,money,account_id)
    	        end, TI18N("Hủy"))
				--iceBirdOnPay(productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host,srv_id,money,account_id)
            else
                if IS_SY_DAN then
                    --sdkCallFunc("dan", info)
					--RoleController:getInstance():requestThirdCharge(prodId, host, info,roleId,account_id,srv_id)
				local str = string.format( TI18N("Bạn có chắc chắn nạp tiền?"),  roleName)
		        CommonAlert.show( str, TI18N("Xác nhận"), function()
			    iceBirdOnPay(productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host,srv_id,money,account_id)
    	        end, TI18N("Hủy"))
				--	iceBirdOnPay(productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host,srv_id,money,account_id)
                else
                   -- sdkCallFunc("pay", info)
					--RoleController:getInstance():requestThirdCharge(prodId, host, info,roleId,account_id,srv_id)
				--	iceBirdOnPay(productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host,srv_id,money,account_id)
								local str = string.format( TI18N("Bạn có chắc chắn nạp tiền?"),  roleName)
		        CommonAlert.show( str, TI18N("Xác nhận"), function()
			    iceBirdOnPay(productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host,srv_id,money,account_id)
    	        end, TI18N("Hủy"))
                end
            end
        end
    end
end
      --local srvid = roleVo.gold_acc
--  return string.format("%s/index.php/server/lists2?account=%s&platform=%s&chanleId=%s&srvid=%s&start=%s&num=%s", URL_PATH.register, account, platform, channelid or '', srvid or '', start or 0, num or 0)
   return string.format("%s/api/role.php?account=%s&platform=%s&chanleId=%s&srvid=%s", URL_PATH.register, account, platform, DEF_CHANNEL or 'dev', srvid)
end

function get_notice_url(days, loginData)
	local host = REAL_LOGIN_DATA and REAL_LOGIN_DATA.host or loginData.host
    return string.format("http://192.168.1.234:81/gonggao.php", host, os.time())
end

require("cli_log")
