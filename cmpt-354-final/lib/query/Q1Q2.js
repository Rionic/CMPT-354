const { client } = require('../client_db')
const { arrStr } = require('../helpers')
const prompts = require('prompts')

async function Q1Q2() {
  // SQL calls to populate prompt selections
  const areas = await client.query(`SELECT DISTINCT area FROM call ORDER BY area`)
  const pis = await client.query(`
    SELECT firstname, lastname, R.id
    FROM collaborator C JOIN researcher R ON C.researcherid = R.id
    WHERE ispi = 'true'
    ORDER BY R.id
  `)

  const res = await prompts([
    {
      type: 'date',
      name: 'month',
      message: 'Select the month to filter',
      initial: new Date(2020, 00, 01),
      mask: 'MMMM'
    },
    {
      type: 'multiselect',
      name: 'area',
      message: 'Select area(s) of interest',
      choices: areas.rows.map((obj) => (
        { title: obj.area, value: obj.area }
      )),
      min: 1,
      hint: '- Space to select / "a" to Toggle all / Return to submit',
      instructions: false
    },
    {
      type: 'multiselect',
      name: 'pi',
      message: 'Select principle investigator(s)',
      choices: pis.rows.map((obj) => (
        { title: `${obj.lastname}, ${obj.firstname} (id: ${obj.id})`, value: obj.id }
      )),
      min: 1,
      hint: '- Space to select / "a" to Toggle all / Return to submit',
      instructions: false
    },
  ])
  
  const { month, area, pi } = res
  const query = await client.query(`
    WITH large_proposal AS (
      SELECT * 
      FROM proposal P
      WHERE (
        amount_requested >= 20000.00 OR
        (SELECT count(id) 
        FROM collaborator 
        WHERE proposalid = P.id) >= 10
      )
    )
    SELECT C.id AS callid, P.id AS proposalid, title
    FROM call C JOIN large_proposal P ON C.id = P.callid
    WHERE (
      EXTRACT(MONTH FROM call_date) = ${month.getMonth() + 1} AND -- replace with month
      area = any(ARRAY[${arrStr(area)}]) AND -- replace with area(s)
      pi = any(ARRAY[${pi}]) -- replace with private investigator(s) id
    );
  `)

  console.table(query.rows)
}

module.exports = { Q1Q2 }