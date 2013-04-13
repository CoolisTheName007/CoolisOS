local h=require'kernel.log'
local t,e,f,e,e,e,s,e,c,e,e,i=sched,pairs,string,term,_G,fs,os,print,unpack,select,pprint,next
local m=coroutine
local o,u=tostring,math
local w,r=debug,util
local e={}
local t=t
local a
env=getfenv()
setmetatable(env,nil)
e.is_running=function()
return t and t.Task.running and t.Task.running.co==m.running()
end
e.time=s.clock
local n=e.time
local y=o({})
local o=t.Task
local o,l,d=0,1,0
last_yield,last_return=-u.huge,-u.huge
e.info=function()
return f.format('load: %f;last yield: %f;last return:%f',r.format_number(d,2),r.format_number(last_yield,2),r.format_number(last_return,2))
end
local r=function(...)
h('platform','DETAIL','yielding to platform')
last_yield=n()
o=last_yield-last_return
local t={m.yield(...)}
last_return=n()
l=last_return-last_yield
d=o/(l+o)
h('platform','DETAIL',e.info())
return t
end
function e.step(o)
if t.ready then o=0 end
if o then
local a,i
if o==0 then
if n()-last_return>=.05 then
a=y
s.queueEvent(a)
else
return
end
else
a,i='timer',s.startTimer(o)
end
local o
repeat
o=r()
if(a==nil or o[1]==a)and(i==nil or i==o[2])then
break
else
t.signal(e,c(o))
if t.ready then break end
end
until false
return
else
if not a[e]then
h('platform','ERROR','no timers or platform listeners, so exiting.')
t.stop()
return
end
local o
if not i(a[e],i(a[e]))then
o=i(a[e])
end
t.signal(e,c(r(o)))
return
end
end
function e._reset()
a=t.fil
end
w.name(e,'platform')
t.platform=e
return e