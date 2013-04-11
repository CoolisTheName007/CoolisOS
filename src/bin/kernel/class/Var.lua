include'kernel.class'
local check=require'kernel.checker'
local dump=require'utils.serpent'.dump
local util=require'kernel.util'
class.Var()
local p=setmetatable({},{__mode='k'})
function Var:__init(file,opt)
	p[self]={}
	p[self].file=file
	local dir=loadreq.getDir(p[self].file)
	if not fs.exists(dir) then fs.makeDir(dir) end
	if not fs.exists(file) then self:setAll{} end 
end

function Var:getAll()
	local s
	util.with(fs.open(p[self].file,'r'),function(f)
		s=f.readAll()
	end)
	local t=loadstring(s)()
	return t
end

function Var:setAll(t)
	util.with(fs.open(p[self].file,'w'),function(f)
		f.write(dump(t))
	end)
end

function Var:__get(k)
	return self:getAll()[k]
end
function Var:__set(k,v)
	local t=self:getAll()
	t[k]=v
	self:setAll(t)
	return true
end
return Var