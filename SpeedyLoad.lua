local pairs, wipe, select = pairs, wipe, select
local GetFramesRegisteredForEvent = GetFramesRegisteredForEvent
local enteredOnce, listenForUnreg
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
local occured = {}
local events = {
	SPELLS_CHANGED = {},
	USE_GLYPH = {},
	PET_TALENT_UPDATE = {},
	WORLD_MAP_UPDATE = {},
	UPDATE_WORLD_STATES = {},
	VEHICLE_UPDATE = {},
	CRITERIA_UPDATE = {},
	RECEIVED_ACHIEVEMENT_LIST = {},
	ACTIONBAR_SLOT_CHANGED = {},
	ACTIONBAR_SLOT_CHANGED = {},
}
local function unregister(event, ...)
	for i = 1, select("#", ...) do
		local frame = select(i, ...)
		frame:UnregisterEvent(event)
		events[event][frame] = 1
	end
end
local function onupdate()
	listenForUnreg = nil
	for event, frames in pairs(events) do
		for frame in pairs(frames) do
			frame:RegisterEvent(event)
			local OnEvent = occured[event] and frame:GetScript("OnEvent")
			if OnEvent then
				local arg1
				if event == "ACTIONBAR_SLOT_CHANGED" then
					arg1 = 0
				end
				OnEvent(frame, event, arg1)
			end
			frames[frame] = nil
		end
	end
	wipe(occured)
	f:SetScript("OnUpdate", nil)
end

f:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_ENTERING_WORLD" then
			if not enteredOnce then
				f:RegisterEvent("PLAYER_LEAVING_WORLD")

				hooksecurefunc(getmetatable(f).__index, "UnregisterEvent", function(frame, event)
						if listenForUnreg then
							local frames = events[event]
							if frames then
								frames[frame] = nil
							end
						end
				end)
				enteredOnce = 1
			else
				f:SetScript("OnUpdate", onupdate)
			end
		elseif event == "PLAYER_LEAVING_WORLD" then
			wipe(occured)
			for event in pairs(events) do
				f:RegisterEvent(event)
				unregister(event, GetFramesRegisteredForEvent(event))
			end
			listenForUnreg = 1
		else
			occured[event] = 1
			f:UnregisterEvent(event)
		end
end)