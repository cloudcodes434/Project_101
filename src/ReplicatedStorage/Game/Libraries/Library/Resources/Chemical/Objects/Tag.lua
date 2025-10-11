local module = {}

--local tags = {}
--function module.Tag(chemical: Value | Computed | Observer, tag: string)
--	local tagEntity = tags[tag]
--	if not tagEntity then
--		tagEntity = Data:entity()
--		Data:add(tagEntity, Tag)
--		tags[tag] = tagEntity
--	end

--	Data:add(chemical.__entity, tagEntity)
--end

--function module.Tagged(tag: string): { Value | Computed | Observer }
--	local tagEntity = tags[tag]
--	if not tagEntity then return end

--	local chemicals = {}
--	for e in Data:query(Chemical):with(tagEntity) do
--		local object = Data:get(e, Object)
--		table.insert(chemicals, object)
--	end

--	return chemicals
--end

return module
