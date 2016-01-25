_ = require 'underscore'

{PADDING,SMALL_PADDING,TXT_HEIGHT,ITEM_ICON_HEIGHT} = require './consts'
{make_sprite} = require './utils/sprite'

module.exports =
	make_statbox : (env,player,i) ->
		{itembase} = env

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
		
		bloody = make_sprite "bloody.png", W, H
		bloody.x = X
		bloody.y = Y

		hidden_overlay = make_sprite "hidden_overlay.png", W, H
		hidden_overlay.x = X
		hidden_overlay.y = Y

		update_hp_txt = (hp) ->
			hp_txt.string = "HP : #{hp}"

		sp_items = []
		update_items = (item_ids) ->
			sp_items.length = 0
			for item_id, i in item_ids
				itemdesc = _.find itembase, (itemdesc) -> itemdesc.id == item_id
				sp = make_sprite itemdesc.icon, null, ITEM_ICON_HEIGHT
				sp.x = AX + i * PADDING + PADDING
				sp.y = Y + H - SMALL_PADDING - ITEM_ICON_HEIGHT
				sp_items.push sp
			return

		if player.id == Player.me().id
			player.hp update_hp_txt
			player.items update_items
		else
			player.last_shown_stat (stat) ->
				if stat?
					update_hp_txt stat.hp
					update_items stat.items

		render : ->
			unless player?
				return

			UI.draw bg

			if player.id == Player.me().id || player.last_shown_stat()?
				UI.draw avatar
				UI.draw name_txt
				UI.draw hp_txt
				for sp_item in sp_items
					UI.draw sp_item

			if player.visible == false
				UI.draw hidden_overlay