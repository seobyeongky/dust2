module.exports =
	make_itembase : (env) ->
		[
			(require './items/medikit') env
			(require './items/mine') env
		]