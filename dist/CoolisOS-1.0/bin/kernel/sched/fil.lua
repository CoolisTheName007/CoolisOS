local s,t=next,setmetatable
Fil=t({},{__tostring='Class Fil'})
Fil.meta={
__index=Fil,
__tostring=function(e)
local o=getmetatable(e)
t(e,nil)
local a=stringify(e,nil,nil,nil,nil,3)
t(e,o)
return a
end,
}
Fil.new=function()
return t({},Fil.meta)
end
Fil.multiset=function(e,o,a)
if a~=nil then
for o,i in pairs(o)do
local t=e[o]
if not t then
t={}
e[o]=t
end
local e
for o=1,#i do
e=i[o]
t[e]=a
end
end
else
for n,i in pairs(o)do
local t=e[n]
if t then
local o
for e=1,#i do
o=i[e]
t[o]=a
end
if not s(t)then e[n]=nil end
end
end
end
return true
end
Fil.get=function(e,t,a)
if e[t]then return e[t][a]end
end
Fil.uniset=function(a,t,i,o)
local e=a[t]
if o~=nil then
if not e then
e={}
a[t]=e
end
e[i]=o
else
if e then
e[i]=nil
end
end
end
return Fil