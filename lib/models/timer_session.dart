enum SessionMode {
  focus,
  shortBreak,
  longBreak,
}

extension SessionModeExtension on SessionMode {
  String get title {
    switch (this) {
      case SessionMode.focus:
        return 'Deep Focus';
      case SessionMode.shortBreak:
        return 'Short Sip & Rest';
      case SessionMode.longBreak:
        return 'Long Recovery';
    }
  }

  String get shortName {
    switch (this) {
      case SessionMode.focus:
        return 'Focus';
      case SessionMode.shortBreak:
        return 'Sip Break';
      case SessionMode.longBreak:
        return 'Recovery';
    }
  }

  String get guidance {
    switch (this) {
      case SessionMode.focus:
        return 'Enter flow state. Silence notifications.';
      case SessionMode.shortBreak:
        return 'Rest your eyes & take a hydrating sip.';
      case SessionMode.longBreak:
        return 'Step away, stretch, and refill your bottle.';
    }
  }
}
