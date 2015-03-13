fs = require('fs')
_ = require('lodash')
sinon = require('sinon')
chai = require('chai')
chai.use(require('sinon-chai'))
expect = chai.expect
configuration = require('../lib/configuration')
Website = require('../lib/website')

describe 'Configuration:', ->

  describe '.load()', ->

    it 'should throw an error if no path', ->
      expect ->
        configuration.load(null, _.noop)
      .to.throw('Missing configuration path argument')

    it 'should throw an error if path is not a string', ->
      expect ->
        configuration.load(123, _.noop)
      .to.throw('Invalid configuration path argument: 123')

    it 'should throw an error if no callback', ->
      expect ->
        configuration.load('/foo/bar', null)
      .to.throw('Missing callback argument')

    it 'should throw an error if callback is not a function', ->
      expect ->
        configuration.load('/foo/bar', [ _.noop ])
      .to.throw('Invalid callback argument: not a function')

    describe 'if configuration path does not exist', ->

      beforeEach ->
        @fsExistsStub = sinon.stub(fs, 'exists')
        @fsExistsStub.yields(false)

      afterEach ->
        @fsExistsStub.restore()

      it 'should return an error', (done) ->
        configuration.load 'foo/bar', (error, config) ->
          expect(error).to.be.an.instanceof(Error)
          expect(error.message).to.equal('No configuration file found. Create one at foo/bar.')
          done()

    describe 'if configuration path exist', ->

      beforeEach ->
        @fsExistsStub = sinon.stub(fs, 'exists')
        @fsExistsStub.yields(true)

      afterEach ->
        @fsExistsStub.restore()

      describe 'if configuration path is loaded successfully', ->

        beforeEach ->
          @configurationRequireStub = sinon.stub(configuration, 'require')
          @configurationRequireStub.returns(foo: 'bar')

        afterEach ->
          @configurationRequireStub.restore()

        it 'should return the object to the callback', (done) ->
          configuration.load 'foo/bar', (error, config) ->
            expect(error).to.not.exist
            expect(config).to.deep.equal(foo: 'bar')
            done()

      describe 'if configuration path is not loaded successfully', ->

        beforeEach ->
          @configurationRequireStub = sinon.stub(configuration, 'require')
          @configurationRequireStub.throws()

        afterEach ->
          @configurationRequireStub.restore()

        it 'should return an error to the callback', (done) ->
          configuration.load 'foo/bar', (error, config) ->
            expect(error).to.be.an.instanceof(Error)
            expect(error.message).to.equal('Error loading foo/bar')
            expect(config).to.not.exist
            done()

  describe '.parse()', ->

    describe 'given no configuration', ->
      expect ->
        configuration.parse()
      .to.throw('Missing configuration argument')

    describe 'given invalid configuration', ->
      expect ->
        configuration.parse([ {} ])
      .to.throw('Invalid configuration argument: not an object')

      expect ->
        configuration.parse(123)
      .to.throw('Invalid configuration argument: not an object')

    describe 'given a valid configuration', ->

      beforeEach ->
        @configuration =
          websites:
            lodash: 'https://lodash.com',
            async: 'https://github.com/caolan/async'
          options:
            destination: '/opt/www/airplane'
          commands:
            clone: 'clone <%- url %>',
            update: 'update <%- url %>'

      it 'should transform websites into an array of Websites', ->
        result = configuration.parse(@configuration)
        expect(result.websites).to.be.an.instanceof(Array)
        for website in result.websites
          expect(website).to.be.an.instanceof(Website)

    describe 'given no configuration websites object', ->

      beforeEach ->
        @configuration =
          options:
            destination: '/opt/www/airplane'
          commands:
            clone: 'clone <%- url %>',
            update: 'update <%- url %>'

      it 'should throw an error', ->
        expect =>
          configuration.parse(@configuration)
        .to.throw('You don\'t have any websites')

    describe 'given an empty configuration websites object', ->

      beforeEach ->
        @configuration =
          websites: {}
          options:
            destination: '/opt/www/airplane'
          commands:
            clone: 'clone <%- url %>',
            update: 'update <%- url %>'

      it 'should throw an error', ->
        expect =>
          configuration.parse(@configuration)
        .to.throw('You don\'t have any websites')

    describe 'given a configuration websites array', ->

      beforeEach ->
        @configuration =
          websites: [
            { name: 'lodash', url: 'https://lodash.com' }
            { name: 'async', url: 'https://github.com/caolan/async' }
          ]
          options:
            destination: '/opt/www/airplane'
          commands:
            clone: 'clone <%- url %>',
            update: 'update <%- url %>'

      it 'should throw an error', ->
        expect =>
          configuration.parse(@configuration)
        .to.throw('Invalid configuration websites: not an object')

    describe 'given an invalid configuration websites', ->

      beforeEach ->
        @configuration =
          websites: 123
          options:
            destination: '/opt/www/airplane'
          commands:
            clone: 'clone <%- url %>',
            update: 'update <%- url %>'

      it 'should throw an error', ->
        expect =>
          configuration.parse(@configuration)
        .to.throw('Invalid configuration websites: not an object')

    describe 'given no configuration options object', ->

      beforeEach ->
        @configuration =
          websites:
            lodash: 'https://lodash.com',
            async: 'https://github.com/caolan/async'
          commands:
            clone: 'clone <%- url %>',
            update: 'update <%- url %>'

      it 'should throw an error', ->
        expect =>
          configuration.parse(@configuration)
        .to.throw('Missing destination configuration option')

    describe 'given no destination configuration option', ->

      beforeEach ->
        @configuration =
          websites:
            lodash: 'https://lodash.com',
            async: 'https://github.com/caolan/async'
          options:
            destination: null
          commands:
            clone: 'clone <%- url %>',
            update: 'update <%- url %>'

      it 'should throw an error', ->
        expect =>
          configuration.parse(@configuration)
        .to.throw('Missing destination configuration option')

    describe 'given a no string destination configuration option', ->

      beforeEach ->
        @configuration =
          websites:
            lodash: 'https://lodash.com',
            async: 'https://github.com/caolan/async'
          options:
            destination: 123
          commands:
            clone: 'clone <%- url %>',
            update: 'update <%- url %>'

      it 'should throw an error', ->
        expect =>
          configuration.parse(@configuration)
        .to.throw('Invalid destination configuration option: not a string')

    describe 'given no configuration commands object', ->

      beforeEach ->
        @configuration =
          websites:
            lodash: 'https://lodash.com',
            async: 'https://github.com/caolan/async'
          options:
            destination: '/opt/www/airplane'

      it 'should throw an error', ->
        expect =>
          configuration.parse(@configuration)
        .to.throw('Missing clone configuration command')

    describe 'given no clone configuration command', ->

      beforeEach ->
        @configuration =
          websites:
            lodash: 'https://lodash.com',
            async: 'https://github.com/caolan/async'
          options:
            destination: '/opt/www/airplane'
          commands:
            clone: null
            update: 'update <%- url %>'

      it 'should throw an error', ->
        expect =>
          configuration.parse(@configuration)
        .to.throw('Missing clone configuration command')

    describe 'given a no string clone configuration command', ->

      beforeEach ->
        @configuration =
          websites:
            lodash: 'https://lodash.com',
            async: 'https://github.com/caolan/async'
          options:
            destination: '/opt/www/airplane'
          commands:
            clone: 123
            update: 'update <%- url %>'

      it 'should throw an error', ->
        expect =>
          configuration.parse(@configuration)
        .to.throw('Invalid clone configuration command: not a string')

    describe 'given no update configuration command', ->

      beforeEach ->
        @configuration =
          websites:
            lodash: 'https://lodash.com',
            async: 'https://github.com/caolan/async'
          options:
            destination: '/opt/www/airplane'
          commands:
            clone: 'clone <%- url %>'
            update: null

      it 'should throw an error', ->
        expect =>
          configuration.parse(@configuration)
        .to.throw('Missing update configuration command')

    describe 'given a no string update configuration command', ->

      beforeEach ->
        @configuration =
          websites:
            lodash: 'https://lodash.com',
            async: 'https://github.com/caolan/async'
          options:
            destination: '/opt/www/airplane'
          commands:
            clone: 'clone <%- url %>'
            update: 123

      it 'should throw an error', ->
        expect =>
          configuration.parse(@configuration)
        .to.throw('Invalid update configuration command: not a string')
