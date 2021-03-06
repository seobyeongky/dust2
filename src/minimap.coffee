{PADDING} = require './consts'
{make_sprite} = require './utils/sprite'
{make_gnodemap} = require './gnodemap'

module.exports =
	make_minimap : (env) ->
		H = 0.6 * UI.height
		bg = make_sprite "minimap.jpg", null, H
		W = bg.scaleX * bg.texture.width
		bg.x = PADDING
		bg.y = PADDING

		gnodemap = env.gnodemap = make_gnodemap env, bg.x, bg.y, bg.scaleY

		render : ->
			UI.draw bg
			gnodemap.render()