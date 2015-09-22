
module.exports = function(router, controllers) {

  router.get('/', controllers.home.index)

  router.post('/messages', controllers.messages.receive)
  router.post('/github', controllers.messages.github)
}

