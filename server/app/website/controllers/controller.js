// Generated by CoffeeScript 1.6.2
(function() {
  var AppError, Controller, conf, models,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  conf = require('../../conf');

  models = new (require('../../models')).Models(conf.db);

  AppError = require('../../common/apperror').AppError;

  Controller = (function() {
    function Controller() {
      this.setValues = __bind(this.setValues, this);
      this.getValue = __bind(this.getValue, this);
      this.isAdmin = __bind(this.isAdmin, this);
      this.isSameUser = __bind(this.isSameUser, this);
      this.ensureSession = __bind(this.ensureSession, this);
    }

    Controller.prototype.ensureSession = function(args, fn) {
      var next, req, res, _ref,
        _this = this;

      req = args[0], res = args[1], next = args[2];
      return this.getUserWithPasskey((_ref = req.query.passkey) != null ? _ref : req.cookies.passkey, function(err, user) {
        if ((user != null ? user.id : void 0) && (user != null ? user.domain : void 0) && (user != null ? user.username : void 0)) {
          req.user = user;
          return fn();
        } else {
          return res.send({
            error: 'NO_SESSION'
          });
        }
      });
    };

    Controller.prototype.attachUser = function(args, fn) {
      var next, req, res, _ref,
        _this = this;

      req = args[0], res = args[1], next = args[2];
      return this.getUserWithPasskey((_ref = req.query.passkey) != null ? _ref : req.cookies.passkey, function(err, user) {
        req.user = user != null ? user : {
          id: 0
        };
        return fn();
      });
    };

    Controller.prototype.getUserWithPasskey = function(passkey, cb) {
      var _this = this;

      if (passkey) {
        return models.Session.get({
          passkey: passkey
        }, {}, function(err, session) {
          if (!err) {
            if (session) {
              return models.User.getById(session.userid, {}, function(err, user) {
                user = user != null ? user.summarize() : void 0;
                return cb(err, user);
              });
            } else {
              return cb();
            }
          } else {
            return cb(err);
          }
        });
      } else {
        return cb();
      }
    };

    Controller.prototype.isSameUser = function(user1, user2) {
      return user1.domain === user2.domain && user1.username === user2.username;
    };

    Controller.prototype.isAdmin = function(user) {
      var u;

      return ((function() {
        var _i, _len, _ref, _results;

        _ref = conf.admins;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          u = _ref[_i];
          if (u.username === (user != null ? user.username : void 0) && u.domain === (user != null ? user.domain : void 0)) {
            _results.push(u);
          }
        }
        return _results;
      })()).length;
    };

    Controller.prototype.getValue = function(src, field, safe) {
      if (safe == null) {
        safe = true;
      }
      return src[field];
    };

    Controller.prototype.handleError = function(onError) {
      return function(fn) {
        return function() {
          if (arguments[0]) {
            return onError(arguments[0]);
          } else {
            return fn.apply(void 0, arguments);
          }
        };
      };
    };

    Controller.prototype.setValues = function(target, src, fields, options) {
      var field, fsrc, ft, setValue, _i, _len, _results, _results1,
        _this = this;

      if (options == null) {
        options = {};
      }
      if (options.safe == null) {
        options.safe = true;
      }
      if (!options.ignoreEmpty) {
        options.ignoreEmpty = true;
      }
      setValue = function(src, targetField, srcField) {
        var val;

        val = _this.getValue(src, srcField, options.safe);
        if (options.ignoreEmpty) {
          if (val != null) {
            return target[field] = val;
          }
        } else {
          return target[field] = val;
        }
      };
      if (fields.constructor === Array) {
        _results = [];
        for (_i = 0, _len = fields.length; _i < _len; _i++) {
          field = fields[_i];
          _results.push(setValue(src, field, field));
        }
        return _results;
      } else {
        _results1 = [];
        for (ft in fields) {
          fsrc = fields[ft];
          _results1.push(setValue(src, ft, fsrc));
        }
        return _results1;
      }
    };

    return Controller;

  })();

  exports.Controller = Controller;

}).call(this);
