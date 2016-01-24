
{spawn,exec} = require 'child_process'
{readFile,writeFile,realpathSync,readFileSync,readdirSync,statSync} = require 'fs'
{join,extname} = require 'path'
coffeelint = require 'coffeelint'

(require 'coffee-script').register()
lint_cfg = require './coffeelint.json'
DefaultReporter = require './node_modules/coffeelint/src/reporters/default'

TARGET_PATH = join("script", "index.js")

launch = (cmd, options=[], callback) ->
	app = spawn cmd, options, (err) ->
		console.log err
	app.stdout.pipe(process.stdout)
	app.stderr.pipe(process.stderr)
	app.on 'exit', (status) -> callback?() if status is 0

launch2 = (cmd, callback) ->
	[x,y...] = cmd.split(' ')
	launch x,y,callback


read = (path) ->
	realPath = realpathSync(path)
	return readFileSync(realPath).toString()

walk = (dir) ->
	results = []
	list = readdirSync(dir)
	list.forEach (file) ->
		file = join(dir, file)
		stat = statSync(file)
		if (stat && stat.isDirectory())
			results = results.concat(walk(file))
		else if extname(file) == '.coffee'
			results.push(file)
	results

lint = (next) ->
	errorReport = new coffeelint.getErrorReport()

	files = walk(join(__dirname, 'src'))

	for file in files
		source = read(file)
		errorReport.lint(file, source, lint_cfg, false)

	error_occured = false
	for path, __v of errorReport.paths
		error_occured = error_occured or errorReport.pathHasError(path)

	if error_occured
		reporter = new DefaultReporter errorReport,
			colorize : false
		reporter.publish()
		next "coffee error - please show log above"
	else
		next()


add_shim_for_global = (next) ->
	readFile TARGET_PATH, (err,data) ->
		return next err if err

		data = "this[\"global\"] = this;\n" + data
		writeFile TARGET_PATH, data, next



task 'sbuild', 'ho!', ->
	lint (err) ->
		if err
			console.log "coffee lint error : ", err
			return

		exec "webmake --ext=coffee src/index.coffee #{TARGET_PATH}", (err,stdout,stderr) ->
			if err?
				console.log "webmake error : ", err
				return

			if stdout
				console.log "webmake stdout : ", stdout

			if stderr
				console.log "webmake stderr : ", stderr
				return

			add_shim_for_global (err) ->
				if err
					console.log "add_shim_for_global error : ", err
					return

				console.log "Build done."