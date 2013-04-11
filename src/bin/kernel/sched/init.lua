include'kernel.class'
local log=require'kernel.log'
local check=require'kernel.checker'.check
local Linked=require 'utils.linked'
local table=table
local pairs=pairs

local sched,Obj,Sync,Task,timer,platform
local os_time

local fil
--[[
2D array of sets of objs, fil[emitter][event][obj]=true
wildcards for emitter, event are '*'; can only be used for listening
reserved values; do not use for custom signals:
	-emitters:
		'timer' 	-timer module;
		'platform'	-events yielded to the scheduler by os.pullEventRaw
]]


---emits a signal with emitter @emitter, event @event and parameters @vararg (...)
--can be called recursively; be careful not to signal the same entry which is being run
--to use infinite loops of signals (e.g. A->B->A) blocking the scheduler, use @Task or @Call instances.
local signal = function (emitter,event,...)
	log('sched', 'DEBUG', "SIGNAL [%s].[%s]", emitter, event)
	local function walk_event(evl,emitter,event,...)
		local copy={}
		for obj,val in pairs(evl) do
			copy[obj]=val
		end
		for obj,val in pairs(copy) do
			-- if d then print(obj) end
			obj:handle(emitter,event,...)
		end
	end
	
	local function walk_emitter(eml,emitter,event,...)
		local evl=eml[event]
		if evl then
			walk_event(evl,emitter,event,...)
		end
		evl=eml['*']
		if evl then
			walk_event(evl,emitter,event,...)
		end
	end
	
	local eml=fil[emitter]
	if eml then
		walk_emitter(eml,emitter,event,...)
	end
	local eml=fil['*']
	if eml then
		walk_emitter(eml,emitter,event,...)
	end
	
	return true
end

--[[Class that Task,Sync implement and that describes what can be put into the waiting table @fil.
--Objs instances keep track of which signals call their @handle field in their @fil field;
--their @parent and @subs fields maintain a tree-like hierarchy used to destroy @subs from an object before destroying the object itself.
--Objs expect to have defined a handle field consisting of a function used to process signals received, syncronously:
--@handle is a function called with args (obj,emitter,event,...) everytime a signal (emitter,event,...) that obj is linked too is emitted.
]]
Obj=class('Obj')
do
local O=Obj
--@name is an optional parameter to set a debugging name
function O:__init()
	self.fil={}
	self.subs={}
	if sched.running then self:setParent(sched.running) end
end

---Takes a link descriptor and tranforms them into a a proper link table for Obj methods to consume
--supports emitter,ev1,ev2,...,timeout
--or {[emt1]={ev1,ev2,...},...},timeout
local function get_args(...)
	local args={...}
	local nargs=#args
	local t,timeout
	if type(args[nargs])=='number' then
		timeout=args[nargs]
		nargs=nargs-1
	end
	if nargs~=0 then
		if nargs==1 then
			t=args[1]
		else
			t={[args[1]]={unpack(args,2,nargs)}}
		end
	end
	return t,timeout
end

--helper
local add_timer=function(t,nd)
	t=t or {}
	if nd then
		if not t[timer] then
			t[timer]={nd}
		else
			table.insert(t[timer],nd)
		end
	end
	return t
end

function get_t(...)
	local t,timeout=get_args(select(name and 3 or 2,...))
	if timeout then t=add_timer(t,timeout+os_time()) end
	return t
end

---Registers @obj in the waiting table @fil in the waiting sets described by the link table @t
function O:link(...)
	local t=get_t(...)
	if t==nil then return end
	local ofil=self.fil
	local root=self.__root
	local fil_tev,ofil_tev,fil_tobj
	for em,tev in pairs(t) do
		fil_tev=fil[em]
		ofil_tev=ofil[em]
		if not ofil_tev then
			ofil[em]={}
			ofil_tev=ofil[em]
			if not fil_tev then fil[em]={} fil_tev=fil[em] end
		end
		local ev
		for i=1,#tev do
			ev=tev[i]
			ofil_tev[ev]=true
			fil_tobj=fil_tev[ev]
			if not fil_tobj then fil_tev[ev]={} fil_tobj=fil_tev[ev] end
			fil_tobj[root]=true
		end
	end
