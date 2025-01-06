extends Resource

export (int, -1, 99) var selectedLevelIndex = -1
export (int, -1, 99) var selectedSubLevelIndex = -1
export (int) var sessionTimeScore = 0
export (int) var sessionStars = 0
export (int) var sessionTimeScoreLastStep = 0
export (int) var sessionFails = 0
var gameStep
var selectedButton = null


