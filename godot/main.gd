extends Node3D

var player: CharacterBody3D
var cam: Camera3D
var yaw := 0.0
var pitch := -7.0
var touch_active := false
var touch_start := Vector2.ZERO
var joy := Vector2.ZERO
var speed := 4.8
var gravity := 14.0

func _ready():
    _build_room()
    _build_player()
    _build_ui()

func material(c: Color, metallic := 0.0, rough := 0.55):
    var m := StandardMaterial3D.new()
    m.albedo_color = c
    m.metallic = metallic
    m.roughness = rough
    return m

func box(pos: Vector3, size: Vector3, m: Material):
    var b := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    b.mesh = mesh
    b.position = pos
    b.material_override = m
    add_child(b)
    var col := StaticBody3D.new()
    col.position = pos
    var cs := CollisionShape3D.new()
    var sh := BoxShape3D.new()
    sh.size = size
    cs.shape = sh
    col.add_child(cs)
    add_child(col)
    return b

func _build_room():
    var floor_m = material(Color("#3b3530"), 0.0, 0.34)
    var wall_m = material(Color("#d8d0c5"), 0.0, 0.68)
    var wood_m = material(Color("#5a4638"), 0.0, 0.38)
    var fabric_m = material(Color("#d9d4ca"), 0.0, 0.82)
    var accent_m = material(Color("#88715d"), 0.0, 0.55)
    box(Vector3(0,-0.15,0), Vector3(16,0.3,12), floor_m)
    box(Vector3(0,3,-6), Vector3(16,6,0.25), wall_m)
    box(Vector3(-8,3,0), Vector3(0.25,6,12), wall_m)
    box(Vector3(8,3,0), Vector3(0.25,6,12), wall_m)
    box(Vector3(0,3,6), Vector3(16,6,0.25), wall_m)

    # reception/workstation
    box(Vector3(-2.5,1.0,-3.9), Vector3(5.8,1.8,1.0), wood_m)
    box(Vector3(-2.5,1.98,-3.9), Vector3(6.0,0.18,1.12), accent_m)

    # detailed room composition
    box(Vector3(3.1,0.48,1.7), Vector3(4.6,0.46,5.1), fabric_m)
    box(Vector3(3.1,0.78,2.0), Vector3(4.15,0.16,4.55), material(Color("#eeeae2"),0,0.86))
    box(Vector3(3.1,1.7,4.05), Vector3(4.7,2.15,0.25), wood_m)
    box(Vector3(1.75,1.02,3.7), Vector3(1.55,0.30,0.85), material(Color("#f7f4ed"),0,0.88))
    box(Vector3(4.45,1.02,3.7), Vector3(1.55,0.30,0.85), material(Color("#f7f4ed"),0,0.88))

    for x in [0.15, 6.05]:
        box(Vector3(x,0.58,3.75), Vector3(0.95,1.1,0.95), wood_m)
        box(Vector3(x,1.28,3.75), Vector3(0.48,0.75,0.48), accent_m)

    # lounge chair + side table
    box(Vector3(-4.9,0.62,0.8), Vector3(2.0,1.2,1.9), material(Color("#735b4b"),0,0.72))
    box(Vector3(-4.9,1.35,1.0), Vector3(2.0,0.25,1.7), material(Color("#806552"),0,0.78))
    box(Vector3(-3.45,0.45,0.8), Vector3(0.65,0.9,0.65), wood_m)

    # wardrobe + luggage bench
    box(Vector3(-6.35,1.95,-1.55), Vector3(2.2,3.9,1.05), wood_m)
    box(Vector3(-4.55,0.55,-1.75), Vector3(2.3,0.85,0.72), accent_m)

    # wall art and architectural trim
    box(Vector3(-5.7,2.5,-5.82), Vector3(1.9,1.3,0.06), accent_m)
    box(Vector3(4.8,2.5,-5.82), Vector3(1.9,1.3,0.06), material(Color("#6f817c"),0,0.62))
    box(Vector3(0,0.12,-5.82), Vector3(15.4,0.24,0.12), accent_m)

    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#11151a")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#d8d3ca")
    env.ambient_light_energy = 0.72
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world.environment = env
    add_child(world)

    for p in [Vector3(-1,4.5,-2), Vector3(3,3.1,2.2), Vector3(-4,3,1.5)]:
        var l := OmniLight3D.new()
        l.position = p
        l.light_energy = 2.1
        l.omni_range = 7.0
        l.light_color = Color("#ffe5bd")
        add_child(l)

func _build_player():
    player = CharacterBody3D.new()
    player.position = Vector3(-0.5,0.9,4.8)
    add_child(player)
    var shape := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.35
    capsule.height = 1.7
    shape.shape = capsule
    shape.position.y = 0.85
    player.add_child(shape)
    cam = Camera3D.new()
    cam.position = Vector3(0,1.62,0)
    cam.current = true
    player.add_child(cam)

func _build_ui():
    var layer := CanvasLayer.new()
    add_child(layer)
    var title := Label.new()
    title.text = "LAST CALL  •  NIGHT SHIFT"
    title.position = Vector2(28,22)
    title.add_theme_font_size_override("font_size",26)
    layer.add_child(title)
    var hint := Label.new()
    hint.text = "FIRST-PERSON TEST   •   LEFT TOUCH = MOVE   •   RIGHT TOUCH = LOOK"
    hint.position = Vector2(28,60)
    hint.add_theme_font_size_override("font_size",15)
    layer.add_child(hint)
    var status := Label.new()
    status.text = "ROOM 101  •  RECEPTION SHIFT"
    status.position = Vector2(28,94)
    status.add_theme_font_size_override("font_size",15)
    layer.add_child(status)

func _unhandled_input(e):
    if e is InputEventScreenTouch:
        if e.pressed:
            touch_active = true
            touch_start = e.position
            joy = Vector2.ZERO
        else:
            touch_active = false
            joy = Vector2.ZERO
    elif e is InputEventScreenDrag and touch_active:
        if e.position.x > get_viewport().get_visible_rect().size.x * 0.5:
            yaw -= e.relative.x * 0.22
            pitch = clamp(pitch - e.relative.y * 0.18, -70.0, 65.0)
        else:
            joy = (e.position - touch_start).limit_length(110.0) / 110.0

func _physics_process(delta):
    if not player:
        return
    var keys := Input.get_vector("move_left","move_right","move_forward","move_back")
    var input := keys if keys.length() > 0.05 else joy
    var basis := Basis(Vector3.UP, deg_to_rad(yaw))
    var dir := basis * Vector3(input.x,0,-input.y)
    if dir.length() > 1.0:
        dir = dir.normalized()
    player.velocity.x = dir.x * speed
    player.velocity.z = dir.z * speed
    if not player.is_on_floor():
        player.velocity.y -= gravity * delta
    else:
        player.velocity.y = 0.0
    player.move_and_slide()
    player.rotation.y = deg_to_rad(yaw)
    cam.rotation.x = deg_to_rad(pitch)
