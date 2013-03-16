include'kernel.class'
local checker=require'kernel.checker'
local check=checker.check
local function property(class, attribute,field,setter,getter)
	class['set'..attribute]=setter or function(self,val) self[field]=val end
	class['get'..attribute]=getter or function(self) return self[field] end
end



--[[ Rect metatable -------------------------------------------------------
Members
    Point.x    -- number
    Point.y    -- number
Methods
    Point:Point(x, y)
    Point:Point(point)
    Point:assign(x, y)
    Point:assign(point)
    Point:clone()          -- return Point
    Point:add(x, y)
    Point:add(point)
    Point:sub(x, y)
    Point:sub(point)
    Point:equal(point)
--------------------------------------------------------------------------]]
class.Point()
do
function Point:__init(x, y)
    self:assign(x, y)
end

function Point:assign(x, y)
    if (not y) then
        self.x = x.x
        self.y = x.y
    else
        self.x = x
        self.y = y
    end
    return self
end

function Point:clone()
    return Point(self)
end

function Point:add(x, y)
    if (not y) then
        self.x = self.x + x.x
        self.y = self.y + x.y
    else
        self.x = self.x + x
        self.y = self.y + y
    end
    return self
end

function Point:sub(x, y)
    if (not y) then
        return self:add(-x.x, -x.y)
    else
        return self:add(-x, -y)
    end
end

function Point:equal(p)
    return self.x == p.x and self.y == p.y
end
function Point:__tostring()
    return '(' .. self.x .. ',' .. self.y ..')'
end
end
--[[ Rect metatable -------------------------------------------------------
Members:
    Rectangle.s -- Point (start)
    Rectangle.e -- Point (end)
Methods:
    Rectangle:assign(x1, y1, x2, y2)
    Rectangle:assign(rect)
    Rectangle:size()    -- return Point
    Rectangle:clone()   -- return Rectangle
    Rectangle:move(deltax, deltay)
    Rectangle:grow(deltax, deltay)
    Rectangle:intersect(rect)
    Rectangle:union(rect)
    Rectangle:equal(rect)
    Rectangle:contains(point)
    Rectangle:empty()
    Rectangle:nempty()
--------------------------------------------------------------------------]]
class.Rectangle()
do
function Rectangle:__init(x1, y1, x2, y2)
    self:assign(x1, y1, x2, y2)
end

function Rectangle:assign(x1, y1, x2, y2)
    if (not y1) then
        self.s = x1.s:clone()
        self.e = x1.e:clone()
    else
        self.s = Point:new(x1, y1)
        self.e = Point:new(x2, y2)
    end
    return self
end

function Rectangle:size()
    return self.e:clone():sub(self.s)
end

function Rectangle:clone()
    return Rectangle:new(self)
end

function Rectangle:move(deltax, deltay)
    self.s:add(deltax, deltay)
    self.e:add(deltax, deltay)
    return self
end

function Rectangle:grow(deltax, deltay)
    self.s:sub(deltax, deltay)
    self.e:add(deltax, deltay)
    return self
end

function Rectangle:intersect(r)
    local s, e = self.s, self.e

    s.x = max(s.x, r.s.x)
    s.y = max(s.y, r.s.y)
    e.x = min(e.x, r.e.x)
    e.y = min(e.y, r.e.y)
    return self
end

function Rectangle:union(r)
    local s, e = self.s, self.e

    s.x = min(s.x, r.s.x)
    s.y = min(s.y, r.s.y)
    e.x = max(e.x, r.e.x)
    e.y = max(e.y, r.e.y)
    return self
end

function Rectangle:equal(r)
    return self.s:equal(r.s) and self.e:equal(r.e)
end

function Rectangle:contains(x, y)
    return x >= self.s.x and x < self.e.x and y >= self.s.y and y < self.e.y
end

function Rectangle:empty()
    return self.s.x >= self.e.x or self.s.y >= self.e.y
end

function Rectangle:nempty()
    return not self:empty()
