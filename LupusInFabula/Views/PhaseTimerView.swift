//
//  PhaseTimerView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import SwiftUI
import Combine

struct PhaseTimerView: View {
    let totalSeconds: Int
    let onTimeUp: () -> Void
    
    @State private var remainingSeconds: Int
    @State private var timer: Timer?
    @State private var isActive: Bool = false
    
    init(totalSeconds: Int, onTimeUp: @escaping () -> Void) {
        self.totalSeconds = totalSeconds
        self.onTimeUp = onTimeUp
        self._remainingSeconds = State(initialValue: totalSeconds)
    }
    
    var body: some View {
        if totalSeconds > 0 {
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // Timer display
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(.orange)
                        
                        Text(timeString)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                    
                    Spacer()
                    
                    // Control buttons
                    HStack(spacing: 12) {
                        if !isActive && remainingSeconds == totalSeconds {
                            Button("Start Timer") {
                                startTimer()
                            }
                            .buttonStyle(.bordered)
                            .foregroundStyle(.orange)
                        } else if isActive {
                            Button("Pause") {
                                pauseTimer()
                            }
                            .buttonStyle(.bordered)
                            .foregroundStyle(.orange)
                        } else if !isActive && remainingSeconds < totalSeconds {
                            Button("Resume") {
                                startTimer()
                            }
                            .buttonStyle(.bordered)
                            .foregroundStyle(.orange)
                        }
                        
                        if remainingSeconds < totalSeconds {
                            Button("Reset") {
                                resetTimer()
                            }
                            .buttonStyle(.bordered)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .frame(height: 6)
                        
                        Rectangle()
                            .fill(.orange)
                            .frame(
                                width: geometry.size.width * progress,
                                height: 6
                            )
                            .animation(.linear(duration: 0.5), value: progress)
                    }
                    .clipShape(Capsule())
                }
                .frame(height: 6)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onDisappear {
                stopTimer()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var timeString: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "%02d", seconds)
        }
    }
    
    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }
    
    // MARK: - Timer Methods
    
    private func startTimer() {
        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                timeUp()
            }
        }
    }
    
    private func pauseTimer() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }
    
    private func stopTimer() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        remainingSeconds = totalSeconds
    }
    
    private func timeUp() {
        stopTimer()
        onTimeUp()
    }
}

#Preview {
    VStack(spacing: 20) {
        PhaseTimerView(totalSeconds: 90) {
            print("Timer finished!")
        }
        
        PhaseTimerView(totalSeconds: 30) {
            print("Short timer finished!")
        }
        
        // Disabled timer (0 seconds)
        PhaseTimerView(totalSeconds: 0) {
            print("No timer")
        }
    }
    .padding()
}
