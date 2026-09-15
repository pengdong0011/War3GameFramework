local jass = require "jass.common"
local japi = require "jass.japi"
local slk = require "jass.slk"
local message = require "jass.message"
local console = require "jass.console"

local std_print = print
function print(...) std_print(('[%.3f]'):format(os.clock()), ...) end

-- 使用框架的基础代码(这行代码本来是放在Gameplay.GameplayEntry的)
require "Gameframework.GameframeworkEntry"

-- 后续使用全局变量Yuyuko,Types和Events完成游戏逻辑即可

--#region 框架自检(可随时删除)
local function SelfTest()
    local player = Types.Player[1]

    local function Check(name, fn)
        local ok, err = pcall(fn)
        local line = string.format('[SelfTest] %-22s %s', name,
            ok and 'OK' or ('FAIL: ' .. tostring(err)))
        print(line)
        player:SendMsg(ok and ('|cFF1CE6B9' .. line .. '|r')
            or ('|cFFFF0303' .. line .. '|r'))
        return ok
    end

    player:SendMsg('|cFFFFFC01[War3GameFramework] 框架已加载|r')
    print('[SelfTest] player =', player._Name, '| frame =', Yuyuko.Time.FrameCount())

    Check('计时器', function()
        local t = jass.CreateTimer()
        jass.TimerStart(t, 1, false, function() print('[SelfTest] 1秒定时回调') end)
    end)

    Check('创建单位', function()
        local x = jass.GetStartLocationX(0) + 200
        local y = jass.GetStartLocationY(0) + 200
        local unit = Types.Unit.Create(player, 1751543663, x, y, 270)
        assert(unit, 'CreateUnit 返回 nil')
        print('[SelfTest] 单位:', unit._Name, 'ID:', unit._ID)
    end)

    Check('漂浮文字', function()
        local x = jass.GetStartLocationX(0) - 200
        local y = jass.GetStartLocationY(0) - 200
        Types.TextTag.Create('框架OK', Types.Point.Create(x, y, 0),
            { red = 255, green = 220, blue = 0, alpha = 255 }, 5)
    end)

    Check('SLK读取', function()
        local id = Yuyuko.ResourceManager.GetUnitIDByName('步兵')
        print('[SelfTest] 步兵ID:', id)
    end)

    -- RSA 加密/解密
    Check('RSA加解密', function()
        local Rsa = require 'Gameframework.Utils.Rsa'
        local plain = '123456789'
        local cipher = Rsa.encrypt(plain)
        local back = Rsa.decrypt(cipher)
        print('[SelfTest] 明文=' .. plain .. ' 密文=' .. cipher)
        assert(back == plain, '解密不符, 得到: ' .. tostring(back))
    end)

    -- RSA 签名(热补丁防篡改所用)
    Check('RSA签名', function()
        local Rsa = require 'Gameframework.Utils.Rsa'
        local content = 'hotfix-content-demo'
        local sign = Rsa.get_sign(content)
        print('[SelfTest] 签名=' .. tostring(sign))
        assert(Rsa.check_sign(content, sign), '签名校验未通过')
        assert(not Rsa.check_sign(content .. 'x', sign), '篡改后仍通过, 签名无效')
    end)

    -- 事件系统: 进游戏后按回车输入任意内容, 看控制台是否打印
    Check('聊天事件', function()
        Yuyuko.EventManager.Subscribe(Events.War3PlayerChatEventArgs.EventID,
            function()
                local msg = jass.GetEventPlayerChatString()
                local p = Types.Player.GetTriggerPlayer()
                print('[SelfTest] 收到聊天:', p._Name, '=>', msg)
                p:SendMsg('|cFFFFFC01事件系统正常|r 你说的是: ' .. msg)
            end)
    end)
end

local initTimer = jass.CreateTimer()
jass.TimerStart(initTimer, 0.5, false, SelfTest)
--#endregion
