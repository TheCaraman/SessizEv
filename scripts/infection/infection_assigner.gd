class_name InfectionAssigner
extends RefCounted
## Decides, once per campaign, who is infected (docs/DecisionLog.md, K-005).
##
## Rules:
##   - Only characters with can_be_infected take part (Lily never does, K-002).
##   - Between MIN_INFECTED and MAX_INFECTED characters are infected.
##   - At least one of the first six visitor offers is infected.
##   - The same seed always gives the same result.
##
## The result is stored in the save and never rolled again.

const MIN_INFECTED: int = 3
const MAX_INFECTED: int = 5


## Returns a dictionary of character id -> bool for the whole roster.
static func assign(campaign_seed: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = campaign_seed

	var eligible: Array[String] = []
	var early: Array[String] = []
	for npc: Dictionary in Roster.NPCS:
		if not npc["can_be_infected"]:
			continue
		eligible.append(npc["id"])
		if npc["arrival_order"] <= Roster.EARLY_ARRIVAL_LIMIT:
			early.append(npc["id"])

	# Fisher-Yates shuffle with the campaign's own generator.
	for i: int in range(eligible.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var swap: String = eligible[i]
		eligible[i] = eligible[j]
		eligible[j] = swap

	var count: int = rng.randi_range(MIN_INFECTED, MAX_INFECTED)
	var chosen: Array[String] = eligible.slice(0, count)

	var has_early: bool = false
	for id: String in chosen:
		if early.has(id):
			has_early = true
			break
	if not has_early:
		# Swap the last pick for one of the early arrivals.
		chosen[count - 1] = early[rng.randi_range(0, early.size() - 1)]

	var result: Dictionary = {}
	for npc: Dictionary in Roster.NPCS:
		result[npc["id"]] = chosen.has(npc["id"])
	return result
