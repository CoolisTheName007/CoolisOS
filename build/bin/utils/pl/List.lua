local n,r,c,m=table.insert,table.remove,table.concat,table.sort
local s,u,i,v,y,p,e=setmetatable,getmetatable,type,tostring,assert,string,next
local e=io.write
local e=require'tablex'
local f,w,b,k,z,_=e.filter,e.imap,e.imap2,e.reduce,e.transform,e.removevalues
local d=e
local g=d.sub
local a=require'utils'
local x,T,e,t,l=a.array_tostring,a.split,a.is_type,a.assert_arg,a.function_arg
local E=d._normalize_slice
local j=a.stdmt.MultiMap
local e=a.stdmt.List
e.__index=e
e._class=e
local h
s(e,{
__call=function(a,t)
return e.new(t)
end,
})
local function o(a,t)
local e=e
if t then
e=u(t)
end
return s(a,e)
end
local function q(t)
return u(t)==e
end
local function u(e)
return i(e)=='table'and not q(e)and#e>0
end
function e:_init(e)
if e then
for e in h(e)do
n(self,e)
end
end
end
function e.new(a)
local t
if not u(a)then
t={}
e._init(t,a)
else
t=a
end
o(t)
return t
end
function e:clone()
local t=o({},self)
e._init(t,self)
return t
end
function e.default_map_with(e)
return function(a,t)
local e=e[t]
if e then
return function(t,...)
return t:map(e,...)
end
else
error("method not found: "..t,2)
end
end
end
function e:append(t)
n(self,t)
return self
end
e.push=n
function e:extend(e)
t(1,e,'table')
for t=1,#e do n(self,e[t])end
return self
end
function e:insert(e,a)
t(1,e,'number')
n(self,e,a)
return self
end
function e:put(e)
return self:insert(1,e)
end
function e:remove(e)
t(1,e,'number')
r(self,e)
return self
end
function e:remove_value(t)
for e=1,#self do
if self[e]==t then r(self,e)return self end
end
return self
end
function e:pop(a)
if not a then a=#self end
t(1,a,'number')
return r(self,a)
end
e.get=e.pop
local d=d.find
e.index=d
function e:contains(e)
return d(self,e)and true or false
end
function e:count(a)
local e=0
for t=1,#self do
if self[t]==a then e=e+1 end
end
return e
end
function e:sort(e)
if e then e=l(1,e)end
m(self,e)
return self
end
function e:sorted(t)
return e(self):sort(t)
end
function e:reverse()
local e=self
local a=#e
local t=a/2
for t=1,t do
local a=a-t+1
e[t],e[a]=e[a],e[t]
end
return self
end
function e:minmax()
local a,t=1e70,-1e70
for e=1,#self do
local e=self[e]
if e<a then a=e end
if e>t then t=e end
end
return a,t
end
function e:slice(t,e)
return g(self,t,e)
end
function e:clear()
for e=1,#self do r(self)end
return self
end
local r=1e-10
function e.range(s,o,i)
if not o then
o=s
s=1
end
if i then
t(3,i,'number')
if not a.is_integer(i)then o=o+r end
else
i=1
end
t(1,s,'number')
t(2,o,'number')
local e=e.new()
for t=s,o,i do n(e,t)end
return e
end
function e:len()
return#self
end
function e:chop(e,t)
return _(self,e,t)
end
function e:splice(e,a)
t(1,e,'number')
e=e-1
local t=1
for a in h(a)do
n(self,t+e,a)
t=t+1
end
return self
end
function e:slice_assign(e,a,o)
t(1,e,'number')
t(1,a,'number')
e,a=E(self,e,a)
if a>=e then self:chop(e,a)end
self:splice(e,o)
return self
end
function e:__concat(a)
t(1,a,'table')
local e=self:clone()
e:extend(a)
return e
end
function e:__eq(e)
if#self~=#e then return false end
for t=1,#self do
if self[t]~=e[t]then return false end
end
return true
end
function e:join(a)
a=a or''
t(1,a,'string')
return c(x(self),a)
end
e.concat=c
local function a(t)
local e=v(t)
if i(t)=='string'then
e='"'..e..'"'
end
return e
end
function e:__tostring()
return'{'..self:join(',',a)..'}'
end
local a={}
function a:__index(e)
return function(t,...)
return self.list:foreachm(e,...)
end
end
function e:foreach(e,...)
if e==nil then
return s({list=self},a)
end
e=l(1,e)
for t=1,#self do
e(self[t],...)
end
end
function e:foreachm(t,...)
for e=1,#self do
local e=self[e]
local t=y(e[t],"method not found on object")
t(e,...)
end
end
function e:filter(t,e)
return o(f(self,t,e),self)
end
function e.split(e,a)
t(1,e,'string')
return o(T(e,a))
end
local t={}
function t:__index(e)
return function(t,...)
return self.list:mapm(e,...)
end
end
function e:map(e,...)
if e==nil then
return s({list=self},t)
end
return o(w(e,self,...),self)
end
function e:transform(e,...)
z(e,self,...)
return self
end
function e:map2(t,e,...)
return o(b(t,self,e,...),self)
end
function e:mapm(t,...)
local a={}
local e=self
for o=1,#e do
local e=e[o]
local n=e[t]
if not n then error(i(e).." does not have method "..t,2)end
a[o]=n(e,...)
end
return o(a,self)
end
function e:reduce(e)
return k(e,self)
end
function e:partition(t,...)
t=l(1,t)
local a={}
for o=1,#self do
local o=self[o]
local t=t(o,...)
if t==nil then t='<nil>'end
if not a[t]then a[t]=e()end
a[t]:append(o)
end
return s(a,j)
end
function e:iter()
return h(self)
end
function e.iterate(e)
if i(e)=='string'then
local t=0
local a=#e
local o=p.sub
return function()
t=t+1
if t>a then return nil
else
return o(e,t,t)
end
end
elseif i(e)=='table'then
local t=0
local a=#e
return function()
t=t+1
if t>a then return nil
else
return e[t]
end
end
elseif i(e)=='function'then
return e
elseif i(e)=='userdata'and io.type(e)=='file'then
return e:lines()
end
end
h=e.iterate
return e
