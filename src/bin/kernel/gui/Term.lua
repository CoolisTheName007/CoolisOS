include'kernel.class'
local Opt=require'kernel.class.Opt'
local checker=require'kernel.checker'
local check=checker.check
local Point=require'Point'
local Rectangle=require'Rectangle'
-- local function nimpl() return error('Not implemented',3) end
-- class.DC()
-- function DC:blit(pos,section) nimpl() end
-- function DC:setCursorPos(pos,section) nimpl() end
-- function DC:write(txt) nimpl() end
-- function DC:setTextColor(pos,section) nimpl() end
-- function DC:setBackgroundColor(pos,section) nimpl() end

class.Term()
local term_opt=Opt{
size=Opt(Point(5,5)),
bcolor=colors.black,
tcolor=colors.white,
pos=Opt(Point(1,1)),
color=term.isColor(),
blink=false,
}
local function update(self) self:emit(UPDATE) end
checker.custom.color=function(n) return (type(n)=='number' and n>=0 or error('Invalid color, must be number >0',3)) end
local native=util.shcopy(term.native)
checker.custom.native_terminal=function(t)
    for i,v in pairs(native) do
        if type(t[i])~=type(native[i]) then return false end
    end
    if typeof(t)~='table' then return false end
    return true
end
function Term.from_native(term)
    check('native_terminal',term)
	return Term{
        size=Point(term.getSize()),
        color=term.isColor(),
        blink=true,
    }
end

function Term:wrap()
	if self.wrapped==nil then
		local term={}
		for i,v in pairs(native) do
			local f=self[i]
			term[i]=function(...)
				return f(self,...)
			end
		end
		self.wrapped=term
	end
	return self.wrapped
