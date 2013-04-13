include'kernel.class'
class.Vec3()
function Vec3:__init(e,t,a)
if type(e)=='table'then
self.x=e.x or e[1]or 0
self.y=e.y or e[2]or 0
self.z=e.z or e[3]or 0
else
self.x=e or 0
self.y=t or 0
self.z=a or 0
end
end
local e=Vec3
local t=Vec3
local e=function(e)return classof(e)==Vec3 end
local a=ofType
local i={
add=function(e,t)
e.x=e.x+t.x
e.y=e.y+t.y
e.z=e.z+t.z
return e
end,
scalarAdd=function(e,t)
e.x=e.x+t
e.y=e.y+t
e.z=e.z+t
return e
end,
subtract=function(e,t)
e.x=e.x-t.x
e.y=e.y-t.y
e.z=e.z-t.z
return e
end,
scalarSubtract=function(e,t)
return e:scalarAdd(-t)
end,
eldot=function(e,t)
e.x=e.x*t.x
e.y=e.y*t.y
e.z=e.z*t.z
return e
end,
scalarMultiply=function(e,t)
e.x=e.x*t
e.y=e.y*t
e.z=e.z*t
return e
end,
divide=function(a,e)
return t(
a.x/e.x,
a.y/e.y,
a.z/e.z
)
end,
scalarDivide=function(a,e)
return t(
a.x/e,
a.y/e,
a.z/e
)
end,
length=function(e)
return math.sqrt(
e.x*e.x
+e.y*e.y
+e.z*e.z
)
end,
lengthSq=function(e)
return(
e.x*e.x
+e.y*e.y
+e.z*e.z
)
end,
distance=function(e,t)
return math.sqrt(
math.pow(t.x-e.x,2)
+math.pow(t.y-e.y,2)
+math.pow(t.z-e.z,2)
)
end,
distanceSq=function(e,t)
return(
math.pow(t.x-e.x,2)
+math.pow(t.y-e.y,2)
+math.pow(t.z-e.z,2)
)
end,
normalize=function(e)
return e:scalarDivide(e:length())
end,
dot=function(t,e)
return(
t.x*e.x
+t.y*e.y
+t.z*e.z
)
end,
cross=function(e,a)
return t(
e.y*a.z-e.z*a.y,
e.z*a.x-e.x*a.z,
e.x*a.y-e.y*a.x
)
end,
containedWithin=function(e,t,a)
return(
e.x>=t.x and e.x<=a.x
and e.y>=t.y and e.y<=a.y
and e.z>=t.z and e.z<=a.z
)
end,
clampX=function(e,o,a)
return t(
math.max(o,math.min(a,e.x)),
e.y,
e.z
)
end,
clampY=function(e,o,a)
return t(
e.x,
math.max(o,math.min(a,e.y)),
e.z
)
end,
clampZ=function(e,o,a)
return t(
e.x,
e.y,
math.max(o,math.min(a,e.z))
)
end,
floor=function(e)
return t(
math.floor(e.x),
math.floor(e.y),
math.floor(e.z)
)
end,
ceil=function(e)
return t(
math.ceil(e.x),
math.ceil(e.y),
math.ceil(e.z)
)
end,
round=function(e)
return t(
math.floor(e.x+.5),
math.floor(e.y+.5),
math.floor(e.z+.5)
)
end,
absolute=function(e)
return t(
math.abs(e.x),
math.abs(e.y),
math.abs(e.z)
)
end,
isCollinearWith=function(e,t)
if e.x==0 and e.y==0 and e.z==0 then
return true
end
local a,i,o=t.x,t.y,t.z
if a==0 and i==0 and o==0 then
return true
end
if(e.x==0)~=(a==0)then return false end
if(e.y==0)~=(i==0)then return false end
if(e.z==0)~=(o==0)then return false end
local a=a/e.x
if a==a then
return t:equals(e:scalarMultiply(a))
end
local a=i/e.y
if a==a then
return t:equals(e:scalarMultiply(a))
end
local a=o/e.z
if a==a then
return t:equals(e:scalarMultiply(a))
end
end,
getIntermediateWithX=function(e,a,s)
local o=a.x-e.x
local i=a.y-e.y
local n=a.z-e.z
if o*o<10000000116860974e-23 then
return nil
else
local a=(s-e.x)/o
return(
(a>=0 and a<=1)
and t(
e.x+o*a,
e.y+i*a,
e.z+n*a
)
or nil
)
end
end,
getIntermediateWithY=function(e,a,s)
local i=a.x-e.x
local o=a.y-e.y
local n=a.z-e.z
if o*o<10000000116860974e-23 then
return nil
else
local a=(s-e.y)/o
return(
(a>=0 and a<=1)
and t(
e.x+i*a,
e.y+o*a,
e.z+n*a
)
or nil
)
end
end,
getIntermediateWithZ=function(e,a,s)
local n=a.x-e.x
local i=a.y-e.y
local o=a.z-e.z
if o*o<10000000116860974e-23 then
return nil
else
local a=(s-e.z)/o
return(
(a>=0 and a<=1)
and t(
e.x+n*a,
e.y+i*a,
e.z+o*a
)
or nil
)
end
end,
rotateAroundX=function(e,a)
local o,a=math.cos(a),math.sin(a)
return t(
e.x,
e.y*o+e.z*a,
e.z*o-e.y*a
)
end,
rotateAroundY=function(e,a)
local o,a=math.cos(a),math.sin(a)
return t(
e.x*o+e.z*a,
e.y,
e.z*o-e.x*a
)
end,
rotateAroundZ=function(e,a)
local a,o=math.cos(a),math.sin(a)
return t(
e.x*a+e.y*o,
e.y*a-e.x*o,
e.z
)
end,
clone=function(e)
return Vec3(e)
end,
equals=function(t,a)
if not e(t)or not e(a)then return false end
return(
a.x==t.x
and a.y==t.y
and a.z==t.z
)
end,
tostring=function(e)
return"("..e.x..", "..e.y..", "..e.z..")"
end,
getMinimum=function(e,a)
return t(
math.min(e.x,a.x),
math.min(e.y,a.y),
math.min(e.z,a.z)
)
end,
getMidpoint=function(a,e)
return t(
(a.x+e.x)/2,
(a.y+e.y)/2,
(a.z+e.z)/2
)
end,
__serialize=function(e)
return{e.x,e.y,e.z}
end
}
local e={
__tostring=i.tostring,
__unm=function(e)return e:scalarMultiply(-1)end,
__add=function(t,o)
if type(o)=="number"and e(t)then
return t:clone():scalarAdd(o)
elseif type(t)=="number"and e(o)then
return o:clone():scalarAdd(t)
elseif e(t)and e(o)then
return t:clone():add(o)
else
error("Attempt to perform vector addition on <"..a(t).."> and <"..a(o)..">")
end
end,
__sub=function(o,t)
if type(t)=="number"and e(o)then
return o:clone():scalarSubtract(t)
elseif type(o)=="number"and e(t)then
return t:clone():scalarSubtract(o)
elseif e(o)and e(t)then
return o:clone():subtract(t)
else
error("Attempt to perform vector subtraction on <"..a(o).."> and <"..a(t)..">")
end
end,
__mul=function(o,t)
if type(t)=="number"and e(o)then
return o:scalarMultiply(t)
elseif type(o)=="number"and e(t)then
return t:scalarMultiply(o)
elseif e(o)and e(t)then
return o:dot(t)
else
error("Attempt to perform vector multiplication on <"..a(o).."> and <"..a(t)..">")
end
end,
__div=function(t,o)
if type(o)=="number"and e(t)then
return t:scalarDivide(o)
elseif type(t)=="number"and e(o)then
return o:scalarDivide(t)
elseif e(t)and e(o)then
return t:divide(o)
else
error("Attempt to perform vector division on <"..a(t).."> and <"..a(o)..">")
end
end,
__eq=i.equals,
__pow=i.cross,
}
util.shcopy(i,Vec3)
util.shcopy(e,Vec3)
return Vec3