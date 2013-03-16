local a=require'kernel.log'
local l=require'kernel.checker'.check
local h=require'utils.linked'
local y=table
local u=pairs
PACKAGE_NAME='sched'
local e,o,o,o,c,t,m
local d
local o={__mode='kv'}
local o={__mode='k'}
local r
local n
local s=function(t,o,...)
a('sched','DEBUG',"SIGNAL %s.%s",t,o)
local function a(t,a,o,...)
local e={}
for a,t in u(t)do
e[a]=t
end
for e,t in u(e)do
e:handle(a,o,...)
end
end
local function s(i,o,t,...)
local e=i[t]
if e then
a(e,o,t,...)
end
e=i['*']
if e then
a(e,o,t,...)
end
end
local e=n[t]
if e then
s(e,t,o,...)
end
local e=n['*']
if e then
s(e,t,o,...)
end
return true
end
local o=setmetatable({},
{__tostring=function()return'Class Obj'end}
)
local i={}
local w={
__index=i,
__tostring=function(e)return getmetatable(e).__type..':'..e.name end,
__type='obj'
}
o.new=function(a)
local t=setmetatable({
fil={},
subs={},
parent=e.running,
},w)
t.name=(a or tostring(t.fil):match(':.(.*)'))
e.running.subs[t]=true
return t
end
function o.step()
local e=o.ready
o.ready=h.new()
while true do
local e=e:remove()
if e==nil then break end
e:resume()
end
end
o._reset=function()
o.ready=h.new()
end
local function f(...)
local t={...}
local e=#t
local a,o
if type(t[e])=='number'then
o=t[e]
e=e-1
end
if e~=0 then
if e==1 then
a=t[1]
else
a={[t[1]]={unpack(t,2,e)}}
end
end
return a,o
end
local b=function(e,t)
e=e or{}
if t then
if not e.timer then
e.timer={t}
else
y.insert(e.timer,t)
end
end
return e
end
function i:link(t)
local i=self.fil
local e,a,o
for t,s in u(t)do
e=n[t]
a=i[t]
if not a then
i[t]={}
a=i[t]
if not e then n[t]={}e=n[t]end
end
local t
for i=1,#s do
t=s[i]
a[t]=true
o=e[t]
if not o then e[t]={}o=e[t]end
o[self]=true
end
end
return self
end
function i:unlink(t)
local s=self.fil
local a,e,i
for o,h in u(t)do
e=s[o]
if e then
a=n[o]
local t
for o=1,#h do
t=h[o]
if e[t]then
e[t]=nil
i=a[t]
i[self]=nil
if not next(i)then a[t]=nil end
end
end
if not next(e)then s[o]=nil end
if not next(a)then n[o]=nil end
end
end
return self
end
function i:reset()
local e
for a,t in u(self.fil)do
e=n[a]
for t in u(t)do
e[t][self]=nil
if not next(e[t])then e[t]=nil end
end
if not next(e)then n[a]=nil end
end
self.fil={}
return self
end
local h={n=0}
function i:finalize()
if h[self]then
error('Detected recursion in Obj.finalize: ending stack='..stringify(h,nil,nil,nil,nil,1),2)
else
h.n=h.n+1
h[self]=h.n
end
while next(self.subs)do
next(self.subs):kill()
end
self.parent.subs[self]=nil
self:reset()
o.ready:remove(self)
h[self]=nil
h.n=h.n-1
return self
end
function i:kill()
s(self,'dying')
self:finalize()
s(self,'dead')
return self
end
function i:setParent(e)
if e==self then error("A scheduler object cannot be it's own parent",2)end
self.parent.subs[self]=nil
e=e or r
self.parent=e
e.subs[self]=true
return self
end
local h={}
function i:setTimeout(e)
if type(e)~='number'then
error('timeout must be number',2)
else
e=c.norm(e)
end
self:cancelTimeout()
self[h]={
timeout=e,
td={timer={e+d()}},
}
self:link(self[h].td)
return self
end
function i:resetTimeout()
local e=self[h]
if e then
self:unlink(e.td)
e.td.timer[1]=d()+e.timeout
self:link(self.td.td)
end
return self
end
function i:cancelTimeout()
local e=self[h]
if e then
self:unlink(e.td)
self.td=nil
end
return self
end
local y=function(e,t,...)
if type(e)=='string'then
return t,e
else
return e
end
end
local p=function(t)
local e={}
for t,a in u(t)do
e[t]=a
end
return e
end
local u=setmetatable({},{
__tostring=function()return'Class Sync'end,
})
local h=p(i)
local v={
__index=h,
__tostring=w.__tostring,
__type='call'
}
u.new=function(...)
local t,e=y(...)
l('function,?string',t,e)
local e=o.new(e)
setmetatable(e,v)
e.f=t
return e
end
function h:handle(...)
self.args={...}
o.ready:insert_r(self)
e.ready=true
return self
end
function h:resume()
local t=e.running
e.running=self
self.f(unpack(self.args))
e.running=t
end
local h=setmetatable({},{
__tostring=function()return'Class Sync'end,
})
local v=p(i)
local v={
__index=v,
__tostring=w.__tostring,
__type='sync'
}
local g=function(t,...)
local a=e.running
e.running=t
t.f(...)
t:kill()
self.f(unpack(self.args))
e.running=a
end
h.once=function(...)
local i,t=y(...)
l('function,?string',i,t)
local e=o.new(t)
e.handle=g
e.f=i
setmetatable(e,v)
local t,o=f(select(t and 3 or 2,...))
if o then t=b(t,o+d())end
if t then e:link(t)end
a('sched','DETAIL','created Sync.once %s from %s with signal descriptor %s',e,i,...)
return e
end
local g=function(t,...)
local a=e.running
e.running=t
if t.timeout then
t.f(...)
t:resetTimeout()
else
t.f(...)
end
e.running=a
end
h.on=function(...)
local i,a=y(...)
l('function,?string',i,a)
local e=o.new(a)
e.handle=g
e.f=i
setmetatable(e,v)
e.kill=sync_perm_kill
local o,a=f(select(a and 3 or 2,...))
if a then
e:setTimeout(a)
end
if o then e:link(o)end
return e
end
t=setmetatable({},{
__tostring=function()return'Class Task'end,
})
local i=p(i)
local w={
__index=i,
__tostring=w.__tostring,
__type='task',
}
t.new=function(...)
local i,t=y(...)
l('function,?string',i,t)
local t=o.new(t)
setmetatable(t,w)
t.co=coroutine.create(i)
t.args={}
a('sched','INFO','Task.new created %s from function %s by %s',t,i,e.running)
return t
end
function i:handle(...)
self.args={...}
o.ready:insert_r(self)
e.ready=true
a('sched','DETAIL','Task:handle rescheduling %s to receive SIGNAL %s.%s',
self,arg[1],arg[2])
return self
end
function i:run(...)
l('task',self)
self.args={...}
o.ready:insert_r(self)
a('sched','INFO',"Task.run scheduling %s",self)
return self
end
function i:kill()
l('task',self)
if self.status~='dead'then
a('sched','INFO',"Task.kill killing %s from %s",self,e.running)
s(self,'dying')
self:finalize()
self.status='dead'
s(self,'dead')
if t.running and t.running.status=='dead'and t.running.co==coroutine.running()then
coroutine.yield()
end
end
return self
end
function i:resume()
e.running=self
local h=self.co
t.running=self
a('sched','DETAIL',"Resuming %s",obj)
local i,n=coroutine.resume(h,unpack(self.args))
t.running=nil
self.args={}
e.running=r
if not i then
a('sched','ERROR',"In %s:%s",self,n)
s(self,"error",i,n)
self:finalize()
elseif coroutine.status(h)=="dead"then
a('sched','INFO',"%s is dead",task)
s(o,"dying",i,n)
self:finalize()
s(self,"dead",i,n)
end
end
function t.wait(...)
local t
local e=e.running
if e.co~=coroutine.running()then error('calling Task.wait outside a task/inside a task but inside another coroutine',2)end
if...==nil then
a('sched','DETAIL',"Task.wait rescheduling %s for resuming ASAP",e)
o.ready:insert_r(e)
elseif...then
a('sched','DETAIL',"%s waiting",e)
local t,a=f(...)
t=a and b(t,d()+a)or t
e:link(t)
else
a('sched','DETAIL',"%s waiting for pre-set signals",e)
end
coroutine.yield()
if...then
e:reset()
end
return unpack(e.args)
end
function t._reset()
t.running=nil
end
local w={}
w.loop=function(n,...)
l('function',n)
local o,i=f(...)
l('task',e.running)
local t=e.running
local s=o or{}
t:link(s)
if i then
local o=d()+i
while true do
a('Wait','DEBUG','in loop')
o=d()+i
t:link{timer={o}}
out=n(e.wait(false))
t:unlink{timer={o}}
if out then break end
end
a('Wait','DEBUG','out loop')
else
while true do
a('Wait','DEBUG','in loop')
if n(e.wait(false))then break end
end
a('Wait','DEBUG','out loop')
end
t:unlink(s)
end
local function i(o,...)
local e=function(...)
while true do
o(t.wait(...))
end
end
a('sched','INFO','sigrun wrapper %s created from %s',
e,o)
return e
end
t.new_sigrun_task=function(e,...)
return t.new(i(e,...))
end
local function i(e,...)
local e=function(...)
e(t.wait(...))
end
return e
end
t.new_sigrunonce_task=function(e,...)
return t.new(i(e,...))
end
t.sigrun=function(...)
local e=t.new_sigrun_task(...)
return e:run()
end
t.sigrunonce=function(...)
local t=t.new_sigrunonce_task(...)
return t:run()
end
e={
signal=s,
emit=function(...)
e.signal(e.me(),...)
end,
Obj=o,
ready=false,
me=function()return e.running end,
Task=t,
Sync=h,
Call=u,
Wait=w,
sigonce=h.once,
sighook=h.on,
task=t.new,
wait=t.wait,
sigrun=t.sigrun,
sigrunonce=t.sigrunonce,
call=u.new
}
e.global={
sched=e,
signal=s,
emit=e.emit,
sigonce=h.once,
sighook=h.on,
task=t.new,
wait=t.wait,
sigrun=t.sigrun,
sigrunonce=t.sigrunonce,
}
local i=setmetatable({sched=e},{__index=_G})
m=require('platform',nil,nil,i)
d=m.time
c=require('timer',nil,nil,i)
e.Timer=c
e.platform=m
local i='stopped'
function e.stop()
a('sched','INFO','%s toggling loop_state=%s to stopping',t.running or'scheduler',i)
if i=='running'then i='stopping'end
end
function e.reset()
if r then
r:kill()
end
n={}
e.fil=n
r=setmetatable(
{
subs={},
name='scheduler',
kill=function(o)
a('sched','INFO',"killing %s from %s",o,e.running)
if e.running~=r then
error('killing scheduler from'..tostring(e.running)..', use sched.stop() instead',2)
end
s(o,'dying',e.running)
while next(o.subs)do
next(o.subs):kill()
end
o.subs={}
o.status='dead'
s(o,'dead',e.running)
if t.running and t.running.status=='dead'and t.running.co==coroutine.running()then
coroutine.yield()
end
e.ready=true
return o
end
},{
__tostring=function(e)return e.name end,
})
e.scheduler=r
e.running=r
o._reset()
t._reset()
c._reset()
m._reset()
i='stopped'
a('sched','INFO','scheduler cleaned.')
end
function e.loop()
a('sched','INFO','Scheduler started')
i='running'
local t=t
local o,t,n,s=
c.nextevent,c.step,o.step,m.step
local a
while true do
t()
n()
a=nil
local t=o()
if t then
local e=d()
a=t<e and 0 or t-e
end
if i~='running'then e.reset()break end
s(a,t)
end
end
e.reset()
return e