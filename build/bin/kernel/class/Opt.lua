class.Opt()
function Opt:__init(e,t,...)
self.typ=t or(typeof(e))
self.val=e
self.args={...}
end
function Opt:drop(a,e,o)
local t=self.typ
if t=='req'then
if e==nil then error(string.format('parameter %s required',tostring(o)))
else return e end
elseif t=='function'then return self.val(unpack(self.args))
elseif t=='raw'then
if e==nil then return self.val else return e end
elseif t=='object'then return e==nil and(self.val.clone and self.val:clone()or self.val.__class(self.val))or e
elseif t=='class'then return self.val(unpack(self.args))
elseif t=='table'then
a=a or{}
e=e or{}
for t,o in pairs(self.val)do
if classof(o)==Opt then
a[t]=o:drop(nil,e[t],t)
else
if e[t]~=nil then
o=e[t]
end
a[t]=o
end
end
return a
end
end
return Opt