path = require('path')
fsPlus = require('fs-plus')
_ = require('lodash')
commands = require('./commands')

module.exports = class Website

  constructor: (website, @commands, options) ->

    if not website?
      throw new Error('Missing website argument')

    if not _.isObject(website) or _.isArray(website)
      throw new Error('Invalid website argument: not an object')

    # TODO: It should test that url is a valid url

    if not website.url?
      throw new Error('Missing website url')

    if not _.isString(website.url)
      throw new Error('Invalid website url: not a string')

    if not website.name?
      throw new Error('Missing website name')

    if not _.isString(website.name)
      throw new Error('Invalid website name: not a string')

    if not @commands?
      throw new Error('Missing commands argument')

    if not _.isObject(@commands) or _.isArray(@commands)
      throw new Error('Invalid commands argument: not an object')

    if not @commands.clone?
      throw new Error('Missing clone command')

    if not _.isString(@commands.clone)
      throw new Error('Invalid clone command: not a string')

    if not @commands.update?
      throw new Error('Missing update command')

    if not _.isString(@commands.update)
      throw new Error('Invalid update command: not a string')

    if not options?
      throw new Error('Missing options argument')

    if not _.isObject(options) or _.isArray(options)
      throw new Error('Invalid options argument: not an object')

    if not options.destination?
      throw new Error('Missing destination option')

    if not _.isString(options.destination)
      throw new Error('Invalid destination option: not a string')

    _.extend(this, website)

    @destination = path.join(options.destination, website.name)

  _evaluateCommand: (command, callback) ->

    # TODO: Find a way to test that the command was parsed
    # successfully. A better way might be to add functionality
    # to command.parse to check that there are no missing
    # interpolations just before returning the result.
    parsedCommand = commands.parse(command, this)

    commands.execute parsedCommand, (error) =>
      return callback(error) if error?
      return callback(null, @destination)

  clone: (callback) ->
    @_evaluateCommand(@commands.clone, callback)

  update: (callback) ->
    @_evaluateCommand(@commands.update, callback)

  exists: (callback) ->
    return fsPlus.isDirectory(@destination, callback)
