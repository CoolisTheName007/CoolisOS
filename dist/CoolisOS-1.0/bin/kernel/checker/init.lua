local a=require'kernel.class'.ofType
custom={}
function conforms(e,t)
return e=="?"
or(e:sub(1,1)=="?"and(t==nil or conforms(e:sub(2,-1),t)))
or a(t)==e
or(custom[e]and custom[e](t))
end
function check_one(e,t)
for e in e:gmatch('|?([^|]*)|?')do
if conforms(e,t)then return true end
end
return false
end
function check(t,...)
local e=0
for t in t:gmatch(',?([^,]*),?')do
e=e+1
if not check_one(t,select(e,...))then
error('arg number '..e..':'..tostring(select(e+1,...),nil)..'of type '..tostring(type(select(e+1,...)))..' is not of type '..t,3)
end
end
end