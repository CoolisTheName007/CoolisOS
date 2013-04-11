

--[[
process:
-state
-state handler
--interrupts
-state machines?
-complex for generalism
-simple for dig queues: <- are generally stateless
	are kept separately, dig queues are just vector coords
	position and orientation->state
	turtle api overwritten to catch movement
	interpreter command to set position, world-wide
	implies keepig initial referencial
	simple wrap-up of goto
(need stack like state machines for pausing, and then returning)
-general pathfinding
	djikstra algorithm
	maintainig map
	- imprredictable movement
	+ can contornate obstacles
]]
--state_stack={}
--
--
--
--function get_move_queue()
--	local q={}
--	for i=1,10 do
--		table.insert(function() goto(Vec3(i,0,0)) end)
--	end
--	return q
--end
--
--[[doing queue implies
--getting state/resuming state
--executing and saving <- open new, save current, delete old
--goto needs some context
--turtle movement is single -coroutined; means that mode can be global
--]]
--function get_coords()
--	f=fs.open('ect/pos','r')
--	pos=Vec3(textutils.deserialize(f.readAll()))
--	f.close()
--	return pos
--end
--function save_pos(pos)
--	f=fs.open('ect/pos','w')
--	f.writeLine(pos:serialize())
--	f.close()
--end
--
--
--function get_state_for(queue)
--	local coords=get_coords()
--	for i,v in pairs(queue) do
--		if v==coords then return i end
--	end
--end
--function do_queue(queue)
--	cur=get_state_for(queue)
--	for i=cur,#queue do
--		goto(queue[i])
--	end
--end
--
--function main()
--	mov_queue=get_move_queue()
--	do_queue(queue)
--end

if not _G.turtle then error('not a turtle',2) end

if turtle._old then
	turtle=util.shcopy(turtle._old)
else
	turtle._old=util.shcopy(turtle)
end

local _log=log
local log=function(...) return _log('turtle',...) end

include'kernel.class'
local Vec3=require'utils.Vec3'

local util=require'kernel.util'
local Var=require'kernel.class.Var'

---forward declaration
local api

--persistence
local pos,dir
local saveDir='ect/turtle'
if not fs.exists(saveDir) then fs.makeDir(saveDir) end

local dump=require'utils.serpent'.dump
local var=Var(fs.combine(saveDir,'pos-dir.var'))
local mode=Var(fs.combine(saveDir,'mode.var'))

local function merge(dst,src)
	for i,v in pairs(src) do
		if dst[i]==nil then
			dst[i]=src[i]
		end
	end
end
merge(mode,{
dig=true,
attack=true,
count=20,
delay=0.5,
gps=false,
})


local function save()
   var.pos=pos
   var.dir=dir
end
local function load()
	pos,dir=Vec3(var.pos),Vec3(var.dir)
end

function set(_pos,_dir)
	pos,dir=(_pos or pos):clone(),(_dir or dir):clone()
	save()
end
function get() return pos:clone(),dir:clone() end

local function sign(num)
	return (num==nil or num==0) and 0 or (num>0 and 1 or -1)
end 
--fuel handling
function ensureFuel()
	if api.ensureFuel then api.ensureFuel() end
