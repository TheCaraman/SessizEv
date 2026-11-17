# BODYCAM-002 — body-worn camera motion

Branch `claude/bodycam-002`, base 30fdc19 (0.1.18) + the owner-approved 0.38 m body (b03b0d1, cherry-picked).

## What it does

`scripts/player/body_cam_motion.gd` (node `Player/BodyCam`) moves `Head/Camera3D` in its **local** transform:

- **Walking:** with each step the view dips (0.6 cm at walking speed), shifts side to side (0.35 cm over a two-step cycle), rolls 0.2° and nods 0.08° (lightened three times at the owner's request, 2026-11-18: 3.8 cm/1.5°, 2.2 cm/0.75°, 1.2 cm/0.4°). The amplitude follows the real horizontal speed, so walking fast sways about 1.6× more. The offset is capped at 6 cm, which keeps the view clear of walls (body radius 0.38 m, near-plane corners reach 0.122 m at FOV 95).
- **Turning:** the view leans into the turn (up to 0.45°) and trails the body slightly (up to 0.3°). A spring drives both, slightly under-damped, so the end of a turn settles softly.
- **Stopping:** the gait strength eases out (about 0.5 s), so the view settles back to the head with no snap.
- Mouse look (Player yaw, Head pitch) is unchanged. `InteractionRay` is a child of the camera, so it always points where the view points. `PlayerController.get_look_direction()` now returns the camera direction for the same reason.
- No blur, pixelation or colour effect.

## When it stops

- **camera_motion below 0.5:** off; the camera never moves.
- **Control lost** (dialogue, room view, shelter, journal): the camera rests on the head immediately. The new `PlayerController.control_changed` signal triggers it, so it happens before the UI draws. After that the node does not touch the camera.
- **Pause:** the camera rests within a frame. The node runs with PROCESS_MODE_ALWAYS.
- **Door transition:** `EventBus.door_transition_changed(true)` makes the camera rest synchronously. This happens before RoomDoor records `_camera_start`. During the tween the node never writes the camera, and RoomDoor hands the camera back to the plain head pose. `room_door.gd` is unchanged.
- **Standing still with nothing to do:** the node does not write the camera at all. Other code, such as peephole aiming and dev captures, can still set the camera there.
- **Large yaw jump in one frame** (more than 0.6 rad, e.g. spawn or load): treated as a teleport, not as a turn.

## Tests

`tests/bodycam_test.gd`, registered in Run-Tests after `player_movement_test`. The checks run as real physics walks in test_room plus a real RoomDoor in house_blockout:

- at rest the camera is identity;
- walk dip, side shift and roll stay inside their bounds; the camera never moves forward; the 6 cm cap holds;
- the ray and the look direction follow the camera;
- multiple steps happen;
- smooth settle with no per-frame snap;
- fast walking sways more than normal walking;
- turn lean direction and limit, turn lag limit, and settle after the turn;
- losing control rests the camera immediately and the node then leaves it alone;
- pause rests it;
- a door transition rests it synchronously and the node never fights the tween;
- camera_motion 0 means zero motion, including on turns;
- real door: the transition starts from the head pose, the room opens, the camera returns to the head, and the motion resumes after the room.

### Results (2026-11-18, Godot 4.7.2, Run-Tests isolated)

- Full suite with `-AudioDriver WASAPI`: "All 36 test suites passed (including hardware audio lifecycle)". This run used the first amplitudes: dip 3.2 cm, side shift 2.0 cm, roll 1.1°, nod 0.45°.
- After raising the amplitudes to their final values, a selected re-run passed: bodycam_test 53, door_transition_test 49, peephole_test 31, player_movement_test 6 checks.
  - That partial run printed an "Object lifetime warning" for peephole_test (no audio driver). It is a warning only, not a failure. I did not compare it against the base.

## Review capture

`scripts/dev/bodycam_review.gd` renders a contact sheet at 1280×720 in an isolated project copy: standing, three walking frames, mid-turn and settled. Output: `docs/qa/bodycam/bodycam-review.png`. Walking frames 2 and 3 show opposite roll; the mid-turn frame shows the lean.

## Not done

- No video or GIF recording; only the contact sheet.
- The camera has not been tried by hand with a mouse; turns in the test are driven by `rotate_y`.
- The new house geometry (codex/house-rebuild-v2) is not covered yet. This branch runs on the b66b4d1 geometry.
