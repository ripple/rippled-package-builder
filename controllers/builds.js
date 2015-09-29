
module.exports = function() {

  return {

    rpm: function(req, res, next) {

      res.status(200).json({
        success: true,
        builds: [
        ] 
      })
    }
  }
}

