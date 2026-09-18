import 'dart:math';
import '../models/drawing_stroke.dart';
import '../models/game_words.dart';

class BotDrawingService {
  final Random _random = Random();

  /// Generates an intelligent hand-drawn stroke for an artist bot who knows [prompt],
  /// drawing part [stepIndex] of the object.
  DrawingStroke generateArtistStroke({
    required String botId,
    required DrawingWordPrompt prompt,
    required int stepIndex,
    required int colorValue,
    required double canvasWidth,
    required double canvasHeight,
  }) {
    // Normalizing drawing area to center 260x260 area inside canvas
    final double midX = canvasWidth / 2;
    final double midY = canvasHeight / 2;

    final String word = prompt.word.toLowerCase();
    List<DrawingPoint> points = <DrawingPoint>[];

    if (word.contains('bicycle') || word.contains('bike')) {
      points = _drawBicyclePart(stepIndex, midX, midY);
    } else if (word.contains('pizza')) {
      points = _drawPizzaPart(stepIndex, midX, midY);
    } else if (word.contains('airplane') || word.contains('plane')) {
      points = _drawAirplanePart(stepIndex, midX, midY);
    } else if (word.contains('ice cream')) {
      points = _drawIceCreamPart(stepIndex, midX, midY);
    } else if (word.contains('elephant')) {
      points = _drawElephantPart(stepIndex, midX, midY);
    } else if (word.contains('guitar')) {
      points = _drawGuitarPart(stepIndex, midX, midY);
    } else if (word.contains('eyeglasses') || word.contains('glasses')) {
      points = _drawGlassesPart(stepIndex, midX, midY);
    } else if (word.contains('watch') || word.contains('clock')) {
      points = _drawClockPart(stepIndex, midX, midY);
    } else if (word.contains('pyramid') || word.contains('tower') || word.contains('eiffel')) {
      points = _drawMonumentPart(stepIndex, midX, midY);
    } else if (prompt.category == 'Animals') {
      points = _drawGenericAnimalPart(stepIndex, midX, midY);
    } else if (prompt.category == 'Vehicles') {
      points = _drawGenericVehiclePart(stepIndex, midX, midY);
    } else if (prompt.category == 'Food') {
      points = _drawGenericFoodPart(stepIndex, midX, midY);
    } else {
      points = _drawGenericObjectPart(stepIndex, midX, midY);
    }

    // Apply organic hand jitter so strokes look authentic like human drawings
    final List<DrawingPoint> organicPoints = _addHandJitter(points);

    return DrawingStroke(
      playerId: botId,
      points: organicPoints,
      colorValue: colorValue,
      strokeWidth: 3.5 + _random.nextDouble() * 1.5,
    );
  }

  /// Generates a deceptive blending-in stroke for an impostor bot who does NOT know the word.
  DrawingStroke generateImpostorStroke({
    required String botId,
    required List<DrawingStroke> existingStrokes,
    required int colorValue,
    required double canvasWidth,
    required double canvasHeight,
  }) {
    final double midX = canvasWidth / 2;
    final double midY = canvasHeight / 2;
    List<DrawingPoint> points = <DrawingPoint>[];

    if (existingStrokes.isEmpty) {
      // Impostor is drawing first: draw an ambiguous central foundation line/curve
      final double startX = midX - 35 + _random.nextDouble() * 15;
      final double startY = midY - 10 + _random.nextDouble() * 20;
      points.add(DrawingPoint(startX, startY));
      points.add(DrawingPoint(midX, startY - 15));
      points.add(DrawingPoint(midX + 40, startY));
    } else {
      // Blend with existing lines: find a point near existing strokes and add a contour or detail
      final DrawingStroke anchorStroke =
          existingStrokes[_random.nextInt(existingStrokes.length)];
      if (anchorStroke.points.isNotEmpty) {
        final DrawingPoint anchor =
            anchorStroke.points[_random.nextInt(anchorStroke.points.length)];
        final double offsetX = (_random.nextDouble() - 0.5) * 40;
        final double offsetY = (_random.nextDouble() - 0.5) * 40;

        final double x0 = anchor.x + offsetX;
        final double y0 = anchor.y + offsetY;
        points.add(DrawingPoint(x0, y0));
        points.add(DrawingPoint(x0 + 15 + _random.nextDouble() * 20, y0 - 10 + _random.nextDouble() * 20));
        points.add(DrawingPoint(x0 + 35 + _random.nextDouble() * 15, y0 + 10));
      } else {
        points.add(DrawingPoint(midX - 20, midY));
        points.add(DrawingPoint(midX + 20, midY));
      }
    }

    final List<DrawingPoint> organicPoints = _addHandJitter(points);

    return DrawingStroke(
      playerId: botId,
      points: organicPoints,
      colorValue: colorValue,
      strokeWidth: 3.5,
    );
  }

