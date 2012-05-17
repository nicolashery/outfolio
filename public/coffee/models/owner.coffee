define ->

  class Owner extends Backbone.Model

    # Using MongoDB
    idAttribute: '_id'

    urlRoot: '/api/owners'
  