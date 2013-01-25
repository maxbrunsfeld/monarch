var Monarch = function() {
  return Monarch.setupConstructor.apply(Monarch, arguments);
};

if (typeof exports !== 'undefined') {
  module.exports = Monarch;
} else {
  window.Monarch = Monarch;
}

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _.extend(Monarch, {
    fetchUrl: '/sandbox',
    resourceUrlRoot: '',
    resourceUrlSeparator: '-',
    snakeCase: false,
    setupConstructor: function(constructor, columnDefinitions) {
      __extends(constructor, Monarch.Record);
      constructor.extended(constructor);
      if (columnDefinitions) {
        return constructor.columns(columnDefinitions);
      }
    },
    Expressions: {},
    Relations: {},
    Remote: {},
    Util: {}
  });

}).call(this);

(function() {
  var __slice = [].slice;

  Monarch.Util.Deferrable = (function() {

    function Deferrable() {
      this._deferrableNodes = {};
      this._deferrableData = {};
      this._deferrableTriggerred = {};
    }

    Deferrable.prototype.onSuccess = function(callback, context) {
      return this.on('success', callback, context);
    };

    Deferrable.prototype.success = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.onSuccess.apply(this, args);
    };

    Deferrable.prototype.onInvalid = function(callback, context) {
      return this.on('invalid', callback, context);
    };

    Deferrable.prototype.onError = function(callback, context) {
      return this.on('error', callback, context);
    };

    Deferrable.prototype.triggerSuccess = function() {
      return this.trigger('success', arguments);
    };

    Deferrable.prototype.triggerInvalid = function() {
      return this.trigger('invalid', arguments);
    };

    Deferrable.prototype.triggerError = function() {
      return this.trigger('error', arguments);
    };

    Deferrable.prototype.on = function(eventName, callback, context) {
      var node, _base, _ref;
      if (this._deferrableTriggerred[eventName] != null) {
        callback.apply(context, this._deferrableData[eventName]);
      } else {
        node = ((_ref = (_base = this._deferrableNodes)[eventName]) != null ? _ref : _base[eventName] = new Monarch.Util.Node());
        node.subscribe(callback, context);
      }
      return this;
    };

    Deferrable.prototype.trigger = function(eventName, data) {
      var _ref;
      this._deferrableTriggerred[eventName] = true;
      this._deferrableData[eventName] = data;
      return (_ref = this._deferrableNodes[eventName]) != null ? _ref.publishArgs(data) : void 0;
    };

    return Deferrable;

  })();

}).call(this);

(function() {
  var isHash, rules;

  rules = {
    plural: [[/(quiz)$/i, "$1zes"], [/^(ox)$/i, "$1en"], [/([m|l])ouse$/i, "$1ice"], [/(matr|vert|ind)ix|ex$/i, "$1ices"], [/(x|ch|ss|sh)$/i, "$1es"], [/([^aeiouy]|qu)y$/i, "$1ies"], [/(hive)$/i, "$1s"], [/(?:([^f])fe|([lr])f)$/i, "$1$2ves"], [/sis$/i, "ses"], [/([ti])um$/i, "$1a"], [/(buffal|tomat)o$/i, "$1oes"], [/(bu)s$/i, "$1ses"], [/(alias|status)$/i, "$1es"], [/(octop|vir)us$/i, "$1i"], [/(ax|test)is$/i, "$1es"], [/s$/i, "s"], [/$/, "s"]],
    singular: [[/(quiz)zes$/i, "$1"], [/(matr)ices$/i, "$1ix"], [/(vert|ind)ices$/i, "$1ex"], [/^(ox)en/i, "$1"], [/(alias|status)es$/i, "$1"], [/(octop|vir)i$/i, "$1us"], [/(cris|ax|test)es$/i, "$1is"], [/(shoe)s$/i, "$1"], [/(o)es$/i, "$1"], [/(bus)es$/i, "$1"], [/([m|l])ice$/i, "$1ouse"], [/(x|ch|ss|sh)es$/i, "$1"], [/(m)ovies$/i, "$1ovie"], [/(s)eries$/i, "$1eries"], [/([^aeiouy]|qu)ies$/i, "$1y"], [/([lr])ves$/i, "$1f"], [/(tive)s$/i, "$1"], [/(hive)s$/i, "$1"], [/([^f])ves$/i, "$1fe"], [/(^analy)ses$/i, "$1sis"], [/((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$/i, "$1$2sis"], [/([ti])a$/i, "$1um"], [/(n)ews$/i, "$1ews"], [/s$/i, ""]],
    irregular: [['move', 'moves'], ['sex', 'sexes'], ['child', 'children'], ['man', 'men'], ['person', 'people']],
    uncountable: ["sheep", "fish", "series", "species", "money", "rice", "information", "equipment"]
  };

  Monarch.Util.Inflection = {
    pluralize: function(word) {
      var i, plural, regex, replaceString, singular, uncountable, _i, _j, _k, _ref, _ref1, _ref2;
      for (i = _i = 0, _ref = rules.uncountable.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        uncountable = rules.uncountable[i];
        if (word.toLowerCase() === uncountable) {
          return uncountable;
        }
      }
      for (i = _j = 0, _ref1 = rules.irregular.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
        singular = rules.irregular[i][0];
        plural = rules.irregular[i][1];
        if (word.toLowerCase() === singular || word === plural) {
          return plural;
        }
      }
      for (i = _k = 0, _ref2 = rules.plural.length; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; i = 0 <= _ref2 ? ++_k : --_k) {
        regex = rules.plural[i][0];
        replaceString = rules.plural[i][1];
        if (regex.test(word)) {
          return word.replace(regex, replaceString);
        }
      }
    },
    singularize: function(word) {
      var i, plural, regex, replaceString, singular, uncountable, _i, _j, _k, _ref, _ref1, _ref2;
      for (i = _i = 0, _ref = rules.uncountable.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        uncountable = rules.uncountable[i];
        if (word.toLowerCase() === uncountable) {
          return uncountable;
        }
      }
      for (i = _j = 0, _ref1 = rules.irregular.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
        singular = rules.irregular[i][0];
        plural = rules.irregular[i][1];
        if (word.toLowerCase() === singular || word === plural) {
          return plural;
        }
      }
      for (i = _k = 0, _ref2 = rules.singular.length; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; i = 0 <= _ref2 ? ++_k : --_k) {
        regex = rules.singular[i][0];
        replaceString = rules.singular[i][1];
        if (regex.test(word)) {
          return word.replace(regex, replaceString);
        }
      }
    },
    underscore: function(word) {
      return word.replace(/([a-zA-Z\d])([A-Z])/g, '$1_$2').toLowerCase();
    },
    camelize: function(word) {
      var camelized, firstLetter, i, part, parts, _i, _len;
      camelized = [];
      parts = word.split(/[_-]/);
      for (i = _i = 0, _len = parts.length; _i < _len; i = ++_i) {
        part = parts[i];
        firstLetter = i === 0 ? part.charAt(0) : part.charAt(0).toUpperCase();
        parts[i] = firstLetter + part.substring(1);
      }
      return parts.join('');
    },
    underscoreAndPluralize: function(word) {
      return Monarch.Util.Inflection.underscore(Monarch.Util.Inflection.pluralize(word));
    },
    capitalize: function(word) {
      return word.charAt(0).toUpperCase() + word.substr(1);
    },
    uncapitalize: function(word) {
      return word.charAt(0).toLowerCase() + word.substr(1);
    },
    convertKeysToSnakeCase: function(data) {
      var convertedData, key, value;
      convertedData = {};
      for (key in data) {
        value = data[key];
        if (isHash(value)) {
          value = Monarch.Util.Inflection.convertKeysToSnakeCase(value);
        }
        convertedData[Monarch.Util.Inflection.underscore(key)] = value;
      }
      return convertedData;
    },
    convertKeysToCamelCase: function(data) {
      var convertedData, key, value;
      convertedData = {};
      for (key in data) {
        value = data[key];
        if (isHash(value)) {
          value = Monarch.Util.Inflection.convertKeysToCamelCase(value);
        }
        convertedData[Monarch.Util.Inflection.camelize(key, true)] = value;
      }
      return convertedData;
    }
  };

  isHash = function(obj) {
    return _.isObject(obj) && !_.isArray(obj);
  };

}).call(this);

(function() {

  Monarch.Util.Node = (function() {

    function Node() {
      this.clear();
    }

    Node.prototype.clear = function() {
      return this.subscriptions = [];
    };

    Node.prototype.publish = function() {
      return this.publishArgs(arguments);
    };

    Node.prototype.publishArgs = function(args) {
      var subscription, _i, _len, _ref, _results;
      _ref = this.subscriptions;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        subscription = _ref[_i];
        _results.push(subscription.publish(args));
      }
      return _results;
    };

    Node.prototype.subscribe = function(callback, context) {
      var subscription;
      subscription = new Monarch.Util.Subscription(callback, context, this);
      this.subscriptions.push(subscription);
      return subscription;
    };

    Node.prototype.unsubscribe = function(subscription) {
      var index, _ref;
      index = this.subscriptions.indexOf(subscription);
      if (index !== -1) {
        this.subscriptions.splice(index, 1);
      }
      if (this.size() === 0) {
        return (_ref = this.emptyNode) != null ? _ref.publish() : void 0;
      }
    };

    Node.prototype.onEmpty = function(callback, context) {
      var _ref;
      if ((_ref = this.emptyNode) == null) {
        this.emptyNode = new Monarch.Util.Node();
      }
      return this.emptyNode.subscribe(callback, context);
    };

    Node.prototype.length = function() {
      return this.subscriptions.length;
    };

    Node.prototype.size = function() {
      return this.subscriptions.length;
    };

    return Node;

  })();

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Util.Promise = (function(_super) {

    __extends(Promise, _super);

    function Promise() {
      return Promise.__super__.constructor.apply(this, arguments);
    }

    return Promise;

  })(Monarch.Util.Deferrable);

}).call(this);

(function() {
  var __slice = [].slice;

  Monarch.Util.Signal = (function() {

    function Signal(sources, transformer) {
      var i, sourceName, _i, _len, _ref, _ref1;
      this.sources = sources;
      this.transformer = transformer;
      if (!_.isArray(this.sources)) {
        this.sources = [this.sources];
      }
      if ((_ref = this.transformer) == null) {
        this.transformer = function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return args.join(' ');
        };
      }
      this.changeNode = new Monarch.Util.Node();
      _ref1 = this.sources;
      for (i = _i = 0, _len = _ref1.length; _i < _len; i = ++_i) {
        sourceName = _ref1[i];
        this.subscribeToSource(sourceName, i);
      }
    }

    Signal.prototype.subscribeToSource = function(source, index) {
      var _this = this;
      return source.onChange(function(newValue, oldValue) {
        var newSourceValues, oldSourceValues;
        newSourceValues = _this.getSourceValues();
        oldSourceValues = _.clone(newSourceValues);
        oldSourceValues[index] = oldValue;
        return _this.publishChange(newSourceValues, oldSourceValues);
      });
    };

    Signal.prototype.publishChange = function(newSourceValues, oldSourceValues) {
      var newValue, oldValue;
      newValue = this.transformer.apply(this, newSourceValues);
      oldValue = this.transformer.apply(this, oldSourceValues);
      return this.changeNode.publish(newValue, oldValue);
    };

    Signal.prototype.getValue = function() {
      return this.transformer.apply(this, this.getSourceValues());
    };

    Signal.prototype.getSourceValues = function() {
      return _.map(this.sources, function(source) {
        return source.getValue();
      });
    };

    Signal.prototype.onChange = function(callback, context) {
      return this.changeNode.subscribe(callback, context);
    };

    return Signal;

  })();

}).call(this);

