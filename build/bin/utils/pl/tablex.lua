local h=require'utils'
local u,d,e=getmetatable,setmetatable,require
local b,w=table.insert,table.remove
local y,e=math.min,math.max
local a,r,j,e,q,g=pairs,type,unpack,next,select,tostring
local i=h.function_arg
local k=h.stdmt.Set
local s=h.stdmt.List
local l=h.stdmt.Map
local p=h.assert_arg
local e={}
local function n(a,t,e)
local e=u(t)or e
return d(a,e)
end
local function f(e)
return d(e,s)
end
local function c(e)
if r(e)=='table'then return true end
return u(e)
end
local function m(e,t)
error(('argument %d is not %s'):format(e,t),3)
end
local function t(t,e)
local e=c(e)
if e==true then return end
if not(e and e.__len and e.__index)then
m(t,"indexable")
end
end
local function o(t,e)
local e=c(e)
if e==true then return end
if not(e and e.__pairs)then
m(t,"iterable")
end
end
local function v(t,e)
local e=c(e)
if e==true then return end
if not(e and e.__newindex)then
m(t,"writeable")
end
end
function e.update(e,t)
v(1,e)
o(2,t)
for t,a in a(t)do
e[t]=a
end
return e
end
function e.size(t)
o(1,t)
local e=0
for t in a(t)do e=e+1 end
return e
end
function e.copy(e)
o(1,e)
local t={}
for e,a in a(e)do
t[e]=a
end
return t
end
function e.deepcopy(t)
if r(t)~='table'then return t end
o(1,t)
local i=u(t)
local o={}
for a,t in a(t)do
if r(t)=='table'then
t=e.deepcopy(t)
end
o[a]=t
end
d(o,i)
return o
end
local m,c=math.abs
function e.deepcompare(e,t,n,o)
local i=r(e)
local s=r(t)
if i~=s then return false end
if i~='table'then
if i=='number'and o then return m(e-t)<o end
return e==t
end
local i=u(e)
if not n and i and i.__eq then return e==t end
for e in a(e)do
if t[e]==nil then return false end
end
for t in a(t)do
if e[t]==nil then return false end
end
for e,a in a(e)do
local e=t[e]
if not c(a,e,n,o)then return false end
end
return true
end
c=e.deepcompare
function e.compare(e,a,o)
t(1,e)
t(2,a)
if#e~=#a then return false end
o=i(3,o)
for t=1,#e do
if not o(e[t],a[t])then return false end
end
return true
end
function e.compare_no_order(o,e,a)
t(1,o)
t(2,e)
if a then a=i(3,a)end
if#o~=#e then return false end
local s={}
for t=1,#o do
local n=o[t]
local i
for t=1,#e do if not s[t]then
local o
if a then o=a(n,e[t])else o=n==e[t]end
if o then
i=t
break
end
end end
if not i then return false end
s[i]=true
end
return true
end
function e.find(a,o,e)
t(1,a)
e=e or 1
if e<0 then e=#a+e+1 end
for e=e,#a do
if a[e]==o then return e end
end
return nil
end
function e.rfind(a,o,e)
t(1,a)
e=e or#a
if e<0 then e=#a+e+1 end
for e=e,1,-1 do
if a[e]==o then return e end
end
return nil
end
function e.find_if(t,e,n)
o(1,t)
e=i(2,e)
for t,a in a(t)do
local e=e(a,n)
if e then return t,e end
end
return nil
end
function e.index_by(a,e)
t(1,a)
t(2,e)
local t={}
for o=1,#e do
t[o]=a[e[o]]
end
return n(t,a,s)
end
function e.map(t,e,...)
o(1,e)
t=i(1,t)
local o={}
for e,a in a(e)do
o[e]=t(a,...)
end
return n(o,e)
end
function e.imap(a,e,...)
t(1,e)
a=i(1,a)
local o={}
for t=1,#e do
o[t]=a(e[t],...)or false
end
return n(o,e,s)
end
function e.map_named_method(a,e,...)
h.assert_string(1,a)
t(2,e)
local o={}
for t=1,#e do
local e=e[t]
local a=e[a]
o[t]=a(e,...)
end
return n(o,e,s)
end
function e.transform(t,e,...)
o(1,e)
t=i(1,t)
for o,a in a(e)do
e[a]=t(a,...)
end
end
function e.range(e,t,o)
if e==t then return{e}
elseif e>t then return{}
end
local i={}
local a=1
if not o then
if t>e then o=t>e and 1 or-1 end
end
for e=e,t,o do i[a]=e;a=a+1 end
return i
end
function e.map2(t,e,h,...)
o(1,e)
o(2,h)
t=i(1,t)
local o={}
for e,a in a(e)do
o[e]=t(a,h[e],...)
end
return n(o,e,s)
end
function e.imap2(e,a,o,...)
t(2,a)
t(3,o)
e=i(1,e)
local i,t={},math.min(#a,#o)
for t=1,t do
i[t]=e(a[t],o[t],...)
end
return i
end
function e.reduce(a,e)
t(2,e)
a=i(1,a)
local o=#e
local t=e[1]
for o=2,o do
t=a(t,e[o])
end
return t
end
function e.foreach(t,e,...)
o(1,t)
e=i(2,e)
for t,a in a(t)do
e(a,t,...)
end
end
function e.foreachi(e,a,...)
t(1,e)
a=i(2,a)
for t=1,#e do
a(e[t],t,...)
end
end
function e.mapn(a,...)
a=i(1,a)
local t={}
local e={...}
local o=1e40
for t=1,#e do
o=y(o,#(e[t]))
end
for n=1,o do
local i,o={},1
for a=1,#e do
i[o]=e[a][n]
o=o+1
end
t[#t+1]=a(j(i))
end
return t
end
function e.pairmap(t,n,...)
o(1,n)
t=i(1,t)
local e={}
for a,o in a(n)do
local a,t=t(a,o,...)
if t then
e[t]=a
else
e[#e+1]=a
end
end
return e
end
local function u(e,t)return e end
function e.keys(t)
o(1,t)
return f(e.pairmap(u,t))
end
local function u(t,e)return e end
function e.values(t)
o(1,t)
return f(e.pairmap(u,t))
end
local function u(e,t)return e,t end
function e.index_map(a)
t(1,a)
return d(e.pairmap(u,a),l)
end
local function u(t,e)return true,e end
function e.makeset(a)
t(1,a)
return d(e.pairmap(u,a),k)
end
function e.merge(i,t,s)
o(1,i)
o(2,t)
local e={}
for a,o in a(i)do
if s or t[a]then e[a]=o end
end
if s then
for t,a in a(t)do
e[t]=a
end
end
return n(e,i,l)
end
function e.difference(e,t,i)
o(1,e)
o(2,t)
local o={}
for e,a in a(e)do
if not t[e]then o[e]=a end
end
if i then
for t,a in a(t)do
if not e[t]then o[t]=a end
end
end
return n(o,e,l)
end
function e.count_map(a,o)
t(1,a)
local t,n={},{}
o=i(2,o)
local s=#a
for i=1,#a do
local e=a[i]
if not n[e]then
n[e]=true
t[e]=1
for i=i+1,s do
local a=a[i]
if o and o(e,a)or e==a then
t[e]=t[e]+1
n[a]=true
end
end
end
end
return d(t,l)
end
function e.filter(e,a,h)
t(1,e)
a=i(2,a)
local o,t={},1
for i=1,#e do
local e=e[i]
if a(e,h)then
o[t]=e
t=t+1
end
end
return n(o,e,s)
end
function e.zip(...)
return e.mapn(function(...)return{...}end,...)
end
local d
function d(s,o,a,t,n,h)
a=a or 1
t=t or 1
local i
if not n then
n=#o
i=#o
else
i=t+y(n-1,#o-t)
end
if s==o then
if a>t and i>=a then
o=e.sub(o,t,n)
t=1;i=#o
end
end
for e=t,i do
s[a]=o[e]
a=a+1
end
if h then
e.clear(s,a)
end
return s
end
function e.icopy(a,e,o,i,n)
t(1,a)
t(2,e)
return d(a,e,o,i,n,true)
end
function e.move(a,e,o,i,n)
t(1,a)
t(2,e)
return d(a,e,o,i,n,false)
end
function e._normalize_slice(a,t,e)
local a=#a
if not t then t=1 end
if t<0 then t=a+t+1 end
if not e then e=a end
if e<0 then e=a+1+e end
return t,e
end
function e.sub(a,i,o)
t(1,a)
i,o=e._normalize_slice(a,i,o)
local e={}
for t=i,o do b(e,a[t])end
return n(e,a,s)
end
function e.set(e,i,a,o)
t(1,e)
a,o=a or 1,o or#e
if h.is_callable(i)then
for t=a,o do
e[t]=i(t)
end
else
for t=a,o do
e[t]=i
end
end
end
function e.new(o,a)
local t={}
e.set(t,a,1,o)
return t
end
function e.clear(t,e)
e=e or 1
for e=e,#t do w(t)end
end
function e.insertvalues(e,...)
p(1,e,'table')
local a,t
if q('#',...)==1 then
a,t=#e+1,...
else
a,t=...
end
if#t>0 then
for a=#e,a,-1 do
e[a+#t]=e[a]
end
local o=1-a
for a=a,a+#t-1 do
e[a]=t[a+o]
end
end
return e
end
function e.removevalues(a,t,o)
p(1,a,'table')
t,o=e._normalize_slice(a,t,o)
for e=t,o do
w(a,t)
end
return a
end
local t
t=function(e,i,o)
for t,e in a(e)do
if e==i then return t end
end
for a,e in a(e)do
if not o[e]and r(e)=='table'then
o[e]=true
local e=t(e,i,o)
if e then
e=g(e)
if r(a)~='string'then
return'['..a..']'..e
else
return a..'.'..e
end
end
end
end
end
function e.search(e,n,i)
o(1,e)
local o={[e]=true}
if i then
for t,e in a(i)do o[e]=true end
end
return t(e,n,o)
end
return e
