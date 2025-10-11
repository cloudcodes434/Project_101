type ChemicalType<T> = { set: (T) -> (), get: () -> (T), __entity: number }

export type GuiBaseProperties = {
	Name: (ChemicalType<string> | string)?,
	Visible: (ChemicalType<boolean> | boolean)?,
	Active: (ChemicalType<boolean> | boolean)?,
	AnchorPoint: (ChemicalType<Vector2> | Vector2)?,
	Position: (ChemicalType<UDim2> | UDim2)?,
	Size: (ChemicalType<UDim2> | UDim2)?,
	Rotation: (ChemicalType<number> | number)?,
	ZIndex: (ChemicalType<number> | number)?,
	LayoutOrder: (ChemicalType<number> | number)?,
	BackgroundTransparency: (ChemicalType<number> | number)?,
	BackgroundColor3: (ChemicalType<Color3> | Color3)?,
	BorderSizePixel: (ChemicalType<number> | number)?,
	BorderColor3: (ChemicalType<Color3> | Color3)?,
	ClipsDescendants: (ChemicalType<boolean> | boolean)?,
	Selectable: (ChemicalType<boolean> | boolean)?,
	Parent: GuiObject?,
	Children: { [number]: Instance | ChemicalType<GuiObject> }
}

type GuiBaseEvents = {
	InputBegan: (input: InputObject, gameProcessed: boolean) -> (),
	InputEnded: (input: InputObject, gameProcessed: boolean) -> (),
	InputChanged: (input: InputObject, gameProcessed: boolean) -> (),

	-- Mouse Events
	MouseEnter: () -> (),
	MouseLeave: () -> (),
	MouseMoved: (deltaX: number, deltaY: number) -> (),
	MouseWheelForward: (scrollDelta: number) -> (),
	MouseWheelBackward: (scrollDelta: number) -> (),

	-- Touch Events
	TouchTap: (touchPositions: {Vector2}, state: Enum.UserInputState) -> (),
	TouchPinch: (scale: number, velocity: number, state: Enum.UserInputState) -> (),
	TouchPan: (pan: Vector2, velocity: Vector2, state: Enum.UserInputState) -> (),
	TouchSwipe: (direction: Enum.SwipeDirection, touches: number) -> (),
	TouchRotate: (rotation: number, velocity: number, state: Enum.UserInputState) -> (),
	TouchLongPress: (duration: number) -> (),

	-- Console/Selection Events
	SelectionGained: () -> (),
	SelectionLost: () -> (),
	SelectionChanged: (newSelection: Instance) -> (),
}

type ImageGuiProperties = GuiBaseProperties & {
	Image: (ChemicalType<string> | string)?,
	ImageColor3: (ChemicalType<Color3> | Color3)?,
	ImageTransparency: (ChemicalType<number> | number)?,
	ScaleType: (ChemicalType<Enum.ScaleType> | Enum.ScaleType)?,
	SliceCenter: (ChemicalType<Rect> | Rect)?,
	TileSize: (ChemicalType<UDim2> | UDim2)?,
	ResampleMode: (ChemicalType<Enum.ResamplerMode> | Enum.ResamplerMode)?,
}

type TextGuiProperties = GuiBaseProperties & {
	Text: (ChemicalType<string> | string)?,
	TextColor3: (ChemicalType<Color3> | Color3)?,
	TextTransparency: (ChemicalType<number> | number)?,
	TextStrokeColor3: (ChemicalType<Color3> | Color3)?,
	TextStrokeTransparency: (ChemicalType<number> | number)?,
	TextScaled: (ChemicalType<boolean> | boolean)?,
	TextSize: (ChemicalType<number> | number)?,
	TextWrapped: (ChemicalType<boolean> | boolean)?,
	FontFace: (ChemicalType<Font> | Font)?,
	LineHeight: (ChemicalType<number> | number)?,
	RichText: (ChemicalType<boolean> | boolean)?,
	TextXAlignment: (ChemicalType<Enum.TextXAlignment> | Enum.TextXAlignment)?,
	TextYAlignment: (ChemicalType<Enum.TextYAlignment> | Enum.TextYAlignment)?,
	TextTruncate: (ChemicalType<Enum.TextTruncate> | Enum.TextTruncate)?,
}

export type FrameProperties = GuiBaseProperties
export type TextLabelProperties = TextGuiProperties
export type ImageLabelProperties = ImageGuiProperties

-- Interactive Elements
type ButtonEvents = GuiBaseEvents & {
	Activated: (inputType: Enum.UserInputType?) -> (),
	MouseButton1Click: () -> (),
	MouseButton2Click: () -> (),
	MouseButton2Down: () -> (),
	MouseButton2Up: () -> (),
	
	MouseWheelForward: nil,
	MouseWheelBackward: nil,
}

