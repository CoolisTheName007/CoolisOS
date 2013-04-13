include'kernel.class'
local e=require'kernel.class.Opt'
local o=require'kernel.checker'
local a=o.check
local s=require'Point'
local h=require'Rectangle'
class.Term()
local i=e{
size=e(s(5,5)),
bcolor=colors.black,
tcolor=colors.white,
pos=e(s(1,1)),
color=term.isColor(),
blink=false,
}
local function e(e)e:emit(UPDATE)end
o.custom.color=function(e)return(type(e)=='number'and e>=0 or error('Invalid color, must be number >0',3))end
local e=util.shcopy(term.native)
o.custom.native_terminal=function(a)
for t,o in pairs(e)do
if type(a[t])~=type(e[t])then return false end
end
if typeof(a)~='table'then return false end
return true
end
function Term.from_native(e)
a('native_terminal',e)
return Term{
size=s(e.getSize()),
color=e.isColor(),
blink=true,
}
end
function Term:wrap()
if self.wrapped==nil then
local t={}
for e,a in pairs(e)do
local a=self[e]
t[e]=function(...)
return a(self,...)
end
end
self.wrapped=t
end
return self.wrapped
end
local e={
'setBackgoundColour',
'setTextColour',
'setCursorPos',
'setCursorBlink',
'write',
'setSize',
'scroll',
'clear',
'setPixel',
}
function Term:setSignals(a)
for t,e in ipairs(e)do
local t=self['_'..e]or self[e]
self[e]=a and function(...)
if not self._calm then sched.signal(self,e,...)self._calm=true end
return t(...)
end or t
end
end
function Term:__init(e)
i:drop(self,e)
self:_allocate()
end
function Term:setCursorPos(e,t)self.pos:assign(e,t)end
function Term:getCursorPos()return self.pos.x,self.pos.y end
function Term:setBackgroundColor(e)a('color',e)self.bcolor=e end
Term.setBackgroundColour=Term.setBackgroundColor
function Term:getBackgroundColor()return self.bcolor end
Term.getBackgroundColour=Term.getBackgroundColor
function Term:setTextColor(e)a('color',e)self.tcolor=e end
Term.setTextColour=Term.setTextColor
function Term:getTextColor()return self.tcolor end
Term.getTextColour=Term.getTextColor
function Term:isColor()return self.color end
Term.isColour=Term.isColor
function Term:setCursorBlink(e)a('boolean',e)self.blink=e end
function Term:getCursorBlink()return self.blink end
function Term:write(t)
a('string',t)
local a=#t
local e=self.pos
if e.x+a<=1 or e.x>self.size.x then
e.x=e.x+a
return
end
if e.x<1 then
t=t:sub(math.abs(e.x)+2)
e.x=1
end
local o=self.matrix[e.y]
if o then
for a=e.x,math.min(e.x-1+a,self.size.x)do
o[a]={tc=self.tcolor,bc=self.bcolor,c=t:sub(a-e.x+1,a-e.x+1)}
end
end
e.x=e.x+a
end
function Term:setSize(e,t)
e.size=t
e:_allocate()
end
function Term:getSize()
return self.size.x,self.size.y
end
function Term:scroll(e)
a('number',e)
e=(e-e%1)
local o,a=e>0 and 1 or nil,e>0 and self.size.y or 1
local t=self.matrix
for e=1,math.abs(e)do
table.remove(t,o)
t[a]=self:_newLine()
end
end
function Term:clear()self:_allocate()end
function Term:clearLine()
if self.matrix[self.pos.y]then
self.matrix[self.pos.y]=self:_newLine()
end
end
function Term:_newLine()
local e={}
for t=1,self.size.x do
e[t]={tc=self.tcolor,bc=self.bcolor,c=' '}
end
return e
end
function Term:_allocate()
local t,e=self.size.x,self.size.y
self.matrix=self.matrix or{}
for e=1,e do
self.matrix[e]=self:_newLine()
end
end
local o=s(1,1)
function Term:blit_native(e,n,a)
n=n or o
a=a or h(n,self.size)
e.setCursorBlink(false)
if self.blink then
local e=self.matrix[self.pos.y]and self.matrix[self.pos.y][self.pos.x]
if e then
self._bcell=e
e.bc,e.tc=e.tc,e.bc
else
self._bcell=nil
end
end
for h=a.s.y,a.e.y do
local s=self.matrix[h]
local i,o=s[1].tc,s[1].bc
local t={}
for a=a.s.x,a.e.x do
local d,r=s[a].tc,s[a].bc
if i~=d or o~=r then
e.setCursorPos(a-#t+n.x-1,h+n.y-1)
e.setTextColor(i==0 and self.tcolor or i)
e.setBackgroundColor(o==0 and self.bcolor or o)
e.write(table.concat(t))
i,o=d,r
t={}
end
table.insert(t,s[a].c)
end
if t[1]then
e.setCursorPos(a.e.x-#t+1,h)
e.setTextColor(i==0 and self.tcolor or i)
e.setBackgroundColor(o==0 and self.bcolor or o)
e.write(table.concat(t))
end
end
if self._bcell then
local e=self._bcell
e.bc,e.tc=e.tc,e.bc
self._bcell=nil
end
end
function Term:setPixel(n,i,o,e,t)
a('string,?|color,?|color,?|Point|number|table,?|number')
if type(e)=='table'then
e,t=e.x,e.y
a('number,number',e,t)
else
e,t=e or self.pos.x,t or self.pos.y
end
if self.matrix[t]and self.matrix[t][e]then
self.matrix[t][e]={c=n or' ',tc=i or self.tcolor,bc=o or self.bcolor}
end
end
function Term:copyState(e)
e=classof(e)==Term and e:wrap()or e
e.setTextColor(self:getTextColor())
e.setBackgroundColor(self:getBackgroundColor())
e.setCursorPos(self:getCursorPos())
end
function Term:_dump_key(t)
local o={}
for a=1,self.size.y do
local e={}
table.foreach(self.matrix[a],function(o,a)table.insert(e,tostring(type(a[t])=='number'and string.char(97+math.ceil(math.log(a[t],2)))or a[t]))end)
e=table.concat(e)
table.insert(o,e)
end
return table.concat(o,'\n')
end
function Term:dump()
return self:_dump_key'c',self:_dump_key'tc',self:_dump_key'bc'
end
function Term:blit_all(e)
for a=1,self.size.y do
local t=self.matrix[a]
for o=1,self.size.x do
local t=t[o]
e.setCursorPos(o,a)
e.setTextColor(t.tc)
e.setBackgroundColor(t.bc)
e.write(t.c)
end
end
end
Term.test=function()
rawset(_G,'t',Term{size=s(term.getSize())})
for e=1,t.size.y do
t:setPixel('a',2^e,2^e,e,e)
end
sleep(1)
term.clear()
t:blit_native(term)
sleep(1)
end
return Term