(function() {

  Monarch.Util.Subscription = (function() {

    function Subscription(callback, context, node) {
      this.callback = callback;
      this.context = context;
      this.node = node;
    }

    Subscription.prototype.publish = function(args) {
      return this.callback.apply(this.context, args);
    };

    Subscription.prototype.destroy = function() {
      return this.node.unsubscribe(this);
    };

    return Subscription;

  })();

}).call(this);

(function() {

  Monarch.Util.SubscriptionBundle = (function() {

    function SubscriptionBundle() {
      this.subscriptions = [];
    }

    SubscriptionBundle.prototype.add = function(subscription) {
      return this.subscriptions.push(subscription);
    };

    SubscriptionBundle.prototype.destroy = function() {
      var subscription, _i, _len, _ref;
      _ref = this.subscriptions;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        subscription = _ref[_i];
        subscription.destroy();
      }
      return this.subscriptions = [];
    };

    return SubscriptionBundle;

  })();

}).call(this);

(function() {

  _.mixin({
    sum: function(array) {
      var element, sum, _i, _len;
      sum = 0;
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        element = array[_i];
        sum += element;
      }
      return sum;
    }
  });

}).call(this);

(function() {
  var __slice = [].slice;

  Monarch.Base = (function() {
    var capitalize;

    function Base() {}

    Base.deriveEquality = function() {
      var properties;
      properties = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.prototype.isEqual = function(other) {
        var property, _i, _len;
        if (!(other instanceof this.constructor)) {
          return false;
        }
        for (_i = 0, _len = properties.length; _i < _len; _i++) {
          property = properties[_i];
          if (!_.isEqual(this[property], other[property])) {
            return false;
          }
        }
        return true;
      };
    };

    Base.delegate = function() {
      var methodName, methodNames, to, _arg, _i, _j, _len, _results,
        _this = this;
      methodNames = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), _arg = arguments[_i++];
      to = _arg.to;
      _results = [];
      for (_j = 0, _len = methodNames.length; _j < _len; _j++) {
        methodName = methodNames[_j];
        _results.push((function(methodName) {
          return _this.prototype[methodName] = function() {
            var args, _ref;
            args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            return (_ref = this[to])[methodName].apply(_ref, args);
          };
        })(methodName));
      }
      return _results;
    };

    capitalize = Monarch.Util.Inflection.capitalize;

    Base.accessors = function() {
      var methodName, methodNames, _i, _len, _results,
        _this = this;
      methodNames = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _results = [];
      for (_i = 0, _len = methodNames.length; _i < _len; _i++) {
        methodName = methodNames[_i];
        _results.push((function(methodName) {
          var memoizedName, setterName;
          setterName = "set" + capitalize(methodName);
          memoizedName = "_" + methodName;
          _this.prototype[methodName] = function(value) {
            return this[memoizedName];
          };
          return _this.prototype[setterName] = function(value) {
            return this[memoizedName] = value;
          };
        })(methodName));
      }
      return _results;
    };

    Base.reopen = function(f) {
      var prototypeProperties;
      prototypeProperties = f.call(this);
      return _.extend(this.prototype, prototypeProperties);
    };

    return Base;

  })();

}).call(this);

(function() {

  Monarch.Field = (function() {

    function Field(record, column) {
      this.record = record;
      this.column = column;
      this.name = this.column.name;
      this.changeNode = new Monarch.Util.Node();
    }

    Field.prototype.setValue = function(newValue) {
      var oldValue;
      oldValue = this.value;
      newValue = this.column.normalizeValue(newValue);
      this.value = newValue;
      if (!_.isEqual(newValue, oldValue)) {
        this.valueChanged(newValue, oldValue);
        this.changeNode.publish(newValue, oldValue);
      }
      return newValue;
    };

    Field.prototype.getValue = function() {
      return this.value;
    };

    Field.prototype.wireRepresentation = function() {
      return this.column.valueWireRepresentation(this.getValue());
    };

    Field.prototype.signal = function(transformer) {
      return new Monarch.Util.Signal(this, transformer);
    };

    Field.prototype.onChange = function(callback, context) {
      return this.changeNode.subscribe(callback, context);
    };

    return Field;

  })();

}).call(this);

(function() {

  Monarch.SyntheticField = (function() {

    function SyntheticField(record, column) {
      this.record = record;
      this.column = column;
      this.name = column.name;
      this.signal = column.definition.call(record);
    }

    SyntheticField.prototype.getValue = function() {
      return this.signal.getValue();
    };

    SyntheticField.prototype.isDirty = function() {
      return false;
    };

    SyntheticField.prototype.onChange = function(callback, context) {
      return this.signal.onChange(callback, context);
    };

    return SyntheticField;

  })();

}).call(this);

(function() {

  Monarch.CompositeTuple = (function() {

    function CompositeTuple(left, right) {
      this.left = left;
      this.right = right;
    }

    CompositeTuple.prototype.getField = function(name) {
      return this.left.getField(name) || this.right.getField(name);
    };

    CompositeTuple.prototype.getFieldValue = function(name) {
      return this.getField(name).getValue();
    };

    CompositeTuple.prototype.getRecord = function(tableName) {
      return this.left.getRecord(tableName) || this.right.getRecord(tableName);
    };

    CompositeTuple.prototype.toString = function() {
      return "<" + this.constructor.displayName + " left:" + this.left.toString() + " right:" + this.right.toString() + ">";
    };

    return CompositeTuple;

  })();

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Expressions.Predicate = (function(_super) {

    __extends(Predicate, _super);

    Predicate.deriveEquality('left', 'right');

    Predicate.forSymbol = function(symbol) {
      return {
        '<': Monarch.Expressions.LessThan,
        '<=': Monarch.Expressions.LessThanOrEqual,
        '>': Monarch.Expressions.GreaterThan,
        '>=': Monarch.Expressions.GreaterThanOrEqual
      }[symbol];
    };

    function Predicate(left, right) {
      this.left = left;
      this.right = right;
    }

    Predicate.prototype.evaluate = function(tuple) {
      var leftValue, rightValue;
      leftValue = this.evaluateOperand(this.left, tuple);
      rightValue = this.evaluateOperand(this.right, tuple);
      return this.operator(leftValue, rightValue);
    };

    Predicate.prototype.evaluateOperand = function(operand, tuple) {
      if (operand instanceof Monarch.Expressions.Column) {
        return tuple.getFieldValue(operand.qualifiedName);
      } else {
        return operand;
      }
    };

    Predicate.prototype.resolve = function(relation) {
      return new this.constructor(this.resolveOperand(this.left, relation), this.resolveOperand(this.right, relation));
    };

    Predicate.prototype.resolveOperand = function(operand, relation) {
      if (_.isString(operand)) {
        return relation.getColumn(operand) || operand;
      } else {
        return operand;
      }
    };

    Predicate.prototype.and = function(otherPredicate) {
      return new Monarch.Expressions.And(this, otherPredicate);
    };

    Predicate.prototype.wireRepresentation = function() {
      return {
        type: this.wireRepresentationType,
        leftOperand: this.operandWireRepresentation(this.left),
        rightOperand: this.operandWireRepresentation(this.right)
      };
    };

    Predicate.prototype.operandWireRepresentation = function(operand) {
      if (operand && _.isFunction(operand.wireRepresentation)) {
        return operand.wireRepresentation();
      } else {
        return {
          type: 'Scalar',
          value: operand
        };
      }
    };

    return Predicate;

  })(Monarch.Base);

}).call(this);

(function() {

  Monarch.Expressions.Column = (function() {

    function Column(table, name, type) {
      this.table = table;
      this.name = name;
      this.type = type;
      this.qualifiedName = this.table.name + "." + this.name;
    }

    Column.prototype.buildLocalField = function(record) {
      return new Monarch.LocalField(record, this);
    };

    Column.prototype.buildRemoteField = function(record) {
      return new Monarch.RemoteField(record, this);
    };

    Column.prototype.eq = function(right) {
      return new Monarch.Expressions.Equal(this, right);
    };

    Column.prototype.wireRepresentation = function() {
      return {
        type: 'Column',
        table: this.table.resourceName(),
        name: this.resourceName()
      };
    };

    Column.prototype.resourceName = function() {
      return Monarch.Util.Inflection.underscore(this.name).replace(/_/g, Monarch.resourceUrlSeparator);
    };

    Column.prototype.normalizeValue = function(value) {
      if (this.type === 'datetime' && _.isNumber(value)) {
        return new Date(value);
      } else {
        return value;
      }
    };

    Column.prototype.valueWireRepresentation = function(value) {
      var _ref;
      if (this.type === 'datetime' && value) {
        return (_ref = value != null ? value.getTime() : void 0) != null ? _ref : value;
      } else {
        return value;
      }
    };

    return Column;

  })();

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Expressions.And = (function(_super) {

    __extends(And, _super);

    function And() {
      return And.__super__.constructor.apply(this, arguments);
    }

    And.prototype.wireRepresentationType = 'And';

    And.prototype.evaluate = function(tuple) {
      return this.left.evaluate(tuple) && this.right.evaluate(tuple);
    };

    And.prototype.satisfyingAttributes = function() {
      return _.extend(this.left.satisfyingAttributes(), this.right.satisfyingAttributes());
    };

    And.prototype.resolve = function(relation) {
      return new this.constructor(relation.resolvePredicate(this.left), relation.resolvePredicate(this.right));
    };

    return And;

  })(Monarch.Expressions.Predicate);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Expressions.Equal = (function(_super) {

    __extends(Equal, _super);

    function Equal() {
      return Equal.__super__.constructor.apply(this, arguments);
    }

    Equal.prototype.wireRepresentationType = 'Equal';

    Equal.prototype.operator = function(left, right) {
      return _.isEqual(left, right);
    };

    Equal.prototype.satisfyingAttributes = function() {
      var attributes;
      attributes = {};
      attributes[this.left.name] = this.right;
      return attributes;
    };

    Equal.prototype.isEqual = function(other) {
      if (!(other instanceof this.constructor)) {
        return false;
      }
      if (_.isEqual(this.left, other.left) && _.isEqual(this.right, other.right)) {
        return true;
      }
      if (_.isEqual(this.left, other.right) && _.isEqual(this.right, other.left)) {
        return true;
      }
      return false;
    };

    return Equal;

  })(Monarch.Expressions.Predicate);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Expressions.GreaterThan = (function(_super) {

    __extends(GreaterThan, _super);

    function GreaterThan() {
      return GreaterThan.__super__.constructor.apply(this, arguments);
    }

    GreaterThan.prototype.wireRepresentationType = 'GreaterThan';

    GreaterThan.prototype.operator = function(left, right) {
      return left > right;
    };

    return GreaterThan;

  })(Monarch.Expressions.Predicate);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Expressions.GreaterThanOrEqual = (function(_super) {

    __extends(GreaterThanOrEqual, _super);

    function GreaterThanOrEqual() {
      return GreaterThanOrEqual.__super__.constructor.apply(this, arguments);
    }

    GreaterThanOrEqual.prototype.wireRepresentationType = 'GreaterThanOrEqual';

    GreaterThanOrEqual.prototype.operator = function(left, right) {
      return left >= right;
    };

    return GreaterThanOrEqual;

  })(Monarch.Expressions.Predicate);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Expressions.LessThan = (function(_super) {

    __extends(LessThan, _super);

    function LessThan() {
      return LessThan.__super__.constructor.apply(this, arguments);
    }

    LessThan.prototype.wireRepresentationType = 'LessThan';

    LessThan.prototype.operator = function(left, right) {
      return left < right;
    };

    return LessThan;

  })(Monarch.Expressions.Predicate);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Expressions.LessThanOrEqual = (function(_super) {

    __extends(LessThanOrEqual, _super);

    function LessThanOrEqual() {
      return LessThanOrEqual.__super__.constructor.apply(this, arguments);
    }

    LessThanOrEqual.prototype.wireRepresentationType = 'LessThanOrEqual';

    LessThanOrEqual.prototype.operator = function(left, right) {
      return left <= right;
    };

    return LessThanOrEqual;

  })(Monarch.Expressions.Predicate);

}).call(this);

