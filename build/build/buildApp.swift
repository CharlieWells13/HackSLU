import SwiftUI
import AVFoundation

@main
struct YourAppName: App {
    init() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession.setActive(true)
            print("Audio session activated with sample rate: \(audioSession.sampleRate)")
        } catch {
            print("Error configuring audio session: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
