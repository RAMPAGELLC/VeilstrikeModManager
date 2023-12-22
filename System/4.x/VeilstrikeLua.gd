# Copyright 2023 RAMPAGE Interactive
class_name VeilstrikeLuaSDK

var lua: LuaAPI
var coroutine: LuaCoroutine

@export var yieldTime = 0
@export var timeSince = 0
@export var Ready = false
@export var ScriptName = "Mod.lua"
@export var LuaSource = ""

func LuaFixArg(arg):
	if arg is Dictionary or arg is Array:
		arg = JSON.stringify(arg)
	if arg == null || typeof(arg) == TYPE_CALLABLE:
		print("Could not format arg with Veilstrike.lua, Defaulted to GoDot: ", arg)
		arg = "No message defined."
	if typeof(arg) == 21 || typeof(arg) == TYPE_FLOAT:
		arg = str(arg)
	if typeof(arg) == TYPE_BOOL and arg == true:
		arg = "TRUE"
	if typeof(arg) == TYPE_BOOL and arg == false:
		arg = "FALSE"
	if typeof(arg) == TYPE_VECTOR3:
		arg = arg.X+", "+arg.Y+", "+arg.Z
	if typeof(arg) == TYPE_VECTOR2:
		arg = str(arg.x) + ", " + str(arg.y)
	if typeof(arg) == TYPE_TRANSFORM2D:
		arg = "Matrix: " + str(arg.elements)
	if typeof(arg) == TYPE_BASIS:
		arg = "Basis: " + str(arg.elements)
	if typeof(arg) == TYPE_QUATERNION:
		arg = "Quat: " + str(arg.x) + ", " + str(arg.y) + ", " + str(arg.z) + ", " + str(arg.w)
	if typeof(arg) == TYPE_RECT2:
		arg = "Rect2: " + str(arg.position) + ", " + str(arg.size)
	if typeof(arg) == TYPE_AABB:
		arg = "AABB: " + str(arg.position) + ", " + str(arg.size)
	if typeof(arg) == TYPE_PLANE:
		arg = "Plane: " + str(arg.normal) + ", " + str(arg.d)
	if typeof(arg) == TYPE_RID:
		arg = "RID: " + str(arg)
	if typeof(arg) == TYPE_NODE_PATH:
		arg = "NodePath: " + str(arg)
	if typeof(arg) == TYPE_TRANSFORM3D:
		arg = "Transform: " + str(arg.basis) + ", " + str(arg.origin)
	return arg

func LuaPrint(varargs)-> void:
	if varargs is Dictionary or varargs is Array:
		for arg in varargs:
			arg = LuaFixArg(arg)
			print_rich("[color=pink]" + "[b][DEBUG] [" + ScriptName + "]: [/b]" + arg + "[/color]")
	else:
		var arg = LuaFixArg(varargs)
		print_rich("[color=pink]" + "[b][DEBUG] [" + ScriptName + "]: [/b]" + arg + "[/color]")

func LuaWarn(varargs)-> void:
	for arg in varargs:
		arg = LuaFixArg(arg)
		push_warning("[WARNING] [" + ScriptName + "]: " + arg)
		print_rich("[color=yellow]" + "[b][WARNING] [" + ScriptName + "]: [/b]" + arg + "[/color]")

func LuaError(arg, dump)-> void:
	arg = LuaFixArg(arg)
	if dump == null:
		dump = false
	Ready = false
	print_rich("[color=red]" + "[b][ERROR] Veilstrike.lua error occurred within " + ScriptName + "[/b][/color]")
	print_rich("[color=red]" +  "[b][ERROR] Veilstrike.lua error: [/b]" + arg + "[/color]")
	if dump == true:
		print_rich("[CODE DUMP] Veilstrike.lua source code dump: " + LuaSource, Color(0, 1, 1))
	push_error("[ERROR] [" + ScriptName + "]: " + arg)
		
func Run()-> void:
	if not Engine.is_editor_hint() and not Ready:
		lua = LuaAPI.new()
        coroutine = lua.new_coroutine()

        var lua_libraries = ["base", "coroutine", "string", "table", "math", "utf8", "debug", "io", "os", "package"];
        lua.bind_libraries(lua_libraries)
		
        coroutine.push_variant("sleep", wait_for_object)
        coroutine.push_variant("print", LuaPrint)
        coroutine.push_variant("warn", LuaWarn)
        coroutine.push_variant("error", LuaError)
		
        coroutine.push_variant("VeilstrikeFlag", VeilstrikeFlag)
        coroutine.push_variant("VeilstrikeClient", VeilstrikeClient)
        coroutine.push_variant("VeilstrikeDev", VeilstrikeDev)
        coroutine.push_variant("VeilstrikeAdmin", VeilstrikeAdmin)
        coroutine.push_variant("VeilstrikeMod", VeilstrikeMod)
        coroutine.push_variant("VeilstrikeHost", VeilstrikeHost)

        coroutine.load_string(LuaSource)
        Ready = true

func _process(delta)-> void:
	if not Engine.is_editor_hint() and Ready == true:
		timeSince += delta
			
		if coroutine.is_done() || timeSince <= yieldTime: return
			
		var ret = coroutine.resume([])
			
		if ret is LuaError:
			push_warning("Veilstrike.lua: ERROR %d: " % ret.type + ret.message)
			return
			
		if ret:
			if ret[0] is Signal:
				set_process(false)
					
				await ret[0]
					
				yieldTime = 0
				timeSince = 1
					
				set_process(true)
				return
					
			timeSince = 0