# DrumShock - PS5 Controller to MIDI Converter

Currently needs to be built via xCode


## Setup Instructions

1. **Open in Xcode**
   - Open Xcode and create a new macOS app project
   - Choose SwiftUI as the interface
   - Name it "DrumShock"
   - Set the bundle identifier (e.g., com.yourname.drumshock)
   - Replace the generated files with the files in the DrumShock folder

2. **Configure Project Settings**
   - Select your project in the navigator
   - Under "Signing & Capabilities":
     - Add your development team
     - Enable "Bluetooth" capability
   - Under "Info":
     - Make sure the Info.plist includes Bluetooth usage descriptions

3. **Build and Run**
   - Select your Mac as the build target
   - Click the Run button or press Cmd+R
   - The app will launch showing the connection status

## Using the App

1. **Connect PS5 Controller**
   - Put your PS5 controller in pairing mode (hold PS + Create buttons)
   - Connect via Bluetooth in System Preferences
   - The app will automatically detect the controller

2. **Set Up Your DAW**
   - Open your favorite DAW (Logic Pro, Ableton, GarageBand, etc.)
   - Create a new MIDI track
   - Select "DrumShock Virtual Output" as the MIDI input
   - Load a drum kit instrument

3. **Play!**
   - Use the button mappings shown in the app
   - Face buttons trigger basic drum sounds
   - Triggers and shoulder buttons for cymbals and toms
   - D-pad for additional drums

## Button Mappings

| PS5 Button | MIDI Note | Drum Sound |
|------------|-----------|------------|
| Cross (X) | C2 (36) | Kick Drum |
| Circle | D2 (38) | Snare Drum |
| Square | F#2 (42) | Closed Hi-Hat |
| Triangle | A#2 (46) | Open Hi-Hat |
| L1 | C#3 (49) | Crash Cymbal |
| R1 | D#3 (51) | Ride Cymbal |
| L2 | A2 (45) | Low Tom |
| R2 | C3 (48) | High Tom |
| D-Pad Up | D3 (50) | High Tom 2 |
| D-Pad Down | B2 (47) | Mid Tom |
| D-Pad Left | G2 (43) | Low Floor Tom |
| D-Pad Right | F2 (41) | High Floor Tom |

## Troubleshooting

- **Controller not detected**: Make sure Bluetooth is enabled and the controller is paired
- **No MIDI output**: Check that your DAW is set to receive from "DrumShock Virtual Output"
- **Latency issues**: This is usually DAW-related; adjust your audio buffer settings

## Code Structure

- `DrumShockApp.swift` - Main app entry point
- `ContentView.swift` - User interface and status display
- `GameControllerManager.swift` - Handles PS5 controller input
- `MidiController.swift` - Manages MIDI output
- `Info.plist` - App permissions and configuration
