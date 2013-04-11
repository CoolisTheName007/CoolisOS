rednet.open'right'

function slave()
	local t={
	1=true
	}
	local send=function(id,n) turtle.select(id) turtle.drop(n) end
	while true do
		local _id,msg=rednet.receive()
		local id,n=msg:match'([^:]):([^:])'
		if id and n then
			n=tonumber(n)
			send(id,n)
		end
	end
end

function master()

delay=5
function _request(id,n)
	repeat
		rednet.broadcast(id..':'..n)
		t=0
		repeat
			if turtle.getItemCount(1)==n then break end
			sleep(dt)
			t=t+dt
		until t>delay
	until turtle.getItemCount(1)==n
	turtle.drop()
end


function request(id,n)
	local r=n%64
	local q=(n-r)/64
	for i=1,q do _request(id,64) end
	_request(id,r)
end

end