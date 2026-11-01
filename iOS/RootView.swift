import SwiftUI
#if canImport(SpeechCoachCore)
import SpeechCoachCore
#endif

private enum CoachStyle {
    static let ink = Color(red: 0.05, green: 0.08, blue: 0.17)
    static let muted = Color(red: 0.30, green: 0.37, blue: 0.51)
    static let blue = Color(red: 0.12, green: 0.42, blue: 0.90)
    static let green = Color(red: 0.15, green: 0.65, blue: 0.38)
    static let surface = Color(red: 0.97, green: 0.98, blue: 0.99)
    static let border = Color(red: 0.88, green: 0.91, blue: 0.94)
}

// These screens are a visual prototype; the phrase and progress are examples.
private enum TrainingScreen {
    case recall, answer, result
}

struct RootView: View {
    @ObservedObject var session: TrainingSession
    @State private var screen: TrainingScreen?
    @State private var selectedRating: Rating?

    var body: some View {
        Group {
            if let screen {
                TrainingView(screen: screen, selectedRating: $selectedRating, close: close, advance: advance)
            } else {
                Button {
                    selectedRating = nil
                    screen = .recall
                } label: {
                    Text("Тренировка")
                        .font(.headline)
                        .foregroundStyle(CoachStyle.ink)
                        .frame(width: 210, height: 76)
                        .background(CoachStyle.surface, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(CoachStyle.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
        }
        .tint(CoachStyle.blue)
    }

    private func close() {
        screen = nil
        selectedRating = nil
    }

    private func advance() {
        switch screen {
        case .recall: screen = .answer
        case .answer: screen = .result
        case .result: close()
        case nil: break
        }
    }
}

private enum Rating: String, CaseIterable {
    case independently = "Вспомнил самостоятельно"
    case difficult = "Вспомнил с трудом"
    case missed = "Не вспомнил"

    var icon: String {
        switch self {
        case .independently: "checkmark"
        case .difficult: "minus"
        case .missed: "xmark"
        }
    }

    var color: Color {
        switch self {
        case .independently: CoachStyle.green
        case .difficult: .orange
        case .missed: .red
        }
    }
}

private struct TrainingView: View {
    let screen: TrainingScreen
    @Binding var selectedRating: Rating?
    let close: () -> Void
    let advance: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 14) {
                    if screen == .result {
                        resultContent
                    } else {
                        progress
                        tags
                        if screen == .recall { recallContent } else { answerContent }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            footer
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
        }
        .background(Color.white.ignoresSafeArea())
        .foregroundStyle(CoachStyle.ink)
    }

    private var header: some View {
        HStack {
            Button(action: close) {
                Image(systemName: "xmark").font(.system(size: 19, weight: .medium))
                    .frame(width: 36, height: 44, alignment: .leading)
            }
            .accessibilityLabel("Закрыть тренировку")
            Spacer()
            Text(screen == .result ? "Результат тренировки" : "Тренировка")
                .font(.headline)
            Spacer()
            Text(screen == .result ? "" : "Пример")
                .font(.subheadline).foregroundStyle(CoachStyle.muted)
                .frame(width: 65, alignment: .trailing)
        }
        .padding(.leading, 20).padding(.trailing, 20)
    }

    private var progress: some View {
        VStack(spacing: 12) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(CoachStyle.border)
                    Capsule().fill(CoachStyle.green).frame(width: geometry.size.width * (screen == .recall ? 0.35 : 0.7))
                }
            }.frame(height: 8)
            Text("Адаптивный режим")
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.indigo)
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(Color.indigo.opacity(0.08), in: Capsule())
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Пример тренировки")
    }

    private var tags: some View {
        HStack(spacing: 8) {
            tag("Повседневное общение", icon: "bubble.left")
            tag("Базовые фразы", icon: "chart.bar.fill")
            Spacer(minLength: 0)
        }
    }

