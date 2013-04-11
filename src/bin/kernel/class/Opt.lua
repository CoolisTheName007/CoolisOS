class.Opt()
function Opt:__init(t,typ,...)
	self.typ=typ or (typeof(t))
	self.val=t
    self.args={...}
end
function Opt:drop(dst,src,name)
    log('Opt','INFO','%s','\n'..pstring{dst,src,name})
    local typ=self.typ
	if typ=='req' then
		if src==nil then error(string.format('parameter %s required',tostring(name)))
		else return src end
	elseif typ=='function' then return self.val(unpack(self.args))
	elseif typ=='raw' then
        if src==nil then return self.val else return src end
	elseif typ=='object' then return src==nil and (self.val.clone and self.val:clone() or self.val.__class(self.val)) or src
	elseif typ=='class' then return self.val(unpack(self.args))
	elseif typ=='table' then
		dst=dst or {}
		src=src or {}
		for i,v in pairs(self.val) do
			if classof(v)==Opt then
				dst[i]=v:drop(nil,src[i],i)
			else
				if src[i]~=nil then
					v=src[i]
				end
				dst[i]=v
			end
		end
		return dst
	end	
end
return Opt