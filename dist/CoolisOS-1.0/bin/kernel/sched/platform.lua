local f=require'kernel.log'
local e,t,t,t,t,t,r,t,l,t,t,h=sched,pairs,string,term,_G,fs,os,print,unpack,select,pprint,next
local c=coroutine
local a,t=tostring,math
PACKAGE_NAME='sched'
local e=e
local t
local m
local o=read
local o=tprint
env=getfenv()
setmetatable(env,nil)
is_running=function()
return e and e.Task.running and e.Task.running.co==c.running()
end
local i=r.clock
env.time=i
local d=a({})
local a=e.Task
local n,s,o,a,u=0,1,-1,1,0
debug=function()
return n,s,o,a,u
end
local s=function(...)
o=i()
n=o-a
local e={c.yield(...)}
a=i()
s=a-o
u=n/(s+n)
return e
end
function step(n,o)
if e.ready then n=0 end
e.ready=false
if n then
local o
if n==0 then
if i()-a>=.05 then
r.queueEvent('timer',d)
o=d
else
return
end
else
o=r.startTimer(n)
end
if t.platform then
local a
local t=t.platform
repeat
a=s()
if a[1]=='timer'and a[2]==o then
break
else
e.signal('platform',l(a))
if e.ready then break end
end
until false
return
else
repeat
until o==s('timer')[2]
return
end
else
if not t.platform then
f('platform','INFO','no timers or platform listeners, so exiting.')
e.stop()
return
end
local a
if not h(t.platform,h(t.platform))then
a=h(t.platform)
end
e.signal('platform',l(s(a)))
return
end
end
function _reset()
t=e.fil
m=e.Timer.link.r
end
return env