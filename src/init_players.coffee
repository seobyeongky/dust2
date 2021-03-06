o = require 'observable'

{nodes} = require './nodes.json'
node_list = Object.keys(nodes)
{MAX_HP} = require './consts'
{make_statbox} = require './statbox'

module.exports = (env,statboxes) ->
	{players,RANDOM} = env
	{shuffle} = RANDOM

	rnd_node_list = shuffle node_list

	j = 1
	players.forEach (player,i) ->
		player.idx = i
		player.hp = o MAX_HP
		player.is_dead = o.compute [player.hp], (hp) -> hp <= 0
		player.turn_used = false
		player.sel = []
		player.node = rnd_node_list.pop()
		player.last_shown_stat = o()
		player.items = o []
		if player.id == Player.me().id
			statboxes[0] = player.statbox = make_statbox env, player, 0
			player.visible = true
		else
			statboxes[j] = player.statbox = make_statbox env, player, j
			j++
			player.visible = false

		player.update_last_shown_stat = ->
			player.last_shown_stat
				hp : player.hp()
				items : player.items().slice(0)

		player.add_item = (item) ->
			player.items().push item
			player.items player.items()

		player.add_items = (items) ->
			player.items().push items...
			player.items player.items()

	return