export type ButtonProperties = {
	AutoButtonColor: (ChemicalType<boolean> | boolean)?,
	Modal: (ChemicalType<boolean> | boolean)?,
	Selected: (ChemicalType<boolean> | boolean)?,
	
	ButtonHoverStyle: (ChemicalType<Enum.ButtonStyle> | Enum.ButtonStyle)?,
	ButtonPressStyle: (ChemicalType<Enum.ButtonStyle> | Enum.ButtonStyle)?,
	ActivationBehavior: (ChemicalType<Enum.ActivationBehavior> | Enum.ActivationBehavior)?,

	SelectionGroup: (ChemicalType<number> | number)?,
	SelectionBehaviorUp: (ChemicalType<Enum.SelectionBehavior> | Enum.SelectionBehavior)?,
	SelectionBehaviorDown: (ChemicalType<Enum.SelectionBehavior> | Enum.SelectionBehavior)?,
	SelectionBehaviorLeft: (ChemicalType<Enum.SelectionBehavior> | Enum.SelectionBehavior)?,
	SelectionBehaviorRight: (ChemicalType<Enum.SelectionBehavior> | Enum.SelectionBehavior)?,
	GamepadPriority: (ChemicalType<number> | number)?,
}


export type TextButtonProperties = TextGuiProperties & ButtonProperties
export type ImageButtonProperties = ImageGuiProperties & ButtonProperties

type TextBoxEvents = GuiBaseEvents & {
	FocusLost: (enterPressed: boolean) -> (),
	FocusGained: () -> (),
	TextChanged: (text: string) -> (),
}

export type TextBoxProperties = TextGuiProperties & {
	ClearTextOnFocus: (ChemicalType<boolean> | boolean)?,
	MultiLine: (ChemicalType<boolean> | boolean)?,
	PlaceholderText: (ChemicalType<string> | string)?,
	PlaceholderColor3: (ChemicalType<Color3> | Color3)?,
	CursorPosition: (ChemicalType<number> | number)?,
	SelectionStart: (ChemicalType<number> | number)?,
	ShowNativeInput: (ChemicalType<boolean> | boolean)?,
	TextInputType: (ChemicalType<Enum.TextInputType> | Enum.TextInputType)?,
}


-- Containers
type ScrollingFrameEvents = GuiBaseEvents & {
	Scrolled: (scrollVelocity: Vector2) -> (),
}

export type ScrollingFrameProperties = FrameProperties & {
	ScrollBarImageColor3: (ChemicalType<Color3> | Color3)?,
	ScrollBarThickness: (ChemicalType<number> | number)?,
	ScrollingDirection: (ChemicalType<Enum.ScrollingDirection> | Enum.ScrollingDirection)?,
	CanvasSize: (ChemicalType<UDim2> | UDim2)?,
	CanvasPosition: (ChemicalType<Vector2> | Vector2)?,
	AutomaticCanvasSize: (ChemicalType<Enum.AutomaticSize> | Enum.AutomaticSize)?,
	VerticalScrollBarInset: (ChemicalType<Enum.ScrollBarInset> | Enum.ScrollBarInset)?,
	HorizontalScrollBarInset: (ChemicalType<Enum.ScrollBarInset> | Enum.ScrollBarInset)?,
	ScrollBarImageTransparency: (ChemicalType<number> | number)?,
	ElasticBehavior: (ChemicalType<Enum.ElasticBehavior> | Enum.ElasticBehavior)?,
	VerticalScrollBarPosition: (ChemicalType<Enum.VerticalScrollBarPosition> | Enum.VerticalScrollBarPosition)?,
}

type ViewportFrameEvents = GuiBaseEvents & {
	ViewportResized: (newSize: Vector2) -> (),
	CameraChanged: (newCamera: Camera) -> (),
}

export type ViewportFrameProperties = FrameProperties & {
	CurrentCamera: (ChemicalType<Camera> | Camera)?,
	ImageColor3: (ChemicalType<Color3> | Color3)?,
	LightColor: (ChemicalType<Color3> | Color3)?,
	LightDirection: (ChemicalType<Vector3> | Vector3)?,
	Ambient: (ChemicalType<Color3> | Color3)?,
	LightAngularInfluence: (ChemicalType<number> | number)?,
}

-- Layouts
export type UIListLayoutProperties = {
	Padding: (ChemicalType<UDim> | UDim)?,
	FillDirection: (ChemicalType<Enum.FillDirection> | Enum.FillDirection)?,
	HorizontalAlignment: (ChemicalType<Enum.HorizontalAlignment> | Enum.HorizontalAlignment)?,
	VerticalAlignment: (ChemicalType<Enum.VerticalAlignment> | Enum.VerticalAlignment)?,
	SortOrder: (ChemicalType<Enum.SortOrder> | Enum.SortOrder)?,
	Appearance: (ChemicalType<Enum.Appearance> | Enum.Appearance)?,
}

