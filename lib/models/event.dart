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

class GameEvent {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final Map<String, double> attributeImpacts;
  final int moneyImpact;
  final int fanImpact;
  final List<String> choices;
  final Map<String, Map<String, double>> choiceOutcomes;

  GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.attributeImpacts = const {},
    this.moneyImpact = 0,
    this.fanImpact = 0,
    this.choices = const [],
    this.choiceOutcomes = const {},
  });
}