end
--[[process
e.g. shell
in out err
term
---in out in out
]]
local active={
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
function Term:setSignals(bool)
	for _,k in ipairs(active) do
		local f=self['_'..k] or self[k]
		self[k]=bool and function(...)
			if not self._calm then sched.signal(self,k,...) self._calm=true end
			return f(...)
		end or f
	end
end
function Term:__init(opt)
	term_opt:drop(self,opt)
	self:_allocate()
end
function Term:setCursorPos(x,y) self.pos:assign(x,y) end
function Term:getCursorPos() return self.pos.x,self.pos.y end
function Term:setBackgroundColor(color) check('color',color) self.bcolor=color end
Term.setBackgroundColour=Term.setBackgroundColor
function Term:getBackgroundColor() return self.bcolor end
Term.getBackgroundColour=Term.getBackgroundColor
function Term:setTextColor(color) check('color',color) self.tcolor=color end
Term.setTextColour=Term.setTextColor
function Term:getTextColor() return self.tcolor end
Term.getTextColour=Term.getTextColor
function Term:isColor() return self.color end
Term.isColour=Term.isColor
function Term:setCursorBlink(bool) check('boolean',bool) self.blink=bool end
function Term:getCursorBlink() return self.blink end
function Term:write(txt)
	check('string',txt)
	local n=#txt
	local pos=self.pos
	if pos.x+n<=1 or pos.x> self.size.x then
		pos.x=pos.x+n
		return
    end
	if pos.x < 1 then
		txt=txt:sub(math.abs(pos.x)+2)
		pos.x=1
	end
	local line=self.matrix[pos.y]
	if line then
		for j=pos.x,math.min(pos.x-1+n,self.size.x) do
			line[j]={tc=self.tcolor,bc=self.bcolor,c=txt:sub(j-pos.x+1,j-pos.x+1)}
		end
	end
    pos.x=pos.x+n
end
function Term:setSize(self,size)
	self.size=size
	self:_allocate()
end
function Term:getSize()
	return self.size.x,self.size.y
end

function Term:scroll(n)
	check('number',n)
	n=(n-n%1)
	local ind,nind=n>0 and 1 or nil,n>0 and self.size.y or 1
	local matrix=self.matrix
	for i=1,math.abs(n) do
		table.remove(matrix,ind)
        matrix[nind]=self:_newLine()
	end
end
function Term:clear() self:_allocate() end
function Term:clearLine()
	if self.matrix[self.pos.y] then
		self.matrix[self.pos.y]=self:_newLine()
	end
end
function Term:_newLine()
	local line={}
	for j=1,self.size.x do
		line[j]={tc=self.tcolor,bc=self.bcolor,c=' '}
	end
	return line
end
function Term:_allocate()
	local X,Y = self.size.x,self.size.y
	self.matrix=self.matrix or {}
	for i=1,Y do
		self.matrix[i]=self:_newLine()
	end
end
local def_pos=Point(1,1)
function Term:blit_native(term,pos,section)
	pos=pos or def_pos
	section=section or Rectangle(pos,self.size)
    term.setCursorBlink(false)
    if self.blink then
        local cell=self.matrix[self.pos.y] and self.matrix[self.pos.y][self.pos.x]
        if cell then
            self._bcell=cell
            cell.bc,cell.tc=cell.tc,cell.bc
        else
            self._bcell=nil
        end
    end
    
	for i=section.s.y,section.e.y do
		local line=self.matrix[i]
		local tc,bc=line[1].tc,line[1].bc
		local tTxt={}
		for j=section.s.x,section.e.x do
			local tl,bl=line[j].tc,line[j].bc
			if tc~=tl or bc~=bl then
				term.setCursorPos(j-#tTxt+pos.x-1,i+pos.y-1)
				term.setTextColor(tc==0 and self.tcolor or tc)
				term.setBackgroundColor(bc==0 and self.bcolor or bc)
				term.write(table.concat(tTxt))
				tc,bc=tl,bl
				tTxt={}
			end
			table.insert(tTxt,line[j].c)
		end
		if tTxt[1] then
			term.setCursorPos(section.e.x-#tTxt+1,i)
			term.setTextColor(tc==0 and self.tcolor or tc)
			term.setBackgroundColor(bc==0 and self.bcolor or bc)
			term.write(table.concat(tTxt))
		end
	end
    if self._bcell then
        local cell=self._bcell
        cell.bc,cell.tc=cell.tc,cell.bc
        self._bcell=nil
    end
end
function Term:setPixel(char,tcolor,bcolor,x,y)
	check('string,?|color,?|color,?|Point|number|table,?|number')
	if type(x)=='table' then
		x,y=x.x,x.y
		check('number,number',x,y)
	else
		x,y=x or self.pos.x, y or self.pos.y 
	end
	if self.matrix[y] and self.matrix[y][x] then
		self.matrix[y][x]={c=char or ' ',tc=tcolor or self.tcolor,bc=bcolor or self.bcolor}
	end
end
function Term:copyState(term)
	term=classof(term)==Term and term:wrap() or term
	term.setTextColor(self:getTextColor())
	term.setBackgroundColor(self:getBackgroundColor())
	term.setCursorPos(self:getCursorPos())
end

-- function Term:from_npaint(file)
	-- -- pos=pos or def_pos
	-- -- section=section or Rectangle(pos,self.size)
	
	-- for line in file:lines() do
		-- if section.x<
	-- end
-- end

function Term:_dump_key(k)
  local s={}
  for i=1, self.size.y do
    local txt={}
    table.foreach(self.matrix[i],function(_,v) table.insert(txt,tostring(type(v[k])=='number' and string.char(97+math.ceil(math.log(v[k],2))) or v[k])) end)
    txt=table.concat(txt)
    table.insert(s,txt)
  end
  return table.concat(s,'\n')
end
function Term:dump()
  return self:_dump_key'c',self:_dump_key'tc',self:_dump_key'bc'
end
function Term:blit_all(term)
	for i=1,self.size.y do
		local line=self.matrix[i]
		for j=1,self.size.x do
			local p=line[j]
			term.setCursorPos(j,i)
			term.setTextColor(p.tc)
			term.setBackgroundColor(p.bc)
			term.write(p.c)
		end
	end
end
-- assert(Term:implements(DC))
Term.test=function()
  rawset(_G,'t',Term{size=Point(term.getSize())})
  for i=1,t.size.y do
    t:setPixel('a',2^i,2^i,i,i)
  end
  sleep(1)
  term.clear()
--  t:setCursorPos(2,2)
  t:blit_native(term)
  sleep(1)
end


return Term