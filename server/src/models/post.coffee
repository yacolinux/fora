utils = require '../lib/utils'
models = require './'
widgets = require '../common/widgets'
ForaModel = require('./foramodel').ForaModel
ForaDbModel = require('./foramodel').ForaDbModel

class Post extends ForaDbModel
    
    @typeDefinition: ->
        {
            name: "post",
            collection: 'posts',
            discriminator: (obj) ->*
                def = yield Post.getTypeUtils().getTypeDefinition(obj.type)
                if def.ctor isnt Post                    
                    throw new Error "Post type definitions must have ctor set to Post"
                def
            schema: {
                type: 'object',        
                properties: {
                    type: { type: 'string' },
                    forum: { $ref: 'forum-summary' },
                    createdBy: { $ref: 'user-summary' },
                    meta: { type: 'array', items: { type: 'string' } },
                    tags: { type: 'array', items: { type: 'string' } },
                    stub: { type: 'string' },
                    recommendations: { type: 'array', items: { $ref: 'user-summary' } },            
                    state: { type: 'string', enum: ['draft','published'] },
                    savedAt: { type: 'integer' }
                },
                required: ['type', 'forum', 'createdBy', 'meta', 'tags', 'stub', 'recommendations', 'state', 'savedAt']
            },
            autoGenerated: {
                createdAt: { event: 'created' },
                updatedAt: { event: 'updated' }
            },            
            trackChanges: true,
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
        
    
    
    @create: (params) ->*
        typeDef = yield (yield @getTypeDefinition()).discriminator params
        post = new Post params
        post.getTypeDefinition = ->*
            typeDef
        post


    
    constructor: (params) ->
        super
        @recommendations ?= []
        @meta ?= []
        @tags ?= []
       
    
    
    addMetaList: (metaList) =>*
        @meta = @meta.concat (m for m in metaList when @meta.indexOf(m) is -1)
        yield @save()
    


    removeMetaList: (metaList) =>*
        @meta = (m for m in @meta when metaList.indexOf(m) is -1)
        yield @save()
        
    

    save: (context, db) =>*
        { context, db } = @getContext context, db
        
        #If the stub has changed, we need to check if it's unique
        @stub ?= utils.uniqueId(16)

        result = yield super(context, db)
        
        if @state is 'published'
            forum = yield models.Forum.getById @forum.id, context, db
            yield forum.refreshSnapshot()
        
        result
            


    #Dummy. So that a data error doesn't blow up the app.
    getTemplate: (name = "standard") =>
        @parseTemplate {
            widget: "postview",                    
            itemPane: [],
            sidebar: []
        }                
        

    
    parseTemplate: (data) =>    
        if data instanceof Array
            (@parseTemplate(i) for i in data)
        else if data.widget
            ctor = if typeof data.widget is 'string' then @getWidget(data.widget) else data.widget
            params = {}
            for k, v of data
                if k isnt 'widget'
                    params[k] = @parseTemplate v
            new ctor params
        else
            data
                


    getWidget: (name) =>
        switch name
            when 'image'
                widgets.Image
            when 'cover'
                widgets.Cover
            when 'heading'
                widgets.Heading
            when 'authorship'
                widgets.Authorship
            when 'html'
                widgets.Html
            when 'text'
                widgets.Text
            when 'postview'
                widgets.PostView
            when 'cardview'
                widgets.CardView
                

    
    getView: =>
        
                
            
exports.Post = Post
