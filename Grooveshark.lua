scriptId = 'com.exa.grooveshark'
description = [[
Grooveshark Contoller based on PaulBernhardt Slacker

No need for a plugin it uses the default Grooveshark shortcuts.

Controls:
- thumbToPinky, to enable controls (automatically locks)
- Wave left/right to next/prev tracks
- Fist to play/pause

]]
active = false
locked = true
appTitle = ""
ENABLED_TIMEOUT = 5200
UNLOCK_HOLD_DURATION = 400

unlocking = 0


function onForegroundWindowChange(app, title)
    -- myo.debug("onForegroundWindowChange: " .. app .. ", " .. title)
	local foundGrooveshark = string.match(title, "^Grooveshark") ~= nil 
	if (foundGrooveshark) then
		appTitle = title
		myo.debug("Grooveshark controls now active")
	else
		myo.debug("Grooveshark controls now inactive")
	end
    return foundGrooveshark or active
end

function activeAppName()
	return appTitle
end

function onPoseEdge(pose, edge)
	pose = conditionallySwapWave(pose)
	if (edge == "on") then
		if (pose == "thumbToPinky") then
			unlocking = myo.getTimeMilliseconds()
			--toggleLock()
		elseif (not locked) then
			myo.debug("onPoseEdge: " .. pose .. ": " .. edge)
			if (pose == "waveOut") then
				onWaveOut()		
				extendUnlock()
			elseif (pose == "fist") then
				onFist()		
				extendUnlock()
			elseif (pose == "waveIn") then
				onWaveIn()
				extendUnlock()
			elseif (pose == "fingersSpread") then
				onFingersSpread()			
				extendUnlock()
			end
		end
	end
end

function onPeriodic()
    local now = myo.getTimeMilliseconds()
	if (unlocking > 0 and now > unlocking + UNLOCK_HOLD_DURATION) then
		toggleLock()
		unlocking = 0
		return
	end
    if not locked then
        if (now - enabledSince) > ENABLED_TIMEOUT then
            toggleLock()
        end
    end
end

function toggleLock()
	locked = not locked
	-- myo.vibrate("short")
	if (not locked) then
		-- Vibrate twice on unlock
		myo.debug("Unlocked")
		myo.vibrate("short")
		enabledSince = myo.getTimeMilliseconds()
	else 
		myo.debug("Locked")
	end
end

function onWaveOut()
	myo.debug("Next")
	myo.keyboard("right_arrow","press","control")
end

function onWaveIn()
	myo.debug("Previous")
	myo.keyboard("left_arrow","press","control")
end

function onFist()
	myo.debug("Play/Pause")
	myo.keyboard("spacebar", "press")
end

function conditionallySwapWave(pose)
	if myo.getArm() == "left" then
        if pose == "waveIn" then
            pose = "waveOut"
        elseif pose == "waveOut" then
            pose = "waveIn"
        end
    end
    return pose
end

function extendUnlock()
    local now = myo.getTimeMilliseconds()
    enabledSince = now
end