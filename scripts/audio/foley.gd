class_name Foley
extends RefCounted
## FOLEY-001: original synthesized placeholder foley (not final sound design).
## Footsteps on a wooden floor, a room door opening and a room door swinging
## shut. Every cue is built from fixed seeds, so the same call always returns
## the same samples. Nothing here touches campaign state.
##
## Recorded foley wins: a file in RECORDED_DIR replaces the synthesized cue
## (see door_open(), door_close(), footstep_takes()). The synthesized cues
## remain the fallback when no recording is there.
##
## Each caller builds its own streams (no shared cache): a stream is released
## together with the node that plays it, which the hardware audio lifecycle
## gate relies on.

const RATE: int = 22050
## Recorded cues, made by Codex (art/sound). Names, without extension:
## door_open, door_close (the leaf hits the frame at RoomDoor.CLOSE_SECONDS
## into the file), footstep_0, footstep_1, ... (any number, one step each).
const RECORDED_DIR: String = "res://assets/audio/foley/"
const RECORDED_EXTENSIONS: Array[String] = ["ogg", "wav"]
## Peak level every cue is normalized to (of full scale).
const PEAK: float = 0.6
## Number of distinct footstep takes.
const FOOTSTEP_VARIANTS: int = 4
const FOOTSTEP_SECONDS: float = 0.24
const DOOR_OPEN_SECONDS: float = 0.55
## The close cue lasts until shortly after the latch.
const DOOR_CLOSE_TAIL: float = 0.25


## The door opening cue: the recording if there is one.
static func door_open() -> AudioStream:
	var recorded: AudioStream = recorded_cue("door_open")
	return recorded if recorded != null else make_door_open()


## The door closing cue, hit at [param shut_at] seconds: the recording if
## there is one (it must put the hit at the same moment).
static func door_close(shut_at: float) -> AudioStream:
	var recorded: AudioStream = recorded_cue("door_close")
	return recorded if recorded != null else make_door_close(shut_at)


## Footstep takes: every recorded footstep_N in order, or the synthesized
## ones when none is recorded.
static func footstep_takes() -> Array[AudioStream]:
	var takes: Array[AudioStream] = []
	while true:
		var recorded: AudioStream = recorded_cue("footstep_%d" % takes.size())
		if recorded == null:
			break
		takes.append(recorded)
	if takes.is_empty():
		for variant: int in FOOTSTEP_VARIANTS:
			takes.append(make_footstep(variant))
	return takes


## A recorded cue by name, or null.
static func recorded_cue(cue: String) -> AudioStream:
	for extension: String in RECORDED_EXTENSIONS:
		var path: String = RECORDED_DIR + cue + "." + extension
		if ResourceLoader.exists(path):
			return load(path) as AudioStream
	return null


## One footstep take: a soft heel thud on boards, then a lighter toe contact
## and a short scuff. [param variant] picks one of FOOTSTEP_VARIANTS takes.
static func make_footstep(variant: int) -> AudioStreamWAV:
	variant = posmod(variant, FOOTSTEP_VARIANTS)
	var noise := RandomNumberGenerator.new()
	noise.seed = 52011 + variant * 977
	# Owner feedback: the first takes were too bright and too loud. These are
	# a dull heel on hollow boards: low thud, a soft (not clicky) contact, the
	# boards ringing low and short, and a muffled toe. Nothing above ~1.5 kHz.
	var thud_hz: float = 58.0 + 5.0 * variant
	var toe_at: float = 0.055 + 0.008 * variant
	var count: int = int(RATE * FOOTSTEP_SECONDS)
	var values := PackedFloat32Array()
	values.resize(count)
	var low: float = 0.0
	var lower: float = 0.0
	var board := _Resonator.new(165.0 + 18.0 * variant, 0.9975)
	var hollow := _Resonator.new(390.0 + 25.0 * variant, 0.994)
	for i: int in count:
		var time: float = float(i) / RATE
		# Two low-pass stages: the noise is a dull knock, not a hiss.
		low = low * 0.90 + noise.randf_range(-1.0, 1.0) * 0.10
		lower = lower * 0.82 + low * 0.18
		var value: float = 0.0
		# Heel: a soft-edged thud.
		var heel: float = _attack(time, 0.006)
		value += heel * sin(TAU * thud_hz * time) * exp(-time * 30.0) * 0.8
		value += heel * lower * exp(-time * 55.0) * 2.2
		# Toe: lighter and duller.
		var age: float = time - toe_at
		var toe: float = 0.0
		if age >= 0.0:
			toe = _attack(age, 0.005) * exp(-age * 75.0)
			value += toe * lower * 1.1
			value += toe * sin(TAU * thud_hz * 1.4 * age) * 0.25
		# The boards ring low and short under each contact.
		var strike: float = (heel * exp(-time * 90.0) + toe * 0.5) * lower
		value += board.step(strike) * 9.0 + hollow.step(strike) * 2.5
		values[i] = value
	return _to_wav(values)


