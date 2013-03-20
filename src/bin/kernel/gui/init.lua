include'kernel.class'

local checker=require'kernel.checker'
local check=checker.check
local function property(class, attribute,field,setter,getter)
	class['set'..attribute]=setter or function(self,val) self[field]=val end
	class['get'..attribute]=getter or function(self) return self[field] end
end



class.EvtH()
do
	function EvtH:__init()
		self.dest={}
		self.sources={}
		self.handlers={}
	end
	function EvtH:handle(event,...)
		
	end
	function EvtH:emit(event,...)
		
	end
	function EvtH:connect(source,...)
		
	end
end