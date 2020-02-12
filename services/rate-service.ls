require! {
    \superagent : { get }
    \prelude-ls : { map, obj-to-pairs, pairs-to-obj, filter }
    \../config.json : { reload-rates-timer }
    \../support.ls
}

store = 
    rates: null
export get-rates-clean = (cb)-> 
    return cb "Not ready yet" if store.rates is null
    cb null, store.rates 
export get-rates = (cb)-> 
    err, rates <- get-rates-clean
    return cb err if err?
    cb null, { data: rates }



load-rates = (cb)->
    err, resp <- get "https://api.coinmarketcap.com/v2/ticker/?convert=EUR" .end
    return cb err if err?
    return cb "Data field is not an object" if typeof! resp.body.data isnt \Object
    result =
        resp.body.data
            |> obj-to-pairs 
            |> filter -> support.index-of(it.1.symbol) > -1
            |> map -> [it.1.symbol, it.1]
            |> pairs-to-obj
    cb null, result

start-processing = (cb)->
    err, rates <- load-rates
    return cb err if err?
    store.rates = rates
    cb null
export rate-service = (cb)->
    err <- start-processing
    <- set-timeout _, reload-rates-timer
    err <- rate-service
    
