local a={['\n']=true;['r']=true;['\t']=true;[' ']=true;[',']=true;[':']=true}
function removeWhite(e)
while a[e:sub(1,1)]do
e=e:sub(2)
end
return e
end
function isArray(a)
local e=0
for t,t in ipairs(a)do
e=e+1
end
local t=0
for e,e in pairs(a)do
t=t+1
end
if t==e then return true else return false end
end
function encodeBoolean(t,e)
return e..tostring(t)
end
function parseBoolean(e)
if e:sub(1,4)=="true"then
return true,removeWhite(e:sub(5))
else
return false,removeWhite(e:sub(6))
end
end
local i={['e']=true;['E']=true;['+']=true;['-']=true;['.']=true}
function encodeNumber(t,e)
return e..tostring(t)
end
function parseNumber(t)
local e=1
while i[t:sub(e,e)]or tonumber(t:sub(e,e))do
e=e+1
end
local a=tonumber(t:sub(1,e-1))
t=removeWhite(t:sub(e))
return a,t
end
function encodeString(t,o)
local e="\""
for a=1,t:len()do
local t=t:sub(a,a)
if t=="\n"then
e=e.."\\n"
elseif t=="\r"then
e=e.."\\r"
elseif t=="\t"then
e=e.."\\t"
elseif t=="\""then
e=e.."\\\""
elseif t=="\\"then
e=e.."\\\\"
else
e=e..t
end
end
return o..e.."\""
end
function parseString(e)
e=e:sub(2)
local t=""
local a=false
while e:sub(1,1)~="\""and not a do
if a then
if e:sub(1,1)=="n"then
t=t.."\n"
elseif e:sub(1,1)=="r"then
t=t.."\r"
elseif e:sub(1,1)=="t"then
t=t.."\t"
elseif e:sub(1,1)=="\""then
t=t.."\""
elseif e:sub(1,1)=="\\"then
t=t.."\\"
else
t=t.."\\"..e:sub(1,1)
end
elseif e:sub(1,1)=="\\"then
a=true
else
t=t..e:sub(1,1)
end
e=e:sub(2)
end
e=removeWhite(e:sub(2))
return t,e
end
function encodeArray(t,e)
e=e.."["
for a,t in ipairs(t)do
e=encodeValue(t,e)
e=e..","
end
if e:sub(-1)==","then
e=e:sub(1,-2)
end
return e.."]"
end
function parseArray(e)
e=removeWhite(e:sub(2))
local a={}
local t=1
while e:sub(1,1)~="]"do
local o=nil
o,e=parseValue(e)
a[t]=o
t=t+1
e=removeWhite(e)
end
e=removeWhite(e:sub(2))
return a,e
end
function encodeObject(t,e)
e=e.."{"
for a,t in pairs(t)do
e=encodeMember(a,t,e)
e=e..","
end
if e:sub(-1)==","then
e=e:sub(1,-2)
end
return e.."}"
end
function parseObject(e)
e=removeWhite(e:sub(2))
local a={}
while e:sub(1,1)~="}"do
local t,o=nil,nil
t,o,e=parseMember(e)
a[t]=o
e=removeWhite(e)
end
e=removeWhite(e:sub(2))
return a,e
end
function encodeMember(a,t,e)
e=encodeValue(a,e)..":"
return encodeValue(t,e)
end
function parseMember(e)
local a=nil
a,e=parseValue(e)
local t=nil
t,e=parseValue(e)
return a,t,e
end
function encodeValue(e,t)
if type(e)=="table"then
if isArray(e)then
return encodeArray(e,t)
else
return encodeObject(e,t)
end
elseif type(e)=="number"then
return encodeNumber(e,t)
elseif type(e)=="string"then
return encodeString(e,t)
elseif type(e)=="boolean"then
return encodeBoolean(e,t)
end
end
function parseValue(e)
local t=e:sub(1,1)
if t=="{"then
return parseObject(e)
elseif t=="["then
return parseArray(e)
elseif tonumber(t)~=nil or i[t]then
return parseNumber(e)
elseif e:sub(1,4)=="true"or e:sub(1,5)=="false"then
return parseBoolean(e)
elseif t=="\""then
return parseString(e)
end
return nil
end
function encode(e)
return encodeValue(e,"")
end
function decode(e)
e=removeWhite(e)
t=parseValue(e)
return t
end