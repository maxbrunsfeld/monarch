if (typeof exports !== 'undefined') {
  var Monarch = require("monarch-db");
}

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Remote.FakeCreateRequest = (function(_super) {

    __extends(FakeCreateRequest, _super);

    FakeCreateRequest.prototype.perform = function() {};

    function FakeCreateRequest(fakeServer, record, fieldValues) {
      this.fakeServer = fakeServer;
      this.fakeServer = fakeServer;
      FakeCreateRequest.__super__.constructor.call(this, record, fieldValues);
      fakeServer.creates.push(this);
    }

    FakeCreateRequest.prototype.succeed = function(fieldValues) {
      var recordWithHighestId, _ref, _ref1;
      if (fieldValues == null) {
        fieldValues = _.clone(this.fieldValues);
      }
      recordWithHighestId = this.record.table.orderBy('id desc').first();
      if ((_ref = fieldValues.id) == null) {
        fieldValues.id = ((_ref1 = recordWithHighestId != null ? recordWithHighestId.id() : void 0) != null ? _ref1 : 0) + 1;
      }
      this.fakeServer.creates = _.without(this.fakeServer.creates, this);
      return this.triggerSuccess(fieldValues);
    };

    return FakeCreateRequest;

  })(Monarch.Remote.CreateRequest);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Remote.FakeDestroyRequest = (function(_super) {

    __extends(FakeDestroyRequest, _super);

    FakeDestroyRequest.prototype.perform = function() {};

    function FakeDestroyRequest(fakeServer, record) {
      this.fakeServer = fakeServer;
      FakeDestroyRequest.__super__.constructor.call(this, record);
      fakeServer.destroys.push(this);
    }

    FakeDestroyRequest.prototype.succeed = function() {
      this.fakeServer.destroys = _.without(this.fakeServer.destroys, this);
      return this.triggerSuccess();
    };

    return FakeDestroyRequest;

  })(Monarch.Remote.DestroyRequest);

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Remote.FakeFetchRequest = (function(_super) {

    __extends(FakeFetchRequest, _super);

    function FakeFetchRequest(fakeServer, relations) {
      this.fakeServer = fakeServer;
      FakeFetchRequest.__super__.constructor.call(this, relations);
      this.fakeServer.fetches.push(this);
    }

    FakeFetchRequest.prototype.perform = function() {};

    FakeFetchRequest.prototype.succeed = function(records) {
      Monarch.Repository.update(records);
      this.fakeServer.fetches = _.without(this.fakeServer.fetches, this);
      return this.triggerSuccess();
    };

    return FakeFetchRequest;

  })(Monarch.Remote.FetchRequest);

}).call(this);

(function() {

  Monarch.Remote.FakeServer = {
    constructor: function() {
      return this.reset();
    },
    create: function(record, wireRepresentation) {
      var request;
      request = new Monarch.Remote.FakeCreateRequest(this, record, wireRepresentation);
      if (this.auto) {
        request.succeed();
      }
      return request;
    },
    update: function(record, wireRepresentation) {
      var request;
      request = new Monarch.Remote.FakeUpdateRequest(this, record, wireRepresentation);
      if (this.auto) {
        request.succeed();
      }
      return request;
    },
    destroy: function(record) {
      var request;
      request = new Monarch.Remote.FakeDestroyRequest(this, record);
      if (this.auto) {
        request.succeed();
      }
      return request;
    },
    fetch: function() {
      var request;
      request = new Monarch.Remote.FakeFetchRequest(this, _.toArray(arguments));
      if (this.auto) {
        request.succeed();
      }
      return request;
    },
    lastCreate: function() {
      return _.last(this.creates);
    },
    lastUpdate: function() {
      return _.last(this.updates);
    },
    lastDestroy: function() {
      return _.last(this.destroys);
    },
    lastFetch: function() {
      return _.last(this.fetches);
    },
    reset: function() {
      this.creates = [];
      this.updates = [];
      this.destroys = [];
      return this.fetches = [];
    }
  };

  Monarch.Remote.OriginalServer = Monarch.Remote.Server;

  Monarch.useFakeServer = function(auto) {
    Monarch.Remote.Server = Monarch.Remote.FakeServer;
    Monarch.Remote.Server.reset();
    return Monarch.Remote.Server.auto = auto;
  };

  Monarch.restoreOriginalServer = function() {
    return Monarch.Remote.Server = Monarch.Remote.OriginalServer;
  };

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Monarch.Remote.FakeUpdateRequest = (function(_super) {

    __extends(FakeUpdateRequest, _super);

    FakeUpdateRequest.prototype.perform = function() {};

    function FakeUpdateRequest(fakeServer, record, fieldValues) {
      this.fakeServer = fakeServer;
      FakeUpdateRequest.__super__.constructor.call(this, record, fieldValues);
      fakeServer.updates.push(this);
    }

    FakeUpdateRequest.prototype.succeed = function(fieldValues) {
      if (fieldValues == null) {
        fieldValues = _.clone(this.fieldValues);
      }
      this.fakeServer.updates = _.without(this.fakeServer.updates, this);
      return this.triggerSuccess(fieldValues);
    };

    return FakeUpdateRequest;

  })(Monarch.Remote.UpdateRequest);

}).call(this);

(function() {



}).call(this);
