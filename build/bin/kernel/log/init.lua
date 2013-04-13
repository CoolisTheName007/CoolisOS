local t,p,v,o,s,e,c,f,a,a,u,y=
string,pcall,table,tostring,setmetatable,os,pairs,next,print,math,type,unpack
local l=_G
local d=require'kernel.util'
local b=require'kernel.checker'.check
local n=textutils
local a=t
local t=pprint
local i=getfenv()
s(i,nil)
function s_to_real(e)
local t=e%60
local e=((e-t)/60)
local a=e%60
local e=((e-a)/60)
return e,a,t
end
local w=function()
local t='Day '..e.day()..', '..n.formatTime(e.time())
local e=e.clock()
local s,n,e=s_to_real(e)
local o=o(e)
local e,i,t=o:match('^([^%.]*)(%.)([^%.]*)$')
e=e or'0'
i=i or'.'
t=t or'0'
e=a.rep('0',2-e:len())..e
t=t..a.rep('0',2-t:len())
o=e..i..t
local e=a.format('%sh%sm%ss',s,n,o)
return a.format('%s',o)
end
levels={}
for t,e in c{'NONE','ERROR','WARNING','INFO','DETAIL','DEBUG','ALL'}do
levels[t],levels[e]=e,t
end
local h=defaultlevel or levels.WARNING
local r=modules or{}
timestampformat=nil
displaylogger=function(e,e,...)
end
storelogger=nil
format=nil
local function n(...)
if displaylogger then displaylogger(...)end
if storelogger then storelogger(...)end
end
function musttrace(t,e)
local t,e=r[t]or h,levels[e]
return not e or t>=e
end
local function m(...)
return(l.debug and l.debug.getinfo or o)(...)
end
function trace(e,t,i,...)
b('string,string,string',e,t,i)
if not musttrace(e,t)then return end
local h,s=p(a.format,i,y(d.map_args({...},function(e)if(u(e)=='number'or u(e)=='string')then return e else return m(e)end end)))
if h then
local i
local function h(a)
if a=="l"then return s
elseif a=="t"then i=i or o(w(timestampformat))return i
elseif a=="m"then return e
elseif a=="s"then return t
else return a end
end
local a=(format or"%t %m-%s: %l"):gsub("%%(%a)",h)
n(e,t,a)
else
n(e,t,"Error in the log formating! ("..o(s)..") - Fallback to raw printing:")
n(e,t,a.format("\tmodule=(%s), severity=(%s), format=(%q), args=(%s)",e,t,i,v.concat(d.map_args({...},debug.getinfo),',')))
end
end
function setLevel(e,...)
local t={...}
local a=levels[e]or levels['ALL']
if not levels[e]then
trace("LOG","ERROR","Unknown severity %q, reverting to 'ALL'",o(e))
end
if f(t)then for t,e in c(t)do r[e]=a end
else h=a end
end
local e=s({},{__mode='k'})
function wrap_class(t)
assert(not e[t])
local a=t.__init
rawset(t,'__init',function(...)
a(...)
i(o(t.__name),'DETAIL','initiated obj %s with args ',debug.getinfo(obj),args_tostring(...))
end)
e[t]=a
end
function unwrapp_class(t)
if e[t]then
rawset(t,'__init',e[t])
e[t]=nil
end
end
s(i,{__call=function(e,...)return trace(...)end})
return i
