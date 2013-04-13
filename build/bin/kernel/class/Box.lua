include'kernel.class'
local e=require'kernel.class.Opt'
local t=sched.pipe
class.Box()
do
local e=e{
pin=e(t),
pout=e(t),
perr=e(t),
terminal=e(nil,'req'),
env=e(function()
local e=setmetatable({},{__index=_G})
e._G=e
return e
end)
}
function Box:__init(t)
e:drop(self,t)
self.env.process=self
self.env.print=function(...)
local e={...}
for e=1,table.getn(e)do
self.pout:send(tostring(arg[e]))
end
end
self.env.read=function(e)
return self.pin:receive(e)
end
self.env.terminal=self.terminal
end
function Box:run(e,...)
setfenv(e,self.env)
return e(...)
end
end
return Box