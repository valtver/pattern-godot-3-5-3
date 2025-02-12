extends Node
# warning-ignore-all:UNUSED_SIGNAL
signal TimerTimeout

signal AppStart(AppDataResourceArray, LevelResource)

signal HudTimerUpdate
signal HudTimeScoreAnimation
signal HudTimeUp
signal HudSetFails

signal Click
signal InactiveClick

signal StartGame
signal LoadComplete

signal AppMainMenu
signal LevelEnd
#APP EVENTS
signal ShowAppBlocker
signal HideAppBlocker

#UI EVENTS
signal ShowUiMainScreen
signal ShowUiSettingsScreen
signal ShowUiSubLevelScreen

#HUD EVENTS
signal HudButtonPlayClick
signal HudButtonReplayClick
signal HudButtonSymbolClick
signal HudButtonMenuClick
signal HudButtonMenuUnClick
signal HudButtonHomeClick
signal HudButtonNextClick
signal GameStepStart
signal GameStepEnd
signal GameTaskEnd(isWin)
signal GameTaskStart
signal GameDataUpdate
signal GameNextLevel
signal GameLevelEnd(isWin)
signal GameLevelStart
signal GameRestart(node)
signal GameQuit

signal ShowHudStartScreen
signal ShowHudGameScreen
signal ShowHudMenuScreen
signal ShowHudWinScreen
signal ShowHudWinScreenScore
signal ShowHudLostScreen
signal ShowHudStepSuccess
signal ShowHudStepFail
signal ShowHudTutorialScreen

signal ShowHudSymbolButtons
signal HideHudSymbolButtons
signal ShowHudMenuButton
signal HideHudMenuButton

signal HudButtonTutorialClick

signal GameBonusCollected

signal ShowFastBlocker
#TUTORIAL
signal TutorialState1
