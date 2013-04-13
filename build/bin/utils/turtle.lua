if not _G.turtle then error('not a turtle',2)end
if turtle._old then
turtle=util.shcopy(turtle._old)
else
turtle._old=util.shcopy(turtle)
end
local e=log
local d=function(...)return e('turtle',...)end
include'kernel.class'
local a=require'utils.Vec3'
local e=require'kernel.util'
local s=require'kernel.class.Var'
local i
local t,e
local o='ect/turtle'
if not fs.exists(o)then fs.makeDir(o)end
local n=require'utils.serpent'.dump
local n=s(fs.combine(o,'pos-dir.var'))
local o=s(fs.combine(o,'mode.var'))
local function s(a,t)
for e,o in pairs(t)do
if a[e]==nil then
a[e]=t[e]
end
end
end
s(o,{
dig=true,
attack=true,
count=20,
delay=.5,
gps=false,
})
local function s()
n.pos=t
n.dir=e
end
local function l()
t,e=a(n.pos),a(n.dir)
end
function set(a,o)
t,e=(a or t):clone(),(o or e):clone()
s()
end
function get()return t:clone(),e:clone()end
local function r(e)
return(e==nil or e==0)and 0 or(e>0 and 1 or-1)
end
function ensureFuel()
if i.ensureFuel then i.ensureFuel()end
end
moves={}
do
local n={
up={
vec=function()return a(0,1,0)end,
at=function(e)
e.y=e.y+1
end,
raw_name="up",
attack=turtle.attackUp,
suck=turtle.suckUp,dig=turtle.digUp,raw_move=turtle.up,detect=turtle.detectUp,place=turtle.placeUp,compare=turtle.compareUp,drop=turtle.dropUp,},
forward={
vec=function()return a(e.x,0,e.z)end,
at=function(e,t)
e.x=e.x+t.x
e.z=e.z+t.z
end,
attack=turtle.attack,
raw_name="forward",suck=turtle.suck,dig=turtle.dig,raw_move=turtle.forward,detect=turtle.detect,place=turtle.place,compare=turtle.compare,drop=turtle.drop,},
down={
vec=function()return a(0,-1,0)end,
at=function(e)
e.y=e.y-1
end,
attack=turtle.attackDown,
raw_name="down",suck=turtle.suckDown,dig=turtle.digDown,raw_move=turtle.down,detect=turtle.detectDown,place=turtle.placeDown,compare=turtle.compareDown,drop=turtle.dropDown,},
back={
vec=function()return a(-e.x,0,-e.z)end,
at=function(e,t)
e.x=e.x-t.x
e.z=e.z-t.z
end,
raw_name='back',raw_move=turtle.back},
}
local o={
left={
vec=function()return a(e.z,0,-e.x)end,
raw_name='turnLeft',raw_move=turtle.turnLeft,at=function(t,e)e.x,e.z=e.z,-e.x end},
right={
vec=function()return a(-e.z,0,e.x)end,
raw_name='turnRight',raw_move=turtle.turnRight,at=function(t,e)e.x,e.z=-e.z,e.x end},
}
local a={
up='down',
forward='back',
right='left',
}
for t,e in pairs(a)do a[e]=t end
local function i(a,o,i,n)
if n then ensureFuel()end
a(t,e)
s()
local a=o()
if not a then i(t,e)s()end
return a
end
for t,e in pairs(n)do
local a={e.at,e.raw_move,n[a[t]].at,true}
turtle[e.raw_name]=function()return i(unpack(a))end
e.move=turtle[e.raw_name]
moves[t]=e
end
for t,e in pairs(o)do
local a={e.at,e.raw_move,o[a[t]].at}
turtle[e.raw_name]=function()return i(unpack(a))end
e.move=turtle[e.raw_name]
moves[t]=e
end
for t,e in pairs(moves)do
setmetatable(e,
{__call=function(t,...)
return e.move(...)
end,
})
end
moves.top=moves.up
moves.bottom=moves.down
moves.front=moves.forward
end
for a,t in pairs(moves)do
local e=(getfenv())
e[a]=t
end
compass={
{name='north',n=0,vec=function()return a(0,0,-1)end},
{name='east',n=1,vec=function()return a(1,0,0)end},
{name='south',n=2,vec=function()return a(0,0,1)end},
{name='west',n=3,vec=function()return a(-1,0,0)end},
}
for t,e in pairs(compass)do compass[e.name]=e end
function getFacing(t)
local o
if t==nil then o=e
elseif classof(t)==a then o=t
elseif type(t)=='string'then o=moves[t].vec()
else error()end
for t,e in ipairs(compass)do
if o==e.vec()then return e.name end
end
end
function getChunk(e)
e=e or t
return math.floor(e.x/16),math.floor(e.z/16)
end
function getChunkPosition(e)
e=e or t
return e.x%16,e.z%16
end
local function h(...)
if classof(...)==a then
return...
elseif type(...)=='string'then
if moves[...]then
return moves[...].vec()
elseif compass[...]then
return compass[...].vec()
end
else return a(...)end
end
local n=false
function clear(t)
t=type(t)=='string'and moves[t]or t
local i=o.count
local s=o.delay
local a=0
local e=0
while(t.detect())and(e<i)do
if(e==0)then
if not o.dig then
return false,'dig'
end
end
a=(t.dig()and 1 or 0)+e
e=e+1
sleep(s)
end
if a~=0 then n=true end
return(e~=i),e,a
end
function force(e)
e=type(e)=='string'and moves[e]or e
local a
if not n then
a=e.move()
if a then return true,0,0 end
end
local s=o.count
local h=o.delay
local i=0
local t=0
while(not a)and(t<s)do
if e.detect()then
if(t==0)then
if not o.dig then
return false,'dig'
end
end
i=(e.dig()and 1 or 0)+t
sleep(h)
else
if not o.attack then
return false,'attack'
end
e.attack()
end
a=e.move()
t=t+1
end
if i~=0 then n=true end
return a,t,i
end
function advance(e,t)
e=type(e)=='string'and moves[e]or e
t=t or 1
for t=1,t do
force(e)
end
end
function turn(...)
local t=h(...)
local a,t=r(t.x),r(t.z)
if a==e.x and t==e.z then
return
elseif(a==-e.x and a~=0)or(t==-e.z and t~=0)then
left()
left()
elseif a~=0 then
if a==-e.z then right()else left()end
elseif t~=0 then
if t==e.x then right()else left()end
end
end
function goto(...)
local e=h(...)
if e.y>t.y then
advance(up,e.y-t.y)
elseif e.y<t.y then
advance(down,t.y-e.y)
end
if e.x~=t.x then
turn({x=e.x-t.x})
advance(forward,math.abs(e.x-t.x))
end
if e.z~=t.z then
turn({z=e.z-t.z})
advance(forward,math.abs(e.z-t.z))
end
end
function move(...)
local e=h(...)
return goto(e+t)
end
function debug()
return({lastMoveNeededDig=n,pos_dir={get()}})
end
local function n()
l()
t,e=(t or a()),(e or compass.south.vec())
s()
if o.gps then
local a,e,t=pcall(getGps)
if a then set(e,t)
else d('WARNING','Could not use gps:',e)end
end
end
function getGps()
rednet.open'right'
local e,t,o=gps.locate(5)
if e then
gps_pos=a(e,t,o)
local e=(get())
for o,t in ipairs(compass)do
if goto(t.vec()+e)then
local e,o,t=gps.locate(5)
if e then
local t=a(e,o,t)
local e=t-gps_pos
if e~=a(0,0,0)then
return true,t,e
end
end
end
end
error'blocked'
else
error'no gps signal'
end
end
n()
i={
debug=debug,
set=set,
get=get,
moves=moves,
front=moves.forward,
bottom=moves.down,
top=moves.up,
clear=clear,
force=force,
advance=advance,
mode=o,
getFacing=getFacing,
getChunk=getChunk,
getChunkPos=getChunkPos,
compass=compass,
getGps=getGps,
turn=turn,
move=move,
goto=goto,
}
for t,e in pairs(moves)do i[t]=e end
i.api=i
return i