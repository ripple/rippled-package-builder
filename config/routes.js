
module.exports = function(router, controllers) {
  router.post('/github', controllers.messages.github)
}

