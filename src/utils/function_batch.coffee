class FunctionBatch
	constructor : ->
		@_list = []

	add : (fn) ->
		@_list.push fn
		return

	remove : (fn) ->
		index = @_list.indexOf fn
		if index >= 0
			@_list.splice index, 1
		return

	flush : (args...) ->
		ret = @_list.map (fn) -> fn args...
		@_list.length = 0
		ret

module.exports = FunctionBatch