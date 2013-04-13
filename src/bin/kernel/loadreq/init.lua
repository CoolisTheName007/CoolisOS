---require implementation in pure Lua for a sandbox environment, with support for globs and full directory tree search.
--Licensed under the MIT license, whatever that is.


local fs=fs
local string=string
local loadfile=loadfile
local error=error
local function log(...)
	return (_G.log and _G.log(...))
end

function getNameExpansion(s) --returns name and expansion from a filepath @s; special cases: ''->'',nil; '.'-> '','';
	local _,_,name,expa=string.find(s, '([^%./\\]*)%.(.*)$')
	return name or s,expa
end

function getDir(s) --returns directory from filepath @s
	return string.match(s,'^(.*)/') or '/'
end

vars={} --to allow edition
--vars.loaded={}
--function loadFile(path,_reload) --@_reload forces reload
--	if (vars.loaded[path]==nil) or _reload then
--		local fnFile, err = loadfile( path )
--		if not fnFile then error('load:'..'path=:'..path..'| '..(err or 'nil'),2) end
--		vars.loaded[path]=fnFile
--	end
--	return vars.loaded[path]
--end
--
---iterator; replaces '?' in g by s and returns the resulting path if it is a file.
local function direct(g,s)
	g=string.gsub(g,'%?',s)
	if fs.exists(g) and not fs.isDir(g) then
		return g
	end
end
--add your finders here: must take (p,s) where p is where to search and s is what to search for.It must return a path.
vars.finders={direct}
vars.paths='?/init.lua;?.lua'

--helper vars for lua_requirer; other requirers may index theirs vars in loadreq.vars
vars.lua_requirer={
required={}, --to unrequire filepath s do require[s]=nil
required_envs={}, --to prevent garbage collection
requiring={}, --to throw error in case of recursive requiring;
}

--[[lua_requirer(path,cenv,env,renv,rerun,args)
Accepts empty or .lua extensions. 
if the rerun flag is true, reloads the file even if it done it before;
if the file has been loaded already returns previous value;
if the file is being loaded returns nil, error_message
else:
loads file in @path;
sets it's env to @env, default {} with metatable with __index set to @renv, default _G;
calls the function with unpack(@args) and returns and saves either
	the function return
	a shallow copy of the functions environment
]]

function lua_requirer(path,cenv,t)
    local env,renv,rerun,args=t.env,t.renv,t.rerun,t.args
    
    local err_prefix='lua_requirer:'
	local vars=vars.lua_requirer
	local _,ext=getNameExpansion(path)
	if not (ext=='' or ext=='lua' or ext==nil) then
		return nil, err_prefix..'wrong extension:'..ext
	end
	
	if vars.requiring[path] then
		return nil, err_prefix..'file is being loaded'
	end
	if not rerun and vars.required[path] then
		return vars.required[path]
	end
	
	local f,e=loadfile(path,path)
	if not f then
		return nil,err_prefix..'loadfile:'..e
	end
	env=env or {}
	env._FILE_PATH=path
	vars.required_envs[path]=env
	setfenv(f,env)
	renv=renv or _G
	setmetatable(env,{__index=renv})
	vars.requiring[path]=true
	local ok,r=pcall(f,args)
	vars.requiring[path]=nil
	if not ok then
		return nil,err_prefix..'while calling module:\n'..r
	elseif r then
		vars.required[path]=r
		return r
	else
		local t={}
		for i,v in pairs(env) do
			t[i]=v
		end
		vars.required[path]=t
		return t
	end
end

--replacement for os_loadAPI that keeps APIS to the caller's env
--local old_os_loadAPI=os.loadAPI
--new_os_loadAPI=function(p)
--	local cenv=getfenv(2)
--	local r,e=loadreq.lua_requirer(p,cenv)
--	if r then
--		local name=getNameExpansion(p)
--		protect(r)
--		cenv[p]=r
--	else
--		error('os.loadAPI(loadreq version):'..e..'\n'..'path='..p,2)
--	end
--end

--[[add your requirers here;
each must 
take as arguments (path,cenv,...) where
	path is the path to required file
	cenv is the environment of the caller of @require
	... are extra arguments passed to @require
return
	one value to be returned by @require
	false|nil, error_message in case of failure
]]
vars.requirers={lua=lua_requirer}

function sufix(s)
	return string.gsub('@/?;@/?.lua;@/?/init.lua;@/?/?.lua;@/?/?;@','@',s)
end


local function _find(s,paths,caller_env)
	local err={'_find: finding '..tostring(s)}
	
	if paths then
	elseif caller_env.REQUIRE_PATH then
		paths=caller_env.REQUIRE_PATH
	elseif caller_env.PACKAGE_NAME and caller_env._FILE_PATH then
		paths=sufix(string.match(caller_env._FILE_PATH,'^(.-'..caller_env.PACKAGE_NAME..')'))..';'..vars.paths
	elseif	caller_env._FILE_PATH then
		paths=sufix(getDir(caller_env._FILE_PATH))..';'..vars.paths
	else
		paths=vars.paths
	end
	
	--replace . by / and .. by . 
	s=string.gsub(s,'([^%.])%.([^%.])','%1/%2') 
	s=string.gsub(s,'^%.([^%.])','/%1')
	s=string.gsub(s,'%.%.','.')
	
	local finders=vars.finders
	
	local finder,path
	for i=1,#finders do
		finder=finders[i]
		for search_path in string.gmatch(paths,';?([^;]+);?') do
			path=finder(search_path,s)
			if path then return path end
			
		end
	end
	table.insert(err,'_find:file not found:'..s..'\ncaller path='..(caller_env._FILE_PATH or 'not available'))
	local serr=table.concat(err,'\n')
	log('loadreq','ERROR','_find:%s',serr)
	return nil,serr
