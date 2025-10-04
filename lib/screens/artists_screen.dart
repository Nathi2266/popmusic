import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../models/artist.dart';
import 'artist_detail_screen.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  String _searchQuery = '';
  Genre? _filterGenre;
  LabelTier? _filterLabel;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, gameState, child) {
        final allArtists = [...gameState.npcs];
        
        // Apply filters
        var filteredArtists = allArtists.where((artist) {
          final matchesSearch = artist.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
          final matchesGenre = _filterGenre == null || 
              artist.primaryGenre == _filterGenre ||
              artist.secondaryGenre == _filterGenre;
          final matchesLabel = _filterLabel == null || 
              artist.labelTier == _filterLabel;
          
          return matchesSearch && matchesGenre && matchesLabel;
        }).toList();

        // Sort by popularity
        filteredArtists.sort((a, b) => 
            b.attributes.popularity.compareTo(a.attributes.popularity));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Artists'),
            backgroundColor: const Color(0xFF16213e),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search artists...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.search, color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF2a2a3e),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All Genres',
                          isSelected: _filterGenre == null,
                          onSelected: () {
                            setState(() {
                              _filterGenre = null;
                            });
                          },
                        ),
                        ...Genre.values.map((genre) => _FilterChip(
                          label: _getGenreName(genre),
                          isSelected: _filterGenre == genre,
                          onSelected: () {
                            setState(() {
                              _filterGenre = genre;
                            });
                          },
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: filteredArtists.isEmpty
              ? const Center(
                  child: Text(
                    'No artists found',
                    style: TextStyle(color: Colors.white54, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredArtists.length,
                  itemBuilder: (context, index) {
                    final artist = filteredArtists[index];
                    return _ArtistCard(
                      artist: artist,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArtistDetailScreen(
                              artistId: artist.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  String _getGenreName(Genre genre) {
    switch (genre) {
      case Genre.pop:
        return 'Pop';
      case Genre.rock:
        return 'Rock';
      case Genre.hiphop:
        return 'Hip Hop';
      case Genre.rnb:
        return 'R&B';
      case Genre.electronic:
        return 'Electronic';
      case Genre.indie:
        return 'Indie';
      case Genre.country:
        return 'Country';
      case Genre.jazz:
        return 'Jazz';
      case Genre.latin:
        return 'Latin';
      case Genre.kpop:
        return 'K-Pop';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        backgroundColor: const Color(0xFF2a2a3e),
        selectedColor: const Color(0xFFe94560),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap;

  const _ArtistCard({
    required this.artist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2a2a3e),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: _getGenreColor(artist.primaryGenre),
                child: Text(
                  artist.name[0],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Artist Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getGenreName(artist.primaryGenre),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${artist.attributes.popularity.toInt()}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.people,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${artist.fanCount}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Label badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getLabelColor(artist.labelTier),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getLabelName(artist.labelTier),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGenreName(Genre genre) {
    switch (genre) {
      case Genre.pop:
        return 'Pop';
      case Genre.rock:
        return 'Rock';
      case Genre.hiphop:
        return 'Hip Hop';
      case Genre.rnb:
        return 'R&B';
      case Genre.electronic:
        return 'Electronic';
      case Genre.indie:
        return 'Indie';
      case Genre.country:
        return 'Country';
      case Genre.jazz:
        return 'Jazz';
      case Genre.latin:
        return 'Latin';
      case Genre.kpop:
        return 'K-Pop';
    }
  }

  String _getLabelName(LabelTier tier) {
    switch (tier) {
      case LabelTier.unsigned:
        return 'Unsigned';
      case LabelTier.indie:
        return 'Indie';
      case LabelTier.major:
        return 'Major';
      case LabelTier.superstar:
        return 'Superstar';
    }
  }

  Color _getGenreColor(Genre genre) {
    switch (genre) {
      case Genre.pop:
        return const Color(0xFFe94560);
      case Genre.rock:
        return const Color(0xFF8B4513);
      case Genre.hiphop:
        return const Color(0xFF9C27B0);
      case Genre.rnb:
        return const Color(0xFFFF6B9D);
      case Genre.electronic:
        return const Color(0xFF00BCD4);
      case Genre.indie:
        return const Color(0xFF8BC34A);
      case Genre.country:
        return const Color(0xFFFF9800);
      case Genre.jazz:
        return const Color(0xFF673AB7);
      case Genre.latin:
        return const Color(0xFFF44336);
      case Genre.kpop:
        return const Color(0xFFE91E63);
    }
  }

  Color _getLabelColor(LabelTier tier) {
    switch (tier) {
      case LabelTier.unsigned:
        return const Color(0xFF607D8B);
      case LabelTier.indie:
        return const Color(0xFF4CAF50);
      case LabelTier.major:
        return const Color(0xFF2196F3);
      case LabelTier.superstar:
        return const Color(0xFFFFD700);
    }
  }
}
