local timeline = {}
local tmcalls = {}
local log = {}
--[[Line 5 will crash you if there is not tween]]
local tween = require("tween")
timeline.verbosity = 4

----------------------------------------------------------------------
--Simple print call to filter messages based on depth and relevance
--context
----------------------------------------------------------------------
local function warn(txt, lvl, trace)
	--[[List of valid error levels]]
	local lvls = {}
	lvls[0] = 'critical'
	lvls[1] = 'error'
	lvls[2] = 'warning'
	lvls[3] = 'info'
	lvls[4] = 'debug'
	lvls[5] = 'verbose'
	local text = tostring(txt)
	local traceback = ''
	local level = 'info'
	if type(lvl) == 'boolean' then
		trace = lvl
	elseif type(lvl) == 'number' then
		level = lvls[lvl] or 'info'
	else
		level = 'info'
	end
	if trace == true then
		traceback = debug.traceback()
	end
	for i,v in ipairs(lvls) do
		if timeline.verbosity >= i then
			if level == lvls[i] then
				print('[TIMELINE]['..level..']:'..text..'\n\n\n'..traceback)
			end
		end
	end
	return
end

------------------------------------------------------------------------
--Call this every update Or when needed it'll update the timeline where
--is called on
------------------------------------------------------------------------
function tmcalls.update(self, dt)
	warn(tostring(self)..':update($dt = '..tostring(dt)..')', 5, false)
	--[[If there's input from Delta add it to the internal clock]]
	if type(dt) == then
		if type(self.clock) == 'number' then
			self.clock = self.clock + dt
		end
	end

	--[[If we have an audio/video source then copy the progress of the source to the clock]]
	if self.source then
		if self.source.tell then
			local success, res = pcall(self.source.tell, self.source)
			clock = tonumber(res)
		end
	end

	--[[TODO: Manage scheduled work]]
	if type(self.eventList) == then
		for i, v in pairs(self.eventList) do
		end
	end
end


-------------------------------------------------------------------------
--This function will edit the clock value for you
--But not update it (call obj:update(dt)) to make effect
-------------------------------------------------------------------------
function tmcalls.setClock(self, newTime)
	warn(tostring(self)..':setClock($newTime = '..tostring(newTime)..')', 5, false)
	if type(newTime) == 'number' then
		self.clock = newTime
	else
		warn([[Error setting the clock manually!
			Reason: $newTime input was not a number.]], 2, true)
	end
end


-------------------------------------------------------------------------
--Add a 'keyframe' object on the timeline where is called on
-------------------------------------------------------------------------
function tmcalls.newEvent(self, start, duration, subject, target, easeFunc, relative)
	warn(tostring(self)..
		':update($start = '..tostring(start)..
		', $duration = '..tostring(duration)..
		', $subject = '..tostring(subject)..
		', $easeFunc = '..tostring(easeFunc)..
		', $relative = '..tostring(relative)..')', 5, false)
	if type(self) == 'table' then
		if type(start) == 'number' then
			if type(duration) == 'number' then
				local newEvent = {
					start = start,
					duration = duration,
					easeFunc = easeFunc or 'lineal',
					subject = subject,
					target = target,
					tween = tween.new(duration, subject, target, easeFunc)
					state = 'waiting',
				}
				if type(relative) == 'boolean' then
					if relative then
						newEvent.duration = start - duration
						newEvent.tween = tween.new(duration, subject, target, easeFunc)
					end
				end
				table.insert(self.eventList, newEvent)
				warn([[New event made.]], 5, true)
				return true
			else
				warn([[New event could not be made!
					Reason: $duration was not a number.]], 2, true)
				return false
			end
		else
			warn([[New event could not be made!
				Reason: $start was not a number.]], 2, true)
			return false
		end
	else
		warn([[New event could not be made!
			Reason: Uknown timeline.]], 2, true)
		return false
	end
end


-----------------------------------------------------------------------
--Debug purposes if something goes wild!
--It gets a number between 0~5
--Zero being the ABSOLUTE *MOST CRITICAL* messages only
--And
--Five being pure traceback madness (Hacker mode)
--
--Also use -1 To get mouth shut (even if is dying)
-----------------------------------------------------------------------
function tmcalls.setVerbosity(self, value)
	warn('timeline.setVerbosity($value = '..tostring(value)..')', 5, false)
	if type(value) == 'number' then
		if value >= -1 then
			if value <= 5 then
				timeline.verbosity = value
			else
				warn([[Verbosity could not be set!
					Reason: Number to high]], 2, true)
			end
		else
			warn([[Verbosity could not be set!
				Reason: Number to low]], 2, true)
		end
	else
		warn([[Verbosity could not be set!
			Reason: $value was not a number]], 2, true)
	end
end

----------------------------------------------------------------------
--This sets how long it takes to a timeline to be 'considered' done
----------------------------------------------------------------------
function tmcalls.setDuration(self, duration)
	warn(tostring(self)..':setDuration($duration = '..tostring(duration)..')', 5, false)
	if type(duration) == 'number' then
			self.duration = duration
		if duration > 0 then
			return
		else
			warn([[timeline.setDuration() was called with a negative number,
				this could be lethal execution-wise!]], 3, false)
		end
	else
		warn([[setDuration could not continue!
			Reason: $duration was not a number.]], 2, true)
	end
end

------------------------------------------------------------------------
--Get a value or warn about it
------------------------------------------------------------------------
function tm.getValue(self, target)
	warn(tostring(self)..':getValue($target = '..tostring(target)..')')
	for k, v in pairs(self) do
		if k == target then
			return v
		end
	end
	warn([[getValue() could not continue!
		Reason: $target was not found.]], 2, true)
	return nil
end

-----------------------------------------------------------------------
--Fancy var = value wrapper
-----------------------------------------------------------------------
function tm.setValue(self, target, value)
	warn(tostring(self)..':setValue($target = '..tostring(target)..')')
	for k, v in pairs(self) do
		if k == target then
			v = value
		end
	end
end

------------------------------------------------------------------------
--Call this to make a timeline where to put your 'keyframes' objects
------------------------------------------------------------------------
function timeline.newTimeline(duration)
	return {
		clock = 0,
		duration = duration or 10,
		eventList = {},
		update = tmcalls.update,
		set = tmcalls.set,
		reset = tmcalls.reset,
		new = tmcalls.new,
		draw = tmcalls.draw,
		getValue = tmcalls.getValue,
		setDuration = tmcalls.setDuration,
		setVerbosity = tmcalls.setVerbosity,
		attachSource = tmcalls.attachSource,
		detachSource = tmcalls.detachSource,
	},
	true
end