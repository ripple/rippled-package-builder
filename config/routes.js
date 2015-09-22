
module.exports = function(router, controllers) {

  router.get('/', controllers.home.index)

  router.post('/messages', controllers.messages.receive)
}

