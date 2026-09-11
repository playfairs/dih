import DihCore
import SwiftUI

struct DihPlayfield: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var game: DihGame
    @EnvironmentObject private var settings: DihSettings

    var body: some View {
        GeometryReader { proxy in
            let arena = CGRect(origin: .zero, size: proxy.size)
            let buttonSize = CGSize(
                width: max(112, CGFloat(game.buttonText.count) * 8 + 44) * game.effectiveTargetScale,
                height: 42 * game.effectiveTargetScale
            )
            let desiredPosition = settings.data.reducedMovement
                ? CGPoint(x: arena.midX, y: arena.midY)
                : game.buttonPosition
            let displayedPosition = DihArena.clampedCenter(
                in: arena,
                buttonSize: buttonSize,
                desired: desiredPosition
            )

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(settings.data.highContrast ? Color.black : Color.primary.opacity(0.035))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(settings.data.highContrast ? Color.white : Color.primary.opacity(0.12)))

                Button(game.buttonText) {
                    withAnimation(movementAnimation) {
                        let openedClone = game.caught(in: arena, buttonSize: buttonSize)
                        DihSoundEffects.play(.catchButton, settings: settings)
                        if openedClone {
                            openWindow(id: "dih")
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(width: buttonSize.width, height: buttonSize.height)
                .position(displayedPosition)
                .onHover { hovering in
                    if hovering {
                        withAnimation(movementAnimation) {
                            game.runAway(from: arena, buttonSize: buttonSize)
                        }
                    }
                }

            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .task(id: "\(proxy.size.width),\(proxy.size.height),\(game.buttonText),\(game.effectiveTargetScale)") {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(500))
                    guard !Task.isCancelled else { return }
                    withAnimation(movementAnimation) {
                        game.autonomousMoveIfNeeded(in: arena, buttonSize: buttonSize)
                    }
                }
            }
        }
    }

    private var movementAnimation: Animation? {
        guard !settings.data.reducedMovement else { return nil }
        return .easeOut(duration: max(0.08, 0.22 * settings.data.animationIntensity))
    }
}

struct CurrencyView: View {
    @EnvironmentObject private var game: DihGame
    @EnvironmentObject private var settings: DihSettings
    let points: Int

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Label("POINTS", systemImage: "circle.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                if settings.data.showScorePopups, let scorePopup = game.scorePopup {
                    Text(scorePopup)
                        .font(.headline.bold().monospacedDigit())
                        .foregroundStyle(.orange)
                        .id(game.scorePopupID)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
                Text("\(points)")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .contentTransition(.numericText())
            }
            .animation(.easeOut(duration: 0.35), value: game.scorePopupID)
        }
    }
}

struct MiniStat: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.caption2.weight(.bold)).foregroundStyle(.secondary)
                Text(value).font(.headline.monospacedDigit())
            }
        } icon: {
            Image(systemName: icon).foregroundStyle(.orange)
        }
    }
}

struct UpgradeCard: View {
    @EnvironmentObject private var game: DihGame
    let id: DihUpgradeID

