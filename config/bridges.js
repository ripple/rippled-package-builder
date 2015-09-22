require("babel/polyfill");

global['Bridges'] = {
  logger: require('winston')
}

function capitalize(str) {
    return str.substr(0, 1).toUpperCase() + str.substr(1);
}

var Application = require('bridges-application')
var path        = require('path')
var requireAll  = require('require-all-to-camel')
var models      = requireAll(__dirname+'/../models')
var lib         = requireAll(__dirname+'/../lib')

for (var key in models) {
  global[capitalize(key)] = models[key]
}

for (var key in lib) {
  global[capitalize(key)] = lib[key]
}

var application = new Application({
  directory : path.join(__dirname, '..'),
  processes : {
    inject: [models, lib]
  }
})

application.supervisor.start()
