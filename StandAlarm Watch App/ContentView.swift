import SwiftUI
import WatchKit

struct ContentView: View {
    @State private var selectedFrequency = 1
    @State private var isRunning = false
    @State private var isVibrating = false
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?

    @State private var isSoundOn = false  // 🔊 New switch

    private let debugRate: TimeInterval = 0.01
    private let standTimeout: Int = 30

    private var frequencies: [TimeInterval] {
        [0, 1800, 3600, 7200].map { $0 * debugRate }
    }

    var body: some View {
        VStack(spacing: 12) {
            Picker("Frequency", selection: $selectedFrequency) {
                Text("Off").tag(0)
                Text("0.5 hr").tag(1)
                Text("1 hr").tag(2)
                Text("2 hr").tag(3)
            }
            .labelsHidden()
            .pickerStyle(.wheel)
            .frame(height: 85)
            .focusable(true)

            // 🔘 Sound toggle + timer status side-by-side
            HStack {
//                Toggle("", isOn: $isSoundOn)
//                    .labelsHidden()
//                    .toggleStyle(SwitchToggleStyle()) // 📌 Tiny switch
//                    .frame(width: 40)

                // Status block
                VStack {
                    if isRunning {
                        Text("⏱️ \(Int(timeRemaining)) seconds left")
                            .font(.headline)
                        Button("Stop") {
                            stopTimer()
                        }
                        .buttonStyle(.borderedProminent)
                    } else if isVibrating {
                        Text("⏱️ Time to Stand!")
                            .font(.headline)
                        Button("Stop") {
                            stopTimer()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Text("⏱️ Wait to start")
                            .font(.headline)
                        Button("Start") {
                            startTimer()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

        }
        .padding()
        .onTapGesture {
            stopTimer()
        }
    }

    func startTimer() {
        let duration = frequencies[selectedFrequency]
        guard duration > 0 else { return }
        timeRemaining = duration
        isRunning = true
        isVibrating = false

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                stopTimer()
                triggerVibration()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isVibrating = false
    }

    func triggerVibration() {
        isVibrating = true
        for i in 0..<standTimeout {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                WKInterfaceDevice.current().play(.notification)
//                if isSoundOn {
//                    // 🎵 Play sound – this is a placeholder
//                    print("🔊 Sound played")
//                    // On real watchOS, use AudioToolbox or AVFoundation if needed
//                }
            }
        }
    }
}
