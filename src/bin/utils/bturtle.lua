if not _G.turtle then return end

local Vec3=require'utils.Vec3'
include'kernel.class'
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
local util=require'kernel.util'
local saveDir=fs.combine(_INSTALL_PATH,'ect/turtle')
local dump=require'utils.serpent'.dump
local saveFile=fs.combine(saveDir,'pos-dir')

local pos,dir

local function save()
   util.with(fs.open(saveFile,'w'),function(f)
       f.write(dump{pos,dir})
   end)
end
function load()
   local p,d
   util.with(fs.open(saveFile,'r'),function(f)
      p,d=unpack(loadstring(f.readAll()))
   end)
   return p,d
end
function set(_pos,_dir)
	pos,dir=_pos,_dir
	save()
end

function sign(num)
	return (not num or num==0) and 0 or num>0 and 1 or -1
end 

local dirs={
up={name="up", suck=turtle.suckUp,dig=turtle.digUp, move=turtle.up, detect=turtle.detectUp, place=turtle.placeUp,compare=turtle.compareUp, drop=turtle.dropUp,},
forward={name="forward",suck=turtle.suck, dig=turtle.dig, move=turtle.forward, detect=turtle.detect, place=turtle.place,compare=turtle.compare, drop=turtle.drop,},
down={name="down",suck=turtle.suckDown,dig=turtle.digDown, move=turtle.down, detect=turtle.detectDown, place=turtle.placeDown,compare=turtle.compareDown, drop=turtle.dropDown,},
back={name='back',move=turtle.back},
}

for dir,t in pairs(dirs) do
  getfenv(dir)=t
end
forward.at =  function()
	at.x=at.x+d.x
	at.z=at.z+d.z
end

up.at = function()
	at.y=at.y+1
end
 
down.at = function()
	at.y=at.y-1
end
 
back.at=function()
  at.x=at.x-d.x
	at.z=at.z-d.z
end

function left()
		turtle.turnLeft()
		dir.x, dir.z = -dir.z, dir.x
		save()
end
 
function right()
		turtle.turnRight()
		d.x, d.z = d.z, -d.x
		pervar.update(Namespace, "d", d )
end

function turn(to)
	local x,z = sign(to.x), sign(to.z)
	if x == d.x and z == d.z then
		return
	elseif (x == -d.x and x~=0) or (z == -d.z and z~=0) then --or?
		left()
		left()
	elseif z ~= 0 then
		if z == -d.x then right() else left() end
	elseif x ~= 0 then
		if x == d.z then right() else left() end
	end	
end

function move(dir)
	if dir.move() then
		dir.at()
		save()
		return true
	else
		return false
	end
end
 
function dig(dir)
	return dir.dig()
end
local lastMoveNeededDig=false
function forceMove(dir, maxDigCount,onDig)
  maxDigCount=maxDigCount or 30
    local moveSuccess = false
 
    -- Flag to determine whether digging has been tried yet. If it has
    -- then pause briefly before digging again to allow sand or gravel to
    -- drop
    local digCount = 0

    if (lastMoveNeededDig == false) then
      -- Didn't need to dig last time the turtle moved, so try moving first

      moveSuccess = move(dir)

      -- Don't need to set the last move needed dig. It is already false, if 
      -- move success is now true, then it won't be changed
    else
      onDig(dir)

 
      -- Try to dig (without doing a detect as it is quicker)
      local digSuccess = digFn()
      if (digSuccess == true) then
        digCount = 1
      end

      moveSuccess = move(dir)

      if (moveSuccess == true) then
        lastMoveNeededDig = digSuccess
      end

    end
 
    -- Loop until we've successfully moved
    if (moveSuccess == false) then
      while ((moveSuccess == false) and (digCount < maxDigCount)) do
 
        -- If there is a block in front, dig it
        if (dir.detect() == true) then
       
            -- If we've already tried digging, then pause before digging again to let
            -- any sand or gravel drop, otherwise check for a chest before digging
            if(digCount == 0) then
              -- Am about to dig a block - check that it is not a chest if necessary
              -- If we are looking for chests, then check that this isn't a chest before moving
              onDig(dir)
            else
              sleep(0.1)
            end
 
            dig(dir)
            digCount = digCount + 1
        else
           -- Am being stopped from moving by a mob, attack it
           dir.attack()
        end

        -- Try the move again
        moveSuccess = move(dir)
      end

      if (digCount == 0) then
        lastMoveNeededDig = false
      else
        lastMoveNeededDig = true
      end
    end

  -- Return the move success
  return moveSuccess
end

function advance(dir, steps,...)
	steps = steps or 1
	for step = 1,steps do
		forceMove(dir, ....)
	end
end

function goto(to)
	if to.y>at.y then
		advance(up, to.y-at.y)
	elseif to.y<at.y then
		advance(down, at.y-to.y)
	end
	if to.x ~= at.x then
		turn({x=to.x-at.x})
		advance(forward, math.abs(to.x-at.x))
	end 
	if to.z ~= at.z then
		turn({z=to.z-at.z})
		advance(forward, math.abs(to.z-at.z))
	end
end
