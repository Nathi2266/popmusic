enum EventType {
  scandal,
  opportunity,
  rivalry,
  collaboration,
  award,
  contest,
  labelOffer,
  randomEncounter
}

enum EventSeverity { low, medium, high }

class GameEvent {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final EventSeverity severity;
  final Map<String, double> attributeImpacts;
  final int moneyImpact;
  final int fanImpact;
  final List<String> choices;
  /// Per-choice outcomes. Special keys: `_money`, `_fans`.
  final Map<String, Map<String, double>> choiceOutcomes;
  bool resolved;
  String? selectedChoice;

  GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.severity = EventSeverity.medium,
    this.attributeImpacts = const {},
    this.moneyImpact = 0,
    this.fanImpact = 0,
    this.choices = const [],
    this.choiceOutcomes = const {},
    this.resolved = false,
    this.selectedChoice,
  });

  bool get isInteractive => choices.isNotEmpty;

  bool get needsPlayerDecision => isInteractive && !resolved;
}
