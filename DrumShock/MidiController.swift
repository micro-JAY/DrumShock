//
//  MidiController.swift
//  DrumShock
//
//  Handles all MIDI output functionality
//  This class creates a virtual MIDI output port and sends MIDI messages
//

import Foundation
import CoreMIDI
import SwiftUI

class MidiController: ObservableObject {
    // Published properties for UI updates
    @Published var isConnected = false
    @Published var lastSentNote: String = "None"
    @Published var currentMode: DAWMode = .standardDrums
    @Published var maschineMode: MaschineMode = .pads
    @Published var abletonMode: AbletonMode = .clips
    
    // MIDI client and port references
    private var midiClient: MIDIClientRef = 0
    private var outputPort: MIDIPortRef = 0
    private var virtualEndpoint: MIDIEndpointRef = 0
    
    // MIDI channel (0-15, displayed as 1-16 to users)
    private let midiChannel: UInt8 = 9  // Channel 10 - standard for drums
    
    
    init() {
        setupMidi()
    }
    
    // Initialize MIDI client and create virtual output
    private func setupMidi() {
        // Create MIDI client
        let clientName = "DrumShock MIDI Client" as CFString
        let status = MIDIClientCreateWithBlock(clientName, &midiClient) { notification in
            // Handle MIDI setup changes if needed
            print("MIDI Notification: \(notification)")
        }
        
        guard status == noErr else {
            print("Failed to create MIDI client: \(status)")
            return
        }
        
        // Create virtual MIDI source (appears as input in other apps)
        let sourceName = "DrumShock Virtual Output" as CFString
        let sourceStatus = MIDISourceCreate(midiClient, sourceName, &virtualEndpoint)
        
        guard sourceStatus == noErr else {
            print("Failed to create virtual MIDI source: \(sourceStatus)")
            return
        }
        
        // Create output port for sending MIDI
        let portName = "DrumShock Output Port" as CFString
        let portStatus = MIDIOutputPortCreate(midiClient, portName, &outputPort)
        
        guard portStatus == noErr else {
            print("Failed to create output port: \(portStatus)")
            return
        }
        
        isConnected = true
        print("MIDI setup complete!")
    }
    
    // Send a MIDI note on message
    func sendNoteOn(note: UInt8, velocity: UInt8 = 127) {
        // MIDI note on message format:
        // Status byte: 0x90 + channel (0-15)
        // Data byte 1: Note number (0-127)
        // Data byte 2: Velocity (0-127)
        
        var packet = MIDIPacket()
        packet.timeStamp = mach_absolute_time()
        packet.length = 3
        packet.data.0 = 0x90 + midiChannel  // Note on + channel
        packet.data.1 = note                 // Note number
        packet.data.2 = velocity             // Velocity
        
        var packetList = MIDIPacketList(numPackets: 1, packet: packet)
        
        // Send to virtual endpoint
        let status = MIDIReceived(virtualEndpoint, &packetList)
        
        if status == noErr {
            DispatchQueue.main.async {
                self.lastSentNote = "Note \(note) (velocity: \(velocity))"
            }
        }
    }
    
    // Send a MIDI note off message
    func sendNoteOff(note: UInt8) {
        // MIDI note off message format:
        // Status byte: 0x80 + channel (0-15)
        // Data byte 1: Note number (0-127)
        // Data byte 2: Velocity (usually 0 for note off)
        
        var packet = MIDIPacket()
        packet.timeStamp = mach_absolute_time()
        packet.length = 3
        packet.data.0 = 0x80 + midiChannel  // Note off + channel
        packet.data.1 = note                 // Note number
        packet.data.2 = 0                   // Velocity (0 for note off)
        
        var packetList = MIDIPacketList(numPackets: 1, packet: packet)
        
        // Send to virtual endpoint
        MIDIReceived(virtualEndpoint, &packetList)
    }
    
    // Send a MIDI Control Change message
    func sendControlChange(cc: UInt8, value: UInt8 = 127) {
        // MIDI CC message format:
        // Status byte: 0xB0 + channel (0-15)
        // Data byte 1: CC number (0-127)
        // Data byte 2: Value (0-127)
        
        var packet = MIDIPacket()
        packet.timeStamp = mach_absolute_time()
        packet.length = 3
        packet.data.0 = 0xB0 + midiChannel  // CC + channel
        packet.data.1 = cc                  // CC number
        packet.data.2 = value               // Value
        
        var packetList = MIDIPacketList(numPackets: 1, packet: packet)
        
        // Send to virtual endpoint
        let status = MIDIReceived(virtualEndpoint, &packetList)
        
        if status == noErr {
            DispatchQueue.main.async {
                self.lastSentNote = "CC \(cc) (value: \(value))"
            }
        }
    }
    
    // Get the appropriate note number based on current mode and button
    func getNoteForButton(_ button: String) -> UInt8? {
        switch currentMode {
        case .standardDrums:
            return getStandardDrumNote(button)
        case .maschine:
            return getMaschineNote(button)
        case .maschineScenes:
            return getMaschineSceneNote(button)
        case .abletonSession:
            return getAbletonNote(button)
        case .ableSample:
            return getSamplerNote(button)
        }
    }
    
