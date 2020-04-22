const { client } = require('../client_db')
const { dateFormat } = require('../helpers')
const prompts = require('prompts')

const dateValid = async (date) => (
  (await client.query(`
    SELECT 1
    FROM meeting
    WHERE ('${dateFormat(date)}' BETWEEN date AND date + interval '1 day');
  `)).rows.length <= 0
)

async function Q7() {
  // Condition 1: Get valid date for new meeting
  const { date } = await prompts([{
    type: 'date',
    name: 'date',
    message: 'Select the date of meeting',
    initial: new Date(),
    mask: 'YYYY-MM-DD',
    validate: async (date) => {
      if (date < Date.now()) return 'Date must be in the future'
      if (!(await dateValid(date))) return 'Date is occupied by another meeting'
      else return true
    }
  }])

  // Condition 2: Get Calls where each call has available reviewers
  const callParams = await client.query(`
    SELECT DISTINCT C.id, title
    FROM call C 
    JOIN proposal P on P.callid = C.id
    JOIN review R on R.proposalid = P.id
    WHERE (
      '${dateFormat(date)}' NOT IN ( -- replace with date
        SELECT date 
        FROM meeting M JOIN participant PA ON PA.meetingid = M.id
        WHERE R.reviewerid = PA.reviewerid
      )
    )
    ORDER BY C.id;
  `)

  if (callParams.rows.length < 3)
    return console.log(`There are ${(callParams.rows.length) ? 
      `only ${callParams.rows.length}/3` : 'no'} available calls for this date. Please use a different date.`)

  const { calls } = await prompts([{
    type: 'multiselect',
    name: 'calls',
    message: 'Choose 3 calls of discussion',
    choices: callParams.rows.map((obj) => (
      { title: `${obj.title} (id: ${obj.id})`, value: obj.id }
    )),
    min: 3,
    max: 3,
    hint: '- Space to select / Return to submit',
    instructions: false
  }])

  // Step 3: Insert new meeting information
  const newMeeting = await client.query(`
    INSERT INTO meeting VALUES (DEFAULT, '${dateFormat(date)}') RETURNING *;
  `)

  const meetingid = newMeeting.rows[0].id
  const discussions = []
  for (const call of calls) {
    discussions.push(...(await client.query(`
      INSERT INTO discussion VALUES (DEFAULT, ${call}, ${meetingid}) RETURNING callid, meetingid;
    `)).rows)
  }

  const reviewers = await client.query(`
    INSERT INTO participant(reviewerid, meetingid, type)
    SELECT DISTINCT R.reviewerid, ${meetingid}, 'guest'::parttype
    FROM call C
    JOIN proposal P on P.callid = C.id
    JOIN review R on R.proposalid = P.id
    WHERE C.id = any(ARRAY[${calls}])
    RETURNING *;
  `)

  console.log('A new meeting has been created:')
  console.table(newMeeting.rows)

  console.log('\nwith discussions:')
  console.table(discussions)

  console.log('\nand participants:')
  console.table(reviewers.rows)
}

module.exports = { Q7 }