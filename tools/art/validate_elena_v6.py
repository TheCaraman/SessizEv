"""Validate skin weights and surface stretch across every exported walk pose."""
import bpy, math, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'source_art/elena_v6/elena_v6.blend'))
body=bpy.data.objects['Elena_joint_revision']; rig=bpy.data.objects['ElenaRig']
assert all(abs(sum(g.weight for g in v.groups)-1)<1e-5 for v in body.data.vertices), 'Unnormalised skin'
blended=sum(1 for v in body.data.vertices if sum(g.weight>1e-5 for g in v.groups)>1)
assert blended>=400, 'Missing elbow/knee blend region'
for track in rig.animation_data.nla_tracks: track.mute=True
rig.animation_data.action=bpy.data.actions['Walk_8fps']
edges=[(e.vertices[0],e.vertices[1]) for e in body.data.edges]
base=[(body.data.vertices[a].co-body.data.vertices[b].co).length for a,b in edges]
minimum=1.; maximum=1.
targets=json.loads((ROOT/'docs/qa/elena-v6/contact-targets.json').read_text())
maximum_target_error=0.
maximum_support_height_error=0.
for frame in range(1,25,3):
    bpy.context.scene.frame_set(frame)
    bpy.context.view_layer.update()
    for target in targets[((frame-1)//3)*2:((frame-1)//3)*2+2]:
        from mathutils import Vector
        actual=rig.pose.bones[target['side']+'Foot'].head
        maximum_target_error=max(maximum_target_error,(actual-Vector(target['ankle'])).length)
    evaluated=body.evaluated_get(bpy.context.evaluated_depsgraph_get())
    mesh=evaluated.to_mesh()
    for target in targets[((frame-1)//3)*2:((frame-1)//3)*2+2]:
        if not target['stance']: continue
        group=body.vertex_groups[target['side']+'Foot'].index
        ids=[v.index for v in body.data.vertices if any(g.group==group and g.weight>.5 for g in v.groups)]
        height=min(mesh.vertices[i].co.z for i in ids)
        maximum_support_height_error=max(maximum_support_height_error,abs(height))
    for v in mesh.vertices: assert all(math.isfinite(c) for c in v.co), 'Non-finite skinned vertex'
    for (a,b),length in zip(edges,base):
        if length<1e-6: continue
        ratio=(mesh.vertices[a].co-mesh.vertices[b].co).length/length
        minimum=min(minimum,ratio);maximum=max(maximum,ratio)
    evaluated.to_mesh_clear()
assert maximum<2.5 and minimum>.15, f'Extreme joint deformation {minimum}..{maximum}'
assert maximum_target_error<.005, f'Foot IK target mismatch: {maximum_target_error}'
assert maximum_support_height_error<.025, f'Support sole not near floor: {maximum_support_height_error}'
result={'blended_vertices':blended,'walk_samples_checked':8,'minimum_edge_ratio':minimum,'maximum_edge_ratio':maximum,'weights_normalized':True,'maximum_ankle_target_error_m':maximum_target_error,'maximum_support_sole_height_m':maximum_support_height_error}
(ROOT/'docs/qa/elena-v6/skin-validation.json').write_text(json.dumps(result,indent=2))
print('ELENA_SKIN_PASS',result)
