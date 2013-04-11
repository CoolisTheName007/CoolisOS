local classname=require'kernel.class'.classname
custom={}

function conforms(t,a)
    local k=t:sub(1, 1)
	return t == "?"
	or (k == "?" and (a==nil or conforms(t:sub(2, -1),a)))
	or (k == "!" and not (conforms(t:sub(2, -1),a)))
    or type(a)==t
	or classname(a) == t
	or (custom[t] and custom[t](a))
end

function check_one(d,a)
	for t in d:gmatch('|?([^|]+)|?') do
		if conforms(t,a) then return true end
	end
	return false
end
function check(s,...)
    if type(s)~='string' then error('arg1 is not of type string',2) end
	local i=0
	for typ in s:gmatch(',?([^,]+),?') do
		i=i+1
		if not check_one(typ,select(i,...)) then
            local msg=string.format('arg%d:(%s) is not of type (%s)',i,tostring((debug and debug.getinfo or type)((select(i,...)))),typ)
			error(msg,3)
		end
	end
end