Binary = require "./binary"

class Difference extends Binary
  @delegate 'table', 'columns', to: 'left'

module.exports = Difference
