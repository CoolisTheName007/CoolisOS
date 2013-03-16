local h,w,r,t,c,e,u,f,a,a,o,m=
string,pcall,table,tostring,setmetatable,os,pairs,next,print,math,type,unpack
local a=_G
local y=require'kernel.util'
local v=require'kernel.checker'.check
local i=pprint
local i=textutils
local n=getfenv()
c(n,nil)
local p=function()
local i=i.formatTime(e.time())
local e=t(e.clock())
local o,a,t=e:match('^([^%.]*)(%.)([^%.]*)$')
e=(o or 0)..(a or'.')..(t or'')..h.rep('0',2-(t and t:len()or 0))
return i..';'..e
end
levels={}
for t,e in u{'NONE','ERROR','WARNING','INFO','DETAIL','DEBUG','ALL'}do
levels[t],levels[e]=e,t
end
local d=defaultlevel or levels.WARNING
local l=modules or{}
timestampformat=nil
displaylogger=displaylogger or function(e,e,...)
if a.print then a.print(...)end
end
storelogger=nil
format=nil
local function s(...)
if displaylogger then displaylogger(...)end
if storelogger then storelogger(...)end
end
function musttrace(t,e)
local t,e=l[t]or d,levels[e]
return not e or t>=e
end
function trace(e,a,i,...)
v('string,string,string',e,a,i)
if not musttrace(e,a)then return end
local o,n=w(h.format,i,m(y.map({...},function(e,a)return(o(e)=='number'and e or t(e))end)))
if o then
local i
local function h(o)
if o=="l"then return n
elseif o=="t"then i=i or t(p(timestampformat))return i
elseif o=="m"then return e
elseif o=="s"then return a
else return o end
end
local t=(format or"%t %m-%s: %l"):gsub("%%(%a)",h)
s(e,a,t)
else
local o={}
local d={...}
for e=1,r.getn(d)do r.insert(o,t(e)..":["..t(d[e]).."]")end
s(e,a,"Error in the log formating! ("..t(n)..") - Fallback to raw printing:")
s(e,a,h.format("\tmodule=(%s), severity=(%s), format=(%q), args=(%s)",e,a,i,r.concat(o," ")))
end
end
function setlevel(e,...)
local o={...}
local a=levels[e]or levels['ALL']
if not levels[e]then
trace("LOG","ERROR","Unknown severity %q, reverting to 'ALL'",t(e))
end
if f(o)then for t,e in u(o)do l[e]=a end
else d=a end
end
c(n,{__call=function(e,...)return trace(...)end})
return n
