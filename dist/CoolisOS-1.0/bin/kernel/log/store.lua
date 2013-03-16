local e='ect/log'
if not fs.exists(e)then
fs.makeDir(e)
end
local function a(e,t)
local e=fs.open(e,'a')
e.writeLine(msg)
e.close()
end
log.storelogger=function(o,i,t)
a(e..'/'..'log.log',t)
a(e..'/'..o..'.log',t)
end