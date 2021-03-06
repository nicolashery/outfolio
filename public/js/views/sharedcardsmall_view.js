// Generated by CoffeeScript 1.3.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['app'], function(App) {
    var SharedCardSmallView;
    return SharedCardSmallView = (function(_super) {

      __extends(SharedCardSmallView, _super);

      function SharedCardSmallView() {
        this.render = __bind(this.render, this);
        return SharedCardSmallView.__super__.constructor.apply(this, arguments);
      }

      SharedCardSmallView.prototype.tagName = 'li';

      SharedCardSmallView.prototype.template = jade.templates.sharedcardsmall;

      SharedCardSmallView.prototype.render = function() {
        var data;
        data = {
          _id: this.model.id,
          name: this.model.shorten('name'),
          address: this.model.shorten('address'),
          city: this.model.shorten('city'),
          notes: this.model.shorten('notes'),
          owner: this.model.get('owner')
        };
        this.$el.html(this.template(data));
        return this;
      };

      return SharedCardSmallView;

    })(Backbone.View);
  });

}).call(this);