end
---
--atomic overrides of the turtle api and moves def
moves={}
do
	local s_dirs={
	up={
	vec=function() return Vec3(0,1,0) end,
	at=function(at)
		at.y=at.y+1
	end,
	raw_name="up",
		attack=turtle.attackUp,
		suck=turtle.suckUp,dig=turtle.digUp, raw_move=turtle.up, detect=turtle.detectUp, place=turtle.placeUp,compare=turtle.compareUp, drop=turtle.dropUp,},
	forward={
	vec=function() return Vec3(dir.x,0,dir.z) end,
	at=function(at,dir)
		at.x=at.x+dir.x
		at.z=at.z+dir.z
	end,
	attack=turtle.attack,
	raw_name="forward",suck=turtle.suck, dig=turtle.dig, raw_move=turtle.forward, detect=turtle.detect, place=turtle.place,compare=turtle.compare, drop=turtle.drop,},
	down={
	vec=function() return Vec3(0,-1,0) end,
	at=function(at)
		at.y=at.y-1
	end,
	attack=turtle.attackDown,
	raw_name="down",suck=turtle.suckDown,dig=turtle.digDown, raw_move=turtle.down, detect=turtle.detectDown, place=turtle.placeDown,compare=turtle.compareDown, drop=turtle.dropDown,},
	back={
	vec=function() return Vec3(-dir.x,0,-dir.z) end,
	at=function(at,dir)
		at.x=at.x-dir.x
		at.z=at.z-dir.z
	end,
	raw_name='back',raw_move=turtle.back},
	}
	local t_dirs={
	left={
	vec=function() return Vec3(dir.z,0,-dir.x) end,
	raw_name='turnLeft',raw_move=turtle.turnLeft,at=function(at,dir)  dir.x, dir.z = dir.z, -dir.x end },
	right={
	vec=function() return Vec3(-dir.z,0,dir.x) end,
	raw_name='turnRight',raw_move=turtle.turnRight,at=function(at,dir) dir.x, dir.z = -dir.z, dir.x end},
	}
	local opp={
	up='down',
	forward='back',
	right='left',
	}
	for i,v in pairs(opp) do opp[v]=i end
	
	local function helpMove(doF,moveF,undoF,fuel)
		if fuel then ensureFuel() end
		doF(pos,dir)
		save()
		local r=moveF()
		if not r then undoF(pos,dir) save() end
		return r
	end
	
	for mv,t in pairs(s_dirs) do
		local args={t.at,t.raw_move,s_dirs[opp[mv]].at,true}
		turtle[t.raw_name]=function() return helpMove(unpack(args)) end
		t.move=turtle[t.raw_name]
		moves[mv]=t
	end
	for mv,t in pairs(t_dirs) do
		local args={t.at,t.raw_move,t_dirs[opp[mv]].at}
		turtle[t.raw_name]=function() return helpMove(unpack(args)) end
		t.move=turtle[t.raw_name]
		moves[mv]=t
	end
	
	--aliases
	-- local function tdo(turnF,doF) return function(...) turnF() return doF(...) end end
	
	-- moves.around={}
	-- util.shcopy({
	-- suck=tdo(moves.around,forward.suck),
	-- attack=tdo(moves.around,forward.attack),
	-- drop=tdo(moves.around,forward.drop),
	-- move=function() turtle.turnLeft() turtle.turnLeft() end,
	-- at=function(at,dir) moves.left.at(at,dir) moves.left.at(at,dir) end, 
	-- },moves.around)
	
	
	
	for i,v in pairs(moves) do
		setmetatable(v,
			{__call=function(t,...)
				return v.move(...)
			end,
			})
	end
	moves.top=moves.up
	moves.bottom=moves.down
	moves.front=moves.forward
	
	
	
end
for i,v in pairs(moves) do
	local env=(getfenv())
	env[i]=v
end
---

--world pos related
compass={
	{name='north',n=0,vec=function() return Vec3( 0, 0,-1) end},
	{name='east',n=1,vec=function() return Vec3( 1, 0, 0) end},
	{name='south',n=2,vec=function() return Vec3( 0, 0, 1) end},
	{name='west',n=3,vec=function() return Vec3(-1, 0, 0) end},
	}
for i,v in pairs(compass) do compass[v.name]=v end

--vec, mov, string, or nil
function getFacing(mv)
	local vec
	if mv==nil then vec=dir
	elseif classof(mv)==Vec3 then vec=mv
	elseif type(mv)=='string' then vec=moves[mv].vec()
	else error() end
	for i,c in ipairs(compass) do
		if vec==c.vec() then return c.name end
	end
end
function getChunk(v)
	v=v or pos
  return math.floor(v.x/16), math.floor(v.z/16)
end
function getChunkPosition(v)
	v=v or pos
  return v.x%16, v.z%16
end
---

--[[input patterns:
x,y,z ->vector
string->move or compass
move or compas->vec

drop
suck
place

]]
--arg transformer
local function trf(...) 
	if classof(...)==Vec3 then
		return ...
	elseif type(...)=='string' then 
		if moves[...] then
			return moves[...].vec()
		elseif compass[...] then
			return compass[...].vec()
		end
	else return Vec3(...) end
