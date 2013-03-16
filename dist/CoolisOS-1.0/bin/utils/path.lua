local a=require"kernel.checker".check
local e={}
local l,u,t,c,d,r,h,s
local function o(n,e,t)
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
function h(...)
return o({...})
end
function u(e)
a('string',e)
local e=t(e)
return o(e)
end
function d(i,e,o)
a('table,string|table',i,e)
local e=type(e)=='string'and t(e)or e
local t=table.remove(e)
local e=s(i,e,o~=nil)
if e then e[t]=o end
end
function c(o,e)
a('table,string|table',o,e)
local e=type(e)=='string'and t(e)or e
local t=table.remove(e)
if not t then return o end
local e=s(o,e)
return e and e[t]
end
function r(e)
a('string',e)
local t=t(e)
local a=#t
local e=a
local function i()
if e==-1 then return nil,nil end
local a,t=o(t,1,e),o(t,e+1,a)
e=e-1
return a,t
end
return i
end
function l(i,e)
a('string,number',i,e)
local t=t(i)
if e>#t then return i,''
elseif-e>#t then return'',i
else
if e<0 then e=#t+e end
return o(t,1,e),o(t,e+1,#t)
end
end
function t(t)
a('string',t)
local i={}
local o,a,e=1
repeat
a=t:find(".",o,true)or#t+1
e=t:sub(o,a-1)
e=tonumber(e)or e
if e and e~=""then table.insert(i,e)end
o=a+1
until a==#t+1
return i
end
function s(n,i,s)
a('table,string|table',n,i)
i=type(i)=="string"and t(i)or i
for a,t in ipairs(i)do
local e=n[t]
if type(e)~="table"then
if not s or(s=="noowr"and e~=nil)then return nil,o(i,1,a)
else e={}n[t]=e end
end
n=e
end
return n
end
e.split=l;e.clean=u;e.segments=t;e.get=c;e.set=d;
e.gsplit=r;e.concat=h;e.find=s
return e
