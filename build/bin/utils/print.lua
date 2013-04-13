local e=io
local u=string
local a=table
local d=type
local i=tostring
local l=pairs
local c=print
local m=getmetatable
local t=select
env=getfenv()
setmetatable(env,nil)
mtostring=function(...)
local e={}
for o=1,t('#',...)do
a.insert(e,i(t(o,...)))
end
return a.concat(e,';')
end
if e and e.stdout then
e.stdout:setvbuf("line")
end
local function f(t)
local function a(e)return
e=='"'and'\\"'or
e=='\\'and'\\\\'or
u.format('\\%03d',e:byte())
end
return'"'..t:gsub('[%z\1-\9\11\12\14-\31\128-\255"\\]',a)..'"'
end
function vprint(e,h,...)
local r={}
local o=0
local t=a.insert
local function s(t)
local n=d(t)
if n=="string"then e(f(t))
elseif n=="boolean"then e(t and"true"or"false")
elseif n=="number"then e(i(t))
elseif n=="nil"then e("nil")
elseif n=="table"then
if m(t)and m(t).__tostring then e(i(t))
elseif r[t]then e(i(a))else
r[t]=true
o=o+1
local function u()
if h then e(",\r\n"..(" "):rep(h*o))
else e(", ")end
end
local a,i=false,false
for e in l(t)do
if a then i=true;break
else a=true end
end
if not a then e"{ }";return
elseif not i or not h then e"{ "
else e("{\r\n"..(" "):rep(h*o))end
local i={}
local a=0
repeat
local e=a+1
local t=t[e]~=nil
if t then i[e]=true;a=e end
until not t
for e=1,a do
if e>1 then u()end
s(t[e])
end
local n=true
for t,o in l(t)do
if not i[t]then
if not n or a~=0 then u()end
n=false
if d(t)=="string"and t:match"^[%a_][%w_]*$"then e(t.." = ")
else e("[");s(t);e("] = ")end
s(o)
end
end
e(" }")
o=o-1
r[t]=nil
end
else e(i(t))end
end
local o={...}
local a=a.getn(o)
for t=1,a do s(o[t]);if t<a then e"\t"end end
end
function p(...)
local e={}
local function o(t)
a.insert(e,t)
end
vprint(o,3,...)
c(a.concat(e))
end
function siprint(o,...)
local t,e=a.insert,{}
vprint(function(a)return t(e,a)end,o,...)
return a.concat(e)
end
function sprint(...)
return siprint(false,...)
end
function printf(...)return c(u.format(...))end
return env