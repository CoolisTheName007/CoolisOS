local z,T="serpent",.224
local E,_="Paul Kulchenko","Lua serializer and pretty printer"
local c={[tostring(1/0)]='1/0 --[[math.huge]]',[tostring(-1/0)]='-1/0 --[[-math.huge]]',[tostring(0/0)]='0/0'}
local g={thread=true,userdata=true}
local n,l,t={},{},(_G or _ENV)
for t,e in ipairs({'and','break','do','else','elseif','end','false',
'for','function','goto','if','in','local','nil','not','or','repeat',
'return','then','true','until','while'})do n[e]=true end
for t,e in pairs(t)do l[e]=t end
for a,e in ipairs({'coroutine','io','math','string','table','os'})do
for a,t in pairs(t[e])do l[t]=e..'.'..a end end
local function y(z,t)
local y,b,u,e=t.name,t.indent,t.fatal,t.debug
local q,k,d,f=t.sparse,t.custom,not t.nohuge,t.debug
local s,_=(t.compact and''or' '),(t.maxlevel or math.huge)
local p,h='_'..(y or''),t.comment and(tonumber(t.comment)or math.huge)
local o,r,i,a={},{'local '..p..'={}'},{},0
local function v(e)return'_'..(tostring(tostring(e)):gsub("[^%w]",""):gsub("(%d%w+)",
function(e)if not i[e]then a=a+1;i[e]=a end return i[e]end))end
local function w(e)return type(e)=="number"and(d and c[tostring(e)]or e)
or type(e)~="string"and tostring(e)
or("%q"):format(e):gsub("\010","n"):gsub("\026","\\026")end
local function d(e,t)
return h and(t or 0)<h and' --[['..(f and type(e)~='string'and debug.getinfo(e)or tostring(e))..']]'or''end
local function x(e,t)return l[e]and l[e]..d(e,t)or not u
and w(select(2,pcall(tostring,e)))or error("Can't serialize "..tostring(e))end
local function j(t,e)
local e=e==nil and''or e
local a=type(e)=="string"and e:match("^[%l%u_][%w_]*$")and not n[e]
local e=a and e or'['..w(e)..']'
return(t or'')..(a and t and'.'or'')..e,e end
local E=type(t.sortkeys)=='function'and t.sortkeys or function(a,t,e)
local t,i=tonumber(e)or 12,{number='a',string='b'}
local function o(e)return("%0"..t.."d"):format(e)end
table.sort(a,function(t,e)
return(a[t]and 0 or i[type(t)]or'z')..(tostring(t):gsub("%d+",o))
<(a[e]and 0 or i[type(e)]or'z')..(tostring(e):gsub("%d+",o))end)end
local function u(e,h,n,c,m,z,a,i)
local y,i,a=type(e),(a or 0),getmetatable(e)
local m,b=j(m,h)
local h=z and
((type(h)=="number")and''or h..s..'='..s)or
(h~=nil and b..s..'='..s or'')
if o[e]then
if f then return h..d(e,i)end
table.insert(r,m..s..'='..s..o[e])
return h..'nil'..d('ref'..tostring(e),i)end
if a and not f then
if a.__serialize or a.__tostring then
o[e]=c or m
if rawget(a,'__serialize')then e=a.__serialize(e)else e=tostring(e)end
y=type(e)
end
end
if y=="table"then
if i>=_ then return h..'{}'..d('max',i)end
o[e]=c or m
if next(e)==nil then return h..'{}'..d(e,i)end
local m,a,w=#e,{},{}
for e=1,m do table.insert(a,e)end
for e in pairs(e)do if not a[e]then table.insert(a,e)end end
if t.sortkeys then E(a,e,t.sortkeys)end
for h,a in ipairs(a)do
local h,m,y=e[a],type(a),h<=m and not q
if t.valignore and t.valignore[h]
or t.keyallow and not t.keyallow[a]
or t.valtypeignore and t.valtypeignore[type(h)]
or q and h==nil then
elseif m=='table'or m=='function'or g[m]then
if f then
local e
if not(o[a]or l[a])then
o[a]=debug.getinfo(a)
e='['..(u(a,nil,n,nil,nil,false,i+1))..']'..d(a,i)
end
table.insert(w,u(h,e or(o[a]or l[a]),n,c,nil,true,i+1))
else
if not o[a]and not l[a]then
local e=j(p,v(a))
r[#r]=u(a,e,n,e,p,true)
end
table.insert(r,'placeholder')
local e=o[e]..'['..(o[a]or l[a]or v(a))..']'
r[#r]=e..s..'='..s..(o[h]or u(h,nil,n,e))
end
else
table.insert(w,u(h,a,n,c,o[e],y,i+1))
end
end
local t=string.rep(n or'',i)
local o=n and'{\n'..t..n or'{'
local a=table.concat(w,','..(n and'\n'..t..n or s))
local t=n and"\n"..t..'}'or'}'
return(k and k(h,o,a,t)or h..o..a..t)..d(e,i)
elseif g[y]then
o[e]=c or m
return h..x(e,i)
elseif y=='function'and not f then
o[e]=c or m
local o,a=pcall(string.dump,e)
local t=o and((t.nocode and"function() --[[..skipped..]] end"or
"loadstring("..w(a)..",'@serialized')")..d(e,i))
return h..(t or x(e,i))
else return h..w(e)end
end
local e=b and"\n"or";"..s
local t=u(z,y,b)
local a=#r>1 and table.concat(r,e)..e or''
return not y and t or"do local "..t..e..a.."return "..y..e.."end"
end
local function a(e,t)if t then for t,a in pairs(t)do e[t]=(e[t]==nil and a or e[t])end end;return e;end
return{_NAME=z,_COPYRIGHT=E,_DESCRIPTION=_,_VERSION=T,serialize=y,
dump=function(t,e)return y(t,a({name='_',compact=true,sparse=true},e))end,
line=function(e,t)return y(e,a({sortkeys=true,comment=true},t))end,
block=function(t,e)return y(t,a({indent='  ',sortkeys=true,comment=true},e))end}