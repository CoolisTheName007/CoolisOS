local e={}
local a=peripheral
function e.update()
for o,t in ipairs(rs.getSides())do
if a.isPresent(t)then
e[t]=a.wrap(t)
else
e[t]=nil
end
end
end
return e