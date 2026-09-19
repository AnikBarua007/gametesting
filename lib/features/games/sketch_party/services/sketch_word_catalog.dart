import 'dart:math';
import '../models/sketch_party_word.dart';

class SketchWordCatalog {
  static const List<SketchPartyWord> allWords = <SketchPartyWord>[
    // EASY (100 pts) - Clear iconic shapes
    SketchPartyWord(
      word: 'Apple',
      category: 'Food',
      difficulty: WordDifficulty.easy,
      synonyms: <String>['Fruit'],
      hint: 'A sweet red or green fruit',
    ),
    SketchPartyWord(
      word: 'House',
      category: 'Places',
      difficulty: WordDifficulty.easy,
      synonyms: <String>['Home', 'Cabin'],
      hint: 'Where people live',
    ),
    SketchPartyWord(
      word: 'Sun',
      category: 'Nature',
      difficulty: WordDifficulty.easy,
      synonyms: <String>['Sunshine', 'Star'],
      hint: 'Bright yellow orb in the sky',
    ),
    SketchPartyWord(
      word: 'Cat',
      category: 'Animals',
      difficulty: WordDifficulty.easy,
      synonyms: <String>['Kitten', 'Kitty'],
      hint: 'Furry pet that meows',
    ),
    SketchPartyWord(
      word: 'Pizza',
      category: 'Food',
      difficulty: WordDifficulty.easy,
      synonyms: <String>['Pie', 'Slice'],
      hint: 'Cheesy triangular food',
    ),
    SketchPartyWord(
      word: 'Car',
      category: 'Vehicles',
      difficulty: WordDifficulty.easy,
      synonyms: <String>['Auto', 'Automobile'],
      hint: 'Vehicle with four wheels',
    ),
    SketchPartyWord(
      word: 'Tree',
      category: 'Nature',
      difficulty: WordDifficulty.easy,
      synonyms: <String>['Plant', 'Oak'],
      hint: 'Has trunk and green leaves',
    ),
    SketchPartyWord(
      word: 'Fish',
      category: 'Animals',
      difficulty: WordDifficulty.easy,
      synonyms: <String>['Goldfish'],
      hint: 'Swims in water',
    ),
    SketchPartyWord(
      word: 'Clock',
      category: 'Objects',
      difficulty: WordDifficulty.easy,
      synonyms: <String>['Watch', 'Time'],
      hint: 'Tells the time',
    ),
    SketchPartyWord(
      word: 'Guitar',
      category: 'Objects',
      difficulty: WordDifficulty.easy,
      synonyms: <String>['Acoustic'],
      hint: 'Musical instrument with strings',
    ),
    SketchPartyWord(
      word: 'Book',
      category: 'Objects',
      difficulty: WordDifficulty.easy,
      synonyms: <String>['Novel'],
      hint: 'Has pages and a cover',
    ),
    SketchPartyWord(
      word: 'Glasses',
      category: 'Objects',
      difficulty: WordDifficulty.easy,
      synonyms: <String>['Spectacles', 'Eyeglasses'],
      hint: 'Worn on face to see',
    ),

    // MEDIUM (200 pts) - More detailed / dynamic
    SketchPartyWord(
      word: 'Rocket',
      category: 'Vehicles',
      difficulty: WordDifficulty.medium,
      synonyms: <String>['Spaceship', 'Spacecraft'],
      hint: 'Blasts off into outer space',
    ),
    SketchPartyWord(
      word: 'Elephant',
      category: 'Animals',
      difficulty: WordDifficulty.medium,
      synonyms: <String>['Mammoth'],
      hint: 'Huge grey animal with a trunk',
    ),
    SketchPartyWord(
      word: 'Campfire',
      category: 'Nature',
      difficulty: WordDifficulty.medium,
      synonyms: <String>['Bonfire', 'Fire'],
      hint: 'Flames on logs outdoors',
    ),
    SketchPartyWord(
      word: 'Helicopter',
      category: 'Vehicles',
      difficulty: WordDifficulty.medium,
      synonyms: <String>['Chopper'],
      hint: 'Flies with spinning blades on top',
    ),
    SketchPartyWord(
      word: 'Burger',
      category: 'Food',
      difficulty: WordDifficulty.medium,
      synonyms: <String>['Hamburger', 'Cheeseburger'],
      hint: 'Patty between sesame buns',
    ),
    SketchPartyWord(
      word: 'Castle',
      category: 'Places',
      difficulty: WordDifficulty.medium,
      synonyms: <String>['Fortress', 'Palace'],
      hint: 'Medieval stone fort with towers',
    ),
    SketchPartyWord(
      word: 'Telescope',
      category: 'Objects',
      difficulty: WordDifficulty.medium,
      synonyms: <String>['Spyglass'],
      hint: 'Optical tube to view distant stars',
    ),
    SketchPartyWord(
      word: 'Pancake',
      category: 'Food',
      difficulty: WordDifficulty.medium,
      synonyms: <String>['Flapjack', 'Hotcake'],
      hint: 'Flat round breakfast cake with syrup',
    ),
    SketchPartyWord(
      word: 'Penguin',
      category: 'Animals',
      difficulty: WordDifficulty.medium,
      synonyms: <String>['Pingu'],
      hint: 'Flightless bird in tuxedo on ice',
    ),
    SketchPartyWord(
      word: 'Volcano',
      category: 'Nature',
      difficulty: WordDifficulty.medium,
      synonyms: <String>['Lava'],
      hint: 'Mountain that erupts red lava',
    ),

    // HARD (300 pts) - Abstract, compound, or intricate
    SketchPartyWord(
      word: 'Astronaut',
      category: 'People',
      difficulty: WordDifficulty.hard,
      synonyms: <String>['Cosmonaut', 'Spaceman'],
      hint: 'Person wearing a space suit on the Moon',
    ),
    SketchPartyWord(
      word: 'Lighthouse',
      category: 'Places',
      difficulty: WordDifficulty.hard,
      synonyms: <String>['Beacon'],
      hint: 'Coastal tower with revolving spotlight',
    ),
    SketchPartyWord(
      word: 'Rollercoaster',
      category: 'Places',
      difficulty: WordDifficulty.hard,
      synonyms: <String>['Coaster', 'Amusement'],
      hint: 'Fast theme park ride on twisting tracks',
    ),
    SketchPartyWord(
      word: 'Submarine',
      category: 'Vehicles',
      difficulty: WordDifficulty.hard,
      synonyms: <String>['Sub', 'U-boat'],
      hint: 'Underwater vessel with periscope',
    ),
    SketchPartyWord(
      word: 'Dragon',
      category: 'Fantasy',
      difficulty: WordDifficulty.hard,
      synonyms: <String>['Wyvern', 'Drake'],
      hint: 'Mythical winged fire-breathing beast',
    ),
    SketchPartyWord(
      word: 'Chandelier',
      category: 'Objects',
      difficulty: WordDifficulty.hard,
      synonyms: <String>['Candelabra'],
      hint: 'Fancy ornate crystal ceiling lamp',
    ),
    SketchPartyWord(
      word: 'Hourglass',
      category: 'Objects',
      difficulty: WordDifficulty.hard,
      synonyms: <String>['Sandglass', 'Timer'],
      hint: 'Glass bulbs with trickling sand',
    ),
    SketchPartyWord(
      word: 'Pyramid',
      category: 'Places',
      difficulty: WordDifficulty.hard,
      synonyms: <String>['Pharaoh'],
      hint: 'Ancient triangular monument in the desert',
    ),
  ];

