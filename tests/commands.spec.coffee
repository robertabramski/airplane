child_process = require('child_process')

_ = require('lodash')
sinon = require('sinon')
chai = require('chai')
chai.use(require('sinon-chai'))
expect = chai.expect
commands = require('../lib/commands')

describe 'Commands:', ->

  describe '.parse()', ->

    describe 'given invalid command values', ->

      it 'should throw if no command', ->
        expect ->
          commands.parse(null, {})
        .to.throw('Missing command argument')

      it 'should throw if command is not a string', ->
        expect ->
          commands.parse(123, {})
        .to.throw('Invalid command argument: 123')

      it 'should throw if command is an empty string', ->
        expect ->
          commands.parse('', {})
        .to.throw('Invalid command argument: empty string')

      it 'should throw if command only contains whitespace', ->
        expect ->
          commands.parse('     ', {})
        .to.throw('Invalid command argument: empty string')

    describe 'given invalid options values', ->

      it 'should throw if no options', ->
        expect ->
          commands.parse('hello', null)
        .to.throw('Missing options argument')

      it 'should throw if options is not an object', ->
        expect ->
          commands.parse('hello', [ foo: 'bar' ])
        .to.throw('Invalid options argument: not an object')

        expect ->
          commands.parse('hello', 123)
        .to.throw('Invalid options argument: not an object')

    describe 'given a valid command', ->

      beforeEach ->
        @command = 'cd <%- destination %> && httrack <%- url %>'

      it 'should parse the command', ->
        options =
          destination: 'foo/bar'
          url: 'https://foobar.com'

        result = commands.parse(@command, options)
        expect(result).to.equal('cd foo/bar && httrack https://foobar.com')

  describe '.execute()', ->

    describe 'given invalid command values', ->

      it 'should throw if no command', ->
        expect ->
          commands.execute(null, _.noop)
        .to.throw('Missing command argument')

      it 'should throw if command is not a string', ->
        expect ->
          commands.execute(123, _.noop)
        .to.throw('Invalid command argument: 123')

      it 'should throw if command is an empty string', ->
        expect ->
          commands.execute('', _.noop)
        .to.throw('Invalid command argument: empty string')

      it 'should throw if command only contains whitespace', ->
        expect ->
          commands.execute('     ', _.noop)
        .to.throw('Invalid command argument: empty string')

    describe 'given invalid callback values', ->

      it 'should throw if no callback', ->
        expect ->
          commands.execute('command', null)
        .to.throw('Missing callback argument')

      it 'should throw if callback is not a function', ->
        expect ->
          commands.execute('command', [ _.noop ])
        .to.throw('Invalid callback argument: not a function')

    describe 'given the command runs correctly', ->

      beforeEach ->
        @childProcessExecStub = sinon.stub(child_process, 'exec')
        @childProcessExecStub.yields(null, 'stdout', null)

      afterEach ->
        @childProcessExecStub.restore()

      it 'should pass stdout to the callback', (done) ->
        commands.execute 'command', (error, output) ->
          expect(error).to.not.exist
          expect(output).to.equal('stdout')
          done()

    describe 'given the command logs to stderr', ->

      beforeEach ->
        @childProcessExecStub = sinon.stub(child_process, 'exec')
        @childProcessExecStub.yields(null, null, 'stderr')

      afterEach ->
        @childProcessExecStub.restore()

      it 'should wrap stderr in an Error and pass it to the callback', (done) ->
        commands.execute 'command', (error, output) ->
          expect(error).to.be.an.instanceof(Error)
          expect(error.message).to.equal('stderr')
          expect(output).to.not.exist
          done()

    describe 'given the command logs to stdout but stderr is an empty string', ->

      beforeEach ->
        @childProcessExecStub = sinon.stub(child_process, 'exec')
        @childProcessExecStub.yields(null, 'stdout', '')

      afterEach ->
        @childProcessExecStub.restore()

      it 'should pass stdout to the callback without any error', (done) ->
        commands.execute 'command', (error, output) ->
          expect(error).to.not.exist
          expect(output).to.equal('stdout')
          done()

    describe 'given the command returns an error', ->

      beforeEach ->
        @childProcessExecStub = sinon.stub(child_process, 'exec')
        @childProcessExecStub.yields(new Error('error'), null, null)

      afterEach ->
        @childProcessExecStub.restore()

      it 'should pass the error to the callback', (done) ->
        commands.execute 'command', (error, output) ->
          expect(error).to.be.an.instanceof(Error)
          expect(error.message).to.equal('error')
          expect(output).to.not.exist
          done()
