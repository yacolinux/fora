#neat trick via http://oranlooney.com/functional-javascript
__Clone = ->
clone = (obj) ->
    __Clone.prototype = obj
    new __Clone


deepCloneObject = (obj) ->
    if (obj is null) or (typeof(obj) isnt 'object')
        obj
    else
        temp = {}

        for key, value of obj
            temp[key] = deepCloneObject(value)
        temp
    

extend = (target, source) ->
    for key, val of source
        if not target[key]?
            target[key] = val
    target
    

cloneAndExtend = (target, parent) ->
    result = clone(parent)
    extend result, target
    result


uniqueId = (length=16) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length
  

fixUrl = (url) ->
    if /http:\/\//.test(url)
        url    
    else
        "http://#{url}"        


log = (msg) ->
    console.log msg
    
        
dumpError = (err) ->
    if err
        log err.stack ? 'There is no stack trace.'
        if err.details
            log err.details
    else
        log 'Error is null or undefined.'
    
exports.clone = clone
exports.deepCloneObject = deepCloneObject
exports.extend = extend
exports.cloneAndExtend = cloneAndExtend
exports.uniqueId = uniqueId
exports.fixUrl = fixUrl
exports.log = log
exports.dumpError = dumpError
