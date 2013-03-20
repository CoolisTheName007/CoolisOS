local log_dir=fs.combine(_INSTALL_PATH,fs.combine('ect','log'))
if not fs.exists(log_dir) then
	fs.makeDir(log_dir)
end
local function append(s,line)
	local f=fs.open(s,'a')
	f.writeLine(msg)
	f.close()
end
log.storelogger=function(module,severity,msg)
	append(fs.combine(log_dir,'log.log'),msg)
	append(fs.combine(log_dir,module..'.log'),msg)
end