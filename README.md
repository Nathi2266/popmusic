# PopMusic Game Logic Overview

The PopMusic game simulates the career of a music artist, driven by weekly progression, player actions, and various game mechanics. The central hub for game state management is the `GameStateService` (`lib/services/game_state_service.dart`), which orchestrates the game flow and manages player and NPC data.

## 1. Core Game Loop (GameStateService)

The game progresses week by week, managed by the `advanceWeek()` method in `GameStateService`. Each week, the following occurs:

- **Week & Year Progression:** The `_currentWeek` increments. If it reaches 52, the `_currentYear` increases, and `_handleEndOfYear()` is called.
- **Player Updates:** The player's `weeksSinceDebut` increases, and `_updatePlayerWeekly()` is called to adjust stamina, popularity decay, and weekly income based on their `LabelTier`.
- **NPC Updates:** Each NPC's `weeksSinceDebut` increases, and `_updateNPCWeekly()` is called. NPCs have a chance to release new songs. Popularity for NPCs also decays weekly.
- **Song Updates:** All released songs in `_allSongs` are updated via `_updateSongWeekly()`.
- **Random Events:** There's a chance for `_triggerRandomEvent()` to occur, which can have positive or negative impacts on the player (e.g., popularity gain, scandal, money opportunity).
- **UI Refresh:** `notifyListeners()` is called to update the UI reflecting the new game state.

## 2. Artist Management (Artist Model & GameStateService)

The `Artist` model (`lib/models/artist.dart`) defines the properties of both the player and NPC artists:

- **Attributes:** `ArtistAttributes` (popularity, reputation, performance, talent, production, songwriting, charisma, marketing, networking, creativity, discipline, stamina, controversy, wealth, influence) determine an artist's strengths and weaknesses.
- **Financials:** `money` and `fanCount` track the artist's financial status and fanbase.
- **Career Progression:** `weeksSinceDebut`, `labelTier`, and `awards` track the artist's career milestones. `LabelTier` determines weekly income and unlocks opportunities.
- **Songs & Albums:** `releasedSongs` and `releasedAlbums` track the IDs of music released by the artist.

`GameStateService` handles the creation of the player artist (`startNewGame()`) and generates NPC artists using `NPCArtists.generateNPCs()`. It also provides methods to `updatePlayerMoney()` and `updatePlayerAttribute()` to modify the player's stats.

## 3. Song Mechanics (Song Model & GameStateService)

The `Song` model (`lib/models/song.dart`) contains details about each song:

- **Core Properties:** `id`, `title`, `artistId`, `genre`, `quality`, `hypeLevel`, `weeksSinceRelease`, and `streams`.
- **Hype Decay:** The `_updateSongWeekly` method currently is a placeholder but implies that `hypeLevel` and `streams` would decay over time.
- **Players can create new songs through the `CreateSongScreen`, which likely involves minigames (songwriting, production) to determine the `quality` and initial `hypeLevel` of the song. NPC artists also release songs periodically via `_npcReleaseSong()` in `GameStateService`.

## 4. Player Actions & Minigames

The game features several screens and associated minigames for player interaction:

- **Songwriting Minigame (`SongwritingMinigameScreen`):** Players select words to build lyrics, and a score is calculated based on choices, influencing song quality.
- **Production Minigame (`ProductionMinigameScreen`):** Players adjust audio parameters (bass, treble, volume) to match target levels, affecting song production quality.
- **Performance Minigame (`PerformanceMinigameScreen`):** Players perform at venues, and their performance score is calculated, impacting fan gain and earnings.
- **Career Progression (`CareerScreen`):** Players can view their career progress, including `LabelTier` progression and `awards` won. They can also upgrade their label tier if they meet the requirements.
- **Music Management (`MusicScreen`):** Players can view their released songs and potentially initiate new song creation.
- **Artist Browsing (`ArtistsScreen`):** Players can view details about NPC artists, filtered by genre and label tier.

## 5. Events and Progression

- **Awards:** At the end of each year, the player can win awards based on their popularity and released songs.
- **Label Tier Progression:** Players can advance through `LabelTier`s (Unsigned, Indie, Major, Superstar) by meeting specific requirements related to popularity, fan count, and awards. Upgrading provides increased weekly income and influence.
- **Random Events:** Random events can positively or negatively affect the player's attributes or money, adding an element of unpredictability to the game.

This overview covers the main logical components and interactions within the PopMusic game.
