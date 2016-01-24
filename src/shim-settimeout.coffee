{Scheduler} = require './scheduler'

module.exports = (env) ->
	scheduler = new Scheduler

	tid_counter = 0
	global.setTimeout = (fn,secs) ->
		scheduler.add fn, secs
		0

	global.clearTimeout = ->

	stop_dict = {}

	global.setInterval = (fn,secs) ->
		tid = tid_counter++
		fn_w = ->
			return if stop_dict[tid]
			fn()
			scheduler.add fn_w, secs
		scheduler.add fn_w, secs

	global.clearInterval = (tid) ->
		stop_dict[tid] = true

	tick : ->
		scheduler.tick()