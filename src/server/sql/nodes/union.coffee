Binary = require "./binary"

class Union extends Binary
  @delegate 'table', 'columns', to: 'left'

module.exports = Union
