local log_dir='ect/log'
if not fs.exists(log_dir) then
	fs.makeDir(log_dir)
end
local function append(s,line)
	local f=fs.open(s,'a')
	f.writeLine(msg)
	f.close()
end
log.storelogger=function(module,severity,msg)
	append(log_dir..'/'..'log.log',msg)
	append(log_dir..'/'..module..'.log',msg)
end