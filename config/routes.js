
module.exports = function(router, controllers) {
  router.post('/github', controllers.messages.github)

  router.get('/builds/rpm', controllers.builds.rpm)
}

