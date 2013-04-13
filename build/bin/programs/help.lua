local t=peripheral.wrap'back'
t.setTextScale(1)
local r=1
local e='CoolisOS/dev/text'
local function d()
local e=fs.open(e,'r')
local t=e.readAll()
e.close()
return t
end
local function e(e)
for e in e:gmatch("([^\n]*)\n?")do
local e,e=e:match'^#([^#- ]+)-?([^#- ]*)#'
end
end
local function l(a)
local e=t
local n,t=e.getSize()
local o,i=e.getCursorPos()
local s=0
local function h()
if i+1<=t then
e.setCursorPos(1,i+1)
else
e.setCursorPos(1,t)
e.scroll(1)
end
o,i=e.getCursorPos()
s=s+1
end
while string.len(a)>0 do
local t=string.match(a,"^[ \t]+")
if t then
e.write(t)
o,i=e.getCursorPos()
a=string.sub(a,string.len(t)+1)
end
local t=string.match(a,"^\n")
if t then
h()
a=string.sub(a,2)
end
local t=string.match(a,"^[^ \t\n]+")
if t then
a=string.sub(a,string.len(t)+1)
if string.len(t)>n then
while string.len(t)>0 do
if o>n then
h()
end
e.write(t)
t=string.sub(t,(n-o)+2)
o,i=e.getCursorPos()
end
else
if o+string.len(t)-1>n then
h()
end
e.write(t)
o,i=e.getCursorPos()
end
end
end
return s
end
local function u(t,i)
local e={''}
for a,t in t:gmatch('(%S+)(%s*)')do
local o=e[#e]..a..t:gsub('\n','')
if#o>i then
table.insert(e,'')
end
if t:find('\n')then
e[#e]=e[#e]..a
t=t:gsub('\n',function()
table.insert(e,'')
return''
end)
else
e[#e]=e[#e]..a..t
end
end
return e
end
local function m(a,e,o)
local t={}
for o=e,e+o-1 do
t[o-e+1]=a[o%(#a)+1]
end
return t
end
local function h(a)
t.clear()
t.setCursorPos(1,1)
local i,e=t.getSize()
for o,e in ipairs(a)do
if(e:sub(1,1)=='#')then
local a=colors[e:match'^#([^-#]+)']
t.setTextColor(a or colors.white)
local a=colors[e:match'^#[^-#]+%-([^#]+)#']
t.setBackgroundColor(a or colors.black)
local t=e:match'^#[^#]+#'
e=e:sub(t:len()+1)
end
c=' '
if(e:sub(-2,-2)=='&')then
c=e:sub(-1,-1)
e=e:sub(1,-3)
end
e=e..string.rep(c,math.max(i-#e,0))
l(e..(o~=#a and'\n'or''))
end
end
local function i()
local n,s=t.getSize()
local a
local e=-1
repeat
local i,o=pcall(d)
if i then a=o else error(o)end
local a=u(a,n)
e=(e+1)%(#a)
t.setTextColor(colors.white)
t.setBackgroundColor(colors.black)
local o=a
for e=1,(e+1)do
local e=o[e]
if(e:sub(1,1)=='#')then
local a=colors[e:match'^#([^-#]+)']
t.setTextColor(a or colors.white)
local e=colors[e:match'^#[^-#]+%-([^#]+)#']
t.setBackgroundColor(e or colors.black)
end
end
h(m(a,e,s))
sleep(r)
until false
end
parallel.waitForAny(i,function()shell.run'shell'end)