end

---Unregisters @obj in the waiting table @fil from the waiting sets described by the link table @t
function O:unlink(...)
	local t=get_t(...)
	if t==nil then return end
	local ofil=self.fil
	local fil_tev,ofil_tev,fil_tobj
	for em,tev in pairs(t) do
		ofil_tev=ofil[em]
		if ofil_tev then
			fil_tev=fil[em]
			local ev
			for i=1,#tev do
				ev=tev[i]
				if ofil_tev[ev] then
					ofil_tev[ev]=nil
					
					fil_tobj=fil_tev[ev]
					fil_tobj[self]=nil
					if not next(fil_tobj) then fil_tev[ev]=nil end
				end
			end
			if not next(ofil_tev) then ofil[em]=nil end
			if not next(fil_tev) then fil[em]=nil end
		end
	end
end

---Unregisters @obj from all the waiting sets it is linked to.
function O:reset()
	local fil_tev
	for em,tev in pairs(self.fil) do
		fil_tev=fil[em]
		for ev in pairs(tev) do
			-- print(ev,'|',self,'|',fil_tev[ev],'|',fil_tev[ev][self])
			fil_tev[ev][self]=nil
			if not next(fil_tev[ev]) then fil_tev[ev]=nil end
		end
		if not next(fil_tev) then fil[em]=nil end
	end
	self.fil={}
end

local ending={n=0}
--helper
---Kills @obj 's subs and removes it from the waiting sets.
function O:silent_destroy()
	local root=self.__root
	if ending[root] then
		error('Detected recursion in Obj.finalize: ending stack='..pstring(ending),2)
	else
		ending.n=ending.n+1
		ending[root]=ending.n
	end
	--handle subs
	while next(self.subs) do
		next(self.subs):destroy()
	end
	
	if self.parent then
		self.parent.Obj.subs[root]=nil
	end
	--remove self from the waiting sets
	self:reset()
	
	--remove self from the action queue
	sched.queue:remove(root)
	
	ending[root]=nil
	ending.n=ending.n-1
end

---same as @O:silent_destroy, but throws some useful warning signals.
function O:destroy(...)
	if not self.destroyed then
		local r=self.__root
		signal(r,'dying',...) --warns subs
		self:silent_destroy()
		signal(r,'dead',...)
		self.destroyed=true
	end
end


local function check_tree(self,new_parent,seen)
    if new_parent==nil then return true,seen end
    new_parent=new_parent.__root
    local r=self.__root
    seen=seen or {r,[r]=true}
    if seen[new_parent] then return false,seen end
    table.insert(seen,new_parent)
    seen[new_parent]=true
    return check_tree(new_parent,new_parent.Obj.parent,seen)
end
---Changes  an @obj parent field.
function O:setParent(parent)
	local rparent,oparent=parent.__root,parent.Obj
	local root=self.__root
    local ok, t=check_tree(self,self.parent)
    if not ok then error('Cycle detected in scheduler hierarchy;debug:'..pstring(t),2) end
	if rparent==root then error("A scheduler object cannot be it's own parent",2) end
	if self.parent then self.parent.Obj.subs[root]=nil end
	self.parent=rparent
	oparent.subs[root]=true
    log('sched','DETAIL','(%s) parent set to (%s) by (%s)',self.__root,(parent and parent.__root),sched.running or 'nil')
end

local TIMEOUT_TOKEN={}
---helpers for linking @obj to timer signals
function O:setTimeout(timeout)
	if type(timeout)~='number' then
		error('timeout must be number',2)
	else
		timeout=timer.norm(timeout)
	end
	self:cancelTimeout()
	self[TIMEOUT_TOKEN]={
	timeout=timeout,
	td={timer={timeout+os_time()}},
	}
	self:link(self[TIMEOUT_TOKEN].td)
	return self