  /// Pick 3 distinct words (1 Easy, 1 Medium, 1 Hard) for the drawer to choose from.
  static List<SketchPartyWord> getWordChoices(Random random) {
    final List<SketchPartyWord> easies =
        allWords.where((w) => w.difficulty == WordDifficulty.easy).toList();
    final List<SketchPartyWord> mediums =
        allWords.where((w) => w.difficulty == WordDifficulty.medium).toList();
    final List<SketchPartyWord> hards =
        allWords.where((w) => w.difficulty == WordDifficulty.hard).toList();

    return <SketchPartyWord>[
      easies[random.nextInt(easies.length)],
      mediums[random.nextInt(mediums.length)],
      hards[random.nextInt(hards.length)],
    ];
  }

  /// Generates the masked letter hint string e.g. "A _ P _ E" depending on progress.
  static String generateMaskedHint(String word, double progress) {
    final String clean = word.toUpperCase();
    final List<String> chars = clean.split('');
    final List<String> result = <String>[];

    // How many letters to reveal based on time progress
    int revealCount = 0;
    if (progress >= 0.70) {
      // Near the end: reveal 35-50% of characters
      revealCount = (clean.length * 0.40).ceil();
    } else if (progress >= 0.45) {
      // Middle: reveal 15-25% of characters
      revealCount = (clean.length * 0.20).ceil().clamp(1, 2);
    }

    // Fixed deterministic indices for revealed characters so it doesn't flicker
    final Set<int> revealedIndices = <int>{};
    if (revealCount >= 1 && clean.isNotEmpty) {
      revealedIndices.add(0); // Reveal first letter
    }
    if (revealCount >= 2 && clean.length > 3) {
      revealedIndices.add(clean.length ~/ 2); // Reveal middle
    }
    if (revealCount >= 3 && clean.length > 5) {
      revealedIndices.add(clean.length - 1); // Reveal last
    }

    for (int i = 0; i < chars.length; i++) {
      final String ch = chars[i];
      if (ch == ' ' || ch == '-') {
        result.add(ch);
      } else if (revealedIndices.contains(i)) {
        result.add(ch);
      } else {
        result.add('_');
      }
    }

    return result.join(' ');
  }
}

