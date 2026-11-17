# HOUSE-ACCESS-001 — walking access to every door (house v2, 0.1.19)

Branch `claude/house-access`, base 0ba8017. Test: `tests/house_access_test.gd`, registered in Run-Tests after `bodycam_test`. No geometry, material or launcher file was changed.

## Method

- **Grid:** 0.2 m cells over the walkable areas (`HouseLayout.WALKABLE_ROOMS`: vestibule, hall, landing, corridor) on both floors. A cell is free only when:
  - the real player capsule fits there without touching anything (radius and height read from `player.tscn`, 0.38 × 1.75, lifted 6 cm);
  - a ray finds a floor beneath it within 12 cm of the storey height.
- **Control checks:** the grid must reject three spots:
  - the capsule against the hall wall;
  - the space under the stairs;
  - the stairwell void upstairs.
- **Doors:** every RoomDoor with a room or the front door. The count must equal the usable openings in `HouseLayout.WALLS` (16). The sealed rear door is out of scope.
- **Walking:** each route is planned with breadth-first search on the grid and then walked with the real PlayerController. Steering is pure pursuit; the player holds move_forward, and move_and_slide runs at 60 Hz. There is no teleport between doors.
  - The tour starts at the real spawn on the upper gallery.
  - It visits the upper doors nearest first, walks the real stairs down along the centre lane, then visits the ground doors.
  - A route fails if:
    - the body gains less than 5 cm in 45 frames (stuck);
    - it leaves the floor height by more than 30 cm;
    - it runs past 1500 frames;
    - the grid has no route.
- **At each door:** the player stands 0.75 m in front, faces the door at eye level, and the real InteractionRay must target the door and show a prompt.

## Result (2026-11-18, Godot 4.7.2, Run-Tests isolated)

`HOUSE ACCESS TEST: PASS (50 checks)`; full suite with WASAPI: "All 38 test suites passed (including hardware audio lifecycle)". The selected run took about 50 s wall time. Every door was reached and was usable:

| Door | Walked | End position |
|---|---|---|
| daniel_bedroom | 2.8 m | (4.82, 3.30, 10.01) |
| guest_a | 3.9 m | (4.77, 3.30, 6.05) |
| guest_b | 2.9 m | (4.70, 3.30, 3.05) |
| isolation | 2.6 m | (7.37, 3.30, 2.80) |
| multipurpose | 2.7 m | (10.17, 3.30, 2.83) |
| bathroom_upper | 5.2 m | (10.23, 3.30, 8.16) |
| storage | 3.1 m | (10.23, 3.30, 11.36) |
| stairs down | 9.8 m to the top, then the flight | (7.66, 0.00, 9.78) |
| front door | 1.7 m | (7.57, 0.00, 11.54) |
| bathroom_ground | 2.7 m | (10.16, 0.00, 10.82) |
| utility | 4.7 m | (10.23, 0.00, 6.06) |
| pantry | 3.1 m | (10.30, 0.00, 2.82) |
| kitchen | 2.5 m | (7.65, 0.00, 2.77) |
| dining | 2.7 m | (4.85, 0.00, 2.83) |
| living_room | 3.8 m | (4.77, 0.00, 6.75) |

No problem was found in the new plan.

## Not covered

- Walking up the stairs, the side lanes and turns. `stairs_test` covers those.
- Night observation routes and NPC paths.
- Entering the rooms. `door_transition_test` covers that.
- Night and power-outage states. The tour runs on Day 1 at 07:00.
- No video or GPU capture; the test is headless.

## Single-storey adaptation (ROOM-COMPACT-001, 2026-11-18)

The test no longer assumes two floors. It reads the walkable floors from `HouseLayout.ROOMS`, and the stair entry points from `HouseLayout.STAIRS` (only when there is more than one floor and the stairs have an area). The doors come from the scene and from `HouseLayout.WALLS`. The fixed-coordinate control checks were replaced by checks taken from the data:
- at every door, the capsule in the wall plane must be rejected;
- under the stairs and the stairwell void are checked only when there are stairs.

- Two-storey house (0.1.19, this branch): PASS, 78 checks.
- Codex's single-storey work in progress (`workers/codex-single-storey`, uncommitted, copied read-only to a scratch folder, this test added): PASS, 49 checks. All 9 doors were reached, the 8 corridor doors and the front door:
  - front door 0.6 m;
  - daniel_bedroom 1.0 m;
  - living_room 2.5 m;
  - kitchen 3.5 m;
  - isolation 3.1 m;
  - guest_a 3.5 m;
  - multipurpose 0.7 m;
  - bathroom_upper 2.8 m;
  - guest_b 0.7 m.

  Nothing was written to Codex's worktree.