end

---cancels the current timeout and sets a new one in @timeout seconds, where @timeout was set by @O:setTimeout 
function O:resetTimeout()
	local td=self[TIMEOUT_TOKEN]
	if td then
		self:unlink(td.td)
		td.td[timer][1]=os_time()+td.timeout
		self:link(self.td.td)
	end
end

---cancels the current timeout
function O:cancelTimeout()
	local td=self[TIMEOUT_TOKEN]
	if td then
		self:unlink(td.td)
		self.td=nil
	end
end
end

 --[[syncronous calls; are called as soon as the signal is received, but can't block as tasks do
once are one-use,
on are permanent,
Constructors Sync.once and Sync.on take both either (function,...) or (name,function,...) where ... is a wait descriptor (see @get_args).
]]
Sync=class('Sync')
do
local S=Sync
local sync_once_handle = function(self,...)
	local sync=self.Sync
	local running=sched.running
	sched.running=self
	sync.f(...)
	self:destroy()
	sched.running = running
end
local sync_on_handle=function(self,...)
	local running=sched.running
	sched.running=self
	local sync=self.Sync
	sync.f(...)
	self:resetTimeout()
	sched.running=running
end
function S:__init(f,mode)
	check('function',f)
	mode=mode or 'on'
	Obj:__init(self)
	if mode=='once' then
	elseif mode=='on' then
	else error('mode?',2) end
	self.mode=mode
	log('sched','INFO','(%s) created with mode %s by (%s)',self,mode,sched.running or 'nil')
end
function S:handle(...)
	if self.mode=='on' then
		sync_once_handle(...)
	else
		sync_on_handle(...)
	end
