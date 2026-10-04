extends Node3D

var player: CharacterBody3D
var camera: Camera3D
var yaw := 0.0
var pitch := -4.0
var move_input := Vector2.ZERO
var look_pointer := -1
var move_pointer := -1
var move_origin := Vector2.ZERO
var speed := 5.8
var fixed_y := 1.58
var guest_nodes: Array[Node3D] = []
var task_label: Label

func _ready():
    _build_environment()
    _build_player()
    _build_guests()
    _build_hud()
    _load_detail_assets()

func mat(c: Color, rough:=0.55, metal:=0.0) -> StandardMaterial3D:
    var m:=StandardMaterial3D.new()
    m.albedo_color=c
    m.roughness=rough
    m.metallic=metal
    return m

func box(pos:Vector3, size:Vector3, material:Material):
    var b:=CSGBox3D.new()
    b.position=pos
    b.size=size
    b.material=material
    b.use_collision=true
    add_child(b)
    return b

func cyl(pos:Vector3, radius:float, height:float, material:Material):
    var c:=CSGCylinder3D.new()
    c.position=pos
    c.radius=radius
    c.height=height
    c.sides=32
    c.material=material
    c.use_collision=true
    add_child(c)
    return c

func _build_environment():
    var wall=mat(Color("#d6d0c6"),.72)
    var floor=mat(Color("#3a3531"),.76)
    var wood=mat(Color("#4a3324"),.38)
    var wood2=mat(Color("#73523a"),.44)
    var linen=mat(Color("#eeeae1"),.9)
    var accent=mat(Color("#29454d"),.78)
    var brass=mat(Color("#b18a4a"),.28,.72)
    var marble=mat(Color("#d4cec2"),.34)
    var glass=mat(Color("#6f8e96"),.12,.18)

    # Full hotel footprint: reception, central corridor, six guest rooms, kitchen/housekeeping.
    box(Vector3(0,-.18,0),Vector3(18,.36,20),floor)
    box(Vector3(0,3,-10),Vector3(18,6,.25),wall)
    box(Vector3(-9,3,0),Vector3(.25,6,20),wall)
    box(Vector3(9,3,0),Vector3(.25,6,20),wall)
    for z in [-2.0,2.0,6.0]:
        box(Vector3(-6.8,3,z),Vector3(4.4,6,.22),wall)
        box(Vector3(6.8,3,z),Vector3(4.4,6,.22),wall)
    box(Vector3(-4.6,3,8.2),Vector3(8.8,6,.22),wall)
    box(Vector3(4.6,3,8.2),Vector3(8.8,6,.22),wall)

    # Reception is physically separated from rooms.
    box(Vector3(0,.8,-8.6),Vector3(7.0,1.6,1.1),wood)
    box(Vector3(0,1.65,-8.6),Vector3(7.2,.18,1.16),marble)
    for x in [-2.2,0,2.2]:
        cyl(Vector3(x,.0,-8.6),.08,1.0,brass)
    box(Vector3(0,2.25,-9.2),Vector3(6.2,1.2,.18),wood2)
    for x in [-2.0,0,2.0]:
        box(Vector3(x,2.0,-9.05),Vector3(1.0,.65,.08),glass)

    for i in range(3):
        var z=4.5-i*4.0
        _make_bed(Vector3(-6.0,.0,z+.35),wood,wood2,linen,accent,brass)
        box(Vector3(-8.0,.9,z-1.0),Vector3(1.0,1.8,.75),wood2)
        box(Vector3(-4.0,.55,z-1.0),Vector3(1.3,1.1,.72),wood2)
        box(Vector3(-4.0,1.28,z-1.0),Vector3(1.0,.10,.62),marble)
        box(Vector3(-4.0,2.0,z-1.35),Vector3(1.3,1.4,.06),glass)
        _make_lamp(Vector3(-8.0,2.0,z-1.0),brass,linen)
        box(Vector3(-6.0,.08,z-1.8),Vector3(3.7,.05,1.6),accent)
        box(Vector3(-2.2,1.6,z+1.4),Vector3(.9,2.9,.15),wood2)
        box(Vector3(-2.2,2.7,z+1.31),Vector3(.52,.28,.04),brass)

    for i in range(3):
        var z=4.5-i*4.0
        _make_double_bed(Vector3(5.9,.0,z+.35),wood,wood2,linen,accent)
        box(Vector3(8.0,.8,z-1.0),Vector3(.95,1.6,.72),wood2)
        box(Vector3(3.7,.55,z-1.0),Vector3(1.4,1.1,.72),wood2)
        box(Vector3(3.7,1.28,z-1.0),Vector3(1.1,.10,.62),marble)
        _make_lamp(Vector3(8.0,1.9,z-1.0),brass,linen)

    for i in range(3):
        var z=4.5-i*4.0
        _make_door(Vector3(-2.05,1.35,z),wood2,brass,str(101+i))
        _make_door(Vector3(2.05,1.35,z),wood2,brass,str(104+i))

    # Separate kitchen and housekeeping work areas.
    box(Vector3(5.8,.65,-7.2),Vector3(5.0,1.3,1.2),marble)
    for x in [4.2,5.8,7.4]:
        box(Vector3(x,1.1,-8.5),Vector3(1.2,2.0,.75),wood2)
    box(Vector3(7.2,.65,-5.0),Vector3(1.6,1.2,1.0),wood2)
    box(Vector3(-7.1,.65,-7.0),Vector3(1.6,1.2,1.0),accent)
    box(Vector3(-7.1,1.45,-7.0),Vector3(1.4,.15,.9),marble)

    for x in [-6,-3,0,3,6]:
        box(Vector3(x,5.7,0),Vector3(.12,.12,19),wood2)
    for p in [Vector3(0,4.5,-7),Vector3(0,4.5,0),Vector3(0,4.5,7)]:
        var l:=OmniLight3D.new()
        l.position=p
        l.light_energy=2.2
        l.omni_range=8.0
        l.light_color=Color("#ffe4b8")
        add_child(l)
    var env:=WorldEnvironment.new()
    var e:=Environment.new()
    e.background_mode=Environment.BG_COLOR
    e.background_color=Color("#0e1114")
    e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color=Color("#d6d1c8")
    e.ambient_light_energy=.75
    e.tonemap_mode=Environment.TONE_MAPPER_FILMIC
    env.environment=e
    add_child(env)

