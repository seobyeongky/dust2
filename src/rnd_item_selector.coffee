_ = require 'underscore'

module.exports = (env) ->
	{RANDOM,itembase} = env
	{number} = RANDOM

	total_weight = _.reduce itembase, ((memo,itemdesc) -> itemdesc.select_weight + memo), 0

	env.selector =
		select : ->
			random_value = number total_weight
			probe = 0
			itemdesc = _.find itembase, (desc) ->
				probe += desc.select_weight
				probe > random_value
			throw new Error("random logic error") unless itemdesc?

			itemdesc.id