local n=math.max
local a=math.abs
function winding(o)
local e,t=o[1],o[2]
local a,i=a(e),a(t)
local a=n(a,i)
if e==a and i~=a then
return{e,t+1}
elseif t==a and e~=-a then
return{e-1,t}
elseif e==-a and t~=-a then
return{e,t-1}
elseif t==-a then
return{e+1,t}
elseif t==-a and e==a then
return{e+1,t}
else print(o[1],o[2])_error'not a valid state'end
end
return winding
