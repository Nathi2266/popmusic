import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../models/artist.dart';
import 'artist_detail_screen.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/empty_state.dart';
// Removed unused imports for Genre and LabelTier
// import '../models/artist.dart';
// import '../models/label_tier.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  String _searchQuery = '';
  // Removed _filterGenre and _filterLabel
  // Genre? _filterGenre;
  // LabelTier? _filterLabel;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, gameState, child) {
        final allArtists = [...gameState.worldArtists]; // Use worldArtists
        
        // Apply filters (only search by name now)
        var filteredArtists = allArtists.where((artist) {
          final matchesSearch = artist.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
          
          // Removed genre and label filters
          // final matchesGenre = _filterGenre == null || 
          //     artist.primaryGenre == _filterGenre ||
          //     artist.secondaryGenre == _filterGenre;
          // final matchesLabel = _filterLabel == null || 
          //     artist.labelTier == _filterLabel;
          
          return matchesSearch; // Only return matchesSearch
        }).toList();

        // Sort by popularity
        filteredArtists.sort((a, b) => 
            (b.attributes['popularity'] ?? 0).compareTo(a.attributes['popularity'] ?? 0)); // Updated attribute access

        return Scaffold(
          appBar: AppBar(
            title: const Text('Artists'),
            backgroundColor: const Color(0xFF16213e),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60), // Adjusted height due to removed filters
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
                  // Removed Filters section
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  //   child: Row(
                  //     children: [
                  //       _FilterChip(
                  //         label: 'All Genres',
                  //         isSelected: _filterGenre == null,
                  //         onSelected: () {
                  //           setState(() {
                  //             _filterGenre = null;
                  //           });
                  //         },
                  //       ),
                  //       ...Genre.values.map((genre) => _FilterChip(
                  //         label: _getGenreName(genre),
                  //         isSelected: _filterGenre == genre,
                  //         onSelected: () {
                  //           setState(() {
                  //             _filterGenre = genre;
                  //           });
                  //         },
                  //       )),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          body: allArtists.isEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return const ShimmerCard();
                  },
                )
              : filteredArtists.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off,
                      title: 'No artists found',
                      subtitle: _searchQuery.isNotEmpty
                          ? 'Try adjusting your search query'
                          : 'No artists in the world yet',
                      iconColor: Colors.white38,
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

  // Removed _getGenreName method
  // String _getGenreName(Genre genre) { ... }
}

// Removed _FilterChip class
// class _FilterChip extends StatelessWidget { ... }

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
                backgroundColor: Colors.blueAccent, // Generic color
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
                    // Removed genre display
                    // Text(
                    //   _getGenreName(artist.primaryGenre),
                    //   style: const TextStyle(
                    //     color: Colors.white70,
                    //     fontSize: 14,
                    //   ),
                    // ),
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
                          '${(artist.attributes['popularity'] ?? 0).toInt()}',
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
                          '${(artist.attributes['fan_connection'] ?? 0 * 100).toInt()}',
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
              // Removed Label badge
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 12,
              //     vertical: 6,
              //   ),
              //   decoration: BoxDecoration(
              //     color: _getLabelColor(artist.labelTier),
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Text(
              //     _getLabelName(artist.labelTier),
              //     style: const TextStyle(
              //       color: Colors.white,
              //       fontSize: 12,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Removed _getGenreName, _getLabelName, _getGenreColor, _getLabelColor
  // String _getGenreName(Genre genre) { ... }
  // String _getLabelName(LabelTier tier) { ... }
  // Color _getGenreColor(Genre genre) { ... }
  // Color _getLabelColor(LabelTier tier) { ... }
}
