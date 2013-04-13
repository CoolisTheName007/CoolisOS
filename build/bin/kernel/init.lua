function dump(t)
local e=fs.open('dump','a')
e.writeLine(t)
e.close()
end
local h=shell.getRunningProgram()
local function r(o)
local t={}
local e=printError
local a='printError'
local i=coroutine.status
local i=function(n)
coroutine.status=i
for o,t in pairs(t)do
rawset(t,a,e)
end
local t,a=pcall(o)
if not t then
e(a)
end
end
for o=1,20 do
local n,e=pcall(getfenv,o)
if n then
if rawget(e,a)~=nil and not t[e]then
t[o]=e
rawset(e,a,i)
end
end
end
coroutine.status=nil
repeat
os.pullEvent()
until false
end
local function d()
local e=string
local e,o,i=rawset,rawget,type
local a=getmetatable
local s=getfenv(('').sub)
e(_G,'getmetatable',nil)
local function n(t)
if i(t)=='string'then
return s
else
return a(t)
end
end
e(_G,'getmetatable',n)
local s=setmetatable
e(_G,'setmetatable',nil)
local function h(a,t)
if t and i(t)=="table"then
local i=o(t,"__index")
local o=o(t,"__newindex")
e(t,"__index",nil)
e(t,"__newindex",nil)
local s=s(a,t)
e(t,"__index",i)
e(t,"__newindex",o)
local t=n(a)
e(t,"__index",i)
e(t,"__newindex",o)
return s
else
return s(a,t)
end
end
e(_G,'setmetatable',h)
e(_G,'loadfile',function(t)
local e=fs.open(t,"r")
if e then
local t,a=loadstring(e.readAll(),t)
e.close()
return t,a
end
return nil,"File not found"
end)
end
local function s()
debug.name(sched.running,'shell')
log.setLevel('sched','DEBUG')
log.store.instant=true
local e=require'kernel.gui'
local t=e.Terminal(_G.term,sched.platform)
local a=require'kernel.gui.shell'
local e=require'kernel.class.Box'
e{terminal=t}:run(a.main)
sched.wait('end')
end
local e=function()
d()
do
_FILE_PATH=h
local e=(_FILE_PATH:match'(.*)bin/kernel/init%.lua'):sub(1,-2)
rawset(_G,'_INSTALL_PATH',e)
rawset(_G,'loadreq',dofile(fs.combine(_INSTALL_PATH,'bin/kernel/loadreq/init.lua')))
rawset(_G,'require',loadreq.require)
rawset(_G,'include',loadreq.include)
loadreq.vars.paths=loadreq.vars.paths:gsub('%?',fs.combine(_INSTALL_PATH,'bin')..'/%?')..';'..loadreq.vars.paths..';'..loadreq.vars.paths:gsub('%?',_INSTALL_PATH..'/%?')
end
do
local function e(t,a)
rawset(_G,t,a)
end
e('util',require'kernel.util')
e('log',require'kernel.log')
log.store=require'kernel.log.store'
log.store.reset()
do
local t=require'utils.serpent'
e('pstring',function(e,a)return t.serialize(e,{debug=true,indent='  ',sortkeys=true,comment=true,maxlevel=a})end)
e('pprint',function(e,t)
debug.step_print(pstring(e))
end)
e('debug',require'kernel.debug')
e('log',require'kernel.log')
local e={
net=require'kernel.net',
sched=require'kernel.sched',
}
for a,t in pairs(require'kernel.class')do
e[a]=t
end
for t,e in pairs(e)do
rawset(_G,t,e)
end
end
do
os.sleep(0)
local e=os
local n=require'kernel.checker'.check
local e=util.shcopy(e)
local function t(i,a,t)
return function(...)
local o,e=nil,nil
if a then o={a(...)}end
e={i(...)}
if t then t(e,o)end
return unpack(e)
end
end
e.version=function()
return'1'
end
e.sleep=function(e)n('number',e)sched.wait(e)end
rawset(_G,'sleep',e.sleep)
rawset(_G,'os',e)
end
end
local e=function(e)return log('init','INFO','task:(%s) says:%s',tostring(sched.running),e)end
sched.task(function()
debug.wrap(s)()
end):run()
sched.loop()
log.store.flush()
print'Press any key to shutdown'
util.wait(os.pullEvent,{'char','q'},'char')
os.shutdown()
end
r(function()
local t,e=xpcall(e,function(e,t)
if _G.debug then
return _G.debug.traceback(e)
else
return e
end
end)
if not t then
if log then
log('init','ERROR','%s',e)
end
if _G.debug then
debug.printError(e)
else
printError(e)
end
end
sleep(2)
end)