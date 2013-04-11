include'kernel.class'
local check=require'kernel.checker'.check
--[[-------------------------------------------------------
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

function Point:__init(x, y)
    return self:assign(x, y)
end

function Point:assign(x, y)
    if (not y) then
        
        check('Point',x)
        
        self.x = x.x
        self.y = x.y
    else
        check('number,number',x,y)
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
        check('Point',x)
        self.x = self.x + x.x
        self.y = self.y + x.y
    else
        check('number,number',x,y)
        self.x = self.x + x
        self.y = self.y + y
    end
    return self
end

function Point:sub(x, y)
    if (not y) then
        check('Point',x)
        return self:add(-x.x, -x.y)
    else
        check('number,number',x,y)
        return self:add(-x, -y)
    end
end

function Point:equal(p)
    check('Point',p)
    return self.x == p.x and self.y == p.y
end
function Point:__tostring()
    return '(' .. self.x .. ',' .. self.y ..')'
end

return Point
