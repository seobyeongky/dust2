_ = require 'underscore'
o = require 'observable'

FunctionBatch = require './utils/function_batch'
{INPUT_CHAT_MESSAGE} = require './system/consts'
{Scheduler} = require './scheduler'
{make_bg} = require './bg'
{make_minimap} = require './minimap'
{make_selbox} = require './selbox'
init_players = require './init_players'


main_key_color = (index) ->
	switch index % 3
		when 0
			{r:0,g:0,b:0,a:255}
		when 1
			{r:50,g:50,b:50,a:255}
		when 2
			{r:255,g:255,b:240,a:255}

sub_key_color = (index) ->
	switch index % 3
		when 0
			{r:255,g:255,b:255,a:255}
		when 1
			{r:180,g:180,b:170,a:255}
		when 2
			{r:190,g:190,b:180,a:255}

module.exports = (env) ->
	env.cleaner = new FunctionBatch
	env.RANDOM = (require './random') 1232
	{players} = env
	turn_player = env.turn_player = o null

	scheduler = new Scheduler
	statboxes = []
	init_players env, statboxes
	bg = make_bg()
	minimap = make_minimap env
	selbox = make_selbox env

	update_turn = ->
		turn_player _.find players, (player) ->
			player.turn_used == false && player.hp() > 0

		unless turn_player()?
			unless (_.find players, (player) -> player.hp() > 0)?
				# game over
				print "모두 사망"
				return

			for player in (_.filter players, (player) -> player.hp() > 0)
				player.turn_used = false
			update_turn()
			return

		turn_player().turn_used = true
		print "#{turn_player().name}님의 턴입니다."

	scheduler.add update_turn, 0.5

	handle_chat = (pid,text) ->
		# dev-only feature
		if text.length > 0 && text[0] == '#'
			eval(text.substr(1))

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