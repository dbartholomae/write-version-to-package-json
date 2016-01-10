chai = require 'chai'
chai.use require 'sinon-chai'
expect = chai.expect
sinon = require 'sinon'
domain = require 'domain'

proxyquire = require 'proxyquire'
mockFs = require 'mock-fs'

describe "write-version-to-package-json", ->
  lastRelease = null
  fs = null

  beforeEach ->
    fs = mockFs.fs()
    lastRelease = sinon.stub()

  afterEach ->
    mockFs.restore()

  it "writes the module's version to package.json", (done) ->
    # Setup
    pkg =
      name: "ModuleName"
    fs.writeFileSync './package.json', JSON.stringify pkg

    lastRelease.yields null, { version: "1.2.1" }

    # Run
    proxyquire '../lib/run.js',
      '@semantic-release/last-release-npm': lastRelease
      'fs': fs
    .then ->
      expect(lastRelease.args[0][1]).to.deep.equal
        pkg: pkg
        npm:
          registry: 'https://registry.npmjs.org/'
          tag: 'latest'
          auth: undefined

      expect(JSON.parse fs.readFileSync('./package.json', { encoding: 'utf-8' }))
      .to.deep.equal
        name: "ModuleName"
        version: "1.2.1"

      done()

  it "throws an error if anything goes wrong", (done) ->
    # Setup
    pkg =
      name: "ModuleName"
    fs.writeFileSync './package.json', JSON.stringify pkg

    lastRelease.yields "Some Error"

    proxyquire '../lib/run.js',
      '@semantic-release/last-release-npm': lastRelease
      'fs': fs
    .then ->
      expect(process.exitCode).to.equal 1
      done()
