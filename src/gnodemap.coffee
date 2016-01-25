{nodes,edges} = require './nodes.json'
{make_sprite} = require './utils/sprite'
{SMALL_PADDING,GNODE_PLAYER_CIRCULAR_PADDING} = require './consts'
{alloc_rule_of_dot} = require './alloc_rule_of_dot'

module.exports =
	make_gnodemap : (env,X,Y,S) ->
		{players} = env

		for player in players
			sp = make_sprite "avatar#{player.idx}.png", null, S * 200
			sp.originX = 0.5 * sp.texture.width
			sp.originY = 0.9 * sp.texture.height
			player.gnodemap_avatar = sp

		gnodes = {}
		Object.keys(nodes).map (node_id) ->
			gnodes[node_id] = do ->
				node = nodes[node_id]
				dot = make_sprite "green_dot.png", SMALL_PADDING, SMALL_PADDING
				dot.originX = 0.5 * dot.texture.width
				dot.originY = 0.5 * dot.texture.height
				dot.x = X + node.pos[0] * S
				dot.y = Y + node.pos[1] * S
				render_queue_player = []
				render_queue_ctrl =
					add_player : (player) ->
						render_queue_player.push player

				render_queue : ->
					render_queue_ctrl

				render : ->
					UI.draw dot

					if render_queue_player.length > 0
						rules = alloc_rule_of_dot render_queue_player.length
						for player, i in render_queue_player
							[dx,dy] = rules[i]
							{gnodemap_avatar} = player
							gnodemap_avatar.x = dot.x + dx * GNODE_PLAYER_CIRCULAR_PADDING
							gnodemap_avatar.y = dot.y + dy * GNODE_PLAYER_CIRCULAR_PADDING
							UI.draw gnodemap_avatar

						render_queue_player.length = 0

		render : ->
			for player in players
				if player.visible
					gnode = gnodes[player.node]
					gnode.render_queue().add_player player

			for node_id, gnode of gnodes
				gnode.render()

			return