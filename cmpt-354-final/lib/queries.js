const { client } = require('./client_db')
const prompts = require('prompts')
const q = require('./query')

// EXPORT FUNCTIONS
const init = async () => {
  // connect to DB
  await client.connect()
  // console.log('successfully connected')
}

const query = async (qVal) => {
  switch (qVal) {
    case 1: await q.Q1Q2(); break
    case 2: await q.Q3(); break
    case 3: await q.Q4(); break
    case 4: await q.Q5(); break
    case 5: await q.Q6(); break
    case 6: await q.Q7(); break
    default: break
  }

  // Return on enter
  return await prompts({
    type: 'password',
    name: 'value',
    message: 'Press return to go back to main menu',
  })
}

module.exports = { init, query }