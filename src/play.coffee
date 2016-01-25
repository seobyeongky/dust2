_ = require 'underscore'
o = require 'observable'

{INPUT_CHAT_MESSAGE} = require './system/consts'
{nodes,edges} = require './nodes.json'
{Scheduler} = require './scheduler'
{make_edgemap} = require './edge_map'
{make_bg} = require './bg'
{make_minimap} = require './minimap'
{make_selbox} = require './selbox'
{make_itembase} = require './itembase'
init_players = require './init_players'
register_selector = require './rnd_item_selector'

module.exports = (env) ->
	{E,players} = env
	itembase = env.itembase = []
	turn_player = env.turn_player = o null
	scheduler = new Scheduler
	edge_map = env.edge_map = make_edgemap nodes, edges
	statboxes = []
	init_players env, statboxes
	bg = make_bg()
	minimap = make_minimap env
	selbox = make_selbox env
	itembase.push make_itembase(env)...
	register_selector env

	notify_turn_end = (player) ->
		print "#{player.name}님께서 턴을 마치셨습니다."

	E.on 'update_visibility', ->
		other_players = (_.filter players, (p) -> p.id != Player.me().id)
		me = _.find players, (p) -> p.id == Player.me().id

		if (not me?) or me.is_dead()
			# 관전자일 경우나 죽었을 때
			for other in other_players
				other.visible = true
				other.update_last_shown_stat()
			return

		for other in other_players
			if me.node == other.node
				other.visible = true
				other.update_last_shown_stat()
			else if edge_map.check_can_go me.node, other.node
				other.visible = true
				other.update_last_shown_stat()
			else
				other.visible = false

	E.on 'move_to_adj_node', (player,node_id) ->
		player.node = node_id
		E.emit 'update_visibility'
		notify_turn_end player
		E.emit 'update_turn'

	E.on 'update_turn', ->
		tplayer = _.find players, (player) ->
			player.turn_used == false && player.is_dead() == false

		unless tplayer?
			unless (_.find players, (player) -> player.is_dead() == false)?
				# game over
				turn_player null
				print "모두 사망"
				return

			for player in (_.filter players, (player) -> player.is_dead() == false)
				player.turn_used = false
			E.emit 'update_turn'
			return

		tplayer.turn_used = true
		print "#{tplayer.name}님의 턴입니다."
		turn_player tplayer

	handle_chat = (pid,text) ->
		# dev-only feature
		if text.length > 0 && text[0] == '#'
			eval(text.substr(1))
			return

		input_num = parseInt(text)
		tplayer = turn_player()
		if tplayer? && tplayer.id == pid && 1 <= input_num && input_num <= 3
			sel = tplayer.sel[input_num - 1]
			if sel?
				sel()

	update = ->
		scheduler.tick()

	render = ->
		UI.draw bg
		minimap.render()
		for statbox in statboxes
			statbox.render()
		selbox.render()

	## init commands ##
	for player in players
		player.add_items [0...3].map -> env.selector.select()

	E.emit 'update_visibility'
	scheduler.add (-> E.emit 'update_turn'), 0.5

	on_frame_move : ->
		update()
		render()
		return

	on_player_input : (pid,type,args...) ->
		if type == INPUT_CHAT_MESSAGE
			handle_chat pid, args[0]