require! {
    \prelude-ls : { each }
    \chalk : { green, yellow, red }
    \./guid.ls
    \fs : { write-file-sync }
    \node-serialize : { serialize }
    \./config.json : { enable-trace }
}

export stringify = (data)->
    return data if typeof! data in <[ Number String ]>
    try
        return serialize data
    catch err
        return JSON.stringify data
export trace = (str, data)->
    return if enable-trace isnt yes
    text = stringify data
    to-file = text.length > 40
    name = "#{__dirname}/logs/#{guid!}.txt"
    if to-file
        write-file-sync name, text
    res =
        | to-file => name
        | _ => text
    console.log "*", yellow(str), res