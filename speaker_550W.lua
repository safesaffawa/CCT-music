-- MIDI Player for CC: Tweaked
-- 完整实现所有提供的 MIDI 事件
-- 时间精度: 480 ticks/beat (120 BPM)

local speaker = peripheral.find("speaker")
if not speaker then
    print("Error: No speaker peripheral found")
    return
end

-- 音符名到半音的映射表
local noteToSemitone = {
    -- 八度 0
    ["F#0"] = 0, ["G0"] = 1, ["G#0"] = 2, ["A0"] = 3, ["A#0"] = 4, ["B0"] = 5,
    -- 八度 1
    ["C1"] = 6, ["C#1"] = 7, ["D1"] = 8, ["D#1"] = 9, ["E1"] = 10, ["F1"] = 11, 
    ["F#1"] = 12, ["G1"] = 13, ["G#1"] = 14, ["A1"] = 15, ["A#1"] = 16, ["B1"] = 17,
    -- 八度 2
    ["C2"] = 18, ["C#2"] = 19, ["D2"] = 20, ["D#2"] = 21, ["E2"] = 22, ["F2"] = 23, 
    ["F#2"] = 24, ["G2"] = 25, ["G#2"] = 26, ["A2"] = 27, ["A#2"] = 28, ["B2"] = 29,
    -- 八度 3
    ["C3"] = 30, ["C#3"] = 31, ["D3"] = 32, ["D#3"] = 33, ["E3"] = 34, ["F3"] = 35, 
    ["F#3"] = 36, ["G3"] = 37, ["G#3"] = 38, ["A3"] = 39, ["A#3"] = 40, ["B3"] = 41,
    -- 八度 4 (中央C)
    ["C4"] = 42, ["C#4"] = 43, ["D4"] = 44, ["D#4"] = 45, ["E4"] = 46, ["F4"] = 47, 
    ["F#4"] = 48, ["G4"] = 49, ["G#4"] = 50, ["A4"] = 51, ["A#4"] = 52, ["B4"] = 53,
    -- 八度 5
    ["C5"] = 54, ["C#5"] = 55, ["D5"] = 56, ["D#5"] = 57, ["E5"] = 58, ["F5"] = 59, 
    ["F#5"] = 60, ["G5"] = 61, ["G#5"] = 62, ["A5"] = 63, ["A#5"] = 64, ["B5"] = 65
}

-- 轨道到乐器的映射
local trackInstruments = {
    [2] = "harp",   -- 主旋律
    [3] = "bell",   -- 高音伴奏
    [4] = "bass",   -- 低音
    [5] = "bass",   -- 低音
    [6] = "flute",  -- 副旋律
    [7] = "guitar", -- 和声
    [8] = "harp",   -- 伴奏
    [9] = "harp",   -- 伴奏
    [10] = "basedrum" -- 鼓点
}

-- 播放单个音符
local function playNote(track, note, velocity)
    local instrument = trackInstruments[track] or "harp"
    local volume = velocity / 127 * 3.0
    local pitch = noteToSemitone[note]
    
    if pitch then
        return speaker.playNote(instrument, volume, pitch)
    else
        -- 处理数字音高（直接使用）
        return speaker.playNote(instrument, volume, tonumber(note) or 0)
    end
end

-- 解析MIDI事件字符串为Lua表
local function parseMidiEvents(midiText)
    local events = {}
    local currentTrack = nil
    local currentTime = 0
    
    for line in midiText:gmatch("[^\r\n]+") do
        -- 检测轨道标题
        local trackMatch = line:match("轨道 #(%d+)")
        if trackMatch then
            currentTrack = tonumber(trackMatch)
            currentTime = 0
        elseif currentTrack then
            -- 解析事件行
            local time, action, note, velocity = line:match("%[(%d+)%] (%a+) (%S+) v(%d+)")
            if time then
                time = tonumber(time)
                currentTime = currentTime + time
                table.insert(events, {
                    time = currentTime,
                    track = currentTrack,
                    action = action,
                    note = note,
                    velocity = tonumber(velocity)
                })
            end
        end
    end
    
    return events
end

