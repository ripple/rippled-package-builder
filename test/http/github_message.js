var supertest = require('supertest')
var app  = require('../../processes/server')()
var http = supertest(app)
var assert = require('assert')

describe('MessagesController', function() {

  it('POST /github should return 200 success', function(done) {

    http.post('/github').end(function(error, resp) {
      assert(resp.body.success)
      done()
    })
  })
})
