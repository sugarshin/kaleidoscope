extend = require 'extend'
jsonp = require 'jsonp-client'
Promise = require 'bluebird'
inherits = require 'inherits'
bean = require 'bean'
EventEmitter2 = require('eventemitter2').EventEmitter2

module.exports =
  class Instagram
    "use strict"

    inherits @, EventEmitter2

    _ACCESS_TOKEN = '3060080.899ffd6.6bb01cbe1a284a8097983a1a443a3ec1'
 
    defaults: {}

    constructor: (@search, @button, opts) ->
      EventEmitter2.call @
      @opts = extend {}, @defaults, opts
      @events()

    _getRandomInt: (min, max) ->
      return Math.floor(Math.random() * (max - min + 1)) + min

    _addCallback: (url) ->
      if url.match(/callback=[a-z]/i) then return url
      return "#{url}#{("&callback=cb#{Math.random()}").replace('.', '')}"

    get: (url) ->
      return new Promise (resolve, reject) =>
        jsonp @_addCallback(url), (err, data) ->
          if err?
            reject err
          else
            resolve data

    getRandomImage: (result) ->
      len = result.data.length
      data = result.data[@_getRandomInt(0, len)]
      image = {}
      return image =
        url: data.images.standard_resolution.url
        width: data.images.standard_resolution.width
        height: data.images.standard_resolution.height

    events: ->
      bean.on @button, 'click.instagramsearch', (ev) =>
        url = "https://api.instagram.com/v1/tags/#{@search.value}/media/recent?access_token=#{_ACCESS_TOKEN}"
        @emit 'search:submit', ev, url
