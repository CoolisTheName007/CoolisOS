local ofType=require'kernel.class'.ofType
custom={}

function conforms(t,a)
	return t == "?"
	or (t:sub(1, 1) == "?" and (a==nil or conforms(t:sub(2, -1),a)))
	or ofType(a) == t
	or (custom[t] and custom[t](a))
end

function check_one(d,a)
	for t in d:gmatch('|?([^|]*)|?') do
		if conforms(t,a) then return true end
	end
	return false
end
function check(s,...)
	local i=0
	for typ in s:gmatch(',?([^,]*),?') do
		i=i+1
		if not check_one(typ,select(i,...)) then
			error('arg number '..i..':'..tostring(select(i+1,...),nil)..'of type '..tostring(type(select(i+1,...)))..' is not of type '..typ,3)
		end
	end
end