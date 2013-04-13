include'kernel.class'
local r=require'utils.linked'
local u=require'kernel.checker'.check
local e=require'kernel.util'.shcopy
local c=error
local e=read
PACKAGE_NAME='sched'
local t=sched
local e
local l=t.Obj
local e=os
local a=math
local a=tonumber
local a=assert
local a=table
local a=pairs
local a=next
local p=type
local a=_G
local y=e.clock
local n=setmetatable
local m=rawset
local d=unpack
local s=debug
env=getfenv()
n(env,nil)
local e={}
e.norm=function(e)
e=e-e%.05
return e
end
local w=e.norm
local function a(e)return nil end
local h
local a,o
local i
e.add=function(i)
if not o[i]then
local e
for t in r.next_r,a,val do
if t>i then
e=t
break
end
end
if e==nil then t.ready=true end
a:insert_r(i,e)
end
end
e.remove=function(e)
a:remove(e)
end
function e.step()
if o[0]==-1 then return end
local i=y()
while o[0]~=-1 and i>=o[0]do
local a=a:remove()
t.signal(e,a)
end
end
e.meta={__index=e}
n(e,{__index=l,__tostring=function()return'Class timer'end})
function e.nextevent()
if o[0]~=-1 then return o[0]end
end
local l={
__newindex=function(o,t,a)
if p(t)~='number'then
c(tostring(t)..'timer events must be numbers',2)
end
if a==nil then
e.remove(t)
else
e.add(t)
end
m(o,t,a)
end,
}
e._reset=function()
local i=t.task(function()end)
s.name(i,'placeholder')
h=n({[{}]={[i]=true}},l)
t.fil[e]=h
a=r()
o=a.r
e.link=a
end
class.CyclicTimer(t.Obj)
do
local a=CyclicTimer
local t=t.Obj
function a:__init(e,...)
t:__init(self)
u('number,function',e,f)
self.delta=w(e)
self.f=f
self.args={...}
end
function a:handle(t,e)
e=e+self.delta
self:link{timer={e}}
self.f(d(self.args))
end
end
e.cyclic=CyclicTimer
s.name(e,'timer')
t.timer=e
return e