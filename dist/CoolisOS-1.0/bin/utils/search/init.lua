local o=fs
local i=string
local l=getfenv()
setmetatable(l,nil)
function iterTree(a,h)
a=a or''
if a=='/'then a=''end
local i={0}
local n={0}
local t={{a,o.list(a),{}}}
local e=1
local s
return function()
repeat
i[e]=i[e]+1
name=t[e][2][i[e]]
if name==nil then
if(not t[e][4])and t[e][3][1]then
t[e][4]=true
t[e][2],t[e][3]=t[e][3],t[e][2]
i[e]=0
else
e=e-1
if e==0 then return end
a=t[e][1]
end
else
s=t[e][1]..'/'..name
if o.isDir(s)then
if t[e][4]then
if h~=e then
e=e+1
a=s
t[e]={a,o.list(a),{}}
i[e]=0
n[e]=0
end
else
n[e]=n[e]+1
t[e][3][n[e]]=name
break
end
else
break
end
end
until false
return a..'/'..name
end
end
function iterFiles(e,t)
local t=iterTree(e,t)
local e
return function()
repeat
e=t()
if e then
if not o.isDir(e)then
return e
end
else
return
end
until false
end
end
function iterDir(t,e)
local t=iterTree(t,e)
local e
return function()
repeat
e=t()
if e then
if o.isDir(e)then
return e
end
else
return
end
until false
end
end
local function d(o)
local t="^"
local e=0
local a
local function r()
if a=='\\'then
e=e+1;a=i.sub(o,e,e)
if a==''then
t='[^]'
return false
end
end
return true
end
local function n(e)
return e:match("^%w$")and e or'%'..e
end
local function h()
while 1 do
if a==''then
t='[^]'
return false
elseif a==']'then
t=t..']'
break
else
if not r()then break end
local s=a
e=e+1;a=i.sub(o,e,e)
if a==''then
t='[^]'
return false
elseif a=='-'then
e=e+1;a=i.sub(o,e,e)
if a==''then
t='[^]'
return false
elseif a==']'then
t=t..n(s)..'%-]'
break
else
if not r()then break end
t=t..n(s)..'-'..n(a)
end
elseif a==']'then
t=t..n(s)..']'
break
else
t=t..n(s)
e=e-1
end
end
e=e+1;a=i.sub(o,e,e)
end
return true
end
local function s()
e=e+1;a=i.sub(o,e,e)
if a==''or a==']'then
t='[^]'
return false
elseif a=='^'or a=='!'then
e=e+1;a=i.sub(o,e,e)
if a==']'then
else
t=t..'[^'
if not h()then return false end
end
else
t=t..'['
if not h()then return false end
end
return true
end
while 1 do
e=e+1;a=i.sub(o,e,e)
if a==''then
t=t..'$'
break
elseif a=='#'then
t=t..'.'
elseif a=='*'then
t=t..'.*'
elseif a=='['then
if not s()then break end
elseif a=='\\'then
e=e+1;a=i.sub(o,e,e)
if a==''then
t=t..'\\$'
break
end
t=t..n(a)
else
t=t..n(a)
end
end
return t
end
local function u(a)
local o={}
local e
local t=0
for a in i.gmatch(a,'[\\/]*([^/\\]+)[\\/]*')do
if a:match('^[%w%s%.]*$')then
e=e and e..'/'..a or a
else
t=t+1
o[t]={e,d(a)}
e=nil
end
end
if e then
if t==0 then
t=t+1
o[t]={e}
else
o[t][3]=e
end
end
return o
end
local function c(n)
local d=#n
if d==0 then return function()return end end
if d==1 and not n[1][2]and o.exists(n[1][1])then
local e=false
return function()
if not e then
e=true
return n[1][1]
else
return
end
end
end
local a=n[1][1]
local s={0}
local r
r={{a,o.isDir(a)and o.list(a)or{}}}
local e=1
local t
local h
return function()
repeat
s[e]=s[e]+1
name=r[e][2][s[e]]
if name==nil then
s[e]=nil
e=e-1
if e==0 then return end
a=r[e][1]
else
if i.match(name,n[e][2])then
t=a..'/'..name
if e==d then
h=n[e][3]
if h then
t=t..'/'..h
if o.exists(t)then
path=t
break
end
else
path=t
break
end
elseif o.isDir(t)then
e=e+1
h=n[e][1]
if h then
t=t..'/'..h
if o.exists(t)then
a=t
r[e]={a,o.list(a)}
s[e]=0
else
e=e-1
end
else
a=t
r[e]={a,o.list(a)}
s[e]=0
end
end
end
end
until false
return path,s
end
end
function iterGlob(e)
return c(u(e))
end
searchGlob=function(e,t)
e=i.gsub(e,'%?',t)
local t=iterGlob(e)
local e
return function()
repeat
e=t()
if e then
if not o.isDir(e)then
return e
end
else
break
end
until false
end
end
function getNameExpansion(e)
local o,o,a,t=i.find(e,'([^%./\\]*)%.(.*)$')
return a or e,t
end
function getDir(e)
return i.match(e,'^(.*)/')or'/'
end
searchTree=function(e,t)
if not e:match('%?')and o.isDir(e)then
if e=='/'then e=''end
local a=iterFiles(e)
local e
return function()
repeat
e=a()
if e then
if i.match(e,t..'$')and not i.match(e,'[^/]'..t..'$')then
return e
end
else
break
end
until false
end
else
return function()end
end
end
return l