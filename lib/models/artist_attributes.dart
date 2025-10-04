class ArtistAttributes {
  double popularity;
  double reputation;
  double performance;
  double talent;
  double production;
  double songwriting;
  double charisma;
  double marketing;
  double networking;
  double creativity;
  double discipline;
  double stamina;
  double controversy;
  double wealth;
  double influence;

  ArtistAttributes({
    this.popularity = 0,
    this.reputation = 50,
    this.performance = 50,
    this.talent = 50,
    this.production = 50,
    this.songwriting = 50,
    this.charisma = 50,
    this.marketing = 50,
    this.networking = 50,
    this.creativity = 50,
    this.discipline = 50,
    this.stamina = 50,
    this.controversy = 0,
    this.wealth = 0,
    this.influence = 0,
  });

  Map<String, double> toMap() {
    return {
      'popularity': popularity,
      'reputation': reputation,
      'performance': performance,
      'talent': talent,
      'production': production,
      'songwriting': songwriting,
      'charisma': charisma,
      'marketing': marketing,
      'networking': networking,
      'creativity': creativity,
      'discipline': discipline,
      'stamina': stamina,
      'controversy': controversy,
      'wealth': wealth,
      'influence': influence,
    };
  }

  factory ArtistAttributes.fromMap(Map<String, dynamic> map) {
    return ArtistAttributes(
      popularity: map['popularity'] ?? 0,
      reputation: map['reputation'] ?? 50,
      performance: map['performance'] ?? 50,
      talent: map['talent'] ?? 50,
      production: map['production'] ?? 50,
      songwriting: map['songwriting'] ?? 50,
      charisma: map['charisma'] ?? 50,
      marketing: map['marketing'] ?? 50,
      networking: map['networking'] ?? 50,
      creativity: map['creativity'] ?? 50,
      discipline: map['discipline'] ?? 50,
      stamina: map['stamina'] ?? 50,
      controversy: map['controversy'] ?? 0,
      wealth: map['wealth'] ?? 0,
      influence: map['influence'] ?? 0,
    );
  }

  ArtistAttributes copy() {
    return ArtistAttributes(
      popularity: popularity,
      reputation: reputation,
      performance: performance,
      talent: talent,
      production: production,
      songwriting: songwriting,
      charisma: charisma,
      marketing: marketing,
      networking: networking,
      creativity: creativity,
      discipline: discipline,
      stamina: stamina,
      controversy: controversy,
      wealth: wealth,
      influence: influence,
    );
  }
}
