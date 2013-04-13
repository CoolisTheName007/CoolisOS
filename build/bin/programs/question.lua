local r=loadfile'CoolisOS/dev/questions'()
local e=rs.setOutput
local t=function(...)return e('back',...)end
local a=function(...)return e('bottom',...)end
for a,t in pairs(rs.getSides())do
e(t,false)
end
local h=function()
reset_term()
print'Right Answer! Pass throught the door!'
t(true)
sleep(2)
t(false)
end
local function o(t,e)
t(true)
sleep(e)
t(false)
sleep(e)
end
local s=function()
reset_term()
print'Wrong answer! Burn in hell!'
local e=os.clock()
while(os.clock()-e)<20 do
o(a,1)
end
end
function reset_term()
term.clear()
term.setCursorPos(1,1)
end
function copy(t)
local e={}
for t,a in pairs(t)do
e[t]=a
end
return e
end
local n
do
local o
o=function(e,t,i)
if t==0 then
i(e)
else
for a=1,t do
e[t],e[a]=e[a],e[t]
o(e,t-1,i)
e[t],e[a]=e[a],e[t]
end
end
end
function permute_iter(e)
local t=#e
local e=coroutine.create(function()o(e,t,coroutine.yield)end)
return function()
local t,e=coroutine.resume(e)
return e
end
end
local function t(e)
if e==0 then return 1 end
return e*t(e-1)
end
function n(e)
local t=math.random()*(t(#e))
local e=permute_iter(e)
for t=1,t-1 do e()end
local e=e()
return e
end
end
function test()
for e,t in pairs(r)do
reset_term()
print(t[1])
if type(t[2])=='string'then
print'Type answer.'
if t[2]~=read()then
return false
end
else
local a=n(copy(t[2]))
for e,t in pairs(a)do
print(e..')'..t)
end
print'Press the number key matching the right answer'
local e,o,i
repeat
local t={os.pullEvent()}
o,e=t[1],t[2]
i,e=pcall(tonumber,e)
until(o=='char'and type(e)=='number'and 1<=e and e<=#a)
if a[e]~=t[2][1]then
return false
end
end
end
return true
end
os.pullEvent=os.pullEventRaw
s()
repeat
if test()then
h()
else
s()
end
until false