(function() {

  Monarch.Expressions.OrderBy = (function() {

    function OrderBy(relation, string) {
      var parts;
      parts = string.split(/\s+/);
      this.column = relation.getColumn(parts[0]);
      this.columnName = this.column.qualifiedName;
      this.directionCoefficient = parts[1] === "desc" ? -1 : 1;
    }

    return OrderBy;

  })();

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Expressions.SyntheticColumn = (function(_super) {

    __extends(SyntheticColumn, _super);

    function SyntheticColumn(table, name, definition) {
      this.table = table;
      this.name = name;
      this.definition = definition;
    }

    SyntheticColumn.prototype.buildLocalField = function(record) {
      return new Monarch.LocalSyntheticField(record, this);
    };

    SyntheticColumn.prototype.buildRemoteField = function(record) {
      return new Monarch.RemoteSyntheticField(record, this);
    };

    return SyntheticColumn;

  })(Monarch.Expressions.Column);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  Monarch.Relations.Relation = (function(_super) {

    __extends(Relation, _super);

    function Relation() {
      return Relation.__super__.constructor.apply(this, arguments);
    }

    Relation.prototype.size = function() {
      return this.all().length;
    };

    Relation.prototype.isEmpty = function() {
      return this.all().length === 0;
    };

    Relation.prototype.contains = function(tuple) {
      return this.indexOf(tuple) !== -1;
    };

    Relation.prototype.find = function(idOrPredicate) {
      var predicate;
      predicate = _.isObject(idOrPredicate) ? idOrPredicate : {
        id: idOrPredicate
      };
      return this.where(predicate).first();
    };

    Relation.prototype.first = function() {
      return this.all()[0];
    };

    Relation.prototype.last = function() {
      return _.last(this.all());
    };

    Relation.prototype.forEach = function(iterator, context) {
      return _.each(this.all(), iterator, context);
    };

    Relation.prototype.each = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.forEach.apply(this, args);
    };

    Relation.prototype.map = function(iterator, context) {
      return _.map(this.all(), iterator, context);
    };

    Relation.prototype.where = function(predicate) {
      if (_.isEmpty(predicate)) {
        return this;
      }
      return new Monarch.Relations.Selection(this, predicate);
    };

    Relation.prototype.join = function(right, predicate) {
      return new Monarch.Relations.InnerJoin(this, right, predicate);
    };

    Relation.prototype.project = function(table) {
      return new Monarch.Relations.Projection(this, table);
    };

    Relation.prototype.joinThrough = function(table, predicate) {
      return this.join(table, predicate).project(table);
    };

    Relation.prototype.union = function(right) {
      return new Monarch.Relations.Union(this, right);
    };

    Relation.prototype.difference = function(right) {
      return new Monarch.Relations.Difference(this, right);
    };

    Relation.prototype.limit = function(limitCount, offsetCount) {
      var operand;
      operand = offsetCount ? this.offset(offsetCount) : this;
      return new Monarch.Relations.Limit(operand, limitCount);
    };

    Relation.prototype.offset = function(count) {
      return new Monarch.Relations.Offset(this, count);
    };

    Relation.prototype.orderBy = function() {
      return new Monarch.Relations.OrderBy(this, _.flatten(_.toArray(arguments)));
    };

    Relation.prototype.buildOrderByExpressions = function(orderByStrings) {
      var orderByString, _i, _len, _results;
      orderByStrings = orderByStrings.concat(['id']);
      _results = [];
      for (_i = 0, _len = orderByStrings.length; _i < _len; _i++) {
        orderByString = orderByStrings[_i];
        _results.push(new Monarch.Expressions.OrderBy(this, orderByString));
      }
      return _results;
    };

    Relation.prototype.resolvePredicate = function(object) {
      var key, predicates, value;
      if (object instanceof Monarch.Expressions.Predicate) {
        return object.resolve(this);
      }
      predicates = (function() {
        var _results;
        _results = [];
        for (key in object) {
          value = object[key];
          _results.push(this.predicateForKeyValue(key, value));
        }
        return _results;
      }).call(this);
      return _.inject(predicates, function(left, right) {
        return left.and(right);
      });
    };

    Relation.prototype.predicateForKeyValue = function(key, value) {
      var parts, predicateClass;
      parts = key.split(" ");
      if (parts[1]) {
        key = parts[0];
        predicateClass = Monarch.Expressions.Predicate.forSymbol(parts[1]);
      } else {
        predicateClass = Monarch.Expressions.Equal;
      }
      return new predicateClass(key, value).resolve(this);
    };

    return Relation;

  })(Monarch.Base);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Relations.Difference = (function(_super) {

    __extends(Difference, _super);

    Difference.deriveEquality('left', 'right');

    Difference.delegate('getColumn', 'inferJoinColumns', 'columns', 'repository', {
      to: 'left'
    });

    function Difference(left, right) {
      this.left = left;
      this.right = right;
      this.orderByExpressions = left.orderByExpressions;
    }

    Difference.prototype.wireRepresentation = function() {
      return {
        type: 'Difference',
        leftOperand: this.left.wireRepresentation(),
        rightOperand: this.right.wireRepresentation()
      };
    };

    return Difference;

  })(Monarch.Relations.Relation);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Relations.InnerJoin = (function(_super) {

    __extends(InnerJoin, _super);

    InnerJoin.deriveEquality('left', 'right', 'predicate');

    InnerJoin.delegate('repository', {
      to: 'left'
    });

    function InnerJoin(left, right, predicate) {
      this.left = _.isFunction(left) ? left.table : left;
      this.right = _.isFunction(right) ? right.table : right;
      this.predicate = this.resolvePredicate(predicate || this.inferPredicate());
      this.orderByExpressions = this.left.orderByExpressions.concat(this.right.orderByExpressions);
    }

    InnerJoin.prototype.inferPredicate = function() {
      var columns;
      columns = this.left.inferJoinColumns(this.right.columns()) || this.right.inferJoinColumns(this.left.columns());
      if (!columns) {
        throw new Error("No join predicate could be inferred");
      }
      return columns[0].eq(columns[1]);
    };

    InnerJoin.prototype.inferJoinColumns = function(columns) {
      return this.left.inferJoinColumns(columns) || this.right.inferJoinColumns(columns);
    };

    InnerJoin.prototype.columns = function() {
      return this.left.columns().concat(this.right.columns());
    };

    InnerJoin.prototype.getColumn = function(name) {
      return this.left.getColumn(name) || this.right.getColumn(name);
    };

    InnerJoin.prototype.buildComposite = function(tuple1, tuple2, sideOfTuple1) {
      if (sideOfTuple1 === 'right') {
        return new Monarch.CompositeTuple(tuple2, tuple1);
      } else {
        return new Monarch.CompositeTuple(tuple1, tuple2);
      }
    };

    InnerJoin.prototype.buildKey = function(tuple, oldKey) {
      var key;
      key = InnerJoin.__super__.buildKey.call(this, tuple);
      if (oldKey) {
        return _.extend(key, oldKey);
      } else {
        return key;
      }
    };

    InnerJoin.prototype.wireRepresentation = function() {
      return {
        type: 'InnerJoin',
        leftOperand: this.left.wireRepresentation(),
        rightOperand: this.right.wireRepresentation(),
        predicate: this.predicate.wireRepresentation()
      };
    };

    return InnerJoin;

  })(Monarch.Relations.Relation);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Relations.Limit = (function(_super) {

    __extends(Limit, _super);

    Limit.deriveEquality('operand', 'count');

    Limit.delegate('getColumn', 'inferJoinColumns', 'columns', 'repository', {
      to: 'operand'
    });

    function Limit(operand, count) {
      this.operand = operand;
      this.count = count;
      this.orderByExpressions = operand.orderByExpressions;
    }

    Limit.prototype.wireRepresentation = function() {
      return {
        type: 'Limit',
        operand: this.operand.wireRepresentation(),
        count: this.count
      };
    };

    return Limit;

  })(Monarch.Relations.Relation);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Relations.Offset = (function(_super) {

    __extends(Offset, _super);

    Offset.deriveEquality('operand', 'count');

    Offset.delegate('getColumn', 'inferJoinColumns', 'columns', 'repository', {
      to: 'operand'
    });

    function Offset(operand, count) {
      this.operand = operand;
      this.count = count;
      this.orderByExpressions = operand.orderByExpressions;
    }

    Offset.prototype.wireRepresentation = function() {
      return {
        type: 'Offset',
        operand: this.operand.wireRepresentation(),
        count: this.count
      };
    };

    return Offset;

  })(Monarch.Relations.Relation);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Relations.OrderBy = (function(_super) {

    __extends(OrderBy, _super);

    OrderBy.deriveEquality('operand', 'orderByExpressions');

    OrderBy.delegate('getColumn', 'inferJoinColumns', 'columns', 'wireRepresentation', 'create', 'created', 'repository', {
      to: 'operand'
    });

    function OrderBy(operand, orderByStrings) {
      this.operand = operand;
      this.orderByExpressions = this.buildOrderByExpressions(orderByStrings);
    }

    OrderBy.prototype.buildKey = function(tuple, changeset) {
      var change, key, name, qName;
      key = OrderBy.__super__.buildKey.call(this, tuple);
      if (changeset) {
        for (name in changeset) {
          change = changeset[name];
          qName = change.column.qualifiedName;
          if (key[qName] != null) {
            key[qName] = change.oldValue;
          }
        }
      }
      return key;
    };

    return OrderBy;

  })(Monarch.Relations.Relation);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Relations.Projection = (function(_super) {

    __extends(Projection, _super);

    Projection.deriveEquality('operand', 'table');

    Projection.delegate('getColumn', 'inferJoinColumns', 'columns', 'repository', {
      to: 'table'
    });

    function Projection(operand, table) {
      this.operand = operand;
      this.table = _.isFunction(table) ? table.table : table;
      this.buildOrderByExpressions();
      this.recordCounts = {};
    }

    Projection.prototype.buildOrderByExpressions = function() {
      var _this = this;
      return this.orderByExpressions = _.filter(this.operand.orderByExpressions, function(orderByExpression) {
        return orderByExpression.column.table.name === _this.table.name;
      });
    };

    Projection.prototype.insert = function(record, newKey) {
      var count, _base, _name, _ref;
      if ((_ref = (_base = this.recordCounts)[_name = record.id()]) == null) {
        _base[_name] = 0;
      }
      count = (this.recordCounts[record.id()] += 1);
      if (count === 1) {
        return Projection.__super__.insert.call(this, record, newKey);
      }
    };

    Projection.prototype.tupleUpdated = function(tuple, changeset, newKey, oldKey) {
      if (!this.changesetInProjection(changeset)) {
        return;
      }
      if (this.lastUpdate === changeset) {
        return;
      }
      this.lastUpdate = changeset;
      return Projection.__super__.tupleUpdated.call(this, tuple.getRecord(this.table.name), changeset, newKey, oldKey);
    };

    Projection.prototype.remove = function(record, newKey, oldKey) {
      var count;
      count = (this.recordCounts[record.id()] -= 1);
      if (count === 0) {
        delete this.recordCounts[record.id()];
        return Projection.__super__.remove.call(this, record, newKey, oldKey);
      }
    };

    Projection.prototype.changesetInProjection = function(changeset) {
      return _.values(changeset)[0].column.table.name === this.table.name;
    };

    Projection.prototype.wireRepresentation = function() {
      return {
        type: 'Projection',
        operand: this.operand.wireRepresentation(),
        table: this.table.name
      };
    };

    return Projection;

  })(Monarch.Relations.Relation);

}).call(this);

