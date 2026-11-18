"""Reproducible Blender study: real closed meshes, reference-projected front,
painted procedural reverse, armature and 8 pose samples per second.
Run blender --background --python tools/art/build_elena_v7.py
"""
import bpy, math, json, random
from pathlib import Path
from mathutils import Vector, Matrix
ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'assets/models/elena_v7'
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
image = bpy.data.images.load(str(OUT / 'clean-front.png'))
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
# Reuse the printed trouser pigment from the clean reference, not unrelated noise.
swatch=bpy.data.images.new('Printed olive cloth',128,128)
source=list(image.pixels); colors=[]; iw,ih=image.size
for y in range(128):
    for x in range(128):
        sx=int(430+x/127*180); sy=ih-1-int(1370+y/127*145)
        index=(sy*iw+sx)*4
        colors.extend(source[index:index+4])
swatch.pixels.foreach_set(colors); swatch.filepath_raw=str(OUT/'printed-olive.png'); swatch.file_format='PNG'; swatch.save(); swatch.pack()
pn=pants.node_tree.nodes.new('ShaderNodeTexImage'); pn.image=swatch
pants.node_tree.links.new(pn.outputs['Color'],pants.node_tree.nodes.get('Principled BSDF').inputs['Base Color'])
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
            if material==pants and not projected:
                uv.data[li].uv=(v.x*4.5,v.z*4.5)
            else: uv.data[li].uv=projection(v.x,v.z)
    group=ob.vertex_groups.new(name=bone); group.add(list(range(len(verts))),1,'REPLACE')
    pieces.append(ob); return ob
def profile(name,sections,depth,material,bone,projected=True,segments=24,face=False):
    verts=[]; faces=[]
    for section in sections:
        u,v,w=section[:3]
        ring_depth=section[3] if len(section)>3 else depth
        x,_,z=point(u,v)
        for i in range(segments):
            t=2*math.pi*i/segments
            xx=x+w*.0011*math.cos(t); yy=ring_depth*math.sin(t)
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
def chain(name,a,joint,b,widths,depths,material,upper,lower,projected=False):
    """One continuous 25-ring surface with smooth two-bone joint weights."""
    av,jv,bv=Vector(a),Vector(joint),Vector(b)
    verts=[]; faces=[]; influences=[]; sides=24; rings=25
    tangent=(bv-av).normalized().cross(Vector((0,1,0))).normalized()
    other=(bv-av).normalized().cross(tangent).normalized()
    for j in range(rings):
        t=j/(rings-1)
        center=av.lerp(jv,t*2) if t<=.5 else jv.lerp(bv,(t-.5)*2)
        f=t*4; k=min(3,int(f)); alpha=f-k
        w=widths[k]*(1-alpha)+widths[k+1]*alpha
        d=depths[k]*(1-alpha)+depths[k+1]*alpha
        blend=max(0,min(1,(t-.37)/.26)); blend=blend*blend*(3-2*blend)
        for i in range(sides):
            angle=2*math.pi*i/sides
            # Cloth compression near the bend and fuller calf/forearm volume.
            joint_crease=math.exp(-((t-.5)/.13)**2)
            fold=1+(.022+.035*joint_crease)*math.cos(angle*4+j*.8)*math.sin(t*math.pi)
            verts.append(tuple(center+tangent*math.cos(angle)*w*fold+other*math.sin(angle)*d*fold))
            influences.append(blend)
    for j in range(rings-1):
        for i in range(sides):
            a0=j*sides+i; b0=j*sides+(i+1)%sides
            faces.append((a0,b0,b0+sides,a0+sides))
    faces.extend([tuple(reversed(range(sides))),tuple((rings-1)*sides+i for i in range(sides))])
    ob=mesh_obj(name,verts,faces,material,upper,projected)
    ug=ob.vertex_groups[upper]; lg=ob.vertex_groups.new(name=lower)
    for i,w in enumerate(influences):
        ug.add([i],1-w,'REPLACE'); lg.add([i],w,'REPLACE')
    return ob
