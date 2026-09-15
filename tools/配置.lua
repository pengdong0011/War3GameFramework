local fs = require 'bee.filesystem'
local ydwe = require 'tools.ydwe'
local subprocess = require 'bee.subprocess'


if not ydwe then
    return
end
print('Platform:', ydwe:string())
-- YDWE 为 bin/ydweconfig.exe, KKWE 为 bin/YDWEConfig.exe
local cfg = ydwe / 'bin' / 'ydweconfig.exe'
if not fs.exists(cfg) then
    cfg = ydwe / 'bin' / 'YDWEConfig.exe'
end
subprocess.spawn {
    cfg
}
