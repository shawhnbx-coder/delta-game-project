## Autoload singleton for random numbers
# Can be used to force predictable behavior for debugging

extends Node
class_name RngClass

var rng = RandomNumberGenerator.new()

# -------------------------------------------------------------------
## Initialize with a specific seed or a random seed
func _ready():
	# Set seed with system time for non‑deterministic starts
	rng.randomize()
	# Optionally set a specific seed for reproducible debugging
	# Note: this overrides the previous randomize() call
	# rng.seed = 12345

# -------------------------------------------------------------------
# Optional helper methods for easy access
func randf() -> float:
	return rng.randf()

func randi_range(min_val: int, max_val: int) -> int:
	return rng.randi_range(min_val, max_val)

func pick_random(array: Array):
	return array.pick_random()

# -------------------------------------------------------------------
## Pick a random element from one of the value arrays
# Uses the ratios of the weights
func pick_weighted(values: Array[Array], weights: Array[float]):
	assert(values.size() == weights.size(), "pick_weighted: array sizes must match")
	var idx = rng.rand_weighted(weights)
	if idx == -1 or values[idx].is_empty():
		return null
	return values[idx].pick_random()
