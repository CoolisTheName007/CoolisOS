local store={}
local log_dir=fs.combine(_INSTALL_PATH,'ect/log')
if not fs.exists(log_dir) then
	fs.makeDir(log_dir)
end


local his={}

local function flush_file(s)
    local f=fs.open(s,'a')
    for i,v in pairs(his[s]) do
        f.writeLine(v)
    end
    f.close()
    his[s]=nil
end

function store.flush(module)
	if not module then
		for s,t in pairs(util.shcopy(his)) do
			flush_file(s)
		end
	else
		local s=fs.combine(log_dir,module..'.log')
		flush_file(s)
	end
end

store.instant=false
function store.append(module,msg)
    local s=fs.combine(log_dir,module..'.log')
	his[s]=his[s] or {}
	table.insert(his[s],msg)
	if store.instant==true then
		flush_file(s)
	end
end

function store.reset(module)
	if module then
		fs.open(fs.combine(log_dir,module..'.log'),'w').close()
	else
		fs.delete(log_dir)
		fs.makeDir(log_dir)
	end
end
log.storelogger=function(module,severity,msg)
	store.append(module,msg)
	store.append('log',msg)
end
return store