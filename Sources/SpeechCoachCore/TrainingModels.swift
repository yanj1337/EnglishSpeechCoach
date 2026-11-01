import Foundation

public enum AppRoute: Equatable, Sendable {
    case home, modeSelection, task, response, feedback, statistics
}

public enum TrainingMode: String, CaseIterable, Sendable {
    case quick = "Quick practice"
    case situation = "Situation"
    case review = "Word review"
}

public struct SpeakingTask: Equatable, Sendable {
    public let situation: String
    public let prompt: String
    public let requiredWords: [String]

    public init(situation: String, prompt: String, requiredWords: [String]) {
        self.situation = situation
        self.prompt = prompt
        self.requiredWords = requiredWords
    }

    public static let sample = SpeakingTask(
        situation: "You are checking in at a hotel. Your room is not ready.",
        prompt: "Ask when it will be ready and suggest what you can do while you wait.",
        requiredWords: ["available", "meanwhile"]
    )
}

public enum SegmentQuality: String, Sendable {
    case strong, uncertain, needsWork
}

public struct SpeechSegment: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let text: String
    public let quality: SegmentQuality

    public init(id: UUID = UUID(), text: String, quality: SegmentQuality) {
        self.id = id
        self.text = text
        self.quality = quality
    }
}

public struct AttemptFeedback: Equatable, Sendable {
    public let transcript: String
    public let segments: [SpeechSegment]
    public let usedRequiredWords: [String]
    public let relevanceScore: Int
    public let coachingTip: String

    public init(transcript: String, segments: [SpeechSegment], usedRequiredWords: [String], relevanceScore: Int, coachingTip: String) {
        self.transcript = transcript
        self.segments = segments
        self.usedRequiredWords = usedRequiredWords
        self.relevanceScore = relevanceScore
        self.coachingTip = coachingTip
    }
}

public struct PrototypeAnalyzer: Sendable {
    public init() {}

    public func analyze(_ transcript: String, task: SpeakingTask) -> AttemptFeedback {
        let words = transcript.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        let normalized = transcript.lowercased()
        let used = task.requiredWords.filter { normalized.contains($0.lowercased()) }
        let segments = words.enumerated().map { index, word in
            SpeechSegment(text: word, quality: quality(for: word, at: index))
        }
        let relevance = min(100, 45 + used.count * 20 + min(words.count, 15))
        let missing = task.requiredWords.filter { !used.contains($0) }
        let tip = missing.isEmpty
            ? "Good: you answered the situation and used both target words."
            : "Try again and include: \(missing.joined(separator: ", "))."
        return AttemptFeedback(
            transcript: transcript,
            segments: segments,
            usedRequiredWords: used,
            relevanceScore: relevance,
            coachingTip: tip
        )
    }

    private func quality(for word: String, at index: Int) -> SegmentQuality {
        if word.count >= 9 { return .uncertain }
        if index > 0 && index.isMultiple(of: 7) { return .needsWork }
        return .strong
    }
}

@MainActor
public final class TrainingSession: ObservableObject {
    @Published public private(set) var route: AppRoute = .home
    @Published public private(set) var selectedMode: TrainingMode?
    @Published public private(set) var feedback: AttemptFeedback?
    @Published public private(set) var completedAttempts = 0
    public let task: SpeakingTask

    public init(task: SpeakingTask = .sample) { self.task = task }

    public func start() { route = .modeSelection }
    public func select(_ mode: TrainingMode) { selectedMode = mode; route = .task }
    public func beginResponse() { route = .response }
    public func submit(transcript: String, analyzer: PrototypeAnalyzer = .init()) {
        feedback = analyzer.analyze(transcript, task: task)
        completedAttempts += 1
        route = .feedback
    }
    public func showStatistics() { route = .statistics }
    public func goHome() { route = .home }
    public func retry() { feedback = nil; route = .response }
}
