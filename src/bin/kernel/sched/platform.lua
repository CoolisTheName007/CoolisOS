local log=require'kernel.log'
local sched,pairs,string,term,_G,fs,os,print,unpack,select,pprint,next=sched,pairs,string,term,_G,fs,os,print,unpack,select,pprint,next
local coroutine=coroutine
local tostring,math=tostring,math
local plat={}

local sched=sched
local fil
env=getfenv()
setmetatable(env,nil)

---Whether or not the coroutine running will yield to the scheduler
plat.is_running=function()
	return sched and sched.Task.running and sched.Task.running.co==coroutine.running()
end

plat.time = os.clock
local time=plat.time
local wake_ev=tostring({})
local Task=sched.Task

local cc,CC,load=0,1,0
last_yield,last_return=-math.huge,-math.huge
plat.info=function()
	return string.format('load: %s;last yield: %d;last return:%s',load,last_yield,last_return)
end

local yield=function(...)
	log('platform','DETAIL',plat.info())
	last_yield=time()
	cc=last_yield-last_return
	local x={coroutine.yield(...)}
	last_return=time()
	CC=last_return-last_yield
	load=cc/(CC+cc)
	return x
end

function plat.step(timeout)
	if sched.ready then timeout=0 end
	if timeout then
		local ev,id
		if timeout==0 then
			if time()-last_return>=0.05 then --retain control for at most (as far as the scheduler can control) one tick if necessary; set to math.huge in case there is too much of a delay between computers;
				log('platform','DETAIL','yielding to platform')
				ev=wake_ev
				os.queueEvent(ev)
			else
				return
			end
		else
			ev,id='timer',os.startTimer(timeout)
		end
		local x
		repeat
			x=yield()
			if (ev==nil or x[1]==ev) and (id==nil or id==x[2]) then
				break
			else
				sched.signal(plat,unpack(x))
				if sched.ready then break end
			end
		until false
		return
	else
		if not fil[plat] then
			log('platform','DETAIL','no timers or platform listeners, so exiting.')
			sched.stop()
			return
		end
		local filter
		if not next(fil[plat],next(fil[plat])) then
			filter=next(fil[plat])
		end
		sched.signal(plat,unpack(yield(filter)))
		return
	end
end

function plat._reset()
	fil=sched.fil
end

return plat