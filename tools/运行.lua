local fs = require 'bee.filesystem'
local ydwe = require 'tools.ydwe'
if not ydwe then
    return
end

local function list_dir(p)
    local out = {}
    if p.list_directory then
        for e in p:list_directory() do out[#out + 1] = e end
    else
        for e in fs.pairs(p) do out[#out + 1] = e end
    end
    return out
end

local function get_debugger()
    local path = fs.path(os.getenv('USERPROFILE')) / '.vscode' / 'extensions'
    if not fs.exists(path) then
        return nil
    end
    for _, extpath in ipairs(list_dir(path)) do
        if fs.is_directory(extpath) and extpath:filename():string():sub(1, 20) == 'actboy168.lua-debug-' then
            local dbgpath = extpath / 'windows' / 'x86' / 'debugger.dll'
            if fs.exists(dbgpath) then
                return dbgpath
            end
        end
    end
end

-- 地图文件名: 放在项目根目录的 .w3x (由 w3x2lni 从 map/ 打包生成)
local MAP_NAME = os.getenv('WGF_MAP') or 'MoeHero.w3x'

local root = fs.path(arg[1])
local map = root / MAP_NAME
if not fs.exists(map) then
    print('地图不存在', map:string())
    print('提示: 设置环境变量 WGF_MAP 指定地图文件名, 或先用 w3x2lni 打包 map/ 生成 .w3x')
    return
end
if get_debugger() then
    --command = command .. ' -debugger 4278'
end

-- 启动方式(YDWE/KKWE 同源, 见 Development/Core/YDWEConfig/Regedit.cpp):
--   编辑器: KKWE.exe -loadfile "xx.w3x"
--   进游戏: bin\YDWEConfig.exe -launchwar3 -loadfile "xx.w3x"
-- 注意 KKWE.exe 不认 -war3, 传错参数只会打开编辑器且不加载地图。
local cfg_name = fs.exists(ydwe / 'bin' / 'ydweconfig.exe') and 'ydweconfig.exe' or 'YDWEConfig.exe'
local cfg = ydwe / 'bin' / cfg_name
if not fs.exists(cfg) then
    print('未找到启动器', cfg:string())
    return
end

-- 用 cmd 的 start 让游戏脱离本脚本进程, 否则子进程会随本脚本退出而被结束
local cmd = string.format('start "" /d "%s" "%s" -launchwar3 -loadfile "%s"',
    (ydwe / 'bin'):string(), cfg:string(), map:string())
print('[Run]', cmd)
os.execute(cmd)
