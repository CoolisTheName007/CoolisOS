local o=require'kernel.checker'.check
PACKAGE_NAME='sched'
local t=require'init'
local e={__type='pipe'};e.__index=e
local a,a,i=table.insert,table.remove,os.clock
t.pipes=setmetatable({},{__mode='kv'})
function pipe(a)
o('?number',a)
local a={
sndidx=1;
rcvidx=1;
content={};
maxlength=a;
state='empty';
wasteabs=32;
wasteprop=2}
if t.pipes then
t.pipes[tostring(a):match(':.(.*)')]=a
end
setmetatable(a,e)
return a
end
local function a(e)
local a=e.sndidx-e.rcvidx
local o=e.state
local a=a==0 and'empty'or e.maxlength==a and'full'or'ready'
if o~=a then
e.state=a
t.signal(e,'state',a)
end
end
local function s(e)
local i=e.rcvidx
local a=i-1
if a<=e.wasteabs then return end
local n=e.sndidx
local o=n-i
if a<=e.wasteprop*o then return end
local t
if n<2e3 then t={select(i,unpack(e.content))}else
local i
i,t=e.content,{}
for e=1,o do t[e]=i[e+a]end
end
e.content,e.rcvidx,e.sndidx=t,1,o+1
end
function e:receive(n)
o('pipe,?number',self,n)
local e
while true do
if self.rcvidx==self.sndidx then
log('pipe','DEBUG',"Pipe %s empty, :receive() waits for data",tostring(self))
e=e or n and i()+n
local e=e and e-i()
if e and e<=0 or t.wait(self,'state',e)=='timer'then
return nil,'timeout'
end
else
local t,e=self.content,self.rcvidx
local o=t[e]
t[e]=false
self.rcvidx=e+1
s(self)
a(self)
return o
end
end
end
function e:send(s,n)
o('pipe,?,?number',self,s,n)
if s==nil then error("Don't :send(nil) in a pipe",2)end
local e=self.maxlength
local e
while self.state=='full'do
log('pipe','DEBUG',"Pipe %s full, :send() blocks until some data is pulled from pipe",tostring(self))
e=e or n and i()+n
local e=e and e-i()
if e and e<=0 or t.wait(self,'state',e)=='timer'then
log('pipe','DEBUG',"Pipe %s :send() timeout",tostring(self))
return nil,'timeout'
else
log('pipe','DEBUG',"Pipe %s state changed, retrying to :send()",tostring(self))
end
end
local e=self.sndidx
self.content[e]=s
self.sndidx=e+1
a(self)
return self
end
function e:pushback(t)
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
a(self)
return self
end
function e:reset()
local e=self.content
self.content={}
a(self)
return e
end
function e:peek()
return self.content[self.rcvidx]
end
function e:length()
return self.sndidx-self.rcvidx
end
function e:setmaxlength(e)
o('pipe,?number',self,e)
if self:length()>e then return nil,'length exceeds new maxlength'end
if e and e<1 then return nil,'invalid maxlength'end
self.maxlength=e
a(self)
return self
end
function e:setwaste(e,t)
self.wasteabs,self.wasteprop=e,t
return self
end
return pipe