extends KinematicBody2D

var vec = Vector2.ZERO # 移动前的2D坐标

const MAX_SPEED = 80 # 角色的最大移动速度

const ACCELERATION = 500 # 移动的加速度

const FRICTION = 500 # 移动的摩擦力

# gdscript 里下划线开头的函数
# 表示回调函数
# _ready函数是在进入该节点时触发的
# 一般用于一些初始化的事情
func _ready():
	pass

# 动画树初始化
onready var animationTree = $AnimationTree
# 初始化该动画树状态器
# 状态器是用来控制动画树中播放的动画
onready var animationState = animationTree.get("parameters/playback")

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
		# 注册动画树中的属性 "parameters/x/x",其内容为input_vec
		# x -> 属性面板中对应的名字
		animationTree.set("parameters/Idle/blend_position", input_vec)
		animationTree.set("parameters/Run/blend_position", input_vec)
		# 检测是否按下shift键
		if Input.is_action_pressed("ui_fast_speed"):
			# travel 函数作用是切换动画
			animationState.travel("Run")
			# 如果为冲刺状态则移动速度加x倍
			vec = vec.move_toward(input_vec * MAX_SPEED * 1.8, ACCELERATION * 10 * delta)
		else :
			animationState.travel("Run")
			# 正常状态移动速度不变
			vec = vec.move_toward(input_vec * MAX_SPEED, ACCELERATION * delta)
	else :
		animationState.travel("Idle")
		vec = vec.move_toward(Vector2.ZERO, FRICTION * delta)
	# move_and_collide用于更新该节点的位置
	# 也会处理一些移动和碰撞的函数,所以可以之间使用它
	# 不过这个函数不能让你沿着墙壁滑动,在遇到碰撞体时会很"粘"
	# 所以我们这里使用了move_and_slide函数
	# 它和move_and_collide函数很像,只不过遇到碰撞体时就
	# 会沿着一个方向偏移,就不会有"附着感了"
	vec = move_and_slide(vec)
