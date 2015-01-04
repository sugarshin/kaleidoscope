$ = require 'jquery'

Mixin = require '../../coffee-mixin/dest/mixin'
Eventz = require '../../eventz/dest/eventz'


module.exports =
  class FileRead
    Mixin.include @, Eventz

    defaults:
      type: 'dataURL'

    constructor: (input, opts) ->
      @opts = $.extend {}, @defaults, opts
      @input = input
      @$input = $(input)
      # @events()

    setImgTag: (event) ->
      deferForWhen = $.Deferred()
      defers = []
      for file, i in event.target.files
        unless file.type.match 'image.*' then continue
        do (file) =>
          defer = $.Deferred()
          defers.push defer.promise()

          reader = new FileReader

          reader.onload = (ev) =>
            @_imgTags or= []
            @_imgTags.push "<img src='#{ev.target.result}' alt=''>"
            defer.resolve()
            

          reader.onerror = (ev) =>
            switch ev.target.error.code
              when ev.target.error.NOT_FOUND_ERR
                alert 'File Not Found!'
              when ev.target.error.NOT_READABLE_ERR
                alert 'File is not readable'
              when ev.target.error.ABORT_ERR
              # noop
              else
                alert 'An error occurred reading this file.'
            defer.reject()
            
          reader.readAsDataURL file

      $.when.apply($, defers).done =>
        deferForWhen.resolve @

      return deferForWhen.promise()

    getImgTag: -> @_imgTags

    events: ->
      @input.addEventListener 'change', (ev) => @setImgTag ev
