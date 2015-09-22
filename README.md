# Bridges Application

Welcome to the Bridges Nodejs application framework!

Bridges is based on a process model running multiple
processes concurrently and HTTP / JSON apis with Express.js

Babel provides built-in ECMAScript6 language support for
legacy nodejs ES5 systems.

## Tests

Tests are written the the `/tests` directory using the
mocha testing framework. Run the tests with the following:

````
npm run test
````

## Usage

````
npm run start
````

## Processes

When bridges starts up the application each file under
`/processes` is started up concurrently. These are meant
to be long-running processes.

## Routes

To extend the HTTP interafce add routes using the express
route syntax in `/config/routes.js`.

## Controllers

The router is passed each controller in the `/controllers`
directory. Controllers handle the http request/response
lifecycle for your application's HTTP endpoints.

