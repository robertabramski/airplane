fs = require('fs')
_ = require('lodash')
Website = require('./website')

# Wrap around require() to allow stubing
exports.require = (path) ->
  return require(path)

exports.load = (configPath, callback) ->

  if not configPath?
    throw new Error('Missing configuration path argument')

  if not _.isString(configPath)
    throw new Error("Invalid configuration path argument: #{configPath}")

  if not callback?
    throw new Error('Missing callback argument')

  if not _.isFunction(callback)
    throw new Error('Invalid callback argument: not a function')

  fs.exists configPath, (exists) ->
    if not exists
      error = new Error("No configuration file found. Create one at #{configPath}.")
      return callback(error)

    try
      result = exports.require(configPath)
    catch error
      return callback(new Error("Error loading #{configPath}"))

    return callback(null, result)

exports.parse = (configuration) ->

  if not configuration?
    throw new Error('Missing configuration argument')

  if not _.isObject(configuration) or _.isArray(configuration)
    throw new Error('Invalid configuration argument: not an object')

  if not configuration.websites?
    throw new Error('You don\'t have any websites')

  if not _.isObject(configuration.websites) or _.isArray(configuration.websites)
    throw new Error('Invalid configuration websites: not an object')

  if _.isEmpty(configuration.websites)
    throw new Error('You don\'t have any websites')

  # Prevent "Cannot read property x from undefined" errors
  # from non existent options/commands objects
  _.defaults configuration,
    options: {}
    commands: {}

  if not configuration.options.destination?
    throw new Error('Missing destination configuration option')

  if not _.isString(configuration.options.destination)
    throw new Error('Invalid destination configuration option: not a string')

  if not configuration.commands.clone?
    throw new Error('Missing clone configuration command')

  if not _.isString(configuration.commands.clone)
    throw new Error('Invalid clone configuration command: not a string')

  if not configuration.commands.update?
    throw new Error('Missing update configuration command')

  if not _.isString(configuration.commands.update)
    throw new Error('Invalid update configuration command: not a string')

  configuration.websites = _.zip(_.keys(configuration.websites), _.values(configuration.websites))
  configuration.websites = _.map configuration.websites, (website) ->

    website =
      name: _.first(website)
      url: _.last(website)

    return new Website(website, configuration.commands, configuration.options)

  return configuration
