require! {
    \big.js : BN
}
operation = (func, a, b)-->
    return null if not a?
    return null if not b?
    try
        #console.log "#{a} `#{func}` #{b}"
        new BN(a.to-string!)[func](b.to-string!).toFixed!
    catch err 
        throw "#err with #{a} `#{func}` #{b}"
export minus = operation \minus
export plus  = operation \plus
export div   = operation \div
export times = operation \times
export mul = times
export round = (x, y)->
    new BN(x).round(y).toFixed!