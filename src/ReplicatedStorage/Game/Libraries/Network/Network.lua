local Packet = require(script:WaitForChild("Packet"))

return {
	BallPhysics = {
		BallPosUpdate = Packet("BallPosUpdate",
			Packet.Any
		),
	},
	Throw = Packet("Throw", Packet.Instance, Packet.Vector3F24, Packet.NumberF16),
	Random = Packet("Hi", Packet.Any)
	
	
}