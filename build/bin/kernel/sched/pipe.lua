include'kernel.class'
local a=require'kernel.checker'.check
local e=sched
e.Pipe=class'Pipe'
do
local t=e.Pipe
local o,o,i=table.insert,table.remove,os.clock
e.pipes=setmetatable({},{__mode='kv'})
function t:__init(t)
a('?number',t)
util.shcopy({
sndidx=1;
rcvidx=1;
content={};
maxlength=t;
state='empty';
wasteabs=32;
wasteprop=2},
self)
if e.pipes then
e.pipes[debug.getinfo(self)]=self
end
end
local function o(t)
local a=t.sndidx-t.rcvidx
local o=t.state
local a=a==0 and'empty'or t.maxlength==a and'full'or'ready'
if o~=a then
t.state=a
e.signal(t,'state',a)
end
end
local function s(e)
local i=e.rcvidx
local o=i-1
if o<=e.wasteabs then return end
local n=e.sndidx
local a=n-i
if o<=e.wasteprop*a then return end
local t
if n<2e3 then t={select(i,unpack(e.content))}else
local i
i,t=e.content,{}
for e=1,a do t[e]=i[e+o]end
end
e.content,e.rcvidx,e.sndidx=t,1,a+1
end
function t:receive(n)
a('?number',n)
local t
while true do
if self.rcvidx==self.sndidx then
log('pipe','DEBUG',"(%s) empty,(%s) :receive() waits for data",self,e.running)
t=t or n and i()+n
local t=t and t-i()
if t and t<=0 or e.wait(self,'state',t)==e.timer then
return nil,'timeout'
end
else
local t,e=self.content,self.rcvidx
local a=t[e]
t[e]=false
self.rcvidx=e+1
s(self)
o(self)
return a
end
end
end
function t:send(s,n)
a('!nil,?number',s,n)
local t=self.maxlength
local t
while self.state=='full'do
log('pipe','DEBUG',"Pipe %s full, :send() blocks until some data is pulled from pipe",self)
t=t or n and i()+n
local t=t and t-i()
if t and t<=0 or e.wait(self,'state',t)=='timer'then
log('pipe','DEBUG',"Pipe %s :send() timeout",self)
return nil,'timeout'
else
log('pipe','DEBUG',"Pipe %s state changed, retrying to :send()",self)
end
end
local e=self.sndidx
self.content[e]=s
self.sndidx=e+1
o(self)
return self
end
function t:pushback(t)
assert(t~=nil,"Don't :pushback(nil) in a pipe")
if self.state=='full'then
return nil,'length would exceed maxlength'
end
local e=self.rcvidx-1
if e==0 then
table.insert(self.content,1,t)
self.sndidx=self.sndidx+1
else
self.content[e]=t
self.rcvidx=e
end
o(self)
return self
end
function t:reset()
local e=self.content
self.content={}
o(self)
return e
end
function t:peek()
return self.content[self.rcvidx]
end
function t:length()
return self.sndidx-self.rcvidx
end
function t:setmaxlength(e)
a('?number',e)
if self:length()>e then return nil,'length exceeds new maxlength'end
if e and e<1 then return nil,'invalid maxlength'end
self.maxlength=e
o(self)
return self
end
function t:setwaste(e,t)
self.wasteabs,self.wasteprop=e,t
return self
end
end
e.SigPipe=class('SigPipe',e.Pipe,e.Obj)
do
local e=e.SigPipe
function e:handle(...)
self:send{...}
end
end
e.pump=function(t,i,o)
a('!nil,function,!nil',t,i,o)
repeat
local e=i(t and t:receive())
if e~=nil and o then o:send(e)end
until false
end
e.to=function(t,a)
repeat
local e=t:receive()
if e~=nil then
for a,t in ipairs(a)do
t:send(e)
end
end
until false
end
e.from=function(t,a)
e.running:reset()
for a,t in ipairs(t)do
e.running:link(t,'*')
end
repeat
e.wait(false)
local e=true
while e do
e=false
for o,t in ipairs(t)do
if t:peek()~=nil then
a:send(t:receive())
e=true
end
end
end
until false
end