end
end
--asyncronous calls through coroutines
Task=class('Task',Obj)
do
local T=Task
---Creates a task object in paused mode;
---fields set by Task.new are
--co: matching coroutine
--args: table of args to unpack and pass to co
--parent: parent task
--subs: sub tasks (see @{Task.setSub} and @{Task.setParent}
--name: name used for logging and result of tostring(task)
--Can take either (f) or (name,f) as args
--@return task
function T:__init(f,...)
	check('function',f)
	Obj:__init(self)
	self.co=coroutine.create( f )
	self.args={...}
	log('sched', 'INFO', 'created (%s) from function (%s) by (%s)', self, f,sched.running or 'nil')
end

---Schedules a task for execution with args (...)
--If T:handle is called several times before resuming the task, task.args will be overwritten and the last args set will be the last ones. 
function T:handle(...)
	self.args={...} --no point in catching args after nil, since self.args is unpacked before returning to the task.
	sched.queue:push(self)
	sched.ready=true
	
	log('sched', 'DETAIL', 'Task:handle rescheduling (%s) to receive SIGNAL [%s].[%s]',
	self,arg[1],arg[2])
	return self
end

---Runs a task with initial args ...
--@param vararg optional arguments to start the task with
--@return task
function T:run(...)
	self.args={...}
	sched.queue:push(self)
    log('sched', 'INFO', "Task.run scheduling (%s)", self)
	return self
end

--- Finishes a task and destroys it's subs.
-- @param self task to terminate (see @{Task.new})
-- @return  task
function T:destroy()
	if self.status~='dead' then
		log('sched', 'INFO', "Task.destroy destroying (%s) from (%s)",self,sched.running or 'nil')
		self.Obj:destroy()
		self.status='dead'
		if Task.running and Task.running.status=='dead' and Task.running.co==coroutine.running() then
			coroutine.yield()
		end
	end
	return self
end

function T:resume()
	sched.running = self
	
	local co=self.co
	Task.running=self
	
	log('sched', 'DETAIL', "Resuming (%s)", self)
	local success, msg = coroutine.resume (co)
	Task.running=nil
	self.args={}
	sched.running = nil
	if not success then
		-- report the error msg
		log('sched', 'ERROR', "In (%s):%s",self,msg)
		signal(self, "error",success, msg)
		--preserve events/subs for error catchers to analize, and then finalize
		self:destroy(success,msg)
	elseif coroutine.status (co) == "dead" then --If the coroutine died, signal it for those who synchronize on its termination.
		log('sched', 'INFO', "(%s) is dead", self)
		self:destroy(success,msg)
	end
end

--- Waits for a signal
--Can only be called from a task
--If called with no arguments, yields and reschedules for execution
--If called with false as argument, yields without rescheduling for execution
-- @param vararg an entries descriptor for the signal (see @{get_args})
-- @return  emitter, event, parameters
function T:wait(...)
	local task = self
	if task.co~=coroutine.running() then error('calling Task.wait outside a task/inside a task but inside another coroutine',2) end
	if ...==nil then
		log('sched', 'DETAIL', "Task.wait rescheduling (%s) for resuming ASAP", task)
		sched.queue:push(task)
	elseif ... then
		log('sched', 'DETAIL', "(%s) waiting", task)
		task:link(...)
	else
		log('sched', 'DETAIL', "(%s) waiting for pre-set signals", task)
	end
    coroutine.yield ()
	if ... then
		task:reset()
	end
	return unpack(task.args)
end

---resets the Task class vars
function Task._reset()
	Task.running=nil
end




-- local Wait={} --some optimizations

-- ---Blocks execution until a signal described by (...) is received; then calls f with the signal as argument (e.g. f(emitter,event,...))
-- --If f returns true, breaks the loop.
-- Wait.loop = function (f,...)
	-- check('function',f)
	-- local t,timeout=get_args(...)
	-- check('task',sched.running)
	-- local task=sched.running
	-- local t=t or {}
	-- task:link(t)
	-- if timeout then 
		-- local nd=os_time()+timeout
		-- while true do
			-- log('Wait','DEBUG','in loop')
			-- nd=os_time()+timeout
			-- task:link{timer={nd}}
			-- out=f(sched.wait(false))
			-- task:unlink{timer={nd}}
			-- if out then break end
		-- end
		-- log('Wait','DEBUG','out loop')
	-- else
		-- while true do
			-- log('Wait','DEBUG','in loop')
			-- if f(sched.wait(false)) then break end
		-- end
		-- log('Wait','DEBUG','out loop')
	-- end
	-- task:unlink(t)
-- end


---Some pre-built utilities for tasks

--helper
local function get_sigrun_wrapper(f,...)
	local wrapper = function(...)
		while true do
			f(sched.wait(...))
		end
	end
	log('sched', 'INFO', 'sigrun wrapper (%s) created from (%s)', 
		wrapper,f)
	return wrapper
end

--- Create a task that listens for a signal.
-- @param f function to be called when the signal appears. The signal
-- is passed to f as parameter. The signal will be provided as 
-- emitter, event, parameters, just as the result of a @{wait}
-- @param vararg a Wait Descriptor for the signal (see @{get_args})
-- @return task in the scheduler
Task._new_sigrun_task = function (f,...)
	return Task( get_sigrun_wrapper(f,...) )
end

--helper
local function get_sigrunonce_wrapper(f,...)
	local wrapper = function(...)
		f(sched.wait(...))
	end
	return wrapper
end

--- Create a task that listens for a signal, once.
-- @param f function to be called when the signal appears. The signal
-- is passed to f as parameter. The signal will be provided as 
-- _emitter, event, parameters_, just as the result of a @{wait}
-- @param vararg a Wait Descriptor for the signal (see @{get_args})
-- @return task in the scheduler
Task._new_sigrunonce_task = function (f,...)
	return Task( get_sigrunonce_wrapper(f,...))
end

--- Create and run a task that listens for a signal.
-- @param f function to be called when the signal appears. The signal
-- is passed to f as parameter. The signal will be provided as 
-- _emitter, event, parameters_, just as the result of a @{wait}
-- @param vararg a Wait Descriptor for the signal (see @{get_args})
-- @return task in the scheduler
Task._sigrun = function(f,...)
	return Task._new_sigrun_task(f,...):run()
end

--- Create and run a task that listens for a signal, once.
-- @param vararg a Wait Descriptor for the signal (see @{get_args})
-- @param f function to be called when the signal appears. The signal
-- is passed to f as parameter. The signal will be provided as 
-- _emitter, event, parameters_, just as the result of a @{wait}
-- @param attached if true, the new task will run in attached more
-- @return task in the scheduler (see @{taskd}).
Task._sigrunonce = function(f,...)
	return Task.new_sigrunonce_task(f,...):run()
end

end


do
sched={
--modules and respective shortcuts
signal=signal,
emit=function(...)
	sched.signal(sched.me(),...)
end,

Obj=Obj,
ready=false,
me=function() return sched.running end,
Task=Task,
Sync=Sync,
-- Call=Call,
-- Wait=Wait,

sigonce=function(f) return Sync(f,'once') end,
sighook=function(f) return Sync(f,'on') end,
wait=function(...) return sched.running:wait() end,
task=Task,
sigrun=Task._sigrun,
sigrunonce=Task._sigrunonce,

--others
}

local renv=setmetatable({sched=sched},{__index=_G})

sched.platform=require('platform',nil,nil,renv)
platform=sched.platform

os_time=platform.time

sched.timer=require('timer',nil,nil,renv)
timer=sched.timer

sched.pipe=require('pipe',nil,nil,renv)

sched.SigPipe=class('SigPipe',sched.pipe,Obj)
sched.sigpipe=sched.SigPipe
do
local S=sched.SigPipe
function S:handle(...)
    self:send{...}
end
end 



local loop_state = 'stopped' -- stopped, running or stopping

function sched.step()
	local old = sched.queue
	sched.queue=Linked()
    --------------------------------------------------------------------
    -- going through `self.queue` until it's empty.
    --------------------------------------------------------------------
    while true do
		local obj = old:remove() --pops first from left->right
		if obj==nil then break end
		
		obj:resume()
    end
	if not sched.queue:isempty() then sched.ready=true end
end

---Exits the scheduler after the current cycle is completed.
function sched.stop()
	log('sched','INFO','(%s) toggling loop_state=%s to stopping',Task.running or 'scheduler',loop_state)
	if loop_state=='running' then loop_state = 'stopping' end
end

---resets internal vars
function sched.reset()
	fil={}
	sched.fil=fil
	sched.running=nil
	sched.queue=Linked()
	Task._reset()
	timer._reset()
	
	platform._reset() --after timer
	loop_state = 'stopped'
	log('sched','INFO','scheduler cleaned.')
end

---Loops over the scheduler cycle,
--returning to the caller function after sched.stop has been called
--calling platform.step for performing sleeps.
function sched.loop ()
	log('sched','INFO','Scheduler started')
    loop_state = 'running'
	local timeout
    while true do --this block is the scheduler step
        timer.step() -- Emit timer signals
        sched.step() -- Run all the ready tasks
		-- Find out when the next timer event is due
        timeout = nil
		local date = timer.nextevent()
		if date then
			local now=os_time()
			timeout = date<now and 0 or date-now
		end
		
		if loop_state~='running' then sched.reset() break end
		platform.step(timeout,date) -- Wait for platform events until the next timer is due
		sched.ready=false
	end
end
sched.reset()

sched.global={
sched=sched,
signal=sched.signal,
emit=sched.emit,
wait=sched.wait,

--sigonce=sched.sigonce,
--sighook=sched.sighook,

task=sched.Task,
pipe=sched.Pipe,
sigpipe=sched.SigPipe,
sigrun=sched.sigrun,
sigrunonce=sched.sigrunonce,
}
end
return sched