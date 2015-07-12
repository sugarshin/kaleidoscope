"use strict"

{ EventEmitter } = require 'events'
{ Promise } = require 'es6-promise'

{ addListener } = require './util'

module.exports =
class FileRead extends EventEmitter

  constructor: (@input, @opts) ->
    super()
    @events()

  # src == dataURL
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

  read: (files) ->
    fileArray = []
    for f, i in files
      file = files.item i
      unless file.type.match 'image.*' then continue
      fileArray.push file
    return Promise.all fileArray.map (file) =>
      new Promise (resolve, reject) =>
        reader = new FileReader

        reader.onload = (ev) =>
          @setLoadedSrcs ev.target.result
          resolve ev

        reader.onerror = (ev) =>
          @_errorFunc ev, reject

        reader.readAsDataURL file

  events: ->
    addListener @input, 'change', (ev) =>
      @emit 'input:change', ev
