extends KinematicBody2D

# 移动前的2D坐标
var vec = Vector2.ZERO
# 角色的最大移动速度
const MAX_SPEED = 100
# 移动的加速度
const ACCELERATION = 10
# 移动的摩擦力
const FRICTION = 25

# gdscript 里下划线开头的函数
# 表示回调函数
# _ready函数是在进入该节点时触发的
# 一般用于一些初始化的事情
func _ready():
	pass

# _physics_process函数会按帧死循环执行
# 该函数一般用于处理视图的更新代码
# 参数delta指的是上一帧花费的时间
func _physics_process(delta:float) -> void:
	# 以下乘以了delta是为了让角色的移动同步电脑的帧率速度
	
	# 移动后的2D坐标
	var input_vec = Vector2.ZERO
	input_vec.x = Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	input_vec.y = Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")
	# 因为左上或者右下类似的斜性移动速度会比正常的上下左右移动速度快
	# 所以我们要用normalizde函数来固定向量的斜性变动
	# 这样就可以确保各个方位的移动速度是一样的了
	input_vec = input_vec.normalized()

	if input_vec != Vector2.ZERO:
		vec += input_vec * ACCELERATION * delta
		vec = vec.limit_length(MAX_SPEED * delta)
	else :
		vec = vec.move_toward(Vector2.ZERO, FRICTION * delta)
	# move_and_collide用于更新该节点的位置
	move_and_collide(vec)
