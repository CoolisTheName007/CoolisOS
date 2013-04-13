local o,e,e=string.format,string.gsub,string.byte
local e=os.clock
local a=io.stdout
local s=table.insert
local e={}
local e={}
e._VERSION="1.1.0"
local i=rawget(_G,'setfenv')
e.lua51=i
if not i then
unpack=table.unpack
loadstring=load
end
e.dir_separator='/'
function e.quit(t,...)
if type(t)=='string'then
e.fprintf(io.stderr,t,...)
t=-1
else
e.fprintf(io.stderr,...)
end
io.stderr:write('\n')
os.exit(t)
end
function e.printf(t,...)
e.assert_string(1,t)
e.fprintf(a,t,...)
end
function e.fprintf(a,t,...)
e.assert_string(2,t)
a:write(o(t,...))
end
local function h(a,t,i,n)
local o=rawget(a,t)
if o and t~='_M'and t~='_NAME'and t~='_PACKAGE'and t~='_VERSION'then
e.printf("warning: '%s.%s' overrides existing symbol\n",n,t)
end
rawset(a,t,i)
end
local function n(e,a)
for t,e in pairs(e)do
if e==a then return t end
end
return'?'
end
local o={}
function e.import(t,a)
a=a or _G
t=t or e
if type(t)=='string'then
t=require(t)
end
local i=n(a,t)
if o[t]then return end
o[t]=i
for e,t in pairs(t)do
h(a,e,t,i)
end
end
e.patterns={
FLOAT='[%+%-%d]%d*%.?%d*[eE]?[%+%-]?%d*',
INTEGER='[+%-%d]%d*',
IDEN='[%a_][%w_]*',
FILE='[%a%.\\][:%][%w%._%-\\]*'
}
function e.escape(t)
e.assert_string(1,t)
return(t:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1'))
end
function e.choose(t,e,a)
if t then return e
else return a
end
end
local n
function e.readfile(t,a)
local a=a and'b'or''
e.assert_string(1,t)
local t,a=io.open(t,'r'..a)
if not t then return e.raise(a)end
local e,a=t:read('*a')
t:close()
if not e then return n(a)end
return e
end
function e.writefile(a,t)
e.assert_string(1,a)
e.assert_string(2,t)
local e,a=io.open(a,'w')
if not e then return n(a)end
e:write(t)
e:close()
return true
end
function e.readlines(t)
e.assert_string(1,t)
local e,t=io.open(t,'r')
if not e then return n(t)end
local t={}
for a in e:lines()do
s(t,a)
end
e:close()
return t
end
function e.split(t,o,h,s)
e.assert_string(1,t)
local r,i,n=string.find,string.sub,table.insert
local a,e=1,{}
if not o then o='%s+'end
if o==''then return{t}end
while true do
local o,h=r(t,o,a,h)
if not o then
local t=i(t,a)
if t~=''then n(e,t)end
if#e==1 and e[1]==''then
return{}
else
return e
end
end
n(e,i(t,a,o-1))
if s and#e==s then
e[#e]=i(t,a)
return e
end
a=h+1
end
end
function e.splitv(a,t)
return unpack(e.split(a,t))
end
function e.array_tostring(o,e,t)
e,t=e or{},t or tostring
for a=1,#o do
e[a]=t(o[a],a)
end
return e
end
local s=load
if e.lua51 then
function e.load(t,i,e,o)
local e,a
if type(t)=='string'then
e,a=loadstring(t,i)
else
e,a=s(t,i)
end
if e and o then setfenv(e,o)end
return e,a
end
end
function e.execute(e)
local e,a,t=os.execute(e)
if i then
return e==0,e
else
return e,t
end
end
if i then
function table.pack(...)
local e=select('#',...)
return{n=e;...}
end
local t='/'
function e.searchpath(e,a)
e=e:gsub('%.',t)
for t in a:gmatch('[^;]+')do
local t=t:gsub('?',e)
local e=io.open(t,'r')
if e then e:close();return t end
end
end
end
if not table.pack then table.pack=_G.pack end
if not rawget(_G,"pack")then _G.pack=table.pack end
function e.memoize(e)
return setmetatable({},{
__index=function(a,t,...)
local e=e(t,...)
a[t]=e
return e
end,
__call=function(t,e)return t[e]end
})
end
function e.is_callable(e)
return type(e)=='function'or getmetatable(e)and getmetatable(e).__call
end
function e.is_type(t,e)
if type(e)=='string'then return type(t)==e end
local t=getmetatable(t)
return e==t
end
local a=getmetatable(io.stdout)
function e.type(t)
local e=type(t)
if e=='table'or e=='userdata'then
local t=getmetatable(t)
if t==a then
return'file'
else
return t._name or"unknown "..e
end
else
return e
end
end
function e.is_integer(t)
return math.ceil(t)==t
end
e.stdmt={
List={_name='List'},Map={_name='Map'},
Set={_name='Set'},MultiMap={_name='MultiMap'}
}
local h={}
function e.add_function_factory(t,e)
h[t]=e
end
local function i(t)
local a=e.raise
if t:find'^|'or t:find'_'then
local e,o=t:match'|([^|]*)|(.+)'
if t:find'_'then
e='_'
o=t
else
if not e then return a'bad string lambda'end
end
local e='return function('..e..') return '..o..' end'
local e,t=loadstring(e)
if not e then return a(t)end
e=e()
return e
else return a'not a string lambda'
end
end
e.string_lambda=e.memoize(i)
local s
function e.function_arg(i,t,o)
e.assert_arg(1,i,'number')
local a=type(t)
if a=='function'then return t end
if a=='string'then
if not s then s=require'pl.operator'.optable end
local a=s[t]
if a then return a end
local e,a=e.string_lambda(t)
if not e then error(a..': '..t)end
return e
elseif a=='table'or a=='userdata'then
local e=getmetatable(t)
if not e then error('not a callable object',2)end
local a=h[e]
if not a then
if not e.__call then error('not a callable object',2)end
return t
else
return a(t)
end
end
if not o then o=" must be callable"end
if i>0 then
error("argument "..i..": "..o,2)
else
error(o,2)
end
end
function e.bind1(t,a)
t=e.function_arg(1,t)
return function(...)return t(a,...)end
end
function e.bind2(t,a)
t=e.function_arg(1,t)
return function(e,...)return t(e,a,...)end
end
function e.assert_arg(t,e,a,i,n,o)
if type(e)~=a then
error(("argument %d expected a '%s', got a '%s'"):format(t,a,type(e)),o or 2)
end
if i and not i(e)then
error(("argument %d: '%s' %s"):format(t,e,n),o or 2)
end
end
function e.assert_string(t,a)
e.assert_arg(t,a,'string',nil,nil,3)
end
local t='default'
function e.on_error(a)
if({['default']=1,['quit']=2,['error']=3})[a]then
t=a
else
if t=='default'then t='error'end
e.raise("Bad argument expected string; 'default', 'quit', or 'error'. Got '"..tostring(a).."'")
end
end
function e.raise(a)
if t=='default'then return nil,a
elseif t=='quit'then e.quit(a)
else error(a,2)
end
end
n=e.raise
return e
