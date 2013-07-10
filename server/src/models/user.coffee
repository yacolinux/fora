utils = require '../common/utils'
Models = require './'
AppError = require('../common/apperror').AppError
BaseModel = require('./basemodel').BaseModel

class User extends BaseModel

    @_getMeta: ->
        forumModule = require('./forum')
        {
            type: User,
            collection: 'users',
            fields: {
                domain: { type: 'string', validate: -> ['twitter', 'fb', 'users'].indexOf(@domain) isnt -1 },
                domainid: 'string',
                username: 'string',
                domainidType: { type: 'string', validate: -> ['username', 'domainid'].indexOf(@domainidType) isnt -1 },
                name: 'string',
                location: 'string',
                picture: 'string',
                thumbnail: 'string',
                email: 'string',
                accessToken: { type: 'string', required: false },
                lastLogin: 'number',
                following: { type: 'array', contents: User.Summary, validate: -> x.validate() for x in @following },
                subscriptions: { type: 'array', contents: forumModule.Forum.Summary, validate: -> x.validate() for x in @subscriptions },            
                about: { type: 'string', required: false },
                createdAt: { autoGenerated: true, event: 'created' },
                updatedAt: { autoGenerated: true, event: 'updated' }            
            },
            logging: {
                isLogged: true,
                onInsert: 'NEW_USER'
            }
        }
        
    
    #Called from controllers when a new session is created.
    @getOrCreateUser: (userDetails, domain, accessToken, cb) =>
        @_models.Session.get { accessToken }, {}, (err, session) =>
            if err
                cb err
            else
                session ?= new @_models.Session { passkey: utils.uniqueId(24), accessToken }
                    
                User.get { domain, username: userDetails.username }, {}, (err, user) =>
                    if user?
                        #Update some details
                        user.name = userDetails.name ? user.name
                        user.domainid = userDetails.domainid ? user.domainid
                        user.username = userDetails.username ? userDetails.domainid
                        user.domainidType = if userDetails.username then 'username' else 'domainid'
                        user.location = userDetails.location ? user.location
                        user.picture = userDetails.picture ? user.picture
                        user.thumbnail = userDetails.thumbnail ? user.thumbnail
                        user.tile = userDetails.tile ? user.tile
                        user.email = userDetails.email ? 'unknown@poe3.com'
                        user.lastLogin = Date.now()
                        user.save {}, (err, u) =>
                            if not err
                                session.userid = u._id.toString()
                                session.save {}, (err, session) =>
                                    if not err
                                        cb null, u, session
                                    else
                                        cb err
                            else
                                cb err
                        
                    else                            
                        #User doesn't exist. create.
                        user = new User()
                        user.domain = domain
                        user.domainid = userDetails.domainid
                        user.username = userDetails.username ? userDetails.domainid
                        user.domainidType = if userDetails.username then 'username' else 'domainid'
                        if domain is 'fb'
                            user.facebookUsername = userDetails.username
                        if domain is 'tw'
                            user.twitterUsername = userDetails.username
                        user.name = userDetails.name
                        user.location = userDetails.location
                        user.picture = userDetails.picture
                        user.thumbnail = userDetails.thumbnail
                        user.tile = userDetails.tile ? '/images/collection-tile.png'
                        user.email = userDetails.email ? 'unknown@poe3.com'
                        user.lastLogin = Date.now()
                        user.preferences = { canEmail: true }
                        user.createdAt = Date.now()
                        user.save {}, (err, u) =>
                            #also create the userinfo
                            if not err
                                userinfo = new @_models.UserInfo()
                                userinfo.userid = u._id.toString()
                                userinfo.save {}, (err, _uinfo) =>
                                    if not err
                                        session.userid = u._id.toString()
                                        session.save {}, (err, session) =>
                                            if not err
                                                cb null, u, session
                                            else
                                                cb err
                                    else
                                        cb err
                            else
                                cb err
                                
    
    
    @getById: (id, context, cb) ->
        super id, context, cb

    

    @getByUsername: (domain, username, context, cb) ->
        User.get { domain, username }, context, (err, user) ->
            cb null, user


    
    @validateSummary: (user) =>
        errors = []
        if not user
            errors.push "Invalid user."
        
        required = ['id', 'domain', 'username', 'name']
        for field in required
            if not user[field]
                errors.push "Invalid #{field}"
                
        errors
        
        

    constructor: (params) ->
        @about ?= ''
        @karma ?= 1
        @preferences ?= {}
        @following = []
        @followerCount = []
        @subscriptions = []
        @totalItemCount = 0
        super

        

    getUrl: =>
        if @domain is 'tw' then "/@#{@username}" else "/#{@domain}/#{@username}"



    save: (context, cb) =>
        super


    summarize: =>        
       new Summary {
            id: @_id.toString()
            domain: @domain
            username: @username
            name: @name
        }

    
class Summary extends BaseModel    
    @_getMeta: ->
        {
            type: Summary,
            fields: {
                id: 'string',
                domain: { type: 'string', validate: -> ['twitter', 'fb', 'users'].indexOf(@domain) isnt -1 },
                username: 'string',
                name: 'string',
            }
        }
            
User.Summary = Summary                
exports.User = User
