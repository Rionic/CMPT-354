// Helpful functions
function arrStr(arr) {
  // returns array as "'el1', 'el2', 'el3'"...
  return "'" + arr.join("','") + "'"
}

function dateFormat(date) {
  return `${date.getFullYear()}-${date.getMonth()+1}-${date.getDate()}`
}

module.exports = { arrStr, dateFormat }