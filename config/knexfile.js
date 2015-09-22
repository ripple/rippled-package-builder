// Update with your config settings.

module.exports = {

  development: {
    client: process.env['DATABASE_DIALECT'],
    connection: {
      host     : process.env['DATABASE_HOST'],
      user     : process.env['DATABASE_USER'],
      password : process.env['DATABASE_PASSWORD'],
      database : process.env['DATABASE_NAME'],
      charset  : 'utf8'
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  },

  staging: {
    client: process.env['DATABASE_DIALECT'],
    connection: {
      host     : process.env['DATABASE_HOST'],
      user     : process.env['DATABASE_USER'],
      password : process.env['DATABASE_PASSWORD'],
      database : process.env['DATABASE_NAME'],
      charset  : 'utf8'
    },
    pool: {
      min: 2,
      max: 10
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  },

  production: {
    client: process.env['DATABASE_DIALECT'],
    connection: {
      host     : process.env['DATABASE_HOST'],
      user     : process.env['DATABASE_USER'],
      password : process.env['DATABASE_PASSWORD'],
      database : process.env['DATABASE_NAME'],
      charset  : 'utf8'
    },
    pool: {
      min: 2,
      max: 10
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  }

};
