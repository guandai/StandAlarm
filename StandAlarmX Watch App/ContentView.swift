import SwiftUI
import UserNotifications
import WatchKit

struct ContentView: View {
    @State private var selectedFrequency = 1
    @State private var isRunning = false
    @State private var isVibrating = false
    @State private var startDate: Date?
    @State private var duration: TimeInterval = 0
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?

    @State private var isSoundOn = false  // 🔊 New switch
    @State private var isNotificationStopped = false // Track notification stop state

    private let debugRate: TimeInterval = 1
    private let standTimeout: Int = 30

    private var frequencies: [TimeInterval] {
        [0, 30, 1800, 3600, 7200].map { $0 * debugRate }
    }
    private var freq_texts: [String] {
        ["Off", "30 sec", "0.5 hr", "1 hr", "2 hr"]
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
            .frame(height: 90)
            .focusable(true)
        }
    }

    struct TimerView: View {
        @Binding var isRunning: Bool
        @Binding var isVibrating: Bool
        @Binding var timeRemaining: TimeInterval
        @Binding var isNotificationStopped: Bool
        let freq_texts: [String]
        let frequencies: [TimeInterval]
        let selectedFrequency: Int
        let startTimer: () -> Void
        let stopNotification: () -> Void
        let stopTimerLoop: () -> Void

        var body: some View {
            VStack {
                if isRunning {
                    Text("⏱️ \(Int(timeRemaining)) seconds left")
                        .font(.headline)
                    HStack {
                        Button("Silent...") {
                            stopNotification()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)

                        Button("Stop!") {
                            stopTimerLoop()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                } else if isVibrating {
                    Text("⏱️ Time to Stand!")
                        .font(.headline)
                    Button("Stop") {
                        stopTimerLoop()
                    }
                    .buttonStyle(.borderedProminent)
                } else if selectedFrequency == 0 {
                    Text("⏱️ Off")
                        .font(.headline)
                    Button("Off") {}

                } else {
                    Text("⏱️ Wait to start")
                        .font(.headline)
                    Button("Remind Each \(freq_texts[selectedFrequency])") {
                        startTimer()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            FrequencyPickerView(
                selectedFrequency: $selectedFrequency,
                freq_texts: freq_texts
            )

            TimerView(
                isRunning: $isRunning,
                isVibrating: $isVibrating,
                timeRemaining: $timeRemaining,
                isNotificationStopped: $isNotificationStopped,
                freq_texts: freq_texts,
                frequencies: frequencies,
                selectedFrequency: selectedFrequency,
                startTimer: startTimer,
                stopNotification: stopNotification,
                stopTimerLoop: stopTimerLoop
            )
        }
        .padding()
        .onTapGesture {
            updateTimeRemaining()
            stopTimerLoop()  // Stop the loop when tapping
        }
        .onAppear {
            requestNotificationPermission()
            if isRunning {
                updateTimeRemaining()
                startBackgroundTimer() // Start background timer
            }
        }
        .onDisappear {
            stopTimerLoop() // Ensure the timer is stopped when leaving the app
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert, .sound,
        ]) { success, error in
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

        // Run a background timer using notifications
        startBackgroundTimer()
    }

    func updateTimeRemaining() {
        guard let startDate else { return }
        let elapsed = Date().timeIntervalSince(startDate)
        let remaining = duration - elapsed
        if remaining <= 0 {
            stopTimerLoop()
            triggerNotification() // Trigger notification when the time is up
            startTimer() // Start a new timer after time is up
        } else {
            timeRemaining = remaining
        }
    }

    func startBackgroundTimer() {
        var loopCounter = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeRemaining()
            
            if !isNotificationStopped && loopCounter > 0 {
                loopCounter += 1
                triggerNotification() // Trigger periodic notifications in the background
            }
        }
    }

    func stopNotification() {
        isNotificationStopped = true
        print("Notifications stopped.")
    }

    func stopTimerLoop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isVibrating = false
        isNotificationStopped = false
        print("Timer loop stopped.")
    }

    func triggerNotification() {
        isVibrating = true
        // Trigger vibration
        WKInterfaceDevice.current().play(.notification)

        let content = UNMutableNotificationContent()
        content.title = "Time to Stand!"
        content.body = "Please stand up and move around."
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Immediate notification
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}
