local log=require 'kernel.log'
local sched,pairs,string,term,_G,fs,os,print,unpack,select,pprint,next=sched,pairs,string,term,_G,fs,os,print,unpack,select,pprint,next
local coroutine=coroutine
local tostring,math=tostring,math
PACKAGE_NAME='sched'


local sched=sched
local fil
local link_r
local read=read
local tprint=tprint
env=getfenv()
setmetatable(env,nil)

---Whether or not the coroutine running will yield to the scheduler
is_running=function()
	return sched and sched.Task.running and sched.Task.running.co==coroutine.running()
end

local time=os.clock
env.time = time
local WAIT_TOKEN=tostring({})
local Task=sched.Task
local cc,CC,last_yield,last_return,load=0,1,-1,1,0

debug=function()
	return cc,CC,last_yield,last_return,load
end

local yield=function(...)
	last_yield=time()
	cc=last_yield-last_return
	local x={coroutine.yield(...)}
	last_return=time()
	CC=last_return-last_yield
	load=cc/(CC+cc)
	return x
end

function step(timeout,nd)
	if sched.ready then timeout=0 end
	sched.ready=false
	if timeout then
		local id
		if timeout==0 then
			if time()-last_return>=0.05 then --retain control for at most (as far as the scheduler can control) one tick if necessary; set to math.huge in case there is too much of a delay between computers;
				os.queueEvent('timer',WAIT_TOKEN)
				id=WAIT_TOKEN
			else
				return
			end
		else
			id=os.startTimer(timeout)
		end
		if fil.platform then
			local x
			local plat=fil.platform
			repeat
				x=yield()
				if x[1]=='timer' and x[2]==id then
					break
				else
					sched.signal('platform',unpack(x))
					if sched.ready then break end
				end
			until false
			return
		else
			repeat
			until id == yield('timer')[2]
			return
		end
	else
		if not fil.platform then
			log('platform','INFO','no timers or platform listeners, so exiting.')
			sched.stop()
			return
		end
		local filter
		if not next(fil.platform,next(fil.platform)) then
			filter=next(fil.platform)
		end
		sched.signal('platform',unpack(yield(filter)))
		return
	end
end

function _reset()
	fil=sched.fil
	link_r=sched.Timer.link.r
end

return env