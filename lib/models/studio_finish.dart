enum StudioFinish {
  rush,
  standard,
  polish,
}

extension StudioFinishX on StudioFinish {
  String get displayName {
    switch (this) {
      case StudioFinish.rush:
        return 'Rush mix';
      case StudioFinish.standard:
        return 'Standard';
      case StudioFinish.polish:
        return 'Polish';
    }
  }

  String get pitch {
    switch (this) {
      case StudioFinish.rush:
        return 'Cheap and fast. Quality takes a hit.';
      case StudioFinish.standard:
        return 'Normal session. Fair cost, fair mix.';
      case StudioFinish.polish:
        return 'Extra days in the booth. Costs more, sounds bigger.';
    }
  }

  double get qualityMult {
    switch (this) {
      case StudioFinish.rush:
        return 0.80;
      case StudioFinish.standard:
        return 1.0;
      case StudioFinish.polish:
        return 1.18;
    }
  }

  double get viralMult {
    switch (this) {
      case StudioFinish.rush:
        return 0.90;
      case StudioFinish.standard:
        return 1.0;
      case StudioFinish.polish:
        return 1.08;
    }
  }

  /// Added on top of the 500 / 1000 marketing release cost.
  double get extraCost {
    switch (this) {
      case StudioFinish.rush:
        return -200;
      case StudioFinish.standard:
        return 0;
      case StudioFinish.polish:
        return 900;
    }
  }

  double get staminaHit {
    switch (this) {
      case StudioFinish.rush:
        return 8;
      case StudioFinish.standard:
        return 12;
      case StudioFinish.polish:
        return 18;
    }
  }

  static StudioFinish fromName(String? name) {
    switch (name) {
      case 'rush':
        return StudioFinish.rush;
      case 'polish':
        return StudioFinish.polish;
      default:
        return StudioFinish.standard;
    }
  }
}
