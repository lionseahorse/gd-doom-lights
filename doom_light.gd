extends Light3D

var PatternString: String:
	set(value):
		PatternString = value
		PreviousCharacter = value[0]
		#print("PatternString value: " + str(value))

@export var LightEnergyMultiplier: float = 1 ##The normal Energy property is overwritten by the code, so adjust this instead.
@export var FlickerRate: float = 0.1
@export_enum("Custom", "normal", "FLICKER", "SLOW STRONG PULSE", "CANDLE (first variety)", "FAST STROBE", "GENTLE PULSE 1", "FLICKER (second variety)", "CANDLE (second variety)", "CANDLE (third variety)", "SLOW STROBE (fourth variety)", "FLUORESCENT FLICKER", "SLOW PULSE NOT FADE TO BLACK") var Pattern: int = 1 :
	set(value):
		CurrentIndex = 0
		Pattern = value
		#print("Enum value: " + str(value))
		if(value == 0):
			assert(CustomString != "", "The light pattern is set to 'Custom', but no custom pattern string is given!")
			PatternString = CustomString
		else:
			PatternString = DefaultPatternsDict[value - 1]

@export var CustomString: String
@export var Interpolate: bool = true

var DefaultPatternsDict: = {
	0: "m",
	1: "mmnmmommommnonmmonqnmmo",
	2: "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba",
	3: "mmmmmaaaaammmmmaaaaaabcdefgabcdefg",
	4: "mamamamamama",
	5: "jklmnopqrstuvwxyzyxwvutsrqponmlkj",
	6: "nmonqnmomnmomomno",
	7: "mmmaaaabcdefgmmmmaaaammmaamm",
	8: "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa",
	9: "aaaaaaaazzzzzzzz",
	10: "mmamammmmammamamaaamammma",
	11: "abcdefghijklmnopqrrqponmlkjihgfedcba"
}

var CurrentIndex: int = 0
var PreviousCharacter: String
var accumulator: float = 0.0

func letterToPercent(letter: String) -> float:
	return (letter.to_lower().to_ascii_buffer()[0] - "a".to_ascii_buffer()[0]) / (float("z".to_ascii_buffer()[0] - float("a".to_ascii_buffer()[0])))

func _ready() -> void:
	Pattern = Pattern #Force the setter to happen once before starting _process

func _process(delta) -> void:
	accumulator += delta
	if(accumulator >= FlickerRate):
		accumulator -= FlickerRate
		PreviousCharacter = PatternString[CurrentIndex]
		CurrentIndex += 1
		CurrentIndex = CurrentIndex % PatternString.length()
		if(not Interpolate):
			light_energy = letterToPercent(PatternString[CurrentIndex]) * LightEnergyMultiplier
	if(Interpolate):
		light_energy = lerp(letterToPercent(PreviousCharacter), letterToPercent(PatternString[CurrentIndex]), accumulator / FlickerRate) * LightEnergyMultiplier
