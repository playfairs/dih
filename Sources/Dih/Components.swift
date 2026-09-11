import DihCore
import SwiftUI

struct CurrencyView: View {
    let points: Int

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Label("POINTS", systemImage: "circle.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            Text("\(points)")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .contentTransition(.numericText())
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
        case .biggerTarget: return "Target size: \(Int(DihEconomy.targetScale(in: projectedSave) * 100))%"
        case .quickHands: return "+\(level) points per catch"
        case .hotlineEfficiency: return "Payout: \(DihEconomy.passivePointsPerInterval(in: projectedSave)) points"
        case .fasterHotline: return "Payout every \(Int(DihEconomy.passiveInterval(in: projectedSave)))s"
        case .escapePrediction: return "Fewer surprise escapes"
        case .cloneDiscount: return "Clone chance: 1 in \(DihEconomy.cloneChance(in: projectedSave))"
        case .luckyDih: return "Bonus chance: \(Int(DihEconomy.bonusChance(in: projectedSave) * 100))%"
        case .combo: return "Current streak bonus: +\(DihEconomy.comboBonus(in: projectedSave))"
        }
    }
}