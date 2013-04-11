include'kernel.class'
local Opt=require'kernel.class.Opt'
local pipe=sched.pipe
class.Box()

do
	local def=Opt{
	pin=Opt(pipe),
	pout=Opt(pipe),
	perr=Opt(pipe),
	terminal=Opt(nil,'req'),
	env=Opt(function()
        local env=setmetatable({},{__index=_G})
        env._G=env
        return env
    end)
	}
	function Box:__init(opt)
		def:drop(self,opt)
		self.env.process=self
		self.env.print=function(...)
			local args={...}
			for i=1,table.getn(args) do
				self.pout:send(tostring(arg[i]))
			end
		end
		self.env.read=function(timeout)
			return self.pin:receive(timeout)
		end
		self.env.terminal=self.terminal
	end
	function Box:run(f,...)
		setfenv(f,self.env)
		return f(...)
	end
end

return Box