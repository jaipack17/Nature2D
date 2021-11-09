local Types = require(script.Parent.Types)
local Globals = require(script.Parent.constants.Globals)

local _VectorOperations = {}
local _Physics = {}

function _VectorOperations.angle(a: Vector2, b: Vector2) : number
    local c = b - a
    return math.atan2(c.Y, c.X)
end

function _Physics.calculate_rope(point1: Types.Point, point2: Types.Point, current: number, length: number, thickness: number) : Vector2
    local restLength
    if current > length then 
        restLength = length
    elseif current < thickness then 
        restLength = thickness
    end
    
    local offset = ((restLength - current)/restLength)/2
    local force = point2.pos - point1.pos 
    force *= offset

    return force
end

function _Physics.calculate_rod(point1: Types.Point, point2: Types.Point, current: number, length: number) : Vector2
    local offset = ((length - current)/length)/2	
    local force = point2.pos - point1.pos
    force *= offset

    return force
end

function _Physics.calculate_spring(point1: Types.Point, point2: Types.Point, length: number, k: number) : Vector2
    local force = point2.pos - point1.pos 
    local mag = force.Magnitude - length
    force = force.Unit
    force *= -1 * k * mag

    return force
end

local _GetCorners = function(frame: GuiObject, engine)
    local pos, size = frame.AbsolutePosition, frame.AbsoluteSize
	local rotation = math.rad(frame.Rotation)
	local center = pos + size/2
	local temp = math.sqrt((size.X/2)^2+(size.Y/2)^2)

	local offset = (engine.path and engine.path.IgnoreGuiInset) and Globals.offset or Vector2.new(0, 0)

	return {
		center - temp*Vector2.new(math.cos(rotation + math.atan2(size.Y, size.X)), math.sin(rotation + math.atan2(size.Y, size.X))) + offset, -- topleft
		center + temp*Vector2.new(math.cos(rotation - math.atan2(size.Y, size.X)), math.sin(rotation - math.atan2(size.Y, size.X))) + offset, -- topright
		center - temp*Vector2.new(math.cos(rotation - math.atan2(size.Y, size.X)), math.sin(rotation - math.atan2(size.Y, size.X))) + offset, -- bottomleft
		center + temp*Vector2.new(math.cos(rotation + math.atan2(size.Y, size.X)), math.sin(rotation + math.atan2(size.Y, size.X))) + offset, -- bottomright
	}
end

return {
    Vector = _VectorOperations,
    Physics = _Physics,
    GetCorners = _GetCorners,
}
