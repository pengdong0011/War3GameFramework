local fs = require 'bee.filesystem'
local registry_ok, registry = pcall(require, 'bee.registry')

-- KKWE 安装目录(从 YDWE fork 而来, 命令行参数与 ydwe.exe 完全一致)
-- 若你的 KKWE 装在其他位置, 修改这里即可
local KKWE_DIR = 'E:/kk/Editor/KKWE'

local function is_valid(dir)
    return dir ~= nil and fs.exists(fs.path(dir) / 'KKWE.exe')
end

local function from_registry()
    if not registry_ok then
        return nil
    end
    local ok, command = pcall(function()
        return (registry.open [[HKEY_CURRENT_USER\SOFTWARE\Classes\YDWEMap\shell\run_war3\command]])['']
    end)
    if not ok or not command then
        return nil
    end
    local f, l = command:find('"[^"]*"')
    if not f then
        return nil
    end
    return fs.path(command:sub(f + 1, l - 1)):remove_filename()
end

-- 优先使用注册表关联的 YDWE, 否则回退到 KKWE
local dir = from_registry()
if not dir or not fs.exists(dir / 'ydwe.exe') then
    if is_valid(KKWE_DIR) then
        return fs.path(KKWE_DIR)
    end
    print('未找到 YDWE/KKWE, 请在 tools/ydwe.lua 中设置 KKWE_DIR')
    return false
end
return dir
