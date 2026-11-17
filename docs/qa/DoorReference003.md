# DOOR-REFERENCE-003 — short threshold into the room

Branch `claude/door-reference`, base 0ba8017 + the owner-approved light bodycam (538e705, cherry-picked).

Reference: the owner's video (D:/KLIPLER/2026-11-18 01-23-39.mkv). Codex's analysis frames are in `runtime/reference-20261118/`. No scene or asset was copied from it.

## Change

- `scripts/house/room_door.gd`:
  - The leaf swings over `OPEN_SECONDS` 0.4 with ease-out, so it moves at once instead of winding up slowly.
  - The camera's step into the doorway now runs **in parallel**: it starts after `APPROACH_DELAY` 0.08 and lasts `APPROACH_SECONDS` 0.32. Before, it started only after the leaf had finished (0.55 + 0.30 = 0.85 s).
  - The room view shows after `TRANSITION_SECONDS` 0.4.
  - The aperture still shows the screen-matched room image, so nothing grows and nothing changes at the handoff.
- **Camera motion off** (`camera_motion` < 0.5, the existing reduced-motion preference): the camera does not move. The leaf swings in `REDUCED_OPEN_SECONDS` 0.25 s, then `RoomView` dissolves in over `DISSOLVE_SECONDS` 0.18 s, about 0.43 s in total. No new setting was added.
- The bodycam motion is separate. It rests at once when `door_transition_changed(true)` fires and never writes the camera during the tween.
- `tests/camera_clearance_test.gd`: one line; the probe window during a door now uses `TRANSITION_SECONDS`.

## Tests

`door_transition_test` grew from 49 to 57 checks. The new checks are:
- the transition length matches the leaf and approach times;
- the transition is 0.35–0.45 s long;
- at 0.22 s the leaf has already swung more than 0.6 rad while the camera is already stepping in at eye height;
- the room shows within `TRANSITION_SECONDS` + 0.12 s of the key press;
- reduced motion: the camera stays still on every frame, the room starts within 0.37 s, the dissolve starts below alpha 0.5 and finishes, and the total stays at 0.45 s or less.

Selected run passed: door_transition 57, camera_clearance 7, bodycam 53, peephole 31, interaction 14. That partial run printed an "Object lifetime warning" for peephole_test; it is a warning only, not a failure.

## Review capture

`scripts/dev/door_reference_review.gd` renders real frames about every 70 ms, at 1280×720 in an isolated copy, into `docs/qa/door-reference/door-transition.png`:
- Rows 1–2, motion on: the leaf is open by the second frame, the camera steps in, and the room fills the screen at about 0.35 s with the same image.
- Rows 3–4, motion off: the camera stays still and the room dissolves in.

## Not done

- No hand play and no video recording.
- Not checked on the single-storey branch. The fixtures use the door nodes, so they should carry over.
