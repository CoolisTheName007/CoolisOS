--CoolisOS/dev/quarry.lua
include'kernel.class'

class.Machine()
local function link(t)
	if t[1] then t[1].start=true end
	for i,v in ipairs(t) do
		v.next=t[i+1]
		v.index=i
	end
end
function Machine:__init(t)
	link(t)
	self.states=t
end
function Machine:find()
	for i,v in ipairs(self.states) do
		if v.is() then
			return v
		end
	end
	error'no match for state'
end
function Machine:run(state)
	state=state or self.states[1]
	while state do
		state.action()
		state=state.next
	end
end

Vec3=require'utils.Vec3'

local delay=5
local max_count=300
Var=require'kernel.class.Var'
var=Var('ect/quarry.var')


winding=require'dev.winding'

include'utils.turtle'
select=function(t)
	if type(t)~='number' then t=t.slot end
	return turtle.select(t)
end
drop=turtle.drop
refuel=turtle.refuel
function clear_inv()
	for i=7,16 do
		select(i)
		drop()
	end
end
function dirClear(dir) select(16) clear(dir) clear_inv() end


api.ensureFuel=function()
	if turtle.getFuelLevel()<10 then
		refuel_machine:run()
	end
end

F,R,C,M,T,I={slot=1},{slot=2},{slot=3},{slot=4},{slot=5},{slot=6}
function isInv(a,b,c,d)
	local function is(s)
		local c=turtle.getItemCount(s)
		if c==0 or c==1 then return c
		else error('inv not match') end
	end
	return is(2)==a and is(3)==b and is(4)==c and is(5)==d
end
function has(t)
	local c=turtle.getItemCount(t.slot)
	if c~=1 and c~=0 then error'no inv match'
	else return c==1 end
end

refuel_states={
{
is=function()
	select(F)
	refuel()
	return has(F)
end,
action=function()
	dirClear(up)
	select(F)
	up.place()
end,
},
{
is=function() return not refuel_states[1].is() end,
action=function()
	repeat
		up.suck()
		turtle.refuel()
		if turtle.getFuelLevel()>10 then
			break
		else
			sleep(1)
		end
	until false
	drop()
	up.dig()
end,
},
}

well_states={
{is=function()
	return isInv(1,1,1,1)
end,
action=function()
	select(16)
	down.dig()
	drop()
	force'forward'
	drop()
	down.dig()
	drop()
	select(M.slot)
	down.place()
	select(16)
	back()
	drop()
	select(C.slot)
	down.place()
end,
},
{is=function()
	return isInv(1,0,0,1)
end,
action=function()
	select(R.slot)
	front.place()
	sleep(delay)
end,
},
{is=function()
	return isInv(0,0,0,1) and front.detect()
end,
action=function()
	if not back() then
		select(16)
		move'back'
		turn'back'
	end
	clear_inv()
end},
{is=function()
	return isInv(0,0,0,1) and not front.detect()
end,
action=function()
	select(T.slot)
	front.place()
end,
},
{is=function()
	return isInv(0,0,0,0)
end,
action=function()
	local p=peripheral.wrap('front')
	p.shutdown()
	p.turnOn()
	select(R.slot)
	repeat
		front.suck()
	until turtle.getItemCount(R.slot)==1
	p.shutdown()
end,
},
{is=function()
	return isInv(1,0,0,0)
end,
action=function()
	select(T.slot)
	front.dig()
end,
},
{is=function()
	return isInv(1,0,0,1) and not down.detect()
end,
action=function()
	select(16)
	force'front'
	drop()
end,
},
{is=function()
	return isInv(1,0,0,1)
end,
action=function()
	select(C.slot)
	down.dig()
end,
},
{is=function()
	return isInv(1,1,0,1) and not down.detect()
end,
action=function()
	select(16)
	force'front'
	drop()
end,
},
{is=function()
	return isInv(1,1,0,1) and down.detect()
end,
action=function()
	select(M.slot)
	down.dig()
end,
},
}

recharge_states={
{
is=function()
	return has(I)
end,
action=function()
	dirClear(up)
	select(I)
	up.place()
end,
},
{
is=function() return ((not has(I)) and has(R)) end,
action=function()
	select(R)
	repeat
		up.drop()
	until (not has(R))
end,
},
{
is=function() return not (has(I) or has(R)) end,
action=function()
	sleep(2)
	select(R)
	repeat
		up.suck()
	until (has(R))
	var.count=0
	select(I)
	up.dig()
end,
},
}

refuel_machine=Machine(refuel_states)
recharge_machine=Machine(recharge_states)

well_machine=Machine(well_states)

wind_machine={
run=function(self,center)
	function project(v)
		return {v.x,v.z}
	end
	print'...........'
	print((get()))
	print(center)
	local p=project((get())-center)
	print(p[1],p[2])
	var.count=var.count or 0
	repeat
		if var.count>max_count then
			recharge_machine:run()
		end
		
		print('actual:',p[1],p[2])
		local n=winding{p[1],p[2]}
		print('winding:',n[1],n[2])
		print('turning:',n[1]-p[1],0,n[2]-p[2])
		turn{n[1]-p[1],0,n[2]-p[2]}
		print('pos,dir:',get())
		local x,z=p[1],p[2]
		local d=math.max(math.abs(x),math.abs(z))
		if (not(x==d and z==(d-1))) and ((not(d==math.abs(x) and d==math.abs(z))) or (d==x and d==-z)) then
			well_machine:run()
		end
		local nex=center+Vec3{n[1],0,n[2]}
		print('to:',nex)
		goto(nex)
		p=n
	until false
end,
}

function resume()
	order={
	refuel_machine,
	recharge_machine,
	well_machine,
	}
	for _,machine in ipairs(order) do
		local s=machine:find()
		if not s.start then
			machine:run(s)
		end
	end
end

function main(_delay,_max_count)
	delay=_delay or delay
	max_count=_max_count or max_count
	resume()
	var.center=var.center or (get())
	wind_machine:run(Vec3(var.center))
end