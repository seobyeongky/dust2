EventEmitter = require './libs/EventEmitter/EventEmitter.min.js'
_ = require 'underscore'
o = require 'observable'

FunctionBatch = require './utils/function_batch'
{INPUT_CHAT_MESSAGE} = require './system/consts'
{nodes,edges} = require './nodes.json'
{Scheduler} = require './scheduler'
{make_edgemap} = require './edge_map'
{make_bg} = require './bg'
{make_minimap} = require './minimap'
{make_selbox} = require './selbox'
init_players = require './init_players'

module.exports = (env) ->
	env.cleaner = new FunctionBatch
	env.RANDOM = (require './random') 1232
	env.E = new EventEmitter
	{E,players} = env
	turn_player = env.turn_player = o null
	scheduler = new Scheduler
	edge_map = env.edge_map = make_edgemap nodes, edges
	statboxes = []
	init_players env, statboxes
	bg = make_bg()
	minimap = make_minimap env
	selbox = make_selbox env

	notify_turn_end = (player) ->
		print "#{player.name}님께서 턴을 마치셨습니다."

	E.on 'move_to_adj_node', (player,node_id) ->
		player.node = node_id
		notify_turn_end player
		E.emit 'update_turn'

	E.on 'update_turn', ->
		tplayer = _.find players, (player) ->
			player.turn_used == false && player.hp() > 0

		unless tplayer?
			unless (_.find players, (player) -> player.hp() > 0)?
				# game over
				turn_player null
				print "모두 사망"
				return

			for player in (_.filter players, (player) -> player.hp() > 0)
				player.turn_used = false
			E.emit 'update_turn'
			return

		tplayer.turn_used = true
		print "#{tplayer.name}님의 턴입니다."
		turn_player tplayer

	scheduler.add (-> E.emit 'update_turn'), 0.5

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

	on_frame_move : ->
		update()
		render()
		return

	on_player_input : (pid,type,args...) ->
		if type == INPUT_CHAT_MESSAGE
			handle_chat pid, args[0]