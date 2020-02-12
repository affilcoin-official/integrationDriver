#reviewed
#tested

require! {
    \prelude-ls : { each }
    \chalk : { green }
}

services = []

log = (err, data)->

export register-service = (name, service)->
    services.push [name, service]

start-service = ([name, service])->
    console.log "[ #{green 'service'} ]", name
    service log

export start-all = ->
    services |> each start-service