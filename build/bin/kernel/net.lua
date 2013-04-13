local t=getfenv(('').len)
local e=t.__net or{}
t.__net=e
e.ids=e.ids or setmetatable({},{__mode='v'})
local a=e.ids
local t=os.getComputerID()
a[t]=_G
e.queueEvent=function(t,...)
if e.ids[t]then
ok,err=pcall(e.ids[t].os.queueEvent,...)
if not ok then
e.ids[t]=nil
return
end
return true
end
end
e.queueAll=function(...)
local a={}
for t in pairs(e.ids)do
a[t]=e.queueEvent(t,...)
end
return a
end
e.rednet={
send=function(a,t)
return e.queueEvent(a,'rednet_message',os.getComputerID(),t,nil)
end,
broadcast=function(a,t)
return e.queueAll('rednet_message',os.getComputerID(),t,nil)
end,
}
return e