profile('Head anatomical volume',[(512,60,46),(514,90,82),(516,145,100),(512,200,102),(511,245,97),(509,285,87),(507,325,68),(503,350,43)],.108,skin,'head',True,40,True)
# Neck is continuous with torso so refinement cannot open a collar seam.
torso=profile('Blouse and open cardigan',[(500,325,44,.062),(500,355,46,.065),(500,380,52,.078),(500,410,96,.11),(501,440,145,.12),(503,520,160,.138),(506,690,147,.125),(507,860,139,.108),(509,1050,163,.137),(509,1210,185,.144),(509,1300,188,.14)],.135,cloth,'spine',True,32)
# Lower cardigan follows the pelvis so chest counterrotation cannot open the waist.
torso_root=torso.vertex_groups.new(name='root')
for v in torso.data.vertices:
    w=max(0,min(1,(1.16-v.co.z)/.22))
    torso.vertex_groups['spine'].add([v.index],1-w,'REPLACE')
    torso_root.add([v.index],w,'REPLACE')
# Skull-following rear shell, rather than a second displaced head-sized object.
profile('Hair cap',[(515,30,14,.025),(515,50,47,.05),(515,75,77,.075),(515,100,96,.095),(515,120,103,.105)],.10,hair,'head',True,40)
verts=[]; faces=[]; sides=24
for u,v,w,d in [(515,65,70,.074),(515,100,98,.10),(515,160,109,.113),(512,220,108,.115),(510,280,95,.104),(505,335,66,.075)]:
    x,_,z=point(u,v)
    for i in range(sides+1):
        t=math.pi*i/sides
        verts.append((x+w*.0011*math.cos(t),.006+d*math.sin(t),z))
for row in range(5):
    for i in range(sides):
        a=row*(sides+1)+i; faces.append((a,a+1,a+sides+2,a+sides+1))
