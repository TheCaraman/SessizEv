"""Reproducible Blender study: real closed meshes, reference-projected front,
painted procedural reverse, armature and 8 pose samples per second.
Run blender --background --python tools/art/build_elena_v3.py
"""
import bpy, math, json, random
from pathlib import Path
from mathutils import Vector
ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'assets/models/elena_v3'
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
image = bpy.data.images.load(str(OUT / 'owner-reference.png'))
image.pack()
def paint(name, color, reference=False):
    m=bpy.data.materials.new(name); m.use_nodes=True
    n=m.node_tree.nodes; l=m.node_tree.links; p=n.get('Principled BSDF')
    p.inputs['Roughness'].default_value=1
    if reference:
        t=n.new('ShaderNodeTexImage'); t.image=image; t.interpolation='Linear'
        l.new(t.outputs['Color'],p.inputs['Base Color'])
    else:
        tex=n.new('ShaderNodeTexNoise'); tex.inputs['Scale'].default_value=160
        tex.inputs['Detail'].default_value=2
        ramp=n.new('ShaderNodeValToRGB')
        ramp.color_ramp.interpolation='CONSTANT'
        ramp.color_ramp.elements[0].position=.35
        ramp.color_ramp.elements[0].color=(*[c*.55 for c in color],1)
        ramp.color_ramp.elements[1].position=.65
        ramp.color_ramp.elements[1].color=(*color,1)
        # glTF cannot export Blender Noise/ColorRamp nodes. Store an actual
        # portable pigment texture rather than silently getting white surfaces.
        rng=random.Random(name)
        bitmap=bpy.data.images.new(name+' pigment',128,128)
        pixels=[]
        for i in range(128*128):
            value=rng.choice([.55,.78,.90,1.0])
            pixels.extend([c*value for c in color]+[1.0])
        bitmap.pixels.foreach_set(pixels)
        bitmap.filepath_raw=str(OUT/(name.replace(' ','_')+'.png'))
        bitmap.file_format='PNG'; bitmap.save(); bitmap.pack()
        portable=n.new('ShaderNodeTexImage'); portable.image=bitmap
        l.new(portable.outputs['Color'],p.inputs['Base Color'])
    return m
front=paint('Owner reference — projected front',(.5,.3,.3),True)
cloth=paint('Charcoal mauve printed wool',(.29,.21,.23))
skin=paint('Muted rose skin',(.58,.36,.32))
hair=paint('Chestnut hair',(.13,.09,.075))
pants=paint('Olive work trousers',(.14,.17,.12))
leather=paint('Worn dark shoes',(.10,.085,.065))
bagmat=paint('Ochre canvas bag',(.43,.31,.19))
pieces=[]
def point(u,v,d=0): return ((u-512)*.0011,d,1.82-v*.00084)
def projection(x,z): return ((x/.0011+512)/1024, 1-(1.82-z)/(.00084*1536))
def mesh_obj(name,verts,faces,material,bone,projected=False):
    mesh=bpy.data.meshes.new(name); mesh.from_pydata(verts,[],faces); mesh.update()
    ob=bpy.data.objects.new(name,mesh); bpy.context.collection.objects.link(ob)
    mesh.materials.append(front if projected else material)
    if projected: mesh.materials.append(material)
    uv=mesh.uv_layers.new(name='ReferenceProjection')
    for poly in mesh.polygons:
        cy=sum(mesh.vertices[i].co.y for i in poly.vertices)/len(poly.vertices)
        poly.material_index=0 if not projected or cy<0 else 1
        poly.use_smooth=True
        for li in poly.loop_indices:
            v=mesh.vertices[mesh.loops[li].vertex_index].co
            uv.data[li].uv=projection(v.x,v.z)
    group=ob.vertex_groups.new(name=bone); group.add(list(range(len(verts))),1,'REPLACE')
    pieces.append(ob); return ob
def profile(name,sections,depth,material,bone,projected=True,segments=24,face=False):
    verts=[]; faces=[]
    for u,v,w in sections:
        x,_,z=point(u,v)
        for i in range(segments):
            t=2*math.pi*i/segments
            xx=x+w*.0011*math.cos(t); yy=depth*math.sin(t)
            if face and yy<0:
                # Explicit brow/cheek/nose volumes instead of a flat portrait.
                def g(uc,vc,su,sv):
                    return math.exp(-((xx-point(uc,vc)[0])/su)**2-((z-point(uc,vc)[2])/sv)**2)
                yy-=.052*g(505,225,.027,.045)+.018*g(455,240,.045,.043)+.018*g(560,240,.045,.043)
                yy+=.013*g(460,190,.028,.016)+.013*g(555,190,.028,.016)
            verts.append((xx,yy,z))
    for j in range(len(sections)-1):
        for i in range(segments):
            a=j*segments+i; b=j*segments+(i+1)%segments
            faces.append((a,b,b+segments,a+segments))
    faces.append(tuple(reversed(range(segments))))
    faces.append(tuple((len(sections)-1)*segments+i for i in range(segments)))
    return mesh_obj(name,verts,faces,material,bone,projected)
