Mixin = require '../../coffee-mixin/dest/mixin'
Eventz = require '../../eventz/dest/eventz'

$ = require 'jquery'

class FileRead
  Mixin.include @, Eventz

  defaults:
    type: 'dataURL'

  constructor: (el, options) ->
    @options = @extend {}, @defaults, options
    @el = el

  addImg: (e) ->


  addImg: (fileList) ->
    @fileReader or= []
    for file, i in fileList
      @fileReader[i] = new FileReader
      @fileReader[i].readAsDataURL file

      @addEvent @fileReader[i], 'load', ->
      # @fileReader[i].onload = (event) ->
        img = $('<img />')
        console.log event.target.result
        img.attr 'src', event.target.result
        
        # result.innerHTML += event.target.result;
        $(result).append img

      @fileReader[i].onerror = (event) ->
        code = event.target.error.code
        result.innerHTML += 'エラー発生：' + code

  events: ->
    @addEvent @el, 'change', 