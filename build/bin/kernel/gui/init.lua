include'kernel.class'
local t=require'kernel.sched'
local e=require'kernel.checker'
local i=e.check
Term=require'Term'
local function e(a,e,t,i,o)
a['set'..e]=i or function(o,e)o[t]=e end
a['get'..e]=o or function(e)return e[t]end
end
local a={
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
function Terminal:__init(e,o)
i('native_terminal',e)
self.native=e
self.term=Term.from_native(e)
debug.namefield(self,'term')
self.pout=t.sigpipe()
debug.namefield(self,'pout')
self.renderer=t.task(function()
while true do
self.term:blit_native(self.native)
self.term:copyState(e)
self.term._calm=false
t.wait(false)
end
end)
self.renderer:link{[self.term]={'*'}}
debug.namefield(self,'renderer')
self.renderer:run()
if e.isColor()then
self.pout:link{[o]=a.mouse}
end
if e.setTextScale then
self.pout:link{[o]=a.touch}
else
self.pout:link{[o]=a.keyboard}
end
self.term:setSignals(true)
t.signal(self.term,'*')
end
end
