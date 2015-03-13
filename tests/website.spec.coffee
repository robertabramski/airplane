fsPlus = require('fs-plus')
_ = require('lodash')
sinon = require('sinon')
chai = require('chai')
chai.use(require('sinon-chai'))
expect = chai.expect
Website = require('../lib/website')
commands = require('../lib/commands')

describe 'Website:', ->

  beforeEach ->
    @website =
      name: 'lodash'
      url: 'https://lodash.com'

    @commands =
      clone: 'clone <%- url %>',
      update: 'update <%- url %>'

    @options =
      destination: '/opt/www/airplane'

  describe '#constructor()', ->

    it 'should throw if no website options', ->
      expect =>
        new Website(null, @commands, @options)
      .to.throw('Missing website argument')

    it 'should throw if website options is not an object', ->
      expect =>
        new Website([ {} ], @commands, @options)
      .to.throw('Invalid website argument: not an object')

      expect =>
        new Website(123, @commands, @options)
      .to.throw('Invalid website argument: not an object')

    it 'should throw if no website url', ->
      expect =>
        new Website(name: 'lodash', @commands, @options)
      .to.throw('Missing website url')

    it 'should throw if website url is not a string', ->
      expect =>
        new Website({ name: 'lodash', url: 123 }, @commands, @options)
      .to.throw('Invalid website url: not a string')

    it 'should throw if no website name', ->
      expect =>
        new Website(url: 'https://lodash.com', @commands, @options)
      .to.throw('Missing website name')

    it 'should throw if website name is not a string', ->
      expect =>
        new Website({ name: 123, url: 'https://lodash.com' }, @commands, @options)
      .to.throw('Invalid website name: not a string')

    it 'should throw if no commands object', ->
      expect =>
        new Website(@website, null, @options)
      .to.throw('Missing commands argument')

    it 'should throw if commands is not an object', ->
      expect =>
        new Website(@website, [ {} ], @options)
      .to.throw('Invalid commands argument: not an object')

      expect =>
        new Website(@website, 123, @options)
      .to.throw('Invalid commands argument: not an object')

    it 'should throw if no clone command', ->
      expect =>
        new Website(@website, _.omit(@commands, 'clone'), @options)
      .to.throw('Missing clone command')

    it 'should throw if clone command is not a string', ->
      expect =>
        new Website(@website, { update: 'update', clone: 123 }, @options)
      .to.throw('Invalid clone command: not a string')

    it 'should throw if no update command', ->
      expect =>
        new Website(@website, _.omit(@commands, 'update'), @options)
      .to.throw('Missing update command')

    it 'should throw if update command is not a string', ->
      expect =>
        new Website(@website, { clone: 'clone', update: 123 }, @options)
      .to.throw('Invalid update command: not a string')

    it 'should throw if no options object', ->
      expect =>
        new Website(@website, @commands, null)
      .to.throw('Missing options argument')

    it 'should throw if options is not an object', ->
      expect =>
        new Website(@website, @commands, [ {} ])
      .to.throw('Invalid options argument: not an object')

      expect =>
        new Website(@website, @commands, 123)
      .to.throw('Invalid options argument: not an object')

    it 'should throw if no destination option', ->
      expect =>
        new Website(@website, @commands, _.omit(@options, 'destination'))
      .to.throw('Missing destination option')

    it 'should throw if destination option is not a string', ->
      expect =>
        new Website(@website, @commands, destination: 123)
      .to.throw('Invalid destination option: not a string')

  describe '.url', ->

    it 'should expose website url to the object', ->
      website = new Website(@website, @commands, @options)
      expect(website.url).to.equal(@website.url)

  describe '#name', ->

    it 'should expose website name to the object', ->
      website = new Website(@website, @commands, @options)
      expect(website.name).to.equal(@website.name)

  describe '#destination', ->

    it 'should concatenate options destination and website name', ->
      website = new Website
        name: 'lodash'
        url: 'https://lodash.com'
      ,
        clone: 'clone <%- url %>'
        update: 'update <%- url %>'
      ,
        destination: '/foo/bar'

      expect(website.destination).to.equal('/foo/bar/lodash')

  describe '#_evaluateCommand()', ->

    describe 'if commands.execute throws an error', ->

      beforeEach ->
        @commandsExecuteStub = sinon.stub(commands, 'execute')
        @commandsExecuteStub.yields(new Error('error'))

      afterEach ->
        @commandsExecuteStub.restore()

      it 'should return the error to the callback', (done) ->
        website = new Website(@website, @commands, @options)
        website._evaluateCommand 'command', (error, destination) ->
          expect(error).to.be.an.instanceof(Error)
          expect(error.message).to.equal('error')
          expect(destination).to.not.exist
          done()

    describe 'if commands.execute succeeds', ->

      beforeEach ->
        @commandsExecuteStub = sinon.stub(commands, 'execute')
        @commandsExecuteStub.yields(null, 'stdout')

      afterEach ->
        @commandsExecuteStub.restore()

      it 'should return the destination to the callback', (done) ->
        website = new Website(@website, @commands, @options)
        website._evaluateCommand 'command', (error, destination) ->
          expect(error).to.not.exist
          expect(destination).to.equal(website.destination)
          done()

  describe '#clone()', ->

    beforeEach ->
      @instance = new Website(@website, @commands, @options)
      @_evaluateCommandStub = sinon.stub(@instance, '_evaluateCommand')
      @_evaluateCommandStub.yields(null, @instance.destination)

    afterEach ->
      @_evaluateCommandStub.restore()

    it 'should call _evaluateCommand with clone command', (done) ->
      @instance.clone (error, destination) =>
        expect(error).to.not.exist
        expect(destination).to.equal(@instance.destination)
        expect(@_evaluateCommandStub).to.have.been.calledOnce
        expect(@_evaluateCommandStub).to.have.been.calledWith(@commands.clone)
        done()

  describe '#update()', ->

    beforeEach ->
      @instance = new Website(@website, @commands, @options)
      @_evaluateCommandStub = sinon.stub(@instance, '_evaluateCommand')
      @_evaluateCommandStub.yields(null, @instance.destination)

    afterEach ->
      @_evaluateCommandStub.restore()

    it 'should call _evaluateCommand with update command', (done) ->
      @instance.update (error, destination) =>
        expect(error).to.not.exist
        expect(destination).to.equal(@instance.destination)
        expect(@_evaluateCommandStub).to.have.been.calledOnce
        expect(@_evaluateCommandStub).to.have.been.calledWith(@commands.update)
        done()

  describe '#exists()', ->

    beforeEach ->
      @fsPlusIsDirectoryStub = sinon.stub(fsPlus, 'isDirectory')
      @fsPlusIsDirectoryStub.yields(true)

    afterEach ->
      @fsPlusIsDirectoryStub.restore()

    it 'should call fsPlus.isDirectory with destination', (done) ->
      website = new Website(@website, @commands, @options)
      website.exists (exists) =>
        expect(exists).to.be.true
        expect(@fsPlusIsDirectoryStub).to.have.been.calledOnce
        expect(@fsPlusIsDirectoryStub).to.have.been.calledWith(website.destination)
        done()
