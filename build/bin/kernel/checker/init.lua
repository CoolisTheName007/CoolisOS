local o=require'kernel.class'.classname
custom={}
function conforms(e,t)
local a=e:sub(1,1)
return e=="?"
or(a=="?"and(t==nil or conforms(e:sub(2,-1),t)))
or(a=="!"and not(conforms(e:sub(2,-1),t)))
or type(t)==e
or o(t)==e
or(custom[e]and custom[e](t))
end
function check_one(t,e)
for t in t:gmatch('|?([^|]+)|?')do
if conforms(t,e)then return true end
end
return false
end
function check(t,...)
if type(t)~='string'then error('arg1 is not of type string',2)end
local e=0
for t in t:gmatch(',?([^,]+),?')do
e=e+1
if not check_one(t,select(e,...))then
local e=string.format(
'arg%d:(%s) is not of type (%s);\n args=%s',
e,tostring((debug and debug.getinfo or type)((select(e,...)))),t,
(debug.args_tostring(...)))
error(e,3)
end
end
end