import 'package:kidsplazone/models/game_card.dart';
import 'package:kidsplazone/screens/aphabetQuegePage.dart';
import 'package:kidsplazone/screens/balloon_pop_page_view.dart';
import 'package:kidsplazone/screens/car_rally_view_screens.dart';
import 'package:kidsplazone/screens/coloring_page_view.dart';
import 'package:kidsplazone/screens/fruit_catcher_pro.dart';
import 'package:kidsplazone/screens/math_adventure_screen.dart';
import 'package:kidsplazone/screens/memory_matched_page_screen.dart';
import 'package:kidsplazone/screens/swaptitle_screens.dart';

final List<GameCardData> games = <GameCardData>[
  GameCardData('🎈 Balloon Pop', () => const BalloonPopPage()),
  GameCardData('🧠 Memory Match', () => const MemoryMatchPage()),
  GameCardData('🧩 Jigsaw Puzzle', () => const SwapPuzzlePage()),
  GameCardData('🎨 Coloring Board', () => const ColoringPage()),
  GameCardData('🔢 Math Adventure', () => const MathAdventurePage()),
  GameCardData('🔤 Alphabet Quest', () => const AlphabetQuestPage()),
  GameCardData('🏎️ Car Rally', () => const CarRallyLearnPage()),
  GameCardData('🍎 Fruit Cacther', () => const FruitCatcherPro()),
];
