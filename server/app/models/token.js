// Generated by CoffeeScript 1.6.2
(function() {
  var AppError, BaseModel, Models, Token, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Models = require('./');

  AppError = require('../common/apperror').AppError;

  BaseModel = require('./basemodel').BaseModel;

  Token = (function(_super) {
    __extends(Token, _super);

    function Token() {
      _ref = Token.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Token._getMeta = function() {
      return {
        type: Token,
        collection: 'tokens',
        fields: {
          type: 'string',
          key: 'string',
          value: 'string',
          createdAt: {
            autoGenerated: true,
            event: 'created'
          },
          updatedAt: {
            autoGenerated: true,
            event: 'updated'
          }
        },
        logging: {
          isLogged: false
        }
      };
    };

    return Token;

  })(BaseModel);

  exports.Token = Token;

}).call(this);
