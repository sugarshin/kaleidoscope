extend = require 'node.extend'

Promise = require 'bluebird'

inherits = require 'inherits'
EventEmitter = require('events').EventEmitter



module.exports =
  class FileRead
    inherits @, EventEmitter
    # Mixin.include @, Eventz

    defaults: {}

    constructor: (@input, opts) ->
      @opts = extend {}, @defaults, opts
      @events()

    setLoadedSrcs: (src) ->
      @_loadedSrcs or= []
      @_loadedSrcs.push src
      return this

    getLoadedSrcs: -> @_loadedSrcs

    _errorFunc: (ev, reject) ->
      switch ev.target.error.code
        when ev.target.error.NOT_FOUND_ERR
          alert 'File Not Found!'
        when ev.target.error.NOT_READABLE_ERR
          alert 'File is not readable'
        when ev.target.error.ABORT_ERR
        # noop
        else
          alert 'An error occurred reading this file.'
      reject new Error('An error occurred reading this file.')# ev.

    read: (event) ->
      promises = []
      for file, i in event.target.files
        unless file.type.match 'image.*' then continue
        do (file) =>
          promises.push promise = new Promise (resolve, reject) =>
            reader = new FileReader

            reader.onload = (ev) =>
              @setLoadedSrcs ev.target.result
              resolve ev

            reader.onerror = (ev) =>
              @_errorFunc ev, reject

            reader.readAsDataURL file

      return promiseAll = new Promise.all promises

    events: ->
      @input.addEventListener 'change', (ev) =>
        @emit 'input:change', ev
        # @trigger 'input:change', ev
