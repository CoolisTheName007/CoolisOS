------------------------------------------------------------------------------
-- timer module
--      supports one time timer timer.new(positive number)
--      supports periodic timer timer.new(negative number)
--      cron-compatible syntax (string conforming to cron syntax)
--      support simple timers
------------------------------------------------------------------------------
include'kernel.class'
local linked=require'utils.linked'
local check=require'kernel.checker'.check
local shcopy=require'kernel.util'.shcopy
local error=error
local read=read
PACKAGE_NAME='sched'


local sched=sched
local fil
local Obj=sched.Obj
local os = os
local math = math
local tonumber = tonumber
local assert = assert
local table = table
local pairs = pairs
local next = next
local type = type
local _G=_G
local os_time=os.clock
local setmetatable=setmetatable
local rawset=rawset
local unpack=unpack

env=getfenv()
setmetatable(env,nil)

local timer={}
timer.norm=function(t) --the CC clock moves in steps of 0.05
	t=t-t%0.05
	-- if t<=0 then
		-- error('time values must be non-negative and multiples of 0.05',3)--to be used internally inside timer functions
	-- end
	return t
end
local norm=timer.norm
-------------------------------------------------------------------------------------
-- Common scheduling code
-------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------
-- These functions must be attached as method :nextevent() to timer objects,
-- and return the timer's next due date.
-------------------------------------------------------------------------------------
local function stimer_nextevent (timer) return nil end

local events
local link,link_r
local n
-------------------------------------------------------------------------------------
-- Take a timer, reference it
-------------------------------------------------------------------------------------

timer.add = function(t)
	if not link_r[t] then
		local ind
		for val in linked.next_r,link,val do
			if val>t then
				ind=val
				break
			end
		end
		-- print(ind)
		if ind==nil then sched.ready=true end--if the next due date changed, signal the platform to break it's step
		link:insert_r(t,ind)
	end
end

-------------------------------------------------------------------------------------
-- Take a timer, dereference it
-------------------------------------------------------------------------------------
timer.remove = function(t)
	link:remove(t)
end

-------------------------------------------------------------------------------------
-- Signal all elapsed timer events.
-- This must be called by the scheduler every time a due date elapses.
-------------------------------------------------------------------------------------
function timer.step()
	if link_r[0]==-1 then return end -- if no timer is set just return and prevent further processing
	local now = os_time()
	while link_r[0]~=-1 and now >= link_r[0] do --about the above redundancy, maybe while loops are heavy?
		local nd = link:remove()
		sched.signal(timer,nd)
	end
end

timer.meta={__index=timer}
setmetatable(timer,{__index=Obj,__tostring=function() return 'Class timer' end})
-------------------------------------------------------------------------------------
-- returns the next expiration date
-------------------------------------------------------------------------------------
function timer.nextevent()
	-- print(link)
	if link_r[0]~=-1 then return link_r[0] end
end

local meta={
	__newindex=function(t,k,v)
		if type(k)~='number' then
			error(tostring(k)..'timer events must be numbers',2)
		end
		-- k=k-k%0.05 --math.ceil(t/0.05)*0.05 --maybe round up for user comfort? this way it's 1.5 time faster
		-- if k<=0 then
			-- error(k..'time values must be positive',2) 
		-- end
		if v==nil then
			timer.remove(k)
		else--could move it here...
			timer.add(k)
		end
		rawset(t,k,v)
	end,
	
}
---resets the timer module
timer._reset=function()
	events=setmetatable({[{}]='placeholder'},meta)
	sched.fil.timer=events
	link=linked()
	link_r=link.r
	timer.link=link
end

class.CyclicTimer(sched.Obj)
do
local C=CyclicTimer
local O=sched.Obj
function C:__init(delta,...)
	O:__init(self)
	check('number,function',delta,f)
	self.delta=norm(delta)
	self.f=f
	self.args={...}
end
function C:handle(_,ev)
	ev=ev+self.delta
	self:link{timer={ev}}
	self.f(unpack(self.args))
end
end
timer.cyclic=CyclicTimer


return timer