do
local function n(t,o)
local e={''}
for a,t in t:gmatch('(%S+)(%s*)')do
local i=e[#e]..a..t:gsub('\n','')
if#i>o then
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
function step_print(a,e)
local e=e or term
local t,e=e.getSize()
local t=n(a,t)
local o=#t%e
local a=(#t-o)/e
for a=0,a-1 do
write(table.concat(t,'\n',a*e+1,(a+1)*e))
os.pullEvent('key')
end
write(table.concat(t,'\n',a*e+1,a*e+o))
os.pullEvent('key')
write('\n')
end
rawset(_G,'printError',function(...)
if term.isColour()then
term.setTextColour(colours.red)
end
local e={...}
for t=1,#e do e[t]=tostring(e[t])end
step_print(table.concat(e,''),term)
term.setTextColour(colours.white)
end)
end
do
rawset(_G,'loadfile',function(t)
local e=fs.open(t,"r")
if e then
local t,a=loadstring(e.readAll(),t)
e.close()
return t,a
end
return nil,"File not found"
end)
local o=_G._error or error
local a
local s=function(a,e)
local t=e or{}
local i={}
local e,n=t
local a=1+(a or 0)
repeat
a=a+1
i[e]=true
n,e=pcall(o,'',a)
if e:match('^[^:]+')=='bios'then break end
table.insert(t,e)
until(i[e])
return t
end
local function i(t,o)
local a={}
local e
for i,t in ipairs(t)do
local t,o=o(t)
if t~=nil then
if e==nil or e.n~=t then
table.insert(a,e)
e={n=t}
end
table.insert(e,o)
end
end
table.insert(a,e)
return a
end
local function n(e)
return i(e,function(e)return e:match('^([^:]+):(.*)')end)
end
local function h(e)
return i(e,function(e)return e:match('^(%d+):(.*)')end)
end
local function r(e,a,t,o)
local i,e=pcall(fs.open,e,'r')
if not i or not e then table.insert(t,'  (could not open file)')
else
for t=1,o-a-1 do
e.readLine()
end
for a=1,a do
table.insert(t,'  '..e.readLine())
end
table.insert(t,'->'..e.readLine())
for a=1,a do
local e=e.readLine()
if e then table.insert(t,'  '..e)
else break end
end
end
end
local function i(e)
local t={}
for e,o in ipairs(n(e))do
local e=o.n or'(no name)'
local a
if fs.exists(e)then
e,dir,a=fs.getName(e),e:match('^(.*)/')or'/',e
e=e..' ('..(dir or'unknown')..')'
elseif false then
end
table.insert(t,e)
for o,e in ipairs(h(o))do
table.insert(t,' line '..(e.n or'(no line)')..', *'..(#e))
local e=e.n and tonumber(e.n)or 1
if a and e then
r(a,1,t,e)
end
end
end
return t
end
a=function(t,e)
if e and type(e)~='number'then a('expected arg2 to be nil or number,got '..type(e),1)end
if t and type(t)~='string'then a('expected arg1 to be nil or string,got '..type(t),1)end
e=e or 0
local a=i(s(e+2,{}))
t='\1'..(t or'')
table.insert(a,1,t)
o(table.concat(a,'\n'),e+2)
end
rawset(_G,'_error',o)
rawset(_G,'error',a)
rawset(_G,'toerror',function(e)
if not e:match'^[^:]+:%d+:\1'then
local t=i{e}
table.insert(t,1,e)
return table.concat(t,'\n')
end
return e
end)
end