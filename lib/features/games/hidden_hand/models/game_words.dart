import 'dart:math';

class DrawingWordPrompt {
  final String word;
  final String category;
  final List<String> synonyms;
  final String hint;

  const DrawingWordPrompt({
    required this.word,
    required this.category,
    this.synonyms = const <String>[],
    this.hint = '',
  });

  bool matchesGuess(String guess) {
    final String clean = guess.trim().toLowerCase();
    if (clean.isEmpty) return false;
    if (clean == word.toLowerCase()) return true;
    for (final String syn in synonyms) {
      if (clean == syn.toLowerCase()) return true;
    }
    // Also check if word contains guess or vice versa for compound phrases
    if (clean.length >= 4 && word.toLowerCase().contains(clean)) return true;
    return false;
  }
}

class GameWordDatabase {
  static const List<DrawingWordPrompt> prompts = <DrawingWordPrompt>[
    // Vehicles
    DrawingWordPrompt(word: 'Bicycle', category: 'Vehicles', synonyms: ['bike', 'cycle'], hint: 'Two wheels with pedals'),
    DrawingWordPrompt(word: 'Airplane', category: 'Vehicles', synonyms: ['plane', 'aeroplane', 'jet'], hint: 'Flies in the sky'),
    DrawingWordPrompt(word: 'Submarine', category: 'Vehicles', synonyms: ['sub'], hint: 'Travels underwater'),
    DrawingWordPrompt(word: 'Helicopter', category: 'Vehicles', synonyms: ['chopper'], hint: 'Rotating blades on top'),
    DrawingWordPrompt(word: 'Rocket', category: 'Vehicles', synonyms: ['spaceship', 'spacecraft'], hint: 'Launches into outer space'),
    DrawingWordPrompt(word: 'Sailboat', category: 'Vehicles', synonyms: ['boat', 'yacht', 'ship'], hint: 'Moves with the wind'),

    // Animals
    DrawingWordPrompt(word: 'Elephant', category: 'Animals', synonyms: ['mammoth'], hint: 'Has a long trunk'),
    DrawingWordPrompt(word: 'Giraffe', category: 'Animals', hint: 'Has a very long neck'),
    DrawingWordPrompt(word: 'Penguin', category: 'Animals', hint: 'Flightless bird in the cold'),
    DrawingWordPrompt(word: 'Kangaroo', category: 'Animals', hint: 'Hops and has a pouch'),
    DrawingWordPrompt(word: 'Octopus', category: 'Animals', synonyms: ['squid'], hint: 'Has eight arms in the sea'),
    DrawingWordPrompt(word: 'Butterfly', category: 'Animals', synonyms: ['moth'], hint: 'Colorful wings, starts as caterpillar'),
    DrawingWordPrompt(word: 'Dinosaur', category: 'Animals', synonyms: ['t-rex', 'dino'], hint: 'Prehistoric giant creature'),

    // Food
    DrawingWordPrompt(word: 'Pizza', category: 'Food', synonyms: ['pizza slice', 'pie'], hint: 'Round crust with melted cheese'),
    DrawingWordPrompt(word: 'Burger', category: 'Food', synonyms: ['hamburger', 'cheeseburger'], hint: 'Patty inside buns'),
    DrawingWordPrompt(word: 'Ice Cream', category: 'Food', synonyms: ['icecream', 'gelato', 'cone'], hint: 'Sweet cold scoop on a cone'),
    DrawingWordPrompt(word: 'Pineapple', category: 'Food', hint: 'Tropical fruit with spiky crown'),
    DrawingWordPrompt(word: 'Cupcake', category: 'Food', synonyms: ['cake', 'muffin'], hint: 'Small cake with frosting'),
    DrawingWordPrompt(word: 'Sushi', category: 'Food', synonyms: ['sushi roll', 'maki'], hint: 'Rice and fish wrapped in seaweed'),

    // Everyday Objects
    DrawingWordPrompt(word: 'Guitar', category: 'Objects', synonyms: ['acoustic guitar', 'electric guitar'], hint: 'String musical instrument'),
    DrawingWordPrompt(word: 'Umbrella', category: 'Objects', synonyms: ['parasol'], hint: 'Keeps you dry in the rain'),
    DrawingWordPrompt(word: 'Eyeglasses', category: 'Objects', synonyms: ['glasses', 'spectacles'], hint: 'Worn on face to see'),
    DrawingWordPrompt(word: 'Wristwatch', category: 'Objects', synonyms: ['watch', 'clock'], hint: 'Tells time on your wrist'),
    DrawingWordPrompt(word: 'Microscope', category: 'Objects', hint: 'Magnifies tiny cells'),
    DrawingWordPrompt(word: 'Telescope', category: 'Objects', hint: 'Looks at stars in the night'),
    DrawingWordPrompt(word: 'Hourglass', category: 'Objects', synonyms: ['sand timer', 'sandglass'], hint: 'Sand trickles down through glass'),
    DrawingWordPrompt(word: 'Crown', category: 'Objects', synonyms: ['tiara'], hint: 'Royal golden headwear'),

    // Landmarks & Nature
    DrawingWordPrompt(word: 'Eiffel Tower', category: 'Landmarks', synonyms: ['tower of paris'], hint: 'Iconic iron tower in Paris'),
    DrawingWordPrompt(word: 'Pyramid', category: 'Landmarks', synonyms: ['egyptian pyramid', 'giza'], hint: 'Ancient triangular stone monument'),
    DrawingWordPrompt(word: 'Volcano', category: 'Nature', hint: 'Mountain erupting with hot lava'),
    DrawingWordPrompt(word: 'Lighthouse', category: 'Landmarks', hint: 'Beacon guiding ships at night'),
    DrawingWordPrompt(word: 'Windmill', category: 'Landmarks', hint: 'Blades turned by the wind'),
    DrawingWordPrompt(word: 'Campfire', category: 'Nature', synonyms: ['fire', 'bonfire'], hint: 'Flames with logs and smoke'),
  ];

  static DrawingWordPrompt getRandomPrompt([Random? random]) {
    final Random r = random ?? Random();
    return prompts[r.nextInt(prompts.length)];
  }
}

