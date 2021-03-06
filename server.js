// Generated by CoffeeScript 1.4.0
(function() {
  var Card, CardSchema, ObjectId, Schema, User, UserSchema, app, bootstrapData, createUserJson, everyauth, express, googleAuthPlugin, googleClientId, googleClientSecret, mongodbUri, mongoose, port;

  express = require('express');

  mongoose = require('mongoose');

  everyauth = require('everyauth');

  port = process.env.PORT || 3000;

  mongodbUri = process.env.MONGOLAB_URI || 'mongodb://localhost/outfolio';

  googleClientId = process.env.GOOGLE_CLIENTID || '484129397477.apps.googleusercontent.com';

  googleClientSecret = process.env.GOOGLE_CLIENTSECRET || 'oVZOq-Ad1MNFHw9jNpOgWa0T';

  Schema = mongoose.Schema;

  ObjectId = Schema.ObjectId;

  app = express();

  mongoose.connect(mongodbUri);

  everyauth.debug = false;

  CardSchema = new Schema({
    name: String,
    address: String,
    city: String,
    notes: String,
    owner: {
      _id: {
        type: ObjectId,
        index: true
      },
      name: String
    },
    created_on: {
      type: Date,
      "default": Date.now
    },
    modified_on: {
      type: Date,
      "default": Date.now
    }
  });

  CardSchema.pre('save', function(next) {
    this.modified_on = new Date;
    return next();
  });

  CardSchema.statics.allByUserId = function(userId, callback) {
    var query;
    query = this.find({});
    query.where('owner._id').equals(userId);
    query.sort('-created_on');
    return query.exec(callback);
  };

  Card = mongoose.model('Card', CardSchema);

  UserSchema = new Schema({
    created_on: {
      type: Date,
      "default": Date.now
    }
  });

  googleAuthPlugin = function(schema, options) {
    schema.add({
      google: {
        id: String,
        email: String,
        verified_email: Boolean,
        name: String,
        given_name: String,
        family_name: String,
        link: String,
        gender: String,
        locale: String,
        access_token: String,
        token_type: String,
        expires_in: Number,
        expires: Date
      }
    });
    return schema["static"]('createWithGoogleOAuth', function(accessToken, accessTokenExtra, googleUser, callback) {
      var expiresDate, params;
      expiresDate = new Date;
      expiresDate.setSeconds(expiresDate.getSeconds() + accessTokenExtra.expires_in);
      params = {
        google: {
          id: googleUser.id,
          email: googleUser.email,
          verified_email: googleUser.verified_email,
          name: googleUser.name,
          given_name: googleUser.given_name,
          family_name: googleUser.family_name,
          link: googleUser.link,
          gender: googleUser.gender,
          locale: googleUser.locale,
          access_token: accessToken,
          token_type: accessTokenExtra.token_type,
          expires_in: accessTokenExtra.expires_in,
          expires: expiresDate
        }
      };
      return this.create(params, callback);
    });
  };

  UserSchema.plugin(googleAuthPlugin);

  User = mongoose.model('User', UserSchema);

  bootstrapData = false;

  if (bootstrapData) {
    Card.find().remove();
    new Card({
      name: 'The Dead Poet',
      address: '450 Amsterdam Ave (& 81st St)',
      city: 'New York',
      notes: 'Irish pub, small room, good beer selection, music jukebox',
      owner: {
        _id: '4fae78cd846ebe2204000003',
        name: 'Nicolas Hery'
      }
    }).save();
    new Card({
      name: 'Solas',
      address: '232 E 9th Street (& 2nd Ave)',
      city: 'New York',
      notes: 'Dancing bar, mainstream music, large room, usually not a long line to get in',
      owner: {
        _id: '4fae78cd846ebe2204000003',
        name: 'Nicolas Hery'
      }
    }).save();
  }

  everyauth.google.entryPath('/login').callbackPath('/auth/google/callback').appId(googleClientId).appSecret(googleClientSecret).scope('https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile').redirectPath('/');

  everyauth.everymodule.logoutPath('/logout');

  everyauth.everymodule.logoutRedirectPath('/');

  everyauth.everymodule.findUserById(function(userId, callback) {
    return User.findById(userId, callback);
  });

  everyauth.google.findOrCreateUser(function(session, accessToken, accessTokenExtra, googleUser) {
    var promise;
    promise = this.Promise();
    User.findOne({
      'google.id': googleUser.id
    }, function(err, foundUser) {
      if (foundUser) {
        return promise.fulfill(foundUser);
      } else {
        return User.createWithGoogleOAuth(accessToken, accessTokenExtra, googleUser, function(err, createdUser) {
          if (err) {
            return promise.fail(err);
          } else {
            return promise.fulfill(createdUser);
          }
        });
      }
    });
    return promise;
  });

  app.configure(function() {
    app.use(express.bodyParser());
    app.use(express.cookieParser('penguin'));
    app.use(express.session({
      secret: 'penguin'
    }));
    app.use(everyauth.middleware());
    app.use(express.methodOverride());
    app.use(app.router);
    app.set('view engine', 'jade');
    app.set('view options', {
      layout: true
    });
    app.set('views', __dirname + '/views');
    return app.use(express["static"](__dirname + '/public'));
  });

  app.configure('development', function() {
    app.use(express.logger('dev'));
    return app.use(express.errorHandler({
      dumpExceptions: true,
      showStack: true
    }));
  });

  app.configure('production', function() {
    app.use(express.logger());
    return app.use(express.errorHandler());
  });

  createUserJson = function(user) {
    return JSON.stringify({
      _id: user._id,
      name: user.google.name,
      email: user.google.email
    });
  };

  app.get('/', function(req, res, next) {
    var locals;
    if (req.loggedIn) {
      return Card.allByUserId(req.user._id, function(err, cards) {
        var locals;
        if (err) {
          return next(err);
        }
        locals = {
          userJson: createUserJson(req.user),
          cardsJson: JSON.stringify(cards)
        };
        return res.render('app', locals);
      });
    } else {
      locals = {
        authenticated: false
      };
      return res.render('home', locals);
    }
  });

  app.get('/home', function(req, res) {
    var locals;
    if (req.loggedIn) {
      locals = {
        authenticated: true,
        user: {
          name: req.user.google.name
        }
      };
      return res.render('home', locals);
    } else {
      locals = {
        authenticated: false
      };
      return res.render('home', locals);
    }
  });

  app.get('/demo', function(req, res) {
    return res.render('app', {
      userJson: 'demo'
    });
  });

  app.get('/cards', function(req, res) {
    if (req.loggedIn) {
      return Card.allByUserId(req.user._id, function(err, cards) {
        var locals;
        if (err) {
          return next(err);
        }
        locals = {
          userJson: createUserJson(req.user),
          cardsJson: JSON.stringify(cards)
        };
        return res.render('app', locals);
      });
    } else {
      return res.redirect('/');
    }
  });

  app.get('/cards/new', function(req, res) {
    if (req.loggedIn) {
      return Card.allByUserId(req.user._id, function(err, cards) {
        var locals;
        if (err) {
          return next(err);
        }
        locals = {
          userJson: createUserJson(req.user),
          cardsJson: JSON.stringify(cards)
        };
        return res.render('app', locals);
      });
    } else {
      return res.redirect('/');
    }
  });

  app.get('/cards/share', function(req, res) {
    var locals;
    if (req.loggedIn) {
      locals = {
        userJson: createUserJson(req.user)
      };
      return res.render('app', locals);
    } else {
      return res.redirect('/');
    }
  });

  app.get('/card/:id', function(req, res) {
    if (req.loggedIn) {
      return Card.findById(req.params.id, function(err, card) {
        var locals;
        if (err || !(card != null) || card.owner._id.toString() !== req.user._id.toString()) {
          return res.redirect('/');
        }
        locals = {
          userJson: createUserJson(req.user),
          cardJson: JSON.stringify(card)
        };
        return res.render('app', locals);
      });
    } else {
      return res.redirect('/');
    }
  });

  app.get('/card/:id/edit', function(req, res) {
    if (req.loggedIn) {
      return Card.findById(req.params.id, function(err, card) {
        var locals;
        if (err || !(card != null) || card.owner._id.toString() !== req.user._id.toString()) {
          return res.redirect('/');
        }
        locals = {
          userJson: createUserJson(req.user),
          cardJson: JSON.stringify(card)
        };
        return res.render('app', locals);
      });
    } else {
      return res.redirect('/');
    }
  });

  app.get('/card/:id/share', function(req, res) {
    if (req.loggedIn) {
      return Card.findById(req.params.id, function(err, card) {
        var locals;
        if (err || !(card != null) || card.owner._id.toString() !== req.user._id.toString()) {
          return res.redirect('/');
        }
        locals = {
          userJson: createUserJson(req.user),
          cardJson: JSON.stringify(card)
        };
        return res.render('app', locals);
      });
    } else {
      return res.redirect('/');
    }
  });

  app.get('/shared/:shareId', function(req, res) {
    return User.findById(req.params.shareId, function(err, owner) {
      if (err || !(owner != null)) {
        return res.redirect('/');
      }
      return Card.allByUserId(req.params.shareId, function(err, cards) {
        var locals;
        if (err) {
          return next(err);
        }
        locals = {
          ownerJson: JSON.stringify({
            _id: owner._id,
            name: owner.google.name
          }),
          sharedCardsJson: JSON.stringify(cards)
        };
        if (req.loggedIn) {
          locals.userJson = createUserJson(req.user);
        }
        return res.render('app', locals);
      });
    });
  });

  app.get('/shared/:shareId/card/:cardId', function(req, res) {
    return User.findById(req.params.shareId, function(err, owner) {
      if (err || !(owner != null)) {
        return res.redirect('/');
      }
      return Card.findById(req.params.cardId, function(err, card) {
        var locals;
        if (err || !(card != null) || card.owner._id.toString() !== req.params.shareId) {
          return res.redirect('/');
        }
        locals = {
          sharedCardJson: JSON.stringify(card)
        };
        if (req.loggedIn) {
          locals.userJson = createUserJson(req.user);
        }
        return res.render('app', locals);
      });
    });
  });

  app.get('/api/cards', function(req, res, next) {
    if (req.loggedIn) {
      return Card.allByUserId(req.user._id, function(err, cards) {
        if (err) {
          return next(err);
        }
        return res.send(cards);
      });
    } else {
      return res.send('Unauthorized', 401);
    }
  });

  app.get('/api/cards/:id', function(req, res, next) {
    if (req.loggedIn) {
      return Card.findById(req.params.id, function(err, card) {
        if (err || !(card != null) || card.owner._id.toString() !== req.user._id.toString()) {
          return res.send('Not Found', 404);
        }
        return res.send(card);
      });
    } else {
      return res.send('Unauthorized', 401);
    }
  });

  app.post('/api/cards', function(req, res, next) {
    var card;
    if (req.loggedIn) {
      card = new Card({
        name: req.body.name,
        address: req.body.address,
        city: req.body.city,
        notes: req.body.notes,
        owner: {
          _id: req.user._id,
          name: req.user.google.name
        }
      });
      return card.save(function(err) {
        if (err) {
          return next(err);
        }
        return res.send(card);
      });
    } else {
      return res.send('Unauthorized', 401);
    }
  });

  app.put('/api/cards/:id', function(req, res, next) {
    if (req.loggedIn) {
      return Card.findById(req.params.id, function(err, card) {
        if (err || !(card != null) || card.owner._id.toString() !== req.user._id.toString()) {
          return res.send('Not Found', 404);
        }
        card.name = req.body.name;
        card.address = req.body.address;
        card.city = req.body.city;
        card.notes = req.body.notes;
        return card.save(function(err) {
          if (err) {
            return next(err);
          }
          return res.send(card);
        });
      });
    } else {
      return res.send('Unauthorized', 401);
    }
  });

  app.del('/api/cards/:id', function(req, res, next) {
    if (req.loggedIn) {
      return Card.findById(req.params.id, function(err, card) {
        if (err || !(card != null) || card.owner._id.toString() !== req.user._id.toString()) {
          return res.send('Not Found', 404);
        }
        return card.remove(function(err) {
          if (err) {
            return next(err);
          }
          return res.send('');
        });
      });
    } else {
      return res.send('Unauthorized', 401);
    }
  });

  app.get('/api/owners/:id', function(req, res, next) {
    return User.findById(req.params.id, ['google.name'], function(err, owner) {
      if (err || !(owner != null)) {
        return res.send('Not Found', 404);
      }
      return res.send({
        _id: owner._id,
        name: owner.google.name
      });
    });
  });

  app.get('/api/shared/:shareId/cards', function(req, res, next) {
    return User.findById(req.params.shareId, function(err, owner) {
      if (err || !(owner != null)) {
        return res.send('Not Found', 404);
      }
      return Card.allByUserId(req.params.shareId, function(err, cards) {
        if (err) {
          return next(err);
        }
        return res.send(cards);
      });
    });
  });

  app.get('/api/shared/:shareId/cards/:cardId', function(req, res, next) {
    return User.findById(req.params.shareId, function(err, owner) {
      if (err || !(owner != null)) {
        return res.send('Not Found', 404);
      }
      return Card.findById(req.params.cardId, function(err, card) {
        if (err || !(card != null) || card.owner._id.toString() !== req.params.shareId) {
          return res.send('Not Found', 404);
        }
        return res.send(card);
      });
    });
  });

  app.listen(port);

  console.log("Outfolio listening on port " + port);

}).call(this);