-- 提供的MIDI数据
local midiText = [[
轨道 #2
[39667] ON C#5 v100
[29] ON E4 v100
[10] ON C#4 v100
[9] ON G#4 v100
[1571] OFF C#5
[0] OFF E4
[0] OFF C#4
[0] OFF G#4
[11965] ON E4 v100
[125] ON A4 v100
[96] ON F#4 v100
[115] OFF E4
[0] ON E4 v100
[125] ON C#4 v100
[96] ON B3 v100
[115] ON F#3 v100
[115] ON B2 v100
[1011] OFF A4
[0] OFF F#4
[0] OFF E4
[0] OFF C#4
[0] OFF B3
[0] OFF F#3
[0] OFF B2
[160490] ON C#3 v100
[259] ON C#4 v100
[464] OFF C#3
[0] OFF C#4

轨道 #3
[151114] ON G#4 v100
[270] OFF G#4
[15003] ON C#5 v100
[725] OFF C#5
[94382] ON C#5 v100
[615] OFF C#5
[9] ON C#5 v100
[759] OFF C#5
[9] ON C#5 v100
[561] OFF C#5

轨道 #4
[186893] ON G#2 v100
[230] OFF G#2
[10] ON G#2 v100
[249] OFF G#2
[0] ON G#2 v100
[125] OFF G#2
[0] ON G#2 v100
[135] OFF G#2
[9] ON G#2 v100
[106] OFF G#2
[0] ON G#2 v100
[134] OFF G#2
[10] ON G#2 v100
[249] OFF G#2
[0] ON G#2 v100
[135] OFF G#2
[0] ON G#2 v100
[125] OFF G#2
[9] ON G#2 v100
[125] OFF G#2
[0] ON G#2 v100
[115] OFF G#2
[10] ON G#2 v100
[69] OFF G#2

轨道 #5
[59165] ON A2 v100
[1782] OFF A2
[39066] ON A2 v100
[254] OFF A2

轨道 #6
[5357] ON E5 v100
[0] ON G#5 v100
[0] ON C#6 v100
[3648] OFF C#6
[38] ON F#5 v100
[0] ON D#6 v100
[77] OFF E5
[0] OFF G#5
[3581] OFF F#5
[0] OFF D#6
[0] ON E5 v100
[0] ON G#5 v100
[0] ON C#6 v100
[3027] OFF G#5
[2445] OFF E5
[0] OFF C#6
[0] ON C#5 v100
[0] ON E5 v100
[0] ON C#6 v100
[0] ON C#7 v100
[163] OFF E5
[0] OFF C#6
[0] OFF C#7
[739] OFF C#5
[0] ON E5 v100
[0] ON E6 v100
[585] OFF E6
[394] OFF E5
[0] ON C#4 v100
[0] ON C#5 v100
[20] ON F#4 v100
[0] ON A4 v100
[902] OFF C#4
[0] OFF C#5
[0] ON D#4 v100
[0] ON D#5 v100
[922] ON C#4 v100
[0] ON C#5 v100
[28] OFF D#4
[0] OFF D#5
[922] ON D#4 v100
[0] ON D#5 v100
[19] OFF C#4
[0] OFF C#5
[960] OFF D#4
[0] OFF D#5
[0] ON C#4 v100
[0] ON E4 v100
[0] ON G#4 v100
[0] ON C#5 v100
[39] OFF F#4
[0] OFF A4
[902] OFF C#4
[0] OFF C#5
[0] ON E5 v100
[922] ON C#4 v100
[0] ON C#5 v100
[38] OFF E5
[845] ON E5 v100
[9] OFF C#5
[39] OFF C#4
[903] OFF E5
[38] ON F#4 v100
[0] ON A4 v100
[0] ON C#5 v100
[38] OFF E4
[0] OFF G#4
[826] ON D#4 v100
[0] ON D#5 v100
[9] OFF C#5
[912] ON C#4 v100
[0] ON C#5 v100
[29] OFF D#5
[10] OFF D#4
[950] OFF F#4
[0] OFF A4
[0] OFF C#4
[0] OFF C#5
[0] ON D#4 v100
[0] ON F#4 v100
[0] ON A4 v100
[0] ON D#5 v100
[931] OFF D#4
[0] OFF F#4
[0] OFF A4
[0] OFF D#5
[0] ON E4 v100
[0] ON G#4 v100
[0] ON C#5 v100
[912] ON E5 v100
[29] OFF C#5
[10] ON E6 v100
[844] OFF E5
[10] ON C#5 v100
[10] OFF E6
[9] ON C#4 v100
[960] OFF C#5
[0] ON E5 v100
[10] OFF C#4
[893] ON F#4 v100
[9] OFF E4
[0] ON C#4 v100
[0] ON A4 v100
[10] ON C#5 v100
[9] OFF G#4
[0] OFF E5
[922] ON D#4 v100
[0] ON D#5 v100
[48] OFF C#4
[0] OFF C#5
[787] ON C#4 v100
[0] ON C#5 v100
[19] OFF D#5
[10] OFF D#4
[941] OFF C#5
[0] ON D#5 v100
[67] OFF C#4
[0] ON D#4 v100
[912] OFF D#5
[0] ON C#2 v100
[0] ON C#3 v100
[0] ON C#5 v100
[19] OFF D#4
[10] OFF F#4
[0] OFF A4
[9] ON E4 v100
[0] ON G#4 v100
[980] OFF C#5
[9] ON E5 v100
[807] OFF E5
[9] ON C#5 v100
[903] OFF C#5
[19] ON E5 v100
[19] OFF E4
[0] ON E4 v100
[845] OFF C#3
[0] ON C#3 v100
[19] ON G#3 v100
[10] OFF E4
[0] ON E4 v100
[9] OFF G#4
[0] OFF E5
[10] ON C#4 v100
[9] ON C#5 v100
[10] ON F#4 v100
[10] ON F#2 v100
[9] ON F#3 v100
[10] ON A3 v100
[48] OFF C#2
[0] OFF G#3
[0] OFF E4
[791] OFF C#3
[73] OFF C#5
[9] ON D#5 v100
[884] OFF D#5
[9] ON C#5 v100
[991] OFF C#4
[84] OFF C#5
[0] ON D#5 v100
[807] OFF D#5
[0] ON C#5 v100
[9] OFF A3
[0] ON C#4 v100
[10] OFF F#3
[0] ON E3 v100
[0] ON A4 v100
[10] OFF F#2
[0] ON A2 v100
[1046] OFF F#4
[0] OFF C#5
[749] ON E4 v100
[9] OFF C#4
[0] ON C#4 v100
[20] OFF E3
[0] ON E3 v100
[9] ON A3 v100
[10] ON E2 v100
[1169] OFF E2
[655] OFF E4
[9] ON F#3 v100
[10] ON F#2 v100
[10] ON D#4 v100
[9] OFF E3
[0] ON B2 v100
[10] OFF A2
[0] ON G#4 v100
[9] ON C#5 v100
[20] OFF A4
[28] OFF C#4
[0] OFF A3
[10] ON B3 v100
[816] ON D#5 v100
[10] OFF C#5
[371] OFF F#3
[0] OFF F#2
[0] OFF D#5
[589] OFF D#4
[9] ON C#4 v100
[0] ON C#5 v100
[893] OFF C#5
[10] ON D#4 v100
[0] ON D#5 v100
[48] OFF C#4
[417] OFF D#5
[495] OFF B2
[0] OFF G#4
[0] OFF B3
[0] OFF D#4
[0] ON C#2 v100
[0] ON C#3 v100
[0] ON C#4 v100
[0] ON G#4 v100
[0] ON C#5 v100
[921] OFF C#4
[0] OFF C#5
[0] ON E4 v100
[0] ON E5 v100
[874] OFF E5
[19] OFF E4
[0] ON C#5 v100
[10] ON C#4 v100
[883] OFF C#5
[19] OFF C#4
[10] ON E4 v100
[0] ON E5 v100
[892] OFF E5
[20] ON C#5 v100
[19] ON C#4 v100
[9] ON A3 v100
[0] ON F#4 v100
[10] ON F#2 v100
[10] OFF G#4
[0] OFF E4
[9] OFF C#2
[903] ON D#5 v100
[9] OFF C#5
[0] ON D#4 v100
[29] OFF C#4
[757] OFF D#5
[0] OFF D#4
[136] ON C#4 v100
[912] OFF C#4
[0] ON D#4 v100
[0] ON D#4 v100
[0] ON D#5 v100
[918] OFF C#3
[0] OFF A3
[0] OFF D#4
[32] OFF D#5
[10] OFF D#4
[9] ON C#5 v100
[10] OFF F#4
[0] ON C#4 v100
[0] ON A4 v100
[10] OFF F#2
[0] ON A2 v100
[0] ON A2 v100
[0] ON E3 v100
[0] ON A3 v100
[0] ON E4 v100
[892] OFF C#5
[10] ON E5 v100
[883] OFF A3
[0] OFF E4
[10] ON C#5 v100
[9] OFF E5
[10] ON C#4 v100
[10] OFF A2
[0] ON A2 v100
[0] ON A3 v100
[9] OFF E3
[10] ON E3 v100
[52] OFF C#4
[0] OFF A2
[0] OFF A3
[793] OFF C#5
[9] ON E4 v100
[999] OFF A4
[9] ON G#4 v100
[0] ON E5 v100
[10] OFF E4
[9] ON G#3 v100
[10] ON C#3 v100
[127] OFF A2
[0] OFF E3
[0] OFF E5
[0] OFF C#3
[3932] OFF C#4
[0] OFF G#4
[0] OFF G#3
[27976] ON E4 v100
[0] ON E5 v100
[423] OFF E4
[0] OFF E5
[0] ON C#4 v100
[0] ON C#5 v100
[432] OFF C#4
[0] OFF C#5
[0] ON E4 v100
[0] ON E5 v100
[441] OFF E4
[0] OFF E5
[0] ON C#4 v100
[0] ON C#5 v100
[519] ON E5 v100
[9] OFF C#4
[0] ON E4 v100
[10] OFF C#5
[413] ON C#4 v100
[9] OFF E4
[0] ON C#5 v100
[10] OFF E5
[461] ON E5 v100
[9] OFF C#5
[10] OFF C#4
[0] ON E4 v100
[413] ON C#4 v100
[9] OFF E4
[0] ON C#5 v100
[10] OFF E5
[470] ON D#4 v100
[0] ON D#5 v100
[10] OFF C#4
[9] OFF C#5
[432] ON C#4 v100
[0] ON C#5 v100
[20] OFF D#4
[19] OFF D#5
[432] ON D#4 v100
[0] ON D#5 v100
[19] OFF C#5
[19] OFF C#4
[413] ON C#4 v100
[0] ON C#5 v100
[10] OFF D#5
[19] OFF D#4
[461] ON D#4 v100
[0] ON D#5 v100
[9] OFF C#4
[10] OFF C#5
[451] ON C#4 v100
[0] ON C#5 v100
[10] OFF D#4
[9] OFF D#5
[432] ON D#4 v100
[0] ON D#5 v100
[10] OFF C#4
[9] OFF C#5
[442] ON C#4 v100
[0] ON C#5 v100
[19] OFF D#4
[0] OFF D#5
[500] OFF C#5
[431] OFF C#4
[0] ON C#4 v100
[0] ON C#5 v100
[461] OFF C#4
[0] OFF C#5
[0] ON E4 v100
[0] ON E5 v100
[451] OFF E4
[0] OFF E5
[10] ON C#4 v100
[0] ON C#5 v100
[451] OFF C#4
[0] OFF C#5
[10] ON E4 v100
[0] ON E5 v100
[489] OFF E4
[0] OFF E5
[10] ON C#5 v100
[10] ON C#4 v100
[441] OFF C#5
[0] OFF C#4
[10] ON E4 v100
[0] ON E5 v100
[451] OFF E4
[0] OFF E5
[10] ON C#4 v100
[0] ON C#5 v100
[19] ON C#3 v100
[0] ON B3 v100
[0] ON D#4 v100
[0] ON F#4 v100
[441] OFF C#4
[0] OFF C#5
[10] ON D#5 v100
[10] OFF D#4
[0] ON D#4 v100
[217] OFF C#3
[0] OFF B3
[224] OFF D#5
[0] OFF D#4
[0] ON C#4 v100
[0] ON C#5 v100
[461] OFF C#4
[0] OFF C#5
[0] ON D#4 v100
[0] ON D#5 v100
[442] OFF D#4
[0] OFF D#5
[0] ON C#4 v100
[0] ON C#5 v100
[528] OFF C#4
[0] OFF C#5
[0] ON D#4 v100
[0] ON D#5 v100
[311] OFF F#4
[82] OFF D#5
[10] ON C#5 v100
[461] OFF C#5
[0] ON D#5 v100
[470] OFF D#4
[10] ON C#2 v100
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON E4 v100
[9] OFF D#5
[10] ON C#5 v100
[451] OFF C#5
[10] ON E5 v100
[453] OFF G#3
[0] OFF E4
[7] OFF E5
[0] ON C#5 v100
[0] ON C#6 v100
[461] OFF C#5
[0] OFF C#6
[0] ON E5 v100
[0] ON E6 v100
[461] OFF E5
[0] OFF E6
[0] ON C#5 v100
[0] ON C#6 v100
[461] OFF C#5
[0] OFF C#6
[0] ON E5 v100
[0] ON E6 v100
[451] OFF E5
[0] OFF E6
[0] ON C#5 v100
[0] ON C#6 v100
[125] OFF C#5
[365] OFF C#6
[0] ON E6 v100
[451] OFF C#2
[0] OFF C#3
[0] OFF E6
[0] ON C#6 v100
[9] ON F#2 v100
[0] ON A3 v100
[0] ON F#4 v100
[0] ON C#5 v100
[10] ON F#3 v100
[490] OFF C#6
[0] ON D#5 v100
[0] ON D#6 v100
[441] OFF C#5
[0] OFF D#5
[0] OFF D#6
[0] ON C#5 v100
[0] ON C#6 v100
[200] OFF C#6
[261] OFF C#5
[0] ON D#5 v100
[442] OFF D#5
[0] ON C#5 v100
[460] OFF C#5
[0] ON D#5 v100
[442] OFF D#5
[0] ON C#5 v100
[509] ON D#5 v100
[0] ON D#6 v100
[19] OFF C#5
[432] OFF D#5
[0] OFF D#6
[19] OFF C#4
[0] OFF F#2
[0] OFF A3
[0] OFF F#4
[0] OFF F#3
[0] ON A2 v100
[0] ON E3 v100
[0] ON A3 v100
[0] ON C#4 v100
[0] ON A4 v100
[0] ON C#5 v100
[0] ON C#6 v100
[509] OFF C#5
[0] OFF C#6
[10] ON E5 v100
[0] ON E6 v100
[403] ON C#5 v100
[0] ON C#6 v100
[19] OFF E5
[0] OFF E6
[407] OFF C#5
[1966] OFF C#6
[344] ON G#4 v100
[9] ON G#2 v100
[10] ON D#4 v100
[10] ON B3 v100
[9] ON F#3 v100
[10] ON C#6 v100
[19] OFF A2
[0] OFF E3
[0] OFF A3
[0] OFF C#4
[0] OFF A4
[442] ON D#6 v100
[19] OFF C#6
[432] ON C#6 v100
[9] OFF D#6
[384] ON D#6 v100
[20] OFF C#6
[249] OFF G#2
[0] OFF F#3
[0] OFF D#6
[1966] OFF B3
[204] OFF G#4
[0] OFF D#4
[13632] ON C#5 v100
[0] ON E5 v100
[86] OFF C#5
[0] OFF E5
[96] ON C#5 v100
[0] ON E5 v100
[58] OFF C#5
[0] OFF E5
[67] ON C#5 v100
[0] ON E5 v100
[86] OFF C#5
[0] OFF E5
[96] ON C#5 v100
[0] ON E5 v100
[58] OFF C#5
[0] OFF E5
[67] ON C#5 v100
[0] ON E5 v100
[87] OFF C#5
[0] OFF E5
[96] ON C#5 v100
[0] ON E5 v100
[57] OFF C#5
[0] OFF E5
[67] ON C#5 v100
[0] ON E5 v100
[87] OFF C#5
[0] OFF E5
[96] ON C#5 v100
[0] ON E5 v100
[57] OFF C#5
[0] OFF E5
[68] ON C#5 v100
[0] ON E5 v100
[86] OFF C#5
[0] OFF E5
[96] ON C#5 v100
[0] ON E5 v100
[58] OFF C#5
[0] OFF E5
[67] ON C#5 v100
[0] ON E5 v100
[86] OFF C#5
[0] OFF E5
[96] ON C#5 v100
[0] ON E5 v100
[58] OFF C#5
[0] OFF E5
[67] ON C#5 v100
[0] ON E5 v100
[49] OFF E5
[613] OFF C#5
[0] ON F#5 v100
[528] OFF F#5
[0] ON C#5 v100
[452] OFF C#5
[0] ON E5 v100
[373] OFF E5
[2478] ON D#5 v100
[240] OFF D#5
[0] ON C#5 v100
[230] OFF C#5
[0] ON C#5 v100
[231] OFF C#5
[0] ON C#5 v100
[230] OFF C#5
[0] ON E5 v100
[230] OFF E5
[0] ON E5 v100
[231] OFF E5
[0] ON E5 v100
[144] OFF E5
[57] ON G#4 v100
[0] ON C#5 v100
[0] ON E5 v100
[116] OFF G#4
[0] OFF C#5
[0] OFF E5
[57] ON G#4 v100
[0] ON C#5 v100
[0] ON E5 v100
[115] OFF G#4
[0] OFF C#5
[0] OFF E5
[58] ON G#4 v100
[0] ON C#5 v100
[0] ON E5 v100
[106] OFF G#4
[0] OFF C#5
[0] OFF E5
[57] ON G#4 v100
[0] ON C#5 v100
[0] ON E5 v100
[106] OFF G#4
[0] OFF C#5
[0] OFF E5
[57] ON G#4 v100
[0] ON C#5 v100
[0] ON E5 v100
[336] OFF G#4
[0] OFF C#5
[0] OFF E5
[48] ON G#4 v100
[0] ON C#5 v100
[0] ON E5 v100
[116] OFF G#4
[0] OFF C#5
[0] OFF E5
[57] ON G#4 v100
[0] ON C#5 v100
[0] ON E5 v100
[106] OFF G#4
[0] OFF C#5
[0] OFF E5
[57] ON G#4 v100
[0] ON C#5 v100
[0] ON E5 v100
[106] OFF G#4
[0] OFF C#5
[0] OFF E5
[58] ON G#4 v100
[0] ON C#5 v100
[0] ON E5 v100
[272] OFF E5
[73] OFF G#4
[0] OFF C#5
[154] ON F#5 v100
[0] ON C#6 v100
[374] OFF F#5
[0] OFF C#6
[67] ON G#4 v100
[0] ON C#5 v100
[260] OFF G#4
[0] OFF C#5
[278] ON E5 v100
[0] ON C#6 v100
[259] OFF E5
[0] OFF C#6
[173] ON D#5 v100
[0] ON C#6 v100
[328] OFF D#5
[0] OFF C#6
[162] ON D#5 v100
[0] ON D#6 v100
[134] OFF D#5
[0] OFF D#6
[317] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON C#5 v100
[0] ON C#5 v100
[0] ON C#6 v100
[0] ON C#6 v100
[432] OFF C#5
[0] OFF C#5
[0] OFF C#6
[0] OFF C#6
[38] ON D#5 v100
[0] ON D#5 v100
[0] ON D#6 v100
[0] ON D#6 v100
[125] OFF D#5
[0] OFF D#5
[0] OFF D#6
[0] OFF D#6
[326] ON C#5 v100
[0] ON C#5 v100
[0] ON C#6 v100
[0] ON C#6 v100
[432] OFF C#6
[39] ON D#5 v100
[9] OFF C#6
[0] ON D#6 v100
[10] OFF C#5
[461] ON C#5 v100
[9] OFF D#5
[0] ON C#6 v100
[10] OFF D#6
[432] ON E5 v100
[0] ON E6 v100
[10] OFF C#6
[19] OFF C#5
[441] ON C#5 v100
[0] ON C#6 v100
[10] OFF E5
[19] OFF E6
[384] OFF C#3
[0] OFF G#3
[10] ON C#3 v100
[9] OFF C#4
[0] ON F#2 v100
[10] ON F#3 v100
[10] OFF C#5
[0] OFF C#6
[0] ON C#4 v100
[9] ON A#3 v100
[10] ON A#4 v100
[0] ON A#5 v100
[55] OFF C#5
[0] OFF C#3
[0] OFF F#2
[0] OFF F#3
[0] OFF A#3
[0] OFF A#4
[0] OFF A#5
[348] ON F#4 v100
[10] ON F#2 v100
[9] ON C#5 v100
[0] ON C#6 v100
[10] OFF C#4
[9] ON F#3 v100
[480] OFF C#5
[0] OFF C#6
[10] ON G#5 v100
[0] ON G#6 v100
[432] OFF G#5
[0] OFF G#6
[10] ON C#5 v100
[0] ON C#6 v100
[441] OFF C#5
[0] OFF C#6
[10] ON F#5 v100
[0] ON F#6 v100
[317] OFF F#5
[0] OFF F#6
[144] OFF F#4
[0] OFF F#2
[0] OFF F#3
[0] ON A2 v100
[0] ON A3 v100
[0] ON A4 v100
[0] ON C#5 v100
[0] ON C#6 v100
[432] OFF C#5
[0] OFF C#6
[0] ON E5 v100
[0] ON E6 v100
[499] OFF E5
[0] OFF E6
[0] ON C#5 v100
[0] ON C#6 v100
[451] OFF C#5
[0] OFF C#6
[0] ON D#5 v100
[0] ON D#6 v100
[320] OFF A2
[0] OFF A3
[0] OFF A4
[0] OFF D#5
[0] OFF D#6
[227] ON C#2 v100
[1739] OFF C#2
[2072] ON C#2 v100
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON G#4 v100
[0] ON C#5 v100
[29] OFF F4
[0] OFF G#4
[0] OFF C#5
[0] ON C#5 v100
[0] ON F5 v100
[0] ON G#5 v100
[29] OFF F5
[0] OFF G#5
[29] OFF C#5
[38] OFF G#3
[0] OFF C#4
[29] OFF C#2
[0] OFF C#3
[182] ON C#2 v100
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON C#5 v100
[0] ON F5 v100
[0] ON G#5 v100
[29] OFF F4
[0] OFF C#5
[0] OFF F5
[0] OFF G#5
[29] OFF C#2
[0] OFF C#3
[0] OFF G#3
[0] OFF C#4
[192] ON C#2 v100
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON C#5 v100
[0] ON F5 v100
[29] OFF F4
[0] OFF C#5
[0] OFF F5
[29] OFF C#2
[0] OFF C#3
[0] OFF G#3
[0] OFF C#4
[153] ON C#2 v100
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON G#4 v100
[0] ON C#5 v100
[0] ON F5 v100
[29] OFF G#4
[0] OFF C#5
[0] OFF F5
[29] OFF C#2
[0] OFF C#3
[0] OFF G#3
[0] OFF C#4
[0] OFF F4
[221] ON C#2 v100
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON C#5 v100
[0] ON F5 v100
[28] OFF C#3
[0] OFF G#3
[0] OFF C#4
[0] OFF F4
[0] OFF C#5
[0] OFF F5
[29] OFF C#2
[67] ON C#2 v100
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON C#5 v100
[0] ON F5 v100
[29] OFF C#3
[0] OFF G#3
[0] OFF C#4
[0] OFF F4
[0] OFF C#5
[0] OFF F5
[29] OFF C#2
[307] ON C#2 v100
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON C#5 v100
[0] ON F5 v100
[29] OFF C#3
[0] OFF G#3
[0] OFF C#4
[0] OFF F4
[0] OFF C#5
[0] OFF F5
[29] OFF C#2
[67] ON C#2 v100
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON C#5 v100
[0] ON F5 v100
[29] OFF C#3
[0] OFF G#3
[0] OFF C#4
[0] OFF F4
[0] OFF C#5
[0] OFF F5
[29] OFF C#2
[134] ON C#3 v100
[0] ON G#3 v100
[0] ON D#4 v100
[106] OFF C#3
[0] OFF G#3
[0] OFF D#4
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON D#4 v100
[105] OFF C#3
[0] OFF G#3
[0] OFF D#4
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON D#4 v100
[106] OFF C#3
[0] OFF G#3
[0] OFF D#4
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON D#4 v100
[105] OFF C#3
[0] OFF G#3
[0] OFF D#4
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[116] OFF C#3
[0] OFF G#3
[0] OFF C#4
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[105] OFF C#3
[0] OFF G#3
[0] OFF C#4
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[106] OFF C#3
[0] OFF G#3
[0] OFF C#4
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON D#4 v100
[105] OFF C#3
[0] OFF G#3
[0] OFF D#4
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON D#4 v100
[106] OFF C#3
[0] OFF G#3
[0] OFF D#4
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON D#4 v100
[106] OFF C#3
[0] OFF G#3
[0] OFF D#4
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON D#4 v100
[105] OFF C#3
[0] OFF G#3
[0] OFF D#4
[0] ON C#3 v100
[0] ON F#3 v100
[0] ON C#4 v100
[106] OFF C#3
[0] OFF F#3
[0] OFF C#4
[0] ON F#2 v100
[0] ON C#3 v100
[0] ON A#3 v100
[0] ON C#4 v100
[115] OFF F#2
[0] OFF C#3
[0] OFF A#3
[0] OFF C#4
[0] ON F#2 v100
[0] ON C#3 v100
[0] ON A#3 v100
[0] ON C#4 v100
[106] OFF F#2
[0] OFF C#3
[0] OFF A#3
[0] OFF C#4
[0] ON F#2 v100
[0] ON C#3 v100
[0] ON A#3 v100
[0] ON C#4 v100
[105] OFF F#2
[0] OFF C#3
[0] OFF A#3
[0] OFF C#4
[0] ON F#2 v100
[0] ON C#3 v100
[0] ON A#3 v100
[0] ON C#4 v100
[106] OFF F#2
[0] OFF C#3
[0] OFF A#3
[0] OFF C#4
[0] ON F#2 v100
[0] ON C#3 v100
[0] ON A#3 v100
[0] ON C#4 v100
[105] OFF F#2
[0] OFF C#3
[0] OFF A#3
[0] OFF C#4
[0] ON F#2 v100
[0] ON C#3 v100
[0] ON A#3 v100
[0] ON C#4 v100
[106] OFF F#2
[0] OFF C#3
[0] OFF A#3
[0] OFF C#4
[0] ON F#2 v100
[0] ON C#3 v100
[0] ON A#3 v100
[0] ON C#4 v100
[24] OFF C#3
[0] OFF A#3
[5] OFF F#2
[0] OFF C#4
[0] ON F#2 v100
[0] ON F#3 v100
[0] ON C#4 v100
[374] OFF F#3
[0] OFF C#4
[0] ON F#3 v100
[0] ON E4 v100
[269] OFF E4
[0] ON C#4 v100
[269] OFF F#3
[0] OFF C#4
[0] ON F#3 v100
[0] ON C#4 v100
[269] OFF C#4
[0] ON E4 v100
[268] OFF F#3
[0] OFF E4
[0] ON C#2 v100
[0] ON C#3 v100
[0] ON F#3 v100
[0] ON C#4 v100
[512] OFF C#2
[0] OFF C#3
[0] OFF F#3
[0] OFF C#4
[7] ON E4 v100
[9] OFF F#2
[0] ON F#1 v100
[0] ON F#2 v100
[0] ON C#4 v100
[10] OFF E4
[0] ON G#3 v100
[10] OFF C#4
[0] OFF G#3
[0] ON G#3 v100
[0] ON C#4 v100
[9] OFF F#1
[0] OFF F#2
[0] ON F#1 v100
[0] ON F#2 v100
[10] OFF F#1
[0] ON F#1 v100
[9] OFF F#2
[10] OFF F#1
[10] OFF G#3
[0] OFF C#4
[9] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[0] ON G#3 v100
[9] OFF G#3
[0] ON G#3 v100
[10] OFF G#3
[1805] ON A1 v100
[0] ON A2 v100
[0] ON E3 v100
[0] ON A3 v100
[0] ON E4 v100
[336] OFF A1
[0] OFF A2
[0] OFF E3
[0] OFF A3
[0] OFF E4
[67] ON A1 v100
[0] ON A2 v100
[0] ON E3 v100
[0] ON A3 v100
[0] ON C#4 v100
[336] OFF A1
[0] OFF A2
[0] OFF E3
[0] OFF A3
[0] OFF C#4
[29] ON A1 v100
[0] ON A2 v100
[0] ON E3 v100
[0] ON A3 v100
[0] ON E4 v100
[336] OFF A1
[0] OFF A2
[0] OFF E3
[0] OFF A3
[0] OFF E4
[28] ON C#2 v100
[0] ON G#2 v100
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[404] OFF C#2
[0] OFF G#2
[0] OFF C#3
[0] OFF G#3
[0] OFF C#4
[0] ON C#2 v100
[0] ON G#2 v100
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON D#4 v100
[104] OFF C#2
[0] OFF G#2
[0] OFF C#3
[0] OFF G#3
[0] OFF D#4
[11] ON C#2 v100
[0] ON C#3 v100
[182] OFF C#2
[0] OFF C#3
[0] ON C#2 v100
[0] ON C#3 v100
[96] OFF C#2
[0] OFF C#3
[0] ON C#2 v100
[0] ON C#3 v100
[29] OFF C#3
[0] ON C#3 v100
[182] OFF C#2
[0] OFF C#3
[0] ON C#2 v100
[0] ON C#3 v100
[125] OFF C#2
[0] OFF C#3
[0] ON C#2 v100
[0] ON C#3 v100
[29] OFF C#3
[29] ON D#4 v100
[0] ON D#5 v100
[38] OFF D#4
[0] OFF D#5
[29] OFF C#2
[0] ON C#2 v100
[0] ON C#3 v100
[182] OFF C#2
[0] OFF C#3
[0] ON C#2 v100
[0] ON C#3 v100
[96] OFF C#2
[0] OFF C#3
[0] ON C#2 v100
[0] ON C#3 v100
[29] ON C#4 v100
[0] ON C#5 v100
[29] OFF C#4
[0] OFF C#5
[29] OFF C#2
[0] OFF C#3
[0] ON C#2 v100
[0] ON C#3 v100
[125] OFF C#2
[0] OFF C#3
[0] ON C#2 v100
[0] ON C#3 v100
[153] OFF C#2
[0] OFF C#3
[29] ON D#4 v100
[0] ON D#5 v100
[29] OFF D#4
[0] OFF D#5
[0] ON D#4 v100
[0] ON D#5 v100
[38] OFF D#4
[0] OFF D#5
[29] ON G#2 v100
[0] ON G#3 v100
[29] OFF G#2
[0] OFF G#3
[29] ON G#2 v100
[0] ON G#3 v100
[96] OFF G#2
[0] OFF G#3
[0] ON G#2 v100
[0] ON G#3 v100
[28] OFF G#2
[0] OFF G#3
[29] ON G#2 v100
[0] ON G#3 v100
[96] OFF G#2
[0] OFF G#3
[0] ON C#2 v100
[0] ON C#3 v100
[0] ON G#3 v100
[29] OFF C#3
[29] OFF C#2
[0] OFF G#3
[0] ON C#2 v100
[0] ON C#3 v100
[0] ON G#3 v100
[83] OFF C#2
[0] OFF C#3
[234] ON D#5 v100
[374] OFF D#5
[10] ON C#5 v100
[9] ON C#3 v100
[0] ON C#4 v100
[10] OFF G#3
[0] ON G#3 v100
[0] ON F4 v100
[374] ON D#5 v100
[19] OFF C#5
[365] ON C#5 v100
[19] OFF D#5
[365] ON D#5 v100
[19] OFF C#5
[168] OFF F4
[188] ON C#5 v100
[9] OFF C#3
[0] OFF C#4
[0] OFF G#3
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON G#4 v100
[10] OFF D#5
[355] ON D#5 v100
[10] OFF C#5
[374] ON C#5 v100
[10] OFF C#3
[0] OFF G#3
[0] OFF C#4
[0] OFF G#4
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON G#4 v100
[9] OFF C#5
[0] ON C#5 v100
[10] OFF D#5
[365] OFF C#5
[0] ON D#5 v100
[374] OFF C#3
[0] OFF G#3
[0] OFF C#4
[0] OFF G#4
[0] OFF D#5
[0] ON F#2 v100
[0] ON F#3 v100
[0] ON C#4 v100
[0] ON F#4 v100
[0] ON C#5 v100
[10] OFF C#5
[0] ON C#5 v100
[384] OFF C#5
[0] ON E5 v100
[9] OFF C#4
[0] ON C#4 v100
[0] ON C#5 v100
[10] OFF F#4
[0] ON F#4 v100
[9] OFF F#3
[0] ON F#3 v100
[356] OFF E5
[0] OFF C#5
[0] ON C#5 v100
[9] OFF C#4
[0] OFF C#5
[0] ON C#4 v100
[0] ON C#5 v100
[355] OFF C#4
[0] OFF C#5
[10] ON E5 v100
[10] ON E4 v100
[374] OFF E5
[0] OFF E4
[0] ON C#4 v100
[0] ON C#5 v100
[374] OFF C#5
[10] OFF C#4
[0] ON E4 v100
[0] ON E5 v100
[298] OFF F#2
[0] OFF E5
[67] OFF F#4
[0] OFF E4
[0] ON F#4 v100
[0] ON C#5 v100
[19] OFF F#3
[0] ON F#2 v100
[0] ON F#3 v100
[0] ON C#4 v100
[0] ON E4 v100
[29] OFF E4
[153] OFF F#4
[0] OFF F#3
[0] ON F#3 v100
[0] ON F#4 v100
[125] OFF F#4
[0] ON E4 v100
[29] OFF C#5
[0] OFF F#2
[0] OFF C#4
[0] OFF F#3
[0] ON F#2 v100
[0] ON F#3 v100
[0] ON C#4 v100
[0] ON F#4 v100
[0] ON C#5 v100
[0] ON E5 v100
[29] OFF E4
[153] OFF F#3
[0] OFF F#4
[0] ON F#3 v100
[0] ON F#4 v100
[125] OFF C#4
[29] OFF F#2
[0] OFF C#5
[0] OFF E5
[0] OFF F#3
[0] OFF F#4
[0] ON A2 v100
[0] ON E3 v100
[0] ON A3 v100
[0] ON C#4 v100
[0] ON E4 v100
[0] ON C#5 v100
[0] ON E5 v100
[29] OFF E4
[0] OFF E5
[0] ON E4 v100
[0] ON E5 v100
[67] OFF E4
[0] OFF E5
[0] ON E4 v100
[0] ON E5 v100
[29] OFF E3
[0] ON E3 v100
[29] OFF E4
[0] OFF E5
[0] ON E4 v100
[0] ON E5 v100
[96] OFF E3
[0] OFF E4
[0] OFF E5
[0] ON E3 v100
[0] ON E4 v100
[0] ON E5 v100
[28] OFF E4
[0] OFF E5
[0] ON E4 v100
[0] ON E5 v100
[29] OFF E3
[0] OFF E4
[29] OFF E5
[0] ON E3 v100
[0] ON E4 v100
[0] ON E5 v100
[38] OFF E4
[29] OFF A2
[0] OFF A3
[0] OFF C#5
[0] OFF E3
[0] OFF E5
[0] ON A2 v100
[0] ON E3 v100
[0] ON A3 v100
[0] ON E4 v100
[0] ON C#5 v100
[0] ON E5 v100
[29] OFF E4
[29] OFF E3
[0] ON E3 v100
[0] ON E4 v100
[29] OFF C#5
[0] OFF E5
[0] OFF E3
[0] OFF E4
[0] ON E4 v100
[0] ON E5 v100
[96] OFF A2
[0] OFF A3
[0] OFF E4
[0] OFF E5
[0] ON A2 v100
[0] ON E3 v100
[0] ON A3 v100
[0] ON E4 v100
[0] ON E5 v100
[28] OFF E3
[0] OFF E4
[0] OFF E5
[0] ON E3 v100
[0] ON E4 v100
[0] ON E5 v100
[29] OFF E4
[125] OFF A2
[0] OFF A3
[0] OFF E3
[0] OFF E5
[0] ON A2 v100
[0] ON E3 v100
[0] ON A3 v100
[0] ON E4 v100
[0] ON E5 v100
[29] OFF E4
[67] OFF A2
[0] OFF E3
[0] OFF A3
[0] OFF E5
[0] ON A2 v100
[0] ON E3 v100
[0] ON A3 v100
[0] ON E4 v100
[0] ON C#5 v100
[0] ON E5 v100
[29] OFF E4
[0] OFF E5
[0] ON E4 v100
[0] ON E5 v100
[29] OFF E3
[0] OFF E4
[28] OFF A2
[0] OFF A3
[0] OFF C#5
[0] OFF E5
[0] ON A2 v100
[0] ON E3 v100
[0] ON A3 v100
[0] ON E4 v100
[0] ON C#5 v100
[0] ON E5 v100
[39] OFF E4
[29] OFF A2
[0] OFF E3
[0] OFF A3
[0] OFF C#5
[0] OFF E5
[0] ON A2 v100
[0] ON E3 v100
[0] ON A3 v100
[0] ON E4 v100
[0] ON C#5 v100
[0] ON E5 v100
[28] OFF E4
[29] OFF E3
[0] OFF A3
[133] OFF E5
[50] ON E5 v100
[0] ON E6 v100
[9] OFF C#5
[29] OFF C#4
[0] ON C#4 v100
[0] ON C#5 v100
[307] OFF E5
[0] OFF E6
[19] OFF C#5
[0] ON C#5 v100
[0] ON C#6 v100
[10] OFF C#4
[0] OFF C#5
[0] ON C#4 v100
[0] ON C#5 v100
[374] OFF C#6
[0] OFF C#5
[10] ON E5 v100
[0] ON E6 v100
[10] OFF C#4
[9] ON C#4 v100
[0] ON C#5 v100
[346] OFF E5
[0] OFF E6
[9] OFF C#5
[0] ON C#5 v100
[0] ON C#6 v100
[20] OFF C#4
[0] OFF C#5
[0] ON C#4 v100
[0] ON C#5 v100
[9] OFF C#5
[0] ON C#5 v100
[10] ON A3 v100
[9] OFF A2
[0] ON A2 v100
[317] OFF C#6
[0] OFF C#5
[10] ON E5 v100
[0] ON E6 v100
[19] OFF C#4
[10] OFF E5
[0] ON E5 v100
[9] OFF E5
[0] ON E5 v100
[371] OFF A3
[0] OFF A2
[0] OFF E6
[0] OFF E5
[359] ON D#5 v100
[0] ON D#6 v100
[393] OFF D#5
[0] OFF D#6
[0] ON C#5 v100
[0] ON C#6 v100
[384] OFF C#5
[0] OFF C#6
[0] ON D#5 v100
[0] ON D#6 v100
[413] OFF D#5
[0] OFF D#6
[0] ON C#5 v100
[0] ON C#6 v100
[346] OFF C#5
[0] OFF C#6
[0] ON D#5 v100
[0] ON D#6 v100
[105] ON G#3 v100
[10] OFF D#5
[0] OFF D#6
[0] ON G#2 v100
[10] ON D#4 v100
[0] ON G#4 v100
[9] ON D#5 v100
[0] ON D#6 v100
[67] OFF G#3
[10] OFF G#2
[0] OFF D#4
[0] OFF G#4
[10] OFF D#5
[0] OFF D#6
[28] ON G#4 v100
[10] ON G#2 v100
[0] ON G#3 v100
[0] ON D#4 v100
[10] ON D#5 v100
[0] ON D#6 v100
[76] OFF G#4
[0] OFF G#3
[0] OFF D#4
[10] OFF G#2
[10] OFF D#5
[0] OFF D#6
[28] ON G#3 v100
[10] ON G#2 v100
[10] ON D#4 v100
[0] ON G#4 v100
[9] ON C#5 v100
[0] ON C#6 v100
[87] OFF G#3
[9] OFF G#2
[0] OFF D#4
[0] OFF G#4
[10] OFF C#5
[0] OFF C#6
[29] ON G#3 v100
[9] ON G#2 v100
[10] ON D#4 v100
[0] ON G#4 v100
[9] ON C#5 v100
[0] ON C#6 v100
[77] OFF G#3
[10] OFF G#2
[0] OFF D#4
[0] OFF G#4
[9] OFF C#5
[0] OFF C#6
[29] ON G#3 v100
[10] ON G#2 v100
[9] ON D#4 v100
[0] ON G#4 v100
[10] ON D#5 v100
[0] ON D#6 v100
[86] OFF G#3
[10] OFF G#2
[10] OFF D#4
[0] OFF G#4
[9] OFF D#5
[0] OFF D#6
[19] ON G#3 v100
[10] ON G#2 v100
[10] ON D#4 v100
[0] ON G#4 v100
[9] ON D#5 v100
[0] ON D#6 v100
[77] OFF G#3
[10] OFF G#2
[9] OFF D#4
[0] OFF G#4
[10] OFF D#5
[0] OFF D#6
[19] ON G#2 v100
[0] ON G#3 v100
[10] ON D#4 v100
[0] ON G#4 v100
[9] ON D#5 v100
[0] ON D#6 v100
[77] OFF G#3
[10] OFF G#2
[0] OFF D#4
[0] OFF G#4
[9] OFF D#5
[0] OFF D#6
[29] ON G#3 v100
[10] ON G#2 v100
[9] ON D#4 v100
[0] ON G#4 v100
[0] ON D#5 v100
[0] ON D#6 v100
[87] OFF G#3
[19] OFF G#2
[9] OFF D#4
[0] OFF G#4
[10] OFF D#5
[0] OFF D#6
[19] ON G#3 v100
[10] ON G#2 v100
[9] ON D#4 v100
[0] ON G#4 v100
[10] ON D#5 v100
[0] ON D#6 v100
[86] OFF G#3
[10] OFF G#2
[10] OFF D#4
[0] OFF G#4
[9] OFF D#5
[0] OFF D#6
[19] ON G#3 v100
[10] ON G#2 v100
[10] ON D#4 v100
[0] ON G#4 v100
[9] ON D#5 v100
[0] ON D#6 v100
[87] OFF G#3
[19] OFF G#2
[9] OFF D#4
[0] OFF G#4
[10] OFF D#5
[0] OFF D#6
[19] ON G#3 v100
[10] ON G#2 v100
[9] ON D#4 v100
[0] ON G#4 v100
[10] ON D#5 v100
[0] ON D#6 v100
[86] OFF G#3
[20] OFF G#2
[9] OFF D#4
[0] OFF G#4
[10] OFF D#5
[0] OFF D#6
[9] ON G#3 v100
[720] OFF G#3
[10] ON C#3 v100
[0] ON G#3 v100
[0] ON E4 v100
[1450] OFF C#3
[0] OFF G#3
[0] OFF E4
[0] ON F#2 v100
[0] ON A3 v100
[0] ON C#4 v100
[0] ON G#4 v100
[1008] ON F#4 v100
[0] ON F#5 v100
[76] OFF F#4
[0] OFF F#5
[682] OFF F#2
[0] OFF A3
[0] OFF C#4
[0] OFF G#4
[0] ON A2 v100
[0] ON E3 v100
[0] ON C#4 v100
[0] ON A4 v100
[1373] OFF A2
[0] OFF E3
[0] OFF C#4
[0] OFF A4
[19] ON G#3 v100
[0] ON D#4 v100
[0] ON G#4 v100
[0] ON C5 v100
[0] ON D#5 v100
[764] OFF G#4
[0] OFF C5
[762] OFF D#4
[0] OFF D#5
[0] ON E4 v100
[0] ON E5 v100
[1690] OFF G#3
[0] OFF E4
[0] ON F#2 v100
[0] ON F#3 v100
[0] ON C#4 v100
[0] ON F#4 v100
[0] ON F#5 v100
[19] OFF E5
[1461] OFF C#4
[0] OFF F#5
[8] OFF F#2
[0] OFF F#3
[0] OFF F#4
[0] ON A2 v100
[0] ON A3 v100
[0] ON A4 v100
[0] ON A5 v100
[29] OFF A5
[0] ON A5 v100
[19] OFF A4
[0] ON A4 v100
[10] OFF A2
[0] OFF A3
[0] ON A2 v100
[0] ON A3 v100
[28] OFF A5
[0] ON A5 v100
[87] OFF A5
[0] ON A5 v100
[38] OFF A5
[0] ON A5 v100
[67] OFF A5
[0] ON A5 v100
[58] OFF A5
[0] ON A5 v100
[67] OFF A5
[0] ON A5 v100
[58] OFF A5
[0] ON A5 v100
[57] OFF A5
[0] ON A5 v100
[58] OFF A5
[0] ON A5 v100
[67] OFF A5
[0] ON A5 v100
[58] OFF A5
[0] ON A5 v100
[57] OFF A5
[0] ON A5 v100
[68] OFF A5
[0] ON A5 v100
[57] OFF A5
[0] ON A5 v100
[67] OFF A5
[0] ON A5 v100
[58] OFF A5
[0] ON A5 v100
[67] OFF A5
[0] ON A5 v100
[58] OFF A5
[0] ON A5 v100
[57] OFF A5
[0] ON A5 v100
[58] OFF A5
[0] ON A5 v100
[67] OFF A5
[0] ON A5 v100
[58] OFF A5
[0] ON A5 v100
[67] OFF A5
[0] ON A5 v100
[58] OFF A5
[0] ON A5 v100
[57] OFF A4
[0] OFF A2
[0] OFF A3
[0] OFF A5
[0] ON C#2 v100
[0] ON C#3 v100
[0] ON C#4 v100
[0] ON C#5 v100
[0] ON A5 v100
[39] OFF A5
[0] ON A5 v100
[57] OFF A5
[0] ON A5 v100
[67] OFF A5
[0] ON A5 v100
[58] OFF A5
[0] ON A5 v100
[67] OFF A5
[0] ON A5 v100
[58] OFF A5
[0] ON A5 v100
[57] OFF C#2
[0] OFF C#5
[0] OFF A5
[317] ON C#5 v100
[355] OFF C#5
[0] ON D#5 v100
[356] OFF D#5
[0] ON C#5 v100
[460] OFF C#3
[0] OFF C#4
[0] OFF C#5
[0] ON F#3 v100
[0] ON C#4 v100
[0] ON F#4 v100
[0] ON A4 v100
[0] ON E5 v100
[478] OFF F#3
[0] OFF F#4
[0] OFF A4
[0] OFF E5
[12] OFF C#4
[0] ON C#3 v100
[0] ON F#3 v100
[0] ON C#4 v100
[0] ON F#4 v100
[0] ON C#5 v100
[0] ON F#5 v100
[230] OFF C#3
[0] OFF F#3
[0] OFF C#4
[0] OFF F#4
[0] OFF C#5
[0] OFF F#5
[0] ON C#3 v100
[0] ON F#3 v100
[0] ON C#4 v100
[0] ON F#4 v100
[0] ON C#5 v100
[0] ON E5 v100
[221] OFF C#3
[0] OFF F#3
[0] OFF C#4
[0] OFF F#4
[0] OFF C#5
[0] OFF E5
[0] ON C#3 v100
[0] ON F#3 v100
[0] ON C#4 v100
[0] ON F#4 v100
[0] ON C#5 v100
[0] ON E5 v100
[221] OFF C#3
[0] OFF F#3
[0] OFF C#4
[0] OFF F#4
[0] OFF C#5
[0] OFF E5
[0] ON C#3 v100
[0] ON E3 v100
[0] ON C#4 v100
[0] ON E4 v100
[0] ON C#5 v100
[0] ON E5 v100
[221] OFF C#3
[0] OFF E3
[0] OFF C#4
[0] OFF E4
[0] OFF C#5
[0] OFF E5
[0] ON C#3 v100
[0] ON E3 v100
[0] ON C#4 v100
[0] ON E4 v100
[0] ON C#5 v100
[0] ON E5 v100
[221] OFF C#3
[0] OFF E3
[0] OFF C#4
[0] OFF E4
[0] OFF C#5
[0] OFF E5
[0] ON C#3 v100
[0] ON E3 v100
[0] ON C#4 v100
[0] ON E4 v100
[0] ON C#5 v100
[0] ON C#5 v100
[0] ON E5 v100
[0] ON E5 v100
[220] OFF C#3
[0] OFF E3
[0] OFF C#4
[0] OFF E4
[0] OFF C#5
[0] OFF E5
[0] ON C#3 v100
[0] ON E3 v100
[0] ON C#4 v100
[0] ON E4 v100
[0] ON C#5 v100
[0] ON E5 v100
[221] OFF C#5
[0] OFF E5
[0] OFF C#3
[0] OFF E3
[0] OFF C#4
[0] OFF E4
[0] ON C#3 v100
[0] ON E3 v100
[0] ON C#4 v100
[0] ON E4 v100
[0] ON C#5 v100
[0] ON E5 v100
[221] OFF C#5
[0] OFF E5
[0] OFF C#3
[0] OFF E3
[0] OFF C#4
[0] OFF E4
[0] ON C#3 v100
[0] ON E3 v100
[0] ON C#4 v100
[0] ON E4 v100
[0] ON C#5 v100
[0] ON E5 v100
[178] OFF C#5
[0] OFF C#3
[0] OFF E3
[0] OFF C#4
[302] ON C#5 v100
[10] ON C#4 v100
[19] OFF E5
[0] OFF E4
[365] ON D#5 v100
[9] ON D#4 v100
[10] OFF C#5
[9] OFF C#4
[298] ON C#5 v100
[10] ON C#4 v100
[9] OFF E5
[0] OFF C#5
[0] OFF D#5
[0] OFF D#4
[19] ON F#4 v100
[0] ON B4 v100
[0] ON D#5 v100
[365] ON D#4 v100
[0] ON D#5 v100
[10] OFF C#5
[0] OFF C#4
[345] ON C#4 v100
[0] ON C#5 v100
[10] OFF D#5
[0] OFF D#4
[176] OFF F#4
[0] OFF B4
[0] OFF D#5
[16] OFF C#5
[10] OFF C#4
[115] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON G#4 v100
[0] ON C#5 v100
[77] OFF G#3
[0] OFF C#4
[0] OFF G#4
[9] OFF C#3
[0] OFF F4
[0] OFF C#5
[58] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON G#4 v100
[0] ON C#5 v100
[86] OFF G#3
[0] OFF C#4
[0] OFF G#4
[10] OFF C#3
[0] OFF F4
[0] OFF C#5
[57] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON G#4 v100
[0] ON C#5 v100
[77] OFF G#3
[0] OFF C#4
[0] OFF G#4
[10] OFF C#3
[0] OFF F4
[0] OFF C#5
[67] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON G#4 v100
[0] ON C#5 v100
[86] OFF G#3
[0] OFF C#4
[0] OFF G#4
[10] OFF C#3
[0] OFF F4
[0] OFF C#5
[58] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON G#4 v100
[0] ON C#5 v100
[76] OFF G#3
[0] OFF C#4
[0] OFF G#4
[10] OFF C#3
[0] OFF F4
[0] OFF C#5
[67] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON G#4 v100
[0] ON C#5 v100
[77] OFF G#3
[0] OFF C#4
[0] OFF G#4
[10] OFF C#3
[0] OFF F4
[0] OFF C#5
[57] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON G#4 v100
[0] ON C#5 v100
[77] OFF G#3
[0] OFF C#4
[0] OFF G#4
[10] OFF C#3
[0] OFF F4
[0] OFF C#5
[67] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON F4 v100
[0] ON G#4 v100
[0] ON C#5 v100
[77] OFF G#3
[0] OFF C#4
[0] OFF G#4
[9] OFF C#3
[0] OFF F4
[0] OFF C#5
[77] ON A3 v100
[0] ON C#4 v100
[0] ON F#4 v100
[0] ON A4 v100
[0] ON C#5 v100
[606] OFF A3
[0] OFF C#4
[719] OFF F#4
[0] OFF A4
[0] OFF C#5
[0] ON E3 v100
[0] ON E4 v100
[0] ON A4 v100
[0] ON C#5 v100
[0] ON E5 v100
[0] ON C#6 v100
[1247] OFF E5
[0] OFF C#6
[519] OFF E3
[0] OFF E4
[0] OFF A4
[0] OFF C#5
[39] ON B3 v100
[0] ON D#4 v100
[0] ON F#4 v100
[0] ON G#4 v100
[0] ON B4 v100
[0] ON D#5 v100
[1408] OFF B3
[0] OFF F#4
[0] OFF B4
[1625] ON E4 v100
[10] OFF D#5
[0] ON E5 v100
[9] ON C#5 v100
[10] OFF D#4
[312] OFF G#4
[0] OFF E4
[14] ON G#3 v100
[0] ON C#4 v100
[0] ON E4 v100
[10] ON C#3 v100
[10] ON E3 v100
[9] ON E6 v100
[183] OFF E6
[9] ON E6 v100
[202] OFF E6
[9] ON C#6 v100
[202] OFF C#6
[10] ON C#6 v100
[201] OFF C#6
[10] ON E6 v100
[86] OFF G#3
[0] OFF C#4
[0] OFF E4
[0] OFF C#3
[0] OFF E3
[10] OFF E6
[9] ON E6 v100
[10] OFF E5
[0] OFF C#5
[0] ON E5 v100
[202] OFF E6
[9] OFF E5
[0] ON C#6 v100
[10] ON G#4 v100
[0] ON C#5 v100
[0] ON G#5 v100
[9] ON A3 v100
[10] ON F#3 v100
[0] ON C#4 v100
[10] ON C#3 v100
[163] OFF C#6
[9] ON C#6 v100
[202] OFF C#6
[10] OFF G#5
[0] ON G#5 v100
[201] OFF G#5
[10] ON G#5 v100
[137] OFF A3
[0] OFF F#3
[0] OFF C#4
[0] OFF C#3
[16] OFF C#5
[0] ON C#3 v100
[0] ON C#4 v100
[0] ON C#5 v100
[10] OFF G#4
[0] OFF C#3
[0] OFF C#4
[0] OFF C#5
[0] ON C#2 v100
[0] ON C#3 v100
[0] ON C#4 v100
[0] ON E4 v100
[0] ON G#4 v100
[0] ON C#5 v100
[10] OFF G#4
[0] ON G#4 v100
[9] OFF C#5
[0] ON C#5 v100
[10] OFF C#4
[0] OFF E4
[0] ON C#4 v100
[0] ON E4 v100
[9] OFF C#3
[10] OFF C#2
[0] OFF G#4
[0] OFF C#5
[10] OFF C#4
[0] OFF E4
[307] ON F#5 v100
[0] ON F#6 v100
[19] OFF F#5
[0] ON F#5 v100
[10] OFF F#6
[0] ON F#6 v100
[19] OFF F#5
[9] OFF F#6
[327] ON C#5 v100
[0] ON C#6 v100
[9] OFF C#5
[0] ON C#5 v100
[10] OFF C#6
[0] ON A2 v100
[0] ON A3 v100
[0] ON C#4 v100
[0] ON E4 v100
[10] OFF C#5
[0] ON C#5 v100
[9] OFF A2
[0] OFF A3
[0] OFF C#4
[0] OFF E4
[0] ON A2 v100
[0] ON A3 v100
[0] ON C#4 v100
[0] ON E4 v100
[10] OFF C#5
[0] ON C#5 v100
[9] OFF C#4
[0] OFF E4
[0] ON C#4 v100
[0] ON E4 v100
[10] OFF A2
[0] OFF A3
[0] ON A2 v100
[0] ON A3 v100
[10] OFF C#5
[0] OFF C#4
[0] OFF E4
[9] OFF A2
[0] OFF A3
[10] OFF G#5
[0] ON F#4 v100
[0] ON A4 v100
[0] ON C#5 v100
[0] ON F#5 v100
[0] ON C#6 v100
[1095] OFF F#4
[0] OFF A4
[0] OFF C#5
[0] OFF F#5
[0] OFF C#6
[124] ON D#5 v100
[0] ON D#6 v100
[48] OFF D#6
[10] OFF D#5
[76] ON G#2 v100
[0] ON C#3 v100
[0] ON G#3 v100
[0] ON C#4 v100
[0] ON D#5 v100
[0] ON D#6 v100
[48] OFF D#5
[0] OFF D#6
[48] ON C#5 v100
[0] ON C#6 v100
[58] OFF C#5
[0] OFF C#6
[67] ON D#5 v100
[0] ON D#6 v100
[48] OFF D#5
[0] OFF D#6
[67] ON C#5 v100
[0] ON C#6 v100
[58] OFF C#5
[0] OFF C#6
[67] ON D#5 v100
[0] ON D#6 v100
[48] OFF D#5
[0] OFF D#6
[67] ON D#5 v100
[0] ON D#6 v100
[58] OFF D#5
[0] OFF D#6
[67] ON D#5 v100
[0] ON D#6 v100
[58] OFF D#5
[0] OFF D#6
[67] ON C#5 v100
[0] ON C#6 v100
[58] OFF C#5
[0] OFF C#6
[67] ON C#5 v100
[0] ON C#6 v100
[57] OFF C#5
[0] OFF C#6
[68] ON D#5 v100
[0] ON D#6 v100
[48] OFF D#5
[0] OFF D#6
[67] ON D#5 v100
[0] ON D#6 v100
[48] OFF D#5
[0] OFF D#6
[67] ON D#5 v100
[0] ON D#6 v100
[58] OFF D#5
[0] OFF D#6
[67] ON D#5 v100
[0] ON D#6 v100
[57] OFF D#5
[0] OFF D#6
[68] ON D#5 v100
[0] ON D#6 v100
[48] OFF D#5
[0] OFF D#6
[9] ON E5 v100
[58] ON C#5 v100
[0] ON C#6 v100
[37] OFF G#2
[0] OFF C#5
[11] OFF C#6
[0] ON C#6 v100
[77] OFF C#6
[0] ON C#6 v100
[76] OFF C#6
[0] ON C#6 v100
[77] OFF C#6
[0] ON E6 v100
[77] OFF E6
[0] ON E6 v100
[77] OFF E6
[0] ON E6 v100
[77] OFF E6
[0] ON E6 v100
[76] OFF E6
[0] ON E6 v100
[77] OFF E6
[0] ON C#6 v100
[77] OFF C#6
[0] ON C#6 v100
[77] OFF C#6
[0] ON C#6 v100
[77] OFF C#6
[0] ON C#6 v100
[67] OFF C#6
[0] ON C#6 v100
[77] OFF C#6
[0] ON C#6 v100
[67] OFF C#6
[0] ON E6 v100
[77] OFF E6
[0] ON E6 v100
[67] OFF E6
[0] ON E6 v100
[77] OFF E6
[0] ON E6 v100
[67] OFF E6
[0] ON F#6 v100
[67] OFF F#6
[0] ON F#6 v100
[10] OFF C#3
[0] OFF G#3
[0] OFF C#4
[0] OFF E5
[0] ON F#2 v100
[0] ON F#3 v100
[0] ON F#4 v100
[0] ON C#5 v100
[0] ON F#5 v100
[0] ON C#6 v100
[67] OFF F#6
[0] ON F#6 v100
[67] OFF F#6
[0] ON F#6 v100
[67] OFF F#6
[0] ON F#6 v100
[67] OFF F#6
[0] ON F#6 v100
[68] OFF F#6
[0] ON F#6 v100
[67] OFF F#6
[0] ON G#6 v100
[67] OFF G#6
[0] ON G#6 v100
[64] OFF G#6
[714] OFF F#2
[0] OFF F#3
[0] OFF F#4
[0] OFF C#5
[0] OFF F#5
[0] OFF C#6
[0] ON C#6 v100
[9] ON A2 v100
[10] ON A4 v100
[0] ON C#5 v100
[0] ON A5 v100
[0] ON E6 v100
[1233] OFF A2
[0] OFF C#5
[0] OFF E6
[15] OFF C#6
[9] OFF A5
[10] OFF A4
[29] ON A5 v100
[9] ON A4 v100
[0] ON C#6 v100
[10] ON D#5 v100
[96] OFF A5
[0] OFF C#6
[10] OFF A4
[9] OFF D#5
[19] ON A4 v100
[0] ON D#5 v100
[0] ON A5 v100
[0] ON C#6 v100
[106] OFF A4
[10] OFF D#5
[0] OFF C#6
[19] OFF A5
[14150] ON G#4 v100
[3193] OFF G#4
[14] ON C#4 v100
[0] ON E4 v100
[192] OFF C#4
[0] OFF E4
[0] ON C#4 v100
[0] ON E4 v100
[192] OFF C#4
[0] OFF E4
[0] ON C#4 v100
[0] ON E4 v100
[182] OFF C#4
[0] OFF E4
[0] ON C#4 v100
[0] ON E4 v100
[182] OFF C#4
[0] OFF E4
[0] ON C#4 v100
[0] ON E4 v100
[183] OFF C#4
[0] OFF E4
[0] ON C#4 v100
[0] ON E4 v100
[182] OFF C#4
[0] OFF E4
[0] ON C#4 v100
[0] ON E4 v100
[183] OFF C#4
[0] OFF E4
[0] ON C#4 v100
[0] ON E4 v100
[182] OFF C#4
[0] OFF E4
[0] ON C#4 v100
[0] ON E4 v100
[182] OFF C#4
[0] OFF E4
[0] ON C#4 v100
[0] ON E4 v100
[183] OFF C#4
[0] OFF E4
[0] ON C#4 v100
[0] ON E4 v100
[144] OFF C#4
[0] ON C#4 v100
[9] ON D#4 v100
[20] OFF E4
[0] ON E4 v100
[28] OFF C#4
[0] OFF D#4
[0] ON C#4 v100
[0] ON D#4 v100
[29] OFF E4
[0] OFF C#4
[0] ON C#4 v100
[0] ON E4 v100
[29] OFF D#4
[0] ON D#4 v100
[29] OFF C#4
[0] OFF E4
[0] ON C#4 v100
[0] ON E4 v100
[29] OFF D#4
[9] OFF C#4
[0] ON C#4 v100
[29] OFF E4
[0] ON D#4 v100
[29] OFF C#4
[9] OFF D#4
[0] ON C#4 v100
[0] ON E4 v100
[39] OFF C#4
[0] OFF E4
[0] ON C#4 v100
[0] ON D#4 v100
[29] OFF D#4
[0] ON D#4 v100
[28] OFF C#4
[10] ON C#4 v100
[19] OFF D#4
[0] ON E4 v100
[29] OFF C#4
[10] OFF E4
[0] ON C#4 v100
[0] ON D#4 v100
[28] OFF D#4
[10] OFF C#4
[0] ON C#4 v100
[19] OFF C#4
[0] ON E4 v100
[29] OFF E4
[0] ON D#4 v100
[29] OFF D#4
[0] ON C#4 v100
[19] OFF C#4
[0] ON C#4 v100
[19] ON E4 v100
[19] OFF C#4
[10] OFF E4
[0] ON D#4 v100
[29] OFF D#4
[0] ON C#4 v100
[19] ON E4 v100
[19] OFF C#4
[10] OFF E4
[0] ON C#4 v100
[0] ON D#4 v100
[29] OFF D#4
[9] OFF C#4
[0] ON C#4 v100
[19] OFF C#4
[10] ON E4 v100
[29] OFF E4
[0] ON E4 v100
[38] OFF E4
[0] ON D#4 v100
[29] OFF D#4
[0] ON D#4 v100
[29] OFF D#4
[0] ON D#4 v100
[29] OFF D#4
[0] ON D#4 v100
[28] OFF D#4
[0] ON D#4 v100
[29] OFF D#4
[0] ON D#4 v100
[29] OFF D#4
[0] ON D#4 v100
[29] OFF D#4
[0] ON D#4 v100
[29] OFF D#4
[0] ON D#4 v100
[38] OFF D#4
[0] ON D#4 v100
[38] OFF D#4
[0] ON D#4 v100
[29] OFF D#4
[0] ON D#4 v100
[29] OFF D#4
[0] ON D#4 v100
[29] OFF D#4
[0] ON D#4 v100
[38] OFF D#4
[0] ON D#4 v100
[29] OFF D#4
[0] ON D#4 v100
[29] OFF D#4
[0] ON D#4 v100
[29] OFF D#4
[0] ON D#4 v100
[2582] ON C#4 v100
[10] OFF D#4
[0] ON E4 v100
[278] OFF C#4
[0] OFF E4
[0] ON D#4 v100
[10] ON B3 v100
[163] OFF D#4
[0] OFF B3
[0] ON C#4 v100
[0] ON E4 v100
[288] OFF C#4
[0] OFF E4
[0] ON B3 v100
[0] ON D#4 v100
[278] OFF B3
[0] OFF D#4
[0] ON C#4 v100
[0] ON E4 v100
[279] OFF C#4
[0] OFF E4
[0] ON D#4 v100
[9] ON B3 v100
[173] OFF D#4
[0] OFF B3
[0] ON C#4 v100
[0] ON E4 v100
[278] OFF C#4
[0] OFF E4
[0] ON D#4 v100
[10] ON B3 v100
[181] OFF D#4
[0] OFF B3
[2056] ON C#4 v100
[0] ON D#4 v100
[0] ON F#4 v100
[57] OFF D#4
[0] OFF F#4
[20] OFF C#4
[67] ON C#4 v100
[0] ON D#4 v100
[0] ON F#4 v100
[57] OFF D#4
[0] OFF F#4
[10] OFF C#4
[77] ON C#4 v100
[0] ON D#4 v100
[0] ON F#4 v100
[57] OFF D#4
[0] OFF F#4
[10] OFF C#4
[77] ON C#4 v100
[0] ON D#4 v100
[0] ON F#4 v100
[57] OFF D#4
[0] OFF F#4
[10] OFF C#4
[77] ON C#4 v100
[0] ON D#4 v100
[0] ON F#4 v100
[57] OFF D#4
[0] OFF F#4
[10] OFF C#4
[77] ON C#4 v100
[0] ON D#4 v100
[0] ON F#4 v100
[57] OFF D#4
[0] OFF F#4
[20] OFF C#4
[76] ON C#4 v100
[0] ON D#4 v100
[0] ON F#4 v100
[58] OFF D#4
[0] OFF F#4
[19] OFF C#4
[77] ON C#4 v100
[0] ON D#4 v100
[0] ON F#4 v100
[58] OFF D#4
[0] OFF F#4
[9] OFF C#4
[77] ON C#4 v100
[0] ON D#4 v100
[0] ON F#4 v100
[58] OFF D#4
[0] OFF F#4
[9] OFF C#4
[77] ON C#4 v100
[0] ON D#4 v100
[0] ON F#4 v100
[58] OFF D#4
[0] OFF F#4
[9] OFF C#4
[77] ON C#4 v100
[0] ON D#4 v100
[0] ON F#4 v100
[58] OFF D#4
[0] OFF F#4
[9] OFF C#4
[77] ON C#4 v100
[0] ON D#4 v100
[0] ON F#4 v100
[58] OFF D#4
[0] OFF F#4
[9] OFF C#4
[77] ON C#4 v100
[0] ON D#4 v100
[0] ON F#4 v100
[58] OFF D#4
[0] OFF F#4
[9] OFF C#4

轨道 #7
[160963] ON C#5 v100
[2217] OFF C#5

轨道 #8
[98611] ON C#4 v100
[3622] OFF C#4
[16365] ON E3 v100
[0] ON A3 v100
[1329] OFF E3
[2387] OFF A3
[0] ON F#3 v100
[0] ON B3 v100
[0] ON D#4 v100
[1545] OFF F#3
[2170] OFF B3
[0] OFF D#4
[35453] ON G#6 v100
[38] ON E6 v100
[86] OFF G#6
[10] ON D#6 v100
[10] OFF E6
[76] OFF D#6
[29] ON C#6 v100
[67] ON G#5 v100
[1382] OFF C#6
[0] OFF G#5
[26151] ON E4 v100
[1373] OFF E4
[37910] ON C#5 v100
[5342] OFF C#5

轨道 #9
[108442] ON C#4 v100
[1655] OFF C#4
[27087] ON C#4 v100
[437] OFF C#4
[21854] ON A3 v100
[394] OFF A3
[1939] ON C#4 v100
[739] OFF C#4
[0] ON C#4 v100
[250] OFF C#4
[19] ON C#4 v100
[364] OFF C#4
[15889] ON D4 v100
[393] OFF D4
[10] ON C#4 v100
[384] OFF C#4
[346] ON C#4 v100
[393] OFF C#4
[12682] ON A2 v100
[249] OFF A2
[10] ON A2 v100
[240] OFF A2
[10] ON A2 v100
[240] OFF A2
[9] ON A2 v100
[250] OFF A2
[9] ON A2 v100
[240] OFF A2
[10] ON A2 v100
[92] OFF A2
[29610] ON A2 v100
[240] OFF A2
[10] ON A2 v100
[240] OFF A2
[10] ON G2 v100
[240] OFF G2

轨道 #10
[184829] ON D2 v100
[0] ON G2 v100
[9] OFF D2
[0] OFF G2
[240] ON D2 v100
[0] ON G2 v100
[10] OFF D2
[0] OFF G2
[115] ON D2 v100
[0] ON G2 v100
[10] OFF D2
[0] OFF G2
[125] ON D2 v100
[9] OFF D2
[96] ON D2 v100
[10] OFF D2
[134] ON D2 v100
[10] OFF D2
[0] ON G2 v100
[9] OFF G2
[231] ON D2 v100
[9] OFF D2
[0] ON G2 v100
[10] OFF G2
[115] ON D2 v100
[10] OFF D2
[0] ON G2 v100
[9] OFF G2
[106] ON D2 v100
[10] OFF D2
[0] ON G2 v100
[9] OFF G2
[115] ON D2 v100
[10] OFF D2
[0] ON G2 v100
[10] OFF G2
[115] ON D2 v100
[9] OFF D2
[0] ON G2 v100
[10] OFF G2
[2362] ON C2 v100
[9] OFF C2
[163] ON G2 v100
[10] OFF G2
[0] ON C3 v100
[10] OFF C3
[124] ON C3 v100
[10] OFF C3
[0] ON G2 v100
[10] OFF G2
[105] ON C2 v100
[10] OFF C2
[115] ON G2 v100
[0] ON C3 v100
[10] OFF G2
[0] OFF C3
[134] ON C3 v100
[10] OFF C3
[0] ON G2 v100
[9] OFF G2
[115] ON C2 v100
[10] OFF C2
[96] ON D2 v100
[10] OFF D2
[9] ON G2 v100
[10] OFF G2
[115] ON C2 v100
[10] OFF C2
[105] ON D2 v100
[10] OFF D2
[9] ON G2 v100
[10] OFF G2
[106] ON C2 v100
[9] OFF C2
[115] ON D2 v100
[10] OFF D2
[10] ON G2 v100
[9] OFF G2
[115] ON C2 v100
[10] OFF C2
[106] ON D2 v100
[9] OFF D2
[10] ON G2 v100
[9] OFF G2
[106] ON C2 v100
[10] OFF C2
[6105] ON D2 v100
[10] OFF D2
[0] ON G2 v100
[9] OFF G2
[125] ON D2 v100
[10] OFF D2
[0] ON G2 v100
[9] OFF G2
[116] ON D2 v100
[9] OFF D2
[0] ON G2 v100
[10] OFF G2
[125] ON D2 v100
[0] ON G2 v100
[9] OFF D2
[0] OFF G2
[221] ON D2 v100
[0] ON G2 v100
[10] OFF D2
[0] OFF G2
[115] ON G2 v100
[9] OFF G2
[10] ON D2 v100
[10] OFF D2
[105] ON G2 v100
[10] OFF G2
[19] ON D2 v100
[10] OFF D2
[67] ON F#2 v100
[9] OFF F#2
[10] ON G2 v100
[10] OFF G2
[0] ON D2 v100
[9] OFF D2
[106] ON D2 v100
[9] OFF D2
[10] ON G2 v100
[10] OFF G2
[86] ON F#2 v100
[10] OFF F#2
[124] ON D2 v100
[10] OFF D2
[0] ON G2 v100
[10] OFF G2
[105] ON D2 v100
[10] OFF D2
[0] ON G2 v100
[9] OFF G2
[116] ON D2 v100
[9] OFF D2
[0] ON G2 v100
[10] OFF G2
[105] ON D2 v100
[10] OFF D2
[0] ON G2 v100
[10] OFF G2
[115] ON D2 v100
[0] ON G2 v100
[9] OFF D2
[0] OFF G2
[240] ON D2 v100
[0] ON G2 v100
[10] OFF D2
[0] OFF G2
[125] ON G2 v100
[9] OFF G2
[0] ON D2 v100
[10] OFF D2
[115] ON G2 v100
[10] OFF G2
[0] ON D2 v100
[9] OFF D2
[106] ON G2 v100
[10] OFF G2
[0] ON D2 v100
[9] OFF D2
[115] ON G2 v100
[10] OFF G2
[0] ON D2 v100
[10] OFF D2
[105] ON G2 v100
[10] OFF G2
[9] ON D2 v100
[10] OFF D2
[106] ON G2 v100
[9] OFF G2
[0] ON D2 v100
[10] OFF D2
[105] ON G2 v100
[10] OFF G2
[0] ON D2 v100
[10] OFF D2
[115] ON G2 v100
[9] OFF G2
[0] ON D2 v100
[10] OFF D2
[106] ON G2 v100
[9] OFF G2
[0] ON D2 v100
[10] OFF D2
[115] ON D2 v100
[0] ON G2 v100
[10] OFF D2
[0] OFF G2
[230] ON G2 v100
[10] OFF G2
[0] ON D2 v100
[9] OFF D2
[13930] ON D2 v100
[0] ON G2 v100
[9] OFF D2
[0] OFF G2
[116] ON D2 v100
[9] OFF D2
[0] ON G2 v100
[10] OFF G2
[115] ON C2 v100
[10] OFF C2
[115] ON D2 v100
[0] ON G2 v100
[9] OFF D2
[0] OFF G2
[125] ON D2 v100
[0] ON G2 v100
[10] OFF D2
[0] OFF G2
[115] ON C2 v100
[10] OFF C2
[115] ON D2 v100
[0] ON G2 v100
[9] OFF D2
[0] OFF G2
[116] ON G2 v100
[9] OFF G2
[0] ON D2 v100
[10] OFF D2
[115] ON G2 v100
[10] OFF G2
[0] ON D2 v100
[9] OFF D2
[106] ON C2 v100
[9] OFF C2
[125] ON C2 v100
[10] OFF C2
[115] ON G2 v100
[10] OFF G2
[0] ON D2 v100
[9] OFF D2
[490] ON D2 v100
[0] ON G2 v100
[9] OFF D2
[0] OFF G2
[231] ON D2 v100
[9] OFF D2
[0] ON G2 v100
[10] OFF G2
[115] ON G2 v100
[10] OFF G2
[0] ON D2 v100
[9] OFF D2
[116] ON G2 v100
[9] OFF G2
[0] ON D2 v100
[10] OFF D2
[115] ON D2 v100
[0] ON G2 v100
[10] OFF D2
[0] OFF G2
[115] ON D2 v100
[0] ON G2 v100
[9] OFF D2
[0] OFF G2
[116] ON C2 v100
[9] OFF C2
[125] ON C2 v100
[10] OFF C2
[489] ON G2 v100
[10] OFF G2
[0] ON D2 v100
[9] OFF D2
[2343] ON D2 v100
[0] ON G2 v100
[9] OFF D2
[0] OFF G2
[202] ON D2 v100
[10] OFF D2
[0] ON G2 v100
[9] OFF G2
[106] ON G2 v100
[9] OFF G2
[0] ON D2 v100
[10] OFF D2
[106] ON G2 v100
[9] OFF G2
[0] ON D2 v100
[10] OFF D2
[115] ON D2 v100
[0] ON G2 v100
[10] OFF D2
[0] OFF G2
[115] ON G2 v100
[9] OFF G2
[0] ON D2 v100
[10] OFF D2
[230] ON G2 v100
[10] OFF G2
[0] ON D2 v100
[10] OFF D2
[115] ON G2 v100
[9] OFF G2
[0] ON D2 v100
[10] OFF D2
[115] ON G2 v100
[10] OFF G2
[0] ON D2 v100
[9] OFF D2
[106] ON D2 v100
[0] ON G2 v100
[10] OFF D2
[0] OFF G2
[115] ON G2 v100
[9] OFF G2
[0] ON D2 v100
[10] OFF D2
[230] ON G2 v100
[10] OFF G2
[0] ON D2 v100
[10] OFF D2
[115] ON D2 v100
[0] ON G2 v100
[9] OFF D2
[0] OFF G2
[116] ON D2 v100
[9] OFF D2
[0] ON G2 v100
[10] OFF G2
[115] ON D2 v100
[10] OFF D2
[0] ON G2 v100
[9] OFF G2
[115] ON D2 v100
[10] OFF D2
[0] ON G2 v100
[10] OFF G2
[105] ON C2 v100
[10] OFF C2
[115] ON G2 v100
[0] ON C3 v100
[10] OFF G2
[0] OFF C3
[115] ON C3 v100
[9] OFF C3
[0] ON G2 v100
[10] OFF G2
[115] ON C3 v100
[10] OFF C3
[0] ON G2 v100
[9] OFF G2
[106] ON G2 v100
[10] OFF G2
[0] ON C3 v100
[9] OFF C3
[106] ON G2 v100
[9] OFF G2
[0] ON D2 v100
[10] OFF D2
[106] ON C2 v100
[9] OFF C2
[115] ON G2 v100
[10] OFF G2
[0] ON D2 v100
[10] OFF D2
[115] ON C2 v100
[9] OFF C2
[116] ON D2 v100
[0] ON G2 v100
[9] OFF D2
[0] OFF G2
[115] ON C2 v100
[10] OFF C2
[125] ON G2 v100
[9] OFF G2
[0] ON D2 v100
[10] OFF D2
]]

-- 解析MIDI数据
local midiEvents = parseMidiEvents(midiText)

-- 按时间排序事件
table.sort(midiEvents, function(a, b) 
    return a.time < b.time 
end)

-- 播放MIDI序列
local function playMIDITime = 0
    local startTime = os.clock()
    
    for _, event in ipairs(midiEvents) do
        -- 计算等待时间 (480 ticks = 1 beat, 120 BPM = 0.5s per beat)
        local waitTime = (event.time - lastTime) / 960
        if waitTime > 0 then
            sleep(waitTime)
        end
        lastTime = event.time
        
        if event.action == "ON" then
            playNote(event.track, event.note, event.velocity)
        end
    end
    
    -- 播放完成后停止所有声音
    speaker.stop()
end

-- 主程序
print("Starting MIDI playback...")
playMIDI()
print("Playback complete")