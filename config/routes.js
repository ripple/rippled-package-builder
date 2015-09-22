
module.exports = function(router, controllers) {

  router.get('/', controllers.home.index)
}

