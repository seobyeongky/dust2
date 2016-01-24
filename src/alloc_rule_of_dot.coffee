# 미니맵 점에 플레이어 아바타 배치 계산
d2r = (degree) ->
	degree * Math.PI / 180

pos_from_angle = (degree,ratio) ->
	[ratio * Mathd.cos(degree), -ratio * Mathd.sin(degree)]

dict =
	1 :
		[
			pos_from_angle 90, 0.5
		]

	2 :
		[
			pos_from_angle 150, 0.5
			pos_from_angle 30, 0.5
		]

	3 :
		[
			pos_from_angle 180, 0.8
			pos_from_angle 90, 0.8
			pos_from_angle 0, 0.8
		]

	4 :
		[
			pos_from_angle 225, 1
			pos_from_angle 135, 1
			pos_from_angle 45, 1
			pos_from_angle 315, 1
		]


module.exports =
	alloc_rule_of_dot : (idx) ->
		dict[idx]