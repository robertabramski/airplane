_ = require('lodash')
child_process = require('child_process')

exports.parse = (command, options) ->

  if not command?
    throw new Error('Missing command argument')

  if not _.isString(command)
    throw new Error("Invalid command argument: #{command}")

  if _.isEmpty(command) or command.trim().length is 0
    throw new Error('Invalid command argument: empty string')

  if not options?
    throw new Error('Missing options argument')

  if not _.isObject(options) or _.isArray(options)
    throw new Error('Invalid options argument: not an object')

  return _.template(command)(options)

exports.execute = (command, callback) ->

  if not command?
    throw new Error('Missing command argument')

  if not _.isString(command)
    throw new Error("Invalid command argument: #{command}")

  if _.isEmpty(command) or command.trim().length is 0
    throw new Error('Invalid command argument: empty string')

  if not callback?
    throw new Error('Missing callback argument')

  if not _.isFunction(callback)
    throw new Error('Invalid callback argument: not a function')

  return child_process.exec command, (error, stdout, stderr) ->
    return callback(error) if error?
    return callback(new Error(stderr)) if stderr? and not _.isEmpty(stderr)
    return callback(null, stdout)
