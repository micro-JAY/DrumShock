//
//  GameControllerManager.swift
//  DrumShock
//
//  Manages PS5 controller connection and input handling
//  This class detects controller connections and maps button presses to MIDI notes
//

import Foundation
import GameController
import SwiftUI

class GameControllerManager: ObservableObject {
    // Published properties for UI updates
    @Published var isControllerConnected = false
    @Published var connectedControllerName = "None"
    @Published var lastPressedButton = "None"
    @Published var modeSwitchButton: ModeSwitchButton = .ps
    
    // Reference to the MIDI controller
    private var midiController: MidiController?
    
    // Currently connected controller
    private var controller: GCController?
    
    // Track button states to handle press/release
    private var buttonStates: [String: Bool] = [:]
    
    // Track currently held notes for repeat functionality
    private var currentlyHeldNotes: Set<UInt8> = []
    
    // Current mode index for cycling through modes
    private var currentModeIndex = 0
    
    private var noteRepeatTimer: Timer?
    private var currentRepeatDirection: String?
    
    init() {
        setupControllerNotifications()
        checkForControllers()
    }
    
    // Set the MIDI controller reference
    func setMidiController(_ midi: MidiController) {
        self.midiController = midi
    }
    
    // Set up notifications for controller connection/disconnection
    private func setupControllerNotifications() {
        // Listen for controller connections
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidConnect),
            name: .GCControllerDidConnect,
            object: nil
        )
        
        // Listen for controller disconnections
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidDisconnect),
            name: .GCControllerDidDisconnect,
            object: nil
        )
    }
    
    // Check for already connected controllers
    private func checkForControllers() {
        GCController.startWirelessControllerDiscovery()
        
        if let controller = GCController.controllers().first {
            self.connectController(controller)
        }
    }
    
    // Handle controller connection
    @objc private func controllerDidConnect(_ notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        connectController(controller)
    }
    
    // Handle controller disconnection
    @objc private func controllerDidDisconnect(_ notification: Notification) {
        DispatchQueue.main.async {
            self.isControllerConnected = false
            self.connectedControllerName = "None"
            self.controller = nil
        }
    }
    
    // Connect to a controller and set up input handlers
    private func connectController(_ controller: GCController) {
        self.controller = controller
        
        DispatchQueue.main.async {
            self.isControllerConnected = true
            self.connectedControllerName = controller.vendorName ?? "Unknown Controller"
        }
        
        // Set up input handlers for DualSense (PS5) controller
        guard let dualsense = controller.extendedGamepad else {
            print("Controller doesn't support extended gamepad profile")
            return
        }
        
        // Map face buttons (Cross, Circle, Square, Triangle)
        setupButton(dualsense.buttonA, name: "Cross (X)", id: "cross")
        setupButton(dualsense.buttonB, name: "Circle", id: "circle")
        setupButton(dualsense.buttonX, name: "Square", id: "square")
        setupButton(dualsense.buttonY, name: "Triangle", id: "triangle")
        
        // Map shoulder buttons
        setupButton(dualsense.leftShoulder, name: "L1", id: "l1")
        setupButton(dualsense.rightShoulder, name: "R1", id: "r1")
        
        // Map triggers as buttons (when pressed beyond threshold)
        setupTrigger(dualsense.leftTrigger, name: "L2", id: "l2")
        setupTrigger(dualsense.rightTrigger, name: "R2", id: "r2")
        
        // Map D-pad buttons
        setupButton(dualsense.dpad.up, name: "D-Pad Up", id: "dpadUp")
        setupButton(dualsense.dpad.down, name: "D-Pad Down", id: "dpadDown")
        setupButton(dualsense.dpad.left, name: "D-Pad Left", id: "dpadLeft")
        setupButton(dualsense.dpad.right, name: "D-Pad Right", id: "dpadRight")
        
        // Map special buttons
        setupSpecialButton(dualsense.buttonHome, name: "PS", id: "ps")
        setupSpecialButton(dualsense.buttonOptions, name: "Options", id: "options")
        setupSpecialButton(dualsense.buttonMenu, name: "Create", id: "create")
        setupSpecialButton(dualsense.leftThumbstickButton, name: "L3", id: "leftStick")
        setupSpecialButton(dualsense.rightThumbstickButton, name: "R3", id: "rightStick")
        
        // Left analog stick for note repeat ONLY
        dualsense.leftThumbstick.valueChangedHandler = { [weak self] dpad, xValue, yValue in
            guard let self = self else { return }
            let threshold: Float = 0.7
            var direction: String?
            var interval: TimeInterval = 0.0

            if xValue < -threshold {
                direction = "left"
                interval = 0.5 // 1/4 note
            } else if yValue > threshold {
                direction = "up"
                interval = 0.25 // 1/8 note
            } else if xValue > threshold {
                direction = "right"
                interval = 0.166 // 1/8 triplet
            } else if yValue < -threshold {
                direction = "down"
                interval = 0.125 // 1/16 note
            }

            if let direction = direction {
                if self.currentRepeatDirection != direction {
                    self.startNoteRepeat(direction: direction, interval: interval)
                }
            } else {
                self.stopNoteRepeat()
            }
        }
    }
    
    // Set up button press/release handlers
    private func setupButton(_ button: GCControllerButtonInput, name: String, id: String) {
        // Initialize button state
        buttonStates[name] = false
        
        // Set up value changed handler
        button.valueChangedHandler = { [weak self] button, value, pressed in
            guard let self = self else { return }
            
            // Check if this is a new press or release
            let wasPressed = self.buttonStates[name] ?? false
            
            if pressed && !wasPressed {
                // Button just pressed - send note on
                if let note = self.midiController?.getNoteForButton(id) {
                    self.midiController?.sendNoteOn(note: note)
                    // Add to currently held notes
                    self.currentlyHeldNotes.insert(note)
                    DispatchQueue.main.async {
                        self.lastPressedButton = name
                    }
                }
            } else if !pressed && wasPressed {
                // Button just released - send note off
                if let note = self.midiController?.getNoteForButton(id) {
                    self.midiController?.sendNoteOff(note: note)
                    // Remove from currently held notes
                    self.currentlyHeldNotes.remove(note)
                }
            }
            
            // Update button state
            self.buttonStates[name] = pressed
        }
    }
    
    // Set up trigger handlers (treated as buttons with threshold)
    private func setupTrigger(_ trigger: GCControllerButtonInput, name: String, id: String) {
        // Initialize trigger state
        buttonStates[name] = false
        
        // Set up value changed handler
        trigger.valueChangedHandler = { [weak self] trigger, value, pressed in
            guard let self = self else { return }
            
            // Treat trigger as pressed when value > 0.5
            let isPressed = value > 0.5
            let wasPressed = self.buttonStates[name] ?? false
            
            if isPressed && !wasPressed {
                // Trigger just pressed - send note on with velocity based on pressure
                let velocity = UInt8(value * 127)
                if let note = self.midiController?.getNoteForButton(id) {
                    self.midiController?.sendNoteOn(note: note, velocity: velocity)
                    // Add to currently held notes
                    self.currentlyHeldNotes.insert(note)
                    DispatchQueue.main.async {
                        self.lastPressedButton = "\(name) (velocity: \(velocity))"
                    }
                }
            } else if !isPressed && wasPressed {
                // Trigger just released - send note off
                if let note = self.midiController?.getNoteForButton(id) {
                    self.midiController?.sendNoteOff(note: note)
                    // Remove from currently held notes
                    self.currentlyHeldNotes.remove(note)
                }
            }
            
            // Update trigger state
            self.buttonStates[name] = isPressed
        }
    }
    
    // Set up special button handlers (mode switch, special controls)
    private func setupSpecialButton(_ button: GCControllerButtonInput?, name: String, id: String) {
        guard let button = button else { return }
        
        // Initialize button state
        buttonStates[name] = false
        
        // Set up value changed handler
        button.valueChangedHandler = { [weak self] button, value, pressed in
            guard let self = self else { return }
            
            // Check if this is a new press or release
            let wasPressed = self.buttonStates[name] ?? false
            
            if pressed && !wasPressed {
                // Check if this is the mode switch button
                if self.shouldSwitchMode(buttonId: id) {
                    self.switchToNextMode()
                } else {
                    // Handle as special control
                    self.midiController?.handleSpecialControl(id, pressed: true)
                }
                
                DispatchQueue.main.async {
                    self.lastPressedButton = name
                }
            } else if !pressed && wasPressed {
                // Handle release for special controls
                if !self.shouldSwitchMode(buttonId: id) {
                    self.midiController?.handleSpecialControl(id, pressed: false)
                }
            }
            
            // Update button state
            self.buttonStates[name] = pressed
        }
    }
    
    // Check if button should trigger mode switch
    private func shouldSwitchMode(buttonId: String) -> Bool {
        switch modeSwitchButton {
        case .ps: return buttonId == "ps"
        case .create: return buttonId == "create"
        case .touchpad: return buttonId == "touchpad"
        case .leftStick: return buttonId == "leftStick"
        case .rightStick: return buttonId == "rightStick"
        }
    }
    
    // Switch to next DAW mode
    private func switchToNextMode() {
        guard let midiController = midiController else { return }
        
        let modes = DAWMode.allCases
        currentModeIndex = (currentModeIndex + 1) % modes.count
        midiController.currentMode = modes[currentModeIndex]
        
        DispatchQueue.main.async {
            self.lastPressedButton = "Mode: \(midiController.currentMode.rawValue)"
        }
    }
    
    private func startNoteRepeat(direction: String, interval: TimeInterval) {
        stopNoteRepeat()
        currentRepeatDirection = direction
        noteRepeatTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Repeat all currently held notes
            for note in self.currentlyHeldNotes {
                self.midiController?.sendNoteOn(note: note)
                // Optionally, sendNoteOff after a short delay for staccato effect
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.midiController?.sendNoteOff(note: note)
                }
            }
        }
    }
    
    private func stopNoteRepeat() {
        noteRepeatTimer?.invalidate()
        noteRepeatTimer = nil
        currentRepeatDirection = nil
    }
    
    // Helper to map button display name to button ID
    private func getButtonId(for name: String) -> String? {
        // Map your display names to IDs as used in setupButton/setupTrigger
        switch name {
        case "Cross (X)": return "cross"
        case "Circle": return "circle"
        case "Square": return "square"
        case "Triangle": return "triangle"
        case "L1": return "l1"
        case "R1": return "r1"
        case "L2": return "l2"
        case "R2": return "r2"
        case "D-Pad Up": return "dpadUp"
        case "D-Pad Down": return "dpadDown"
        case "D-Pad Left": return "dpadLeft"
        case "D-Pad Right": return "dpadRight"
        case "PS": return "ps"
        case "Options": return "options"
        case "Create": return "create"
        case "L3": return "leftStick"
        case "R3": return "rightStick"
        case "Touchpad": return "touchpad"
        default: return nil
        }
    }
    
    // Clean up
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
