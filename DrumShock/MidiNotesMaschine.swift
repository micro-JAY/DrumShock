//
//  MidiNotesMaschine.swift
//  DrumShock
//
//  MIDI note mappings optimized for Maschine 3
//  These match Maschine's default 16-pad layout
//

import Foundation

// Maschine's default pad layout (bottom-left to top-right)
enum MidiNotesMaschine {
    // Bottom row (Pads 13-16)
    static let cross = 36      // C1 - Pad 13
    static let circle = 37     // C#1 - Pad 14  
    static let square = 38     // D1 - Pad 15
    static let triangle = 39   // D#1 - Pad 16
    
    // Second row (Pads 9-12)
    static let dpadLeft = 40   // E1 - Pad 9
    static let dpadDown = 41   // F1 - Pad 10
    static let dpadRight = 42  // F#1 - Pad 11
    static let dpadUp = 43     // G1 - Pad 12
    
    // Third row (Pads 5-8)
    static let l1 = 44         // G#1 - Pad 5
    static let r1 = 45         // A1 - Pad 6
    static let l2 = 46         // A#1 - Pad 7
    static let r2 = 47         // B1 - Pad 8
    
    // Top row (Pads 1-4) - Could map additional buttons
    static let l3 = 48         // C2 - Pad 1
    static let r3 = 49         // C#2 - Pad 2
    static let touchpad = 50   // D2 - Pad 3
    static let options = 51    // D#2 - Pad 4
}