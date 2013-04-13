include'kernel.class'
local i=require'kernel.log'
local n=require'kernel.checker'.check
local o=require'kernel.sched'
local t=setmetatable({},{__mode='kv'})
class.Catalog()
local a=Catalog
a.named=t
function a:__init()
self.objs=setmetatable({},{__mode='kv'})
end
function a:register(e,a)
if type(e)~='table'then error('not a table',2)end
if self.objs[a]~=e then error('name taken',2)end
self.objs[e]=a
self.objs[a]=e
o.signal(self,'+'..a,e)
t[e]=t[e]or setmetatable({},{__mode='kv'})
t[e][self]=true
end
function a:unregister(e)
local a=self.objs[e]
local i=type(a)=='string'and a or e
self.objs[a]=nil
self.objs[e]=nil
if t[obj]then
t[obj][self]=nil
end
o.signal(self,'-'..i,obj)
end
function a:waitFor(e,a)
n('string',e)
i('catalog','INFO','catalog %s queried for name "%s" by %s',self,e,o.me())
local t
if self[e]then return self[e]else
local a,o,e=o.wait(self,'+'..e,a)
if a==self then t=e end
end
i('catalog','INFO','catalog %s queried for name "%s" by %s, found %s',self,e,o.me(),t)
return t
end
return a