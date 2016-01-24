_ = require 'underscore'
o = require 'observable'

{PADDING,SMALL_PADDING,TXT_HEIGHT} = require './consts'
{make_sprite} = require './utils/sprite'

module.exports =
	make_selbox : (env) ->
		{turn_player,cleaner} = env

		bg = make_sprite "frame0.png", 0.4 * UI.width, 0.2 * UI.height
		bg.x = PADDING
		bg.y = UI.height - PADDING - bg.scaleY * bg.texture.height

		make_txt = (i) ->
			txt = new Text
			txt.color = rgba(255,255,255,255)
			txt.characterSize = TXT_HEIGHT
			txt.x = bg.x + SMALL_PADDING
			txt.y = bg.y + SMALL_PADDING + i * (txt.characterSize + SMALL_PADDING)
			txt

		txtlist = [0...3].map make_txt
		other_turn_txt = make_txt 0
		timer = o 0
		tid = setInterval ->
			timer timer() + 1
		, 1
		cleaner.add ->
			clearInterval tid

		o.compute [timer, turn_player], (count,player) ->
			if player?
				postfix = ""
				postfix += "." for i in [0...(count % 4)]
				other_turn_txt.string = "#{player.name}님의 턴#{postfix}"
			return

		set_player : ->

		render : ->
			UI.draw bg

			unless turn_player()?
				return

			if turn_player().id != Player.me().id
				UI.draw other_turn_txt
				return

			txtlist.forEach (txt) ->
				UI.draw txt