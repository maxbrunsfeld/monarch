var Monarch = function() {
  return Monarch.setupConstructor.apply(Monarch, arguments);
};

if (typeof exports !== 'undefined') {
  var _ = require("underscore");
  module.exports = Monarch;
} else {
  window.Monarch = Monarch;
}