func _make_bed(p,wood,wood2,linen,accent,brass):
    box(p+Vector3(0,.30,0),Vector3(4.4,.55,2.8),wood)
    box(p+Vector3(0,.72,0),Vector3(4.15,.62,2.55),linen)
    box(p+Vector3(0,1.05,.15),Vector3(3.9,.18,2.25),mat(Color("#f7f5ef"),.92))
    box(p+Vector3(0,1.18,.85),Vector3(3.8,.10,.65),accent)
    box(p+Vector3(0,1.65,1.38),Vector3(4.5,2.6,.28),wood2)
    for x in [-1.6,1.6]:
        box(p+Vector3(x,.58,1.7),Vector3(.75,1.0,.75),wood2)
        _make_lamp(p+Vector3(x,1.9,1.7),brass,linen)

func _make_double_bed(p,wood,wood2,linen,accent):
    box(p+Vector3(0,.3,0),Vector3(4.2,.55,2.75),wood)
    box(p+Vector3(0,.75,0),Vector3(4.0,.62,2.5),linen)
    box(p+Vector3(0,1.05,.15),Vector3(3.7,.18,2.2),mat(Color("#f6f4ed"),.92))
    box(p+Vector3(0,1.17,.85),Vector3(3.6,.10,.62),accent)
    box(p+Vector3(0,1.55,1.35),Vector3(4.3,2.4,.28),wood2)

func _make_lamp(p,metal,shade):
    cyl(p,.13,.08,metal)
    cyl(p+Vector3(0,.45,0),.045,.75,metal)
    var s:=CSGSphere3D.new()
    s.position=p+Vector3(0,.88,0)
    s.radius=.28
    s.height=.42
    s.material=shade
    add_child(s)

func _make_door(p,wood2,brass,num):
    box(p,Vector3(1.05,2.8,.16),wood2)
    cyl(p+Vector3(.43,0,.13),.055,.05,brass)
    var l:=Label3D.new()
    l.text=num
    l.position=p+Vector3(0,.95,.12)
    l.font_size=32
    l.modulate=Color("#f1e8cf")
    add_child(l)

func _build_player():
    player=CharacterBody3D.new()
    player.position=Vector3(0,fixed_y,-6.2)
    add_child(player)
    var cs:=CollisionShape3D.new()
    var cap:=CapsuleShape3D.new()
    cap.radius=.35
    cap.height=1.7
    cs.shape=cap
    cs.position.y=.85
    player.add_child(cs)
    camera=Camera3D.new()
    camera.position=Vector3(0,0,0)
    camera.current=true
    camera.fov=74.0
    camera.near=0.05
    camera.far=180.0
    camera.keep_aspect=Camera3D.KEEP_HEIGHT
    player.add_child(camera)

func _build_guests():
    for i in range(3):
        guest_nodes.append(_make_guest(Vector3(-1.0,.0,5.0-i*4.0)))

