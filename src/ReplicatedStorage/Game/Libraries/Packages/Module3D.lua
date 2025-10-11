local FAR_POSITION = Vector3.new(0,10000,0)
local Module3D = {}
function Module3D.new(Model)
	local CFrameOffset = CFrame.new()
	local DepthMultiplier = 1
	
	local Model3D = {}
	Model3D.Object3D = Model
	
	if Model:IsA("BasePart") then
		local NewModel = Instance.new("Model")
		NewModel.Name = "Model3D"
		Model.Parent = NewModel
		NewModel.PrimaryPart = Model
		
		Model = NewModel
		Model3D.Object3D = Model
	end
	
	local ViewportFrame = Instance.new("ViewportFrame")
	ViewportFrame.BackgroundTransparency = 1
	Model3D.AdornFrame = ViewportFrame
	
	local Camera = Instance.new("Camera")
	Camera.Parent = ViewportFrame
	ViewportFrame.CurrentCamera = Camera
	
	local BasePrimaryPart = Model.PrimaryPart
	if not BasePrimaryPart then
		Model.PrimaryPart = Model:FindFirstChildWhichIsA("BasePart",true)
	end
	
	if Model.PrimaryPart then
		Model:SetPrimaryPartCFrame(CFrame.new(FAR_POSITION - Model.PrimaryPart.Position) * Model.PrimaryPart.CFrame)
		Model.PrimaryPart = BasePrimaryPart
	end
	Model.Parent = ViewportFrame
	local function UpdateCFrame()
		local BoundingCFrame,BoundingSize = Model:GetBoundingBox()
		local ModelCenter = BoundingCFrame.p
		
		--Determine the distance back.
		local MaxSize = math.max(BoundingSize.X,BoundingSize.Y,BoundingSize.Z)
		local DistanceBack = ((MaxSize/math.tan(math.rad(Camera.FieldOfView)))) * DepthMultiplier
		local Center = CFrame.new(ModelCenter)
		Camera.CFrame = Center * CFrameOffset * CFrame.new(0,0,(MaxSize/2) + DistanceBack)
		Camera.Focus = Center
	end
	
	function Model3D:Update()
		UpdateCFrame()
	end
	
	function Model3D:SetActive(Active)
		ViewportFrame.Visible = Active
	end
	
	function Model3D:GetActive()
		return ViewportFrame.Visible
	end
	
	function Model3D:SetCFrame(NewCF)
		CFrameOffset = NewCF
		UpdateCFrame()
	end
	
	function Model3D:GetCFrame()
		return CFrameOffset
	end
	
	function Model3D:SetDepthMultiplier(Multiplier)
		DepthMultiplier = Multiplier
		UpdateCFrame()
	end
	
	function Model3D:GetDepthMultiplier()
		return DepthMultiplier
	end
	
	function Model3D:Destroy()
		self.AdornFrame:Destroy()
		self.Object3D:Destroy()
	end
	
	function Model3D:End()
		self:Destroy()
	end
	
	local Metatable = {}
	setmetatable(Model3D,Metatable)
	Metatable.__index = function(self,Index)
		if Index == "Camera" then
			return ViewportFrame.CurrentCamera
		end
		
		local ObjectValue = rawget(Model3D,Index)
		if ObjectValue ~= nil then
			return ObjectValue
		end
		
		return ViewportFrame[Index]
	end
	Metatable.__newindex = function(self,Index,NewValue)
		ViewportFrame[Index] = NewValue
	end
	
	UpdateCFrame()
	return Model3D
end

function Module3D:Attach3D(Frame,Model, FixedSize)
	local Model3D = Module3D.new(Model)
	Model3D.AnchorPoint = Vector2.new(0.5,0.5)
	Model3D.Position = UDim2.new(0.5,0,0.5,0)
	Model3D.Visible = false
	Model3D.Parent = Frame
	
	local function UpdateFrameSize()
		local AbsoluteSize = Frame.AbsoluteSize
		local MinSize = math.abs(math.min(AbsoluteSize.X,AbsoluteSize.Y)) 
		Model3D.AdornFrame.Size = FixedSize or UDim2.new(0,MinSize,0,MinSize)
	end
	local FrameChanged = Frame.Changed:Connect(UpdateFrameSize)
	UpdateFrameSize()
	
	local BaseDestroy = Model3D.Destroy
	local function NewDesstroy(self)
		BaseDestroy(self)
		
		if FrameChanged then
			FrameChanged:Disconnect()
			FrameChanged = nil
		end
	end
	rawset(Model3D,"Destroy",NewDesstroy)
	
	return Model3D
end



return Module3D