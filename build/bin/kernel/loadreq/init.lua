local a=fs
local t=string
local h=loadfile
local n=error
local function s(...)
return(_G.log and _G.log(...))
end
function getNameExpansion(e)
local o,o,a,t=t.find(e,'([^%./\\]*)%.(.*)$')
return a or e,t
end
function getDir(e)
return t.match(e,'^(.*)/')or'/'
end
vars={}
local function o(e,o)
e=t.gsub(e,'%?',o)
if a.exists(e)and not a.isDir(e)then
return e
end
end
vars.finders={o}
vars.paths='?/init.lua;?.lua'
vars.lua_requirer={
required={},
required_envs={},
requiring={},
}
function lua_requirer(e,a,t)
local a,n,s,r=t.env,t.renv,t.rerun,t.args
local i='lua_requirer:'
local t=vars.lua_requirer
local d,o=getNameExpansion(e)
if not(o==''or o=='lua'or o==nil)then
return nil,i..'wrong extension:'..o
end
if t.requiring[e]then
return nil,i..'file is being loaded'
end
if not s and t.required[e]then
return t.required[e]
end
local o,s=h(e,e)
if not o then
return nil,i..'loadfile:'..s
end
a=a or{}
a._FILE_PATH=e
t.required_envs[e]=a
setfenv(o,a)
n=n or _G
setmetatable(a,{__index=n})
t.requiring[e]=true
local n,o=pcall(o,r)
t.requiring[e]=nil
if not n then
return nil,i..'while calling module:\n'..o
elseif o then
t.required[e]=o
return o
else
local o={}
for e,a in pairs(a)do
o[e]=a
end
t.required[e]=o
return o
end
end
vars.requirers={lua=lua_requirer}
function sufix(e)
return t.gsub('@/?;@/?.lua;@/?/init.lua;@/?/?.lua;@/?/?;@','@',e)
end
local function h(a,o,e)
local n={'_find: finding '..tostring(a)}
if o then
elseif e.REQUIRE_PATH then
o=e.REQUIRE_PATH
elseif e.PACKAGE_NAME and e._FILE_PATH then
o=sufix(t.match(e._FILE_PATH,'^(.-'..e.PACKAGE_NAME..')'))..';'..vars.paths
elseif e._FILE_PATH then
o=sufix(getDir(e._FILE_PATH))..';'..vars.paths
else
o=vars.paths
end
a=t.gsub(a,'([^%.])%.([^%.])','%1/%2')
a=t.gsub(a,'^%.([^%.])','/%1')
a=t.gsub(a,'%.%.','.')
local h=vars.finders
local r,i
for e=1,#h do
r=h[e]
for e in t.gmatch(o,';?([^;]+);?')do
i=r(e,a)
if i then return i end
end
end
table.insert(n,'_find:file not found:'..a..'\ncaller path='..(e._FILE_PATH or'not available'))
local e=table.concat(n,'\n')
s('loadreq','ERROR','_find:%s',e)
return nil,e
end
find=h
local function o(t,a,o)
local e={}
table.insert(e,'loadreq:require: while requiring '..tostring(t))
local t,i=h(t,a.path,o)
if t==nil then
table.insert(e,i)
return nil,table.concat(e,'\n')
end
for n,i in pairs(vars.requirers)do
local a,o=i(t,o,a)
if a then
return a,t
else
table.insert(e,o)
end
end
return nil,table.concat(e,'\n')
end
function require(t,e)
e=e or{}
local t,e=o(t,e,getfenv(2))
if t==nil then
s('loadreq','ERROR','require:%s',e)
n(e,1)
else
s('loadreq','INFO','require: success in requiring [%s]',e)
return t
end
end
function include(t,e)
e=e or{}
local a=getfenv(2)
local e,t=o(t,e,a)
if e then
for e,t in pairs(e)do
if type(e)=='string'and e:sub(1,1)~='_'then
a[e]=t
end
end
return true
else
s('loadreq','ERROR','include:%s',t)
n(t,1)
end
end
function reload(t,e)
e=e or{}
e.rerun=true
return require(t,e)
end
vars.bProtected=true
local function t(e,a,t)
if vars.bProtected then
n("Attempt to write to protected")
else
rawset(e,a,t)
end
end
function protect(a)
local e=getmetatable(a)
if e=="Protected"then
return
end
if e then
e.__newindex=t
else
setmetatable(a,{__newindex=t})
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
__newindex=function(e,t,a)
if vars.bProtected then
n("Attempt to write to protected")
else
rawset(e,t,a)
end
end,
__metatable='Protected',
})
end
env=getfenv()
return env
