include'kernel.class'
local a=require'kernel.gui.Point'
class.Rectangle()
function Rectangle:__init(e,t,a,o)
self:assign(e,t,a,o)
end
function Rectangle:assign(e,t,o,i)
if(not t)then
self.s=e.s:clone()
self.e=e.e:clone()
elseif(not o)then
self.s=e:clone()
self.e=t:clone()
else
self.s=a(e,t)
self.e=a(o,i)
end
return self
end
function Rectangle:size()
return self.e:clone():sub(self.s)
end
function Rectangle:clone()
return Rectangle(self)
end
function Rectangle:move(e,t)
self.s:add(e,t)
self.e:add(e,t)
return self
end
function Rectangle:grow(e,t)
self.s:sub(e,t)
self.e:add(e,t)
return self
end
function Rectangle:intersect(a)
local t,e=self.s,self.e
t.x=max(t.x,a.s.x)
t.y=max(t.y,a.s.y)
e.x=min(e.x,a.e.x)
e.y=min(e.y,a.e.y)
return self
end
function Rectangle:union(e)
local a,t=self.s,self.e
a.x=min(a.x,e.s.x)
a.y=min(a.y,e.s.y)
t.x=max(t.x,e.e.x)
t.y=max(t.y,e.e.y)
return self
end
function Rectangle:equal(e)
return self.s:equal(e.s)and self.e:equal(e.e)
end
function Rectangle:contains(t,e)
return t>=self.s.x and t<self.e.x and e>=self.s.y and e<self.e.y
end
function Rectangle:empty()
return self.s.x>=self.e.x or self.s.y>=self.e.y
end
function Rectangle:nempty()
return not self:empty()
end
function Rectangle:__tostring()
if(self:empty())then
return'rect (empty)'
else
return'rect ('..self.s:tostring()..','..self.e:tostring()..')'
end
end
return Rectangle