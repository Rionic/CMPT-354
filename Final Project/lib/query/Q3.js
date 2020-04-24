const { client } = require('../client_db')
const { arrStr } = require('../helpers')
const prompts = require('prompts')

async function Q3() {
  const areas = await client.query(`SELECT DISTINCT area FROM call ORDER BY area`)

  const { area } = await prompts([{
      type: 'multiselect',
      name: 'area',
      message: 'Select area(s) of interest',
      choices: areas.rows.map((obj) => (
        { title: obj.area, value: obj.area }
      )),
      min: 1,
      hint: '- Space to select / "a" to Toggle all / Return to submit',
      instructions: false
    }
  ])

  const query = await client.query(`
    SELECT *
    FROM proposal P
    WHERE (
      EXISTS (
        SELECT 1 FROM call C 
        WHERE (
          C.id = P.callid AND
          C.area = any(ARRAY[${arrStr(area)}]) -- replace with area
        )
      ) AND
      
      amount_requested = (
        SELECT max(amount_requested) FROM proposal
      )
    );
  `)
  
  console.table(query.rows)
}

module.exports = { Q3 }