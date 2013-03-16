local s=fs
local o=string
local h=loadfile
local i=error
local a,e
function getNameExpansion(e)
local o,o,t,a=o.find(e,'([^%./\\]*)%.(.*)$')
return t or e,a
end
function getDir(e)
return o.match(e,'^(.*)/')or'/'
end
vars={}
vars.loaded={}
function loadFile(e,t)
if(vars.loaded[e]==nil)or t then
local t,a=h(e)
if not t then i('load:'..'path=:'..e..'| '..(a or'nil'),2)end
vars.loaded[e]=t
end
return vars.loaded[e]
end
local function n(e,t)
e=o.gsub(e,'%?',t)
if s.exists(e)and not s.isDir(e)then
return e
end
end
vars.finders={n}
vars.paths='bin/?;bin/?.lua;bin/?/init.lua;?;?.lua;?/init.lua'
vars.lua_requirer={
required={},
required_envs={},
requiring={},
}
function lua_requirer(e,t,a,n,r,s)
local i='lua_requirer:'
local t=vars.lua_requirer
local d,o=getNameExpansion(e)
if not(o==''or o=='lua'or o==nil)then
return nil,i..'wrong extension:'..o
end
if t.requiring[e]then
return nil,i..'file is being loaded'
end
if not r and t.required[e]then
return t.required[e]
end
local o,h=h(e,e)
if not o then
return nil,i..'loadfile:'..h
end
a=a or{}
a.FILE_PATH=e
t.required_envs[e]=a
setfenv(o,a)
n=n or _G
setmetatable(a,{__index=n})
t.requiring[e]=true
local o=o(s and unpack(s))
t.requiring[e]=nil
if o then
t.required[e]=o
return o
else
local o={}
for a,e in pairs(a)do o[a]=e end
t.required[e]=o
return o
end
end
old_os_loadAPI=os.loadAPI
new_os_loadAPI=function(e)
local a=getfenv(2)
local t,o=loadreq.lua_requirer(e,a)
if t then
local o=getNameExpansion(e)
protect(t)
a[e]=t
else
i('os.loadAPI(loadreq version):'..o..'\n'..'path='..e,2)
end
end
vars.requirers={lua=lua_requirer}
function sufix(e)
return o.gsub('@/?;@/?.lua;@/?/init.lua;@/?/?.lua;@/?/?;@','@',e)
end
local function d(e,i,t)
local r={'_find: finding '..tostring(e)}
if i then
elseif t.REQUIRE_PATH then
i=t.REQUIRE_PATH
elseif t.PACKAGE_NAME and t.FILE_PATH then
i=sufix(o.match(t.FILE_PATH,'^(.-'..t.PACKAGE_NAME..')'))..';'..vars.paths
elseif t.FILE_PATH then
i=sufix(getDir(t.FILE_PATH))..';'..vars.paths
else
i=vars.paths
end
e=o.gsub(e,'([^%.])%.([^%.])','%1/%2')
e=o.gsub(e,'^%.([^%.])','/%1')
e=o.gsub(e,'%.%.','.')
local h=vars.finders
local s,n
for t=1,#h do
s=h[t]
for t in o.gmatch(i,';?([^;]+);?')do
n=s(t,e)
if n then return n end
end
end
table.insert(r,'_find:file not found:'..e..'\ncaller path='..(t.FILE_PATH or'not available'))
local e=table.concat(r,'\n')
if a then a('loadreq','ERROR','_find:%s',e)end
return nil,e
end
find=d
local function o(a,o,t,...)
local e={}
table.insert(e,'loadreq:require: while requiring '..tostring(a))
local a,o=d(a,o,t)
if a==nil then
table.insert(e,o)
return nil,table.concat(e,'\n')
end
for i,o in pairs(vars.requirers)do
local t,a=o(a,t,...)
if t then
return t
else
table.insert(e,a)
end
end
return nil,table.concat(e,'\n')
end
function require(e,t,...)
local t,o=o(e,t,getfenv(2),...)
if t==nil then
if a then a('loadreq','ERROR','require:%s',o)end
i(o,2)
else
if a then a('loadreq','INFO','require: success in requiring %s',e)end
return t
end
end
function include(n,t,...)
local e=getfenv(2)
local o,t=o(n,t,e,...)
if o then
for a,t in pairs(o)do
e[a]=t
end
return true
else
if a then a('loadreq','ERROR','include:%s',t)end
i(t,2)
end
end
function reload(t,a,...)
local e=args or{...}
if e[3]==nil then e[3]=true end
return require(t,a,unpack(e))
end
vars.bProtected=true
local function o(t,e,a)
if vars.bProtected then
i("Attempt to write to protected")
else
rawset(t,e,a)
end
end
function protect(t)
local e=getmetatable(t)
if e=="Protected"then
return
end
if e then
e.__newindex=o
else
setmetatable(t,{__newindex=o})
end
end
function unprotect(e)
local e=getmetatable(e)
if not e then
return
end
vars.bProtected=false
e.__newindex=nil
vars.bProtected=true
end
function permaProtect(e)
local t=getmetatable(e)
if t=="Protected"then
return
end
setmetatable(e,{
__newindex=function(t,a,e)
if bProtected then
i("Attempt to write to protected")
else
rawset(t,a,e)
end
end,
__metatable='Protected',
})
end
rawset(_G,'require',require)
if s.exists('bin/kernel/log/init.lua')then
a=require'kernel.log'
end
rawset(_G,'require',nil)
env=getfenv()
return env
