(function(Monarch) {
  Monarch.Remote.UpdateCommand = new JS.Class('Monarch.Remote.UpdateCommand', Monarch.Remote.Command, {
    requestType: 'put',

    requestUrl: function() {
      return Monarch.sandboxUrl + '/' + this.record.table.name + '/' + this.record.id();
    },

    requestData: function() {
      return { field_values: this.fieldValues };
    },

    triggerSuccess: function(attributes) {
      this.record.remotelyUpdated(attributes);
      this.callSuper(this.record);
    },

    triggerSuccess: function(attributes) {
      var changeset = this.record.remotelyUpdated(_.camelizeKeys(attributes));
      this.callSuper(this.record, changeset);
    }
  });
})(Monarch, jQuery);