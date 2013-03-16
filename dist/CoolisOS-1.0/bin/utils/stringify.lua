local a,y,m,d,c,n,f,w,p=type,os,write,tostring,tonumber,string,getmetatable,pairs,table
local i
i=function(e,t,l,s,r,h,u,o)
local a=a(t)
if a=="string"then
e[#e+1]=(
s~="\n"and n.gsub(n.format("%q",t),"\\\n","\\n")
or n.format("%q",t)
)
elseif a=="boolean"then
e[#e+1]=t and"true"or"false"
elseif a=="number"then
e[#e+1]=d(t)
elseif a=="function"then
local t=d(t)
e[#e+1]="function"
e[#e+1]=":("
if true then
e[#e+1]=t
else
end
e[#e+1]=")"
elseif a=="table"then
if h[t]or o==u or(f(t)and f(t).__tostring)then
e[#e+1]="<"..d(t)..">"
else
o=o+1
h[t]=true
e[#e+1]="{"..s
for t,a in w(t)do
e[#e+1]=n.rep(l,r).."["
i(e,t,l,s,r+1,h,u,o)
e[#e+1]="] = "
i(e,a,l,s,r+1,h,u,o)
e[#e+1]=","..s
end
e[#e+1]=n.rep(l,r-1).."}"
o=o-1
end
elseif a=="nil"then
e[#e+1]="nil"
else
e[#e+1]=a.."<"..d(t)..">"
end
end
local o=function(s,e,n,o,t,a)
local e={}
i(
e,
s,
n or"  ",o or"\n",
(c(t)or 0)+1,
{},
a,
0
)
return p.concat(e)
end
local e=function(t,a)
local e={}
i(
e,
t,
spacing_h or"  ",spacing_v or"\n",
(c(preindent)or 0)+1,
{},
a,
0
)
for t=1,#e,10 do
m(e[t])
y.pullEvent('key')
end
m('\n')
end
M={stringify=o,_stringify=i,dprint=e}
return M