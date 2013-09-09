moment = require('../common/lib/moment')
DatabaseModel = require('../common/data/databasemodel').DatabaseModel
models = require('./')

class Message extends DatabaseModel
    
    @describeType: {
        type: @,
        collection: 'messages',
        fields: {
            userid: 'string',
            type: { type: 'string', validate: -> ['message', 'global-notification', 'user-notification'].indexOf(@type) isnt -1 },
            to: { useCustomValidationOnly: true, validate: -> if @type is 'user-notification' or @type is 'message' then @to.validate() },
            from: { useCustomValidationOnly: true, validate: -> if @type is 'message' then @from.validate() },
            data: 'object',
            createdAt: { autoGenerated: true, event: 'created' },
            updatedAt: { autoGenerated: true, event: 'updated' }
        }
    }
        
        
    
    format: (_format) =>
        try
            switch _format
                when 'timeline'
                    switch @reason
                        when 'new-forum'
                            user = @data.forum.createdBy
                            {                        
                                subject: {
                                    thumbnail: user.thumbnail,
                                    name: user.name,
                                    link: "/~#{user.username}"
                                },
                                verb: "added a new forum",
                                object: {
                                    thumbnail: @data.forum.icon,
                                    name: @data.forum.name,
                                    link: "/#{@data.forum.stub}"
                                },
                                time: moment(@timestamp).from(Date.now())
                            }
                        when 'published-post'
                            user = @data.post.createdBy
                            {
                                subject: {
                                    thumbnail: user.thumbnail,
                                    name: user.name,
                                    link: "/~#{user.username}"
                                },
                                verb: "published",
                                object: {
                                    name: @data.post.title,
                                    link: "/#{@data.post.forum.stub}/#{@data.post._id}"
                                },
                                time: moment(@timestamp).from(Date.now())
                            }                   
        catch error
            return ''                
            
            
    
exports.Message = Message
