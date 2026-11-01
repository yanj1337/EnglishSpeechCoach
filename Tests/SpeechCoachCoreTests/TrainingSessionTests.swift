import XCTest
@testable import SpeechCoachCore

@MainActor
final class TrainingSessionTests: XCTestCase {
    func testCompleteHappyPath() {
        let session = TrainingSession()
        session.start()
        XCTAssertEqual(session.route, .modeSelection)
        session.select(.situation)
        XCTAssertEqual(session.route, .task)
        session.beginResponse()
        session.submit(transcript: "When will the room be available? Meanwhile, may I leave my bags?")
        XCTAssertEqual(session.route, .feedback)
        XCTAssertEqual(session.feedback?.usedRequiredWords.count, 2)
        XCTAssertEqual(session.completedAttempts, 1)
    }

    func testMissingTargetWordCreatesActionableTip() {
        let result = PrototypeAnalyzer().analyze("When will my room be ready?", task: .sample)
        XCTAssertTrue(result.usedRequiredWords.isEmpty)
        XCTAssertTrue(result.coachingTip.contains("available"))
        XCTAssertTrue(result.coachingTip.contains("meanwhile"))
    }

    func testRetryClearsFeedback() {
        let session = TrainingSession()
        session.submit(transcript: "It is available meanwhile")
        session.retry()
        XCTAssertEqual(session.route, .response)
        XCTAssertNil(session.feedback)
    }
}
