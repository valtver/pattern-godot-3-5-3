extends Node
# warning-ignore-all:UNUSED_SIGNAL
signal HudTimerUpdate
signal HudWinScore

signal Click
signal InactiveClick

signal StartGame
signal LoadComplete

signal AppMainMenu
signal LevelEnd

#UI EVENTS
signal ShowUiMainScreen
signal ShowUiSettingsScreen
signal ShowUiSubLevelScreen

#HUD EVENTS
signal ShowHudStartScreen
signal ShowHudGameScreen
signal ShowHudMenuScreen
signal ShowHudWinScreen
signal ShowHudLostScreen
signal ShowHudTutorialScreen

signal ShowHudSymbolButtons
signal HideHudSymbolButtons
signal ShowHudMenuButton
signal HideHudMenuButton

signal HudButtonSymbolClick
signal HudButtonPlayClick
signal HudButtonMenuClick
signal HudButtonTutorialClick
signal HudButtonReplayClick
signal HudButtonHomeClick
signal HudButtonNextClick

#TUTORIAL
signal TutorialState1
