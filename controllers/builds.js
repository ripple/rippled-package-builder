import {RPMBuilds} from '../lib/s3'

module.exports = function() {

  return {

    rpm: function(req, res, next) {

      RPMBuilds().then(function(builds) {
        res.status(200).json({
          success: true,
          builds: builds
        })
      })
      .catch(function(error) {
        res.status(500).json({
          success: false,
          error: error,
        })
      })
    }
  }
}

