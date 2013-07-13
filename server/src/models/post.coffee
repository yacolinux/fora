async = require '../common/async'
utils = require '../common/utils'
AppError = require('../common/apperror').AppError
mdparser = require('../common/markdownutil').marked
BaseModel = require('./basemodel').BaseModel

class Post extends BaseModel
    
    @describeModel: ->
        models = @getModels()
        forumModule = require('./forum')
        {
            type: Post,
            collection: 'posts',
            discriminator: (obj) -> if obj.type is 'article' then models.Article,
            fields: {
                type: 'string',
                forum: { type: models.Forum.Summary },
                createdBy: { type: models.User.Summary, validate: -> @createdBy.validate() },
                meta: { type: 'array', contents: 'string' },
                createdAt: { autoGenerated: true, event: 'created' },
                updatedAt: { autoGenerated: true, event: 'updated' }
            },
            concurrency: 'optimistic',
            logging: {
                isLogged: true,
                onInsert: 'NEW_POST'
            }
        }



    @search: (criteria, settings, context, db, cb) =>
        limit = @getLimit settings.limit, 100, 1000
                
        params = {}
        for k, v of criteria
            params[k] = v
        
        Post.find params, ((cursor) -> cursor.sort(settings.sort).limit limit), context, db, cb        
        
        
    
    constructor: (params) ->
        @recommendations ?= []
        @meta ?= []
        @tags ?= []
        @rating ?= 1
        @createdAt = Date.now()
        super
        
        
    
    save: (context, db, cb) =>
        #If there is a stub, check if a post with the same stub already exists.
        if @stub
            Post.get { @stub }, {}, db, (err, post) =>
                if not post
                    super
                else
                    cb new AppError "Stub already exists", "STUB_EXISTS"
        else
            super
            
            
exports.Post = Post
