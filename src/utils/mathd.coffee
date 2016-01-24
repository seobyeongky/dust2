d2r = (degree) ->
	degree * Math.PI / 180

global.Mathd =
	cos : (degree) ->
		Math.cos(d2r(degree))

	sin : (degree) ->
		Math.sin(d2r(degree))