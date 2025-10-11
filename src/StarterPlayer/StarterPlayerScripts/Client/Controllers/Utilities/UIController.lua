-- // Services -- \\
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketPlaceService = game:GetService("MarketplaceService")

-- // Variables -- \\
local Player = Players.LocalPlayer
local PlayerUI = Player.PlayerGui

local MainUI = PlayerUI:WaitForChild("Main")
local Frames = MainUI:WaitForChild("Frames")
local SideButtons1 = MainUI:WaitForChild("SideButtons1")
local SideButtons2 = MainUI:WaitForChild("SideButtons2")
 

local Modules = ReplicatedStorage:WaitForChild("Modules")

-- // Bool -- \\
local isInCooldown = false
local lastEquippedFrame = nil

-- // Containers
local EffectsTable = {}
local UIController = {}
-- // Modules -- \\
local Libraries = require(Modules:WaitForChild("Library"))
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
		local foundFrame = Frames:FindFirstChild(Frame)

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
		if State:get() == false then
			if EffectsTable[UIObject] then
				EffectsTable[UIObject] = nil
				table.remove(EffectsTable, table.find(EffectsTable, UIObject))

				for _, Object in UIObject:GetDescendants() do
					if Object:IsA("UIGradient") and Object.Name == "Shine" then
						Object:Destroy()
					end
				end
			end
		end

		if State:get() == true then
			local VectorIcon = UIObject:FindFirstChildOfClass("ImageLabel")
			local BodyImage = UIObject:FindFirstChild("Body")

			if VectorIcon and BodyImage then
				BodyImage = BodyImage:FindFirstChild("Main")
				UIController:ToggleShineEffect(UIObject :: Frame, { VectorIcon, BodyImage })
			end
		end

		local numberToAnimateTo = State:get() == true and scaleGoal or 1

		Spring.target(UIScale, 0.65, 4, {
			Scale = numberToAnimateTo,
		})
	end

	Give(UIObject)({
		[OnEvent("MouseEnter")] = function()
			State:set(true)
			game.SoundService["UI - Hover 1"]:Play()
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
		game.SoundService["UI Click"]:Play()
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

	for _, v in Frames:GetDescendants() do
		if v:IsA("TextButton") or v:IsA("ImageButton") then
			if v.Name ~= "Close" then
				continue
			end

			UIController:ConnectButtonToCallback(v, function()
				local MainFrame = v.Parent.Parent

				UIController:ToggleFrame(MainFrame, false)
			end)
		end
	end
	
	local function AddAnim(Frame: Frame, isBTN: boolean)
		UIController:AddHover(Frame, 1.06)
		
		if isBTN == true then
			UIController:AddClickEffect(Frame.Frame, Frame.Frame.BUY, .95)
		end
		
		if not isBTN then
			UIController:AddClickEffect(Frame, Frame.TextButton, .95)
			
			UIController:ConnectButtonToCallback(Frame.TextButton, function()
				UIController:ToggleFrame(Frame.Name)
			end)
		end
	end
	
	for i, Frame in SideButtons1:GetChildren() do
		if not Frame:IsA("Frame")then
			continue
		end
		if string.find(Frame.Name, "BTN") then
			AddAnim(Frame, true)
		else
			for i, mainFrame in Frame:GetChildren()do
				if not mainFrame:IsA("Frame") then
					continue
				end
				AddAnim(mainFrame, false)
			end
		end
	end
	
	--> 2x Speed Animation
	UIController:AddHover(SideButtons2["2XSPEED"], 1.08)
	UIController:AddClickEffect(SideButtons2["2XSPEED"], SideButtons2["2XSPEED"].BUY, .9)
	
	
	
	--> Conveyor Button Animations
	UIController:AddHover(MainUI.ConveyorBTN, 1.08)
	UIController:AddClickEffect(MainUI.ConveyorBTN, MainUI.ConveyorBTN.TextButton, .9)
	
	UIController:ConnectButtonToCallback(SideButtons1.LevelBTN.Frame.BUY, function()
		MarketPlaceService:PromptProductPurchase(Player, ProductIDs["Skip Level"])
	end)
end

return UIController
