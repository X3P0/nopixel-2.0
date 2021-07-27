Config = {}

Config.version = "3.1.0"

------- Modules -------
Config.enableDebug = false
Config.enableGrids = true
Config.enableRadio = true
Config.enablePhone = true
Config.enableMegaphone = true
Config.enablePodium = true
Config.enableGag = true
Config.enableGaze = true
Config.setProximityEvents = true
Config.enableToko = true
Config.enableSpeaker = true
Config.enableSubmixes = true
Config.environmentalEffects = true
Config.enableFilters = {
    phone = true,
    radio = true,
    megaphone = true,
    podium = true,
    gag = true
}

------- Default Settings -------

Config.settings = {
    ["releaseDelay"] = 200,
    ["stereoAudio"] = false,
    ["localClickOn"] = false,
    ["localClickOff"] = false,
    ["remoteClickOn"] = false,
    ["remoteClickOff"] = false,
    ["clickVolume"] = 0.8,
    ["radioVolume"] = 0.8,
    ["phoneVolume"] = 0.8
}

------- Voice Proximity -------

Config.voiceRanges = {
    { name = "whisper", range = 0.8 },
    { name = "normal", range = 2.0 },
    { name = "shout", range = 4.0 }
}

------- Hotkeys Config -------

Config.cycleProximityHotkey = "z"
Config.cycleRadioChannelHotkey = "i"
Config.transmitToRadioHotkey = "capital"
Config.phoneLoudSpeaker = "plus"

------- Modules Config -------

-- Speaker Module
Config.speakerDistance = 2.0
Config.radioSpeaker = true
Config.phoneSpeaker = true

-- Radio Module
Config.enableMultiFrequency = false

-- Grid Module
Config.gridSize = 384
Config.gridEdge = 192
Config.gridMinX = -4600
Config.gridMaxX = 4600
Config.gridMaxY = 9200
