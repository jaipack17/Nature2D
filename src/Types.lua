--[[
	Type Definitions
]]--

export type Quadtree<T> = {
	position: Vector2,
	size: Vector2,
	capacity: number,
	objects: {T},
	divided: boolean,
}

export type Canvas = {
	topLeft: Vector2,
	size: Vector2,
	frame: Frame?
}

export type Point = {
	Parent: any,
	frame: Frame?,
	engine: { any },
	canvas: Canvas,
	oldPos: Vector2,
	pos: Vector2,
	forces: Vector2,
	gravity: Vector2,
	friction: number,
	bounce: number,
	snap: boolean,
	selectable: boolean,
	render: boolean,
	keepInCanvas: boolean,
	color: Color3?,
	radius: number,
}

export type RigidBody = {
	CreateProjection: (Axis: Vector2, Min: number, Max: number) -> (number, number),
	SetState: (state: string, value: any) -> (),
	GetState: (state: string) -> any,
	
	id: string,
	vertices: { Point },
	edges: { any },
	frame: GuiObject?,
	anchored: boolean,
	mass: number,
	collidable: boolean,
	center: Vector2,
	engine: { any },
	spawnedAt: number,
	lifeSpan: number?,
	anchorRotation: number?,
	anchorPos: Vector2?,
	Touched: any,
	CanvasEdgeTouched: any,
	States: { any }
}

export type Exceptions = {
	NO_CANVAS_FOUND: string,
	NO_RIGIDBODIES_FOUND: string,
	PROPERTY_NOT_FOUND: string,
}

export type SegmentConfig = {
	restLength: number?, 
	render: boolean, 
	thickness: number,
	support: boolean
}

export type EngineConfig = {
	gravity: Vector2,
	friction: number,
	bounce: number,
	speed: number,
}

export type PointConfig = {
	snap: boolean, 
	selectable: boolean, 
	render: boolean,
	keepInCanvas: boolean
}

export type Collision = {
	axis: Vector2,
	depth: number,
	edge: any,
	vertex: Point
}

export type Range = {
	position: Vector2,
	size: Vector2
}

return nil