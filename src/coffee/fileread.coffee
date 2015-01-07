Promise = require 'bluebird'
_ = require 'underscore'

Mixin = require '../../coffee-mixin/dest/mixin'
Eventz = require '../../eventz/dest/eventz'

module.exports =
  class FileRead
    Mixin.include @, Eventz

    defaults:
      result: null

    constructor: (@input, opts) ->
      @opts = _.extend {}, @defaults, opts
      @events()

    outputResult: (src) ->
      div = document.createElement 'div'
      div.className = 'result-file-image'

      img = document.createElement 'img'
      img.src = src

      div.appendChild img

      @_resultImgsEl or= []
      @_resultImgsEl.push div
      @opts.result.appendChild div
      return this

    _loadedFunc: (ev, resolve) ->
      @_imgSrcs or= []
      @_imgSrcs.push ev.target.result
      # @outputResult ev.target.result
      resolve @

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

    setImgSrc: (event) ->
      promises = []
      for file, i in event.target.files
        unless file.type.match 'image.*' then continue
        do (file) =>
          promises.push promise = new Promise (resolve, reject) =>
            reader = new FileReader

            reader.onload = (ev) =>
              @_loadedFunc ev, resolve

            reader.onerror = (ev) =>
              @_errorFunc ev, reject

            reader.readAsDataURL file

      return promiseAll = new Promise.all promises

    getImgSrc: -> @_imgSrcs

    events: ->
      @input.addEventListener 'change', (ev) =>
        @trigger 'input:change', ev

      @opts.result.addEventListener 'click', (ev) =>
        @trigger 'result:click', ev