end
find=_find

local function _require(s,opt,caller_env)
	local err={}
	table.insert(err,'loadreq:require: while requiring '..tostring(s))
	local path,e=_find(s,opt.path,caller_env)
	if path==nil then
		table.insert(err,e)
		return nil, table.concat(err,'\n')
	end
	for req_name,requirer in pairs(vars.requirers) do
		local r,e=requirer(path,caller_env,opt)
		if r then
			return r,path
		else
			table.insert(err,e)
		end
	end
	return nil, table.concat(err,'\n')
end

--[[require(s,paths,...)
@paths is a string of paths separated by ';' where there can be '?'
-acquires @paths variable, by the following order;
	0-arg @paths
		Example (_FILE_PATH='myFolder/myFolder2/myAPI.lua'):
		myAPI=require('myFolder2.myAPI','myFolder/?.lua') 
	1-REQUIRE_PATH in the caller's path, if existent
		Example (_FILE_PATH='myFolder/myFolder2/myAPI.lua'):
		REQUIRE_PATH='myFolder/?.lua'
		myAPI=require'myFolder2.myAPI' 
	2-directory named PACKAGE_NAME in _FILE_PATH, if defined in the caller's environment
	with sufixes appended by @sufix and concatenated with @vars.paths.
	_FILE_PATH is set, for instance, by lua_loader in the files it loads.
		Example (_FILE_PATH='myFolder/myFolder3/myFolder/runningFile'):
		PACKAGE_NAME='myFolder'
		myAPI=require'myAPI' --@paths is 'myFolder/?;myFolder/?.lua;myFolder/?/init.lua;myFolder/?/?.lua;myFolder/?/?;myFolder'
	3-directory of _FILE_PATH, if defined
	with sufixes appended by @sufix and concatenated with @vars.paths.
		Example (_FILE_PATH='myFolder/runningFile'):
		myAPI=require'myAPI' --@paths is 'myFolder/?;myFolder/?.lua;myFolder/?/init.lua;myFolder/?/?.lua;myFolder/?/?;myFolder'
	4-@vars.paths as set in loadreq.vars.paths
-replaces '.' in @s by '/' and '..' by '.'
--for all search_path in @paths
 -	for all iterators in vars.finders, iterates over the paths returned;
	default iterator:	see @direct
-for the first valid path, calls the loaders sequentially until one succeds, 
in which case it returns the first value that the loader returns, else if it returns nil,e accumulates e as an error message
els, if all loaders fail, errors immediatly, printing all error messages
-in case of failure finding the path, errors with useful info
]]

function require(s,opt)
    opt=opt or {}
	local t,e=_require(s,opt,getfenv(2))
	if t==nil then
		log('loadreq','ERROR','require:%s',e)
		error(e,1)
	else
		log('loadreq','INFO','require: success in requiring [%s]',e)
		return t
	end
end

---same as require, but copies the returned API to the caller's environment
function include(s,opt)
    opt=opt or {}
	local caller_env=getfenv(2)
	local t,e=_require(s,opt,caller_env)
	if t then
		for i,v in pairs(t) do
			if type(i)=='string' and i:sub(1,1)~='_' then
				caller_env[i]=v
			end
		end
		return true
	else
		log('loadreq','ERROR','include:%s',e)
		error(e,1)
	end
end

function reload(s,opt)
    opt=opt or {}
    opt.rerun=true
	return require(s,opt)
end

--protection utilities; these are meant more as a warning than OS-grade protection
vars.bProtected=true
local function protected_access(t,k,v)
	if vars.bProtected then
		error( "Attempt to write to protected" )
	else
		rawset( t, k, v )
	end
end
function protect(_t)--shallow protection for tables (slows down access to the tables themselves, not to their values, e.g. local t.a=protected_table.a print(a) should do the trick)
	local meta = getmetatable( _t )
	if meta == "Protected" then
		-- already hard protected
		return
	end
	if meta then
		meta.__newindex = protected_access
	else
		setmetatable( _t, {__newindex = protected_access} )
	end
end
function unprotect(_t)--removes the shallow protection
	local meta = getmetatable( _t )
	if not meta then
		return
	end
	vars.bProtected=false
	meta.__newindex=nil
	vars.bProtected=true
end

function permaProtect(_t) --same as the os.loadAPI does
	local meta = getmetatable( _t )
	if meta == "Protected" then
		-- already hard protected
		return
	end
	setmetatable( _t, {
		__newindex = function( t, k, v )
			if vars.bProtected then
				error( "Attempt to write to protected" )
			else
				rawset( t, k, v )
			end
		end,
		__metatable = 'Protected',
	} )
end

env=getfenv()
return env
