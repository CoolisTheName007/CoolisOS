local h={}
function h.main()
h.env=getfenv()
local y=sched.pipe()
sched.task(sched.pump):run(
terminal.pout,
function(e)if e[2]=='char'or e[2]=='key'then table.remove(e,1)return e end end,
y)
local a=terminal.term:wrap()
function write(e)
local n,t=a.getSize()
local o,i=a.getCursorPos()
local s=0
local function h()
if i+1<=t then
a.setCursorPos(1,i+1)
else
a.setCursorPos(1,t)
a.scroll(1)
end
o,i=a.getCursorPos()
s=s+1
end
while string.len(e)>0 do
local t=string.match(e,"^[ \t]+")
if t then
a.write(t)
o,i=a.getCursorPos()
e=string.sub(e,string.len(t)+1)
end
local t=string.match(e,"^\n")
if t then
h()
e=string.sub(e,2)
end
local t=string.match(e,"^[^ \t\n]+")
if t then
e=string.sub(e,string.len(t)+1)
if string.len(t)>n then
while string.len(t)>0 do
if o>n then
h()
end
a.write(t)
t=string.sub(t,(n-o)+2)
o,i=a.getCursorPos()
end
else
if o+string.len(t)-1>n then
h()
end
a.write(t)
o,i=a.getCursorPos()
end
end
end
return s
end
function print(...)
local e=0
for a,t in ipairs({...})do
e=e+write(tostring(t))
end
e=e+write("\n")
return e
end
function printError(...)
if a.isColour()then
a.setTextColour(colours.red)
end
print(...)
a.setTextColour(colours.white)
end
local s={}
do
local i,n,e,h
local function r(n,e,t)
local a={}
local o
local i=0
e=e or 1
t=t or#n
for e=e,t do
local e=n[e]
if not e then break
elseif e==''then
i=i+1
else
table.insert(a,o)
o=e
end
end
table.insert(a,o)
return table.concat(a,'.',1,t-e+1-i)
end
function n(t,e)
local e=type(e)=='string'and i(e)or e
local a=table.remove(e)
if not a then return t end
local e=h(t,e)
return e and e[a]
end
function i(a)
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
function h(a,e,o)
e=type(e)=="string"and i(e)or e
for n,i in ipairs(e)do
local t=a[i]
if type(t)~="table"then
if not o or(o=="noowr"and t~=nil)then return nil,r(e,1,n)
else t={}a[i]=t end
end
a=t
end
return a
end
s.get=n
end
local function r(e,a)
a=a or _G
e=e or""
e=e:match("([%w_][%w_%.%:]*)$")or""
if e==''then e='.'end
local e,n,t=e:match("$(.-)([%.%:]?)([^%.%:]*)$")
local i=s.get(a,e)
local s=n==":"
local a={}
local function o(e,i)
if type(e)~='table'then return end
for a,e in pairs(e)do
local o=type(e)
if type(a)=='string'and a:match("^"..t)and(not s or o=='function'or(o=='table'and getmetatable(e)and getmetatable(e).__call))then i[a]=true end
end
end
o(i,a)
if n==":"or n=="."then
local e=getmetatable(i)
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
local t=i[t]
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
local function p(t,e)
if t:sub(e,e)==' 'then
return''
end
local t=t:reverse()
sLeft=t:match('[^_]*',t:len()-e):reverse()
return sLeft
end
local function o(e)
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
local a,i,t=t:match("^(.-)([/\\]?)([^/\\]*)$")
local a=_G.shell and _G.shell.resolve(a)or a
if fs.isDir(a)then
local a,i=pcall(fs.list,a)
if a then
local a=nil
local o="^"..o(t)..'.*'
for i,t in ipairs(i)do
a=string.match(t,o)
if a then
table.insert(e,a)
end
end
end
end
table.sort(e)
if t==e[1]then
local o=e[1]
if fs.isDir(a..'/'..t)then
e[1]=e[1]..'/'
end
end
return e,t:len()
end
local function f(h,s,w,u)
local l=u==nil or u==true
a.setCursorBlink(true)
local t=""
local n=nil
local e=0
if h then
h=string.sub(h,1,1)
end
local d=0
local o={n=0}
function reset_matches()
o={n=0}
end
function get_matches(e)
if l then
return get_fs_matches(e)
else
return r(e,w)
end
end
local c,i=a.getSize()
local r,m=a.getCursorPos()
local function i(i)
local o=0
if r+e>=c then
o=(r+e)-c
end
a.setCursorPos(r,m)
local i=i or h
if i then
a.write(string.rep(i,string.len(t)-o))
else
a.write(string.sub(t,o+1))
end
a.setCursorPos(r+e-o,m)
end
while true do
local r,a=unpack(y:receive())
if r=="char"then
reset_matches()
t=string.sub(t,1,e)..a..string.sub(t,e+1)
e=e+1
i()
elseif r=="key"then
if not(a==keys.tab)then
reset_matches()
end
if not(a==keys.rightShift)then
d=0
end
if a==keys.enter then
break
elseif a==keys.tab then
if o[1]then
local a=string.len(o[o.n])
o.n=(o.n)%#o+1
if string.len(o[o.n])<a then i(" ")end
t=string.sub(t,1,e-a)..o[o.n]..string.sub(t,e+1)
e=e-a+o[o.n]:len()
i()
else
o,len=get_matches(p(t,e))
o.n=0
if#o>0 then
o.n=1
local a=len
t=string.sub(t,1,e-a)..o[o.n]..string.sub(t,e+1)
e=e-a+o[o.n]:len()
i()
end
if#o==1 then reset_matches()end
end
elseif a==keys.rightShift then
d=(d+1)%2
if d==0 then
l=not l
end
reset_matches()
elseif a==keys.left then
if e>0 then
e=e-1
i()
end
elseif a==keys.right then
if e<string.len(t)then
e=e+1
i()
end
elseif a==keys.up or a==keys.down then
if s then
i(" ");
if a==keys.up then
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
elseif a==keys.backspace then
if e>0 then
i(" ");
t=string.sub(t,1,e-1)..string.sub(t,e+1)
e=e-1
i()
end
elseif a==keys.home then
e=0
i()
elseif a==keys.delete then
if e<string.len(t)then
i(" ");
t=string.sub(t,1,e)..string.sub(t,e+2)
i()
end
elseif a==keys["end"]then
e=string.len(t)
i()
elseif a==29 then
write'\n'
return t..f(h,s,w,u)
end
end
end
a.setCursorBlink(false)
a.setCursorPos(c+1,m)
print()
return t
end
local function i()
local i={
normal='>>>',
complete='..',
}
input={}
output={}
local a={
['#']=function(e)
end,
['=']=function(o)
local n='in['..#input..']'
local function i(t,a)
local e,o=loadstring(t,a)
if e then return e end
local t,a=loadstring("return "..t,a)
if t then return t,nil,true end
return nil,(e and o or a)
end
func,e,o=i(o,n)
if func then
setfenv(func,h.env)
local e={pcall(function()return func()end)}
if e[1]then
table.remove(e,1)
local t=table.remove(e)
print(table.concat(util.map_args(e,tostring),',')..tostring(t))
else
printError(tResults[2])
end
else
printError(e)
end
end
}
local t='='
h.prompt=i.normal
repeat
write(t)
local e=f(nil,input,h.env,t=='#'and true)
table.insert(input,e)
if e:sub(1,1)=='$'then
t=e:sub(2,2)
e=e:sub(3)
end
a[t](e)
until false
end
debug.wrap(
i()
)
end
return h