(function() {
  var addSatisfyingAttributes,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  Monarch.Relations.Selection = (function(_super) {

    __extends(Selection, _super);

    Selection.deriveEquality('operand', 'predicate');

    Selection.delegate('getColumn', 'inferJoinColumns', 'columns', 'repository', {
      to: 'operand'
    });

    function Selection(operand, predicate) {
      this.operand = operand;
      this.predicate = this.resolvePredicate(predicate);
      this.orderByExpressions = operand.orderByExpressions;
    }

    Selection.prototype.create = function() {
      var args, attributes, _ref;
      attributes = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref = this.operand).create.apply(_ref, [addSatisfyingAttributes(this.predicate, attributes)].concat(__slice.call(args)));
    };

    Selection.prototype.created = function(attributes) {
      return this.operand.created(addSatisfyingAttributes(this.predicate, attributes));
    };

    Selection.prototype.wireRepresentation = function() {
      return {
        type: 'Selection',
        predicate: this.predicate.wireRepresentation(),
        operand: this.operand.wireRepresentation()
      };
    };

    return Selection;

  })(Monarch.Relations.Relation);

  addSatisfyingAttributes = function(predicate, hashes) {
    var hash, satisifyingAttributes, _i, _len, _results;
    satisifyingAttributes = predicate.satisfyingAttributes();
    if (_.isArray(hashes)) {
      _results = [];
      for (_i = 0, _len = hashes.length; _i < _len; _i++) {
        hash = hashes[_i];
        _results.push(_.extend({}, hash, satisifyingAttributes));
      }
      return _results;
    } else {
      return _.extend({}, hashes, satisifyingAttributes);
    }
  };

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  Monarch.Relations.Table = (function(_super) {
    var capitalize, uncapitalize, _ref;

    __extends(Table, _super);

    _ref = Monarch.Util.Inflection, capitalize = _ref.capitalize, uncapitalize = _ref.uncapitalize;

    Table.delegate('repository', {
      to: 'recordClass'
    });

    function Table(recordClass) {
      this.recordClass = recordClass;
      this.name = recordClass.tableName || recordClass.name;
      this.columnsByName = {};
      this.column('id', 'integer');
      this.defaultOrderBy('id');
      this.initialize();
    }

    Table.prototype.initialize = function() {};

    Table.prototype.column = function(name, type) {
      return this.columnsByName[name] = new Monarch.Expressions.Column(this, name, type);
    };

    Table.prototype.syntheticColumn = function(name, definition) {
      return this.columnsByName[name] = new Monarch.Expressions.SyntheticColumn(this, name, definition);
    };

    Table.prototype.getColumn = function(name) {
      var parts;
      parts = name.split('.');
      if (parts.length === 2) {
        if (parts[0] !== this.name) {
          return;
        }
        name = parts[1];
      }
      return this.columnsByName[name];
    };

    Table.prototype.columns = function() {
      return _.values(this.columnsByName);
    };

    Table.prototype.eachColumn = function(f, ctx) {
      return _.each(this.columnsByName, f, ctx);
    };

    Table.prototype.defaultOrderBy = function() {
      return this.orderByExpressions = this.buildOrderByExpressions(_.toArray(arguments));
    };

    Table.prototype.inferJoinColumns = function(columns) {
      var column, match, name, _i, _len;
      for (_i = 0, _len = columns.length; _i < _len; _i++) {
        column = columns[_i];
        name = column.name;
        match = name.match(/^(.+)Id$/);
        if (match && capitalize(match[1]) === this.name) {
          return [this.getColumn('id'), column];
        }
      }
    };

    Table.prototype.update = function(recordsById) {
      var attributes, existingRecord, id, localAttributes, name, value, _results;
      _results = [];
      for (id in recordsById) {
        attributes = recordsById[id];
        id = parseInt(id);
        localAttributes = {};
        for (name in attributes) {
          value = attributes[name];
          localAttributes[name] = value;
        }
        existingRecord = this.find(id);
        if (existingRecord) {
          _results.push(existingRecord.updated(localAttributes));
        } else {
          localAttributes.id = id;
          _results.push(this.recordClass.created(localAttributes));
        }
      }
      return _results;
    };

    Table.prototype.resourceUrl = function() {
      return this.recordClass.resourceUrl(this.name);
    };

    Table.prototype.resourceName = function() {
      return this.recordClass.resourceName(this.name);
    };

    Table.prototype.wireRepresentation = function() {
      return {
        type: 'Table',
        name: this.resourceName()
      };
    };

    Table.prototype.create = function() {
      var args, _ref1;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref1 = this.recordClass).create.apply(_ref1, args);
    };

    Table.prototype.created = function() {
      var args, _ref1;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref1 = this.recordClass).created.apply(_ref1, args);
    };

    return Table;

  })(Monarch.Relations.Relation);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Relations.Union = (function(_super) {

    __extends(Union, _super);

    Union.deriveEquality('left', 'right');

    Union.delegate('getColumn', 'inferJoinColumns', 'columns', 'repository', {
      to: 'left'
    });

    function Union(left, right) {
      this.left = left;
      this.right = right;
      this.orderByExpressions = this.left.orderByExpressions;
    }

    Union.prototype.tupleUpdated = function(tuple, changeset, newKey, oldKey) {
      if (this.lastUpdate === changeset) {
        return;
      }
      this.lastUpdate = changeset;
      return Union.__super__.tupleUpdated.call(this, tuple, changeset, newKey, oldKey);
    };

    Union.prototype.wireRepresentation = function() {
      return {
        type: 'Union',
        leftOperand: this.left.wireRepresentation(),
        rightOperand: this.right.wireRepresentation()
      };
    };

    return Union;

  })(Monarch.Relations.Relation);

}).call(this);

