local a=function(...)
print(string.format(...))
end
local t={
}
t.sRevision="1.1.4, 2/23/09"
function t:new(e)
e=e or{}
setmetatable(e,self)
self.__index=self
return e
end
function t:addState(a,e,t)
self[e]={
name=a,
handler=e,
super=t,
toLcaCache={},
}
end
function t:dump()
for t,e in pairs(self)do
a("State-%s\t%s,  Parent-%s, toLcaCache: %s\n",
e.name,tostring(e),tostring(self[e.super]),tostring(e.toLcaCache))
end
end
function t:onStart(e)
self.tEvt={
sType,
}
self.tEvt.sType="entry"
self.rCurr=self[e]
self.rNext=0
self.rCurr.handler(self)
while true do
self.tEvt.sType="init"
self.rCurr.handler(self)
if self.rNext==0 then
break
end
local e={}
local t=self.rNext
while t~=self.rCurr do
e[#e+1]=t.handler
t=self[t.super]
end
self.tEvt.sType="entry"
for t=#e,1,-1 do
e[t](self)
end
self.rCurr=self.rNext
self.rNext=0
end
end
function t:onEvent(e)
self.tEvt.sType=e
local e=self.rCurr
while true do
self.rSource=e
self.tEvt.Evt=e.handler(self)
if self.tEvt.Evt==0 then
if self.rNext~=0 then
local t={}
e=self.rNext
while e~=self.rCurr do
t[#t+1]=e.handler
e=self[e.super]
end
self.tEvt.sType="entry"
for e=#t,1,-1 do
t[e](self)
end
self.rCurr=self.rNext
self.rNext=0
while true do
self.tEvt.sType="init"
self.rCurr.handler(self)
if self.rNext==0 then
break
end
local t={}
e=self.rNext
while e~=self.rCurr do
t[#t+1]=e.handler
e=self[e.super]
end
self.tEvt.sType="entry"
for e=#t,1,-1 do
t[e](self)
end
self.rCurr=self.rNext
self.rNext=0
end
end
break
end
e=self[e.super]
end
return(0)
end
function t:exit(t)
local e=self.rCurr
self.tEvt.sType="exit"
while e~=self.rSource do
e.handler(self)
e=self[e.super]
end
while t~=0 do
t=t-1
e.handler(self)
e=self[e.super]
end
self.rCurr=e
end
function t:toLCA(t)
local a=0
if self.rSource==t then
return(1)
end
local e=self.rSource
while e~=nil do
local t=t
while t~=nil do
if e==t then
return(a)
end
t=self[t.super]
end
a=a+1
e=self[e.super]
end
return(0)
end
function t:stateTran(e)
if self.rCurr.toLcaCache[self.tEvt.sType]==nil then
self.rCurr.toLcaCache[self.tEvt.sType]=self:toLCA(self[e])
end
self:exit(self.rCurr.toLcaCache[self.tEvt.sType])
self.rNext=self[e]
end
function t:stateStart(e)
self.rNext=self[e]
end
function t:stateCurrent()
return self.rCurr
end
function t:revision()
return sRevision
end
return t