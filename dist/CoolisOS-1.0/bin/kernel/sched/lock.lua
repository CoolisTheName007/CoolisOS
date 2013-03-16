local s=require'kernel.checker'.check
local u=require'utils.table'.pack
PACKAGE_NAME='sched'
local a=require'init'
local t=setmetatable
local e=tostring
local e=string
local h=error
local e=assert
local o=table
local o=next
local n=pairs
local i=type
local r=unpack
env=getfenv()
t(env,nil)
LOCK={hooks={},objlocks=t({},{__mode="k"})}
LOCK.__index=LOCK
function new()
return t({waiting={}},LOCK)
end
function LOCK:destroy()
self.owner="destroyed"
for e,t in n(self.waiting)do
a.signal(self,e)
self.waiting[e]=nil
end
end
local function d(e)
for t,a in n(LOCK.hooks[e])do
if t.owner==e then t:release(e)
elseif t.waiting then t.waiting[e]=nil end
end
LOCK.hooks[e]=nil
end
local function l(t,e)
if not LOCK.hooks[e]then
local t=a.sigonce(function()
d(e)
end,e,"die")
LOCK.hooks[e]={sighook=t}
end
(LOCK.hooks[e])[t]=true
end
local function n(t,e)
(LOCK.hooks[e])[t]=nil
if not o(LOCK.hooks[e],o(LOCK.hooks[e]))then
(LOCK.hooks[e].sighook):kill()
LOCK.hooks[e]=nil
end
end
function LOCK:acquire()
local t=a.tasks.running
e(self.owner~=t,"a lock cannot be acquired twice by the same thread")
e(self.owner~="destroyed","cannot acquire a destroyed lock")
l(self,t)
while self.owner do
self.waiting[t]=true
a.wait(self,{t})
if self.owner=="destroyed"then h("lock destroyed while waiting")end
end
self.waiting[t]=nil
self.owner=t
end
function LOCK:release(t)
t=t or a.tasks.running
e(self.owner~="destroyed","cannot release a destroyed lock")
e(self.owner==t,"unlock must be done by the thread that locked")
n(self,t)
self.owner=nil
local e=o(self.waiting)
if e then
a.signal(self,e)
end
end
function lock(t)
e(t,"you must provide an object to lock on")
e(i(t)~="string"and i(t)~="number","the object to lock on must be a collectable object (no string or number)")
if not LOCK.objlocks[t]then LOCK.objlocks[t]=new()end
LOCK.objlocks[t]:acquire()
end
function unlock(t,a)
e(t,"you must provide an object to unlock on")
e(LOCK.objlocks[t],"this object was not locked")
LOCK.objlocks[t]:release()
end
function synchronized(e)
s(e,'function')
local function a(...)
local t=lock(e)
local t=u(e(...))
unlock(e)
return r(t,1,t.n)
end
return a
end
return env
