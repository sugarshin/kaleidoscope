Promise = require 'bluebird'
_ = require 'underscore'

Mixin = require '../../coffee-mixin/dest/mixin'
Eventz = require '../../eventz/dest/eventz'

module.exports =
  class FileRead
    Mixin.include @, Eventz

    defaults:
      type: 'dataURL'

    constructor: (@input, opts) ->
      @opts = _.extend {}, @defaults, opts
      @events()

    setImgSrc: (event) ->
      promises = []
      for file, i in event.target.files
        unless file.type.match 'image.*' then continue
        do (file) =>
          promises.push promise = new Promise (resolve, reject) =>
            reader = new FileReader

            reader.onload = (ev) =>
              @_imgSrcs or= []
              @_imgSrcs.push ev.target.result
              # @_imgTags.push "<img src='#{ev.target.result}' alt=''>"
              resolve @

            reader.onerror = (ev) ->
              switch ev.target.error.code
                when ev.target.error.NOT_FOUND_ERR
                  alert 'File Not Found!'
                when ev.target.error.NOT_READABLE_ERR
                  alert 'File is not readable'
                when ev.target.error.ABORT_ERR
                # noop
                else
                  alert 'An error occurred reading this file.'
              reject new Error('An error occurred reading this file.')# ev.target.error

            reader.readAsDataURL file

      return promiseAll = new Promise.all promises

    getImgSrc: -> @_imgSrcs

    events: ->
      @input.addEventListener 'change', (ev) => @trigger 'input:change', ev