func _make_guest(pos):
    var root:=Node3D.new()
    root.position=pos
    add_child(root)
    var skin=mat(Color("#b97858"),.72)
    var suit=mat(Color("#1c2730"),.65)
    var shirt=mat(Color("#ece8dc"),.9)
    var head:=CSGSphere3D.new()
    head.radius=.23
    head.height=.48
    head.position=Vector3(0,1.75,0)
    head.material=skin
    root.add_child(head)
    box_at(root,Vector3(0,1.05,0),Vector3(.62,.95,.36),suit)
    cyl_at(root,Vector3(-.16,.45,0),.10,.82,suit)
    cyl_at(root,Vector3(.16,.45,0),.10,.82,suit)
    cyl_at(root,Vector3(-.40,1.05,0),.065,.72,shirt)
    cyl_at(root,Vector3(.40,1.05,0),.065,.72,shirt)
    var name:=Label3D.new()
    name.text="GUEST"
    name.position=Vector3(0,2.15,0)
    name.font_size=18
    name.modulate=Color("#f4eee2")
    root.add_child(name)
    return root

func box_at(parent,pos,size,material):
    var b:=CSGBox3D.new()
    b.position=pos
    b.size=size
    b.material=material
    parent.add_child(b)
    return b

func cyl_at(parent,pos,r,h,material):
    var c:=CSGCylinder3D.new()
    c.position=pos
    c.radius=r
    c.height=h
    c.sides=24
    c.material=material
    parent.add_child(c)
    return c

func _load_detail_assets():
    _instance_glb("res://assets/luggage.glb",Vector3(-1.75,.42,-7.0),Vector3(.7,.7,.7))
    _instance_glb("res://assets/cleaning_cart.glb",Vector3(-7.1,.0,-5.8),Vector3(.9,.9,.9))
    _instance_glb("res://assets/cleaning_cart.glb",Vector3(7.1,.0,-5.8),Vector3(.9,.9,.9))

func _instance_glb(path:String,pos:Vector3,scale:Vector3):
    if not ResourceLoader.exists(path):
        return
    var packed=load(path)
    if packed is PackedScene:
        var n=packed.instantiate()
        n.position=pos
        n.scale=scale
        add_child(n)

func _build_hud():
    var layer:=CanvasLayer.new()
    add_child(layer)
    var title:=Label.new()
    title.text="LAST CALL  •  NIGHT SHIFT"
    title.position=Vector2(24,18)
    title.add_theme_font_size_override("font_size",24)
    layer.add_child(title)
    var status:=Label.new()
    status.text="NIGHT 1   •   RECEPTION   •   6 ROOMS ACTIVE"
    status.position=Vector2(24,52)
    status.add_theme_font_size_override("font_size",15)
    layer.add_child(status)
    task_label=Label.new()
    task_label.text="TASK: CHECK IN ARRIVING GUESTS  •  Tap a guest when nearby"
    task_label.position=Vector2(24,78)
    task_label.add_theme_font_size_override("font_size",15)
    layer.add_child(task_label)
    var move:=Label.new()
    move.text="◉ MOVE\nDrag on LEFT"
    move.position=Vector2(40,610)
    move.add_theme_font_size_override("font_size",18)
    layer.add_child(move)
    var look:=Label.new()
    look.text="LOOK ↗\nDrag on RIGHT"
    look.position=Vector2(1030,610)
    look.add_theme_font_size_override("font_size",16)
    layer.add_child(look)

func _input(e):
    if e is InputEventScreenTouch:
        if e.pressed:
            if e.position.x < get_viewport().size.x*.48:
                move_pointer=e.index
                move_origin=e.position
                move_input=Vector2.ZERO
            else:
                look_pointer=e.index
        else:
            if e.index==move_pointer:
                move_pointer=-1
                move_input=Vector2.ZERO
            if e.index==look_pointer:
                look_pointer=-1
    elif e is InputEventScreenDrag:
        if e.index==move_pointer:
            move_input=((e.position-move_origin)/90.0).limit_length(1.0)
        elif e.index==look_pointer:
            yaw-=e.relative.x*.12
            pitch=clamp(pitch-e.relative.y*.09,-65,65)

func _physics_process(delta):
    if not player:
        return
    var keyboard:=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
    var input:=keyboard if keyboard.length()>.05 else move_input
    var basis:=Basis(Vector3.UP,deg_to_rad(yaw))
    var dir=basis*Vector3(input.x,0,-input.y)
    player.velocity.x=dir.x*speed
    player.velocity.z=dir.z*speed
    player.velocity.y=0.0
    player.move_and_slide()
    # Keep the first-person camera at eye height even if a mobile/Web collision edge case occurs.
    player.global_position.y=fixed_y
    player.global_position.x=clamp(player.global_position.x,-8.0,8.0)
    player.global_position.z=clamp(player.global_position.z,-9.0,9.0)
    player.rotation.y=deg_to_rad(yaw)
    camera.rotation.x=deg_to_rad(pitch)
    camera.position=Vector3(0,0,0)
