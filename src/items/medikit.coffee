module.exports = (env) ->

	id : 'medikit'
	name : '메디킷'
	select_weight : 2
	capacity : 3
	icon : "medikit.png"
	use : (player) ->
		player.hp Math.min(100, player.hp + 30)