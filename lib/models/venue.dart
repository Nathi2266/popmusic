enum VenueSize {
  small,
  medium,
  large,
  stadium
}

class Venue {
  final String name;
  final VenueSize size;
  final int capacity;
  final int basePay;
  final int popularityRequired;

  const Venue({
    required this.name,
    required this.size,
    required this.capacity,
    required this.basePay,
    required this.popularityRequired,
  });
}

class VenueData {
  static const List<Venue> venues = [
    Venue(
      name: 'Local Bar',
      size: VenueSize.small,
      capacity: 50,
      basePay: 200,
      popularityRequired: 0,
    ),
    Venue(
      name: 'Coffee Shop',
      size: VenueSize.small,
      capacity: 30,
      basePay: 150,
      popularityRequired: 0,
    ),
    Venue(
      name: 'Club',
      size: VenueSize.medium,
      capacity: 200,
      basePay: 800,
      popularityRequired: 20,
    ),
    Venue(
      name: 'Theater',
      size: VenueSize.medium,
      capacity: 500,
      basePay: 2000,
      popularityRequired: 35,
    ),
    Venue(
      name: 'Concert Hall',
      size: VenueSize.large,
      capacity: 2000,
      basePay: 8000,
      popularityRequired: 50,
    ),
    Venue(
      name: 'Arena',
      size: VenueSize.large,
      capacity: 10000,
      basePay: 40000,
      popularityRequired: 70,
    ),
    Venue(
      name: 'Stadium',
      size: VenueSize.stadium,
      capacity: 50000,
      basePay: 200000,
      popularityRequired: 85,
    ),
  ];
}
