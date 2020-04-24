const prompts = require('prompts')
const figlet = require('figlet')
const clear = require('clear')
const queries = require('./lib/queries')

const { client } = require('./lib/client_db')

;(async () => {
  await queries.init()

  const intro = async () => {
    const title = figlet.textSync('Grant Track', { font: 'Varsity' })
    console.log(title)

    return await prompts({
      type: 'select',
      name: 'value',
      message: 'Pick a task to query',
      choices: [
        { title: '1. Get monthly competitions', description: 'Q1 & Q2', value: 1 },
        { title: '2. Get largest requested proposals', description: 'Q3', value: 2 },
        { title: '3. Get largest awarded proposals', description: 'Q4', value: 3 },
        { title: '4. Get largest average discrepancy proposals', description: 'Q5', value: 4 },
        { title: '5. Assign researcher proposal review', description: 'Q6', value: 5 },
        { title: '6. Schedule a competition meeting', description: 'Q7', value: 6 },
        { title: '7. Exit program', value: null },
      ]
    })
  }

  const runner = async () => {
    clear()
    const { value } = await intro()
    if (value == null) return client.end()
    else await queries.query(value)
    return runner()
  }
  runner()
})()