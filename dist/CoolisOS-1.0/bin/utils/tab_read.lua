local s={}
do
local n,h,e,r
local function d(n,e,t)
local i={}
local a
local o=0
e=e or 1
t=t or#n
for e=e,t do
local e=n[e]
if not e then break
elseif e==''then
o=o+1
else
table.insert(i,a)
a=e
end
end
table.insert(i,a)
return table.concat(i,'.',1,t-e+1-o)
end
function h(a,e)
local t=type(e)=='string'and n(e)or e
local e=table.remove(t)
if not e then return a end
local t=r(a,t)
return t and t[e]
end
function n(a)
local i={}
local o,t,e=1
repeat
t=a:find(".",o,true)or#a+1
e=a:sub(o,t-1)
e=tonumber(e)or e
if e and e~=""then table.insert(i,e)end
o=t+1
until t==#a+1
return i
end
function r(a,e,o)
e=type(e)=="string"and n(e)or e
for n,i in ipairs(e)do
local t=a[i]
if type(t)~="table"then
if not o or(o=="noowr"and t~=nil)then return nil,d(e,1,n)
else t={}a[i]=t end
end
a=t
end
return a
end
s.get=h
end
local function r(e,a)
a=a or _G
e=e or""
e=e:match("([%w_][%w_%.%:]*)$")or""
local e,i,t=e:match("(.-)([%.%:]?)([^%.%:]*)$")
local n=s.get(a,e)
local s=i==":"
local a={}
local function o(e,i)
if type(e)~='table'then return end
for a,e in pairs(e)do
local o=type(e)
if type(a)=='string'and a:match("^"..t)and(not s or o=='function'or(o=='table'and getmetatable(e)and getmetatable(e).__call))then i[a]=true end
end
end
o(n,a)
if i==":"or i=="."then
local e=getmetatable(n)
if e then
local t,i=e.__index,e.__newindex
o(t,a)
if i~=t then o(i,a)end
if e~=t and e~=i then o(e,a)end
end
end
local e={}
for t,a in pairs(a)do table.insert(e,t)end
table.sort(e)
if t==e[1]then
local t=n[t]
local a=type(t)
if a=='function'then e[1]=e[1].."("
elseif getmetatable(t)and getmetatable(t).__index then
e[1]=e[1]..":"
elseif a=='table'then e[1]=e[1].."."
end
end
t=t or''
return e,t:len()
end
local function m(t,e)
if t:sub(e,e)==' 'then
return''
end
local t=t:reverse()
sLeft=t:match('[^_]*',t:len()-e):reverse()
return sLeft
end
local function i(e)
return(e:gsub('%%','%%%%')
:gsub('%^','%%%^')
:gsub('%$','%%%$')
:gsub('%(','%%%(')
:gsub('%)','%%%)')
:gsub('%.','%%%.')
:gsub('%[','%%%[')
:gsub('%]','%%%]')
:gsub('%*','%%%*')
:gsub('%+','%%%+')
:gsub('%-','%%%-')
:gsub('%?','%%%?'))
end
function get_fs_matches(t)
local e={}
local t=t:match([[[^%[%]%'%"]+$]])or""
local a,o,t=t:match("^(.-)([/\\]?)([^/\\]*)$")
local o=_G.shell and _G.shell.resolve(a)or a
if fs.isDir(o)then
local a,o=pcall(fs.list,o)
if a then
local a=nil
local t="^"..i(t)..'.*'
for i,o in ipairs(o)do
a=string.match(o,t)
if a then
table.insert(e,a)
end
end
end
end
table.sort(e)
if t==e[1]then
local a=e[1]
if fs.isDir(o..'/'..t)then
e[1]=e[1]..'/'
end
end
return e,t:len()
end
local function c(o,s,i,e)
local l=e==nil or e==true
term.setCursorBlink(true)
local t=""
local n=nil
local e=0
if o then
o=string.sub(o,1,1)
end
local h=0
local a={n=0}
function reset_matches()
a={n=0}
end
function get_matches(e)
if l then
return get_fs_matches(e)
else
return r(e,i)
end
end
local u,i=term.getSize()
local r,d=term.getCursorPos()
local function i(i)
local a=0
if r+e>=u then
a=(r+e)-u
end
term.setCursorPos(r,d)
local o=i or o
if o then
term.write(string.rep(o,string.len(t)-a))
else
term.write(string.sub(t,a+1))
end
term.setCursorPos(r+e-a,d)
end
while true do
local r,o=os.pullEvent()
if r=="char"then
reset_matches()
t=string.sub(t,1,e)..o..string.sub(t,e+1)
e=e+1
i()
elseif r=="key"then
if not(o==keys.tab)then
reset_matches()
end
if not(o==keys.rightShift)then
h=0
end
if o==keys.enter then
break
elseif o==keys.tab then
if a[1]then
local o=string.len(a[a.n])
a.n=(a.n)%#a+1
if string.len(a[a.n])<o then i(" ")end
t=string.sub(t,1,e-o)..a[a.n]..string.sub(t,e+1)
e=e-o+a[a.n]:len()
i()
else
a,len=get_matches(m(t,e))
a.n=0
if#a>0 then
a.n=1
local o=len
t=string.sub(t,1,e-o)..a[a.n]..string.sub(t,e+1)
e=e-o+a[a.n]:len()
i()
end
if#a==1 then reset_matches()end
end
elseif o==keys.rightShift then
h=(h+1)%2
if h==0 then
l=not l
end
reset_matches()
elseif o==keys.left then
if e>0 then
e=e-1
i()
end
elseif o==keys.right then
if e<string.len(t)then
e=e+1
i()
end
elseif o==keys.up or o==keys.down then
if s then
i(" ");
if o==keys.up then
if n==nil then
if#s>0 then
n=#s
end
elseif n>1 then
n=n-1
end
else
if n==#s then
n=nil
elseif n~=nil then
n=n+1
end
end
if n then
t=s[n]
e=string.len(t)
else
t=""
e=0
end
i()
end
elseif o==keys.backspace then
if e>0 then
i(" ");
t=string.sub(t,1,e-1)..string.sub(t,e+1)
e=e-1
i()
end
elseif o==keys.home then
e=0
i()
elseif o==keys.delete then
if e<string.len(t)then
i(" ");
t=string.sub(t,1,e)..string.sub(t,e+2)
i()
end
elseif o==keys["end"]then
e=string.len(t)
i()
end
end
end
term.setCursorBlink(false)
term.setCursorPos(u+1,d)
print()
return t
end
local function e()
a=setmetatable({},{__index={b=1,c=function()end},__newindex={},__tostring=function()return'aaa'end})
repeat
c(nil,nil,getfenv(),false)
print()
until false
end
return c