export type UIGridLayoutProperties = {
	CellSize: (ChemicalType<UDim2> | UDim2)?,
	CellPadding: (ChemicalType<UDim2> | UDim2)?,
	StartCorner: (ChemicalType<Enum.StartCorner> | Enum.StartCorner)?,
	FillDirection: (ChemicalType<Enum.FillDirection> | Enum.FillDirection)?,
	HorizontalAlignment: (ChemicalType<Enum.HorizontalAlignment> | Enum.HorizontalAlignment)?,
	VerticalAlignment: (ChemicalType<Enum.VerticalAlignment> | Enum.VerticalAlignment)?,
	SortOrder: (ChemicalType<Enum.SortOrder> | Enum.SortOrder)?,
}

-- Style Elements
export type UICornerProperties = {
	CornerRadius: (ChemicalType<UDim> | UDim)?,
}

export type UIStrokeProperties = {
	Color: (ChemicalType<Color3> | Color3)?,
	Thickness: (ChemicalType<number> | number)?,
	Transparency: (ChemicalType<number> | number)?,
	Enabled: (ChemicalType<boolean> | boolean)?,
	ApplyStrokeMode: (ChemicalType<Enum.ApplyStrokeMode> | Enum.ApplyStrokeMode)?,
	LineJoinMode: (ChemicalType<Enum.LineJoinMode> | Enum.LineJoinMode)?,
}

export type UIGradientProperties = {
	Color: (ChemicalType<ColorSequence> | ColorSequence)?,
	Transparency: (ChemicalType<NumberSequence> | NumberSequence)?,
	Offset: (ChemicalType<Vector2> | Vector2)?,
	Rotation: (ChemicalType<number> | number)?,
	Enabled: (ChemicalType<boolean> | boolean)?,
}

export type UIPaddingProperties = {
	PaddingTop: (ChemicalType<UDim> | UDim)?,
	PaddingBottom: (ChemicalType<UDim> | UDim)?,
	PaddingLeft: (ChemicalType<UDim> | UDim)?,
	PaddingRight: (ChemicalType<UDim> | UDim)?,
}

export type UIScaleProperties = {
	Scale: (ChemicalType<number> | number)?,
}


type CanvasMouseEvents = GuiBaseEvents & {
	MouseWheel: (direction: Enum.MouseWheelDirection, delta: number) -> (),
}

export type CanvasGroupProperties = {
	GroupTransparency: (ChemicalType<number> | number)?,
	GroupColor3: (ChemicalType<Color3> | Color3)?,
} & CanvasMouseEvents

-- Constraints
export type UIAspectRatioConstraintProperties = {
	AspectRatio: (ChemicalType<number> | number)?,
	AspectType: (ChemicalType<Enum.AspectType> | Enum.AspectType)?,
	DominantAxis: (ChemicalType<Enum.DominantAxis> | Enum.DominantAxis)?,
}

export type UISizeConstraintProperties = {
	MinSize: (ChemicalType<Vector2> | Vector2)?,
	MaxSize: (ChemicalType<Vector2> | Vector2)?,
}

-- Specialized
export type BillboardGuiProperties = GuiBaseProperties & {
	Active: (ChemicalType<boolean> | boolean)?,
	AlwaysOnTop: (ChemicalType<boolean> | boolean)?,
	LightInfluence: (ChemicalType<number> | number)?,
	MaxDistance: (ChemicalType<number> | number)?,
	SizeOffset: (ChemicalType<Vector2> | Vector2)?,
	StudsOffset: (ChemicalType<Vector3> | Vector3)?,
	ExtentsOffset: (ChemicalType<Vector3> | Vector3)?,
}

export type SurfaceGuiProperties = GuiBaseProperties & {
	Active: (ChemicalType<boolean> | boolean)?,
	AlwaysOnTop: (ChemicalType<boolean> | boolean)?,
	Brightness: (ChemicalType<number> | number)?,
	CanvasSize: (ChemicalType<Vector2> | Vector2)?,
	Face: (ChemicalType<Enum.NormalId> | Enum.NormalId)?,
	LightInfluence: (ChemicalType<number> | number)?,
	PixelsPerStud: (ChemicalType<number> | number)?,
	SizingMode: (ChemicalType<Enum.SurfaceGuiSizingMode> | Enum.SurfaceGuiSizingMode)?,
	ToolPunchThroughDistance: (ChemicalType<number> | number)?,
}

