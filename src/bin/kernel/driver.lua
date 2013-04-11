local driver={}

local peripheral=peripheral
function driver.update()
	for _, side in ipairs(rs.getSides()) do
		if peripheral.isPresent(side) then
			driver[side]=peripheral.wrap(side)
			-- sched.signal(peripheral,peripheral[side].getType(),side)
		else
			driver[side]=nil
		end
	end
end

return driver