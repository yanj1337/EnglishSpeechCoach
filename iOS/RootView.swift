import SwiftUI
#if canImport(SpeechCoachCore)
import SpeechCoachCore
#endif

struct RootView: View {
    @ObservedObject var session: TrainingSession

    var body: some View {
        NavigationStack {
            Group {
                switch session.route {
                case .home: HomeView(session: session)
                case .modeSelection: ModeSelectionView(session: session)
                case .task: TaskView(session: session)
                case .response: ResponseView(session: session)
                case .feedback: FeedbackView(session: session)
                case .statistics: StatisticsView(session: session)
                }
            }
            .animation(.easeInOut(duration: 0.18), value: session.route)
        }
        .tint(.blue)
    }
}

private struct Screen<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(title).font(.largeTitle.bold())
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
    }
}

private struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(title, action: action)
            .font(.headline).frame(maxWidth: .infinity).padding()
            .background(.blue, in: RoundedRectangle(cornerRadius: 14)).foregroundStyle(.white)
    }
}

private struct HomeView: View {
    @ObservedObject var session: TrainingSession
    var body: some View {
        Screen(title: "Practice speaking") {
            Text("React to an unexpected situation in English. Speak naturally; improve one thing at a time.")
                .foregroundStyle(.secondary)
            PrimaryButton(title: "Start practice", action: session.start)
            Button("View statistics", action: session.showStatistics).frame(maxWidth: .infinity)
        }
    }
}

private struct ModeSelectionView: View {
    @ObservedObject var session: TrainingSession
    var body: some View {
        Screen(title: "Choose a mode") {
            ForEach(TrainingMode.allCases, id: \.self) { mode in
                Button { session.select(mode) } label: {
                    HStack { Text(mode.rawValue).font(.headline); Spacer(); Image(systemName: "chevron.right") }
                        .padding().background(.background, in: RoundedRectangle(cornerRadius: 14))
                }.buttonStyle(.plain)
            }
            Button("Back", action: session.goHome)
        }
    }
}

private struct TaskView: View {
    @ObservedObject var session: TrainingSession
    var body: some View {
        Screen(title: "Your situation") {
            Text(session.task.situation).font(.title3.bold())
            Text(session.task.prompt)
            Text("Use these words").font(.caption.bold()).foregroundStyle(.secondary)
            HStack { ForEach(session.task.requiredWords, id: \.self) { Text($0).padding(.horizontal, 12).padding(.vertical, 8).background(.blue.opacity(0.12), in: Capsule()) } }
            PrimaryButton(title: "Answer aloud", action: session.beginResponse)
        }
    }
}

private struct ResponseView: View {
    @ObservedObject var session: TrainingSession
    @State private var isRecording = false
    @State private var transcript = "When will the room be available? Meanwhile, may I leave my bags here?"
    var body: some View {
        Screen(title: "Your answer") {
            Text("Prototype input: tap the microphone, then edit the live transcript if needed.").foregroundStyle(.secondary)
            TextEditor(text: $transcript).frame(minHeight: 120).padding(8).background(.background, in: RoundedRectangle(cornerRadius: 12))
            Button {
                withAnimation { isRecording.toggle() }
            } label: {
                Image(systemName: isRecording ? "stop.fill" : "mic.fill").font(.system(size: 32))
                    .frame(width: 76, height: 76).background(isRecording ? .red : .blue, in: Circle()).foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            if isRecording { Text("Listening… words will be colored as confidence arrives.").frame(maxWidth: .infinity).foregroundStyle(.red) }
            PrimaryButton(title: "Analyze answer") { isRecording = false; session.submit(transcript: transcript) }
        }
    }
}

private struct FeedbackView: View {
    @ObservedObject var session: TrainingSession
    var body: some View {
        Screen(title: "Feedback") {
            if let feedback = session.feedback {
                Text("Speech segments").font(.headline)
                FlowLayout(items: feedback.segments)
                HStack { Label("Clear", systemImage: "circle.fill").foregroundStyle(.green); Label("Check", systemImage: "circle.fill").foregroundStyle(.orange); Label("Retry", systemImage: "circle.fill").foregroundStyle(.red) }.font(.caption)
                Text("Answer relevance: \(feedback.relevanceScore)%").font(.title3.bold())
                ProgressView(value: Double(feedback.relevanceScore), total: 100)
                Text(feedback.coachingTip).padding().background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }
            PrimaryButton(title: "Try again", action: session.retry)
            Button("View statistics", action: session.showStatistics).frame(maxWidth: .infinity)
            Button("Home", action: session.goHome).frame(maxWidth: .infinity)
        }
    }
}

private struct FlowLayout: View {
    let items: [SpeechSegment]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 7)], alignment: .leading, spacing: 7) {
            ForEach(items) { item in Text(item.text).padding(.horizontal, 8).padding(.vertical, 5).background(color(item.quality).opacity(0.18), in: RoundedRectangle(cornerRadius: 7)).foregroundStyle(color(item.quality)) }
        }
    }
    private func color(_ quality: SegmentQuality) -> Color {
        switch quality { case .strong: .green; case .uncertain: .orange; case .needsWork: .red }
    }
}

private struct StatisticsView: View {
    @ObservedObject var session: TrainingSession
    var body: some View {
        Screen(title: "Statistics") {
            HStack(spacing: 12) {
                StatCard(value: "\(session.completedAttempts)", label: "Attempts")
                StatCard(value: session.feedback.map { "\($0.relevanceScore)%" } ?? "—", label: "Latest relevance")
            }
            Text("The first version keeps statistics intentionally small: completed attempts, target-word usage, and answer relevance.").foregroundStyle(.secondary)
            PrimaryButton(title: "Practice again", action: session.start)
            Button("Home", action: session.goHome).frame(maxWidth: .infinity)
        }
    }
}

private struct StatCard: View {
    let value: String; let label: String
    var body: some View { VStack { Text(value).font(.title.bold()); Text(label).font(.caption).foregroundStyle(.secondary) }.frame(maxWidth: .infinity).padding().background(.background, in: RoundedRectangle(cornerRadius: 14)) }
}
