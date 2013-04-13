include'kernel.class'
local e=require'kernel.checker'.check
class.Point()
function Point:__init(t,e)
return self:assign(t,e)
end
function Point:assign(t,a)
if(not a)then
e('Point',t)
self.x=t.x
self.y=t.y
else
e('number,number',t,a)
self.x=t
self.y=a
end
return self
end
function Point:clone()
return Point(self)
end
function Point:add(t,a)
if(not a)then
e('Point',t)
self.x=self.x+t.x
self.y=self.y+t.y
else
e('number,number',t,a)
self.x=self.x+t
self.y=self.y+a
end
return self
end
function Point:sub(t,a)
if(not a)then
e('Point',t)
return self:add(-t.x,-t.y)
else
e('number,number',t,a)
return self:add(-t,-a)
end
end
function Point:equal(t)
e('Point',t)
return self.x==t.x and self.y==t.y
end
function Point:__tostring()
return'('..self.x..','..self.y..')'
end
return Point
