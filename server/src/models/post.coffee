utils = require '../common/utils'
mdparser = require('../common/lib/markdownutil').marked
DatabaseModel = require('../common/data/databasemodel').DatabaseModel
models = require('./')
Q = require('../common/q')

class Post extends DatabaseModel
    
    @describeType: {
        type: @,
        collection: 'posts',
        discriminator: (obj) -> if obj.type is 'article' then models.Article else Post
        fields: {
            type: 'string',
            forum: { type: models.Forum.Summary },
            createdBy: { type: models.User.Summary },
            meta: { type: 'array', contentType: 'string' },
            stub: { type: 'string' },
            state: { type: 'string', validate: -> ['draft','published'].indexOf(@state) isnt -1 },
            title: { type: 'string', required: false },
            recommendations: { type: 'array', contentType: models.User.Summary },                                
            publishedAt: { type: 'number', required: false, validate: -> not (@state is 'published' and not @publishedAt) },
            createdAt: { autoGenerated: true, event: 'created' },
            updatedAt: { autoGenerated: true, event: 'updated' }
        },
        logging: {
            onInsert: 'NEW_POST'
        }
    }



    @search: (criteria, settings, context, db) =>
        limit = @getLimit settings.limit, 100, 1000
                
        params = {}
        for k, v of criteria
            params[k] = v
        
        Post.find params, ((cursor) -> cursor.sort(settings.sort).limit limit), context, db
        

        
    @getLimit: (limit, _default, max) ->
        result = _default
        if limit
            result = limit
            if result > max
                result = max
        result    


    
    constructor: (params) ->
        super
        @recommendations ?= []
        @meta ?= []
        @tags ?= []
        @rating ?= 1
        @createdAt ?= Date.now()
        
    
    
    addMetaList: (metaList) =>
        (Q.async =>
            @meta = @meta.concat (m for m in metaList when @meta.indexOf(m) is -1)
            yield @save()
        )()
        


    removeMetaList: (metaList) =>
        (Q.async =>
            @meta = (m for m in @meta when metaList.indexOf(m) is -1)
            yield @save()
        )()

        
    
    save: (context, db) =>
        { context, db } = @getContext context, db
        (Q.async =>        
            #Make sure we aren't overwriting another post with the same stub in the same forum.
            post = yield Post.get({ @stub, 'forum.id': @forum.id }, context, db)    
            if post and (post._id.toString() isnt @_id?.toString()) #Same post?
                if @_id
                    #We prefix the id so that sameness goes away                    
                    @stub = @_id?.toString() + "-" + @stub
                else
                    #No id yet. So, we'll do this once the post gets saved and gets an id.
                    stub = @stub
                    @stub = undefined
            post = yield super(context, db)
            if stub
                post.stub = post._id.toString() + "-" + stub
                post = yield post.save()

            if @state is 'published'
                forum = yield models.Forum.getById(@forum.id, context, db)
                forum.refreshSnapshot()
            
            return post)()

        
            
exports.Post = Post
