
module.exports = function(models, lib) {

  return {
    receive: function(req, res, next) {
      console.log(req.body)

      res.status(200).send({
        success: true,
        message: 'Welcome to Bridges'
      })
    }
  }
}

