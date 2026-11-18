class_name Foley
extends RefCounted
## FOLEY-001: original synthesized placeholder foley (not final sound design).
## Footsteps on a wooden floor, a room door opening and a room door swinging
## shut. Every cue is built from fixed seeds, so the same call always returns
## the same samples. Nothing here touches campaign state.
##
## Each caller builds its own streams (no shared cache): a stream is released
## together with the node that plays it, which the hardware audio lifecycle
## gate relies on.

const RATE: int = 22050
## Peak level every cue is normalized to (of full scale).
const PEAK: float = 0.6
## Number of distinct footstep takes.
const FOOTSTEP_VARIANTS: int = 4
const FOOTSTEP_SECONDS: float = 0.24
const DOOR_OPEN_SECONDS: float = 0.55
## The close cue lasts until shortly after the latch.
const DOOR_CLOSE_TAIL: float = 0.25


## One footstep take: a soft heel thud on boards, then a lighter toe contact
## and a short scuff. [param variant] picks one of FOOTSTEP_VARIANTS takes.
static func make_footstep(variant: int) -> AudioStreamWAV:
	variant = posmod(variant, FOOTSTEP_VARIANTS)
	var noise := RandomNumberGenerator.new()
	noise.seed = 52011 + variant * 977
	var thud_hz: float = 74.0 + 9.0 * variant
	var toe_at: float = 0.040 + 0.007 * variant
	var count: int = int(RATE * FOOTSTEP_SECONDS)
	var values := PackedFloat32Array()
	values.resize(count)
	var low: float = 0.0
	var board := _Resonator.new(310.0 + 35.0 * variant, 0.9965)
	for i: int in count:
		var time: float = float(i) / RATE
		low = low * 0.80 + noise.randf_range(-1.0, 1.0) * 0.20
		var value: float = 0.0
		# Heel.
		var heel: float = _attack(time, 0.003)
		value += heel * sin(TAU * thud_hz * time) * exp(-time * 38.0) * 0.9
		value += heel * low * exp(-time * 70.0) * 0.8
		# Toe and scuff.
		var age: float = time - toe_at
		if age >= 0.0:
			value += _attack(age, 0.002) * low * exp(-age * 90.0) * 0.45
			value += low * exp(-age * 28.0) * 0.06
		# A faint board resonance excited by the heel.
		value += board.step(heel * low * exp(-time * 120.0)) * 0.25
		values[i] = value
	return _to_wav(values)


## Door opening: the latch clicks, then the hinge creaks while the leaf swings.
static func make_door_open() -> AudioStreamWAV:
	var noise := RandomNumberGenerator.new()
	noise.seed = 88123
	var count: int = int(RATE * DOOR_OPEN_SECONDS)
	var values := PackedFloat32Array()
	values.resize(count)
	var creak := _Creak.new(noise, 0.05, 0.42, 175.0, 255.0, 0.55)
	var high: float = 0.0
	for i: int in count:
		var time: float = float(i) / RATE
		var hiss: float = noise.randf_range(-1.0, 1.0)
		high = hiss - high * 0.4
		var value: float = _click(time, 0.0, high) + _click(time, 0.018, high) * 0.5
		value += creak.sample(time)
		values[i] = value
	return _to_wav(values)


## Door swinging shut: a shorter, falling creak, then the leaf meets the frame
## at [param shut_at] seconds and the latch clicks just after.
static func make_door_close(shut_at: float) -> AudioStreamWAV:
	var noise := RandomNumberGenerator.new()
	noise.seed = 88457
	var count: int = int(RATE * (shut_at + DOOR_CLOSE_TAIL))
	var values := PackedFloat32Array()
	values.resize(count)
	var creak := _Creak.new(noise, 0.02, shut_at - 0.08, 240.0, 165.0, 0.4)
	var low: float = 0.0
	var high: float = 0.0
	var frame := _Resonator.new(140.0, 0.9975)
	for i: int in count:
		var time: float = float(i) / RATE
		var hiss: float = noise.randf_range(-1.0, 1.0)
		low = low * 0.85 + hiss * 0.15
		high = hiss - high * 0.4
		var value: float = creak.sample(time)
		var age: float = time - shut_at
		if age >= 0.0:
			var hit: float = _attack(age, 0.002)
			value += hit * sin(TAU * 58.0 * age) * exp(-age * 22.0) * 1.0
			value += hit * low * exp(-age * 45.0) * 0.9
			value += frame.step(hit * low * exp(-age * 80.0)) * 0.3
		value += _click(time, shut_at + 0.03, high) * 0.8
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


static func _click(time: float, at: float, high: float) -> float:
	var age: float = time - at
	if age < 0.0 or age > 0.03:
		return 0.0
	return (high * 0.6 + sin(TAU * 2300.0 * age) * 0.5) * exp(-age * 260.0) * 0.7


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
