import AppKit
import DihCore

@MainActor
enum DihSoundEffects {
  enum Effect {
    case catchButton
    case hotline
    case upgrade
  }

  static func play(_ effect: Effect, settings: DihSettings) {
    guard settings.data.soundEffectsEnabled else { return }

    let name: NSSound.Name
    switch effect {
    case .catchButton: name = NSSound.Name("Pop")
    case .hotline: name = NSSound.Name("Ping")
    case .upgrade: name = NSSound.Name("Tink")
    }

    if let sound = NSSound(named: name) {
      sound.volume = Float(settings.data.masterVolume)
      sound.play()
    } else {
      NSSound.beep()
    }
  }
}
