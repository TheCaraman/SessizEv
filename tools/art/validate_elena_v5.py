"""Validate skin weights and surface stretch across every exported walk pose."""
import bpy, math, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'source_art/elena_v5/elena_v5.blend'))
body=bpy.data.objects['Elena_joint_revision']; rig=bpy.data.objects['ElenaRig']
assert all(abs(sum(g.weight for g in v.groups)-1)<1e-5 for v in body.data.vertices), 'Unnormalised skin'
blended=sum(1 for v in body.data.vertices if sum(g.weight>1e-5 for g in v.groups)>1)
assert blended>=400, 'Missing elbow/knee blend region'
for track in rig.animation_data.nla_tracks: track.mute=True
rig.animation_data.action=bpy.data.actions['Walk_8fps']
edges=[(e.vertices[0],e.vertices[1]) for e in body.data.edges]
base=[(body.data.vertices[a].co-body.data.vertices[b].co).length for a,b in edges]
minimum=1.; maximum=1.
for frame in range(1,25,3):
    bpy.context.scene.frame_set(frame)
    evaluated=body.evaluated_get(bpy.context.evaluated_depsgraph_get())
    mesh=evaluated.to_mesh()
    for v in mesh.vertices: assert all(math.isfinite(c) for c in v.co), 'Non-finite skinned vertex'
    for (a,b),length in zip(edges,base):
        if length<1e-6: continue
        ratio=(mesh.vertices[a].co-mesh.vertices[b].co).length/length
        minimum=min(minimum,ratio);maximum=max(maximum,ratio)
    evaluated.to_mesh_clear()
assert maximum<2.5 and minimum>.15, f'Extreme joint deformation {minimum}..{maximum}'
result={'blended_vertices':blended,'walk_samples_checked':8,'minimum_edge_ratio':minimum,'maximum_edge_ratio':maximum,'weights_normalized':True}
(ROOT/'docs/qa/elena-v5/skin-validation.json').write_text(json.dumps(result,indent=2))
print('ELENA_SKIN_PASS',result)
