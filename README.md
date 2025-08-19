# Lupus in Fabula - iOS App

A beautiful, offline pass-and-play party game app that simulates the classic Werewolf/Mafia game using modern iOS technologies.

## Features

### 🎮 Core Game Features
- **Game Setup**: Configure 4-24 players with customizable role distributions
- **Role Reveal**: Secure pass-and-play role revelation with tap-and-hold mechanics
- **Night Phase**: Sequential role actions (Werewolves, Seer, Doctor) with guided prompts
- **Day Phase**: Voting interface with elimination mechanics
- **Win Detection**: Automatic win condition checking for both teams

### 🎯 Game Roles
- **Werewolf** 🐺: Eliminate villagers at night
- **Villager** 👤: Vote to eliminate suspected werewolves
- **Seer** 🔮: Check player alignments at night
- **Doctor** 💊: Protect players from werewolf attacks
- **Hunter** 🏹: Take revenge when eliminated

### 🎨 Design & UX
- **HIG-aligned**: Follows Apple Human Interface Guidelines
- **Dynamic Type**: Supports accessibility text scaling
- **SF Symbols**: Consistent iconography throughout
- **Haptic Feedback**: Tactile responses for key actions
- **Smooth Animations**: 60fps transitions and micro-interactions

### 🔒 Privacy & Security
- **Offline Only**: No internet connection required
- **Local Storage**: All data stays on device using SwiftData
- **No Tracking**: Zero analytics or data collection
- **Privacy Screen**: Clear explanation of data handling

## Technical Architecture

### 🏗️ Architecture
- **Feature-first**: Organized by game features rather than MVVM layers
- **Observation Framework**: Modern state management with `@Observable` and `@Bindable`
- **SwiftData**: Local persistence with `@Model` and `@Query`
- **NavigationStack**: Value-based navigation with type-safe routing

### 📱 Platform Requirements
- **iOS 17+**: Latest SwiftUI and Observation APIs
- **SwiftData**: Modern Core Data replacement
- **Dynamic Type**: Accessibility support
- **Haptics**: Tactile feedback for better UX

### 🗄️ Data Models
```swift
@Model final class Role
@Model final class RolePreset  
@Model final class SavedConfig
@Model final class GameSession
```

## Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+ deployment target
- macOS 14.0+ (for development)

### Installation
1. Clone the repository
2. Open `LupusInFabula.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project

### First Launch
The app automatically seeds:
- 5 core roles (Werewolf, Villager, Seer, Doctor, Hunter)
- 3 preset configurations for different player counts
- Sample game configurations

## Game Flow

### 1. Setup Phase
- Choose player count (4-24)
- Select from preset configurations or customize roles
- Validate role distribution matches player count
- Save configuration for future games

### 2. Role Reveal Phase
- Pass device between players
- Tap-and-hold to reveal individual roles
- Blur effects and haptics for secure revelation
- Automatic progression to next player

### 3. Night Phase
- Sequential role actions guided by narrator prompts
- Werewolves choose elimination targets
- Special roles use their abilities
- Coach-style instructions for each action

### 4. Day Phase
- Display current game state (alive players, team counts)
- Voting interface for player elimination
- Win condition checking
- Round progression

## Development Notes

### State Management
- Uses `@Observable` for feature states
- `@Bindable` for view bindings
- No `ObservableObject` or Combine
- Direct model binding in views

### Navigation
- `NavigationStack` with value-based routing
- `GamePhase` enum for type-safe navigation
- Path state managed in feature states

### Persistence
- SwiftData for all local storage
- Automatic seeding on first launch
- Configuration persistence between sessions
- Game session state management

### Accessibility
- VoiceOver labels on all interactive elements
- Dynamic Type support throughout
- High contrast mode compatibility
- Haptic feedback for key actions

## Testing

The app includes:
- Unit tests for game logic
- UI tests for critical user flows
- Deterministic tests for voting and elimination rules

## Privacy

This app is designed with privacy as a core principle:
- **No network access**: Completely offline
- **No data collection**: Zero analytics or tracking
- **Local storage only**: SwiftData keeps everything on device
- **No third-party services**: No external dependencies
- **User control**: Complete data deletion on app removal

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow the existing code style and architecture
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by the classic Werewolf/Mafia party game
- Built with modern iOS development best practices
- Designed for accessibility and privacy
- Uses Apple's latest frameworks and APIs
