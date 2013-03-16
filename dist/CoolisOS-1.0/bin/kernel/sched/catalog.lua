local d=require'kernel.log'
local s=require'kernel.checker'.check
local r=sched
local e,l,i,e
=next,setmetatable,tostring,getmetatable
local a={}
local e
local t
a.register=function(o,n,h)
s('catalog,string',o,n)
if o[n]and o[n]~=h then
return nil,'used'
end
d('CATALOG','INFO','%s registered in catalog %s as "%s"',
i(h),e[t][o],n)
o[n]=h
e[o][h]=n
r.signal('catalog',e[t][o]..'+'..n,h)
return true
end
a.unregister=function(o,n)
s('catalog',o)
if type(n)=='string'then
e[o][o[n]]=nil
o[n]=nil
else
o[e[o][n]]=nil
e[o][n]=nil
end
d('CATALOG','INFO','%s unregistered from catalog %s, had name "%s"',
i(object),e[t][o],name)
r.signal('catalog',e[t][o]..'-'..name,object)
return true
end
a.waitfor=function(t,e,o)
s('catalog,string,?number',t,e,o)
d('catalog','INFO','catalog %s queried for name "%s" by %s',i(t),e,i(r.me()))
local o=t[e]or select(3,r.wait('catalog',get_register_event(t,e),o))
d('catalog','INFO','catalog %s queried for name "%s" by %s, found %s',i(t),e,i(r.me()),i(o))
return o
end
a.get_catalog=function(o)
s('string',o)
if t[o]then
return t[o]
else
local i=l({},{__mode='v',__type='catalog',__tostring=function()return o end,__index=a})
e[i]={}
a.register(t,o,i)
return i
end
end
a._reset=function()
e={}
t=l({},{__tostring=function()return'catalogs'end,__type='catalog',__index=a})
e[t]={}
e[t][t]='catalogs'
end
l(a,{__call=function(t,...)
local e=select('#',...)
if e==3 then
s('catalog,string',catalogd,name)
return t.register(...)
elseif e==1 then
s('string',...)
return t.get_catalog(...)
end
end})
return a