local peripheral=peripheral
function peripheral.update()
	for _, side in ipairs(rs.getSides()) do
		if peripheral.isPresent(side) then
			peripheral[side]=peripheral.wrap(side)
			sched.signal(peripheral,peripheral[side].getType(),side)
		end
	end
end
sched.sighook({platform='peripheral_detach'