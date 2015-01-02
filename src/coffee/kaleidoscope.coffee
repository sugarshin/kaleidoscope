$ = require 'jquery'
_ = require 'underscore'

Mixin = require './../../coffee-mixin/dest/mixin'
Eventz = require './../../eventz/dest/eventz'
# Tneve = require './../../tneve.js/dest/tneve'

FileRead = require './fileread'

result = document.getElementById 'result'

document.getElementById('file').addEventListener 'change', (e) ->
  fileList = document.getElementById('file').files
  # reader = new FileReader
  console.log e.target.files
  # console.log reader
  frs = []
  for i in [0...e.target.files.length]
    frs[i] = new FileReader
    frs[i].readAsDataURL e.target.files[i]

    frs[i].onload = (event) ->
      img = $('<img />')
      console.log event.target.result
      img.attr 'src', event.target.result
      
      # result.innerHTML += event.target.result;
      $(result).append img

    frs[i].onerror = (event) ->
      code = event.target.error.code
      result.innerHTML += 'エラー発生：' + code

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