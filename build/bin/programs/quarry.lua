include'kernel.class'
class.Machine()
local function o(e)
if e[1]then e[1].start=true end
for a,t in ipairs(e)do
t.next=e[a+1]
t.index=a
end
end
function Machine:__init(e)
o(e)
self.states=e
end
function Machine:find()
for t,e in ipairs(self.states)do
if e.is()then
return e
end
end
error'no match for state'
end
function Machine:run(e)
e=e or self.states[1]
while e do
e.action()
e=e.next
end
end
Vec3=require'utils.Vec3'
local h=5
local s=300
Var=require'kernel.class.Var'
var=Var('ect/quarry.var')
winding=require'dev.winding'
include'utils.turtle'
select=function(e)
if type(e)~='number'then e=e.slot end
return turtle.select(e)
end
drop=turtle.drop
refuel=turtle.refuel
function clear_inv()
for e=7,16 do
select(e)
drop()
end
end
function dirClear(e)select(16)clear(e)clear_inv()end
api.ensureFuel=function()
if turtle.getFuelLevel()<10 then
refuel_machine:run()
end
end
F,R,C,M,T,I={slot=1},{slot=2},{slot=3},{slot=4},{slot=5},{slot=6}
function isInv(o,a,i,t)
local function e(e)
local e=turtle.getItemCount(e)
if e==0 or e==1 then return e
else error('inv not match')end
end
return e(2)==o and e(3)==a and e(4)==i and e(5)==t
end
function has(e)
local e=turtle.getItemCount(e.slot)
if e~=1 and e~=0 then error'no inv match'
else return e==1 end
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
is=function()return not refuel_states[1].is()end,
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
sleep(h)
end,
},
{is=function()
return isInv(0,0,0,1)and front.detect()
end,
action=function()
if not back()then
select(16)
move'back'
turn'back'
end
clear_inv()
end},
{is=function()
return isInv(0,0,0,1)and not front.detect()
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
local e=peripheral.wrap('front')
e.shutdown()
e.turnOn()
select(R.slot)
repeat
front.suck()
until turtle.getItemCount(R.slot)==1
e.shutdown()
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
return isInv(1,0,0,1)and not down.detect()
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
return isInv(1,1,0,1)and not down.detect()
end,
action=function()
select(16)
force'front'
drop()
end,
},
{is=function()
return isInv(1,1,0,1)and down.detect()
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
is=function()return((not has(I))and has(R))end,
action=function()
select(R)
repeat
up.drop()
until(not has(R))
end,
},
{
is=function()return not(has(I)or has(R))end,
action=function()
sleep(2)
select(R)
repeat
up.suck()
until(has(R))
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
run=function(e,n)
function project(e)
return{e.x,e.z}
end
print'...........'
print((get()))
print(n)
local e=project((get())-n)
print(e[1],e[2])
var.count=var.count or 0
repeat
if var.count>s then
recharge_machine:run()
end
print('actual:',e[1],e[2])
local t=winding{e[1],e[2]}
print('winding:',t[1],t[2])
print('turning:',t[1]-e[1],0,t[2]-e[2])
turn{t[1]-e[1],0,t[2]-e[2]}
print('pos,dir:',get())
local o,i=e[1],e[2]
local a=math.max(math.abs(o),math.abs(i))
if(not(o==a and i==(a-1)))and((not(a==math.abs(o)and a==math.abs(i)))or(a==o and a==-i))then
well_machine:run()
end
local a=n+Vec3{t[1],0,t[2]}
print('to:',a)
goto(a)
e=t
until false
end,
}
function resume()
order={
refuel_machine,
recharge_machine,
well_machine,
}
for e,t in ipairs(order)do
local e=t:find()
if not e.start then
t:run(e)
end
end
end
function main(e,t)
h=e or h
s=t or s
resume()
var.center=var.center or(get())
wind_machine:run(Vec3(var.center))
end