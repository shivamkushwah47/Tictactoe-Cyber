# 🎮 TicTacToe Cyber Edition — Flutter

A fully functional, animated Tic-Tac-Toe game built with Flutter.

## ✨ Features

### Gameplay
- ⚔️ **2 Player Mode** — play with two players on the same device
- 🤖 **vs AI Mode** — challenge the computer
- 🧠 **3 AI Difficulty Levels**: Easy, Medium, Hard (Hard = unbeatable Minimax AI!)

### Animations (Flutter Level)
- 🎯 Piece placement: scale + rotate spring animation
- 💥 Haptic feedback on every move
- ✨ Winning line: animated glowing laser beam (CustomPainter)
- 🏆 Winning cells: pulse animation
- 📳 Draw: shake animation
- 🎊 Confetti burst when someone wins
- 🌊 Animated cyberpunk background (CustomPainter)
- 🔄 Score cards: active player pulse + glow effect
- 📱 Page transitions: fade + slide
- 🎭 Win modal: elastic scale-in animation
- 💡 AI thinking: bouncing dots indicator

### Game Features
- 📊 Score tracking (X, O, Draws)
- 📅 Match history indicators
- 🏠 Home screen with board preview
- 🎨 Difficulty selector
- 🔁 New Round & Reset All buttons

## 🚀 Setup & Run

### Requirements
- Flutter 3.10+
- Dart 3.0+
- Android Studio / VS Code

### Steps

```bash
# 1. Navigate to the project folder
cd tictactoe

# 2. Install dependencies
flutter pub get

# 3. Run the app (on a connected device or emulator)
flutter run

# 4. Build release APK
flutter build apk --release
# APK location: build/app/outputs/flutter-apk/app-release.apk
```

### Dependencies

```yaml
flutter_animate: ^4.3.0    # Smooth animations
confetti: ^0.7.0           # Win celebration
google_fonts: ^6.1.0       # Orbitron + Rajdhani fonts
shared_preferences: ^2.2.2 # Score persistence
audioplayers: ^5.2.1       # Sound effects (optional)
```

## 📁 Project Structure

```text
lib/
├── main.dart                    # App entry point
├── theme/
│   └── app_theme.dart          # Colors, gradients, shadows
├── models/
│   └── game_logic.dart         # Game state + Minimax AI
├── screens/
│   ├── home_screen.dart        # Splash/menu screen
│   └── game_screen.dart        # Main game screen
└── widgets/
    ├── cell_widget.dart        # Animated game cell
    ├── score_card.dart         # Player score display
    └── win_line_painter.dart   # Custom win line painter
```

## 🎨 Design

**Theme**: Cyberpunk / Neon Dark

- Background: Deep Navy `#0A0A1A`
- X Color: Cyan `#00E5FF`
- O Color: Hot Pink `#FF4081`
- Font: Orbitron (headings) + Rajdhani (body)

---

Made with ❤️ using Flutter
