// Generated by CoffeeScript 1.6.2
(function() {
  var AppError, ApplicationCache, apiControllers, app, conf, database, express, findHandler, getNetwork, handleDomainUrls, host, models, port, root, uiControllers, utils, validator,
    _this = this;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  express = require('express');

  conf = require('../conf');

  models = new (require('../models')).Models(conf.db);

  database = new (require('../common/database')).Database(conf.db);

  AppError = require('../common/apperror').AppError;

  utils = require('../common/utils');

  ApplicationCache = require('../common/cache').ApplicationCache;

  validator = require('validator');

  uiControllers = require('./controllers/ui');

  apiControllers = require('./controllers/api');

  utils.log("Fora application started at " + (new Date));

  utils.log("NODE_ENV is " + process.env.NODE_ENV);

  app = express();

  app.use(express.bodyParser({
    uploadDir: '../../www-user/temp',
    limit: '6mb'
  }));

  app.use(express.limit('6mb'));

  app.set("view engine", "hbs");

  app.set('view options', {
    layout: 'layouts/default'
  });

  app.use('/public', express["static"](__dirname + '/public'));

  app.use(express.favicon());

  app.use(express.cookieParser());

  app.use(function(req, res, next) {
    var inputs, key, val, _i, _len, _ref;

    _ref = [req.params, req.query, req.body];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      inputs = _ref[_i];
      if (inputs) {
        for (key in inputs) {
          val = inputs[key];
          val = inputs[key];
          if (!/-html$/.test(key)) {
            val = val.replace('<', '&lt;');
            val = val.replace('>', '&gt;');
          }
          inputs[key] = validator.sanitize(val).xss();
        }
      }
    }
    return next();
  });

  findHandler = function(name, getHandler) {
    var controller, handler;

    controller = (function() {
      switch (name.toLowerCase()) {
        case 'ui/auth':
          return new uiControllers.Auth();
        case 'ui/users':
          return new uiControllers.Users();
        case 'ui/home':
          return new uiControllers.Home();
        case 'ui/forums':
          return new uiControllers.Forums();
        case 'ui/dev_designs':
          return new uiControllers.Dev_Designs();
        case 'api/sessions':
          return new apiControllers.Sessions();
        case 'api/users':
          return new apiControllers.Users();
        case 'api/forums':
          return new apiControllers.Forums();
        case 'api/posts':
          return new apiControllers.Posts();
        case 'api/articles':
          return new apiControllers.Articles();
        case 'api/files/images':
          return new apiControllers.Images();
        default:
          throw new Error("Cannot find controller " + name + ".");
      }
    })();
    handler = getHandler(controller);
    return function(req, res, next) {
      var network;

      network = getNetwork(req.headers.host);
      if (network) {
        req.network = network;
        return handler(req, res, next);
      } else {
        return next(new AppError('Invalid Network', 'INVALID_NETWORK'));
      }
    };
  };

  getNetwork = function(hostName) {
    var hostNames, n;

    hostNames = hostName.split('.');
    if (hostNames[0] === 'www') {
      hostNames = hostNames[0].shift();
    }
    hostName = hostNames.join('.');
    return ((function() {
      var _i, _len, _ref, _results;

      _ref = conf.networks;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        if (n.domain === hostName) {
          _results.push(n);
        }
      }
      return _results;
    })())[0];
  };

  handleDomainUrls = function(domain, fnHandler) {
    return function(c) {
      return function(req, res, next) {
        req.params.domain = domain;
        return fnHandler(c)(req, res, next);
      };
    };
  };

  app.get('/auth/twitter', findHandler('ui/auth', function(c) {
    return c.twitter;
  }));

  app.get('/auth/twitter/callback', findHandler('ui/auth', function(c) {
    return c.twitterCallback;
  }));

  app.post('/api/sessions', findHandler('api/sessions', function(c) {
    return c.create;
  }));

  app.post('/api/forums', findHandler('api/forums', function(c) {
    return c.create;
  }));

  app.post('/api/forums/:forum', findHandler('api/forums', function(c) {
    return c.createItem;
  }));

  app.put("/api/admin/posts/:id", findHandler('api/posts', function(c) {
    return c.admin_update;
  }));

  app.get('/', findHandler('ui/home', function(c) {
    return c.index;
  }));

  app.get('/:forum', findHandler('ui/forums', function(c) {
    return c.index;
  }));

  app.use(app.router);

  /*
  app.use (err, req, res, next) ->
      utils.log err
      res.send(500, { error: err })
  */


  app.use(function(req, res, next) {
    res.status(404);
    res.render('404', {
      url: req.url
    });
    return res.send(404, {
      error: 'HTTP 404. There is no water here.'
    });
  });

  database.getDb(function(err, db) {
    db.collection('sessions', function(_, coll) {
      coll.ensureIndex({
        passkey: 1
      }, function() {});
      return coll.ensureIndex({
        accessToken: 1
      }, function() {});
    });
    db.collection('forums', function(_, coll) {
      coll.ensureIndex({
        'createdBy.id': 1
      }, function() {});
      coll.ensureIndex({
        'createdBy.username': 1,
        'createdBy.domain': 1
      }, function() {});
      return coll.ensureIndex({
        'stub': 1
      }, function() {});
    });
    db.collection('posts', function(_, coll) {
      coll.ensureIndex({
        uid: 1
      }, function() {});
      coll.ensureIndex({
        uid: 1,
        state: 1
      }, function() {});
      coll.ensureIndex({
        uid: -1,
        state: 1
      }, function() {});
      coll.ensureIndex({
        publishedAt: 1
      }, function() {});
      coll.ensureIndex({
        'createdBy.id': 1
      }, function() {});
      return coll.ensureIndex({
        'createdBy.username': 1,
        'createdBy.domain': 1
      }, function() {});
    });
    db.collection('messages', function(_, coll) {
      coll.ensureIndex({
        userid: 1
      }, function() {});
      return coll.ensureIndex({
        'related.type': 1,
        'related.id': 'related.id'
      }, function() {});
    });
    return db.collection('tokens', function(_, coll) {
      return coll.ensureIndex({
        type: 1,
        key: 1
      }, function() {});
    });
  });

  host = process.argv[2];

  port = process.argv[3];

  app.listen(port);

}).call(this);