(function() {

  Monarch.Errors = (function() {

    function Errors() {
      this.errorsByField = {};
    }

    Errors.prototype.add = function(name, error) {
      var _base, _ref;
      if ((_ref = (_base = this.errorsByField)[name]) == null) {
        _base[name] = [];
      }
      return this.errorsByField[name].push(error);
    };

    Errors.prototype.on = function(name) {
      return this.errorsByField[name] || [];
    };

    Errors.prototype.assign = function(errorsByField) {
      this.errorsByField = errorsByField;
    };

    Errors.prototype.isEmpty = function() {
      return _.isEmpty(this.errorsByField);
    };

    Errors.prototype.clear = function(name) {
      return delete this.errorsByField[name];
    };

    return Errors;

  })();

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.LocalField = (function(_super) {

    __extends(LocalField, _super);

    function LocalField() {
      return LocalField.__super__.constructor.apply(this, arguments);
    }

    LocalField.prototype.isDirty = function() {
      return !_.isEqual(this.getValue(), this.getRemoteValue());
    };

    LocalField.prototype.getRemoteValue = function() {
      return this.record.getRemoteField(this.name).getValue();
    };

    LocalField.prototype.valueChanged = function() {
      return this.record.errors.clear(this.name);
    };

    return LocalField;

  })(Monarch.Field);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.LocalSyntheticField = (function(_super) {

    __extends(LocalSyntheticField, _super);

    function LocalSyntheticField() {
      return LocalSyntheticField.__super__.constructor.apply(this, arguments);
    }

    return LocalSyntheticField;

  })(Monarch.SyntheticField);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  Monarch.Record = (function(_super) {
    var capitalize, methodName, singularize, uncapitalize, underscoreAndPluralize, _fn, _i, _len, _ref, _ref1,
      _this = this;

    __extends(Record, _super);

    _ref = Monarch.Util.Inflection, singularize = _ref.singularize, capitalize = _ref.capitalize, uncapitalize = _ref.uncapitalize, underscoreAndPluralize = _ref.underscoreAndPluralize;

    Record.extended = function(subclass) {
      subclass.defineColumnAccessor('id');
      subclass.table = new Monarch.Relations.Table(subclass);
      return this.repository().registerTable(subclass.table);
    };

    Record.tables = function() {
      return this.repository().tables;
    };

    Record.resourceUrl = function(name) {
      return Monarch.resourceUrlRoot + '/' + this.resourceName(name);
    };

    Record.resourceName = function(name) {
      return underscoreAndPluralize(uncapitalize(name)).replace(/_/g, Monarch.resourceUrlSeparator);
    };

    Record.column = function(name, type) {
      this.table.column(name, type);
      this.defineColumnAccessor(name);
      return this;
    };

    Record.columns = function(hash) {
      var name, type;
      for (name in hash) {
        type = hash[name];
        this.column(name, type);
      }
      return this;
    };

    Record.syntheticColumn = function(name, definition) {
      this.table.syntheticColumn(name, definition);
      this.prototype[name] = function() {
        return this.getFieldValue(name);
      };
      return this;
    };

    Record.hasMany = function(name, options) {
      var foreignKey, targetClassName, _ref1, _ref2;
      if (options == null) {
        options = {};
      }
      targetClassName = (_ref1 = options.className) != null ? _ref1 : singularize(capitalize(name));
      foreignKey = (_ref2 = options.foreignKey) != null ? _ref2 : uncapitalize(this.table.name) + "Id";
      return this.relatesTo(name, function() {
        var conditions, relation, target;
        target = this.tables()[targetClassName];
        conditions = _.extend({}, options.conditions || {});
        if (options.through) {
          target = this[options.through]().joinThrough(target);
        } else {
          conditions[foreignKey] = this.id();
        }
        relation = target.where(conditions);
        if (options.orderBy) {
          return relation.orderBy(options.orderBy);
        } else {
          return relation;
        }
      });
    };

    Record.relatesTo = function(name, definition) {
      this.prototype[name] = function() {
        var _base, _ref1;
        return (_ref1 = (_base = this._associations)[name]) != null ? _ref1 : _base[name] = definition.call(this);
      };
      return this;
    };

    Record.belongsTo = function(name, options) {
      var foreignKey, targetClassName, _ref1, _ref2;
      if (options == null) {
        options = {};
      }
      targetClassName = (_ref1 = options.className) != null ? _ref1 : capitalize(name);
      foreignKey = (_ref2 = options.foreignKey) != null ? _ref2 : name + "Id";
      this.prototype[name] = function() {
        var target;
        target = this.tables()[targetClassName];
        return target.find(this[foreignKey]());
      };
      return this;
    };

    Record.defaultOrderBy = function() {
      this.table.defaultOrderBy.apply(this.table, arguments);
      return this;
    };

    Record.create = function(attributes) {
      var record;
      record = new this(attributes);
      return record.save();
    };

    Record.created = function(attributes) {
      var record;
      record = new this();
      record.created(attributes);
      return record;
    };

    Record.defineColumnAccessor = function(name) {
      return this.prototype[name] = function() {
        var field;
        field = this.getField(name);
        if (arguments.length === 0) {
          return field.getValue();
        } else {
          return field.setValue(arguments[0]);
        }
      };
    };

    _ref1 = ['table', 'wireRepresentation', 'contains', 'onUpdate', 'onInsert', 'onRemove', 'at', 'indexOf', 'where', 'join', 'union', 'difference', 'limit', 'offset', 'orderBy', 'find', 'size', 'getColumn', 'all', 'each', 'first', 'last', 'clear'];
    _fn = function(methodName) {
      return Record[methodName] = function() {
        var args, _ref2;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return (_ref2 = this.table)[methodName].apply(_ref2, args);
      };
    };
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      methodName = _ref1[_i];
      _fn(methodName);
    }

    function Record(attributes) {
      var _this = this;
      this.table = this.constructor.table;
      this.errors = new Monarch.Errors();
      this._associations = {};
      this.localFields = {};
      this.remoteFields = {};
      this.table.eachColumn(function(column) {
        _this.localFields[column.name] = column.buildLocalField(_this);
        return _this.remoteFields[column.name] = column.buildRemoteField(_this);
      });
      if (attributes) {
        this.localUpdate(attributes);
      }
      this.afterInitialize();
    }

    Record.prototype.afterInitialize = _.identity;

    Record.prototype.beforeCreate = _.identity;

    Record.prototype.afterCreate = _.identity;

    Record.prototype.beforeUpdate = _.identity;

    Record.prototype.afterUpdate = _.identity;

    Record.prototype.beforeDestroy = _.identity;

    Record.prototype.afterDestroy = _.identity;

    Record.prototype.getField = function(name) {
      var parts;
      parts = name.split('.');
      if (parts.length > 1) {
        if (parts[0] === this.table.name) {
          name = parts[1];
        } else {
          return void 0;
        }
      }
      return this.localFields[name];
    };

    Record.prototype.getFieldValue = function(name) {
      return this.getField(name).getValue();
    };

    Record.prototype.getRemoteField = function(name) {
      return this.remoteFields[name];
    };

    Record.prototype.update = function(attributes) {
      this.localUpdate(attributes);
      return this.save();
    };

    Record.prototype.localUpdate = function(attributes) {
      var name, value, _results;
      _results = [];
      for (name in attributes) {
        value = attributes[name];
        _results.push(typeof this[name] === "function" ? this[name](value) : void 0);
      }
      return _results;
    };

    Record.prototype.onUpdate = function(callback, context) {
      var _ref2;
      if ((_ref2 = this.onUpdateNode) == null) {
        this.onUpdateNode = new Monarch.Util.Node();
      }
      return this.onUpdateNode.subscribe(callback, context);
    };

    Record.prototype.onDestroy = function(callback, context) {
      var _ref2;
      if ((_ref2 = this.onDestroyNode) == null) {
        this.onDestroyNode = new Monarch.Util.Node();
      }
      return this.onDestroyNode.subscribe(callback, context);
    };

    Record.prototype.wireRepresentation = function(allFields) {
      return this.fieldValues(true, allFields);
    };

    Record.prototype.fieldValues = function(wireRepresentation, allFields) {
      var field, fieldValues, name, value, _ref2;
      fieldValues = {};
      _ref2 = this.localFields;
      for (name in _ref2) {
        field = _ref2[name];
        value = wireRepresentation ? (allFields || field.isDirty()) && !(field instanceof Monarch.SyntheticField) ? field.wireRepresentation() : void 0 : field.getValue();
        if (value !== void 0) {
          fieldValues[name] = value;
        }
      }
      return fieldValues;
    };

    Record.prototype.created = function(attributes) {
      this.updated(attributes);
      this.table.insert(this);
      return this.afterCreate();
    };

    Record.prototype.updated = function(attributes) {
      var changeset, name, newKey, newRecord, oldKey, value, _ref2, _ref3;
      newRecord = !this.id();
      changeset = this.pendingChangeset = {};
      oldKey = this.table.buildKey(this);
      for (name in attributes) {
        value = attributes[name];
        if ((_ref2 = this.getRemoteField(name)) != null) {
          _ref2.setValue(value);
        }
      }
      newKey = this.table.buildKey(this);
      delete this.pendingChangeset;
      if (!(newRecord || _.isEmpty(changeset))) {
        this.table.tupleUpdated(this, changeset, newKey, oldKey);
      }
      this.afterUpdate();
      if ((_ref3 = this.onUpdateNode) != null) {
        _ref3.publish(changeset);
      }
      return changeset;
    };

    Record.prototype.destroyed = function() {
      var _ref2;
      this.table.remove(this);
      this.afterDestroy();
      return (_ref2 = this.onDestroyNode) != null ? _ref2.publish() : void 0;
    };

    Record.prototype.isValid = function() {
      return this.errors.isEmpty();
    };

    Record.prototype.isDirty = function() {
      return _.any(this.localFields, function(field) {
        return field.isDirty();
      });
    };

    Record.prototype.isEqual = function(other) {
      return (this.constructor === other.constructor) && (this.id() === other.id());
    };

    Record.prototype.signal = function() {
      var fieldNames, fields, name, transformer, _j;
      fieldNames = 2 <= arguments.length ? __slice.call(arguments, 0, _j = arguments.length - 1) : (_j = 0, []), transformer = arguments[_j++];
      if (!_.isFunction(transformer)) {
        fieldNames.push(transformer);
        transformer = void 0;
      }
      fields = (function() {
        var _k, _len1, _results;
        _results = [];
        for (_k = 0, _len1 = fieldNames.length; _k < _len1; _k++) {
          name = fieldNames[_k];
          if (this.remoteSignals) {
            _results.push(this.getRemoteField(name));
          } else {
            _results.push(this.getField(name));
          }
        }
        return _results;
      }).call(this);
      return new Monarch.Util.Signal(fields, transformer);
    };

    Record.prototype.getRecord = function(tableName) {
      if (this.table.name === tableName) {
        return this;
      }
    };

    Record.prototype.toString = function() {
      var attrStrings, name, value;
      attrStrings = (function() {
        var _ref2, _results;
        _ref2 = this.fieldValues();
        _results = [];
        for (name in _ref2) {
          value = _ref2[name];
          _results.push("" + name + ": " + (JSON.stringify(value)));
        }
        return _results;
      }).call(this);
      return "<" + this.constructor.name + " " + (attrStrings.join(', ')) + ">";
    };

    Record.prototype.tables = function() {
      return this.constructor.tables();
    };

    return Record;

  }).call(this, Monarch.Base);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.RemoteField = (function(_super) {

    __extends(RemoteField, _super);

    function RemoteField() {
      return RemoteField.__super__.constructor.apply(this, arguments);
    }

    RemoteField.prototype.valueChanged = function(newValue, oldValue) {
      this.record.pendingChangeset[this.name] = {
        newValue: newValue,
        oldValue: oldValue,
        column: this.column
      };
      return this.setLocalValue(newValue, oldValue);
    };

    RemoteField.prototype.setLocalValue = function(value) {
      return this.record.getField(this.name).setValue(value);
    };

    return RemoteField;

  })(Monarch.Field);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.RemoteSyntheticField = (function(_super) {

    __extends(RemoteSyntheticField, _super);

    function RemoteSyntheticField(record, column) {
      var _this = this;
      record.remoteSignals = true;
      RemoteSyntheticField.__super__.constructor.call(this, record, column);
      record.remoteSignals = false;
      this.signal.onChange(function(newValue, oldValue) {
        return _this.valueChanged(newValue, oldValue);
      });
    }

    RemoteSyntheticField.prototype.valueChanged = function(newValue, oldValue) {
      return this.record.pendingChangeset[this.name] = {
        newValue: newValue,
        oldValue: oldValue,
        column: this.column
      };
    };

    return RemoteSyntheticField;

  })(Monarch.SyntheticField);

}).call(this);

(function() {
  var moduleName, visitPrimitive, visiteeName, _i, _len, _ref,
    __slice = [].slice;

  Monarch.Util.Visitor = {
    visit: function() {
      var args, object;
      object = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if ((object != null ? object.acceptVisitor : void 0) != null) {
        return object.acceptVisitor(this, args);
      } else {
        return visitPrimitive.apply(this, arguments);
      }
    }
  };

  _ref = ["Expressions", "Relations"];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    moduleName = _ref[_i];
    _.each(Monarch[moduleName], function(klass, klassName) {
      var methodName;
      methodName = "visit_" + moduleName + "_" + klassName;
      return klass.prototype.acceptVisitor = function(visitor, args) {
        return visitor[methodName].apply(visitor, [this].concat(__slice.call(args)));
      };
    });
  }

  visitPrimitive = function(object) {
    var method, name;
    name = visiteeName(object);
    method = this['visit_' + name];
    if (!method) {
      throw new Error("Cannot visit " + name);
    }
    return method.apply(this, arguments);
  };

  visiteeName = function(object) {
    switch (object) {
      case null:
        return "null";
      case void 0:
        return "undefined";
      default:
        return object.constructor.name;
    }
  };

}).call(this);

(function() {



}).call(this);

(function() {

  (function(jQuery) {
    return jQuery.ajaxSetup({
      converters: {
        "json records": function(json) {
          return Monarch.Repository.update(json);
        },
        "json records!": function(json) {
          Monarch.Repository.clear();
          return Monarch.Repository.update(json);
        },
        "json data+records": function(json) {
          Monarch.Repository.update(json.records);
          return json.data;
        },
        "json data+records!": function(json) {
          Monarch.Repository.clear();
          Monarch.Repository.update(json.records);
          return json.data;
        }
      }
    });
  })(jQuery);

}).call(this);