  // --- Bicycle Parts ---
  List<DrawingPoint> _drawBicyclePart(int step, double cx, double cy) {
    switch (step % 5) {
      case 0: // Rear wheel
        return _generateCircle(cx - 55, cy + 30, 26);
      case 1: // Front wheel
        return _generateCircle(cx + 55, cy + 30, 26);
      case 2: // Main frame triangle
        return <DrawingPoint>[
          DrawingPoint(cx - 55, cy + 30),
          DrawingPoint(cx - 10, cy + 30),
          DrawingPoint(cx - 25, cy - 20),
          DrawingPoint(cx - 55, cy + 30),
        ];
      case 3: // Front fork & handlebars
        return <DrawingPoint>[
          DrawingPoint(cx + 55, cy + 30),
          DrawingPoint(cx + 35, cy - 25),
          DrawingPoint(cx + 25, cy - 35),
          DrawingPoint(cx + 45, cy - 35),
        ];
      default: // Seat & chain stay
        return <DrawingPoint>[
          DrawingPoint(cx - 38, cy - 20),
          DrawingPoint(cx - 12, cy - 20),
          DrawingPoint(cx - 10, cy + 30),
          DrawingPoint(cx + 35, cy - 25),
        ];
    }
  }

  // --- Pizza Parts ---
  List<DrawingPoint> _drawPizzaPart(int step, double cx, double cy) {
    switch (step % 5) {
      case 0: // Curved outer crust
        return <DrawingPoint>[
          DrawingPoint(cx - 55, cy - 60),
          DrawingPoint(cx - 20, cy - 70),
          DrawingPoint(cx + 20, cy - 70),
          DrawingPoint(cx + 55, cy - 60),
        ];
      case 1: // Left slice side
        return <DrawingPoint>[
          DrawingPoint(cx - 55, cy - 60),
          DrawingPoint(cx, cy + 65),
        ];
      case 2: // Right slice side
        return <DrawingPoint>[
          DrawingPoint(cx + 55, cy - 60),
          DrawingPoint(cx, cy + 65),
        ];
      case 3: // Pepperoni 1 & 2
        return _generateCircle(cx - 18, cy - 20, 10);
      default: // Pepperoni 3 & cheese detail
        return _generateCircle(cx + 15, cy - 10, 9);
    }
  }

  // --- Airplane Parts ---
  List<DrawingPoint> _drawAirplanePart(int step, double cx, double cy) {
    switch (step % 5) {
      case 0: // Fuselage (body)
        return <DrawingPoint>[
          DrawingPoint(cx - 80, cy),
          DrawingPoint(cx - 20, cy - 12),
          DrawingPoint(cx + 60, cy - 10),
          DrawingPoint(cx + 85, cy),
          DrawingPoint(cx + 60, cy + 10),
          DrawingPoint(cx - 20, cy + 12),
          DrawingPoint(cx - 80, cy),
        ];
      case 1: // Top main wing
        return <DrawingPoint>[
          DrawingPoint(cx - 10, cy - 10),
          DrawingPoint(cx - 30, cy - 65),
          DrawingPoint(cx - 5, cy - 65),
          DrawingPoint(cx + 30, cy - 10),
        ];
      case 2: // Bottom main wing
        return <DrawingPoint>[
          DrawingPoint(cx - 10, cy + 10),
          DrawingPoint(cx - 30, cy + 65),
          DrawingPoint(cx - 5, cy + 65),
          DrawingPoint(cx + 30, cy + 10),
        ];
      case 3: // Tail fin
        return <DrawingPoint>[
          DrawingPoint(cx - 65, cy),
          DrawingPoint(cx - 85, cy - 35),
          DrawingPoint(cx - 72, cy - 35),
          DrawingPoint(cx - 50, cy),
        ];
      default: // Windows / cockpit arc
        return <DrawingPoint>[
          DrawingPoint(cx + 65, cy - 6),
          DrawingPoint(cx + 78, cy),
          DrawingPoint(cx + 65, cy + 6),
        ];
    }
  }

