local string_mt=getfenv(('').len)
local net=string_mt.__net or {}
string_mt.__net=net
net.ids=net.ids or setmetatable({},{__mode='v'})
local ids=net.ids
ids[os.getComputerID()]=_G

net.queueEvent=function(id,...)
	if net.ids[id] then
		ok,err=pcall(net.ids[id].os.queueEvent,...)
		if not ok then
			net.ids[id]=nil
			return
		end
		return true
	end
end
net.queueAll=function(...)
	local t={}
	for id in pairs(net.ids) do
		t[id]=net.queueEvent(id,...)
	end
	return t
end
net.rednet={
send=function(id,msg)
	return net.queueEvent(id,'rednet_message',os.getComputerID(),msg,nil)
end,
broadcast=function(id,msg)
	return net.queueAll('rednet_message',os.getComputerID(),msg,nil)
end,
}

return net