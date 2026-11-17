# SINGLE-STOREY-AUDIT-001 — independent consistency review of 0.1.20

Branch `claude/single-storey-audit`, base 7dc0629 (0.1.20). This is a read-first review. Fixes are only in files outside Codex's geometry, art and night_route ownership. Geometry and data findings are reported, not changed.

## Checked and consistent

- **Plan coverage:** the 14 room rects tile the 15 × 12.5 m footprint with no gap or overlap.
  - Every functional room is reachable. Eight rooms have a corridor door opening onto a walkable area: kitchen and living room off the hall/entrance; isolation off the landing; guest_a, guest_b, multipurpose and bathroom off the corridor; Daniel's room off the entrance.
  - The other two are 2D links: utility from the kitchen, storage from the bathroom.
  - `house_access_test` walks all 9 doors.
- **Room ids in data:**
  - `jobs.json` uses kitchen and utility; the night event `source_room` is bathroom_upper.
  - `night_observation` routes use only existing ids.
  - BEDS (guest_a, guest_b, multipurpose) and the accusation room list all exist.
- **Text:** no EN/TR string or dialogue still refers to stairs, an upper or lower floor, or a gallery. "Step" and "basamak" refer to the front doorstep.
- **Positional audio:**
  - `DoorAudio` places the knock at the front door opening from `HouseLayout.WALLS`.
  - `HouseNightEvents` places the pipe noise at the source room centre, at floor × storey height + 1.2 m.
  - Both follow the plan. Porch constants (door x 7.5, front 12.5) match the main door.
- **Saves:** no player position is saved; a load always starts at the scene spawn. Two-storey saves therefore load into the single-storey house without a stranded position. Room aliases are migrated on load (ROOM-COMPACT-001).

## Fixed here (commit 3ac2d8a)

- **Stale developer helpers** now derive their viewpoints from HouseLayout and the front door through the new `scripts/dev/review_spots.gd`:
  - `camera_corner_review`: the default corner is the east end of the bedroom corridor, and a floor that does not exist is refused. A warning fires if the spot lands on furniture. The old entrance default landed on the coat bench, putting the eye at 1.96 m.
  - `corridor_review`: `--upper` is refused with a message.
  - `capture_screenshots`: the stair and upper-corridor shots were retired; the new shots are hall from entrance, entrance window, hall from landing and corridor from landing.
  - `manual_lighting_capture`: the "upper" point was retired.
- **Isolation guard:** `capture_screenshots` (whose header told people to run it on the real project; it starts campaigns and answers the door) and `door_reference_review` (it changes `camera_motion`) now refuse to run outside an isolated copy.
- **New test:** `tests/dev_helpers_test.gd` (36 checks) covers:
  - the isolation check;
  - the floor guard;
  - the front door matching the real RoomDoor;
  - every capture viewpoint lying in a walkable area with room for the player body.
- **Real captures** of all four tools ran in an isolated copy at 1280×720 and were reviewed by eye.

## Reported to Codex (not changed here)

1. **Night routes still describe the old stair landing** (`resources/events/night_observation.json`). guest_b and multipurpose go `room → landing → corridor → bathroom_upper`. In the new plan both doors open straight onto the corridor beside the bathroom, and the landing lies west, off the way.
   - Effect: 2 extra steps (4 minutes) in the off-screen timing. Not visible as text.
   - Changing the routes would make already saved `night_witness_record`s fail `NightObservation.valid()`, because it compares steps to the route one by one. A fix needs a legacy-route allowance or a record migration.
2. **Unused strings:** `ROOM_LANDING` (the landing now uses `ROOM_HALL`), plus `ROOM_DINING`, `ROOM_PANTRY` and `ROOM_BATHROOM_GROUND`, which are only reachable through aliases. They are harmless; delete them or keep them for old reports.
3. **`camera_clearance_test` stair section** silently does nothing when `STAIRS` is empty, because the loop never runs. Correct, but it does not say so.
4. **`room_lighting_test.gd:41`** label still says "ground and upper corridor".
5. **Other dev scenes without the isolation guard:** atmosphere_review, peephole_review, porch_review, room_art_preview, room_style_review, dialogue_art_preview. These were not changed; the guard is offered.

## Tests

- Selected: dev_helpers_test 36 PASS.
- Full suite with WASAPI: "All 41 test suites passed (including hardware audio lifecycle)".
