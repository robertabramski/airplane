chalk = require('chalk')
async = require('async')
configuration = require('./configuration')
settings = require('./settings')

async.waterfall [

  (callback) ->
    console.log("Loading config file: #{settings.configPath}")
    configuration.load(settings.configPath, callback)

  (config, callback) ->
    config = configuration.parse(config)
    async.eachSeries config.websites, (website, done) ->
      website.exists (exists) ->
        if exists
          console.log("#{chalk.yellow('[update]')} #{website.url} -> #{website.destination}")
          website.update(done)
        else
          console.log("#{chalk.green('[clone]')} #{website.url} -> #{website.destination}")
          website.clone(done)
    , callback

], (error) ->
  if error?
    console.error(error.message)
    process.exit(1)

  console.log('Finish processing websites.')
