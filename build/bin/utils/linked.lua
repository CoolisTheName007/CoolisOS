include'kernel.class'
local e=pairs
local i=print
class.Linked()
function Linked:__init(e)
self.r,self.l={[0]=-1},{[-1]=0}
if e then self:append_r(e)end
end
function Linked._insert(e,t,o,a)
if e.r[t]then return end
o,a=o or 0,a or-1
e.r[o],e.l[t],e.r[t],e.l[a]
=t,o,a,t
end
function Linked.insert_l(t,a,e)
return Linked._insert(t,a,e,t.r[e or 0])
end
function Linked.insert_r(t,a,e)
return Linked._insert(t,a,t.l[e or-1],e)
end
function Linked.remove(t,e)
e=e or t.r[0]
if t.r[e]then t.r[t.l[e]],t.l[t.r[e]],t.r[e],t.l[e]=t.r[e],t.l[e],nil,nil end
if e==-1 then e=nil end
return e,t.r[e]
end
function Linked.next_r(t,e)
local e=t.r[e or 0]
if e~=-1 then return e end
end
function Linked.next_l(e,t)
local e=e.r[t or-1]
if e~=0 then return e end
end
function Linked.__tostring(e)
s={}
for e in self.next_r,e,nil do
table.insert(s,tostring(e))
end
return'Linked instance:'..table.concat(s,'<>')
end
function Linked:append_r(t)
local e
for a,t in ipairs(t)do
self:insert_r(t,e)
e=t
end
end
function Linked:has(e)
return self.r[e]~=nil
end
function Linked:isempty()
return self.r[0]==-1
end
Linked.append=Linked.append_r
Linked.push=Linked.insert_r
Linked.pop=Linked.remove
function Linked.test()
t={'a',3,4}
l=Linked(t)
i(l)
l:remove(3)
i(l)
i(l:has(4),l:has(3))
return l
end
return Linked