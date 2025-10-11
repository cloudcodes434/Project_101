-- // Services -- \\
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- // Variables -- \\
local Modules = ReplicatedStorage:WaitForChild("Game")
local Libraries = Modules:WaitForChild("Libraries")
local NetworkFolder = Libraries:WaitForChild("Network")
local Packets = NetworkFolder:WaitForChild("Packets")
local Packages = Libraries:WaitForChild("Packages")

-- // Modules -- \\
local Promise = require(Packages:WaitForChild("Promise"))

-- // Static Variables -- \\

local Library = {
	Modules = {},
}

local Services = {}
local Controllers = {}
local Networking = {
	Packets = {},
}

function Library:LoadResources()
	local function Add(Container, Module: ModuleScript)
		if not Module:IsA("ModuleScript") then
			return
		end
		local loaded = require(Module)
		Container[Module.Name] = loaded
	end

	-- // LOAD INFORMATION -- \\
	for _, v in script:GetChildren() do
		if not Library.Modules[v.Name] then
			Library.Modules[v.Name] = {}
		end

		for _, module in v:GetChildren() do
			Add(Library.Modules[v.Name], module)
		end
	end

	-- // Load Packets (Networking) -- \\

	for _, v in Packets:GetChildren() do
		if not v:IsA("ModuleScript") then
			return
		end

		local packetContents = require(v)

		if typeof(packetContents) ~= "table" then
			continue
		end

		for packetName, packet in packetContents do
			if Networking.Packets[packetName] then
				Library:Debug(string.format("There already exists a packet with name %s", packetName))
				continue
			end
			Networking.Packets[packetName] = packet
		end
	end

	return true
end

function Library:Debug(debugMsg: string)
	if Library.Modules["Global"].DEBUG_ENABLED == false then
		return
	end

	local serverType = RunService:IsServer() and "SERVER" or "CLIENT"
	if RunService:IsStudio() then
		serverType = "STUDIO"
	end

	warn("[" .. serverType .. " DEBUG]:", debugMsg)
end

function Library:InitDataLoad() end

function Library:LoadServices(Container)
	if not Container or not Container:IsA("Folder") then
		return
	end

	local FolderContents = Container:GetDescendants()

	for _, Service in FolderContents do
		local serviceName = Service.Name
		if not Service:IsA("ModuleScript") then
			continue
		end

		local LoadedService = require(Service)

		if Services[serviceName] then
			Library:Debug(string.format("A service already exist with the name %s", serviceName))
			return
		end
		Services[serviceName] = LoadedService

		if LoadedService.Init then
			task.spawn(LoadedService.Init, LoadedService)
		end
	end
end

function Library:Fire(packet: string, target, ...)
	if typeof(packet) ~= "string" then
		Library:Debug(string.format("The forwarded type to function :%s() ; is not a string", "ConnectToPacket"))
		return
	end

	local packetContent = Networking.Packets[packet]
	if not packetContent or packetContent == nil then
		Library:Debug(
			string.format("The function :%s() ; failed as it could not find packet %s", "ConnectToPacket", packet)
		)
		return
	end
	local isServer = RunService:IsServer()
	if target or isServer then
		if typeof(target) == "table" then
			for _, Player: Player in target do
				if not Player:IsA("Player") then
					Library:Debug(string.format("The passed table does not contain a table; Packet %s", packet))
					return
				end
				Library:Fire(packet, Player, ...)
			end
		else
			if target:IsA("Player") then
				Library:Debug(string.format("Packet sent to %s, packet name: %s", target.Name, packet))
				packetContent:FireClient(target, ...)
			end

			return true
		end
		return true
	end

	packetContent:Fire(...)
	return true
end

function Library:ConnectToPacket(packet: string, func: (any) -> ())
	if typeof(packet) ~= "string" then
		Library:Debug(string.format("The forwarded type to function :%s() ; is not a string", "ConnectToPacket"))
		return
	end

	if typeof(func) ~= "function" then
		local formattedString = string.format("The forwarded function is not function type %s", "ConnectToPacket")
		Library:Debug(formattedString)
		return
	end

	local packetContent = Networking.Packets[packet]
	if not packetContent or packetContent == nil then
		Library:Debug(
			string.format("The function :%s() ; failed as it could not find packet %s", "ConnectToPacket", packet)
		)
		return
	end

	local isServer = RunService:IsServer()
	local functionForWait = isServer and packetContent.OnServerEvent or packetContent.OnClientEvent

	if not functionForWait then
		return
	end

	functionForWait:Connect(function(...)
		task.spawn(func, ...)
	end)
end

function Library:LoadControllers(Container: Folder)
	if not Container or not Container:IsA("Folder") then
		return
	end

	local FolderContents = Container:GetDescendants()

	for _, Controller in FolderContents do
		local controllerName = Controller.Name
		if not Controller:IsA("ModuleScript") then
			continue
		end

		local LoadedController = require(Controller)

		if Controllers[controllerName] then
			Library:Debug(string.format("A controller already exist with the name %s", controllerName))
			return
		end
		Controllers[controllerName] = LoadedController

		if LoadedController.Init then
			task.spawn(LoadedController.Init, LoadedController)
		end
	end
end

function Library:LoadDesiredSystems(Folder: Folder)
	local isServer = RunService:IsServer()

	local functionToRun = isServer and "LoadServices" or "LoadControllers"

	-- // Run the function for loading controllers/services -- \\
	Library[functionToRun](Library, Folder)

	local container = isServer and Services or Controllers

	for _: string, controller: { Start: (any) -> () } in container do
		if controller.Start then
			controller:Start()
		end
	end
end

function Library:GetService(serviceName: string, yieldEnabled: boolean?)
	if not RunService:IsServer() then
		return {}
	end

	if Services[serviceName] then
		return Services[serviceName]
	end

	if not yieldEnabled then
		return
	end
	
	task.wait()
	return Library:GetService(serviceName, yieldEnabled)
end

function Library:GetController(controllerName: string, yieldEnabled: boolean?)
	if RunService:IsServer() then
		return {}
	end

	if Controllers[controllerName] then
		return Controllers[controllerName]
	end

	if not yieldEnabled then
		return
	end
	
	task.wait()
	return Library:GetController(controllerName, yieldEnabled)
end

function Library:Init(folderToLoad: Folder)
	return Promise.new(function(resolve)
		Library:LoadResources()
		Library:LoadDesiredSystems(folderToLoad)

		return resolve()
	end)
end
return Library
