local VFXDuration = 0.5-- How long your VFX lasts, will only start trying to emit again after this duration is finished
local EmitChance = 1 -- 1 in N
local ChanceWait = 0.3 -- waits before rolling the chance again

while true do
	local emitchance = math.random(1, EmitChance)

	--print(EmitChance)
	task.wait(ChanceWait)
	if emitchance ~= 1 then


	else


		-- Emitter stuff
		for i, v in script.Parent:GetDescendants() do
			if not v:IsA("ParticleEmitter") then continue end

			task.spawn(function()
				task.wait(v:GetAttribute("EmitDelay"))

				task.spawn(function()
					v.Enabled = true
					task.delay(v:GetAttribute("EmitDuration"), function()
						v.Enabled = false
					end)

					v:Emit(v:GetAttribute("EmitCount"))
				end)
			end)
		end


		-- Beam stuff
		for i, v in script.Parent:GetDescendants() do
			if not v:IsA("Beam") then continue end

			task.spawn(function()
				task.wait(v:GetAttribute("EmitDelay"))

				v.Enabled = true
				task.delay(v:GetAttribute("EmitDuration"), function()
					v.Enabled = false
				end)
			end)
		end


		-- Trail stuff
		for i, v in script.Parent:GetDescendants() do
			if not v:IsA("Trail") then continue end

			task.spawn(function()
				task.wait(v:GetAttribute("EmitDelay"))

				v.Enabled = true
				task.delay(v:GetAttribute("EmitDuration"), function()
					v.Enabled = false
				end)
			end)
		end


		-- Sound stuff
		for i, v in script.Parent:GetDescendants() do
			if not v:IsA("Sound") then continue end

			task.spawn(function()
				task.wait(v:GetAttribute("Delay"))
				v:Play()
			end)
		end

		task.wait(VFXDuration) -- Waits until you VFX is finished emitting to try and emit again
	end
end
