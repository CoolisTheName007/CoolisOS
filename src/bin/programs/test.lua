--CoolisOS/dev/test.lua

-- r()
function r()
v=loadreq.reload'utils.Vec3'
t=loadreq.reload'utils.turtle'
end
r()
function g()
shell.run('CoolisOS/dev/quarry.lua')
m=recharge_machine
end
g()

-- function r()
	-- w=loadreq.reload'dev.winding'
	-- iter=function(_,p) return w(p) end
	-- for p in iter,nil,{0,0} do
		-- print(p[1],',',p[2])
		-- os.pullEvent'key'
	-- end
-- end