  // --- Ice Cream Parts ---
  List<DrawingPoint> _drawIceCreamPart(int step, double cx, double cy) {
    switch (step % 5) {
      case 0: // Cone
        return <DrawingPoint>[
          DrawingPoint(cx - 40, cy + 10),
          DrawingPoint(cx, cy + 85),
          DrawingPoint(cx + 40, cy + 10),
          DrawingPoint(cx - 40, cy + 10),
        ];
      case 1: // Waffle cone grid
        return <DrawingPoint>[
          DrawingPoint(cx - 25, cy + 25),
          DrawingPoint(cx + 15, cy + 65),
        ];
      case 2: // Bottom scoop
        return <DrawingPoint>[
          DrawingPoint(cx - 45, cy + 10),
          DrawingPoint(cx - 40, cy - 25),
          DrawingPoint(cx, cy - 40),
          DrawingPoint(cx + 40, cy - 25),
          DrawingPoint(cx + 45, cy + 10),
        ];
      case 3: // Top scoop
        return <DrawingPoint>[
          DrawingPoint(cx - 30, cy - 30),
          DrawingPoint(cx - 25, cy - 60),
          DrawingPoint(cx, cy - 70),
          DrawingPoint(cx + 25, cy - 60),
          DrawingPoint(cx + 30, cy - 30),
        ];
      default: // Cherry & drip
        return _generateCircle(cx, cy - 78, 9);
    }
  }

  // --- Elephant Parts ---
  List<DrawingPoint> _drawElephantPart(int step, double cx, double cy) {
    switch (step % 5) {
      case 0: // Body dome
        return <DrawingPoint>[
          DrawingPoint(cx - 60, cy + 30),
          DrawingPoint(cx - 65, cy - 30),
          DrawingPoint(cx - 10, cy - 50),
          DrawingPoint(cx + 40, cy - 35),
          DrawingPoint(cx + 50, cy + 30),
        ];
      case 1: // Head & Trunk curving up
        return <DrawingPoint>[
          DrawingPoint(cx + 40, cy - 35),
          DrawingPoint(cx + 65, cy - 20),
          DrawingPoint(cx + 75, cy + 15),
          DrawingPoint(cx + 85, cy + 25),
          DrawingPoint(cx + 80, cy + 10),
        ];
      case 2: // Giant Ear
        return <DrawingPoint>[
          DrawingPoint(cx + 30, cy - 35),
          DrawingPoint(cx + 15, cy - 10),
          DrawingPoint(cx + 25, cy + 15),
          DrawingPoint(cx + 45, cy - 5),
        ];
      case 3: // Front Legs
        return <DrawingPoint>[
          DrawingPoint(cx + 30, cy + 30),
          DrawingPoint(cx + 30, cy + 70),
          DrawingPoint(cx + 45, cy + 70),
          DrawingPoint(cx + 45, cy + 30),
        ];
      default: // Back Legs & Tail
        return <DrawingPoint>[
          DrawingPoint(cx - 50, cy + 30),
          DrawingPoint(cx - 50, cy + 70),
          DrawingPoint(cx - 35, cy + 70),
          DrawingPoint(cx - 35, cy + 30),
        ];
    }
  }

  // --- Guitar Parts ---
  List<DrawingPoint> _drawGuitarPart(int step, double cx, double cy) {
    switch (step % 5) {
      case 0: // Body lower bout
        return <DrawingPoint>[
          DrawingPoint(cx - 40, cy + 10),
          DrawingPoint(cx - 50, cy + 50),
          DrawingPoint(cx, cy + 75),
          DrawingPoint(cx + 50, cy + 50),
          DrawingPoint(cx + 40, cy + 10),
          DrawingPoint(cx - 40, cy + 10),
        ];
      case 1: // Body upper bout
        return <DrawingPoint>[
          DrawingPoint(cx - 40, cy + 10),
          DrawingPoint(cx - 30, cy - 20),
          DrawingPoint(cx + 30, cy - 20),
          DrawingPoint(cx + 40, cy + 10),
        ];
      case 2: // Sound hole
        return _generateCircle(cx, cy + 15, 12);
      case 3: // Long neck
        return <DrawingPoint>[
          DrawingPoint(cx - 8, cy - 20),
          DrawingPoint(cx - 8, cy - 80),
          DrawingPoint(cx + 8, cy - 80),
          DrawingPoint(cx + 8, cy - 20),
        ];
      default: // Headstock
        return <DrawingPoint>[
          DrawingPoint(cx - 12, cy - 80),
          DrawingPoint(cx - 12, cy - 98),
          DrawingPoint(cx + 12, cy - 98),
          DrawingPoint(cx + 12, cy - 80),
        ];
    }
  }