end
--public api
--mv based
local lastMoveNeededDig=false


function clear(mv)
	mv=type(mv)=='string' and moves[mv] or mv
	local maxCount=mode.count
	local delay=mode.delay
	
	local dig_count=0
	local count=0
	while (mv.detect()) and (count < maxCount) do
		if(count == 0) then
		  -- Am about to dig a block - check that it is not a chest if necessary
		  -- If we are looking for chests, then check that this isn't a chest before moving
			if not mode.dig then
				return false,'dig'
			end
		end
        dig_count = (mv.dig() and 1 or 0)+count
		count=count+1
		sleep(delay)
    end
	if dig_count~=0 then lastMoveNeededDig=true end
	return (count~=maxCount),count,dig_count
end

function force(mv)
	mv=type(mv)=='string' and moves[mv] or mv
	local suc
	if not lastMoveNeededDig then
		suc=mv.move()
		if suc then return true,0,0 end
	end
	local maxCount=mode.count
	local delay=mode.delay
	
	local dig_count=0
	local count=0
	while (not suc) and (count < maxCount) do
		if mv.detect() then
			if(count == 0) then
			  -- Am about to dig a block - check that it is not a chest if necessary
			  -- If we are looking for chests, then check that this isn't a chest before moving
				if not mode.dig then
					return false,'dig'
				end
			end
			dig_count = (mv.dig() and 1 or 0)+count
			sleep(delay)
		else
			if not mode.attack then
				return false,'attack'
			end
			mv.attack()
		end
		suc=mv.move()
		count=count+1
    end
	if dig_count~=0 then lastMoveNeededDig=true end
	return suc,count,dig_count
end

function advance(mv, steps)
	mv=type(mv)=='string' and moves[mv] or mv
	steps = steps or 1
	for step = 1,steps do
		force(mv)
	end
end

--vector based
function turn(...)
	local to=trf(...)
	local x,z = sign(to.x), sign(to.z)
	if x == dir.x and z == dir.z then
		return
	elseif (x == -dir.x and x~=0) or (z == -dir.z and z~=0) then --or?
		left()
		left()
	elseif x ~= 0 then
		if x == -dir.z then right() else left() end
	elseif z ~= 0 then
		if z == dir.x then right() else left() end
	end	
end

function goto(...)
	local to=trf(...)
	if to.y>pos.y then
		advance(up, to.y-pos.y)
	elseif to.y<pos.y then
		advance(down, pos.y-to.y)
	end
	if to.x ~= pos.x then
		turn({x=to.x-pos.x})
		advance(forward, math.abs(to.x-pos.x))
	end 
	if to.z ~= pos.z then
		turn({z=to.z-pos.z})
		advance(forward, math.abs(to.z-pos.z))
	end
end

function move(...)
	local to=trf(...)
	return goto(to+pos)
end
---
function debug()
	return ({lastMoveNeededDig=lastMoveNeededDig,pos_dir={get()}})
end
--init code
local function update()
	load()
	pos,dir=(pos or Vec3()),(dir or compass.south.vec())
	save()
	if mode.gps then
		local ok, pos_,dir_=pcall(getGps)
		if ok then set(pos_,dir_)
		else log('WARNING','Could not use gps:',pos_) end
	end
end

function getGps()
	rednet.open'right'
	local x,y,z=gps.locate(5)
	if x then
		gps_pos=Vec3(x,y,z)
		local org=(get())
		for _,c in ipairs(compass) do
			if goto(c.vec()+org) then
				local x,y,z=gps.locate(5)
				if x then
					local gps_pos2=Vec3(x,y,z)
					local dir=gps_pos2-gps_pos
					if dir~=Vec3(0,0,0) then
						return true,gps_pos2,dir
					end
				end
			end
		end
		error'blocked'
	else
		error'no gps signal'
	end
end
---

update()



api={
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

mode=mode,

getFacing=getFacing,
getChunk=getChunk,
getChunkPos=getChunkPos,
compass=compass,

getGps=getGps,

turn=turn,
move=move,
goto=goto,
}
for i,v in pairs(moves) do api[i]=v end
api.api=api

return api