    private func tag(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.caption)
            .foregroundStyle(CoachStyle.muted)
            .padding(.horizontal, 11).padding(.vertical, 9)
            .background(Color(red: 0.95, green: 0.97, blue: 0.99), in: RoundedRectangle(cornerRadius: 12))
    }

    private var recallContent: some View {
        VStack(spacing: 26) {
            Text("Как скажешь?").font(.subheadline.weight(.medium)).foregroundStyle(CoachStyle.muted)
            Text("Попроси собеседника повторить.")
                .font(.title2.bold()).multilineTextAlignment(.center)
            Text("Попробуй вспомнить фразу по-английски.")
                .font(.subheadline).foregroundStyle(CoachStyle.muted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 245)
        .padding(.horizontal, 18)
        .cardStyle()
        .overlay(alignment: .bottomLeading) { EmptyView() }
        .padding(.bottom, 2)
        .accessibilityElement(children: .combine)
    }

    private var answerContent: some View {
        VStack(spacing: 14) {
            VStack(spacing: 12) {
                Text("Образец ответа").font(.subheadline).foregroundStyle(CoachStyle.muted)
                Text("Could you say that again?")
                    .font(.system(size: 28, weight: .bold)).multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Можешь повторить?").foregroundStyle(CoachStyle.muted)
                Text("Сравни со своим ответом.")
                    .font(.subheadline).foregroundStyle(CoachStyle.muted)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 28).padding(.horizontal, 18)
            .cardStyle()

            VStack(alignment: .leading, spacing: 8) {
                Text("Как получилось вспомнить?").font(.headline)
                Text("Оцени свою попытку.").font(.subheadline).foregroundStyle(CoachStyle.muted)
                ForEach(Rating.allCases, id: \.self) { rating in
                    Button { selectedRating = rating } label: {
                        HStack(spacing: 12) {
                            ratingIcon(rating)
                            Text(rating.rawValue).font(.subheadline)
                            Spacer()
                        }
                        .padding(11)
                        .background(selectedRating == rating ? rating.color.opacity(0.09) : CoachStyle.surface, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedRating == rating ? rating.color.opacity(0.45) : CoachStyle.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selectedRating == rating ? .isSelected : [])
                }
            }
            .padding(14).cardStyle(background: .white)
        }
    }

    private var resultContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark")
                .font(.system(size: 28, weight: .bold)).foregroundStyle(CoachStyle.green)
                .frame(width: 64, height: 64).background(CoachStyle.green.opacity(0.14), in: Circle())
            VStack(spacing: 5) {
                Text("Пример завершён").font(.title2.bold())
                Text("Так будет выглядеть тренировка").font(.subheadline).foregroundStyle(CoachStyle.muted)
            }.multilineTextAlignment(.center)
            if let selectedRating {
                HStack(spacing: 12) {
                    ratingIcon(selectedRating)
                    Text(selectedRating.rawValue).font(.subheadline)
                    Spacer()
                }
                .padding(16).cardStyle(background: .white)
            }
            Text("Карточки и результаты тренировок появятся на следующем этапе.")
                .font(.subheadline).foregroundStyle(CoachStyle.muted)
                .multilineTextAlignment(.center).padding(.horizontal, 16)
        }.padding(.top, 18)
    }

    private var footer: some View {
        VStack(spacing: 12) {
            if screen == .recall {
                Label("Вспомни фразу, затем открой ответ.", systemImage: "lightbulb")
                    .font(.subheadline).foregroundStyle(CoachStyle.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button(action: advance) {
                Text(screen == .recall ? "Показать ответ" : screen == .answer ? "Дальше" : "Завершить")
                    .font(.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(CoachStyle.blue, in: RoundedRectangle(cornerRadius: 13))
            }
            .disabled(screen == .answer && selectedRating == nil)
            .opacity(screen == .answer && selectedRating == nil ? 0.5 : 1)
        }
        .padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 12)
    }

    private func ratingIcon(_ rating: Rating) -> some View {
        Image(systemName: rating.icon).font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white).frame(width: 22, height: 22)
            .background(rating.color, in: Circle())
            .accessibilityHidden(true)
    }
}

private extension View {
    func cardStyle(background: Color = CoachStyle.surface) -> some View {
        self.background(background, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(CoachStyle.border, lineWidth: 1))
    }
}

#Preview {
    RootView(session: TrainingSession())
}