  // --- Glasses Parts ---
  List<DrawingPoint> _drawGlassesPart(int step, double cx, double cy) {
    switch (step % 5) {
      case 0: // Left frame
        return _generateCircle(cx - 40, cy, 24);
      case 1: // Right frame
        return _generateCircle(cx + 40, cy, 24);
      case 2: // Bridge
        return <DrawingPoint>[
          DrawingPoint(cx - 16, cy - 5),
          DrawingPoint(cx, cy - 12),
          DrawingPoint(cx + 16, cy - 5),
        ];
      case 3: // Left temple
        return <DrawingPoint>[
          DrawingPoint(cx - 64, cy),
          DrawingPoint(cx - 95, cy - 20),
        ];
      default: // Right temple
        return <DrawingPoint>[
          DrawingPoint(cx + 64, cy),
          DrawingPoint(cx + 95, cy - 20),
        ];
    }
  }

  // --- Clock Parts ---
  List<DrawingPoint> _drawClockPart(int step, double cx, double cy) {
    switch (step % 5) {
      case 0: // Dial
        return _generateCircle(cx, cy, 45);
      case 1: // Top strap
        return <DrawingPoint>[
          DrawingPoint(cx - 20, cy - 43),
          DrawingPoint(cx - 20, cy - 85),
          DrawingPoint(cx + 20, cy - 85),
          DrawingPoint(cx + 20, cy - 43),
        ];
      case 2: // Bottom strap
        return <DrawingPoint>[
          DrawingPoint(cx - 20, cy + 43),
          DrawingPoint(cx - 20, cy + 85),
          DrawingPoint(cx + 20, cy + 85),
          DrawingPoint(cx + 20, cy + 43),
        ];
      case 3: // Hour Hand
        return <DrawingPoint>[
          DrawingPoint(cx, cy),
          DrawingPoint(cx + 18, cy - 12),
        ];
      default: // Minute Hand
        return <DrawingPoint>[
          DrawingPoint(cx, cy),
          DrawingPoint(cx, cy - 28),
        ];
    }
  }

  // --- Pyramid / Eiffel Tower / Landmark Parts ---
  List<DrawingPoint> _drawMonumentPart(int step, double cx, double cy) {
    switch (step % 5) {
      case 0: // Base
        return <DrawingPoint>[
          DrawingPoint(cx - 65, cy + 70),
          DrawingPoint(cx + 65, cy + 70),
        ];
      case 1: // Left sloped pillar
        return <DrawingPoint>[
          DrawingPoint(cx - 65, cy + 70),
          DrawingPoint(cx - 20, cy),
          DrawingPoint(cx, cy - 75),
        ];
      case 2: // Right sloped pillar
        return <DrawingPoint>[
          DrawingPoint(cx + 65, cy + 70),
          DrawingPoint(cx + 20, cy),
          DrawingPoint(cx, cy - 75),
        ];
      case 3: // Cross platform
        return <DrawingPoint>[
          DrawingPoint(cx - 35, cy + 20),
          DrawingPoint(cx + 35, cy + 20),
        ];
      default: // Spire tip
        return <DrawingPoint>[
          DrawingPoint(cx, cy - 75),
          DrawingPoint(cx, cy - 95),
        ];
    }
  }

  // --- Generic Animal Parts ---
  List<DrawingPoint> _drawGenericAnimalPart(int step, double cx, double cy) {
    switch (step % 5) {
      case 0: // Head
        return _generateCircle(cx, cy - 35, 28);
      case 1: // Ears
        return <DrawingPoint>[
          DrawingPoint(cx - 25, cy - 50),
          DrawingPoint(cx - 35, cy - 80),
          DrawingPoint(cx - 10, cy - 60),
          DrawingPoint(cx + 10, cy - 60),
          DrawingPoint(cx + 35, cy - 80),
          DrawingPoint(cx + 25, cy - 50),
        ];
      case 2: // Body
        return <DrawingPoint>[
          DrawingPoint(cx - 20, cy - 10),
          DrawingPoint(cx - 40, cy + 40),
          DrawingPoint(cx + 40, cy + 40),
          DrawingPoint(cx + 20, cy - 10),
        ];
      case 3: // Legs
        return <DrawingPoint>[
          DrawingPoint(cx - 30, cy + 40),
          DrawingPoint(cx - 30, cy + 70),
          DrawingPoint(cx + 30, cy + 40),
          DrawingPoint(cx + 30, cy + 70),
        ];
      default: // Tail & face
        return <DrawingPoint>[
          DrawingPoint(cx + 35, cy + 25),
          DrawingPoint(cx + 65, cy + 10),
          DrawingPoint(cx + 70, cy - 5),
        ];
    }
  }

