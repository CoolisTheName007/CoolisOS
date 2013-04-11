--Recharger
--log.setLevel('INFO','recharge')
_log=log
log=function(...) return _log('recharge',...) end
args={...}
tmax=args[1] and tonumber(args[1]) or 1800
local Var=require'kernel.class.Var'
var=Var('ect/recharger.var')
local t=require'utils.turtle'
local pdir=t.moves.down
local tdir=t.moves.up
g1=pdir.detect
g2=function() return turtle.getItemCount(1)==1 end
g3=function() return turtle.getItemCount(2)==1 end
select=turtle.select

function out()
	log('INFO','outputing cell')
	select(2)
	repeat
		tdir.drop()
		if not(g3() and g2()) then break else sleep(1) end
	until false
	log('INFO','done')
end
function place()
	log('INFO','placing cell')
	select(1)
	repeat
		pdir.place()
		if (not g2()) and g1() then break else sleep(1) end
	until g1()
	log('INFO','done')
end
function remove()
	log('INFO','removing cell')
	select(2)
	t.clear(pdir)
	log('INFO','done')
end
local BREAK
function main()
sleep(5)
repeat
log('INFO','starting')
if g1() and g2() then
	remove()
end
if g2() and g3() then
	out()
	sleep(5)
end
if g2() and not g3() then
	place()
	var.count=0
end
if g1() and not (g2() and g3())then
	log('INFO','recharging')
	var.count=var.count or 0
	tc=var.count
	ti=os.clock()
	select(1)
	repeat
		var.count=(os.clock()-ti)+tc
		print('now:'..var.count..';max='..tmax)
		sleep(1)
		tdir.suck()
		if g2() or BREAK then break end
	until var.count>tmax
	log('INFO','done')
	remove()
end
if g3() and not(g1() and g2()) then
	log('INFO','waiting for input')
	select(1)
	repeat
		tdir.suck()
		if not g2() then
			sleep(1)
		else
			break
		end
	until false
	log('INFO','done')
end
sleep(1)
log('INFO','done')
until false
end
function control()
	while true do
		ev,id=os.pullEvent()
		if ev=='char' and id=='k' then BREAK= not BREAK end
		if ev=='char' and id=='l' then BREAK= not BREAK sleep(3) BREAK= not BREAK end
	end
end
parallel.waitForAny(control,main)