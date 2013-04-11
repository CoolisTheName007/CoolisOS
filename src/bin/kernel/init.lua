


function dump(s)
	local f=fs.open('dump','a')
	f.writeLine(s)
	f.close()
end

local path=shell.getRunningProgram()
local function override(f)
local t={}
local fo=printError
local key='printError'
local co=coroutine.status
local wrapped=function(s)
	coroutine.status=co
	for i,v in pairs(t) do
		rawset(v,key,fo)
	end
	local ok,err=pcall(f)
	if not ok then
		fo(err)
	end
end
for i=1,20 do
	local ok,err=pcall(getfenv,i)
	if ok then
		if rawget(err,key)~=nil and not t[err] then
			t[i]=err
			rawset(err,key,wrapped)
		end
	end
end
coroutine.status=nil
repeat
	os.pullEvent()
until false
end


local function fixes()
	local string=string
	local rawset, rawget,type=rawset, rawget,type
	local nativegetmetatable=getmetatable
	local s_meta=getfenv(('').sub)
	rawset(_G,'getmetatable',nil)
	local function getmetatable(t)
		if type(t)=='string' then
			return s_meta
		else
			return nativegetmetatable(t)
		end
	end
	rawset(_G,'getmetatable',getmetatable)

	local nativesetmetatable = setmetatable
	rawset(_G,'setmetatable',nil)
	local function setmetatable( _o, _t )
		if _t and type(_t) == "table" then
			local idx = rawget( _t, "__index" )
			local newidx=rawget( _t, "__newindex" )
			rawset(_t,"__index",nil)
			rawset(_t,"__newindex",nil)
			local r= nativesetmetatable( _o, _t )
			rawset(_t,"__index",idx)
			rawset(_t,"__newindex",newidx)
			local meta=getmetatable(_o)
			rawset(meta,"__index",idx)
			rawset(meta,"__newindex",newidx)
			return r
		else
			return nativesetmetatable( _o, _t )
		end
	end
	rawset(_G,'setmetatable',setmetatable)

	rawset(_G,'loadfile',function( _sFile )
		local file = fs.open( _sFile, "r" )
		if file then
			local func, err = loadstring( file.readAll(),_sFile)
			file.close()
			return func, err
		end
		return nil, "File not found"
	end)

end

local function start()
	debug.wrap(function()
	local v=require'utils.Vec3'
	local gui=require'kernel.gui'
    
	local terminal=gui.Terminal(_G.term,sched.platform)
    local shell=require'kernel.gui.shell'
	local Box=require'kernel.class.Box'
	Box{terminal=terminal}:run(shell.main)
	end)()
    sched.wait('end')
end

local main=function()
	--overrides
	fixes()
	
	---set install variables and module loading utilities
	do
	_FILE_PATH=path
	local loc=(_FILE_PATH:match'(.*)bin/kernel/init%.lua'):sub(1,-2)
	rawset(_G,'_INSTALL_PATH',loc)
	rawset(_G,'loadreq',dofile(fs.combine(_INSTALL_PATH,'bin/kernel/loadreq/init.lua')))
	rawset(_G,'require',loadreq.require)
	rawset(_G,'include',loadreq.include)
	loadreq.vars.paths=loadreq.vars.paths:gsub('%?',fs.combine(_INSTALL_PATH,'bin')..'/%?')..';'..loadreq.vars.paths..';'..loadreq.vars.paths:gsub('%?',_INSTALL_PATH..'/%?')
	end
	
	---load modules
	do
	rawset(_G,'log',require'kernel.log')
	log.store=require'kernel.log.store'
	log.store.reset()
    log.store.instant=true
	log.setLevel('INFO')
    do
	local serpent=require'utils.serpent'
	local globals={
		-- read=require'utils.tab_read',
        pstring=function(this,max_level) return serpent.serialize(this,{debug=true,indent = '  ', sortkeys = true, comment = true,maxlevel=max_level}) end,
		pprint=function(this,max_level)
			debug.step_print(pstring(this))
			-- print(stringify(this,docol, spacing_h, spacing_v, preindent,max_level))
		end,
		net=require'kernel.net',
		util=require'kernel.util',
		sched=require'kernel.sched',
		debug=require'kernel.debug',
		log=require'kernel.log',
	}
	for i,v in pairs(require'kernel.class') do
		globals[i]=v
	end
	for i,v in pairs(globals) do
		rawset(_G,i,v)
	end
	sched.pipe=require'kernel.sched.pipe'
	end
	
	
	--overrided to os
	do
    os.sleep(0)
	local o_os=os
    local check=require'kernel.checker'.check
	local os=util.shcopy(o_os)
	local function wrap(f,i,e)
		return function(...)
			local ir,fr=nil,nil
			if i then ir={i(...)} end
			fr={f(...)}
			if e then e(fr,ir) end
			return unpack(fr)
		end
	end
	os.version=function()
		return '1'
	end
	os.sleep=function(n) check('number',n) sched.wait(n) end
	rawset(_G,'sleep',os.sleep)
	os.pullEventRaw=function(filter)
		check('string',filter)
		if not sched.running then
			return o_os.pullEventRaw(filter)
		end
		
		local task=sched.running
		task._queue=task._queue or {}
		local q=task._queue
		while q[1] do
			local r=table.remove(q,1)
			if filter==nil or r[1]==filter then
				return unpack(r)
			end
		end
		repeat
			local r={sched.wait(sched.platform,filter or '*')}
			table.remove(r,1)
			if filter==nil or r[2]==filter then
				return unpack(r)
			else
				table.insert(q,r)
			end
		until false
	end
	os.pullEvent=function( _sFilter )
		local eventData = {os.pullEventRaw( _sFilter )}
		if eventData[1] == "terminate" then
			error("Terminated")
		end
		return unpack(eventData)
	end
	
	rawset(_G,'os',os)
	end
	end
	
	local f=function(s) return log('init','INFO','task:(%s) says:%s',tostring(sched.running),s) end
	sched.task(function()
        debug.wrap(start)()
	end):run()
	
	sched.loop()
	log.store.flush()
    print'Press any key to shutdown'
    util.wait(os.pullEvent,{'char','q'},'char')
	os.shutdown()
end

override(function()
	local ok,er=xpcall(main,function(msg,level)
		if _G.debug then
			return _G.debug.traceback(msg)
		else
			return msg
		end
	end)
	if not ok then
        if log then
            log('init','ERROR','%s',er)
        end
		if _G.debug then
			debug.printError(er)
		else
			printError(er)
		end
    end
end)