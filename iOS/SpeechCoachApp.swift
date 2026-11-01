import SwiftUI
#if canImport(SpeechCoachCore)
import SpeechCoachCore
#endif

@main
struct SpeechCoachApp: App {
    @StateObject private var session = TrainingSession()

    var body: some Scene {
        WindowGroup {
            RootView(session: session)
        }
    }
}
