local i
if keep_ambiguous then
i={_type='ambiguous'}
local function e(e)
return function()
error('Invalid '..e..' on ambiguous')
end
end
local e=
{
__add=e('addition'),
__sub=e('substraction'),
__mul=e('multiplication'),
__div=e('division'),
__mod=e('modulus operation'),
__pow=e('exponentiation'),
__unm=e('unary minus'),
__concat=e('concatenation'),
__len=e('length operation'),
__eq=e('equality comparison'),
__lt=e('less than'),
__le=e('less or equal'),
__index=e('indexing'),
__newindex=e('new indexing'),
__call=e('call'),
__tostring=function()return'ambiguous'end,
__tonumber=e('conversion to number')
}
setmetatable(i,e)
end
local h=
{
__index=true,
__newindex=true,
__type=true,
__class=true,
__bases=true,
__inherited=true,
__from=true,
__shared=true,
__user_init=true,
__name=true,
__initialized=true,
__root=true,
}
local a=
{
__init='__user_init',
__set='__user_set',
__get='__user_get'
}
local o={}
o.__index=o
function o:__newindex(e,t)
if a[e]then e=a[e]end
if e=='__user_get'then
self.__index=t and function(o,e)
local a=self[e]
if a==nil and not h[e]then a=t(o,e)end
return a
end or self
elseif e=='__user_set'then
self.__newindex=t and function(o,e,a)
if h[e]or not t(o,e,a)then rawset(o,e,a)end
end or nil
end
rawset(self,e,t)
end
local function d(t,s,r,o)
if r then
local e=s[t]
if e then return e end
end
local e={__type='object'}
if o==nil then
o=e
end
e.__root=o
e[t.__name]=e
local n=#t.__bases
if n>0 then
local a={}
local h={}
for n=1,n do
local n=t.__bases[n]
local t=d(n,s,t.__shared[n],o)
e[n.__name]=t
for e,t in pairs(t)do
if not h[e]then
if not a[e]then a[e]=t
elseif a[e]~=t then
a[e]=i
table.insert(h,e)
end
end
end
end
for t,a in pairs(a)do
if not e[t]then e[t]=a end
end
end
setmetatable(e,t)
if r then s[t]=e end
return e
end
function o:__call(...)
local e=d(self,{},false)
e:__init(...)
return e
end
function o:implements(a)
local function t(e)
if e==i then return false end
if type(e)=='function'then return true end
local e=getmetatable(e)
return e and type(e.__call)=='function'
end
for e,a in pairs(a)do
if not h[e]and t(a)and not t(self[e])then
return false
end
end
return true
end
function o:is_a(e)
if self.__class==e then return true end
local function t(a,e)
for o=1,#e do
local e=e[o]
if e==a or t(a,e.__bases)then
return true
end
end
return false
end
if not t(e,self.__bases)then return false end
return self:implements(e)
end
function o:__init(...)
if self.__initialized then return end
if self.__user_init then self:__user_init(...)end
for e=1,#self.__bases do
local e=self.__bases[e]
self[e.__name]:__init(...)
end
self.__initialized=true
end
function ofType(e)
local e=type(e)
return e=='table'and classname(e)or e
end
function typeof(t)
local e=type(t)
return e=='table'and t.__type or e
end
function classof(e)
local t=type(e)
return t=='table'and e.__class or nil
end
function classname(e)
if not classof(e)then return nil end
local e=e.__name
return type(e)=='string'and e or nil
end
function implements(e,t)
return classof(e)and e:implements(t)or false
end
function is_a(e,t)
return classof(e)and e:is_a(t)or false
end
class={}
local d={}
setmetatable(class,d)
function d:__call(...)
local e={...}
local t=
{
__type='class',
__bases={},
__shared={}
}
t.__class=t
t.__index=t
if type(e[1])=='string'then
t.__name=e[1]
table.remove(e,1)
else
t.__name=t
end
local n={}
local s={}
local d={}
for r=1,#e do
local a=e[r]
local e=typeof(a)
local o=e=='share'
assert(e=='class'or o,
'Base '..r..' is not a class or shared class')
if o then a=a.__class end
assert(t.__shared[a]==nil,'Base '..r..' is duplicated')
t.__bases[r]=a
t.__shared[a]=o
for e,r in pairs(a)do
if type(r)=='function'and not h[e]and(type(e)=='string'and not e:match'^_[^_]')and
not d[e]then
local t
local h=a.__inherited[e]
if h then
if h~=r then
a.__inherited[e]=nil
a.__from[e]=nil
else
t=a.__from[e]
end
end
t=t or{class=a,shared=o}
local a=s[e]
if not a then
s[e]=t
local t=t.class
n[e]=function(a,...)
return t[e](a[t.__name],...)
end
elseif a.class~=t.class or
not a.shared or not t.shared then
n[e]=i
table.insert(d,e)
s[e]=nil
end
end
end
end
setmetatable(t,o)
for e,a in pairs(n)do t[e]=a end
t.__inherited=n
t.__from=s
return t
end
function d:__index(e)
return function(...)
local t=class(e,...)
local a=getfenv(2)
a[e]=t
return t
end
end
function shared(e)
assert(typeof(e)=='class','Argument is not a class')
return{__type='share',__class=e}
end
