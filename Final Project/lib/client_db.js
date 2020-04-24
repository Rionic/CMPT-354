const dotenv = require('dotenv')
const { Client } = require('pg')

dotenv.config()

const options = {
  user: process.env.USER,
  password: process.env.PASS,
  host: process.env.HOST,
  port: process.env.PORT,
  database: process.env.DB,
}

if (process.env.SSL === 'true') options.ssl = { rejectUnauthorized: false }
const client = new Client(options)

module.exports = { client }