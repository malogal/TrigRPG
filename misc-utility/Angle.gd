class_name Angle extends RefCounted

#rounding precision required
const ERROR:=0.001

var rads:float
#for display
var prefix:String
var suffix:String

#makes angle from (0,0) to (x,y) if (x,y)!=(0,0). in this case, val is ignored. otherwise, makes angle val.
func _init(val:float,x:float = 0,y:float = 0,is_deg:bool = false, pre:String = "",suf:String = ""):
	if x or y:
		if x==0 and y>0:
			val = PI/2
		elif x==0:
			val = -PI/2
		elif x>0:
			val = atan(y/x)
		else:
			val = atan(y/x)+PI
	rads = 0
	if is_deg:
		add_deg(val)
	else:
		add_rad(val)
	prefix = pre
	suffix = suf

func gcd(a:int,b:int) -> int:
	return a if b==0 else gcd(b,a%b)

func round(nearest,degrees=false):
	if degrees:
		nearest = nearest*PI/180
	rads = nearest*round(rads/nearest)

func mod_2pi(val) -> float:
	#print("before: "+str(val))
	var modifier:=TAU if val<0 else -TAU
	while val<0 or val>TAU:
		val+=modifier
	if TAU-val<ERROR:
		val = 0
	#print("after:  "+str(val))
	return val

func add_deg(val:int) -> void:
	rads = mod_2pi(rads+val*PI/180)

func add_rad(val:float) -> void:
	rads = mod_2pi(rads+val)

func sub_deg(val:int) -> void:
	rads = mod_2pi(rads-val*PI/180)

func sub_rad(val:float) -> void:
	rads = mod_2pi(rads-val)

func add_angle(angle:Angle) -> void:
	add_rad(angle.rads)

func sub_angle(angle:Angle) -> void:
	sub_rad(angle.rads)

func is_zero() -> bool:
	return abs(rads)<ERROR or abs(rads-TAU)<ERROR

func get_str_deg() -> String:
	return prefix+str(round(rads*18000/PI)/100)+suffix

func get_str_rad() -> String:
	#search for approximation
	var decimal:=rads/PI
	for denominator in range(1,100):
		var numerator:=decimal*denominator
		if abs(numerator-round(numerator))<ERROR:
			return prefix+str(round(numerator))+"π"+("/"+str(denominator) if denominator>1 else "")+suffix
	#fails to approximate
	return prefix+str(round(rads*100)/100)+suffix

func get_rich_str_rad() -> String:
	#search for approximation
	var decimal:=rads/PI
	for denominator in range(1,100):
		var numerator:=decimal*denominator
		if abs(numerator-round(numerator))<ERROR:
			var num_str: String = str(round(numerator))
			if round(numerator) == 1:
				num_str = ""
			if denominator>1:
				return prefix+"[u]"+num_str+"π[/u]\n"+str(denominator)+suffix
			else:
				return prefix+num_str+"π"+suffix
	#fails to approximate
	return prefix+ ("%.2f"%rads) +suffix
