const { client } = require('../client_db')
const prompts = require('prompts')

async function Q5() {
  const areas = await client.query(`SELECT DISTINCT area FROM call ORDER BY area`)

  const { area } = await prompts({
    type: 'select',
    name: 'area',
    message: 'Select area of interest',
    choices: areas.rows.map((obj) => (
      { title: obj.area, value: obj.area }
    ))
  })

  const query = await client.query(`
    SELECT C.area, avg(abs(amount_requested - amount_awarded)) AS discrepancy
    FROM proposal P JOIN call C on C.id=P.id
    WHERE area = '${area}' -- replace with area
    GROUP BY C.area;
  `)

  console.table(query.rows)
}

module.exports = { Q5 }