mesh_obj('Fitted rear hair',verts,faces,hair,'head',False)
profile('Tied ponytail',[(420,300,22),(409,340,30),(400,390,27),(397,445,20),(405,485,6)],.032,hair,'head',False)
bpy.data.objects['Tied ponytail'].location.y=.075
bones=[('root',(0,0,0),(0,0,.82),None),('spine',(0,0,.82),(0,0,1.46),'root'),('head',(0,0,1.46),(0,0,1.79),'spine')]
for side,sg in [('L',-1),('R',1)]:
    hip=(sg*.105,0,.81); knee=(sg*.105,-.015,.43); ankle=(sg*.105,0,.09)
    shoulder=(sg*.185,0,1.43); elbow=(sg*.250,-.005,1.12); wrist=(sg*.275,-.02,.83)
    bones.extend([(side+'Thigh',hip,knee,'root'),(side+'Shin',knee,ankle,side+'Thigh'),(side+'Foot',ankle,(sg*.105,-.15,.055),side+'Shin'),(side+'Clavicle',(sg*.045,0,1.44),shoulder,'spine'),(side+'Arm',shoulder,elbow,side+'Clavicle'),(side+'Forearm',elbow,wrist,side+'Arm'),(side+'Hand',wrist,(sg*.275,-.02,.742),side+'Forearm')])
    trouser=chain(side+' continuous trousers',hip,knee,ankle,[.076,.109,.082,.086,.062],[.089,.113,.084,.081,.057],pants,side+'Thigh',side+'Shin')
    pg=trouser.vertex_groups.new(name='root')
    for v in trouser.data.vertices:
        t=(v.index//24)/24
        w=max(0,1-t/.15)*.8
        if w>0:
            trouser.vertex_groups[side+'Thigh'].add([v.index],1-w,'REPLACE')
            pg.add([v.index],w,'REPLACE')
    limb(side+' shoe',(sg*.105,.045,.065),(sg*.105,-.15,.06),[.058,.072,.067],[.05,.055,.035],leather,side+'Foot')
    chain(side+' continuous sleeve',shoulder,elbow,wrist,[.045,.093,.077,.077,.050],[.062,.090,.072,.070,.046],cloth,side+'Arm',side+'Forearm',True)
    # Continuous palm + curled fingers, with the palms turned toward the thighs.
    first_hand=len(pieces)
    limb(side+' palm',wrist,(sg*.275,-.020,.758),[.029,.034,.028],[.018,.021,.016],skin,side+'Hand')
    for finger in range(4):
        x=sg*.275+(finger-1.5)*.013
        length=[.044,.056,.051,.039][finger]
        joint=(x,-.026,.770-length*.53)
        limb(side+' finger base '+str(finger),(x,-.018,.770),joint,[.008,.008,.007],[.009,.008,.007],skin,side+'Hand')
        limb(side+' finger tip '+str(finger),joint,(x,-.038,.770-length),[.007,.007,.005],[.007,.007,.005],skin,side+'Hand')
    limb(side+' thumb',(sg*.250,-.020,.804),(sg*.230,-.034,.764),[.011,.010,.007],[.011,.010,.007],skin,side+'Hand')
    hand_parts=pieces[first_hand:]; del pieces[first_hand:]
    bpy.ops.object.select_all(action='DESELECT')
    for ob in hand_parts: ob.select_set(True)
    bpy.context.view_layer.objects.active=hand_parts[0]; bpy.ops.object.join()
    hand=bpy.context.object; hand.name=side+' anatomical hand'
    remesh=hand.modifiers.new('Unified palm and fingers','REMESH'); remesh.mode='VOXEL'; remesh.voxel_size=.0025; remesh.use_smooth_shade=True
    bpy.ops.object.modifier_apply(modifier=remesh.name)
    smooth=hand.modifiers.new('Hand contour','SMOOTH'); smooth.factor=.6; smooth.iterations=2
    bpy.ops.object.modifier_apply(modifier=smooth.name)
    hand.vertex_groups.clear(); hg=hand.vertex_groups.new(name=side+'Hand')
    hg.add(list(range(len(hand.data.vertices))),1,'REPLACE')
    # Restore printed skin after voxel union, which otherwise has no UV layer.
    hand.data.materials.clear(); hand.data.materials.append(front)
    while hand.data.uv_layers:
        hand.data.uv_layers.remove(hand.data.uv_layers[0])
    uv=hand.data.uv_layers.new(name='ReferenceProjection')
    uv.active_render=True
    for poly in hand.data.polygons:
        poly.material_index=0
        for li in poly.loop_indices:
            co=hand.data.vertices[hand.data.loops[li].vertex_index].co
            u=(.168 if side=='L' else .773)+(co.x-wrist[0])/.068*.078
            v=1-(1350+(.83-co.z)/.12*158)/1536
            uv.data[li].uv=(u,v)
    rotation=Matrix.Rotation(-sg*math.radians(68),4,'Z')
    for v in hand.data.vertices: v.co=Vector(wrist)+rotation.to_3x3()@(v.co-Vector(wrist))
    for poly in hand.data.polygons: poly.use_smooth=True
    pieces.append(hand)
profile('Pelvis trouser transition',[(512,1210,145,.12),(512,1260,160,.128),(512,1310,165,.13),(512,1350,154,.115)],.13,pants,'root',False,40)
# Independent canvas geometry; there is no baked hand or strap on the shirt.
profile('Canvas shoulder bag',[(820,810,30),(835,860,66),(835,1050,72),(820,1240,53),(812,1260,34)],.080,bagmat,'spine',False,32)
bpy.data.objects['Canvas shoulder bag'].location=Vector((.045,.15,0))
strap_points=[(.385,.07,1.11),(.32,-.09,1.20),(.255,-.11,1.34),(.205,-.035,1.47),(.205,.035,1.47),(.26,.12,1.34),(.33,.19,1.20),(.385,.23,1.11)]
for i in range(len(strap_points)-1):
    limb('Canvas strap '+str(i),strap_points[i],strap_points[i+1],[.016,.016,.016],[.008,.008,.008],bagmat,'spine')
# Refine only after joint groups have been assigned, preserving blended weights.
for ob in pieces:
    if ob.name.startswith('Canvas strap ') or 'anatomical hand' in ob.name: continue
    # Catmull-Clark changes the actual silhouette, not only triangle density.
    # Applied before rigging so exported GLB contains the refined surface.
    bpy.context.view_layer.objects.active=ob
    sub=ob.modifiers.new('Sculpted surface refinement','SUBSURF')
    sub.subdivision_type='CATMULL_CLARK'
    sub.levels=2 if ob.name=='Head anatomical volume' else 1
    sub.render_levels=sub.levels
    bpy.ops.object.modifier_apply(modifier=sub.name)

# Merge real meshes into a skinned character, keep distinct material slots and UVs.
bpy.ops.object.select_all(action='DESELECT')
for ob in pieces: ob.select_set(True)
bpy.context.view_layer.objects.active=pieces[0]; bpy.ops.object.join()
body=bpy.context.object; body.name='Elena_joint_revision'
arm=bpy.data.armatures.new('ElenaSkeleton'); rig=bpy.data.objects.new('ElenaRig',arm); bpy.context.collection.objects.link(rig)
bpy.context.view_layer.objects.active=rig; bpy.ops.object.mode_set(mode='EDIT')
for name,head,tail,parent in bones:
    b=arm.edit_bones.new(name); b.head=head; b.tail=tail
    if parent: b.parent=arm.edit_bones[parent]
bpy.ops.object.mode_set(mode='OBJECT'); body.parent=rig
mod=body.modifiers.new('Skin','ARMATURE'); mod.object=rig
scene=bpy.context.scene; scene.render.fps=24
contact_samples=[]
def pose_segment(name,head,tail):
    bone=rig.pose.bones[name]
    rest=bone.bone.tail_local-bone.bone.head_local
    align=rest.rotation_difference(Vector(tail)-Vector(head))
    rotation=align.to_matrix().to_4x4() @ bone.bone.matrix_local.to_quaternion().to_matrix().to_4x4()
    bone.matrix=Matrix.Translation(Vector(head)) @ rotation
    bpy.context.view_layer.update()
def leg_pose(side,sg,phase,offset):
    # Two-bone analytic IK with forward knee pole and an authored stance/swing.
    t=(phase+(0 if side=='L' else .5))%1
    if t<.625:
        y=-.14+.28*(t/.625); lift=0; stance=True
    else:
        f=(t-.625)/.375; smooth=f*f*(3-2*f)
        y=.14-.28*smooth; lift=.064*math.sin(math.pi*f); stance=False
    root_transform=rig.pose.bones['root'].matrix @ rig.data.bones['root'].matrix_local.inverted()
    h=root_transform @ Vector((sg*.105,0,.81))
    foot=Vector((sg*.105,y,.077+lift))
    upper=(Vector((0,-.015,.43))-Vector((0,0,.81))).length
    lower=(Vector((0,0,.09))-Vector((0,-.015,.43))).length
    direction=(foot-h).normalized(); distance=min((foot-h).length,upper+lower-.001)
    along=(upper*upper-lower*lower+distance*distance)/(2*distance)
    bend=math.sqrt(max(.00001,upper*upper-along*along))
    pole=Vector((0,-1,0)); pole=(pole-direction*pole.dot(direction)).normalized()
    knee=h+direction*along+pole*bend
    pose_segment(side+'Thigh',h,knee)
    pose_segment(side+'Shin',knee,foot)
    # Keep the support sole level; swing foot gets a small toe clearance angle.
    toe=foot+Vector((0,-.15,-.035 if stance else -.015))
    pose_segment(side+'Foot',foot,toe)
    return {'side':side,'phase':round(t,4),'stance':stance,'ankle':list(foot)}
def action(name,walk=False):
    rig.animation_data_create(); rig.animation_data.action=bpy.data.actions.new(name)
    for frame in range(1,26,3):
        phase=(frame-1)/24*math.tau
        for b in rig.pose.bones:
            b.rotation_mode='XYZ'; b.location=(0,0,0); b.rotation_euler=(0,0,0)
        rig.pose.bones['spine'].rotation_euler.y=.014*math.sin(phase)
        if walk:
            offset=Vector((.008*math.sin(phase),0,-.030+.006*math.cos(phase*2)))
            # Root bone local Y follows world Z in this skeleton.
            rig.pose.bones['root'].location=(offset.x,offset.z,0)
            rig.pose.bones['root'].rotation_euler.y=.028*math.sin(phase)
            rig.pose.bones['spine'].rotation_euler.y=-.070*math.sin(phase)
            rig.pose.bones['spine'].rotation_euler.x=.012+.010*math.cos(phase*2)
            rig.pose.bones['spine'].rotation_euler.z=.016*math.sin(phase)
            rig.pose.bones['head'].rotation_euler.y=.025*math.sin(phase)
            bpy.context.view_layer.update()
            for side,sg in [('L',-1),('R',1)]:
                contact_samples.append(leg_pose(side,sg,(frame-1)/24,offset))
                chest=rig.pose.bones['spine'].matrix @ rig.data.bones['spine'].matrix_local.inverted()
                clav=rig.data.bones[side+'Clavicle']
                sh=chest@clav.tail_local
                sh.z+=sg*.006*math.sin(phase)
                sh.y+=sg*.012*math.sin(phase)
                pose_segment(side+'Clavicle',chest@clav.head_local,sh)
                sh=rig.pose.bones[side+'Clavicle'].tail.copy()
                swing=math.sin(phase)*sg
                ul=(rig.data.bones[side+'Arm'].tail_local-rig.data.bones[side+'Arm'].head_local).length
                fl=(rig.data.bones[side+'Forearm'].tail_local-rig.data.bones[side+'Forearm'].head_local).length
                el=sh+Vector((sg*.055,-.075*swing,-.30)).normalized()*ul
                wr=el+Vector((sg*.022,-.035-.060*swing,-.29)).normalized()*fl
                pose_segment(side+'Arm',sh,el)
                pose_segment(side+'Forearm',el,wr)
                pose_segment(side+'Hand',wr,wr+(wr-el).normalized()*.088)
        for b in rig.pose.bones:
            b.keyframe_insert('rotation_euler',frame=frame,group=b.name)
            b.keyframe_insert('location',frame=frame,group=b.name)
    act=rig.animation_data.action
    for fc in act.fcurves:
        for kp in fc.keyframe_points: kp.interpolation='CONSTANT'
    track=rig.animation_data.nla_tracks.new(); track.name=name; track.strips.new(name,1,act)
    rig.animation_data.action=None
action('Idle_8fps'); action('Walk_8fps',True)
(ROOT/'docs/qa/elena-v7/contact-targets.json').write_text(json.dumps(contact_samples,indent=2))
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
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'source_art/elena_v7/elena_v7.blend'))
bpy.ops.object.select_all(action='DESELECT'); body.select_set(True); rig.select_set(True); bpy.context.view_layer.objects.active=rig
bpy.ops.export_scene.gltf(filepath=str(OUT/'elena_v7.glb'),use_selection=True,export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=False)
scene.render.filepath=str(ROOT/'docs/qa/elena-v7/blender-front.png'); bpy.ops.render.render(write_still=True)
cam.location=(2.7,-2.7,1.1); cam.rotation_euler=(Vector((0,0,1))-cam.location).to_track_quat('-Z','Y').to_euler()
scene.render.filepath=str(ROOT/'docs/qa/elena-v7/blender-angle.png'); bpy.ops.render.render(write_still=True)
triangles=sum(len(p.vertices)-2 for p in body.data.polygons)
(OUT/'manifest.json').write_text(json.dumps({'triangles':triangles,'vertices':len(body.data.vertices),'bones':len(bones),'animations':['Idle_8fps','Walk_8fps'],'animation_samples_per_second':8,'limb_rings':25,'limb_sides':24,'joint_weights':'smooth two-bone blend','separate_bag':True,'limitations':['Front projection texture; reverse uses procedural pigments','Study likeness, not approved production character','Shoulder attachment and side UV require further art refinement']},indent=2))
print('ELENA_BUILD_PASS',triangles,'triangles',len(bones),'bones')
