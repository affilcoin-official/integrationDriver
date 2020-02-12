require! {
    \./db.ls : { invoicedb, indexdb }
    \./web3t.ls
    \./log.ls : { trace }
    \./number.ls : { times, div }
    \./services/rate-service.ls : { get-rates }
    \./create-index.ls
    \./config.json : { mnemonic }
    \./guid.ls
    \./support.ls
}

value-to-amount = (value)->
    value `times` 100


convert-from-fiat = ({ amount, amount-currency, invoice-currency }, cb)->
    #err, rates <- get-rates
    #return cb err if err?
    return cb "usd, eur are not supported here" if amount-currency in <[ usd eur ]>
    price = 
        |  invoice-currency in <[ usd eur ]> => rates.data[invoice-currency]?quotes?[amount-currency]?price
        | _ => amount-currency
    trace "price #{price}", rates
    return cb "Price is not defined for #{invoice-currency}.#{amount-currency}" if not price?
    result = amount `div` price
    cb null, result

convert-from-crypto = ({ amount, amount-currency, invoice-currency }, cb)->
    return cb "amount-currency should be equal to invoice-currency" if amount-currency isnt invoice-currency
    return cb "invoice-currency should be in #{support.join ','}" if invoice-currency not in support
    cb null, amount
    
convert = (invoice-request, cb)->
    return convert-from-crypto invoice-request, cb if invoice-request.amount-currency in support
    convert-from-fiat invoice-request, cb


module.exports = (invoice-request, cb)->
    { amount, amount-currency, callback-url, invoice-currency } = invoice-request
    return cb "amount is required" if not amount?
    return cb "amount-currency is required" if not amount-currency?
    return cb "callback-url is required" if not callback-url?
    return cb "invoice-currency is required" if not invoice-currency?
    err, invoice-amount <- convert invoice-request
    return cb err if err?
    err, index <- create-index
    token = invoice-currency.to-lower-case!
    coin = web3t[token]
    return cb "There is not web3 provider for #{token}" if not coin?
    err, account <- coin.create-account { mnemonic, index }
    return cb err if err?
    status = \new
    deadline = 100
    _id = guid!
    invoice = { _id, amount: invoice-amount, currency: invoice-currency, account.address, index, status, deadline, callback-url }
    err <- invoicedb.save invoice
    return cb err if err?
    trace "invoice", invoice
    cb null, invoice
    
    
    
    