include'kernel.class'
local sched=require'kernel.sched'
local checker=require'kernel.checker'
local check=checker.check
Term=require'Term'
local function property(class, attribute,field,setter,getter)
	class['set'..attribute]=setter or function(self,val) self[field]=val end
	class['get'..attribute]=getter or function(self) return self[field] end
end

local cc_events={
mouse={
'mouse_click',
'mouse_scroll',
'mouse_drag',
},
touch={
'monitor_touch',
},
keyboard={
'key',
'char',
},
}

class.Terminal()
do
function Terminal:__init(term,emitter)
    check('native_terminal',term)
	self.native=term
	self.term=Term.from_native(term)
    self.pout=sched.sigpipe()
	self.renderer=sched.sigrun(function()
		self.term:blit_native(self.native)
		self.term:copyState(term)
	end,{[self.term]={'*'}})
	if term.isColor() then
		self.pout:link{[emitter]=cc_events.mouse}
	end
	if term.setTextScale then
		self.pout:link{[emitter]=cc_events.touch}
	else
		self.pout:link{[emitter]=cc_events.keyboard}
	end
end
end

