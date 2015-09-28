class GithubEvent {
  constructor(payload) {
    this.payload = payload
  }
}

class PushEvent extends GithubEvent {

  toString() {

    return {
      type: 'PushEvent',
      rel: this.payload.rel,
    }
  }
}

class ReleaseEvent extends GithubEvent {

  toString() {
    return {
      type: 'ReleaseEvent'
    }
  }
}

class PullRequestEvent extends GithubEvent {
  toString() {
    var merged

    if (this.payload.action === 'closed' && this.payload.pull_request.merged) {
      merged = true 
    } else {
      merged = false
    }

    return {
      type: 'PullRequestEvent',
      merged: false
    }
  }
}

function parseEvent(payload) {
  if (payload.ref) {
    return new PushEvent(payload)
  } else if (payload.action == 'released' && payload.release) {
    return new ReleaseEvent(payload)
  } else if (payload.pull_request) {
    return new PullRequestEvent(payload)
  }
}

module.exports = function(models, lib) {

  return {
    receive: function(req, res, next) {
      console.log(req.body)

      res.status(200).send({
        success: true,
        message: 'Welcome to Bridges'
      })
    },

    github: function(req, res, next) {
      console.log(req.body)
      var event = parseEvent(req.body)

      if (event) {
        console.log(event.toString())
        console.log(req.body)
      }

      res.status(200).send({
        success: true,
        message: 'Welcome to Bridges'
      })
    }

  }
}