    private func getStandardDrumNote(_ button: String) -> UInt8? {
        switch button {
        case "cross": return StandardDrumNotes.cross
        case "circle": return StandardDrumNotes.circle
        case "square": return StandardDrumNotes.square
        case "triangle": return StandardDrumNotes.triangle
        case "l1": return StandardDrumNotes.l1
        case "r1": return StandardDrumNotes.r1
        case "l2": return StandardDrumNotes.l2
        case "r2": return StandardDrumNotes.r2
        case "dpadUp": return StandardDrumNotes.dpadUp
        case "dpadDown": return StandardDrumNotes.dpadDown
        case "dpadLeft": return StandardDrumNotes.dpadLeft
        case "dpadRight": return StandardDrumNotes.dpadRight
        default: return nil
        }
    }
    
    private func getMaschineNote(_ button: String) -> UInt8? {
        switch button {
        case "cross": return MaschineNotes.cross
        case "circle": return MaschineNotes.circle
        case "square": return MaschineNotes.square
        case "triangle": return MaschineNotes.triangle
        case "l1": return MaschineNotes.l1
        case "r1": return MaschineNotes.r1
        case "l2": return MaschineNotes.l2
        case "r2": return MaschineNotes.r2
        case "dpadUp": return MaschineNotes.dpadUp
        case "dpadDown": return MaschineNotes.dpadDown
        case "dpadLeft": return MaschineNotes.dpadLeft
        case "dpadRight": return MaschineNotes.dpadRight
        default: return nil
        }
    }
    
    private func getAbletonNote(_ button: String) -> UInt8? {
        switch button {
        case "cross": return AbletonNotes.cross
        case "circle": return AbletonNotes.circle
        case "square": return AbletonNotes.square
        case "triangle": return AbletonNotes.triangle
        case "l1": return AbletonNotes.l1
        case "r1": return AbletonNotes.r1
        case "l2": return AbletonNotes.l2
        case "r2": return AbletonNotes.r2
        case "dpadUp": return AbletonNotes.dpadUp
        case "dpadDown": return AbletonNotes.dpadDown
        case "dpadLeft": return AbletonNotes.dpadLeft
        case "dpadRight": return AbletonNotes.dpadRight
        default: return nil
        }
    }
    
    private func getSamplerNote(_ button: String) -> UInt8? {
        switch button {
        case "cross": return SamplerNotes.cross
        case "circle": return SamplerNotes.circle
        case "square": return SamplerNotes.square
        case "triangle": return SamplerNotes.triangle
        case "l1": return SamplerNotes.l1
        case "r1": return SamplerNotes.r1
        case "l2": return SamplerNotes.l2
        case "r2": return SamplerNotes.r2
        case "dpadUp": return SamplerNotes.dpadUp
        case "dpadDown": return SamplerNotes.dpadDown
        case "dpadLeft": return SamplerNotes.dpadLeft
        case "dpadRight": return SamplerNotes.dpadRight
        default: return nil
        }
    }
    
    private func getMaschineSceneNote(_ button: String) -> UInt8? {
        switch button {
        case "cross": return MaschineNotes.scene1      // Scene 1
        case "circle": return MaschineNotes.scene2     // Scene 2
        case "square": return MaschineNotes.scene3     // Scene 3
        case "triangle": return MaschineNotes.scene4   // Scene 4
        case "dpadLeft": return MaschineNotes.scene5   // Scene 5
        case "dpadDown": return MaschineNotes.scene6   // Scene 6
        case "dpadRight": return MaschineNotes.scene7  // Scene 7
        case "dpadUp": return MaschineNotes.scene8     // Scene 8
        case "l1", "r1", "l2", "r2":
            // These buttons can be used for other scene functions
            return nil
        default: return nil
        }
    }
    
    // Handle special control functions
    func handleSpecialControl(_ control: String, pressed: Bool) {
        guard pressed else { return } // Only act on press, not release
        
        switch currentMode {
        case .maschine:
            handleMaschineControl(control)
        case .abletonSession:
            handleAbletonControl(control)
        default:
            break
        }
    }
    
    private func handleMaschineControl(_ control: String) {
        switch maschineMode {
        case .withPatterns:
            switch control {
            case "options": sendControlChange(cc: MaschineNotes.patternNext)
            case "create": sendControlChange(cc: MaschineNotes.patternPrev)
            default: break
            }
        case .withScenes:
            switch control {
            case "options": sendControlChange(cc: MaschineNotes.patternNext)
            case "create": sendControlChange(cc: MaschineNotes.patternPrev)
            case "leftStick": sendControlChange(cc: MaschineNotes.sceneNext)
            case "rightStick": sendControlChange(cc: MaschineNotes.scenePrev)
            default: break
            }
        default:
            break
        }
    }
    
    private func handleAbletonControl(_ control: String) {
        switch abletonMode {
        case .withScenes:
            switch control {
            case "options": sendControlChange(cc: AbletonNotes.sceneLaunch1)
            case "create": sendControlChange(cc: AbletonNotes.sceneLaunch2)
            case "leftStick": sendControlChange(cc: AbletonNotes.sceneLaunch3)
            default: break
            }
        case .withTransport:
            switch control {
            case "options": sendControlChange(cc: AbletonNotes.play)
            case "create": sendControlChange(cc: AbletonNotes.stop)
            case "leftStick": sendControlChange(cc: AbletonNotes.record)
            case "rightStick": sendControlChange(cc: AbletonNotes.sceneLaunch1)
            default: break
            }
        default:
            break
        }
    }
    
    
    // Clean up MIDI resources
    deinit {
        if virtualEndpoint != 0 {
            MIDIEndpointDispose(virtualEndpoint)
        }
        if outputPort != 0 {
            MIDIPortDispose(outputPort)
        }
        if midiClient != 0 {
            MIDIClientDispose(midiClient)
        }
    }
}
