--CoolisOS/dev/question.lua

local questions=loadfile'CoolisOS/dev/questions'()

local set=rs.setOutput
local setDoor=function(...) return set('back',...) end
local setFire=function(...) return set('bottom',...) end
for i,v in pairs(rs.getSides()) do
	set(v,false)
end

local right=function()
	reset_term()
	print'Right Answer! Pass throught the door!'
	setDoor(true)
	sleep(2)
	setDoor(false)
end
local function pulse(f,delay)
	f(true)
	sleep(delay)
	f(false)
	sleep(delay)
end

local wrong=function()
	reset_term()
	print'Wrong answer! Burn in hell!'
	local t=os.clock()
	while (os.clock()-t)<20 do
		pulse(setFire,1)
	end
end

function reset_term()
	term.clear()
	term.setCursorPos(1,1)
end

function copy(t)
	local c={}
	for i,v in pairs(t) do
		c[i]=v
	end
	return c
end

local get_permut
do
local permgen
permgen = function (a, n, fn)
if n == 0 then
fn(a)
else
for i=1,n do
-- put i-th element as the last one
a[n], a[i] = a[i], a[n]
 
-- generate all permutations of the other elements
permgen(a, n - 1, fn)
 
-- restore i-th element
a[n], a[i] = a[i], a[n]
 
end
end
end
 
--- an iterator over all permutations of the elements of a list.
-- Please note that the same list is returned each time, so do not keep references!
-- @param a list-like table
-- @return an iterator which provides the next permutation as a list
function permute_iter (a)
local n = #a
local co = coroutine.create(function () permgen(a, n, coroutine.yield) end)
return function ()   -- iterator
local code, res = coroutine.resume(co)
return res
end
end

local function factorial(n)
	if n==0 then return 1 end
	return n*factorial(n-1)
end

function get_permut(t)
	local n=math.random()*(factorial(#t))
	local iter=permute_iter(t)
	for i=1,n-1 do iter() end
	local perm=iter()
	return perm
end
end

function test()
	for i,question in pairs(questions) do
		reset_term()
		print(question[1])
		if type(question[2])=='string' then
			print'Type answer.'
			if question[2]~=read() then
				return false																																				
			end
		else
			local permut=get_permut(copy(question[2]))
			for i,answer in pairs(permut) do
				print(i..')'..answer)
			end
			print'Press the number key matching the right answer'
			local id,ev,ok
			repeat
				local t={os.pullEvent()}
				ev,id=t[1],t[2]
				ok,id=pcall(tonumber,id)
			until (ev=='char' and type(id)=='number' and 1<=id and id<=#permut)
			if permut[id]~=question[2][1] then
				return false
			end
		end
	end
	return true
end

os.pullEvent=os.pullEventRaw
wrong()
repeat
	if test() then
		right()
	else
		wrong()
	end
until false