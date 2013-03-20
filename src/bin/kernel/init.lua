
---one patch
rawset(_G,'loadfile',function( _sFile )
	local file = fs.open( _sFile, "r" )
	if file then
		local func, err = loadstring( file.readAll(),_sFile)
		file.close()
		return func, err
	end
	return nil, "File not found"
end)

---set up of _INSTALL_PATH and module resolution
_FILE_PATH=({...})[1]
local loc=(_FILE_PATH:match'(.*)bin/kernel/init%.lua'):sub(1,-2)
rawset(_G,'_INSTALL_PATH',loc)
os.loadAPI(fs.combine(_INSTALL_PATH,'bin/kernel/loadreq/init.lua'))
rawset(_G,'loadreq',_G['init.lua'])
rawset(_G,'init.lua',nil)
rawset(_G,'require',loadreq.require)
rawset(_G,'include',loadreq.include)
loadreq.vars.paths=loadreq.vars.paths:gsub('%?',fs.combine(_INSTALL_PATH,'bin')..'/%?')..';'..loadreq.vars.paths

---patches
local string=string

local rawset, rawget,type=rawset, rawget,type

local nativegetmetatable=getmetatable
rawset(_G,'getmetatable',nil)
local function getmetatable(t)
	if type(t)=='string' then
		return string
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
---


--global modules and utilities
rawset(_G,'log',require'kernel.log')
require'kernel.log.store'

local globals={
	stringify=require'utils.stringify'.stringify,
	dprint=require'utils.stringify'.dprint,
	read=require'utils.tab_read',
	pprint=function(this,max_level)
		print(stringify(this,docol, spacing_h, spacing_v, preindent,max_level))
	end,
	net=require'kernel.net',
	util=require'kernel.util',
	sched=require'kernel.sched',
	log=require'kernel.log',
}

for i,v in pairs(require'kernel.class') do
	globals[i]=v
end

for i,v in pairs(globals) do
	rawset(_G,i,v)
end

