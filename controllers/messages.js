import Events from '../lib/events'

module.exports = function(models, lib) {

  return {

    github: function(req, res, next) {
      let payload = req.body

      if (payload.rel === 'refs/heads/develop') {

        Events.emit('push:develop', payload)

      } else if (payload.action == 'published' && payload.release) {

        Events.emit('release', payload)
      }

      res.status(200)
    }
  }
}