(function() {

  Monarch.Util.SkipList = (function() {

    function SkipList(comparator) {
      var i, _i, _ref;
      this.comparator = comparator != null ? comparator : this.defaultComparator;
      this.maxLevels = 8;
      this.p = 0.25;
      this.currentLevel = 0;
      this.minusInfinity = {};
      this.plusInfinity = {};
      this.head = new Monarch.Util.SkipListNode(this.maxLevels, this.minusInfinity, void 0);
      this.nil = new Monarch.Util.SkipListNode(this.maxLevels, this.plusInfinity, void 0);
      for (i = _i = 0, _ref = this.maxLevels; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        this.head.pointer[i] = this.nil;
        this.head.distance[i] = 1;
      }
    }

    SkipList.prototype.insert = function(key, value) {
      var closestNode, i, level, maxLevels, newNode, next, nextDistance, prevNode, steps, _i, _j, _k, _ref, _ref1;
      if (value == null) {
        value = key;
      }
      next = this.buildNextArray();
      nextDistance = this.buildNextDistanceArray();
      closestNode = this.findClosestNode(key, next, nextDistance);
      if (closestNode.key === key) {
        return closestNode.value = value;
      } else {
        level = this.randomLevel();
        if (level > this.currentLevel) {
          for (i = _i = _ref = this.currentLevel + 1; _ref <= level ? _i <= level : _i >= level; i = _ref <= level ? ++_i : --_i) {
            next[i] = this.head;
          }
          this.currentLevel = level;
        }
        newNode = new Monarch.Util.SkipListNode(level, key, value);
        steps = 0;
        for (i = _j = 0; 0 <= level ? _j <= level : _j >= level; i = 0 <= level ? ++_j : --_j) {
          prevNode = next[i];
          newNode.pointer[i] = prevNode.pointer[i];
          prevNode.pointer[i] = newNode;
          newNode.distance[i] = prevNode.distance[i] - steps;
          prevNode.distance[i] = steps + 1;
          steps += nextDistance[i];
        }
        maxLevels = this.maxLevels;
        for (i = _k = _ref1 = level + 1; _ref1 <= maxLevels ? _k < maxLevels : _k > maxLevels; i = _ref1 <= maxLevels ? ++_k : --_k) {
          next[i].distance[i] += 1;
        }
        return _.sum(nextDistance);
      }
    };

    SkipList.prototype.insertAll = function(array) {
      var element, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        element = array[_i];
        _results.push(this.insert(element));
      }
      return _results;
    };

    SkipList.prototype.remove = function(key) {
      var cursor, i, next, nextDistance, _i, _ref;
      next = this.buildNextArray();
      nextDistance = this.buildNextDistanceArray();
      cursor = this.findClosestNode(key, next, nextDistance);
      if (this.compare(cursor.key, key) === 0) {
        for (i = _i = 0, _ref = this.currentLevel; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          if (next[i].pointer[i] === cursor) {
            next[i].pointer[i] = cursor.pointer[i];
            next[i].distance[i] += cursor.distance[i] - 1;
          } else {
            next[i].distance[i] -= 1;
          }
        }
        while (this.currentLevel > 0 && this.head.pointer[this.currentLevel] === this.nil) {
          this.currentLevel--;
        }
        return _.sum(nextDistance);
      } else {
        return -1;
      }
    };

    SkipList.prototype.find = function(key) {
      var cursor;
      cursor = this.findClosestNode(key);
      if (this.compare(cursor.key, key) === 0) {
        return cursor.value;
      } else {
        return void 0;
      }
    };

    SkipList.prototype.indexOf = function(key) {
      var cursor, nextDistance;
      nextDistance = this.buildNextDistanceArray();
      cursor = this.findClosestNode(key, null, nextDistance);
      if (this.compare(cursor.key, key) === 0) {
        return _.sum(nextDistance);
      } else {
        return -1;
      }
    };

    SkipList.prototype.at = function(index) {
      var cursor, i, _i, _ref;
      index += 1;
      cursor = this.head;
      for (i = _i = _ref = this.currentLevel; _ref <= 0 ? _i <= 0 : _i >= 0; i = _ref <= 0 ? ++_i : --_i) {
        while (cursor.distance[i] <= index) {
          index -= cursor.distance[i];
          cursor = cursor.pointer[i];
        }
      }
      if (cursor === this.nil) {
        return void 0;
      } else {
        return cursor.value;
      }
    };

    SkipList.prototype.keys = function() {
      var cursor, keys;
      keys = [];
      cursor = this.head.pointer[0];
      while (cursor !== this.nil) {
        keys.push(cursor.key);
        cursor = cursor.pointer[0];
      }
      return keys;
    };

    SkipList.prototype.values = function() {
      var cursor, values;
      values = [];
      cursor = this.head.pointer[0];
      while (cursor !== this.nil) {
        values.push(cursor.value);
        cursor = cursor.pointer[0];
      }
      return values;
    };

    SkipList.prototype.compare = function(a, b) {
      if (a === this.minusInfinity) {
        return (b === this.minusInfinity ? 0 : -1);
      }
      if (b === this.minusInfinity) {
        return (a === this.minusInfinity ? 0 : 1);
      }
      if (a === this.plusInfinity) {
        return (b === this.plusInfinity ? 0 : 1);
      }
      if (b === this.plusInfinity) {
        return (a === this.plusInfinity ? 0 : -1);
      }
      return this.comparator(a, b);
    };

    SkipList.prototype.defaultComparator = function(a, b) {
      if (a < b) {
        return -1;
      }
      if (a > b) {
        return 1;
      }
      return 0;
    };

    SkipList.prototype.findClosestNode = function(key, next, nextDistance) {
      var cursor, i, _i, _ref;
      cursor = this.head;
      for (i = _i = _ref = this.currentLevel; _ref <= 0 ? _i <= 0 : _i >= 0; i = _ref <= 0 ? ++_i : --_i) {
        while (this.compare(cursor.pointer[i].key, key) < 0) {
          if (nextDistance != null) {
            nextDistance[i] += cursor.distance[i];
          }
          cursor = cursor.pointer[i];
        }
        if (next != null) {
          next[i] = cursor;
        }
      }
      return cursor.pointer[0];
    };

    SkipList.prototype.randomLevel = function() {
      var level, maxLevels;
      maxLevels = this.maxLevels;
      level = 0;
      while (Math.random() < this.p && level < maxLevels - 1) {
        level++;
      }
      return level;
    };

    SkipList.prototype.buildNextArray = function() {
      var i, next, _i, _ref;
      next = new Array(this.maxLevels);
      for (i = _i = 0, _ref = this.maxLevels; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        next[i] = this.head;
      }
      return next;
    };

    SkipList.prototype.buildNextDistanceArray = function() {
      var i, nextDistance, _i, _ref;
      nextDistance = new Array(this.maxLevels);
      for (i = _i = 0, _ref = this.maxLevels; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        nextDistance[i] = 0;
      }
      return nextDistance;
    };

    return SkipList;

  })();

}).call(this);

(function() {

  Monarch.Util.SkipListNode = (function() {

    function SkipListNode(level, key, value) {
      this.level = level;
      this.key = key;
      this.value = value;
      this.pointer = new Array(level);
      this.distance = new Array(level);
    }

    return SkipListNode;

  })();

}).call(this);

(function() {
  var convertKeysToCamelCase, convertKeysToSnakeCase, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ref = Monarch.Util.Inflection, convertKeysToSnakeCase = _ref.convertKeysToSnakeCase, convertKeysToCamelCase = _ref.convertKeysToCamelCase;

  Monarch.Remote.MutateRequest = (function(_super) {

    __extends(MutateRequest, _super);

    function MutateRequest(record, fieldValues) {
      this.record = record;
      this.fieldValues = fieldValues;
      MutateRequest.__super__.constructor.call(this);
      Monarch.Repository.pauseUpdates();
      this.perform();
    }

    MutateRequest.prototype.perform = function() {
      var data,
        _this = this;
      data = this.requestData();
      if (Monarch.snakeCase && (data != null)) {
        data = convertKeysToSnakeCase(data);
      }
      return jQuery.ajax({
        url: this.requestUrl(),
        type: this.requestType,
        data: data,
        dataType: 'json',
        success: function(data) {
          return _this.handleSuccess(data);
        },
        error: function(data) {
          return _this.handleError(data);
        }
      });
    };

    MutateRequest.prototype.handleSuccess = function(data) {
      if (Monarch.snakeCase && (data != null)) {
        data = convertKeysToCamelCase(data);
      }
      return this.triggerSuccess(data);
    };

    MutateRequest.prototype.handleError = function(error) {
      var data;
      if (error.status === 422) {
        data = JSON.parse(error.responseText);
        if (Monarch.snakeCase) {
          data = convertKeysToCamelCase(data);
        }
        return this.triggerInvalid(data);
      }
    };

    MutateRequest.prototype.triggerSuccess = function() {
      MutateRequest.__super__.triggerSuccess.apply(this, arguments);
      return Monarch.Repository.resumeUpdates();
    };

    MutateRequest.prototype.triggerInvalid = function(errors) {
      this.record.errors.assign(errors);
      MutateRequest.__super__.triggerInvalid.call(this, this.record);
      return Monarch.Repository.resumeUpdates();
    };

    return MutateRequest;

  })(Monarch.Util.Deferrable);

}).call(this);

