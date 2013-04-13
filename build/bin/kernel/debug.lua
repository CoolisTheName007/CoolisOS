include'kernel.class'
local n=require'kernel.checker'.check
local e={}
local function o(t,o)
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
function e.step_print(a,e)
local e=e or term
local t,e=e.getSize()
e=e-1
local t=o(a,t)
local i=#t%e
local o=(#t-i)/e
for a=0,o-1 do
if a~=0 then write'\n'end
write(table.concat(t,'\n',a*e+1,(a+1)*e))
write('\nPress any key to continue')
os.pullEvent('key')
end
write('\n')
write(table.concat(t,'\n',o*e+1,o*e+i))
write('\n')
end
function e.printError(...)
if term.isColour()then
term.setTextColour(colours.red)
end
local t={...}
for a=1,#t do t[a]=tostring(t[a])end
e.step_print(table.concat(t,''),term)
term.setTextColour(colours.white)
end
do
rawset(_G,'loadfile',function(t)
local e=fs.open(t,"r")
if e then
local a,t=loadstring(e.readAll(),t)
e.close()
return a,t
end
return nil,"File not found"
end)
local i=function(t,e,i)
local a=e or{}
local o={}
local e,n=a
local t=2+(t or 0)
repeat
t=t+1
o[e]=true
n,e=pcall(error,'',t)
if e:match('^[^:]+')=='bios'then break end
table.insert(a,e)
until(o[e]or(i and(t+1-2>i)))
return a
end
local function o(a,o)
local t={}
local e
for i,a in ipairs(a)do
local a,o=o(a)
if a~=nil then
if e==nil or e.n~=a then
table.insert(t,e)
e={n=a}
end
table.insert(e,o)
end
end
table.insert(t,e)
return t
end
local function r(e)
return o(e,function(e)return e:match('^([^:]+):(.*)')end)
end
local function h(e)
return o(e,function(e)return e:match('^(%d+):(.*)')end)
end
local function s(e,a,t,o)
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
local function n(e)
local t={}
for e,o in ipairs(r(e))do
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
s(a,1,t,e)
end
end
end
return t
end
function e.traceback(e,a,t)
local a=a or 0
local t=n(i(a+1,{},t))
e=(e and'\n')..'['..(e or'debug.traceback')
table.insert(t,1,e)
return table.concat(t,'\n')..'\n]'
end
function e.printTraceback(t,a)
e.printError(e.traceback(t,(a or 0)+1))
end
function e.tracebackError(t,a)
error(e.traceback(t,(a or 0)+1),2)
end
end
function e.raw(e)
if type(e)=='table'then
local t=getmetatable(e)
if t then
local a=rawget(t,'__tostring')
rawset(t,'__tostring',nil)
local e=tostring(e)
rawset(t,'__tostring',a)
return e
else
return tostring(e)
end
else
return tostring(e)
end
end
function e.log(...)
return log('debug','DEBUG','(%s):\nMsg:\n\t%s\nFrom:%s',sched.running or'nil',e.args_tostring(...),e.traceback('',1,2))
end
function e.objinfo(t)
return(e.named[t]and e.named[t]..'|'or'')
..(typeof(t)=='object'and(classname(t)or e.raw(t))..' instance|'or'')
..e.raw(t)or''
end
function e.getinfo(t)
if type(t)=='table'then
return e.objinfo(t)
else
return type(t)..':'..tostring(t)
end
end
function e.args_tostring(...)
local a={}
local t={...}
for o=1,table.maxn(t)do table.insert(a,(e.getinfo)(t[o]))end
return table.concat(a,',')
end
function e.wrap(t)
return function(...)
local e={xpcall(t,e.traceback)}
local t,e=e[1],e[2]
if not t then error(e,2)end
end
end
e.named=setmetatable({},{__mode='kv'})
function e.name(t,a)
e.named[t]=a
return t
end
function e.namefield(o,a,t)
t=t==nil and o[a]or t
n('table,!nil,!nil',o,a,t)
o[a]=t
e.name(t,string.format('(%s).(%s)',e.getinfo(o),e.getinfo(a)))
return t
end
return e