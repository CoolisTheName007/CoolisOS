rawset(_G,'loadfile',function(t)
local e=fs.open(t,"r")
if e then
local t,a=loadstring(e.readAll(),t)
e.close()
return t,a
end
return nil,"File not found"
end)
os.loadAPI'bin/kernel/loadreq/init.lua'
rawset(_G,'loadreq',_G['init.lua'])
rawset(_G,'init.lua',nil)
rawset(_G,'require',loadreq.require)
rawset(_G,'include',loadreq.include)
FILE_PATH='os/main'
local s=string
local e,i,o=rawset,rawget,type
local a=getmetatable
e(_G,'getmetatable',nil)
local function n(t)
if o(t)=='string'then
return s
else
return a(t)
end
end
e(_G,'getmetatable',n)
local s=setmetatable
e(_G,'setmetatable',nil)
local function h(a,t)
if t and o(t)=="table"then
local o=i(t,"__index")
local i=i(t,"__newindex")
e(t,"__index",nil)
e(t,"__newindex",nil)
local s=s(a,t)
e(t,"__index",o)
e(t,"__newindex",i)
local t=n(a)
e(t,"__index",o)
e(t,"__newindex",i)
return s
else
return s(a,t)
end
end
e(_G,'setmetatable',h)
e(_G,'log',require'kernel.log')
require'kernel.log.store'
local t={
stringify=require'utils.stringify'.stringify,
dprint=require'utils.stringify'.dprint,
read=require'utils.tab_read',
pprint=function(e,t)
print(stringify(e,docol,spacing_h,spacing_v,preindent,t))
end,
net=require'kernel.net',
util=require'kernel.util',
sched=require'kernel.sched',
}
for t,a in pairs(t)do
e(_G,t,a)
end
