conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
utils = require('../../lib/utils')
auth = require '../../common/web/auth'
widgets = require '../../common/widgets'

exports.index = auth.handler ->*
    editorsPicks = yield models.Post.find { meta: 'pick', 'forum.network': @network.stub }, ((cursor) -> cursor.sort({ _id: -1 }).limit 1), {}, db
    featured = yield models.Post.find { meta: 'featured', 'forum.network': @network.stub }, ((cursor) -> cursor.sort({ _id: -1 }).limit 12), {}, db
    featured = (f for f in featured when (x._id for x in editorsPicks).indexOf(f._id) is -1)

    for post in editorsPicks.concat(featured)
        template = widgets.parse yield post.getTemplate 'card'
        result = template.render {
            post,
            forum: post.forum,
        }
        post.html = result.html
        
    coverContent = "<h1>Editor's Picks</h1>
                    <p>Fora is a place to share ideas. To Discuss and to debate. Everything on Fora is free.</p>"

    yield @render 'home/index', { 
        editorsPicks,
        featured,
        pageName: 'home-page',
        pageLayout: {
            type: 'single-section-page single-column with-cover auto-cover',
            cover: {
                image: { src: '/public/images/cover.jpg' },
            },
            coverContent
        }
    }



exports.login = ->*
    yield @render 'home/login', { 
        pageName: 'login-page', 
        pageType: 'single-section-page', 
    }

