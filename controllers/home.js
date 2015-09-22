
module.exports = function(models, lib) {

  return {
    index: function(req, res, next) {
      res.status(200).send({
        success: true,
        message: 'Welcome to Bridges'
      })
    }
  }
}