end


function Rectangle:__tostring()
    if (self:empty()) then
        return 'rect (empty)'
    else
        return 'rect (' .. self.s:tostring() .. ',' .. self.e:tostring() .. ')'
    end
end

end
--[[ test Rectangle ----------------------------------------------------------]]

class.Opt()
do
function Opt:__init(t,typ)
	self.typ=typ or (typeof(t)=='object' and 'clone' or typeof(t))
	self.val=t
end
function Opt:drop(dst,src)
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
end

local function nimpl() return error('Not implemented',3) end

class.DC()
function DC:blit(pos,section) nimpl() end
function DC:setCursorPos(pos,section) nimpl() end
function DC:write(txt) nimpl() end
function DC:setTextColor(pos,section) nimpl() end
function DC:setBackgroundColor(pos,section) nimpl() end




class.EvtH()
do
	function EvtH:__init()
		self.dest={}
		self.sources={}
		self.handlers={}
	end
	function EvtH:handle(event,...)
		
	end
	function EvtH:emit(event,...)
		
	end
	function EvtH:connect(source,...)
		
	end
end

local class.Term()
do
local term_opt=Opt{
size=Opt(Point(5,5)),
bcolor=colors.black,
tcolor=colors.white,
pos=Opt(Point(1,1)),
}
local function update(self) self:emit(UPDATE) end
local function check_color(n) return (type(n)=='number' and n>=0 or error('Invalid color, must be number >0',2)) end
function Term:__init()
	term_opt:drop(self)
	self:allocate()
end
function Term:setCursorPos(x,y) self.pos:assign(x,y) end
function Term:getCursorPos() return self.pos.x,self.pos.y end
function Term:setBackgroundColor(color) check_color(color) self.bcolor=color end
function Term:getBackgroundColor() return self.bcolor end

function Term:setTextColor(color) check_color(color) self.tcolor=color end
function Term:getTextColor() return self.tcolor end
function Term:write(txt)
	if type(txt)~='string' then error('args: string',2) end
	local n=#txt
	
end
function Term:setSize(self,size)
	self.size=size
	self:allocate()
end
function Term:getSize(self)
	return self.size.x,self.size.y
end

function Term:allocate()
	local X,Y = self.size.x,self.size.y
	self.matrix=self.matrix or {}
	for i=,Y do
		local line={}
		for j=1,X do
			line[j]={tc=self.tcolor,bc=self.bcolor,c=' '}
		end
		self.matrix[i]=line
	end
