-- Type Definitions

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
	airfriction: number,
	bounce: number,
	snap: boolean,
	selectable: boolean,
	render: boolean,
	keepInCanvas: boolean,
	color: Color3?,
	radius: number
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

export type SegmentConfig = {
	restLength: number?,
	render: boolean,
	thickness: number?,
	support: boolean,
	TYPE: string,
}

export type EngineConfig = {
	gravity: Vector2,
	friction: number,
	bounce: number,
	speed: number,
	airfriction: number,
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

export type Properties = {
	Position: Vector2?,
	Visible: boolean?,
	Snap: boolean?,
	KeepInCanvas: boolean?,
	Radius: number?,
	Color: Color3?,
	Type: string?,
	Point1: Point?,
	Point2: Point?,
	Thickness: number?,
	RestLength: number?,
	SpringConstant: number?,
	Object: GuiObject?,
	Collidable: boolean?,
	Anchored: boolean?,
	LifeSpan: number?,
	Gravity: Vector2?,
	Friction: number?,
	AirFriction: number?,
	Structure: {}?,
	Mass: number?,
	CanRotate: boolean
}

export type Custom = {
	Vertices: { any },
	Edges: { any }
}

export type Plugins = {
	Triangle: (a: Vector2, b: Vector2, c: Vector2) -> (),
	Quad: (a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> (),
	MouseConstraint: (engine: { any }, range: number, rigidbodies: { any }) -> ()
}

export type DebugInfo = {
	Objects: {
		RigidBodies: number,
		Constraints: number,
		Points: number
	},
	Running: boolean,
	Physics: {
		Gravity: Vector2,
		Friction: number,
		AirFriction: number,
		CollisionMultiplier: number,
		TimeSteps: number,
		SimulationSpeed: number,
		UsingQuadtrees: boolean,
		FramerateIndependent: boolean
	},
	Path: ScreenGui,
	Canvas: {
		Frame: GuiObject,
		TopLeft: Vector2,
		Size: Vector2
	}
}

return nil
