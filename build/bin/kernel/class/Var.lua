include'kernel.class'
local e=require'kernel.checker'
local o=require'utils.serpent'.dump
local a=require'kernel.util'
class.Var()
local e=setmetatable({},{__mode='k'})
function Var:__init(t,a)
e[self]={}
e[self].file=t
local e=loadreq.getDir(e[self].file)
if not fs.exists(e)then fs.makeDir(e)end
if not fs.exists(t)then self:setAll{}end
end
function Var:getAll()
local t
a.with(fs.open(e[self].file,'r'),function(e)
t=e.readAll()
end)
local e=loadstring(t)()
return e
end
function Var:setAll(t)
a.with(fs.open(e[self].file,'w'),function(e)
e.write(o(t))
end)
end
function Var:__get(e)
return self:getAll()[e]
end
function Var:__set(t,a)
local e=self:getAll()
e[t]=a
self:setAll(e)
return true
end
return Var