## Door opening, as an ordinary interior door with a lever handle (owner
## feedback: the first version's long hinge creak sounded artificial):
## the lever goes down with a small metal click, the latch bolt pulls out of
## the strike plate with a clack, the leaf comes off the frame with a soft
## wooden knock, and the swing moves air. Only a faint, short hinge rub.
static func make_door_open() -> AudioStreamWAV:
	var noise := RandomNumberGenerator.new()
	noise.seed = 88123
	var count: int = int(RATE * DOOR_OPEN_SECONDS)
	var values := PackedFloat32Array()
	values.resize(count)
	var lever := _Metal.new([1830.0, 2960.0, 4410.0], 160.0)
	var bolt := _Metal.new([1270.0, 2140.0, 3380.0, 5150.0], 110.0)
	var leaf := _Wood.new(noise, [118.0, 245.0, 510.0], [0.9965, 0.993, 0.988])
	var air := _Air.new(noise)
	var rub := _Creak.new(noise, 0.17, 0.30, 95.0, 120.0, 0.08)
	for i: int in count:
		var time: float = float(i) / RATE
		var value: float = lever.sample(time, 0.0) * 0.55
		value += lever.sample(time, 0.035) * 0.25  # the lever's spring
		value += bolt.sample(time, 0.085) * 0.8
		value += leaf.sample(time, 0.10, 0.35)
		value += air.sample(time, 0.10, DOOR_OPEN_SECONDS - 0.03, 0.30) * 0.3
		value += rub.sample(time)
		values[i] = value
	return _to_wav(values)


## Door swinging shut: the leaf pushes air as it swings, then meets the frame
## at [param shut_at] seconds: a solid wooden knock with the latch bolt
## snapping into the strike plate at the same moment, and a small rattle.
static func make_door_close(shut_at: float) -> AudioStreamWAV:
	var noise := RandomNumberGenerator.new()
	noise.seed = 88457
	var count: int = int(RATE * (shut_at + DOOR_CLOSE_TAIL))
	var values := PackedFloat32Array()
	values.resize(count)
	var frame := _Wood.new(noise, [92.0, 205.0, 430.0, 760.0], [0.997, 0.9945, 0.991, 0.985])
	var bolt := _Metal.new([1340.0, 2230.0, 3510.0, 4870.0], 95.0)
	var rattle := _Metal.new([2610.0, 3890.0], 220.0)
	var air := _Air.new(noise)
	for i: int in count:
		var time: float = float(i) / RATE
		var value: float = air.sample(time, 0.0, shut_at, 0.75) * 0.35
		var age: float = time - shut_at
		if age >= 0.0:
			value += _attack(age, 0.0015) * sin(TAU * 64.0 * age) * exp(-age * 26.0) * 0.9
		value += frame.sample(time, shut_at, 1.0)
		value += bolt.sample(time, shut_at + 0.006) * 0.7
		value += rattle.sample(time, shut_at + 0.055) * 0.15
		values[i] = value
	return _to_wav(values)


## Seconds into [param stream] where the loudest sample sits.
static func peak_time(stream: AudioStreamWAV) -> float:
	var best: int = 0
	var best_index: int = 0
	for i: int in stream.data.size() / 2:
		var level: int = absi(stream.data.decode_s16(i * 2))
		if level > best:
			best = level
			best_index = i
	return float(best_index) / stream.mix_rate


static func _attack(age: float, rise: float) -> float:
	return clampf(age / rise, 0.0, 1.0) if age >= 0.0 else 0.0


