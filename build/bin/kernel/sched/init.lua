include'kernel.class'
local a=require'kernel.log'
local m=require'kernel.checker'.check
local c=require'utils.linked'
local u=table
local o=pairs
local e,s,h,t,n,l
local r
local i
local d=function(t,n,...)
a('sched','DEBUG',"SIGNAL [%s].[%s]",t,n)
local function a(t,a,i,...)
local e={}
for a,t in o(t)do
e[a]=t
end
for e,t in o(e)do
e:handle(a,i,...)
end
end
local function o(i,o,t,...)
local e=i[t]
if e then
a(e,o,t,...)
end
e=i['*']
if e then
a(e,o,t,...)
end
end
local e=i[t]
if e then
o(e,t,n,...)
end
local e=i['*']
if e then
o(e,t,n,...)
end
return true
end
s=class('Obj')
do
local t=s
function t:__init()
self.fil={}
self.subs={}
if e.running then self:setParent(e.running)end
end
local function h(...)
local t={...}
local e=#t
local a,o
if type(t[e])=='number'then
o=t[e]
e=e-1
end
if e~=0 then
if e==1 and type(t[1])=='table'then
a=t[1]
else
a={[t[1]]={e==1 and'*'or unpack(t,2,e)}}
end
end
return a,o
end
local s=function(e,t)
e=e or{}
if t then
if not e[n]then
e[n]={t}
else
u.insert(e[n],t)
end
end
return e
end
function get_t(...)
local e,t=h(...)
if t then e=s(e,t+r())end
return e
end
function t:link(...)
local e=get_t(...)
if e==nil then return end
local s=self.fil
local h=self.__root
local t,n,a
for e,o in o(e)do
t=i[e]
n=s[e]
if not n then
s[e]={}
n=s[e]
if not t then i[e]={}t=i[e]end
end
local e
for i=1,#o do
e=o[i]
n[e]=true
a=t[e]
if not a then t[e]={}a=t[e]end
a[h]=true
end
end
end
function t:unlink(...)
local r=self.__root
local e=get_t(...)
if e==nil then return end
local s=self.fil
local a,t,n
for o,h in o(e)do
t=s[o]
if t then
a=i[o]
local e
for o=1,#h do
e=h[o]
if t[e]then
t[e]=nil
n=a[e]
n[r]=nil
if not next(n)then a[e]=nil end
end
end
if not next(t)then s[o]=nil end
if not next(a)then i[o]=nil end
end
end
end
function t:reset()
local e
local n=self.__root
for a,t in o(self.fil)do
e=i[a]
if e then
for t in o(t)do
if e[t]then
e[t][n]=nil
if not next(e[t])then e[t]=nil end
end
end
if not next(e)then i[a]=nil end
end
end
self.fil={}
end
local i={n=0}
function t:silent_destroy()
local t=self.__root
if i[t]then
error('Detected recursion in Obj.finalize: ending stack='..pstring(i),2)
else
i.n=i.n+1
i[t]=i.n
end
while next(self.subs)do
next(self.subs):destroy()
end
if self.parent then
self.parent.Obj.subs[t]=nil
end
self:reset()
e.queue:remove(t)
i[t]=nil
i.n=i.n-1
end
function t:destroy(...)
if not self.destroyed then
local e=self.__root
d(e,'dying',...)
self:silent_destroy()
d(e,'dead',...)
self.destroyed=true
end
end
local function s(a,t,e)
if t==nil then return true,e end
t=t.__root
local a=a.__root
e=e or{a,[a]=true}
if e[t]then return false,e end
u.insert(e,t)
e[t]=true
return s(t,t.Obj.parent,e)
end
function t:setParent(t)
local i,n=t.__root,t.Obj
local o=self.__root
local s,h=s(self,self.parent)
if not s then error('Cycle detected in scheduler hierarchy;debug:'..pstring(h),2)end
if i==o then error("A scheduler object cannot be it's own parent",2)end
if self.parent then self.parent.Obj.subs[o]=nil end
self.parent=i
n.subs[o]=true
a('sched','DETAIL','(%s) parent set to (%s) by (%s)',self.__root,(t and t.__root),e.running or'nil')
end
local a={}
function t:setTimeout(e)
if type(e)~='number'then
error('timeout must be number',2)
else
e=n.norm(e)
end
self:cancelTimeout()
self[a]={
timeout=e,
td={timer={e+r()}},
}
self:link(self[a].td)
return self
end
function t:resetTimeout()
local e=self[a]
if e then
self:unlink(e.td)
e.td[n][1]=r()+e.timeout
self:link(self.td.td)
end
end
function t:cancelTimeout()
local e=self[a]
if e then
self:unlink(e.td)
self.td=nil
end
end
function t:__debug()
local e={}
for t,a in o(self.fil)do
local t=debug.getinfo(t)
e[t]={}
for a in o(a)do
u.insert(e[t],debug.getinfo(a))
end
end
return string.format('%s;   \nWait descriptor:%s',debug.objinfo(self),pstring(e))
end
end
h=class('Sync')
do
local o=h
local n=function(t,...)
local o=t.Sync
local a=e.running
e.running=t
o.f(...)
t:destroy()
e.running=a
end
local i=function(t,...)
local o=e.running
e.running=t
local a=t.Sync
a.f(...)
t:resetTimeout()
e.running=o
end
function o:__init(o,t)
m('function',o)
t=t or'on'
s:__init(self)
if t=='once'then
elseif t=='on'then
else error('mode?',2)end
self.mode=t
a('sched','INFO','(%s) created with mode %s by (%s)',self,t,e.running or'nil')
end
function o:handle(...)
if self.mode=='on'then
n(...)
else
i(...)
end
end
end
t=class('Task',s)
do
local o=t
function o:__init(t,...)
m('function',t)
s:__init(self)
self.co=coroutine.create(t)
self.args={...}
a('sched','INFO','created (%s) from function (%s) by (%s)',self,t,e.running or'nil')
end
function o:handle(...)
self.args={...}
e.queue:push(self)
e.ready=true
a('sched','DETAIL','Task:handle rescheduling (%s) to receive SIGNAL [%s].[%s]',
self,...)
return self
end
function o:run(...)
self.args={...}
e.queue:push(self)
a('sched','INFO',"Task.run scheduling (%s)",self)
return self
end
function o:destroy()
if self.status~='dead'then
a('sched','INFO',"Task.destroy destroying (%s) from (%s)",self,e.running or'nil')
self.Obj:destroy()
self.status='dead'
if t.running and t.running.status=='dead'and t.running.co==coroutine.running()then
coroutine.yield()
end
end
return self
end
function o:resume()
e.running=self
local n=self.co
t.running=self
a('sched','DETAIL',"Resuming (%s)",self)
local o,i=coroutine.resume(n,unpack(self.args))
a('sched','DETAIL',"Exited (%s)",self)
t.running=nil
self.args={}
e.running=nil
if not o then
a('sched','ERROR',"In (%s):%s",self,i)
d(self,"error",o,i)
self:destroy(o,i)
elseif coroutine.status(n)=="dead"then
a('sched','INFO',"(%s) is dead",self)
self:destroy(o,i)
end
end
function o:wait(...)
local t=self
if t.co~=coroutine.running()then error('calling Task.wait outside a task/inside a task but inside another coroutine',2)end
if(...)==nil then
e.queue:push(t)
a('sched','DETAIL',"Task.wait rescheduling (%s) for resuming ASAP",t)
elseif...then
t:link(...)
a('sched','DETAIL',"(%s) waiting",t)
else
a('sched','DETAIL',"(%s) waiting for pre-set signals",t)
end
coroutine.yield()
if...then
t:reset()
end
return unpack(t.args)
end
function t._reset()
t.running=nil
end
t.sigrun=function(a,...)
local e=function()
while true do
a(e.wait(false))
end
end
local e=t(e)
e:link(...)
return e
end
t.sigrunonce=function(a,...)
local e=function()
a(e.wait(false))
end
local e=t(e)
e:link(...)
return e
end
end
do
e={
signal=d,
emit=function(...)
e.signal(e.me(),...)
end,
Obj=s,
ready=false,
me=function()return e.running end,
Task=t,
Sync=h,
sigonce=function(e)return h(e,'once')end,
sighook=function(e)return h(e,'on')end,
wait=function(...)return e.running:wait(...)end,
sigrun=t.sigrun,
sigrunonce=t.sigrunonce,
}
local s=function(a,t)
t=t or{}
t.env={sched=e}
return require(a,t)
end
l=s'platform'
r=l.time
n=s'timer'
s'pipe'
local s='stopped'
function e.step()
local t=e.queue
e.queue=c()
while true do
local e=t:remove()
if e==nil then break end
e:resume()
end
if not e.queue:isempty()then e.ready=true end
end
function e.stop()
a('sched','INFO','(%s) toggling loop_state=%s to stopping',t.running or'scheduler',s)
if s=='running'then s='stopping'end
end
function e.reset()
i={}
e.fil=i
e.running=nil
e.queue=c()
t._reset()
n._reset()
l._reset()
s='stopped'
a('sched','INFO','scheduler cleaned.')
end
function e.loop()
a('sched','INFO','Scheduler started')
s='running'
local t
while true do
n.step()
e.step()
t=nil
local a=n.nextevent()
if a then
local e=r()
t=a<e and 0 or a-e
end
if s~='running'then e.reset()break end
l.step(t)
e.ready=false
end
end
function e.debug()
local t={}
local a={}
for n,e in o(i)do
local t={}
for i,n in o(e)do
local e={}
for a in o(n)do
u.insert(e,debug.getinfo(a))
end
t[debug.getinfo(i)]=e
end
a[debug.getinfo(n)]=t
end
t.fil=a
return pstring(t)
end
local t={}
for e,a in o(e)do
if type(e)=='string'then t[e:lower()]=a end
end
for t,a in o(t)do e[t]=a end
e.reset()
end
return e