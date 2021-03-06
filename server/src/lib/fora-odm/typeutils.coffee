utils = require '../utils'

class TypeUtils
    

    isPrimitiveType: (type) ->      
        ['string', 'number', 'integer', 'boolean', 'array'].indexOf(type) > -1   


    
    isCustomType: (type) ->
        not @isPrimitiveType type



    completeTypeDefinition: (def, ctor) =>
        def.ctor = ctor

        def.schema ?= {} 
        def.schema.properties ?= {}
        def.schema.required ?= []

        if def.autoGenerated
            for k, v of def.autoGenerated
                def.schema.properties[k] = { type: 'integer' }
                def.schema.required.push k
        
        def
        

    
    resolveReferences: =>*
        for name, def of TypeUtils.typeCache
            yield @resolveReferencesInDef def
        return
        
    
    
    resolveReferencesInDef: (def) =>*
        fn = (val, prop) =>*
            if val.type is 'object'
                if val.properties
                    subTypeDef = { 
                        name: "<anonymous>", 
                        schema: {
                            type: val.type,
                            properties: val.properties,
                            required: val.required
                        }
                    }
                    prop.typeDefinition = subTypeDef
                    yield @resolveReferencesInDef subTypeDef
            else if val.$ref
                prop.typeDefinition = yield @getTypeDefinition val.$ref
        
        
        for property, value of def.schema.properties
            if value.type is 'array'
                yield fn value.items, def.schema.properties[property].items
            else
                yield fn value, def.schema.properties[property]
        

    
    buildTypeCache: =>*
        TypeUtils.typeCache = {}
        
        if @getCacheItems
            items = yield @getCacheItems()

            for modelName, def of items
                utils.log "loading type #{modelName}"     
                TypeUtils.typeCache[modelName] = def        
        
            yield @resolveReferences()
            
        utils.log 'Type loading complete'



    getTypeDefinitions: =>
        TypeUtils.typeCache



    getTypeDefinition: (name, dynamicResolutionContext = {}) =>*
        #First check if it resolves in type cache
        #Then check if it resolves in the context
        #Otherwise build dynamic typedef
        return (TypeUtils.typeCache[name] ? dynamicResolutionContext[name]) ? yield @resolveDynamicTypeDefinition(name, dynamicResolutionContext)

    

    init: (name) =>*
        throw new Error "This method must be overridden in derived class"



    resolveDynamicTypeDefinition: (name) =>*
        throw new Error "This method must be overridden in derived class"



module.exports = TypeUtils