export type ScreenGuiProperties = GuiBaseProperties & {
	Active: (ChemicalType<boolean> | boolean)?,
	AlwaysOnTop: (ChemicalType<boolean> | boolean)?,
	Brightness: (ChemicalType<number> | number)?,
	DisplayOrder: (ChemicalType<number> | number)?,
	IgnoreGuiInset: (ChemicalType<boolean> | boolean)?,
	OnTopOfCoreBlur: (ChemicalType<boolean> | boolean)?,
	ScreenInsets: (ChemicalType<Enum.ScreenInsets> | Enum.ScreenInsets)?,
	ZIndexBehavior: (ChemicalType<Enum.ZIndexBehavior> | Enum.ZIndexBehavior)?,
}

export type EventNames = (
	"InputBegan" | "InputEnded" | "InputChanged" |
	"MouseEnter" | "MouseLeave" | "MouseMoved" |
	"MouseButton1Down" | "MouseButton1Up" |
	"MouseWheelForward" | "MouseWheelBackward" |

	"TouchTap" | "TouchPinch" | "TouchPan" |
	"TouchSwipe" | "TouchRotate" | "TouchLongPress" |

	"SelectionGained" | "SelectionLost" | "SelectionChanged" |

	"Activated" | "MouseButton1Click" | "MouseButton2Click" |
	"MouseButton2Down" | "MouseButton2Up" |

	"FocusLost" | "FocusGained" | "TextChanged" |

	"Scrolled" |

	"ViewportResized" | "CameraChanged" |

	"BillboardTransformed" |

	"SurfaceChanged" |

	"GroupTransparencyChanged" |

	"StrokeUpdated" |

	"GradientOffsetChanged" |

	"ChildAdded" | "ChildRemoved" | "AncestryChanged"
)

export type PropertyNames = (
	"Name" | "Visible" | "Active" | "AnchorPoint" | "Position" | "Size" |
	"Rotation" | "ZIndex" | "LayoutOrder" | "BackgroundTransparency" |
	"BackgroundColor3" | "BorderSizePixel" | "BorderColor3" |
	"ClipsDescendants" | "Selectable" |

	"Image" | "ImageColor3" | "ImageTransparency" | "ScaleType" |
	"SliceCenter" | "TileSize" | "ResampleMode" |

	"Text" | "TextColor3" | "TextTransparency" | "TextStrokeColor3" |
	"TextStrokeTransparency" | "TextScaled" | "TextSize" | "TextWrapped" |
	"FontFace" | "LineHeight" | "RichText" | "TextXAlignment" |
	"TextYAlignment" | "TextTruncate" |

	"AutoButtonColor" | "Modal" | "Selected" | "ButtonHoverStyle" |
	"ButtonPressStyle" | "ActivationBehavior" | "SelectionGroup" |
	"SelectionBehaviorUp" | "SelectionBehaviorDown" |
	"SelectionBehaviorLeft" | "SelectionBehaviorRight" | "GamepadPriority" |

	"ClearTextOnFocus" | "MultiLine" | "PlaceholderText" |
	"PlaceholderColor3" | "CursorPosition" | "SelectionStart" |
	"ShowNativeInput" | "TextInputType" |

	"ScrollBarImageColor3" | "ScrollBarThickness" | "ScrollingDirection" |
	"CanvasSize" | "CanvasPosition" | "AutomaticCanvasSize" |
	"VerticalScrollBarInset" | "HorizontalScrollBarInset" |
	"ScrollBarImageTransparency" | "ElasticBehavior" | "VerticalScrollBarPosition" |

	"CurrentCamera" | "LightColor" | "LightDirection" | "Ambient" |
	"LightAngularInfluence" |

	"Padding" | "FillDirection" | "HorizontalAlignment" | "VerticalAlignment" |
	"SortOrder" | "Appearance" | "CellSize" | "CellPadding" | "StartCorner" |

	"CornerRadius" | "Color" | "Thickness" | "Transparency" | "Enabled" |
	"ApplyStrokeMode" | "LineJoinMode" | "Offset" | "Rotation" |
	"PaddingTop" | "PaddingBottom" | "PaddingLeft" | "PaddingRight" | "Scale" |

	"GroupTransparency" | "GroupColor3" |

	"AspectRatio" | "AspectType" | "DominantAxis" | "MinSize" | "MaxSize" |

	"AlwaysOnTop" | "LightInfluence" | "MaxDistance" | "SizeOffset" |
	"StudsOffset" | "ExtentsOffset" |

	"Brightness" | "Face" | "PixelsPerStud" | "SizingMode" | "ToolPunchThroughDistance" |

	"Parent" | "Children"
)


return {}