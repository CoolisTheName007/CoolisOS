local s=fs
local a=string
local h=loadfile
local n=error
local o,e
function getNameExpansion(e)
local o,o,a,t=a.find(e,'([^%./\\]*)%.(.*)$')
return a or e,t
end
function getDir(e)
return a.match(e,'^(.*)/')or'/'
end
vars={}
vars.loaded={}
function loadFile(e,t)
if(vars.loaded[e]==nil)or t then
local t,a=h(e)
if not t then n('load:'..'path=:'..e..'| '..(a or'nil'),2)end
vars.loaded[e]=t
end
return vars.loaded[e]
end
local function i(e,t)
e=a.gsub(e,'%?',t)
if s.exists(e)and not s.isDir(e)then
return e
end
end
vars.finders={i}
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
for e,a in pairs(a)do o[e]=a end
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
n('os.loadAPI(loadreq version):'..o..'\n'..'path='..e,2)
end
end
vars.requirers={lua=lua_requirer}
function sufix(e)
return a.gsub('@/?;@/?.lua;@/?/init.lua;@/?/?.lua;@/?/?;@','@',e)
end
local function d(e,i,t)
local r={'_find: finding '..tostring(e)}
if i then
elseif t.REQUIRE_PATH then
i=t.REQUIRE_PATH
elseif t.PACKAGE_NAME and t.FILE_PATH then
i=sufix(a.match(t.FILE_PATH,'^(.-'..t.PACKAGE_NAME..')'))..';'..vars.paths
elseif t.FILE_PATH then
i=sufix(getDir(t.FILE_PATH))..';'..vars.paths
else
i=vars.paths
end
e=a.gsub(e,'([^%.])%.([^%.])','%1/%2')
e=a.gsub(e,'^%.([^%.])','/%1')
e=a.gsub(e,'%.%.','.')
local h=vars.finders
local s,n
for t=1,#h do
s=h[t]
for t in a.gmatch(i,';?([^;]+);?')do
n=s(t,e)
if n then return n end
end
end
table.insert(r,'_find:file not found:'..e..'\ncaller path='..(t.FILE_PATH or'not available'))
local e=table.concat(r,'\n')
if o then o('loadreq','ERROR','_find:%s',e)end
return nil,e
end
find=d
local function a(t,o,a,...)
local e={}
table.insert(e,'loadreq:require: while requiring '..tostring(t))
local t,o=d(t,o,a)
if t==nil then
table.insert(e,o)
return nil,table.concat(e,'\n')
end
for i,o in pairs(vars.requirers)do
local t,a=o(t,a,...)
if t then
return t
else
table.insert(e,a)
end
end
return nil,table.concat(e,'\n')
end
function require(t,e,...)
local a,e=a(t,e,getfenv(2),...)
if a==nil then
if o then o('loadreq','ERROR','require:%s',e)end
n(e,2)
else
if o then o('loadreq','INFO','require: success in requiring %s',t)end
return a
end
end
function include(t,i,...)
local e=getfenv(2)
local t,a=a(t,i,e,...)
if t then
for a,t in pairs(t)do
e[a]=t
end
return true
else
if o then o('loadreq','ERROR','include:%s',a)end
n(a,2)
end
end
vars.bProtected=true
local function a(e,a,t)
if vars.bProtected then
n("Attempt to write to protected")
else
rawset(e,a,t)
end
end
function protect(t)
local e=getmetatable(t)
if e=="Protected"then
return
end
if e then
e.__newindex=a
else
setmetatable(t,{__newindex=a})
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
__newindex=function(e,a,t)
if bProtected then
n("Attempt to write to protected")
else
rawset(e,a,t)
end
end,
__metatable='Protected',
})
end
rawset(_G,'require',require)
if s.exists('bin/kernel/log/init.lua')then
o=require'kernel.log'
end
rawset(_G,'require',nil)
env=getfenv()
return env