  // --- Generic Vehicle Parts ---
  List<DrawingPoint> _drawGenericVehiclePart(int step, double cx, double cy) {
    switch (step % 5) {
      case 0: // Wheels
        return _generateCircle(cx - 45, cy + 35, 18);
      case 1: // Front Wheel
        return _generateCircle(cx + 45, cy + 35, 18);
      case 2: // Lower chassis
        return <DrawingPoint>[
          DrawingPoint(cx - 75, cy + 20),
          DrawingPoint(cx + 75, cy + 20),
        ];
      case 3: // Roof & windshield
        return <DrawingPoint>[
          DrawingPoint(cx - 45, cy + 20),
          DrawingPoint(cx - 25, cy - 25),
          DrawingPoint(cx + 25, cy - 25),
          DrawingPoint(cx + 50, cy + 20),
        ];
      default: // Bumpers & lights
        return <DrawingPoint>[
          DrawingPoint(cx - 75, cy + 20),
          DrawingPoint(cx - 75, cy + 5),
          DrawingPoint(cx - 60, cy + 5),
        ];
    }
  }

  // --- Generic Food Parts ---
  List<DrawingPoint> _drawGenericFoodPart(int step, double cx, double cy) {
    switch (step % 5) {
      case 0: // Plate / Bun base
        return <DrawingPoint>[
          DrawingPoint(cx - 60, cy + 25),
          DrawingPoint(cx, cy + 45),
          DrawingPoint(cx + 60, cy + 25),
        ];
      case 1: // Main filling / patty
        return <DrawingPoint>[
          DrawingPoint(cx - 55, cy + 10),
          DrawingPoint(cx + 55, cy + 10),
        ];
      case 2: // Bun top dome
        return <DrawingPoint>[
          DrawingPoint(cx - 55, cy),
          DrawingPoint(cx - 35, cy - 40),
          DrawingPoint(cx, cy - 50),
          DrawingPoint(cx + 35, cy - 40),
          DrawingPoint(cx + 55, cy),
        ];
      case 3: // Cheese drip / detail
        return <DrawingPoint>[
          DrawingPoint(cx - 25, cy + 10),
          DrawingPoint(cx - 15, cy + 25),
          DrawingPoint(cx - 5, cy + 10),
        ];
      default: // Garnish / seeds
        return _generateCircle(cx, cy - 25, 4);
    }
  }

  // --- Generic Object Parts ---
  List<DrawingPoint> _drawGenericObjectPart(int step, double cx, double cy) {
    switch (step % 5) {
      case 0: // Foundation
        return <DrawingPoint>[
          DrawingPoint(cx - 50, cy + 50),
          DrawingPoint(cx + 50, cy + 50),
          DrawingPoint(cx + 50, cy - 30),
          DrawingPoint(cx - 50, cy - 30),
          DrawingPoint(cx - 50, cy + 50),
        ];
      case 1: // Roof / Top
        return <DrawingPoint>[
          DrawingPoint(cx - 55, cy - 30),
          DrawingPoint(cx, cy - 75),
          DrawingPoint(cx + 55, cy - 30),
        ];
      case 2: // Center feature / Window
        return _generateCircle(cx, cy + 5, 16);
      case 3: // Stand / Column
        return <DrawingPoint>[
          DrawingPoint(cx, cy + 50),
          DrawingPoint(cx, cy + 85),
          DrawingPoint(cx - 25, cy + 85),
          DrawingPoint(cx + 25, cy + 85),
        ];
      default: // Accent details
        return <DrawingPoint>[
          DrawingPoint(cx - 30, cy + 5),
          DrawingPoint(cx - 30, cy + 30),
        ];
    }
  }

  List<DrawingPoint> _generateCircle(double cx, double cy, double radius) {
    final List<DrawingPoint> circle = <DrawingPoint>[];
    const int segments = 12;
    for (int i = 0; i <= segments; i++) {
      final double angle = (i / segments) * 2 * pi;
      circle.add(DrawingPoint(
        cx + cos(angle) * radius,
        cy + sin(angle) * radius,
      ));
    }
    return circle;
  }

  List<DrawingPoint> _addHandJitter(List<DrawingPoint> points) {
    if (points.isEmpty) return points;
    return points.map((p) {
      final double jitterX = (_random.nextDouble() - 0.5) * 2.5;
      final double jitterY = (_random.nextDouble() - 0.5) * 2.5;
      return DrawingPoint(p.x + jitterX, p.y + jitterY);
    }).toList();
  }
}

