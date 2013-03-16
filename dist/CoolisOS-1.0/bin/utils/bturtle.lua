local e=require'utils.Vec3'
include'kernel.class'
state_stack={}
function get_move_queue()
local a={}
for t=1,10 do
table.insert(function()goto(e(t,0,0))end)
end
return a
end
function get_coords()
f=fs.open('ect/pos','r')
pos=e(textutils.deserialize(f.readAll()))
f.close()
return pos
end
function save_pos(e)
f=fs.open('ect/pos','w')
f.writeLine(e:serialize())
f.close()
end
function get_state_for(e)
local t=get_coords()
for a,e in pairs(e)do
if e==t then return a end
end
end
function do_queue(e)
cur=get_state_for(e)
for t=cur,#e do
goto(e[t])
end
end
function main()
mov_queue=get_move_queue()
do_queue(queue)
end
function sign(e)
return(not e or e==0)and 0 or e>0 and 1 or-1
end
up={name="up",dig=turtle.digUp,move=turtle.up,detect=turtle.detectUp,place=turtle.placeUp,compare=turtle.compareUp,drop=turtle.dropUp,}
forward={name="forward",dig=turtle.dig,move=turtle.forward,detect=turtle.detect,place=turtle.place,compare=turtle.compare,drop=turtle.drop,}
down={name="down",dig=turtle.digDown,move=turtle.down,detect=turtle.detectDown,place=turtle.placeDown,compare=turtle.compareDown,drop=turtle.dropDown,}
forward.at=function()
at.x=at.x+d.x
at.z=at.z+d.z
end
up.at=function()
at.y=at.y+1
end
down.at=function()
at.y=at.y-1
end
function shouldDig(e)
return false
end
function left()
turtle.turnLeft()
d.x,d.z=-d.z,d.x
pervar.update(Namespace,"d",d)
end
function right()
turtle.turnRight()
d.x,d.z=d.z,-d.x
pervar.update(Namespace,"d",d)
end
function turn(e)
local e,t=sign(e.x),sign(e.z)
if e==d.x and t==d.z then
return
elseif(e==-d.x and e~=0)or(t==-d.z and t~=0)then
left()
left()
elseif t~=0 then
if t==-d.x then right()else left()end
elseif e~=0 then
if e==d.z then right()else left()end
end
end
function move(e)
if e.move()then
e.at()
pervar.update(Namespace,"at",at)
return true
else
return false
end
end
function dig(t)
local e=true
disposeJunk()
checkOverflow()
e=t.dig()
return e
end
function advance(e,t)
t=t or 1
for t=1,t do
while not move(e)do
if e.detect()then
if shouldDig()then
if not dig(e)then
print("Un-dig-able obstacle.Trying again and expecting a different result. Not mad, see?")
sleep(10)
end
else
print("Found obstacle and i'm not supposed to dig it.Help!")
sleep(10)
end
else
print("Something that I can't detect is blocking my path. Move it!")
turtle.attack()
end
end
end
end
function goto(e)
if e.y>at.y then
advance(up,e.y-at.y)
elseif e.y<at.y then
advance(down,at.y-e.y)
end
if e.x~=at.x then
turn({x=e.x-at.x})
advance(forward,math.abs(e.x-at.x))
end
if e.z~=at.z then
turn({z=e.z-at.z})
advance(forward,math.abs(e.z-at.z))
end
end
function str_to_t(t)
local e={}
for t in string.gmatch(t,'%a[%d-]*')do
argletter=string.sub(t,1,1)
argnum=string.sub(t,2)
e[argletter]=tonumber(argnum)
end
return e
end
function t_to_crd(e)
local o,a,t
o=vc{x=e.x or 0,y=e.y or 0,z=e.z or 0}
a=vc{x=(e.r or 1)-1,y=(e.u or 1)-1,z=(e.f or 1)-1}
t=vc{x=-(e.l or 1)+1,y=-(e.d or 1)+1,z=-(e.b or 1)+1}
return o+a+t
end
function requestDrop()
if serverID then
print('Requesting drop.')
rednet.send(serverID,'need_drop')
end
end
function waitDrop()
if serverID then
print('Waiting message.')
repeat
senderID,message,distance=rednet.receive()
print(senderID,message,distance)
until(senderID==serverID and message=='go')
print('Moving to drop.')
end
end
function unlockDrop()
if serverID then
print('Unlocking drop point.')
rednet.send(serverID,'drop_done')
print('Drop point unlocked.')
end
end
function dropLoot(e)
util.narg(e,{
waitPoint=vc(),
dropPoint=vc(),
gotoD=goto,
gotoW=goto,
fDrop=drop.default,
leaveD=goto,
leaveW=goto,
serverID=nil,
})
print(2)
local e=pervar.exists(Namespace,'state')and pervar.read(Namespace,'state')or 0
if serverID then util.open_modem()print('Modem online.')end
if e==0 then
print('Drop sequence iniciated')
local t=vc(at)
pervar.update(Namespace,'stoppedAt',t)
e=1
pervar.update(Namespace,'state',e)
end
if e==1 then
print('Going to wait point.')
gotoW(waitPoint)
e=1.5
pervar.update(Namespace,'state',e)
requestDrop()
end
if e==1.5 then
print('Waiting for free drop point.')
waitDrop()
e=2
pervar.update(Namespace,'state',e)
end
if e==2 then
print('Going to drop point.')
gotoD(dropPoint)
e=3
pervar.update(Namespace,'state',e)
end
if e==3 then
print('Dropping.')
fDrop()
print('Done dropping.')
e=4
pervar.update(Namespace,'state',e)
end
if e==4 then
print('Going back to wait point.')
leaveD(waitPoint)
e=5
pervar.update(Namespace,'state',e)
unlockDrop()
end
if e==5 then
print('Resuming position.')
leaveW(pervar.read(Namespace,'stoppedAt'))
e=0
pervar.update(Namespace,'state',e)
pervar.delete(Namespace,'stoppedAt')
end
print('Drop sequence complete')
if serverID then util.close_modem()print('Modem offline.')end
return true
end
function isFull(e)
return getItemCount(default_set.n)~=0
end
function checkOverflow()
if isFull()then
if pervar.read(Namespace,'state')==0 then
print('Need to drop.')
dropLoot()
end
end
end
function designate(e,t)
print("Designate "..e.." as "..t)
if not slot[e]then slot[e]={}end
if not slot[t]then slot[t]={}end
slot[e].designation=t
table.insert(slot[t],e)
pervar.update(Namespace,'slot',slot)
end
default_set={1,2,3,4,5,6,7,8,9}
default_set.n=#default_set
drop={}
drop.ground=function(e)
util.narg(e,{
set=default_set,
min=0,
max=0,
dir=forward,
})
for t,e in ipairs(set)do
turtle.select(e)
if turtle.getItemCount(e)>max then
dir.drop(turtle.getItemCount(e)-min)
end
end
turtle.select(slot.normal[1]or 1)
end
drop.RP2=function(e)
util.narg(e,{
n=default_set.n,
wait=false,
signal=util.flare,
})
for e=1,n do
while turtle.getItemCount(e)>0 do
signal()
if not wait then
break
end
end
end
end
drop.default=drop.ground
function getCount(e)
e=e or default_set
local t=0
for a,e in ipairs(e)do
t=t+turtle.getItemCount(e)
end
return t
end
load.API('pervar')
env=getfenv()
Namespace='bturtle'
default={
at=vc(),
d=vc(0,0,1),
slot={junk={},normal={}},
}
function reload()
for e,t in pairs(default)do
if pervar.exists(Namespace,e)then
if e=='at'or e=='d'then
env[e]=vc(t)
else
env[e]=pervar.read(Namespace,e)
end
else
env[e]=t
pervar.update(Namespace,e,t)
end
end
end
reload()
return env