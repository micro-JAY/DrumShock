//
//  DrumShockApp.swift
//  DrumShock
//
//  Main entry point for the PS5 to MIDI converter app
//

import SwiftUI

@main
struct DrumShockApp: App {
    // Create instances of our controller managers
    @StateObject private var gameControllerManager = GameControllerManager()
    @StateObject private var midiController = MidiController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameControllerManager)
                .environmentObject(midiController)
                .frame(minWidth: 600, minHeight: 400)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
    }
}