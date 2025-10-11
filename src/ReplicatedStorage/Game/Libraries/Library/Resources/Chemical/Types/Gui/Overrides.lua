local Guitype = require(script.Parent)

local module = {}

type ChemicalGui<T> = T

type GuiObjects = {
	
}

type function Give(element: type)
	if not element:is("table") then
		error("Can only be a table")
	end
	
	
end

export type GiveFunction = (
	-- Basic Elements
	((element: Frame)-> ((properties: Guitype.FrameProperties ) -> ChemicalGui<Frame>)) &
	((element: TextLabel)-> ((properties: Guitype.TextLabelProperties ) -> ChemicalGui<TextLabel>)) &
	((element: ImageLabel)-> ((properties: Guitype.ImageLabelProperties ) -> ChemicalGui<ImageLabel>)) &

	-- Interactive Elements
	((element: TextButton | GuiButton)-> ((properties: Guitype.TextButtonProperties ) -> ChemicalGui<TextButton>)) &
	((element: ImageButton | GuiButton)-> ((properties: Guitype.ImageButtonProperties ) -> ChemicalGui<ImageButton>)) &
	((element: TextBox)-> ((properties: Guitype.TextBoxProperties ) -> ChemicalGui<TextBox>)) &

	-- Containers
	((element: ScrollingFrame)-> ((properties: Guitype.ScrollingFrameProperties ) -> ChemicalGui<ScrollingFrame>)) &
	((element: ViewportFrame)-> ((properties: Guitype.ViewportFrameProperties ) -> ChemicalGui<ViewportFrame>)) &

	-- Layouts
	((element: UIListLayout)-> ((properties: Guitype.UIListLayoutProperties ) -> ChemicalGui<UIListLayout>)) &
	((element: UIGridLayout)-> ((properties: Guitype.UIGridLayoutProperties ) -> ChemicalGui<UIGridLayout>)) &

	-- Style Elements
	((element: UICorner)-> ((properties: Guitype.UICornerProperties ) -> ChemicalGui<UICorner>)) &
	((element: UIStroke)-> ((properties: Guitype.UIStrokeProperties ) -> ChemicalGui<UIStroke>)) &
	((element: UIGradient)-> ((properties: Guitype.UIGradientProperties ) -> ChemicalGui<UIGradient>)) &
	((element: UIPadding)-> ((properties: Guitype.UIPaddingProperties ) -> ChemicalGui<UIPadding>)) &
	((element: UIScale)-> ((properties: Guitype.UIScaleProperties ) -> ChemicalGui<UIScale>)) &
	((element: CanvasGroup)-> ((properties: Guitype.CanvasGroupProperties ) -> ChemicalGui<CanvasGroup>)) &

	-- Constraints
	((element: UIAspectRatioConstraint)-> ((properties: Guitype.UIAspectRatioConstraintProperties ) -> ChemicalGui<UIAspectRatioConstraint>)) &
	((element: UISizeConstraint)-> ((properties: Guitype.UISizeConstraintProperties ) -> ChemicalGui<UISizeConstraint>)) &

	-- Specialized
	((element: BillboardGui)-> ((properties: Guitype.BillboardGuiProperties ) -> ChemicalGui<BillboardGui>)) &
	((element: SurfaceGui)-> ((properties: Guitype.SurfaceGuiProperties ) -> ChemicalGui<SurfaceGui>)) &
	((element: ScreenGui)-> ((properties: Guitype.ScreenGuiProperties ) -> ChemicalGui<ScreenGui>)) &

	-- Fallback
	((element: GuiObject)-> ((properties: Guitype.GuiBaseProperties ) -> ChemicalGui<GuiObject>))
)

export type CreateFunction = (
	-- Basic Elements
	((element: "Frame")-> ((properties: Guitype.FrameProperties ) -> ChemicalGui<Frame>)) &
	((element: "TextLabel")-> ((properties: Guitype.TextLabelProperties ) -> ChemicalGui<TextLabel>)) &
	((element: "ImageLabel")-> ((properties: Guitype.ImageLabelProperties ) -> ChemicalGui<ImageLabel>)) &

	-- Interactive Elements
	((element: "TextButton")-> ((properties: Guitype.TextButtonProperties ) -> ChemicalGui<TextButton>)) &
	((element: "ImageButton")-> ((properties: Guitype.ImageButtonProperties ) -> ChemicalGui<ImageButton>)) &
	((element: "TextBox")-> ((properties: Guitype.TextBoxProperties ) -> ChemicalGui<TextBox>)) &

	-- Containers
	((element: "ScrollingFrame")-> ((properties: Guitype.ScrollingFrameProperties ) -> ChemicalGui<ScrollingFrame>)) &
	((element: "ViewportFrame")-> ((properties: Guitype.ViewportFrameProperties ) -> ChemicalGui<ViewportFrame>)) &

	-- Layouts
	((element: "UIListLayout")-> ((properties: Guitype.UIListLayoutProperties ) -> ChemicalGui<UIListLayout>)) &
	((element: "UIGridLayout")-> ((properties: Guitype.UIGridLayoutProperties ) -> ChemicalGui<UIGridLayout>)) &

	-- Style Elements
	((element: "UICorner")-> ((properties: Guitype.UICornerProperties ) -> ChemicalGui<UICorner>)) &
	((element: "UIStroke")-> ((properties: Guitype.UIStrokeProperties ) -> ChemicalGui<UIStroke>)) &
	((element: "UIGradient")-> ((properties: Guitype.UIGradientProperties ) -> ChemicalGui<UIGradient>)) &
	((element: "UIPadding")-> ((properties: Guitype.UIPaddingProperties ) -> ChemicalGui<UIPadding>)) &
	((element: "UIScale")-> ((properties: Guitype.UIScaleProperties ) -> ChemicalGui<UIScale>)) &
	((element: "CanvasGroup")-> ((properties: Guitype.CanvasGroupProperties ) -> ChemicalGui<CanvasGroup>)) &

	-- Constraints
	((element: "UIAspectRatioConstraint")-> ((properties: Guitype.UIAspectRatioConstraintProperties ) -> ChemicalGui<UIAspectRatioConstraint>)) &
	((element: "UISizeConstraint")-> ((properties: Guitype.UISizeConstraintProperties ) -> ChemicalGui<UISizeConstraint>)) &

	-- Specialized
	((element: "BillboardGui")-> ((properties: Guitype.BillboardGuiProperties ) -> ChemicalGui<BillboardGui>)) &
	((element: "SurfaceGui")-> ((properties: Guitype.SurfaceGuiProperties ) -> ChemicalGui<SurfaceGui>)) &
	((element: "ScreenGui")-> ((properties: Guitype.ScreenGuiProperties ) -> ChemicalGui<ScreenGui>)) &

	-- Fallback
	((element: "GuiObject")-> ((properties: Guitype.GuiBaseProperties ) -> ChemicalGui<GuiObject>))
)

return module
