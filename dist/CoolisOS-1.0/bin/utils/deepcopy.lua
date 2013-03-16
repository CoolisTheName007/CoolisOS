do
local u=type
local f=rawget
local l=rawset
local m=next
local d=getmetatable
local r=setmetatable
local c=unpack
local t={}
t.deepcopy_copyfunc_list={
_plainolddata=function(t,e,t,t)
return e,true
end,
["table"]=function(t,o,e,n,h,s,a,u)
local a,i=nil,false
if n==nil then
e=t[o]
if e~=nil then
return e,true
else
e={}
t[o]=e
local a=d(o)
if a~=nil then
if not t.metatable_immutable then
t:_recurse(a)
return e,'metatable'
else
r(e,a)
end
end
end
a=nil
i=true
elseif n=='metatable'then
local o=s
t:_pop(2)
if o~=nil then
r(e,o)
end
a=nil
i=true
elseif n=='key'then
local n=h
local s=s
if s~=nil then
local a=f(o,n)
t:_recurse(a)
return e,'value'
else
t:_pop(2)
a=n
i=true
end
elseif n=='value'then
local h=h
local n=s
local o=u
t:_pop(4)
if o~=nil then
l(e,n,o)
end
a=h
i=true
end
if i then
local a,o=m(o,a)
if a~=nil then
t:_recurse(a)
return e,'key'
else
return e,true
end
end
return
end,
["function"]=function(t,a,e,o,o,o,o)
local o,o=false,nil
e=t[a]
if e~=nil then
return e,true
elseif t.function_immutable then
e=a
return e,true
else
e=loadstring(string.dump(a),nil,nil,t.function_env)
t[a]=e
return e,true
end
end,
["userdata"]=nil,
["lightuserdata"]=nil,
["thread"]=nil,
}
t.deepcopy_copyfunc_list["number"]=t.deepcopy_copyfunc_list._plainolddata
t.deepcopy_copyfunc_list["string"]=t.deepcopy_copyfunc_list._plainolddata
t.deepcopy_copyfunc_list["boolean"]=t.deepcopy_copyfunc_list._plainolddata
t.deepcopy_copyfunc_list["nil"]=t.deepcopy_copyfunc_list._plainolddata
do
local a,o,r,n,h=0,1,2,3,4
function t.deepcopy_push(...)
local e=select('#',...)
local t=stack._top+1
for e=1,e do
stack[t+e]=select(e,...)
end
stack._top=stack_top+e
end
function t.deepcopy_pop(e,t)
e._top=e._top-t
end
function t.deepcopy_recurse(e,d)
local s=e._ptr
local i=e._top
local t=i+1
e._top=i+h
e._ptr=t
e[t+a]=d
e[t+o]=nil
e[t+r]=s
e[t+n]=nil
end
function t.deepcopy(i,e,d)
local e=e or{}
e[1+a]=i e[1+o]=nil
e[1+r]=nil e[1+n]=nil
e._ptr=1 e._top=4
e._push=t.deepcopy_push e._pop=t.deepcopy_pop
e._recurse=t.deepcopy_recurse
local l=t.deepcopy_copyfunc_list
repeat
local t=e._ptr
local s=e[t+a]
local i,a
e[0]=e[0]
if e.value_ignore and e.value_ignore[s]then
i=nil
a=true
else
if e.value_translate then
i=e.value_translate[s]
if i~=nil then
a=true
end
end
if not a then
local h=u(s)
local h=(
d and d[h]
or l[h]
or error(("cannot copy type %q"):format(h),2)
)
i,a=h(
e,
s,
e[t+o],
c(e,t+n,e._top)
)
end
end
e[t+o]=i
if a==true then
local a=e[t+r]
e._top=t+1
t=a
e._ptr=t
else
e[t+n]=a
end
until t==nil
return e[1+o]
end
end
return t.deepcopy
end
