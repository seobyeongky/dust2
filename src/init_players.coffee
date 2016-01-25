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
	for player, i in players
		player.idx = i
		player.hp = o MAX_HP
		player.turn_used = false
		if player.id == Player.me().id
			statboxes[i] = player.statbox = make_statbox player, i
			player.visible = true
			player.sel = []
		else
			statboxes[j] = player.statbox = make_statbox player, j
			j++
			player.visible = false

		player.node = rnd_node_list.pop()

	return