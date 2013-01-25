var Monarch = function() {
  return Monarch.setupConstructor.apply(Monarch, arguments);
};

if (typeof exports !== 'undefined') {
  module.exports = Monarch;
} else {
  window.Monarch = Monarch;
}
