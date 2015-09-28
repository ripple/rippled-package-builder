import Events from '../lib/events'

module.exports = function() {

  return {

    github: function(req, res, next) {
      console.log('req.body', req.body)

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