def limb(name,a,b,widths,depths,material,bone,projected=False):
    # Rings perpendicular to a limb center line; garment silhouette not capsules.
    axis=(Vector(b)-Vector(a)).normalized()
    tangent=axis.cross(Vector((0,1,0))).normalized(); other=axis.cross(tangent).normalized()
    verts=[]; faces=[]; sides=12
    for j,w in enumerate(widths):
        center=Vector(a).lerp(Vector(b),j/(len(widths)-1))
        for i in range(sides):
            t=2*math.pi*i/sides
            verts.append(tuple(center+tangent*math.cos(t)*w+other*math.sin(t)*depths[j]))
    for j in range(len(widths)-1):
        for i in range(sides):
            a0=j*sides+i; b0=j*sides+(i+1)%sides
            faces.append((a0,b0,b0+sides,a0+sides))
    faces.extend([tuple(reversed(range(sides))),tuple((len(widths)-1)*sides+i for i in range(sides))])
    return mesh_obj(name,verts,faces,material,bone,projected)
profile('Head anatomical volume',[(515,60,48),(515,90,85),(515,145,105),(510,200,111),(510,245,105),(510,285,94),(505,325,76),(500,350,46)],.102,skin,'head',True,32,True)
profile('Neck',[(500,325,44),(500,380,47),(500,425,70)],.062,skin,'spine')
profile('Blouse and open cardigan',[(500,392,78),(501,440,155),(503,520,166),(506,690,155),(507,860,170),(509,1050,178),(509,1240,178)],.135,cloth,'spine',True,32)
# Hair follows the back of the skull, with a tied bunch and asymmetrical strands.
profile('Hair cap',[(515,32,20),(515,52,68),(518,85,105),(525,140,120)],.11,hair,'head',True)
profile('Back hair',[(520,95,96),(520,180,108),(515,275,98),(480,365,70),(450,410,38)],.095,hair,'head',False)
# Move back hair behind the face, leaving front UV face uninterrupted.
bpy.data.objects['Back hair'].location.y=.125
profile('Tied ponytail',[(380,330,28),(365,380,42),(375,440,35),(390,495,8)],.045,hair,'head',True)
bpy.data.objects['Tied ponytail'].location.y=.10
bones=[('root',(0,0,0),(0,0,.82),None),('spine',(0,0,.82),(0,0,1.46),'root'),('head',(0,0,1.46),(0,0,1.79),'spine')]
for side,sg in [('L',-1),('R',1)]:
    hip=(sg*.105,0,.81); knee=(sg*.105,-.015,.43); ankle=(sg*.105,0,.09)
    shoulder=(sg*.215,0,1.43); elbow=(sg*.285,-.005,1.12); wrist=(sg*.31,-.02,.83)
    bones.extend([(side+'Thigh',hip,knee,'root'),(side+'Shin',knee,ankle,side+'Thigh'),(side+'Foot',ankle,(sg*.105,-.15,.055),side+'Shin'),(side+'Arm',shoulder,elbow,'spine'),(side+'Forearm',elbow,wrist,side+'Arm')])
    limb(side+' trouser thigh',hip,knee,[.095,.101,.080],[.103,.099,.077],pants,side+'Thigh')
    limb(side+' trouser shin',knee,ankle,[.082,.072,.061],[.079,.068,.055],pants,side+'Shin')
    limb(side+' shoe',(sg*.105,.045,.065),(sg*.105,-.15,.06),[.058,.072,.067],[.05,.055,.035],leather,side+'Foot')
    limb(side+' sleeve upper',shoulder,elbow,[.094,.103,.083],[.104,.095,.073],cloth,side+'Arm',True)
    limb(side+' sleeve lower',elbow,wrist,[.084,.079,.052],[.075,.077,.049],cloth,side+'Forearm',True)
    limb(side+' hand',wrist,(sg*.31,-.023,.70),[.045,.049,.03],[.027,.027,.017],skin,side+'Forearm',True)
