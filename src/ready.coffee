EventEmitter = require './libs/EventEmitter/EventEmitter.min.js'
_ = require 'underscore'

{STATE_PLAY,BG_KIND,MAX_NR_PLAYER,TXT_HEIGHT,PADDING,SMALL_PADDING} = require './consts'
{INPUT_CHAT_MESSAGE} = require './system/consts'
{Scheduler} = require './scheduler'
{shuffle} = require './utils'
FunctionBatch = require './utils/function_batch'

module.exports = (env) ->
	{lv} = env

	env.my_id = Player.me().id
	env.my_name = Player.me().name
	env.cleaner = new FunctionBatch
	env.E = new EventEmitter

	count = 0
	scheduler = new Scheduler

	info_txt = new Text
	info_txt.color = {r:0,g:255,b:0,a:255}
	info_txt.x = 0.2 * UI.width
	info_txt.y = 0.3 * UI.height
	info_txt.characterSize = TXT_HEIGHT
	info_txt.string = "dust2에 오신 것을 환영합니다.\n시작하기 전에 각오 한마디를 채팅으로 입력하십시오."

	det_text = new Text
	det_text.color = {r:255,g:255,b:255,a:255}
	det_text.x = 0.2 * UI.width + PADDING
	det_text.y = 0.3 * UI.height + 2 * TXT_HEIGHT + SMALL_PADDING
	det_text.characterSize = TXT_HEIGHT

	Audio.playMusic "audio/infantry_close01.wav"
	dict = {}
	players = env.players = []

	exit = ->
		rnd_hash_code = players.map (p) ->
			dict[p.id]
		.join()
		.hashCode()
		env.RANDOM = (require './random') Math.abs(rnd_hash_code)
		Audio.stopMusic()
		env.state = STATE_PLAY

	check = ->
		count = 0
		txt_str = ""
		for player in players
			det_str = ""
			_ref = dict[player.id]
			if _ref?
				det_str = _ref
				count++
			txt_str += "#{player.name}님 : #{det_str}\n"

		if count == players.length
			scheduler.add exit, 1

		det_text.string = txt_str

	scheduler.add ->
		rawplayers = Player.all()
		for i in [0...Math.min(rawplayers.length, MAX_NR_PLAYER)]
			players.push rawplayers[i]

		check()
	, 1

	handle_chat = (pid,text) ->
		return if dict[pid]?
		return if players.length == 0
		return unless _.find(players, (p) -> p.id == pid)?
		dict[pid] = text
		check()

	on_frame_move : ->
		scheduler.tick()
		UI.draw info_txt
		UI.draw det_text

	on_player_input : (pid,type,args...) ->
		if type == INPUT_CHAT_MESSAGE
			handle_chat pid, args[0]