(function() {
  var clearEvents, deactivateIfNeeded, hasSubscriptions, otherOperand, setupEvents, subscribe, subscribeToBothOperands, subscribeToLeftAndRightOperands, subscribeToOperand,
    __slice = [].slice;

  Monarch.Events = {
    onInsert: function(relation, callback, context) {
      Monarch.Events.activate(relation);
      return relation._insertNode.subscribe(callback, context);
    },
    onUpdate: function(relation, callback, context) {
      Monarch.Events.activate(relation);
      return relation._updateNode.subscribe(callback, context);
    },
    onRemove: function(relation, callback, context) {
      Monarch.Events.activate(relation);
      return relation._removeNode.subscribe(callback, context);
    },
    publishInsert: function() {
      var args, relation, _ref;
      relation = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref = relation._insertNode).publish.apply(_ref, args);
    },
    publishUpdate: function() {
      var args, relation, _ref;
      relation = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref = relation._updateNode).publish.apply(_ref, args);
    },
    publishRemove: function() {
      var args, relation, _ref;
      relation = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref = relation._removeNode).publish.apply(_ref, args);
    },
    activate: function(relation) {
      if (!relation.isActive) {
        return this.visit(relation);
      }
    },
    clear: function(relation) {
      return clearEvents(relation);
    },
    visit: Monarch.Util.Visitor.visit,
    visit_Relations_Table: function(r) {
      return setupEvents(r);
    },
    visit_Relations_Difference: function(r) {
      return subscribeToLeftAndRightOperands(r, {
        left: {
          onInsert: function(tuple, index, newKey, oldKey) {
            if (!r.right.containsKey(newKey, oldKey)) {
              return r.insert(tuple, newKey, oldKey);
            }
          },
          onUpdate: function(tuple, changeset, newIndex, oldIndex, newKey, oldKey) {
            if (!r.right.containsKey(newKey, oldKey)) {
              return r.tupleUpdated(tuple, changeset, newKey, oldKey);
            }
          },
          onRemove: function(tuple, index, newKey, oldKey) {
            if (r.containsKey(oldKey)) {
              return r.remove(tuple);
            }
          }
        },
        right: {
          onInsert: function(tuple, index, newKey, oldKey) {
            if (r.containsKey(newKey, oldKey)) {
              return r.remove(tuple);
            }
          },
          onRemove: function(tuple, index, newKey, oldKey) {
            if (r.left.containsKey(newKey, oldKey)) {
              return r.insert(tuple, newKey, oldKey);
            }
          }
        }
      });
    },
    visit_Relations_InnerJoin: function(r) {
      return subscribeToBothOperands(r, {
        onInsert: function(side, tuple1, index, newKey, oldKey) {
          return otherOperand(r, side).each(function(tuple2) {
            var composite, newCompositeKey, oldCompositeKey;
            composite = r.buildComposite(tuple1, tuple2, side);
            newCompositeKey = r.buildKey(composite);
            oldCompositeKey = r.buildKey(composite, oldKey);
            if (r.predicate.evaluate(composite)) {
              return r.insert(composite, newCompositeKey, oldCompositeKey);
            }
          });
        },
        onUpdate: function(side, tuple1, changeset, newIndex, oldIndex, newKey, oldKey) {
          return otherOperand(r, side).each(function(tuple2) {
            var composite, existingComposite, newCompositeKey, oldCompositeKey;
            composite = r.buildComposite(tuple1, tuple2, side);
            newCompositeKey = r.buildKey(composite);
            oldCompositeKey = r.buildKey(composite, oldKey);
            existingComposite = r.findByKey(oldCompositeKey);
            if (r.predicate.evaluate(composite)) {
              if (existingComposite) {
                return r.tupleUpdated(existingComposite, changeset, newCompositeKey, oldCompositeKey);
              } else {
                return r.insert(composite, newCompositeKey, oldCompositeKey);
              }
            } else {
              if (existingComposite) {
                return r.remove(existingComposite, newCompositeKey, oldCompositeKey, changeset);
              }
            }
          });
        },
        onRemove: function(side, tuple1, index, newKey, oldKey) {
          return otherOperand(r, side).each(function(tuple2) {
            var existingComposite, newComposite, newCompositeKey, oldCompositeKey;
            newComposite = r.buildComposite(tuple1, tuple2, side);
            newCompositeKey = r.buildKey(newComposite);
            oldCompositeKey = r.buildKey(newComposite, oldKey);
            existingComposite = r.findByKey(oldCompositeKey);
            if (existingComposite) {
              return r.remove(existingComposite, newCompositeKey, oldCompositeKey);
            }
          });
        }
      });
    },
    visit_Relations_Limit: function(r) {
      return subscribeToOperand(r, {
        onInsert: function(tuple, index, newKey, oldKey) {
          var oldLastTuple;
          if (index < r.count) {
            oldLastTuple = r.at(r.count - 1);
            if (oldLastTuple) {
              r.remove(oldLastTuple);
            }
            return r.insert(tuple, newKey, oldKey);
          }
        },
        onUpdate: function(tuple, changeset, newIndex, oldIndex, newKey, oldKey) {
          var newLastTuple, oldLastTuple;
          if (oldIndex < r.count) {
            if (newIndex < r.count) {
              return r.tupleUpdated(tuple, changeset, newKey, oldKey);
            } else {
              r.remove(tuple, newKey, oldKey, changeset);
              newLastTuple = r.operand.at(r.count - 1);
              if (newLastTuple) {
                return r.insert(newLastTuple);
              }
            }
          } else {
            if (newIndex < r.count) {
              oldLastTuple = r.at(r.count - 1);
              if (oldLastTuple) {
                r.remove(oldLastTuple);
              }
              return r.insert(tuple, newKey, oldKey);
            }
          }
        },
        onRemove: function(tuple, index, newKey, oldKey) {
          var newLastTuple;
          r.remove(tuple, newKey, oldKey);
          newLastTuple = r.operand.at(r.count - 1);
          if (newLastTuple) {
            return r.insert(newLastTuple);
          }
        }
      });
    },
    visit_Relations_Offset: function(r) {
      return subscribeToOperand(r, {
        onInsert: function(tuple, index, newKey, oldKey) {
          var newFirstTuple;
          if (index < r.count) {
            newFirstTuple = r.operand.at(r.count);
            if (newFirstTuple) {
              return r.insert(newFirstTuple);
            }
          } else {
            return r.insert(tuple, newKey, oldKey);
          }
        },
        onUpdate: function(tuple, changeset, newIndex, oldIndex, newKey, oldKey) {
          var newFirstTuple, oldFirstTuple;
          if (oldIndex < r.count) {
            if (newIndex >= r.count) {
              oldFirstTuple = r.at(0);
              if (oldFirstTuple) {
                r.remove(oldFirstTuple);
              }
              return r.insert(tuple, newKey, oldKey);
            }
          } else {
            if (newIndex < r.count) {
              r.remove(tuple, newKey, oldKey, changeset);
              newFirstTuple = r.operand.at(r.count);
              if (newFirstTuple) {
                return r.insert(newFirstTuple);
              }
            } else {
              return r.tupleUpdated(tuple, changeset, newKey, oldKey);
            }
          }
        },
        onRemove: function(tuple, index, newKey, oldKey) {
          var oldFirstTuple;
          if (index < r.count) {
            oldFirstTuple = r.at(0);
            if (oldFirstTuple) {
              return r.remove(oldFirstTuple);
            }
          } else {
            return r.remove(tuple, newKey, oldKey);
          }
        }
      });
    },
    visit_Relations_OrderBy: function(r) {
      return subscribeToOperand(r, {
        onInsert: function(tuple) {
          return r.insert(tuple);
        },
        onUpdate: function(tuple, changeset) {
          return r.tupleUpdated(tuple, changeset, r.buildKey(tuple), r.buildKey(tuple, changeset));
        },
        onRemove: function(tuple, index, newKey, oldKey, changeset) {
          return r.remove(tuple, r.buildKey(tuple), r.buildKey(tuple, changeset));
        }
      });
    },
    visit_Relations_Projection: function(r) {
      return subscribeToOperand(r, {
        onInsert: function(tuple, index, newKey, oldKey) {
          return r.insert(tuple.getRecord(r.table.name), newKey, oldKey);
        },
        onUpdate: function(tuple, changeset, newIndex, oldIndex, newKey, oldKey) {
          return r.tupleUpdated(tuple, changeset, newKey, oldKey);
        },
        onRemove: function(tuple, index, newKey, oldKey) {
          return r.remove(tuple.getRecord(r.table.name), newKey, oldKey);
        }
      });
    },
    visit_Relations_Selection: function(r) {
      return subscribeToOperand(r, {
        onInsert: function(tuple, _, newKey, oldKey) {
          if (r.predicate.evaluate(tuple)) {
            return r.insert(tuple, newKey, oldKey);
          }
        },
        onUpdate: function(tuple, changeset, newIndex, oldIndex, newKey, oldKey) {
          if (r.predicate.evaluate(tuple)) {
            if (r.containsKey(oldKey)) {
              return r.tupleUpdated(tuple, changeset, newKey, oldKey);
            } else {
              return r.insert(tuple, newKey, oldKey);
            }
          } else {
            if (r.containsKey(oldKey)) {
              return r.remove(tuple, newKey, oldKey, changeset);
            }
          }
        },
        onRemove: function(tuple, _, newKey, oldKey) {
          if (r.containsKey(oldKey)) {
            return r.remove(tuple, newKey, oldKey);
          }
        }
      });
    },
    visit_Relations_Union: function(r) {
      return subscribeToBothOperands(r, {
        onInsert: function(side, tuple, index, newKey, oldKey) {
          if (!r.containsKey(newKey, oldKey)) {
            return r.insert(tuple, newKey, oldKey);
          }
        },
        onUpdate: function(side, tuple, changeset, newIndex, oldIndex, newKey, oldKey) {
          return r.tupleUpdated(tuple, changeset, newKey, oldKey);
        },
        onRemove: function(side, tuple, index, newKey, oldKey) {
          if (!otherOperand(r, side).containsKey(newKey, oldKey)) {
            return r.remove(tuple, newKey, oldKey);
          }
        }
      });
    }
  };

  subscribeToOperand = function(r, callbacks) {
    var callback, event, _results;
    Monarch.Events.activate(r.operand);
    setupEvents(r);
    _results = [];
    for (event in callbacks) {
      callback = callbacks[event];
      _results.push(subscribe(r, r.operand, event, callback));
    }
    return _results;
  };

  subscribeToLeftAndRightOperands = function(r, callbacksBySide) {
    var callback, callbacks, event, side, _results;
    Monarch.Events.activate(r.right);
    Monarch.Events.activate(r.left);
    setupEvents(r);
    _results = [];
    for (side in callbacksBySide) {
      callbacks = callbacksBySide[side];
      _results.push((function() {
        var _results1;
        _results1 = [];
        for (event in callbacks) {
          callback = callbacks[event];
          _results1.push(subscribe(r, r[side], event, callback));
        }
        return _results1;
      })());
    }
    return _results;
  };

  subscribeToBothOperands = function(r, callbacks) {
    var callback, callbacksBySide, event, side, sideCallbacks;
    callbacksBySide = {
      left: {},
      right: {}
    };
    for (side in callbacksBySide) {
      sideCallbacks = callbacksBySide[side];
      for (event in callbacks) {
        callback = callbacks[event];
        sideCallbacks[event] = _.bind(callback, this, side);
      }
    }
    return subscribeToLeftAndRightOperands(r, callbacksBySide);
  };

  subscribe = function(r, operand, event, callback) {
    return r.subscriptions.add(Monarch.Events[event](operand, callback));
  };

  deactivateIfNeeded = function(r) {
    if (hasSubscriptions(r) && r.constructor !== Monarch.Relations.Table) {
      r._insertNode = null;
      r._updateNode = null;
      r._removeNode = null;
      r.subscriptions.destroy();
      return r.isActive = false;
    }
  };

  setupEvents = function(r) {
    r._insertNode = new Monarch.Util.Node();
    r._updateNode = new Monarch.Util.Node();
    r._removeNode = new Monarch.Util.Node();
    r._insertNode.onEmpty(function() {
      return deactivateIfNeeded(r);
    });
    r._updateNode.onEmpty(function() {
      return deactivateIfNeeded(r);
    });
    r._removeNode.onEmpty(function() {
      return deactivateIfNeeded(r);
    });
    r.subscriptions = new Monarch.Util.SubscriptionBundle();
    r.isActive = true;
    return r.contents();
  };

  clearEvents = function(r) {
    r._insertNode.clear();
    r._updateNode.clear();
    return r._removeNode.clear();
  };

  hasSubscriptions = function(r) {
    if (!r.isActive) {
      return false;
    }
    return (r._insertNode.size() + r._updateNode.size() + r._removeNode.size()) > 0;
  };

  otherOperand = function(r, side) {
    if (side === 'left') {
      return r.right;
    } else {
      return r.left;
    }
  };

}).call(this);

(function() {
  var __slice = [].slice;

  _.extend(Monarch, {
    fetch: function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = Monarch.Remote.Server).fetch.apply(_ref, args);
    }
  });

}).call(this);

(function() {

  Monarch.Record.reopen(function() {
    var methodName, _fn, _i, _len, _ref,
      _this = this;
    this.repository = function() {
      return Monarch.Repository;
    };
    _ref = ['fetch', 'findOrFetch'];
    _fn = function(methodName) {
      return _this[methodName] = function() {
        return this.table[methodName].apply(this, arguments);
      };
    };
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      methodName = _ref[_i];
      _fn(methodName);
    }
    return {
      save: function() {
        if (this.id()) {
          if (this.beforeUpdate() === false) {
            return;
          }
          return Monarch.Remote.Server.update(this, this.wireRepresentation());
        } else {
          if (this.beforeCreate() === false) {
            return;
          }
          return Monarch.Remote.Server.create(this, this.wireRepresentation());
        }
      },
      fetch: function() {
        return this.table.where({
          id: this.id()
        }).fetch();
      },
      destroy: function() {
        if (this.beforeDestroy() === false) {
          return;
        }
        return Monarch.Remote.Server.destroy(this);
      }
    };
  });

}).call(this);

(function() {

  Monarch.RecordRetriever = {
    retrieveRecords: Monarch.Util.Visitor.visit,
    visit_Relations_Selection: function(r) {
      var _this = this;
      return _.filter(r.operand.all(), function(tuple) {
        return r.predicate.evaluate(tuple);
      });
    },
    visit_Relations_Difference: function(r) {
      return _.difference(r.left.all(), r.right.all());
    },
    visit_Relations_InnerJoin: function(r) {
      var all,
        _this = this;
      all = [];
      r.left.each(function(leftTuple) {
        return r.right.each(function(rightTuple) {
          var composite;
          composite = r.buildComposite(leftTuple, rightTuple);
          if (r.predicate.evaluate(composite)) {
            return all.push(composite);
          }
        });
      });
      return all;
    },
    visit_Relations_Limit: function(r) {
      return r.operand.all().slice(0, r.count);
    },
    visit_Relations_Offset: function(r) {
      return r.operand.all().slice(r.count);
    },
    visit_Relations_OrderBy: function(r) {
      return r.operand.all().sort(r.buildComparator(true));
    },
    visit_Relations_Projection: function(r) {
      var _this = this;
      return r.operand.map(function(composite) {
        return composite.getRecord(r.table.name);
      });
    },
    visit_Relations_Union: function(r) {
      return _.union(r.left.all(), r.right.all()).sort(r.buildComparator(true));
    }
  };

}).call(this);

(function() {

  Monarch.Relations.Projection.reopen(function() {
    return {
      all: function() {
        if (this._contents) {
          return this._contents.values();
        } else {
          return _.uniq(this.retrieveRecords());
        }
      }
    };
  });

}).call(this);

