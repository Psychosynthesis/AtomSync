fs = require 'fs-plus'
EventEmitter = require("events").EventEmitter

module.exports =
class Host
  constructor: (@configPath, @logger, @emitter) ->
    return if !fs.existsSync @configPath
    try
      data = fs.readFileSync @configPath, "utf8"
      settings = JSON.parse(data)
      for k, v of settings
        this[k] = v
    catch err
      @logger.error "#{err}, in file: #{@configPath}"
      atom.notifications.addError "AtomSync Error",
      {dismissable: true, detail: "#{err}", description: "#{@configPath}" }
      throw error

    @port?= ""
    @port = @port.toString()
    @ignore = @ignore.join(", ") if @ignore
    @watch  = @watch.join(", ") if @watch

  saveJSON: ->
    configPath = @configPath
    emitter = @emitter

    @configPath = undefined
    @emitter = undefined

    @ignore?= ".atom-sync.json,.git/**"
    @ignore = @ignore.split(',')
    @ignore = (val.trim() for val in @ignore when val)

    @watch  ?= ""
    @watch   = @watch.split(',')
    @watch   = (val.trim() for val in @watch when val)

    @transport?="scp"

    fs.writeFile configPath, JSON.stringify(this, null, 2), (err) ->
      if err
        console.log("Failed saving file #{configPath}")
      else
        emitter.emit 'configured'