end
function Term:blit_native(term,pos,section)
	for i=section.s.y,section.e.y do
		local line=self.matrix[i]
		local tc,bc=line[1].tc,line[1].bc
		local tTxt={}
		for j=section.s.x,section.e.x do
			local tl,bl=line[j].tc,line[j].bc
			if tc~=tl or bc~=bl then
				term.setCursorPos(j-#tTxt,i)
				term.setTextColor(tc)
				term.setBackgroundColor(bc)
				term.write(table.concat(tTxt))
				tc,bc=tl,bl
				tTxt={}
			end
			table.insert(tTxt,line[j].c)
		end
		if tTxt[1] then
			term.setCursorPos(section.e.x-#tTxt,i)
			term.setTextColor(tc)
			term.setBackgroundColor(bc)
			term.write(table.concat(tTxt))
		end
	end
end
end
assert(Term:implements(DC))
local trueCursor={term.getCursorPos()}

local redirectBufferBase = {
    write=
      function(buffer,...)
        local cy=buffer.curY
        if cy>0 and cy<=buffer.height then
          local text=table.concat({...}," ")
          local cx=buffer.curX
          local px, py
          if buffer.isActive and not buffer.cursorBlink then
            term.native.setCursorPos(cx+buffer.scrX, cy+buffer.scrY)
          end
          for i=1,#text do
            if cx<=buffer.width then
              local curCell=buffer[cy][cx]
              local char,textColor,backgroundColor=string.char(text:byte(i)),buffer.textColor,buffer.backgroundColor
              if buffer[cy].isDirty or curCell.char~=char or curCell.textColor~=textColor or curCell.backgroundColor~=backgroundColor then
                buffer[cy][cx].char=char
                buffer[cy][cx].textColor=textColor
                buffer[cy][cx].backgroundColor=backgroundColor
                buffer[cy].isDirty=true
              end
            end
            cx=cx+1
          end
          buffer.curX=cx
          if buffer.isActive then
            buffer.drawDirty()
            if not buffer.cursorBlink then
              trueCursor={cx+buffer.scrX-1,cy+buffer.scrY-1}
              term.native.setCursorPos(unpack(trueCursor))
            end
          end
        end
      end,
      
    setCursorPos=
      function(buffer,x,y)
        buffer.curX=math.floor(x)
        buffer.curY=math.floor(y)
        if buffer.isActive and buffer.cursorBlink then
          term.native.setCursorPos(x+buffer.scrX-1,y+buffer.scrY-1)
          trueCursor={x+buffer.scrX-1,y+buffer.scrY-1}
        end
      end,
      
    getCursorPos=
      function(buffer)
        return buffer.curX,buffer.curY
      end,
      
    scroll=
      function(buffer,offset)
        for j=1,offset do
          local temp=table.remove(buffer,1)
          table.insert(buffer,temp)
          for i=1,#temp do
            temp[i].char=" "
            temp[i].textColor=buffer.textColor
            temp[i].backgroundColor=buffer.backgroundColor
          end
        end
        if buffer.isActive then
          term.redirect(term.native)
          buffer.blit()
          term.restore()
        end
      end,
      
    isColor=
      function(buffer)
        return buffer._isColor
      end,
      
    isColour=
      function(buffer)
        return buffer._isColor
      end,
      
    clear=
      function(buffer)
        for y=1,buffer.height do
          for x=1,buffer.width do
            buffer[y][x]={char=" ",textColor=buffer.textColor,backgroundColor=buffer.backgroundColor}
          end
        end
        if buffer.isActive then
          term.redirect(term.native)
          buffer.blit()
          term.restore()
        end
      end,
      
    clearLine=
      function(buffer)
        local line=buffer[buffer.curY]
        local fg,bg = buffer.textColor, buffer.backgroundColor
        for x=1,buffer.width do
          line[x]={char=" ",textColor=fg,backgroundColor=bg}
        end
        buffer[buffer.curY].isDirty=true
        if buffer.isActive then
          buffer.drawDirty()
        end
      end,
      
    setCursorBlink=
      function(buffer,onoff)
        buffer.cursorBlink=onoff
        if buffer.isActive then
          term.native.setCursorBlink(onoff)
          if onoff then
            term.native.setCursorPos(buffer.curX,buffer.curY)
            trueCursor={buffer.curX,buffer.curY}
          end
        end
      end,
      
    getSize=
      function(buffer)
        return buffer.width, buffer.height
      end,
      
    setTextColor=
      function(buffer,color)
        buffer.textColor=color
        if buffer.isActive then
          if term.native.isColor() or color==colors.black or color==colors.white then
            term.native.setTextColor(color)
          end
        end
      end,
      
    setTextColour=
      function(buffer,color)
        buffer.textColor=color
        if buffer.isActive then
          if term.native.isColor() or color==colors.black or color==colors.white then
            term.native.setTextColor(color)
          end
        end
      end,
      
    setBackgroundColor=
      function(buffer,color)
        buffer.backgroundColor=color
        if buffer.isActive then
          if term.native.isColor() or color==colors.black or color==colors.white then
        term.native.setBackgroundColor(color)
          end
        end
      end,
      
    setBackgroundColour=
      function(buffer,color)
        buffer.backgroundColor=color
        if buffer.isActive then
          if term.native.isColor() or color==colors.black or color==colors.white then
        term.native.setBackgroundColor(color)
          end
        end
      end,
    
    resize=
      function(buffer,width,height)
        if buffer.width~=width or buffer.height~=height then
          local fg, bg=buffer.textColor, buffer.backgroundColor
          if width>buffer.width then
            for y=1,buffer.height do
              for x=#buffer[y]+1,width do
                buffer[y][x]={char=" ",textColor=fg,backgroundColor=bg}
              end
            end
          end

          if height>buffer.height then
            local w=width>buffer.width and width or buffer.width
            for y=#buffer+1,height do
              local row={}           
              for x=1,width do
                row[x]={char=" ",textColor=fg,backgroundColor=bg}
              end
              buffer[y]=row
            end
          end
          buffer.width=width
          buffer.height=height
        end
      end,
      
    blit=
      function(buffer,sx,sy,dx, dy, width,height)
        sx=sx or 1
        sy=sy or 1
        dx=dx or buffer.scrX
        dy=dy or buffer.scrY
        width=width or buffer.width
        height=height or buffer.height
        
        local h=sy+height>buffer.height and buffer.height-sy or height-1
        for y=0,h do
          local row=buffer[sy+y]
          local x=0
          local cell=row[sx]
          local fg,bg=cell.textColor,cell.backgroundColor
          local str=""
          local tx=x
          while true do
            str=str..cell.char
            x=x+1
            if x==width or sx+x>buffer.width then
              break
            end
            cell=row[sx+x]
            if cell.textColor~=fg or cell.backgroundColor~=bg then
              --write
              term.setCursorPos(dx+tx,dy+y)
              term.setTextColor(fg)
              term.setBackgroundColor(bg)
              term.write(str)
              str=""
              tx=x
              fg=cell.textColor
              bg=cell.backgroundColor              
            end
          end 
          term.setCursorPos(dx+tx,dy+y)
          term.setTextColor(fg)
          term.setBackgroundColor(bg)
          term.write(str)
        end
      end,
      
    drawDirty =
      function(buffer)
        term.redirect(term.native)
        for y=1,buffer.height do
          if buffer[y].isDirty then
            term.redirect(term.native)
            buffer.blit(1,y,buffer.scrX,buffer.scrY+y-1,buffer.width,buffer.height)
            term.restore()
            buffer[y].isDirty=false
          end
        end
        term.restore()
      end,
      
    makeActive =
      function(buffer,posX, posY)
        posX=posX or 1
        posY=posY or 1
        buffer.scrX=posX
        buffer.scrY=posY
        term.redirect(term.native)
        buffer.blit(1,1,posX,posY,buffer.width,buffer.height)
        term.setCursorPos(buffer.curX,buffer.curY)
        term.setCursorBlink(buffer.cursorBlink)
        term.setTextColor(buffer.textColor)
        term.setBackgroundColor(buffer.backgroundColor)
        buffer.isActive=true
        term.restore()
      end,
      
    isBuffer = true,
    
  }
    

function createRedirectBuffer(width,height,fg,bg,isColor)
   bg=bg or colors.black
   fg=fg or colors.white
   isColor=isColor~=nil and isColor or term.isColor()
   local buffer={}
   
   do 
     local w,h=term.getSize()
     width,height=width or w,height or h
   end
   
   for y=1,height do
     local row={}
     for x=1,width do
       row[x]={char=" ",textColor=fg,backgroundColor=bg}
     end
     buffer[y]=row
   end
   buffer.scrX=1
   buffer.scrY=1
   buffer.width=width
   buffer.height=height
   buffer.cursorBlink=false
   buffer.textColor=fg
   buffer.backgroundColor=bg
   buffer._isColor=isColor
   buffer.curX=1
   buffer.curY=1
   
   local meta={}
   local function wrap(f,o)
     return function(...)
         return f(o,...)
       end
   end
   for k,v in pairs(redirectBufferBase) do
     if type(v)=="function" then
       meta[k]=wrap(v,buffer)
     else
       meta[k]=v
     end
   end
   setmetatable(buffer,{__index=meta})
   return buffer
end