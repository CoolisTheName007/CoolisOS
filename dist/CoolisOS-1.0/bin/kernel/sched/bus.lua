local e={}
local function i(a,t)
if not e[t]then
e[t]={}
end
e[t][a]=true
end
local function t(a,t)
if e[t]then
e[t][a]=nil
end
end
function run_event(a)
if e[a]then
local o,t={},0
for e in pairs(e[a])do
table.insert(o,e)
t=t+1
end
for e=1,t do
o[e]:handle(a)
end
end
end
local e={}
function publish(t)
table.insert(t,e)
end
function run()
while true do
local e=table.remove(e,1)
if not e then break end
run_event(e)
end
end
e={'start'}
newObj={handle=function(t,e)print('I has event:'..tostring(e))end}
i(newObj,'start')
run()