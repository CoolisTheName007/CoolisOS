local i,o,e,t=next,type,unpack,select
local p,r=setmetatable,getmetatable
local u,_=table.insert,table.sort
local c,z=table.remove,table.concat
local x,j,g=math.randomseed,math.random,math.huge
local m,w,d=math.floor,math.max,math.min
local E=getfenv
local n=e
local t,s=pairs,ipairs
local e={}
local function T(e,t)return e>t end
local function f(t,e)return t<e end
local function y(e,t,a)return(e<t)and t or(e>a and a or e)end
local function q(t,e)return e and true end
local function k(e)return not e end
local function v(a)
local e
for t,t in t(a)do e=(e or 0)+1 end
return e
end
local function b(o,i,n,...)
local a
local e=n or e.identity
for o,t in t(o)do
if not a then a=e(t,...)
else
local e=e(t,...)
a=i(a,e)and a or e
end
end
return a
end
local h=-1
function e.wait(i,o,...)
local a,e
repeat
a={i(...)}
e=true
for o,t in t(o)do
if a[o]~=t then
e=false
break
end
end
until e
return a
end
function e.tnil(t)
local e=i(t)
if e then
for a,o in i,t,e do
t[e]=nil
e=a
end
t[e]=nil
end
end
function e.shcopy(a,e)
e=e or{}
for t,a in t(a)do
e[t]=a
end
return e
end
local l
l=function(i,s,a,n)
a=a or{}
i[s]=a
for e,t in t(s)do
if o(t)=='table'then
if i[t]then
a[e]=i[t]
else
if not(o(a[e])=='table')and(n or a[e]==nil)then
a[e]={}
end
l(i,t,a[e],n)
end
elseif n or a[e]==nil then a[e]=t end
end
return a
end
e.copy=function(...)return l({},...)end
function e.diff(s,i,n)
local o={}
local a={}
local e=n and t or e.recursivepairs
for t,e in e(s)do a[t]=e end
for e,t in e(i)do
if t~=a[e]then table.insert(o,e)end
a[e]=nil
end
for e,t in t(a)do table.insert(o,e)end
return o
end
function e.sortedpairs(a)
local e={}
local o=table.insert
for t in t(a)do o(e,t)end
table.sort(e)
local t=0
return function()
t=t+1
return e[t],a[e[t]]
end
end
function e.recursivepairs(h,n)
check('table,?|string',h,n)
local function r(s,i,e)
e[s]=true
local h=i==""and i or"."
for t,a in t(s)do
t=h..tostring(t)
if o(a)=='table'then
if not e[a]then r(a,i..t,e)end
else
coroutine.yield(i..t,a)
end
end
e[s]=nil
end
n=n or""
return coroutine.wrap(function()r(h,cleanpath(n),{})end)
end
function e.multipairs(e,...)
local e={tables={e,...},i=1,k=i(e)}
local function n()
if not e.i then return end
local o=e.tables[e.i]
local a,t=e.k,o[e.k]
local t=i(o,a)
while t==nil do
e.i=e.i+1
local a=e.tables[e.i]
if not a then e.i=false;break
else t=i(a)end
end
e.k=t
return a,o[a]
end
return n,nil,nil
end
function e.each(a,o,...)
if not e.isObject(a)then return end
for t,e in t(a)do
o(t,e,...)
end
return a
end
e.forEach=e.each
function e.map(o,i,...)
local a={}
for e,t in t(o)do
a[e]=i(e,t,...)
end
return a
end
e.collect=e.map
function e.reduce(i,o,a)
for t,e in t(i)do
a=not a and e or o(a,e)
end
return a
end
e.inject=e.reduce
e.foldl=e.reduce
function e.reduceRight(t,o,a)
return e.reduce(e.reverse(t),o,a)
end
e.injectr=e.reduceRight
e.foldr=e.reduceRight
function e.mapReduce(i,n,o)
local a={}
for t,e in t(i)do
a[t]=not o and e or n(o,e)
o=a[t]
end
return a
end
e.mapr=e.mapReduce
function e.mapReduceRight(a,t,o)
return e.mapReduce(e.reverse(a),t,o)
end
e.maprr=e.mapReduceRight
function e.include(o,a)
local i=e.isFunction(a)and a or e.isEqual
for t,e in t(o)do
if i(e,a)then return true end
end
return false
end
e.any=e.include
e.some=e.include
function e.detect(i,a)
local o=e.isFunction(a)and a or e.isEqual
for e,t in t(i)do
if o(t,a)then return e end
end
end
e.find=e.detect
e.where=e.detect
function e.select(o,a,...)
local i=e.map(o,a,...)
local a={}
for e,t in t(i)do
if t then a[#a+1]=o[e]end
end
return a
end
e.filter=e.select
function e.reject(o,a,...)
local i=e.map(o,a,...)
local a={}
for e,t in t(i)do
if not t then a[#a+1]=o[e]end
end
return a
end
e.discard=e.reject
function e.all(t,a,...)
return((#e.select(e.map(t,a,...),q))==(#t))
end
e.every=e.all
function e.invoke(t,a,...)
local o={...}
return e.map(t,function(i,t)
if e.isObject(t)then
if e.has(t,a)then
if e.isCallable(t[a])then
return t[a](t,n(o))
else return t[a]
end
else
if e.isCallable(a)then
return a(t,n(o))
end
end
elseif e.isCallable(a)then
return a(t,n(o))
end
end)
end
function e.pluck(a,t)
return e.reject(e.map(a,function(a,e)
return e[t]
end),
k)
end
function e.max(e,t,...)
return b(e,T,t,...)
end
function e.min(t,e,...)
return b(t,f,e,...)
end
function e.shuffle(a,t)
if t then x(t)end
local t={}
e.each(a,function(e,o)
local a=m(j()*e)+1
t[e]=t[a]
t[a]=o
end)
return t
end
function e.same(t,a)
return e.all(t,function(o,t)
return e.include(a,t)
end)
and e.all(a,function(o,a)
return e.include(t,a)
end)
end
function e.sort(e,t)
_(e,t)
return e
end
function e.toArray(...)
return{...}
end
function e.groupBy(i,a,...)
local o={...}
local t={}
local o=e.isFunction(a)and a
or(e.isString(a)and function(t,e)
return e[a](e,n(o))
end)
if not o then return end
e.each(i,function(e,a)
local e=o(e,a)
if t[e]then t[e][#t[e]+1]=a
else t[e]={a}
end
end)
return t
end
function e.countBy(i,o,...)
local a={...}
local t={}
e.each(i,function(i,e)
local e=o(i,e,n(a))
t[e]=(t[e]or 0)+1
end)
return t
end
function e.size(...)
local t={...}
local a=t[1]
if e.isNil(a)then
return 0
elseif e.isObject(a)then
return v(t[1])
else
return v(t)
end
end
function e.containsKeys(e,a)
for t in t(a)do
if not e[t]then return false end
end
return true
end
function e.sameKeys(a,t)
e.each(a,function(e)
if not t[e]then return false end
end)
e.each(t,function(e)
if not a[e]then return false end
end)
return true
end
function e.reverse(t)
local e={}
for a=#t,1,-1 do
e[#e+1]=t[a]
end
return e
end
function e.selectWhile(t,o,...)
local a={}
for e,t in s(t)do
if o(e,t,...)then a[e]=t else break end
end
return a
end
e.takeWhile=e.selectWhile
function e.dropWhile(a,o,...)
local t
for e,a in s(a)do
if not o(e,a,...)then
t=e
break
end
end
if e.isNil(t)then return{}end
return e.rest(a,t)
end
e.rejectWhile=e.dropWhile
function e.sortedIndex(t,o,a,i)
local a=a or f
if i then e.sort(t,a)end
for e=1,#t do
if not a(t[e],o)then return e end
end
return#t+1
end
function e.indexOf(e,a)
for t=1,#e do
if e[t]==a then return t end
end
end
function e.lastIndexOf(t,a)
local e=e.indexOf(e.reverse(t),a)
if e then return#t-e+1 end
end
function e.add(t,...)
e.each({...},function(a,e)u(t,1,e)end)
return t
end
function e.push(t,...)
e.each({...},function(a,e)t[#t+1]=e end)
return t
end
function e.pop(t)
local a=t[1]
c(t,1)
return a
end
e.shift=e.pop
function e.unshift(e)
local t=e[#e]
c(e)
return t
end
function e.removeRange(t,a,o)
local t=e.clone(t)
local n,i=(i(t)),#t
if i<1 then return t end
a=y(a or n,n,i)
o=y(o or i,n,i)
if o<a then return t end
local o=o-a+1
local a=a
while o>0 do
c(t,a)
o=o-1
end
return t
end
e.rmRange=e.removeRange
function e.slice(t,o,a)
return e.select(t,function(e)
return(e>=(o or i(t))and e<=(a or#t))
end)
end
function e.first(t,a)
local a=a or 1
return e.slice(t,1,d(a,#t))
end
e.head=e.first
e.take=e.first
function e.initial(a,t)
if t and t<0 then return end
return e.slice(a,1,t and#a-(d(t,#a))or#a-1)
end
function e.last(a,t)
if t and t<=0 then return end
return e.slice(a,t and#a-d(t-1,#a-1)or 2,#a)
end
function e.rest(t,a)
if a and a>#t then return{}end
return e.slice(t,a and w(1,d(a,#t))or 1,#t)
end
e.tail=e.rest
function e.compact(t)
return e.reject(t,function(t,e)
return not e
end)
end
function e.flatten(n,a)
local i=a or false
local o
local a={}
for n,t in t(n)do
if e.isObject(t)and not i then
o=e.flatten(t)
e.each(o,function(t,e)a[#a+1]=e end)
else a[#a+1]=t
end
end
return a
end
function e.difference(t,...)
local a=e.toArray(...)
return e.select(t,function(o,t)
return not e.include(a,t)
end)
end
e.without=e.difference
function e.uniq(t,o,a,...)
local a=a and e.map(t,a,...)or t
local t={}
if not o then
for o,a in s(a)do
if not e.include(t,a)then
t[#t+1]=a
end
end
return t
end
t[#t+1]=a[1]
for e=2,#a do
if a[e]~=t[#t]then
t[#t+1]=a[e]
end
end
return t
end
e.unique=e.uniq
function e.union(...)
return e.uniq(e.flatten({...}))
end
function e.intersection(t,...)
local o={...}
local a={}
for i,t in s(t)do
if e.all(o,function(o,a)
return e.include(a,t)
end)then
u(a,t)
end
end
return a
end
function e.zip(...)
local t={...}
local o=e.max(e.map(t,function(t,e)
return#e
end))
local a={}
for o=1,o do
a[o]=e.pluck(t,o)
end
return a
end
function e.append(t,o)
local e={}
for a,t in s(t)do e[a]=t end
for a,t in s(o)do e[#e+1]=t end
return e
end
function e.range(...)
local t={...}
local o,i,a
if#t==0 then return{}
elseif#t==1 then i,o,a=t[1],0,1
elseif#t==2 then o,i,a=t[1],t[2],1
elseif#t==3 then o,i,a=t[1],t[2],t[3]
end
if(a and a==0)then return{}end
local t={}
local i=w(m((i-o)/a),0)
for e=1,i do t[#t+1]=o+a*e end
if#t>0 then u(t,1,o)end
return t
end
e.count=e.range
function e.invert(a)
local t={}
e.each(a,function(e,a)t[a]=e end)
return t
end
e.mirror=e.invert
function e.concat(t,o,i,a)
local t=e.map(t,function(t,e)
return tostring(e)
end)
return z(t,o,i,a)
end
e.join=e.concat
function e.identity(e)
return e
end
function e.once(a)
local e=0
local t={}
return function(...)
e=e+1
if e<=1 then t={...}end
return a(n(t))
end
end
function e.memoize(o,a)
local t=p({},{__mode='kv'})
local a=a or e.identity
return function(...)
local e=a(...)
local a=t[e]
if not a then t[e]=o(...)end
return t[e]
end
end
e.cache=e.memoize
function e.after(t,e)
local a,e=e,0
return function(...)
e=e+1
if e>=a then return t(...)end
end
end
function e.compose(...)
local a=e.reverse{...}
return function(...)
local e
for a,t in t(a)do
e=e and t(e)or t(...)
end
return e
end
end
function e.wrap(e,t)
return function(...)
return t(e,...)
end
end
function e.times(e,a,...)
local t={}
for e=1,e do
t[e]=a(e,...)
end
return t
end
function e.bind(t,e)
return function(...)
return t(e,...)
end
end
function e.bindn(t,...)
local a={...}
return function(...)
return t(n(e.append(a,{...})))
end
end
function e.uniqueId(t,...)
h=h+1
if t then
if e.isString(t)then
return t:format(h)
elseif e.isFunction(t)then
return t(h,...)
end
end
return h
end
e.uId=e.uniqueId
function e.keys(a)
local t={}
e.each(a,function(e,a)t[#t+1]=e end)
return t
end
function e.values(a)
local t={}
e.each(a,function(a,e)t[#t+1]=e end)
return t
end
function e.pairs(a)
local t={}
e.each(a,function(e,a)
t[#t+1]={e,a}
end)
return t
end
function e.extend(a,...)
local t={...}
e.each(t,function(o,t)
if e.isObject(t)then
e.each(t,function(e,t)
a[e]=t
end)
end
end)
return a
end
function e.functions(a,t)
if not a then return e.sort(e.keys(e))end
local t=t or{}
e.each(a,function(a,o)
if e.isFunction(o)then
t[#t+1]=a
end
end)
local a=r(a)
if a and a.__index then
e.functions(a.__index,t)
end
return e.sort(t)
end
e.methods=e.functions
function e.clone(t,i)
if not e.isObject(t)then return t end
local a={}
e.each(t,function(o,t)
if e.isObject(t)then
if not i then
a[o]=e.clone(t,i)
else a[o]=t
end
else
a[o]=t
end
end)
return a
end
function e.has(t,e)
return t[e]~=nil
end
function e.pick(t,...)
local o=e.flatten{...}
local a={}
e.each(o,function(o,e)
if t[e]then
a[e]=t[e]
end
end)
return a
end
e.choose=e.pick
function e.omit(a,...)
local o=e.flatten{...}
local t={}
e.each(a,function(a,i)
if not e.include(o,a)then
t[a]=i
end
end)
return t
end
e.drop=e.omit
function e.template(t,a)
e.each(a,function(e,a)
if not t[e]then
t[e]=a
end
end)
return t
end
e.defaults=e.template
function e.isEqual(a,i,s)
local n=o(a)
local o=o(i)
if n~=o then return false end
if n~='table'then return(a==i)end
local n=r(a)
local o=r(i)
if s then
if n or o and n.__eq or o.__eq then
return(a==i)
end
end
if e.size(a)~=e.size(i)then return false end
for t,a in t(a)do
local t=i[t]
if e.isNil(t)or not e.isEqual(a,t,s)then return false end
end
for t,o in t(i)do
local t=a[t]
if e.isNil(t)then return false end
end
return true
end
function e.result(t,a,...)
if t[a]then
if e.isCallable(t[a])then
return t[a](t,...)
else return t[a]
end
end
if e.isCallable(a)then
return a(t,...)
end
end
function e.isObject(e)
return o(e)=='table'
end
function e.isCallable(t)
return(e.isFunction(t)or
(e.isObject(t)and r(t)
and r(t).__call~=nil)or false)
end
function e.isArray(t)
if not e.isObject(t)then return false end
return e.all(e.keys(t),function(a,t)
return e.isNumber(t)and(m(t)==t)
end)
end
function e.isEmpty(t)
if e.isString(t)then return#t==0 end
if e.isObject(t)then return i(t)==nil end
return true
end
function e.isString(e)
return o(e)=='string'
end
function e.isFunction(e)
return o(e)=='function'
end
function e.isNil(e)
return e==nil
end
function e.isFinite(t)
if not e.isNumber(t)then return false end
return t>-g and t<g
end
function e.isNumber(e)
return o(e)=='number'
end
function e.isNaN(t)
return e.isNumber(t)and t~=t
end
function e.isBoolean(e)
return o(e)=='boolean'
end
local function a()
local t=e.functions()
local a=E()
e.each(t,function(o,t)
a[t]=e[t]
end)
end
local t=a
local t={import=a,mixin=t}
t.__index=t
return p(e,t)