static func _to_wav(values: PackedFloat32Array) -> AudioStreamWAV:
	var peak: float = 0.0
	for value: float in values:
		peak = maxf(peak, absf(value))
	var scale: float = PEAK / peak if peak > 0.0 else 0.0
	var samples := PackedByteArray()
	samples.resize(values.size() * 2)
	for i: int in values.size():
		var faded: float = values[i] * scale
		# Short fade at the very end so a cue never ends on a click.
		var left: int = values.size() - i
		if left < 64:
			faded *= float(left) / 64.0
		samples.encode_s16(i * 2, int(clampf(faded, -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = samples
	return wav


## Two-pole resonator: a wooden body ringing at one frequency.
class _Resonator:
	var _a1: float
	var _a2: float
	var _y1: float = 0.0
	var _y2: float = 0.0

	func _init(hz: float, radius: float) -> void:
		_a1 = 2.0 * radius * cos(TAU * hz / Foley.RATE)
		_a2 = -radius * radius

	func step(x: float) -> float:
		var y: float = _a1 * _y1 + _a2 * _y2 + x
		_y2 = _y1
		_y1 = y
		return y * 0.02


## Hinge creak: stick-slip pulses whose rate glides from [param from_hz] to
## [param to_hz], each ringing a small wooden resonance.
class _Creak:
	var _noise: RandomNumberGenerator
	var _start: float
	var _end: float
	var _from: float
	var _to: float
	var _level: float
	var _phase: float = 0.0
	var _body: _Resonator
	var _bright: _Resonator

	func _init(noise: RandomNumberGenerator, start: float, end: float, from_hz: float, to_hz: float, level: float) -> void:
		_noise = noise
		_start = start
		_end = end
		_from = from_hz
		_to = to_hz
		_level = level
		_body = _Resonator.new(880.0, 0.985)
		_bright = _Resonator.new(1730.0, 0.975)

	func sample(time: float) -> float:
		var excitation: float = 0.0
		if time >= _start and time < _end:
			var t: float = (time - _start) / (_end - _start)
			# Uneven speed makes it sound like wood, not a tone.
			var rate: float = lerpf(_from, _to, t) * (1.0 + 0.12 * sin(TAU * 7.0 * t) + _noise.randf_range(-0.05, 0.05))
			_phase += rate / Foley.RATE
			if _phase >= 1.0:
				_phase -= 1.0
				excitation = 1.0 + _noise.randf_range(-0.3, 0.3)
			excitation *= sin(PI * t) * _level
		return (_body.step(excitation) + _bright.step(excitation) * 0.5) * 8.0


## Small metal parts (lever, latch bolt, strike plate): a few inharmonic
## modes that die away within a few hundredths of a second.
class _Metal:
	var _modes: Array
	var _decay: float

	func _init(modes: Array, decay: float) -> void:
		_modes = modes
		_decay = decay

	func sample(time: float, at: float) -> float:
		var age: float = time - at
		if age < 0.0 or age > 0.12:
			return 0.0
		var value: float = 0.0
		var weight: float = 1.0
		for index: int in _modes.size():
			var hz: float = _modes[index]
			value += sin(TAU * hz * age + index * 1.3) * exp(-age * _decay * (1.0 + 0.45 * index)) * weight
			weight *= 0.62
		return value * Foley._attack(age, 0.0004)


## A wooden panel struck once: a short noise burst for the knock itself,
## then the panel's own low modes ringing briefly.
class _Wood:
	var _noise: RandomNumberGenerator
	var _modes: Array = []
	var _gains: Array = []
	var _low: float = 0.0

	func _init(noise: RandomNumberGenerator, hz: Array, radius: Array) -> void:
		_noise = noise
		for index: int in hz.size():
			_modes.append(_Resonator.new(hz[index], radius[index]))
			# Roughly equal loudness per mode for the same strike.
			_gains.append((1.0 - float(radius[index])) * 2.0 * sin(TAU * float(hz[index]) / Foley.RATE) / 0.02 * pow(0.7, index))

	func sample(time: float, at: float, level: float) -> float:
		_low = _low * 0.6 + _noise.randf_range(-1.0, 1.0) * 0.4
		var age: float = time - at
		var strike: float = 0.0
		if age >= 0.0 and age < 0.05:
			strike = _low * exp(-age * 220.0) * Foley._attack(age, 0.0008) * level
		var value: float = strike * 0.35
		for index: int in _modes.size():
			value += (_modes[index] as _Resonator).step(strike) * float(_gains[index]) * 6.0
		return value


## Air moved by the swinging leaf: deep, soft noise that swells to a peak at
## [param peak] (0-1 of the swing) and dies away by [param end].
class _Air:
	var _noise: RandomNumberGenerator
	var _a: float = 0.0
	var _b: float = 0.0

	func _init(noise: RandomNumberGenerator) -> void:
		_noise = noise

	func sample(time: float, start: float, end: float, peak: float) -> float:
		_a = _a * 0.95 + _noise.randf_range(-1.0, 1.0) * 0.05
		_b = _b * 0.93 + _a * 0.07
		if time < start or time >= end:
			return 0.0
		var t: float = (time - start) / (end - start)
		var envelope: float = pow(t / peak, 1.5) if t < peak else pow((1.0 - t) / (1.0 - peak), 1.2)
		return _b * envelope * 6.0
