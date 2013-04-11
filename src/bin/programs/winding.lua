local max=math.max
local abs=math.abs

function winding(p)
	local x,y=p[1],p[2]
	local ax,ay=abs(x),abs(y)
	local d=max(ax,ay)
	
	if x==d and ay~=d then
		return {x,y+1}
	elseif y==d and x~=-d then
		return {x-1,y}
	elseif x==-d and y~=-d then
		return {x,y-1}
	elseif y==-d then
		return {x+1,y}
	elseif y==-d and x==d then
		return {x+1,y}
	else print(p[1],p[2]) _error'not a valid state' end
end

return winding

