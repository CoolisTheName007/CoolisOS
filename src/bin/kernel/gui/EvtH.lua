class.EvtH()
do
function EvtH:__init()

end

function EvtH:destroy()

end
function EvtH:queue()
	
end
wxEvtHandler::Connect
function EvtH:connect(src,event,f,...)
	local cast=src.EvtH
	local t=cast.dst[event] or setmetatable({},{__mode='k'})
	cast.dst[event][self]=true
	
	t=self.handlers[event] or {}
	self.handlers[event]=t
	t[f]={...}
end

wxEvtHandler::Disconnect
function EvtH:disconnect(src,event,f,this)
	srcs=src and {src=true} or self.src
	for src in pairs(srcs) do
		events=event and {event=src[event]} or src.dst
		for event,evth in pairs(events) do
			fs=f and {f}
		end
	end
end
wxEvtHandler::GetClientData
function EvtH:()

end
wxEvtHandler::GetClientObject
function EvtH:()

end
wxEvtHandler::GetEvtHandlerEnabled
function EvtH:isEnabled()

end
wxEvtHandler::GetNextHandler
function EvtH:next()

end
wxEvtHandler::GetPreviousHandler
function EvtH:previous()

end
wxEvtHandler::ProcessEvent
function EvtH:process()

end
wxEvtHandler::SearchEventTable
function EvtH:search()

end
wxEvtHandler::SetClientData
function EvtH:()

end
wxEvtHandler::SetClientObject
function EvtH:()

end
function EvtH:setEnabled()

end
function EvtH:setNext()

end
function EvtH:setPrevious()

end
end