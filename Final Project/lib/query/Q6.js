const { client } = require('../client_db')
const prompts = require('prompts')

async function Q6() {
  const propid = await client.query(`SELECT id FROM proposal`)
  const { pid } = await prompts({ 
    type: 'select',
    name: 'pid',
    message: 'Select a proposal ID to review',
    choices: propid.rows.map((obj) => (
      { title: obj.id, value: obj.id }
    )),
    initial: 0
  })

  const revlist = await client.query(`
    SELECT reviewerid
    FROM review

    EXCEPT

    SELECT DISTINCT(reviewerid)
    FROM(
        SELECT *
        FROM (SELECT *
          FROM conflict c JOIN (
              SELECT reviewerid, proposalid, pi
              FROM proposal p JOIN review r ON r.proposalid = p.id
              WHERE proposalid = ${pid} -- Replace 1 with user's proposal entry
            ) pr 
            ON pr.pi = c.researcher1
          UNION
          SELECT *
          FROM conflict c JOIN (
            SELECT reviewerid, proposalid, pi
            FROM proposal p JOIN review r ON r.proposalid = p.id
            WHERE proposalid = ${pid} -- Replace 1 with user's proposal entry
          ) pr
      ON pr.pi = c.researcher2) pru
    WHERE researcher1 = reviewerid AND researcher2 = pi
    OR researcher2 = reviewerid AND researcher1 = pi) pru2

    EXCEPT

    -- Filter out reviewers with 3 or more reviews
    SELECT reviewerid
    FROM review
    GROUP BY reviewerid
    HAVING count(*) > 2

    EXCEPT

    -- Filter out reviewers who review their own proposal
    SELECT reviewerid
    FROM review JOIN conflict ON reviewerid = researcher1
    WHERE researcher1 = researcher2
  `)

  if (revlist.rows.length <= 0)
    return console.log('There are no suitable reviewers available.')

  const req = await prompts({
    type: 'multiselect',
    name: 'reviewers',
    message: 'Here is a list of non-conflicting reviewers.\n Select any to assign.',
    choices:  revlist.rows.map((obj) => (
      { title: obj.reviewerid, value: obj.reviewerid })),
    initial: 0,
    hint: '- Space to select / "a" to Toggle all / Return to submit',
    instructions: false
  })

  const { reviewers } = req
  const reviews = []

  for (let i = 0; i < reviewers.length; i++) {
    reviews.push(...(await client.query(`
      INSERT INTO review VALUES
      (DEFAULT,${reviewers[i]},${pid},now() + interval '2 week','f', NULL)
      RETURNING *;
    `)).rows)
  }

  console.log('Reviewers have been assigned:')
  console.table(reviews)
}

module.exports = { Q6 }