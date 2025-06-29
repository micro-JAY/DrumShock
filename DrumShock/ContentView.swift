//
//  ContentView.swift
//  DrumShock
//
//  Main user interface showing connection status and button mappings
//

import SwiftUI

struct ContentView: View {
    // Access our controller managers from the environment
    @EnvironmentObject var gameControllerManager: GameControllerManager
    @EnvironmentObject var midiController: MidiController
    
    // State for showing settings
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with title and settings
            HStack {
                VStack(alignment: .leading) {
                    Text("DrumShock")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("PS5 Controller to MIDI Converter")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showingSettings.toggle() }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            // Mode selector
            HStack {
                Text("Mode:")
                    .fontWeight(.semibold)
                
                Picker("DAW Mode", selection: $midiController.currentMode) {
                    ForEach(DAWMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 400)
                
                Text("(Press \(gameControllerManager.modeSwitchButton.rawValue) to switch)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            
            // Connection status
            HStack(spacing: 40) {
                // Controller status
                VStack {
                    HStack {
                        Circle()
                            .fill(gameControllerManager.isControllerConnected ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        
                        Text("Controller")
                            .fontWeight(.semibold)
                    }
                    Text(gameControllerManager.connectedControllerName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // MIDI status
                VStack {
                    HStack {
                        Circle()
                            .fill(midiController.isConnected ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        
                        Text("MIDI Output")
                            .fontWeight(.semibold)
                    }
                    Text(midiController.isConnected ? "DrumShock Virtual Output" : "Not Connected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Mode-specific options
            if midiController.currentMode == .maschine {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Maschine Options")
                        .font(.headline)
                    
                    Picker("Features", selection: $midiController.maschineMode) {
                        ForEach(MaschineMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    
                    if midiController.maschineMode != .pads {
                        Text("• Options/Create: Pattern switching")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if midiController.maschineMode == .withScenes {
                        Text("• L3/R3: Scene switching")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.05))
                .cornerRadius(10)
            }
            
            if midiController.currentMode == .abletonSession {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ableton Options")
                        .font(.headline)
                    
                    Picker("Features", selection: $midiController.abletonMode) {
                        ForEach(AbletonMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    
                    if midiController.abletonMode == .withScenes {
                        Text("• Options/Create/L3: Scene launch 1-3")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if midiController.abletonMode == .withTransport {
                        Text("• Options: Play, Create: Stop, L3: Record")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.purple.opacity(0.05))
                .cornerRadius(10)
            }
            
            // Activity monitor
            HStack(spacing: 30) {
                VStack {
                    Text("Last Button")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(gameControllerManager.lastPressedButton)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                
                VStack {
                    Text("Last MIDI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(midiController.lastSentNote)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(.purple)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)
            
            // Dynamic button mappings based on mode
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(getMappingTitle())
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    ForEach(getCurrentMappings(), id: \.button) { mapping in
                        MappingRow(
                            button: mapping.button,
                            midi: mapping.midi,
                            instrument: mapping.instrument
                        )
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding(25)
        .frame(width: 800, height: 900)
        .onAppear {
            // Connect the game controller manager to the MIDI controller
            gameControllerManager.setMidiController(midiController)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(gameControllerManager: gameControllerManager)
        }
    }
    
    // Get mapping title based on current mode
    func getMappingTitle() -> String {
        switch midiController.currentMode {
        case .standardDrums:
            return "Button Mappings (Standard Drum Kit)"
        case .maschine:
            return "Button Mappings (Maschine Pads)"
        case .maschineScenes:
            return "Button Mappings (Maschine Scene Control)"
        case .abletonSession:
            return "Button Mappings (Ableton Session View)"
        case .ableSample:
            return "Drum Rack Sampler mode"
        }
    }
    
    // Get current mappings based on mode
    func getCurrentMappings() -> [(button: String, midi: String, instrument: String)] {
        switch midiController.currentMode {
        case .standardDrums:
            return [
                ("✕ (Cross)", "C2 (36)", "Kick Drum"),
                ("○ (Circle)", "D2 (38)", "Snare Drum"),
                ("□ (Square)", "F#2 (42)", "Closed Hi-Hat"),
                ("△ (Triangle)", "A#2 (46)", "Open Hi-Hat"),
                ("L1", "C#3 (49)", "Crash Cymbal"),
                ("R1", "D#3 (51)", "Ride Cymbal"),
                ("L2", "A2 (45)", "Low Tom"),
                ("R2", "C3 (48)", "High Tom"),
                ("D-Pad Up", "D3 (50)", "High Tom 2"),
                ("D-Pad Down", "B2 (47)", "Mid Tom"),
                ("D-Pad Left", "G2 (43)", "Low Floor Tom"),
                ("D-Pad Right", "F2 (41)", "High Floor Tom")
            ]
        case .maschine:
            return [
                ("✕ (Cross)", "C1 (36)", "Pad 13"),
                ("○ (Circle)", "C#1 (37)", "Pad 14"),
                ("□ (Square)", "D1 (38)", "Pad 15"),
                ("△ (Triangle)", "D#1 (39)", "Pad 16"),
                ("D-Pad Left", "E1 (40)", "Pad 9"),
                ("D-Pad Down", "F1 (41)", "Pad 10"),
                ("D-Pad Right", "F#1 (42)", "Pad 11"),
                ("D-Pad Up", "G1 (43)", "Pad 12"),
                ("L1", "G#1 (44)", "Pad 5"),
                ("R1", "A1 (45)", "Pad 6"),
                ("L2", "A#1 (46)", "Pad 7"),
                ("R2", "B1 (47)", "Pad 8")
            ]
        case .maschineScenes:
            return [
                ("✕ (Cross)", "C2 (48)", "Scene 1"),
                ("○ (Circle)", "C#2 (49)", "Scene 2"),
                ("□ (Square)", "D2 (50)", "Scene 3"),
                ("△ (Triangle)", "D#2 (51)", "Scene 4"),
                ("D-Pad Left", "E2 (52)", "Scene 5"),
                ("D-Pad Down", "F2 (53)", "Scene 6"),
                ("D-Pad Right", "F#2 (54)", "Scene 7"),
                ("D-Pad Up", "G2 (55)", "Scene 8"),
                ("L1", "-", "Reserved"),
                ("R1", "-", "Reserved"),
                ("L2", "-", "Reserved"),
                ("R2", "-", "Reserved")
            ]
        case .abletonSession:
            return [
                ("✕ (Cross)", "F3 (53)", "Clip 1,1"),
                ("○ (Circle)", "F#3 (54)", "Clip 2,1"),
                ("□ (Square)", "G3 (55)", "Clip 3,1"),
                ("△ (Triangle)", "G#3 (56)", "Clip 4,1"),
                ("D-Pad Left", "C#3 (49)", "Clip 1,2"),
                ("D-Pad Down", "D3 (50)", "Clip 2,2"),
                ("D-Pad Right", "D#3 (51)", "Clip 3,2"),
                ("D-Pad Up", "E3 (52)", "Clip 4,2"),
                ("L1", "A2 (45)", "Clip 1,3"),
                ("R1", "A#2 (46)", "Clip 2,3"),
                ("L2", "B2 (47)", "Clip 3,3"),
                ("R2", "C3 (48)", "Clip 4,3")
            ]
        case .ableSample:
            return [
                ("✕ (Cross)", "C1 (36)", "Pad 13"),
                ("○ (Circle)", "C#1 (37)", "Pad 14"),
                ("□ (Square)", "D1 (38)", "Pad 15"),
                ("△ (Triangle)", "D#1 (39)", "Pad 16"),
                ("D-Pad Left", "E1 (40)", "Pad 9"),
                ("D-Pad Down", "F1 (41)", "Pad 10"),
                ("D-Pad Right", "F#1 (42)", "Pad 11"),
                ("D-Pad Up", "G1 (43)", "Pad 12"),
                ("L1", "G#1 (44)", "Pad 5"),
                ("R1", "A1 (45)", "Pad 6"),
                ("L2", "A#1 (46)", "Pad 7"),
                ("R2", "B1 (47)", "Pad 8")
            ]
        }
    }
}

// Settings view
struct SettingsView: View {
    @ObservedObject var gameControllerManager: GameControllerManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Mode Switch Button")
                    .font(.headline)
                
                Picker("Switch modes with:", selection: $gameControllerManager.modeSwitchButton) {
                    ForEach(ModeSwitchButton.allCases, id: \.self) { button in
                        Text(button.description).tag(button)
                    }
                }
                .pickerStyle(.radioGroup)
                
                Text("Press the selected button to cycle through DAW modes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(30)
        .frame(width: 500, height: 400)
    }
}

// Helper view for button mapping rows
struct MappingRow: View {
    let button: String
    let midi: String
    let instrument: String
    
    var body: some View {
        HStack {
            Text(button)
                .frame(width: 120, alignment: .leading)
                .fontWeight(.medium)
            
            Text("→")
                .foregroundColor(.secondary)
            
            Text(midi)
                .frame(width: 80, alignment: .leading)
                .foregroundColor(.blue)
            
            Text(instrument)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.system(size: 13, design: .monospaced))
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GameControllerManager())
            .environmentObject(MidiController())
    }
}
