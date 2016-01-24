{PADDING,SMALL_PADDING,TXT_HEIGHT} = require './consts'
{make_sprite} = require './utils/sprite'

module.exports =
	make_statbox : (player,i) ->
		W = 0.4 * UI.width
		H = 0.2 * UI.height
		X = UI.width - W - PADDING
		Y = PADDING + i * (SMALL_PADDING + 0.2 * UI.height)

		bg = make_sprite "frame0.png", W, H
		bg.x = X
		bg.y = Y

		AX = X + SMALL_PADDING
		avatar = make_sprite "avatar#{player.idx}.png", null, H - 2 * SMALL_PADDING
		avatar.x = AX
		avatar.y = Y + SMALL_PADDING
		AX += avatar.scaleX * avatar.texture.width

		name_txt = new Text
		name_txt.x = AX + PADDING
		name_txt.y = Y + SMALL_PADDING
		name_txt.characterSize = TXT_HEIGHT
		name_txt.string = player.name
		name_txt.color = if player.id == Player.me().id then rgba(0,255,0,255) else rgba(255,0,0,255)

		hp_txt = new Text
		hp_txt.x = AX + PADDING
		hp_txt.y = Y + SMALL_PADDING + TXT_HEIGHT + SMALL_PADDING
		hp_txt.characterSize = TXT_HEIGHT
		hp_txt.color = rgba(255, 255, 255, 255)
		player.hp (hp) ->
			hp_txt.string = "HP : #{player.hp()}"
		
		bloody = make_sprite "bloody.png", W, H
		bloody.x = X
		bloody.y = Y

		render : ->
			unless player?
				return

			UI.draw bg

			if player.visible
				UI.draw avatar
				UI.draw name_txt
				UI.draw hp_txt