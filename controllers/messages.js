import Events from '../lib/events'

module.exports = function() {

  return {

    github: function(req, res, next) {

      let payload = req.body

      if (payload.ref === 'refs/heads/develop') {

        Events.emit('push:develop', payload)

      } else if (payload.ref === 'refs/heads/release') {

        Events.emit('push:release', payload)

      } else if (payload.ref === 'refs/heads/master') {

        Events.emit('push:master', payload)
      }

      res.status(200).json({
        success: true	
      })
    }
  }
}

