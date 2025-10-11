-- // Services -- \\
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketPlaceService = game:GetService("MarketplaceService")
-- // Variables -- \\
local Player = Players.LocalPlayer
local PlayerUI = Player.PlayerGui
local GameFolder = ReplicatedStorage:WaitForChild("Game")


-- // Bool -- \\
local isInCooldown = false
local lastEquippedFrame = nil

-- // Containers
local EffectsTable = {}
local UIController = {}
-- // Modules -- \\
local Libraries = require(GameFolder:WaitForChild("Library"))
local ProductIDs = Libraries.Modules.Global.IDs

function OpenFrame(Frame: Frame)
	local UIScale = Frame:FindFirstChildOfClass("UIScale")
	if not UIScale then
		UIScale = Instance.new("UIScale")
		UIScale.Parent = Frame
	end

	UIScale.Scale = 0.85
	Frame.Visible = true

	UIController["Spring"].target(UIScale, 0.65, 4, { Scale = 1 })
	lastEquippedFrame = Frame
end

function CloseFrame(Frame: Frame)
	local UIScale = Frame:FindFirstChildOfClass("UIScale")
	if not UIScale then
		UIScale = Instance.new("UIScale")
		UIScale.Parent = Frame
	end
	Frame.Visible = true

	UIController["Spring"].target(UIScale, 0.65, 4, { Scale = 0 })

	task.delay(0.4, function()
		Frame.Visible = false
	end)
end



function UIController:ToggleFrame(Frame: Frame, State: boolean | nil)
	if isInCooldown then
		return
	end

	isInCooldown = true
	task.delay(0.5, function()
		isInCooldown = false
	end)
	if typeof(Frame) == "string" then
		local foundFrame = UIController.Frames:FindFirstChild(Frame)

		if not foundFrame then
			return
		end

		Frame = foundFrame
	end

	if State == nil then
		State = not Frame.Visible
	end

	if State == true then
		if lastEquippedFrame ~= nil and lastEquippedFrame ~= Frame then
			CloseFrame(lastEquippedFrame)
		elseif lastEquippedFrame == Frame then
			CloseFrame(Frame)
			lastEquippedFrame = nil
		--	UIController["HUDController"]:ShowHUD()
			return
		end

	--	UIController["HUDController"]:HideHUD()
		OpenFrame(Frame)
		return
	end

	--UIController["HUDController"]:ShowHUD()
	lastEquippedFrame = nil
	CloseFrame(Frame)
end

function UIController:AddHover(UIObject: GuiObject, scaleGoal: number?)
	local Chemical = UIController["Chemical"]
	local Spring = UIController["Spring"]

	if not Chemical or not Chemical["Value"] then
		return
	end

	local Value = Chemical.Value
	local OnEvent = Chemical.onEvent
	local Give = Chemical.Give

	local UIScale = UIObject:FindFirstChildOfClass("UIScale")
	if not UIScale then
		UIScale = Instance.new("UIScale")
		UIScale.Parent = UIObject
	end

	local State = Value(nil)

	local function OnHover()
		local numberToAnimateTo = State:get() == true and scaleGoal or 1

		Spring.target(UIScale, 0.65, 4, {
			Scale = numberToAnimateTo,
		})
	end

	Give(UIObject)({
		[OnEvent("MouseEnter")] = function()
			State:set(true)
			OnHover()
		end,

		[OnEvent("MouseLeave")] = function()
			State:set(false)
			OnHover()
		end,
	})
end

function UIController:ConnectButtonToCallback(UIObject: GuiButton, funct: () -> ())
	if UIObject:IsA("Frame") then
		UIObject = UIObject:FindFirstChildOfClass("TextButton") :: TextButton
	end

	UIObject.Activated:Connect(function()
		if funct then
			funct()
		end
	end)
	return true
end

function UIController:AddClickEffect(UIObject: GuiButton, UIButton: GuiButton?, scaleGoal: number?)
	local Chemical = UIController["Chemical"]
	local Spring = UIController["Spring"]

	if not Chemical or not Chemical.Value then
		return
	end

	local Value = Chemical.Value
	local OnEvent = Chemical.onEvent
	local Give = Chemical.Give

	if not UIButton then
		UIButton = UIObject
	end

	local UIScale = UIObject:FindFirstChildOfClass("UIScale")
	if not UIScale then
		UIScale = Instance.new("UIScale")
		UIScale.Parent = UIObject
	end

	local State = Value(nil)

	local function OnHover()
		local numberToAnimateTo = State:get() == true and scaleGoal or 1

		Spring.target(UIScale, 0.65, 4, {
			Scale = numberToAnimateTo,
		})
	end

	Give(UIButton)({
		[OnEvent("MouseButton1Down")] = function()
			State:set(true)
			OnHover()
		end,

		[OnEvent("MouseButton1Up")] = function()
			State:set(false)
			OnHover()
		end,
	})
end

function UIController:Init()
	UIController.Spring = Libraries.Modules["Resources"].Spring
	UIController.Chemical = Libraries.Modules["Resources"].Chemical
end

function UIController:Start()
	UIController.HUDController = Libraries:GetController("HUDController")
	UIController.Spring = Libraries.Modules["Resources"].Spring
	UIController.Chemical = Libraries.Modules["Resources"].Chemical

	local MainUI = PlayerUI:WaitForChild("Main")
	local Frames = MainUI:WaitForChild("Frames")


	UIController.Frames = Frames
end

return UIController
