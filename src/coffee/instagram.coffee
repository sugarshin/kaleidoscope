"use strict"

Promise = require 'bluebird'
{ EventEmitter } = require 'events'
jsonp = require 'jsonp'
bean = require 'bean'

module.exports =
class Instagram extends EventEmitter

  _ACCESS_TOKEN = '3060080.899ffd6.6bb01cbe1a284a8097983a1a443a3ec1'

  constructor: (@search, @button, @opts) ->
    EventEmitter.call @
    @events()

  _getRandomInt: (min, max) ->
    return Math.floor(Math.random() * (max - min + 1)) + min

  get: (url) ->
    new Promise (resolve, reject) =>
      jsonp url, (err, data) ->
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
