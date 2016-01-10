Promise = require('bluebird')
fs = Promise.promisifyAll(require('fs'))
lastRelease = require '@semantic-release/last-release-npm'


pkg = fs.readFileAsync './package.json', { encoding: 'utf-8' }
.then JSON.parse

version = Promise.props
  pkg: pkg
  npm:
    registry: 'https://registry.npmjs.org/'
    tag: 'latest'
    auth: undefined
.then (cfg) ->
  Promise.fromCallback (cb) ->
    lastRelease null, cfg, cb
.get 'version'
.catch (err) ->
  console.error err
  process.exitCode = 1

pkg = fs.readFileAsync './package.json', { encoding: 'utf-8' }
.then JSON.parse

module.exports = Promise.join pkg, version, (pkg, version) ->
  pkg.version = version
  return pkg
.then (pkg) ->
  fs.writeFileAsync './package.json', JSON.stringify(pkg, null, 2)
