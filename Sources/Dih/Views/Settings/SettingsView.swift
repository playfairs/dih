import DihCore
import SwiftUI

struct SettingsView: View {
  @EnvironmentObject private var settings: DihSettings

  var body: some View {
    Form {
      Section("Gameplay") {
        Toggle("Button movement", isOn: binding(\.movementEnabled))
        Toggle("Flee on hover", isOn: binding(\.fleeBehaviorEnabled))
        Picker("Difficulty", selection: binding(\.difficulty)) {
          ForEach(DihDifficulty.allCases, id: \.self) { Text($0.rawValue).tag($0) }
        }
        Toggle("Clone windows", isOn: binding(\.cloneWindowsEnabled))
        Stepper(
          "Maximum clone windows: \(settings.data.maximumCloneWindows)",
          value: binding(\.maximumCloneWindows), in: 1...8)
      }

      Section("Appearance") {
        Picker("Appearance", selection: binding(\.appearance)) {
          ForEach(DihAppearance.allCases, id: \.self) { appearance in
            Text(appearance.displayName).tag(appearance)
          }
        }
        Toggle("Achievement notifications", isOn: binding(\.achievementNotificationsEnabled))
      }

      Section("Interface") {
        Toggle("Show reactions", isOn: binding(\.showReactions))
        Toggle("Show score popups", isOn: binding(\.showScorePopups))
        Toggle("Show statistics", isOn: binding(\.showStatistics))
        Toggle("Show passive notifications", isOn: binding(\.showPassiveNotifications))
        Toggle("Show achievements", isOn: binding(\.showAchievements))
        Toggle("Compact mode", isOn: binding(\.compactMode))
        Toggle("Reduce animations", isOn: binding(\.reducedMovement))
      }

      Section("Accessibility") {
        Toggle("Larger button", isOn: binding(\.largerButton))
        Toggle("Slower button", isOn: binding(\.slowerButton))
        Toggle("High contrast playfield", isOn: binding(\.highContrast))
      }

      Section("Audio") {
        Toggle("Sound effects", isOn: binding(\.soundEffectsEnabled))
        Slider(value: binding(\.masterVolume), in: 0...1) {
          Text("Master volume")
        } minimumValueLabel: {
          Image(systemName: "speaker.fill")
        } maximumValueLabel: {
          Image(systemName: "speaker.wave.3.fill")
        }
        Text("Audio is intentionally quiet for now. The button is loud enough.")
          .font(.caption).foregroundStyle(.secondary)
      }
    }
    .formStyle(.grouped)
    .padding(20)
    .frame(minWidth: 600, minHeight: 520)
  }

  private func binding<Value>(_ keyPath: WritableKeyPath<DihSettingsData, Value>) -> Binding<Value>
  {
    Binding(
      get: { settings.data[keyPath: keyPath] },
      set: { settings.update(keyPath, $0) }
    )
  }
}
