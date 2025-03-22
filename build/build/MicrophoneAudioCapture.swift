import AVFoundation

class MicrophoneAudioCapture {
    static let shared = MicrophoneAudioCapture()
    private let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private var audioPlayer: AVAudioPlayer?  // Persist the player instance
    private let fileURL: URL

    private init() {
        // Save the file to the Documents directory so it persists
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documents.appendingPathComponent("recording.caf")
    }

    func startCapturing() {
        let inputNode = audioEngine.inputNode
        // Use the input node’s actual hardware format
        let recordingFormat = inputNode.inputFormat(forBus: 0)
        print("Using recording format: \(recordingFormat)")

        // Remove any existing file
        try? FileManager.default.removeItem(at: fileURL)
        
        do {
            // Create an AVAudioFile for writing using the hardware format settings
            audioFile = try AVAudioFile(forWriting: fileURL, settings: recordingFormat.settings)
        } catch {
            print("Error creating audio file: \(error)")
            return
        }

        // Install a tap on the input node to capture audio buffers
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
            guard let self = self else { return }
            do {
                try self.audioFile?.write(from: buffer)
            } catch {
                print("Error writing audio buffer: \(error)")
            }
        }

        do {
            try audioEngine.start()
            print("Audio engine started, recording...")
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }

    func stopCapturing() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        print("Stopped recording. Audio file saved at: \(fileURL)")
    }

    func playRecording() {
        do {
            // Keep the player in a property so it isn't deallocated immediately.
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("Playing recording from: \(fileURL)")
        } catch {
            print("Error playing recording: \(error)")
        }
    }
}