profile('Canvas shoulder bag',[(785,690,20),(820,850,60),(815,1010,69),(790,1140,46)],.065,bagmat,'spine',True)
limb('Canvas strap',point(697,425,-.16),point(800,930,-.17),[.027,.027,.027],[.012,.012,.012],bagmat,'spine',True)
# Merge real meshes into a skinned character, keep distinct material slots and UVs.
bpy.ops.object.select_all(action='DESELECT')
for ob in pieces: ob.select_set(True)
bpy.context.view_layer.objects.active=pieces[0]; bpy.ops.object.join()
body=bpy.context.object; body.name='Elena_reference_study'
arm=bpy.data.armatures.new('ElenaSkeleton'); rig=bpy.data.objects.new('ElenaRig',arm); bpy.context.collection.objects.link(rig)
bpy.context.view_layer.objects.active=rig; bpy.ops.object.mode_set(mode='EDIT')
for name,head,tail,parent in bones:
    b=arm.edit_bones.new(name); b.head=head; b.tail=tail
    if parent: b.parent=arm.edit_bones[parent]
bpy.ops.object.mode_set(mode='OBJECT'); body.parent=rig
mod=body.modifiers.new('Skin','ARMATURE'); mod.object=rig
scene=bpy.context.scene; scene.render.fps=24
def action(name,walk=False):
    rig.animation_data_create(); rig.animation_data.action=bpy.data.actions.new(name)
    for frame in range(1,26,3):
        phase=(frame-1)/24*math.tau
        for b in rig.pose.bones: b.rotation_mode='XYZ'; b.rotation_euler=(0,0,0)
        rig.pose.bones['spine'].rotation_euler.y=.014*math.sin(phase)
        if walk:
            for side,sg in [('L',-1),('R',1)]:
                rig.pose.bones[side+'Thigh'].rotation_euler.x=.30*math.sin(phase)*sg
                rig.pose.bones[side+'Shin'].rotation_euler.x=max(0,-math.sin(phase)*sg)*.46
                rig.pose.bones[side+'Arm'].rotation_euler.x=-.16*math.sin(phase)*sg
        for b in rig.pose.bones: b.keyframe_insert('rotation_euler',frame=frame,group=b.name)
    act=rig.animation_data.action
    for fc in act.fcurves:
        for kp in fc.keyframe_points: kp.interpolation='CONSTANT'
    track=rig.animation_data.nla_tracks.new(); track.name=name; track.strips.new(name,1,act)
    rig.animation_data.action=None
action('Idle_8fps'); action('Walk_8fps',True)
# A neutral inspection scene is kept in .blend, excluded from GLB export.
scene.frame_start=1; scene.frame_end=24
scene.render.engine='CYCLES'; scene.cycles.samples=24
scene.world.color=(.12,.12,.12)
def area(name,at,energy,size):
    d=bpy.data.lights.new(name,'AREA'); d.energy=energy; d.shape='DISK'; d.size=size
    o=bpy.data.objects.new(name,d); bpy.context.collection.objects.link(o); o.location=at
    o.rotation_euler=(Vector((0,0,1))-o.location).to_track_quat('-Z','Y').to_euler()
area('Key',(-2,-3,3),180,3); area('Fill',(2,-2,1.5),80,3)
camd=bpy.data.cameras.new('Review'); cam=bpy.data.objects.new('Review',camd); bpy.context.collection.objects.link(cam)
cam.location=(0,-3.5,1.1); cam.rotation_euler=(Vector((0,0,1))-cam.location).to_track_quat('-Z','Y').to_euler(); camd.type='ORTHO'; camd.ortho_scale=2.1; scene.camera=cam
scene.render.resolution_x=768; scene.render.resolution_y=1024; scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG'
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'source_art/elena_v3/elena_v3.blend'))
bpy.ops.object.select_all(action='DESELECT'); body.select_set(True); rig.select_set(True); bpy.context.view_layer.objects.active=rig
bpy.ops.export_scene.gltf(filepath=str(OUT/'elena_v3.glb'),use_selection=True,export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=False)
scene.render.filepath=str(ROOT/'docs/qa/elena-v3/blender-front.png'); bpy.ops.render.render(write_still=True)
cam.location=(2.7,-2.7,1.1); cam.rotation_euler=(Vector((0,0,1))-cam.location).to_track_quat('-Z','Y').to_euler()
scene.render.filepath=str(ROOT/'docs/qa/elena-v3/blender-angle.png'); bpy.ops.render.render(write_still=True)
triangles=sum(len(p.vertices)-2 for p in body.data.polygons)
(OUT/'manifest.json').write_text(json.dumps({'triangles':triangles,'vertices':len(body.data.vertices),'bones':len(bones),'animations':['Idle_8fps','Walk_8fps'],'animation_samples_per_second':8,'limitations':['Front projection texture; reverse uses procedural pigments','Study likeness, not approved production character','Rigid part weights; joint deformation requires refinement']},indent=2))
print('ELENA_BUILD_PASS',triangles,'triangles',len(bones),'bones')
