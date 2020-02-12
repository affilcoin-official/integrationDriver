require! {
    \../db.ls : { invoicedb }
    \../web3t.ls
    \../config.json : { mnemonic }
    \../log.ls : { trace }
    \superagent : { post }
    \../log.ls : { trace }
}

transfer-root = (invoice, cb)->
    trace "transfer root #{invoice.transfer-deadline}"
    invoice.transfer-deadline = invoice.transfer-deadline ? 10
    invoice.transfer-status = invoice.transfer-status ? \new
    err <- invoicedb.save invoice
    return cb "status is not new" if invoice.transfer-status isnt \new
    return cb "deadline is reached" if invoice.transfer-deadline <= 0
    token = invoice.currency.to-lower-case!
    coin = web3t[token]
    return cb "coin not found" if not coin?
    err, account <- coin.create-account { invoice.index, mnemonic }
    return cb err if err?
    err, root-account <- coin.create-account { index: 0, mnemonic }
    return cb err if err?
    err <- coin.send-all-funds { account, to: root-account.address }
    trace "send-all-funds #{err}"
    invoice.transfer-deadline -= 1
    invoice.transfer-status = \failed if invoice.transfer-deadline is 0
    invoice.transfer-status = \done if not err?
    err <- invoicedb.save invoice
    return cb err if err?
    cb null
    
process-transfers = ([invoice, ...invoices], cb)->
    return cb null if not invoice?
    err <- transfer-root invoice
    err <- process-transfers invoices
    cb null


inform-callback = (invoice, cb)->
    trace "inform callback #{invoice.callback-deadline} (#{invoice.callback-url})"
    invoice.callback-deadline = invoice.callback-deadline ? 10
    invoice.callback-deadline -= 1
    invoice.status = \uninformed if invoice.callback-deadline <= 0
    err <- invoicedb.save invoice
    return cb "deadline is reached" if invoice.callback-deadline <= 0
    return cb null if (invoice.callback-url ? "").length is 0
    return cb err if err?
    err, data <- post invoice.callback-url, invoice .end
    invoice.status = \uninformed if invoice.callback-deadline is 0
    invoice.status = \informed if not err?
    err <- invoicedb.save invoice
    return cb err if err?
    cb null
    

process-balance = (invoice, cb)->
    trace "process balance"
    return cb "invoice deadline cannot be less than 0" if invoice.deadline < 1
    token = invoice.currency.to-lower-case!
    coin = web3t[token]
    return cb "coin not found" if not coin?
    err, account <- coin.create-account { invoice.index, mnemonic }
    return cb err if err?
    err, balance <- coin.get-balance { account }
    invoice.deadline = invoice.deadline - 1
    invoice.status = \old if invoice.deadline is 0
    err <- invoicedb.save invoice
    return cb err if err?
    trace "got balance", { balance, invoice.deadline }
    return cb "Balance is less than required" if +balance < +invoice.amount
    invoice.status = \paid
    err <- invoicedb.save invoice
    return cb err if err?
    err <- inform-callback invoice
    err <- transfer-root invoice
    cb null

process-invoice = (invoice, cb)->
    trace "process invoice"
    process-balance invoice, cb if invoice.status is \new
    inform-callback invoice, cb if invoice.status is \paid

process-invoices = ([invoice, ...rest], cb)->
    return cb null if not invoice?
    err <- process-invoice invoice
    err <- process-invoices rest
    cb err

start-processing = (cb)->
    err, invoices <- invoicedb.find { status: $in: <[ new paid ]> }
    return cb err if err?
    #trace "invoices #{invoices.length}"
    err <- process-invoices invoices
    err, invoices <- invoicedb.find { transfer-status: 'new' }
    return cb err if err?
    err <- process-transfers invoices
    cb null

export invoice-service = (cb)->
    err <- start-processing
    <- set-timeout _, 3000
    err <- invoice-service