    private var definition: DihUpgradeDefinition { game.definition(for: id) }
    private var level: Int { game.level(for: id) }
    private var isMaxed: Bool { definition.maximumLevel.map { level >= $0 } ?? false }
    private var affordable: Bool { game.points >= game.cost(for: id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: definition.icon)
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .frame(width: 30)
                VStack(alignment: .leading, spacing: 3) {
                    Text(definition.name).font(.headline)
                    Text(definition.description).font(.callout).foregroundStyle(.secondary)
                }
                Spacer()
                Text("Lv. \(level)")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: Capsule())
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Now: \(effectText)")
                    if !isMaxed {
                        Text("Next: \(nextEffectText)")
                    }
                }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if game.isUnlocked(id) && !isMaxed {
                    Button("\(game.cost(for: id)) pts", systemImage: "circle.fill") {
                        DihSoundEffects.play(.upgrade, settings: game.settings)
                        game.purchase(id)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(!affordable)
                } else if isMaxed {
                    Label("MAX", systemImage: "checkmark.seal.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.green)
                } else {
                    Label(definition.unlockText, systemImage: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.quaternary))
        .opacity(game.isUnlocked(id) || level > 0 ? 1 : 0.72)
    }

    private var effectText: String {
        effectText(at: level)
    }

    private var nextEffectText: String {
        effectText(at: level + 1)
    }

    private func effectText(at level: Int) -> String {
        var projectedSave = game.save
        projectedSave.upgrades[id.rawValue] = level
        switch id {
        case .betterGrip: return "Escape chance: \(Int(DihEconomy.runAwayChance(in: projectedSave) * 100))%"
        case .stickyButton: return "Movement delay: \(Int(DihEconomy.movementDelay(in: projectedSave)))s"
        case .slowerDih: return "Escape and self-move chance reduced"
        case .magnetHands: return "Target size: \(Int(DihEconomy.catchRadiusMultiplier(in: projectedSave) * 100))%"
        case .reflexes: return "Hover escape reduced"
        case .biggerTarget: return "Target size: \(Int(DihEconomy.targetScale(in: projectedSave) * 100))%"
        case .quickHands: return "+\(level) points per catch"
        case .comboTraining: return "Streak bonus: +\(DihEconomy.comboBonus(in: projectedSave))"
        case .hotlineEfficiency: return "Payout: \(DihEconomy.passivePointsPerInterval(in: projectedSave)) points"
        case .fasterHotline: return "Payout every \(Int(DihEconomy.passiveInterval(in: projectedSave)))s"
        case .betterAdvice: return "Advice efficiency: \(Int(DihEconomy.passiveMultiplier(in: projectedSave) * 100))%"
        case .dedicatedOperator: return "Offline cap: \(Int(DihEconomy.offlineDuration(in: projectedSave) / 3600))h"
        case .automatedHotline: return "Passive multiplier: \(Int(DihEconomy.passiveMultiplier(in: projectedSave) * 100))%"
        case .hotlineMultiplier: return "Passive multiplier: \(Int(DihEconomy.passiveMultiplier(in: projectedSave) * 100))%"
        case .escapePrediction: return "Fewer surprise escapes"
        case .cloneDiscount: return "Clone chance: 1 in \(DihEconomy.cloneChance(in: projectedSave))"
        case .cloneCapacity: return "Clone limit: \(DihEconomy.cloneLimit(in: projectedSave))"
        case .cloneRewards: return "Clone reward: \(DihEconomy.cloneRewardMultiplier(in: projectedSave))x"
        case .cloneCoordination: return "Clone target: \(Int(DihEconomy.cloneTargetMultiplier(in: projectedSave) * 100))%"
        case .cloneMultiplier: return "Clone reward: \(DihEconomy.cloneRewardMultiplier(in: projectedSave))x"
        case .luckyDih: return "Bonus chance: \(Int(DihEconomy.bonusChance(in: projectedSave) * 100))%"
        case .criticalCatch: return "Critical chance: \(Int(DihEconomy.criticalChance(in: projectedSave) * 100))%"
        case .pointMultiplier: return "Catch multiplier: \(DihEconomy.pointMultiplier(in: projectedSave))x"
        case .streakMastery: return "Streak multiplier: \(DihEconomy.streakMultiplier(in: projectedSave))x"
        case .goldenDih: return "Golden chance: \(Int(DihEconomy.goldenChance(in: projectedSave) * 100))%"
        case .secondChance: return "Streak save: \(Int(DihEconomy.secondChance(in: projectedSave) * 100))%"
        case .arcadeLuck: return "Rare event odds: \(Int((DihEconomy.arcadeLuck(in: projectedSave) - 1) * 100))% better"
        case .combo: return "Current streak bonus: +\(DihEconomy.comboBonus(in: projectedSave))"
        }
    }
}