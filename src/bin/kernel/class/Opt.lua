class.Opt()
function Opt:__init(t,typ)
	self.typ=typ or (typeof(t)=='object' and 'clone' or typeof(t))
	self.val=t
end
function Opt:drop(dst,src)
  local typ=self.typ
	if typ=='raw' then return self.val
	elseif typ=='clone' then return self.val:clone()
	elseif typ=='table' then
		dst=dst or {}
		src=src or {}
		for i,v in pairs(self.val) do
			if ofType(v)==Opt then
				dst[i]=v:drop(nil,src[i])
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