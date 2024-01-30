extends RefCounted

#degrees as normal
var deg_num:int = 0
var deg_den:int = 1
#radians as fraction of π
var rad_num:int = 0
var rad_den:int = 1
#for display
var prefix:String
var suffix:String

func _init(num:int,den:int,is_deg:bool,pre:String,suf:String):
	if is_deg:
		add_deg(num,den)
	else:
		add_rad(num,den)
	prefix = pre
	suffix = suf

func gcd(a:int,b:int) -> int:
	return a if b==0 else gcd(b,a%b)

func add_deg(num:int,den:int) -> void:
	var new_num = deg_num*den+deg_den*num
	var new_den = deg_den*den
	var simp = gcd(new_den,new_num)
	deg_num = new_num/simp
	deg_den = new_den/simp
	rad_num = deg_num
	rad_den = 180*deg_den
	simp = gcd(rad_den,rad_num)
	rad_num/=simp
	rad_den/=simp

func add_rad(num:int,den:int) -> void:
	var new_num = deg_num*den+deg_den*num
	var new_den = deg_den*den
	var simp = gcd(new_den,new_num)
	rad_num = new_num/simp
	rad_den = new_den/simp
	deg_num = 180*rad_num
	deg_den = rad_den
	simp = gcd(deg_den,deg_num)
	deg_num/=simp
	deg_den/=simp

func sub_deg(num:int,den:int) -> void:
	add_deg(-num,den)

func sub_rad(num:int,den:int) -> void:
	add_rad(-num,den)

func is_zero() -> bool:
	return deg_num==0

func get_str_deg() -> String:
	return prefix+str(deg_num)+("/"+str(deg_den) if deg_den>1 else "")+suffix

func get_str_rad() -> String:
	return prefix+str(rad_num)+"π"+("/"+str(rad_den) if rad_den>1 else "")+suffix
