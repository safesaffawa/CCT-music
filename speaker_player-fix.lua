-- CC: Tweaked Speaker Player
-- Official documentation: https://tweaked.cc/peripheral/speaker.html#v:playNote
--
-- Note: 
-- Pitch argument uses semitones as the unit
-- 0, 12, 24 map to F#
-- 6, 18 map to C

-- Find speaker peripheral
local speaker = peripheral.find("speaker")
if not speaker then
    print("Error: No speaker peripheral found")
    return
end

-- Available instrument list
local instruments = {
    "harp", "basedrum", "snare", "hat", "bass",
    "flute", "bell", "guitar", "chime", "xylophone"
}

-- Note to semitone mapping
local noteToSemitone = {
    -- Octave 0
    ["F#0"] = 0, ["G0"] = 1, ["G#0"] = 2, ["A0"] = 3, ["A#0"] = 4, ["B0"] = 5,
    
    -- Octave 1
    ["C1"] = 6, ["C#1"] = 7, ["D1"] = 8, ["D#1"] = 9, ["E1"] = 10, ["F1"] = 11, 
    ["F#1"] = 12, ["G1"] = 13, ["G#1"] = 14, ["A1"] = 15, ["A#1"] = 16, ["B1"] = 17,
    
    -- Octave 2
    ["C2"] = 18, ["C#2"] = 19, ["D2"] = 20, ["D#2"] = 21, ["E2"] = 22, ["F2"] = 23, 
    ["F#2"] = 24, ["G2"] = 25, ["G#2"] = 26, ["A2"] = 27, ["A#2"] = 28, ["B2"] = 29,
    
    -- Octave 3
    ["C3"] = 30, ["C#3"] = 31, ["D3"] = 32, ["D#3"] = 33, ["E3"] = 34, ["F3"] = 35, 
    ["F#3"] = 36, ["G3"] = 37, ["G#3"] = 38, ["A3"] = 39, ["A#3"] = 40, ["B3"] = 41,
    
    -- Octave 4 (Middle C)
    ["C4"] = 42, ["C#4"] = 43, ["D4"] = 44, ["D#4"] = 45, ["E4"] = 46, ["F4"] = 47, 
    ["F#4"] = 48, ["G4"] = 49, ["G#4"] = 50, ["A4"] = 51, ["A#4"] = 52, ["B4"] = 53,
    
    -- Octave 5
    ["C5"] = 54, ["C#5"] = 55, ["D5"] = 56, ["D#5"] = 57, ["E5"] = 58, ["F5"] = 59, 
    ["F#5"] = 60, ["G5"] = 61, ["G#5"] = 62, ["A5"] = 63, ["A#5"] = 64, ["B5"] = 65
}

-- Helper function to check if value exists in table
local function tableContains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Play single note
-- @param instrument string Instrument name
-- @param volume number Volume (0.0 - 3.0)
-- @param pitch number|string Pitch (semitone value or note string)
local function playNote(instrument, volume, pitch)
    -- Convert note string to semitone
    if type(pitch) == "string" then
        pitch = noteToSemitone[pitch]
        if not pitch then
            print("Error: Invalid note " .. pitch)
            return false
        end
    end
    
    -- Validate parameters
    if not tableContains(instruments, instrument) then
        print("Error: Invalid instrument " .. instrument)
        return false
    end
    
    if volume < 0 or volume > 3.0 then
        print("Error: Volume out of range (0.0-3.0)")
        return false
    end
    
    if pitch < 0 or pitch > 65 then
        print("Error: Pitch out of range (0-65)")
        return false
    end
    
    -- Play the note
    return speaker.playNote(instrument, volume, pitch)
end

-- Play note sequence
-- @param sequence table Note sequence (each element is {instrument, volume, pitch})
-- @param delay number Delay between notes (seconds)
local function playSequence(sequence, delay)
    for _, note in ipairs(sequence) do
        local instrument, volume, pitch = table.unpack(note)
        if playNote(instrument, volume, pitch) then
            sleep(delay or 0.5)
        else
            print("Playback failed")
            break
        end
    end
end

-- Stop all sounds
local function stopAllSounds()
    speaker.stop() -- Stop all playing sounds
end

-- ===== Example Usage =====

-- Example 1: Play single notes
print("Playing single notes...")
playNote("harp", 1.0, 12)      -- Using semitone value (F#1)
playNote("bell", 1.5, "C4")    -- Using note name (Middle C)
sleep(1)

-- Example 2: Play scale
print("Playing scale...")
local scale = {
    {"harp", 1.0, "C4"},
    {"harp", 1.0, "D4"},
    {"harp", 1.0, "E4"},
    {"harp", 1.0, "F4"},
    {"harp", 1.0, "G4"},
    {"harp", 1.0, "A4"},
    {"harp", 1.0, "B4"},
    {"harp", 1.0, "C5"}
}
playSequence(scale, 0.3)
sleep(1)

-- Example 3: Play jingle
print("Playing jingle...")
local jingle = {
    {"bell", 1.5, "E4"},
    {"bell", 1.5, "E4"},
    {"bell", 1.5, "E4"},
    {"bell", 1.5, "C4"},
    {"bell", 1.5, "E4"},
    {"bell", 1.5, "G4"},
    {"bell", 2.0, "G3"}
}
playSequence(jingle, 0.4)
sleep(1)

-- Example 4: Play drum beat
print("Playing drum beat...")
local drumBeat = {
    {"basedrum", 2.0, 0},  -- F#0
    {"snare", 1.5, 0},     -- F#0
    {"hat", 1.0, 0},       -- F#0
    {"basedrum", 2.0, 0},  -- F#0
    {"hat", 1.0, 0},       -- F#0
    {"snare", 1.5, 0},     -- F#0
    {"hat", 1.0, 0},       -- F#0
}
playSequence(drumBeat, 0.2)

print("Playback complete")