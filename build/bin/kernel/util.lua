local A,m=error,pcall
local i,o,e,t=next,type,unpack,select
local v,h=setmetatable,getmetatable
local c,_=table.insert,table.sort
local u,T=table.remove,table.concat
local E,x,b=math.randomseed,math.random,math.huge
local l,p,d=math.floor,math.max,math.min
local z=getfenv
local n=e
local t,s=pairs,ipairs
local e={}
local function j(t,e)return t>e end
local function g(e,t)return e<t end
local function f(e,t,a)return(e<t)and t or(e>a and a or e)end
local function k(t,e)return e and true end
local function q(e)return not e end
local function w(a)
local e
for t,t in t(a)do e=(e or 0)+1 end
return e
end
local function y(n,i,o,...)
local a
local o=o or e.identity
for t,e in t(n)do
if not a then a=o(e,...)
else
local e=o(e,...)
a=i(a,e)and a or e
end
end
return a
end
local r=-1
function e.format_number(e,t)local t=10^t local a=e%1 local o=e-a local e=a*t local e=e-e%1 return o+e/t end
function e.with(e,t,...)
local a,t=m(t,e,...)
if e and e.close then e:close()end
if not a then A('util.with:'..t,2)end
return a,t
end
function e.set(t,...)
local e={...}
local t,o=t,#e
for a=1,(o-2)do
t[e[a]]=t[e[a]]or{}
t=t[e[a]]
end
t[e[o-1]]=e[o]
end
function e.get(e,...)
local t={...}
for a=1,#t do
e=e[t[a]]
if e==nil then return nil end
end
end
function e.delete(e,...)
local t={...}
local a=#t
for a=1,a-1 do
e=e[t[a]]
if e==nil then return nil end
end
e[t[a]]=nil
end
function e.map_args(e,o)
local t={}
for a=1,table.maxn(e)do table.insert(t,o(e[a]))end
return t
end
function e.wait(o,i,...)
local e,a
repeat
e={o(...)}
a=true
for t,o in t(i)do
if e[t]~=nil and e[t]~=o then
a=false
break
end
end
until a
return e
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
for a,t in t(a)do
e[a]=t
end
return e
end
local m
m=function(i,s,a,n)
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
m(i,t,a[e],n)
end
elseif n or a[e]==nil then a[e]=t end
end
return a
end
e.copy=function(...)return m({},...)end
function e.diff(s,n,i)
local o={}
local a={}
local e=i and t or e.recursivepairs
for e,t in e(s)do a[e]=t end
for e,t in e(n)do
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
function e.recursivepairs(h,a)
check('table,?|string',h,a)
local function s(n,i,e)
e[n]=true
local h=i==""and i or"."
for t,a in t(n)do
t=h..tostring(t)
if o(a)=='table'then
if not e[a]then s(a,i..t,e)end
else
coroutine.yield(i..t,a)
end
end
e[n]=nil
end
a=a or""
return coroutine.wrap(function()s(h,cleanpath(a),{})end)
end
function e.multipairs(e,...)
local e={tables={e,...},i=1,k=i(e)}
local function n()
if not e.i then return end
local a=e.tables[e.i]
local t,o=e.k,a[e.k]
local o=i(a,t)
while o==nil do
e.i=e.i+1
local t=e.tables[e.i]
if not t then e.i=false;break
else o=i(t)end
end
e.k=o
return t,a[t]
end
return n,nil,nil
end
function e.each(a,o,...)
if not e.isObject(a)then return end
for e,t in t(a)do
o(e,t,...)
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
function e.reduce(o,i,a)
for t,e in t(o)do
a=not a and e or i(a,e)
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
function e.mapReduceRight(o,t,a)
return e.mapReduce(e.reverse(o),t,a)
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
function e.detect(o,a)
local i=e.isFunction(a)and a or e.isEqual
for t,e in t(o)do
if i(e,a)then return t end
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
for t,e in t(i)do
if not e then a[#a+1]=o[t]end
end
return a
end
e.discard=e.reject
function e.all(t,a,...)
return((#e.select(e.map(t,a,...),k))==(#t))
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
function e.pluck(t,a)
return e.reject(e.map(t,function(t,e)
return e[a]
end),
q)
end
function e.max(t,e,...)
return y(t,j,e,...)
end
function e.min(t,e,...)
return y(t,g,e,...)
end
function e.shuffle(a,t)
if t then E(t)end
local t={}
e.each(a,function(e,o)
local a=l(x()*e)+1
t[e]=t[a]
t[a]=o
end)
return t
end
function e.same(a,t)
return e.all(a,function(o,a)
return e.include(t,a)
end)
and e.all(t,function(o,t)
return e.include(a,t)
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
e.each(i,function(e,i)
local e=o(e,i,n(a))
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
return w(t[1])
else
return w(t)
end
end
function e.containsKeys(a,e)
for e in t(e)do
if not a[e]then return false end
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
for t,e in s(t)do
if o(t,e,...)then a[t]=e else break end
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
local a=a or g
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
e.each({...},function(a,e)c(t,1,e)end)
return t
end
function e.push(t,...)
e.each({...},function(a,e)t[#t+1]=e end)
return t
end
function e.pop(t)
local a=t[1]
u(t,1)
return a
end
e.shift=e.pop
function e.unshift(e)
local t=e[#e]
u(e)
return t
end
function e.removeRange(t,a,o)
local t=e.clone(t)
local n,i=(i(t)),#t
if i<1 then return t end
a=f(a or n,n,i)
o=f(o or i,n,i)
if o<a then return t end
local o=o-a+1
local a=a
while o>0 do
u(t,a)
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
function e.initial(t,a)
if a and a<0 then return end
return e.slice(t,1,a and#t-(d(a,#t))or#t-1)
end
function e.last(a,t)
if t and t<=0 then return end
return e.slice(a,t and#a-d(t-1,#a-1)or 2,#a)
end
function e.rest(t,a)
if a and a>#t then return{}end
return e.slice(t,a and p(1,d(a,#t))or 1,#t)
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
function e.uniq(a,o,t,...)
local a=t and e.map(a,t,...)or a
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
c(a,t)
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
function e.append(a,t)
local e={}
for t,a in s(a)do e[t]=a end
for a,t in s(t)do e[#e+1]=t end
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
local i=p(l((i-o)/a),0)
for e=1,i do t[#t+1]=o+a*e end
if#t>0 then c(t,1,o)end
return t
end
e.count=e.range
function e.invert(a)
local t={}
e.each(a,function(a,e)t[e]=a end)
return t
end
e.mirror=e.invert
function e.concat(t,i,o,a)
local t=e.map(t,function(t,e)
return tostring(e)
end)
return T(t,i,o,a)
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
function e.memoize(a,o)
local t=v({},{__mode='kv'})
local o=o or e.identity
return function(...)
local e=o(...)
local o=t[e]
if not o then t[e]=a(...)end
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
function e.times(t,a,...)
local e={}
for t=1,t do
e[t]=a(t,...)
end
return e
end
function e.bind(e,t)
return function(...)
return e(t,...)
end
end
function e.bindn(a,...)
local t={...}
return function(...)
return a(n(e.append(t,{...})))
end
end
function e.uniqueId(t,...)
r=r+1
if t then
if e.isString(t)then
return t:format(r)
elseif e.isFunction(t)then
return t(r,...)
end
end
return r
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
e.each(t,function(t,e)
a[t]=e
end)
end
end)
return a
end
function e.functions(a,t)
if not a then return e.sort(e.keys(e))end
local t=t or{}
e.each(a,function(o,a)
if e.isFunction(a)then
t[#t+1]=o
end
end)
local a=h(a)
if a and a.__index then
e.functions(a.__index,t)
end
return e.sort(t)
end
e.methods=e.functions
function e.clone(a,i)
if not e.isObject(a)then return a end
local t={}
e.each(a,function(o,a)
if e.isObject(a)then
if not i then
t[o]=e.clone(a,i)
else t[o]=a
end
else
t[o]=a
end
end)
return t
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
function e.isEqual(i,a,n)
local s=o(i)
local o=o(a)
if s~=o then return false end
if s~='table'then return(i==a)end
local s=h(i)
local o=h(a)
if n then
if s or o and s.__eq or o.__eq then
return(i==a)
end
end
if e.size(i)~=e.size(a)then return false end
for t,o in t(i)do
local t=a[t]
if e.isNil(t)or not e.isEqual(o,t,n)then return false end
end
for t,a in t(a)do
local t=i[t]
if e.isNil(t)then return false end
end
return true
end
function e.result(a,t,...)
if a[t]then
if e.isCallable(a[t])then
return a[t](a,...)
else return a[t]
end
end
if e.isCallable(t)then
return t(a,...)
end
end
function e.isObject(e)
return o(e)=='table'
end
function e.isCallable(t)
return(e.isFunction(t)or
(e.isObject(t)and h(t)
and h(t).__call~=nil)or false)
end
function e.isArray(t)
if not e.isObject(t)then return false end
return e.all(e.keys(t),function(a,t)
return e.isNumber(t)and(l(t)==t)
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
return t>-b and t<b
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
local a=z()
e.each(t,function(o,t)
a[t]=e[t]
end)
end
local t=a
local t={import=a,mixin=t}
t.__index=t
return v(e,t)