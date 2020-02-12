require! {
    \./db.ls : { indexdb }
}


state=
    busy: no

create-index = (cb)->
    err <- indexdb.save { }
    return cb err if err?
    err, stats <- indexdb.stats
    return cb err if err?
    return cb "cannot be 0" if stats.count is 0
    cb null, stats.count

create-index-wrapper = (cb)->
    return cb "Busy" if state.busy
    state.busy = yes
    err, index <- create-index
    state.busy = no
    return cb err if err?
    cb null, index
    
module.exports = create-index-wrapper