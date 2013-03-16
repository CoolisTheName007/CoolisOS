include'kernel.class'
class.Vec3()
function Vec3:__init(e,a,t)
if type(e)=='table'then
self.x=e.x or e[1]or 0
self.y=e.y or e[2]or 0
self.z=e.z or e[3]or 0
else
self.x=e or 0
self.y=a or 0
self.z=t or 0
end
end
local e=Vec3
local e=Vec3
local t=function(e)return classof(e)==Vec3 end
local a=classof
local i={
add=function(t,a)
return e(
t.x+a.x,
t.y+a.y,
t.z+a.z
)
end,
scalarAdd=function(t,a)
return e(
t.x+a,
t.y+a,
t.z+a
)
end,
subtract=function(t,a)
return e(
t.x-a.x,
t.y-a.y,
t.z-a.z
)
end,
scalarSubtract=function(t,a)
return e(
t.x-a,
t.y-a,
t.z-a
)
end,
dot=function(a,t)
return e(
a.x*t.x,
a.y*t.y,
a.z*t.z
)
end,
scalarMultiply=function(a,t)
return e(
a.x*t,
a.y*t,
a.z*t
)
end,
divide=function(t,a)
return e(
t.x/a.x,
t.y/a.y,
t.z/a.z
)
end,
scalarDivide=function(a,t)
return e(
a.x/t,
a.y/t,
a.z/t
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
distance=function(t,e)
return math.sqrt(
math.pow(e.x-t.x,2)
+math.pow(e.y-t.y,2)
+math.pow(e.z-t.z,2)
)
end,
distanceSq=function(t,e)
return(
math.pow(e.x-t.x,2)
+math.pow(e.y-t.y,2)
+math.pow(e.z-t.z,2)
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
cross=function(t,a)
return e(
t.y*a.z-t.z*a.y,
t.z*a.x-t.x*a.z,
t.x*a.y-t.y*a.x
)
end,
containedWithin=function(e,t,a)
return(
e.x>=t.x and e.x<=a.x
and e.y>=t.y and e.y<=a.y
and e.z>=t.z and e.z<=a.z
)
end,
clampX=function(t,a,o)
return e(
math.max(a,math.min(o,t.x)),
t.y,
t.z
)
end,
clampY=function(t,a,o)
return e(
t.x,
math.max(a,math.min(o,t.y)),
t.z
)
end,
clampZ=function(t,o,a)
return e(
t.x,
t.y,
math.max(o,math.min(a,t.z))
)
end,
floor=function(t)
return e(
math.floor(t.x),
math.floor(t.y),
math.floor(t.z)
)
end,
ceil=function(t)
return e(
math.ceil(t.x),
math.ceil(t.y),
math.ceil(t.z)
)
end,
round=function(t)
return e(
math.floor(t.x+.5),
math.floor(t.y+.5),
math.floor(t.z+.5)
)
end,
absolute=function(t)
return e(
math.abs(t.x),
math.abs(t.y),
math.abs(t.z)
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
getIntermediateWithX=function(t,a,i)
local o=a.x-t.x
local s=a.y-t.y
local n=a.z-t.z
if o*o<10000000116860974e-23 then
return nil
else
local a=(i-t.x)/o
return(
(a>=0 and a<=1)
and e(
t.x+o*a,
t.y+s*a,
t.z+n*a
)
or nil
)
end
end,
getIntermediateWithY=function(t,a,n)
local s=a.x-t.x
local o=a.y-t.y
local i=a.z-t.z
if o*o<10000000116860974e-23 then
return nil
else
local a=(n-t.y)/o
return(
(a>=0 and a<=1)
and e(
t.x+s*a,
t.y+o*a,
t.z+i*a
)
or nil
)
end
end,
getIntermediateWithZ=function(t,a,s)
local n=a.x-t.x
local i=a.y-t.y
local o=a.z-t.z
if o*o<10000000116860974e-23 then
return nil
else
local a=(s-t.z)/o
return(
(a>=0 and a<=1)
and e(
t.x+n*a,
t.y+i*a,
t.z+o*a
)
or nil
)
end
end,
rotateAroundX=function(t,a)
local a,o=math.cos(a),math.sin(a)
return e(
t.x,
t.y*a+t.z*o,
t.z*a-t.y*o
)
end,
rotateAroundY=function(t,a)
local o,a=math.cos(a),math.sin(a)
return e(
t.x*o+t.z*a,
t.y,
t.z*o-t.x*a
)
end,
rotateAroundZ=function(t,a)
local a,o=math.cos(a),math.sin(a)
return e(
t.x*a+t.y*o,
t.y*a-t.x*o,
t.z
)
end,
clone=function(t)
return e(
t.x,
t.y,
t.z
)
end,
equals=function(e,a)
if not t(e)or not t(a)then return false end
return(
a.x==e.x
and a.y==e.y
and a.z==e.z
)
end,
tostring=function(e)
return"("..e.x..", "..e.y..", "..e.z..")"
end,
getMinimum=function(a,t)
return e(
math.min(a.x,t.x),
math.min(a.y,t.y),
math.min(a.z,t.z)
)
end,
getMidpoint=function(t,a)
return e(
(t.x+a.x)/2,
(t.y+a.y)/2,
(t.z+a.z)/2
)
end,
serialize=function(e)
return{e.x,e.y,e.z}
end
}
local e={
__tostring=i.tostring,
__unm=function(e)return e:scalarMultiply(-1)end,
__add=function(e,o)
if type(o)=="number"and t(e)then
return e:scalarAdd(o)
elseif type(e)=="number"and t(o)then
return o:scalarAdd(e)
elseif t(e)and t(o)then
return e:add(o)
else
error("Attempt to perform vector addition on <"..a(e).."> and <"..a(o)..">")
end
end,
__sub=function(o,e)
if type(e)=="number"and t(o)then
return o:scalarSubtract(e)
elseif type(o)=="number"and t(e)then
return e:scalarSubtract(o)
elseif t(o)and t(e)then
return o:subtract(e)
else
error("Attempt to perform vector subtraction on <"..a(o).."> and <"..a(e)..">")
end
end,
__mul=function(e,o)
if type(o)=="number"and t(e)then
return e:scalarMultiply(o)
elseif type(e)=="number"and t(o)then
return o:scalarMultiply(e)
elseif t(e)and t(o)then
return e:dot(o)
else
error("Attempt to perform vector multiplication on <"..a(e).."> and <"..a(o)..">")
end
end,
__div=function(o,e)
if type(e)=="number"and t(o)then
return o:scalarDivide(e)
elseif type(o)=="number"and t(e)then
return e:scalarDivide(o)
elseif t(o)and t(e)then
return o:divide(e)
else
error("Attempt to perform vector division on <"..a(o).."> and <"..a(e)..">")
end
end,
__eq=i.equals,
__pow=i.cross,
}
util.shcopy(i,Vec3)
util.shcopy(e,Vec3)
return Vec3