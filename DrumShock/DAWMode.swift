//
//  DAWMode.swift
//  DrumShock
//
//  Defines different DAW modes and their MIDI mappings
// 

import Foundation

// Available DAW modes
enum DAWMode: String, CaseIterable {
    case standardDrums = "Standard Drums"
    case maschine = "Maschine 3"
    case maschineScenes = "Maschine Scenes"
    case abletonSession = "Ableton Session"
    case ableSample = "Drum Rack Sampler"

    
    var description: String {
        switch self {
        case .standardDrums:
            return "General MIDI drum mapping"
        case .maschine:
            return "Optimized for Maschine 3 pads"
        case .maschineScenes:
            return "Maschine scene switching"
        case .abletonSession:
            return "Ableton Live session view control"
        case .ableSample:
            return "Drum Rack Sampler mode"
        }
    }
}

// Maschine-specific features
enum MaschineMode: String, CaseIterable {
    case pads = "Pads Only"
    case withPatterns = "Pads + Patterns"
    case withScenes = "Pads + Scenes"
}

// Ableton-specific features  
enum AbletonMode: String, CaseIterable {
    case clips = "Clip Launch"
    case withScenes = "Clips + Scenes"
    case withTransport = "Full Control"
}

// MIDI mappings for Standard Drums mode
struct StandardDrumNotes {
    static let cross = UInt8(36)      // C2 - Kick drum
    static let circle = UInt8(38)     // D2 - Snare drum
    static let square = UInt8(42)     // F#2 - Closed hi-hat
    static let triangle = UInt8(46)   // A#2 - Open hi-hat
    static let l1 = UInt8(49)         // C#3 - Crash cymbal
    static let r1 = UInt8(51)         // D#3 - Ride cymbal
    static let l2 = UInt8(45)         // A2 - Low tom
    static let r2 = UInt8(48)         // C3 - High tom
    static let dpadUp = UInt8(50)     // D3 - High tom 2
    static let dpadDown = UInt8(47)   // B2 - Mid tom
    static let dpadLeft = UInt8(43)   // G2 - Low floor tom
    static let dpadRight = UInt8(41)  // F2 - High floor tom
}

// MIDI mappings for Drum Sampler mode
struct SamplerNotes {
    static let cross = UInt8(36)      // C1 - Pad 13
    static let circle = UInt8(37)     // C#1 - Pad 14
    static let square = UInt8(38)     // D1 - Pad 15
    static let triangle = UInt8(39)   // D#1 - Pad 16
    static let dpadLeft = UInt8(40)   // E1 - Pad 9
    static let dpadDown = UInt8(41)   // F1 - Pad 10
    static let dpadRight = UInt8(42)  // F#1 - Pad 11
    static let dpadUp = UInt8(43)     // G1 - Pad 12
    static let l1 = UInt8(44)         // G#1 - Pad 5
    static let r1 = UInt8(45)         // A1 - Pad 6
    static let l2 = UInt8(46)         // A#1 - Pad 7
    static let r2 = UInt8(47)         // B1 - Pad 8
}

// MIDI mappings for Maschine mode
struct MaschineNotes {
    // Bottom row (Pads 13-16)
    static let cross = UInt8(36)      // C1 - Pad 13
    static let circle = UInt8(37)     // C#1 - Pad 14
    static let square = UInt8(38)     // D1 - Pad 15
    static let triangle = UInt8(39)   // D#1 - Pad 16
    
    // Second row (Pads 9-12)
    static let dpadLeft = UInt8(40)   // E1 - Pad 9
    static let dpadDown = UInt8(41)   // F1 - Pad 10
    static let dpadRight = UInt8(42)  // F#1 - Pad 11
    static let dpadUp = UInt8(43)     // G1 - Pad 12
    
    // Third row (Pads 5-8)
    static let l1 = UInt8(44)         // G#1 - Pad 5
    static let r1 = UInt8(45)         // A1 - Pad 6
    static let l2 = UInt8(46)         // A#1 - Pad 7
    static let r2 = UInt8(47)         // B1 - Pad 8
    
    // Scene selection (top row, for example)
    static let scene1 = UInt8(48)     // C2 - Scene 1
    static let scene2 = UInt8(49)     // C#2 - Scene 2
    static let scene3 = UInt8(50)     // D2 - Scene 3
    static let scene4 = UInt8(51)     // D#2 - Scene 4
    static let scene5 = UInt8(52)     // E2 - Scene 5
    static let scene6 = UInt8(53)     // F2 - Scene 6
    static let scene7 = UInt8(54)     // F#2 - Scene 7
    static let scene8 = UInt8(55)     // G2 - Scene 8
    
    // Pattern switching (CC messages)
    static let patternPrev = UInt8(106)  // CC 106
    static let patternNext = UInt8(107)  // CC 107
    
    // Scene switching  
    static let scenePrev = UInt8(108)    // CC 108
    static let sceneNext = UInt8(109)    // CC 109
}

// MIDI mappings for Ableton Session View
struct AbletonNotes {
    // Clip launching (first 4x3 grid)
    static let cross = UInt8(53)      // F3 - Clip 1,1
    static let circle = UInt8(54)     // F#3 - Clip 2,1
    static let square = UInt8(55)     // G3 - Clip 3,1
    static let triangle = UInt8(56)   // G#3 - Clip 4,1
    
    static let dpadLeft = UInt8(49)   // C#3 - Clip 1,2
    static let dpadDown = UInt8(50)   // D3 - Clip 2,2
    static let dpadRight = UInt8(51)  // D#3 - Clip 3,2
    static let dpadUp = UInt8(52)     // E3 - Clip 4,2
    
    static let l1 = UInt8(45)         // A2 - Clip 1,3
    static let r1 = UInt8(46)         // A#2 - Clip 2,3
    static let l2 = UInt8(47)         // B2 - Clip 3,3
    static let r2 = UInt8(48)         // C3 - Clip 4,3
    
    // Scene launching (CC messages)
    static let sceneLaunch1 = UInt8(82)  // CC 82 - Scene 1
    static let sceneLaunch2 = UInt8(83)  // CC 83 - Scene 2
    static let sceneLaunch3 = UInt8(84)  // CC 84 - Scene 3
    
    // Transport controls
    static let play = UInt8(116)         // CC 116 - Play
    static let stop = UInt8(117)         // CC 117 - Stop
    static let record = UInt8(118)       // CC 118 - Record
}

// Mode switch button options
enum ModeSwitchButton: String, CaseIterable {
    case ps = "PS Button"
    case create = "Create Button"
    case touchpad = "Touchpad Press"
    case leftStick = "Left Stick Press"
    case rightStick = "Right Stick Press"
    
    var description: String {
        return self.rawValue
    }
}
