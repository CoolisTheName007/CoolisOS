table=require'utils.table'
local e,o
local i,t=pcall,xpcall
function o(a,t,o,...)
if not o then
return false,a(...)
end
if coroutine.status(t)=='suspended'then
return e(a,t,coroutine.yield(...))
else
return true,...
end
end
function e(t,e,...)
return o(t,e,coroutine.resume(e,...))
end
function coxpcall(t,n,...)
local o,a=i(coroutine.create,t)
if not o then
local e=table.pack(...)
local e=function()return t(unpack(e,1,e.n))end
a=coroutine.create(e)
end
return e(n,a,...)
end
local function e(e,...)
return...
end
function copcall(t,...)
return coxpcall(t,e,...)
end
