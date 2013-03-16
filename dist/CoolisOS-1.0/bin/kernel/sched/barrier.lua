local o=require'kernel.checker'.check
PACKAGE_NAME='sched'
local t=require'init'
local a={__type='barrier'};a.__index=a
t.barriers=setmetatable({},{__mode='kv'})
function barrier(e)
o('integer',e)
local e={n=e}
if t.barriers then
t.barriers[tostring(e):match(':.(.*)')]=e
end
setmetatable(e,a)
return e
end
a.reach=function(e)
if e.n<=1 then
e.n=0
t.signal(e,'zero')
else
e.n=e.n-1
t.wait(e,'zero')
end
end
return barrier