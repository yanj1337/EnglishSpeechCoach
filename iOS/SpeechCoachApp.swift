import SwiftUI
#if canImport(SpeechCoachCore)
import SpeechCoachCore
#endif

@main
struct SpeechCoachApp: App {
    @StateObject private var session = TrainingSession()
    @State private var showingLaunch = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showingLaunch { LaunchScreen() }
                else { RootView(session: session) }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(650))
                withAnimation(.easeOut(duration: 0.2)) { showingLaunch = false }
            }
        }
    }
}

private struct LaunchScreen: View {
    var body: some View { Color.blue.opacity(0.72).ignoresSafeArea() }
}
