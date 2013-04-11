include'kernel.class'
local Point=require'kernel.gui.Point'
class.Rectangle()
--[[ -------------------------------------------------------
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
function Rectangle:__init(x1, y1, x2, y2)
    self:assign(x1, y1, x2, y2)
end

function Rectangle:assign(x1, y1, x2, y2)
    if (not y1) then
        self.s = x1.s:clone()
        self.e = x1.e:clone()
    elseif (not x2) then
        self.s=x1:clone()
        self.e=y1:clone()
    else
        self.s = Point(x1, y1)
        self.e = Point(x2, y2)
    end
    return self
end

function Rectangle:size()
    return self.e:clone():sub(self.s)
end

function Rectangle:clone()
    return Rectangle(self)
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
return Rectangle