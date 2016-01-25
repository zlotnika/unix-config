-- http://www.jonathanlaliberte.com/2010/03/15/itunes-sleep-timer-with-fade-out-applescript/

    property lastSleepLength : 5
    property fade_for_minutes : 10

    global endTime, initialVolume

    on idle
    -- Wait until fade_for_minutes before the end time
    -- Then call fade_sound which will fade the sound, pause itunes, and reset the volume
    set curTime to current date
    if ((curTime + (fade_for_minutes * 60)) ≥ endTime) then
    my fade_sound()
    quit me
    end if
    return 1
    end idle

    on run
    try
    set endTime to (current date) + getSleepLength()
    tell application "iTunes" to set initialVolume to sound volume

    on error number -128
    -- user canceled
    quit me
    end try
    end run

    on fade_sound()
    set timeBetweenDecreases to ((fade_for_minutes * 60) / initialVolume)
    repeat with i from 0 to initialVolume
    delay timeBetweenDecreases
    tell application "iTunes" to set the sound volume to (sound volume) - 1
    end repeat
    my iTunesReset()
    end fade_sound

    -- Pause iTunes and reset volume
    on iTunesReset()
    tell application "Finder"
    if process "iTunes" exists then
    tell application "iTunes"
    if player state is playing then
    pause
    end if
    set the sound volume to initialVolume
    end tell
    end if
    end tell
    end iTunesReset

    -- gets the amount of minutes till we go to sleep
    on getSleepLength()
    repeat
    set dialogResult to display dialog "How many minutes till we go to Sleep?" default answer lastSleepLength
    try
    if text returned of the dialogResult is not "" then
    set sleepLength to text returned of dialogResult as number
    exit repeat
    end if
    beep
    end try
    end repeat

    set lastSleepLength to sleepLength

    return (sleepLength * 60) -- Return in seconds
    end getSleepLength
