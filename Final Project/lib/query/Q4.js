const { client } = require('../client_db')
const { dateFormat } = require('../helpers')
const prompts = require('prompts')

async function Q4() {
  const { date } = await prompts({
    type: 'date',
    name: 'date',
    message: 'Include only proposals before',
    initial: new Date(2020, 02, 01),
    mask: 'YYYY-MM-DD'
  })

  const query = await client.query(`
    SELECT id, amount_awarded, proposal_date
    FROM proposal P
    WHERE (
      proposal_date < '${dateFormat(date)}' AND -- replace with date
      amount_awarded = (SELECT max(amount_awarded) FROM proposal)
    );
  `)

  console.table(query.rows)
}

module.exports = { Q4 }