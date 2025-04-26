import SwiftUI
import WatchKit
import UserNotifications

struct ContentView: View {
    @State private var selectedFrequency = 1
    @State private var isRunning = false
    @State private var isVibrating = false
    @State private var startDate: Date?
    @State private var duration: TimeInterval = 0
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?

    @State private var isSoundOn = false  // 🔊 New switch

    private let debugRate: TimeInterval = 1
    private let standTimeout: Int = 30

    private var frequencies: [TimeInterval] {
        [0, 5, 1800, 3600, 7200].map { $0 * debugRate }
    }
    private var freq_texts: [String] {
        ["Off", "5 sec", "0.5 hr", "1 hr", "2 hr"]
    }
    
    struct FrequencyPickerView: View {
        @Binding var selectedFrequency: Int
        let freq_texts: [String]

        var body: some View {
            Picker("Frequency", selection: $selectedFrequency) {
                ForEach(freq_texts.indices, id: \.self) { index in
                    Text(freq_texts[index])
                        .tag(index)
                        .font(.headline)
                        .foregroundColor(index == 0 ? .gray : .blue)
                }
            }
            .labelsHidden()
            .pickerStyle(.wheel)
            .frame(height: 85)
            .focusable(true)
        }
    }

    struct TimerView: View {
        @Binding var isRunning: Bool
        @Binding var isVibrating: Bool
        @Binding var timeRemaining: TimeInterval
        let frequencies: [TimeInterval]
        let selectedFrequency: Int
        let startTimer: () -> Void
        let stopTimer: () -> Void

        var body: some View {
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
                    Button("Remind Each \(Int(frequencies[selectedFrequency]))") {
                        startTimer()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            FrequencyPickerView(selectedFrequency: $selectedFrequency, freq_texts: freq_texts)

            TimerView(
                isRunning: $isRunning,
                isVibrating: $isVibrating,
                timeRemaining: $timeRemaining,
                frequencies: frequencies,
                selectedFrequency: selectedFrequency,
                startTimer: startTimer,
                stopTimer: stopTimer
            )
        }
        .padding()
        .onTapGesture {
            updateTimeRemaining()
            stopTimer()
        }
        .onAppear {
            requestNotificationPermission()

            if isRunning {
                updateTimeRemaining()
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    updateTimeRemaining()
                }
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                print("Notifications permission granted ✅")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func startTimer() {
        duration = frequencies[selectedFrequency]
        guard duration > 0 else { return }
        startDate = Date()
        timeRemaining = duration
        isRunning = true
        isVibrating = false

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeRemaining()
        }
    }

    func updateTimeRemaining() {
        guard let startDate else { return }
        let elapsed = Date().timeIntervalSince(startDate)
        let remaining = duration - elapsed
        if remaining <= 0 {
            stopTimer()
            triggerNotification()
        } else {
            timeRemaining = remaining
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isVibrating = false
    }

    func triggerNotification() {
        isVibrating = true

        let content = UNMutableNotificationContent()
        content.title = "Time to Stand!"
        content.body = "Please stand up and move around."
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}
