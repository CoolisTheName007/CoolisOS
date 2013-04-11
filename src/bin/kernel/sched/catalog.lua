--- A general purpose Catalog.
-- The catalog is used to give tasks well known names for sharing purposes. 
-- It also allows synchronization, by blocking the requester until the object
-- is made available. Catalogs themselves are made available under a Well Known
-- name. Typical catalogs are "tasks", "mutexes" and "pipes".
-- The catalog does not check for multiple names per object.
-- @module catalog
-- @usage local tasks = require 'catalog'()
--...
--tasks:register('a task', sched.Task.running)
--...
--local a_task=tasks:waitFor('a task')
-- @alias M
include'kernel.class'
local log = require'kernel.log'
local check=require'kernel.checker'.check
local sched=require'kernel.sched'

local named=setmetatable({},{__mode='kv'})

class.Catalog()
local C=Catalog
C.named=named
function C:__init()
	self.objs=setmetatable({},{__mode='kv'})
end
function C:register(obj,name)
	if type(obj)~='table' then error('not a table',2) end
	if self.objs[name]~=obj then error('name taken',2) end
	self.objs[obj]=name
	self.objs[name]=obj
	sched.signal(self,'+'..name,obj)
	
	named[obj]=named[obj] or setmetatable({},{__mode='kv'})
	named[obj][self]=true
end
function C:unregister(id)
	local s = self.objs[id]
	local name=type(s)=='string' and s or id
	self.objs[s]=nil
	self.objs[id]=nil
	
	if named[obj] then
		named[obj][self]=nil
	end
	sched.signal(self,'-'..name,obj)
end
function C:waitFor(name,timeout)
	check('string',name)
	log('catalog', 'INFO', 'catalog %s queried for name "%s" by %s',self, name,sched.me())
	
	local obj
	if self[name] then return self[name] else
		local em,ev,o=sched.wait(self,'+'..name,timeout)
		if em==self then obj=o end
	end
	log('catalog', 'INFO', 'catalog %s queried for name "%s" by %s, found %s',self, name,sched.me(),obj)
	return obj
end

return C