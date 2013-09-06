DatabaseModel = require('../common/data/databasemodel').DatabaseModel
models = require('./')
Q = require('../common/q')

class Membership extends DatabaseModel
    
    @describeModel: {
        type: @,
        collection: 'memberships',
        fields: {
            user: { type: models.User.Summary },
            forum: { type: models.Forum.Summary },
            roles: { type: 'array', contentType: 'string' }
            createdAt: { autoGenerated: true, event: 'created' },
            updatedAt: { autoGenerated: true, event: 'updated' }
        },
    }    


exports.Membership = Membership