(function() {
  var __slice = [].slice;

  Monarch.Relations.Relation.reopen(function() {
    return {
      contents: function() {
        var contents, tuple, _i, _j, _len, _len1, _ref, _ref1;
        if (this.isActive) {
          if (!this._contents) {
            this._contents = this.buildContents();
            _ref = this.retrieveRecords();
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              tuple = _ref[_i];
              this.insert(tuple);
            }
          }
          return this._contents;
        } else {
          contents = this.buildContents();
          _ref1 = this.retrieveRecords();
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            tuple = _ref1[_j];
            contents.insert(this.buildKey(tuple), tuple);
          }
          return contents;
        }
      },
      buildContents: function() {
        return new Monarch.Util.SkipList(this.buildComparator());
      },
      all: function() {
        if (this._contents) {
          return this._contents.values();
        } else {
          return this.retrieveRecords();
        }
      },
      retrieveRecords: function() {
        return Monarch.RecordRetriever.retrieveRecords(this);
      },
      onInsert: function(callback, context) {
        return Monarch.Events.onInsert(this, callback, context);
      },
      onUpdate: function(callback, context) {
        return Monarch.Events.onUpdate(this, callback, context);
      },
      onRemove: function(callback, context) {
        return Monarch.Events.onRemove(this, callback, context);
      },
      insert: function(tuple, newKey, oldKey) {
        var index;
        if (newKey == null) {
          newKey = this.buildKey(tuple);
        }
        index = this.contents().insert(newKey, tuple);
        return Monarch.Events.publishInsert(this, tuple, index, newKey, oldKey || newKey);
      },
      tupleUpdated: function(tuple, changeset, newKey, oldKey) {
        var newIndex, oldIndex;
        oldIndex = this.contents().remove(oldKey);
        newIndex = this.contents().insert(newKey, tuple);
        return Monarch.Events.publishUpdate(this, tuple, changeset, newIndex, oldIndex, newKey, oldKey);
      },
      remove: function(tuple, newKey, oldKey, changeset) {
        var index;
        if (newKey == null) {
          newKey = oldKey = this.buildKey(tuple);
        }
        index = this.contents().remove(oldKey);
        return Monarch.Events.publishRemove(this, tuple, index, newKey, oldKey, changeset);
      },
      indexOf: function(tuple) {
        return this.contents().indexOf(this.buildKey(tuple));
      },
      containsKey: function() {
        var keys,
          _this = this;
        keys = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return _.any(keys, function(key) {
          return _this.contents().indexOf(key) !== -1;
        });
      },
      at: function(index) {
        return this.contents().at(index);
      },
      findByKey: function(key) {
        return this.contents().find(key);
      },
      buildKey: function(tuple) {
        var columnName, key, orderByExpression, _i, _len, _ref;
        key = {};
        _ref = this.orderByExpressions;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          orderByExpression = _ref[_i];
          columnName = orderByExpression.columnName;
          key[columnName] = tuple.getFieldValue(columnName);
        }
        return key;
      },
      buildComparator: function(compareRecords) {
        var lessThan, orderByExpressions;
        lessThan = function(a, b) {
          if ((a === null || a === void 0) && b !== null && b !== void 0) {
            return false;
          }
          if ((b === null || b === void 0) && a !== null && a !== void 0) {
            return true;
          }
          return a < b;
        };
        orderByExpressions = this.orderByExpressions;
        return function(a, b) {
          var aValue, bValue, columnName, directionCoefficient, orderByExpression, _i, _len;
          for (_i = 0, _len = orderByExpressions.length; _i < _len; _i++) {
            orderByExpression = orderByExpressions[_i];
            columnName = orderByExpression.columnName;
            directionCoefficient = orderByExpression.directionCoefficient;
            if (compareRecords) {
              aValue = a.getFieldValue(columnName);
              bValue = b.getFieldValue(columnName);
            } else {
              aValue = a[columnName];
              bValue = b[columnName];
            }
            if (lessThan(aValue, bValue)) {
              return -1 * directionCoefficient;
            } else if (lessThan(bValue, aValue)) {
              return 1 * directionCoefficient;
            }
          }
          return 0;
        };
      },
      fetch: function() {
        return Monarch.Remote.Server.fetch(this);
      }
    };
  });

}).call(this);

(function() {

  Monarch.Relations.Table.reopen(function() {
    return {
      clear: function() {
        Monarch.Events.clear(this);
        return this._contents = this.buildContents();
      },
      defaultOrderBy: function() {
        this.orderByExpressions = this.buildOrderByExpressions(_.toArray(arguments));
        return this._contents = this.buildContents();
      },
      findOrFetch: function(id) {
        var promise, record,
          _this = this;
        record = this.find(id);
        promise = new Monarch.Util.Promise;
        if (record) {
          promise.triggerSuccess(record);
        } else {
          Monarch.Remote.Server.fetch(this.where({
            id: id
          })).onSuccess(function() {
            record = _this.find(id);
            return promise.triggerSuccess(record);
          });
        }
        return promise;
      },
      initialize: function() {
        return Monarch.Events.activate(this);
      }
    };
  });

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Remote.CreateRequest = (function(_super) {

    __extends(CreateRequest, _super);

    function CreateRequest() {
      return CreateRequest.__super__.constructor.apply(this, arguments);
    }

    CreateRequest.prototype.requestType = 'post';

    CreateRequest.prototype.requestUrl = function() {
      return this.record.table.resourceUrl();
    };

    CreateRequest.prototype.requestData = function() {
      if (!_.isEmpty(this.fieldValues)) {
        return {
          fieldValues: this.fieldValues
        };
      }
    };

    CreateRequest.prototype.triggerSuccess = function(attributes) {
      this.record.created(attributes);
      return CreateRequest.__super__.triggerSuccess.call(this, this.record);
    };

    return CreateRequest;

  })(Monarch.Remote.MutateRequest);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Remote.DestroyRequest = (function(_super) {

    __extends(DestroyRequest, _super);

    function DestroyRequest() {
      return DestroyRequest.__super__.constructor.apply(this, arguments);
    }

    DestroyRequest.prototype.requestType = 'delete';

    DestroyRequest.prototype.requestUrl = function() {
      return this.record.table.resourceUrl() + '/' + this.record.id();
    };

    DestroyRequest.prototype.requestData = function() {};

    DestroyRequest.prototype.triggerSuccess = function() {
      this.record.destroyed();
      return DestroyRequest.__super__.triggerSuccess.call(this, this.record);
    };

    return DestroyRequest;

  })(Monarch.Remote.MutateRequest);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  Monarch.Remote.FetchRequest = (function(_super) {

    __extends(FetchRequest, _super);

    function FetchRequest(relations) {
      FetchRequest.__super__.constructor.call(this);
      this.relations = relations;
      this.perform();
    }

    FetchRequest.prototype.perform = function() {
      var relation, relationsJson,
        _this = this;
      relationsJson = JSON.stringify((function() {
        var _i, _len, _ref, _results;
        _ref = this.relations;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          relation = _ref[_i];
          _results.push(relation.wireRepresentation());
        }
        return _results;
      }).call(this));
      return jQuery.ajax({
        url: Monarch.fetchUrl,
        type: 'get',
        data: {
          relations: relationsJson
        },
        dataType: 'records',
        success: function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return _this.triggerSuccess.apply(_this, args);
        },
        error: function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return _this.triggerError.apply(_this, args);
        }
      });
    };

    return FetchRequest;

  })(Monarch.Util.Deferrable);

}).call(this);

(function() {

  Monarch.Remote.Server = {
    create: function(record, wireRepresentation) {
      var request;
      request = new Monarch.Remote.CreateRequest(record, wireRepresentation);
      if ($.ajaxSettings.async) {
        return request;
      } else {
        return request.record;
      }
    },
    update: function(record, wireRepresentation) {
      var promise;
      if (record.isDirty()) {
        promise = new Monarch.Remote.UpdateRequest(record, wireRepresentation);
      } else {
        promise = new Monarch.Util.Deferrable();
        promise.triggerSuccess(record);
      }
      if ($.ajaxSettings.async) {
        return promise;
      } else {
        return record;
      }
    },
    destroy: function(record) {
      return new Monarch.Remote.DestroyRequest(record);
    },
    fetch: function(relationOrArray) {
      var relations;
      relations = _.isArray(relationOrArray) ? relationOrArray : _.toArray(arguments);
      return new Monarch.Remote.FetchRequest(relations);
    }
  };

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Remote.UpdateRequest = (function(_super) {

    __extends(UpdateRequest, _super);

    function UpdateRequest() {
      return UpdateRequest.__super__.constructor.apply(this, arguments);
    }

    UpdateRequest.prototype.requestType = 'put';

    UpdateRequest.prototype.requestUrl = function() {
      return this.record.table.resourceUrl() + '/' + this.record.id();
    };

    UpdateRequest.prototype.requestData = function() {
      return {
        fieldValues: this.fieldValues
      };
    };

    UpdateRequest.prototype.triggerSuccess = function(attributes) {
      var changeset;
      changeset = this.record.updated(attributes);
      return UpdateRequest.__super__.triggerSuccess.call(this, this.record, changeset);
    };

    return UpdateRequest;

  })(Monarch.Remote.MutateRequest);

}).call(this);

(function() {
  var camelize, capitalize, convertKeysToCamelCase, singularize, _ref;

  _ref = Monarch.Util.Inflection, capitalize = _ref.capitalize, convertKeysToCamelCase = _ref.convertKeysToCamelCase, camelize = _ref.camelize, singularize = _ref.singularize;

  Monarch.Repository = {
    tables: {},
    pauseCount: 0,
    registerTable: function(table) {
      return this.tables[table.name] = table;
    },
    update: function(hashOrArray) {
      var command, operation, recordsHash, resourceName, _i, _len, _results, _results1;
      if (this.pauseCount > 0) {
        this.deferredUpdates.push(hashOrArray);
        return;
      }
      if (_.isArray(hashOrArray)) {
        if (!_.isArray(hashOrArray[0])) {
          hashOrArray = [hashOrArray];
        }
        _results = [];
        for (_i = 0, _len = hashOrArray.length; _i < _len; _i++) {
          command = hashOrArray[_i];
          operation = this['perform' + capitalize(command.shift())];
          _results.push(operation.apply(this, command));
        }
        return _results;
      } else {
        _results1 = [];
        for (resourceName in hashOrArray) {
          recordsHash = hashOrArray[resourceName];
          if (Monarch.snakeCase) {
            recordsHash = convertKeysToCamelCase(recordsHash);
          }
          _results1.push(this.tableForResourceName(resourceName).update(recordsHash));
        }
        return _results1;
      }
    },
    tableForResourceName: function(resourceName) {
      var table, tableName;
      tableName = capitalize(singularize(camelize(resourceName)));
      if (table = this.tables[tableName]) {
        return table;
      } else {
        throw new Error("No table exists for resource name '" + resourceName + "'");
      }
    },
    isPaused: function() {
      return this.pauseCount > 0;
    },
    pauseUpdates: function() {
      if (this.pauseCount === 0) {
        this.deferredUpdates = [];
      }
      return this.pauseCount++;
    },
    resumeUpdates: function() {
      var updateArg, _i, _len, _ref1;
      this.pauseCount--;
      if (this.pauseCount === 0) {
        _ref1 = this.deferredUpdates;
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          updateArg = _ref1[_i];
          this.update(updateArg);
        }
        return delete this.deferredUpdates;
      }
    },
    performCreate: function(resourceName, attributes) {
      var table;
      if (Monarch.snakeCase) {
        attributes = convertKeysToCamelCase(attributes);
      }
      table = this.tableForResourceName(resourceName);
      if (table.find(attributes.id)) {
        return;
      }
      return table.recordClass.created(attributes);
    },
    performUpdate: function(resourceName, id, attributes) {
      var record, table;
      if (Monarch.snakeCase) {
        attributes = convertKeysToCamelCase(attributes);
      }
      table = this.tableForResourceName(resourceName);
      record = table.find(parseInt(id));
      return record != null ? record.updated(attributes) : void 0;
    },
    performDestroy: function(resourceName, id) {
      var record, table;
      table = this.tableForResourceName(resourceName);
      record = table.find(parseInt(id));
      return record != null ? record.destroyed() : void 0;
    },
    clear: function() {
      var name, table, _ref1, _results;
      this.pauseCount = 0;
      delete this.deferredUpdates;
      _ref1 = this.tables;
      _results = [];
      for (name in _ref1) {
        table = _ref1[name];
        _results.push(table.clear());
      }
      return _results;
    },
    subscriptionCount: function() {
      var count, name, table, _ref1;
      count = 0;
      _ref1 = this.tables;
      for (name in _ref1) {
        table = _ref1[name];
        count += table.subscriptionCount();
      }
      return count;
    }
  };

}).call(this);

(function() {



}).call(this);
