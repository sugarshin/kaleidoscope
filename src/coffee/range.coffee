"use strict"

{ EventEmitter } = require 'events'
objectAssign = require 'object-assign'

{ addListener } = require './util'

module.exports =
class Range extends EventEmitter

  defaults:
    text: null

  constructor: (@input, opts) ->
    super()
    @opts = objectAssign {}, @defaults, opts
    @setVal @input.value
    @changeText @getVal()
    @events()

  changeText: (num) ->
    @opts.text.innerText = num
    return this

  setVal: (val) ->
    @_val = val
    return this

  getVal: -> @_val

  events: ->
    addListener @input, 'input', (ev) =>
      @changeText ev.target.value

    addListener @input, 'change', (ev) =>
      @setVal parseInt(ev.target.value, 10)
      @emit 'input:change', ev
