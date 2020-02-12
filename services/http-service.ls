require! {
    \http
    \https
    \cors
    \express
    \body-parser
    \express-validation : validate
    \../config.json : { rate-limit, port, ip, portSSL, enable-static }
    \../web3t.ls
    #\./rate-service.ls : { get-rates }
    \../config.json : { mnemonic }
    \../log.ls : { trace }
    \web3 : Web3
}

app = express!

restify-callback = (res)-> (err, data)->
   trace \resp-err, "#{err.message ? err }" if err?
   trace \resp, data  if not err?
   return res.status 400 .send({ error: "#{err.message ? err }" }) if err?
   res.status 200 .send { data }

get-balance = ({ token, address }, cb)->
    return cb "token is required" if not token?
    return cb "not found #{token}" if not web3t[token]?
    return cb "not found #{address}" if not address?
    account = { address }
    err, data <- web3t[token].get-balance { account }
    return cb err if err?
    cb null, data

get-address = ({ index, token }, cb)->
    return cb "index is required" if not index?
    return cb "index should an integer" if index.match(/^[0-9]+$/) is null
    return cb "not found #{token}" if not web3t[token]?
    err, account <- web3t[token].create-account { index: +index, mnemonic }
    return cb err if err?
    cb null, account.address



send = ({ params, body }, cb)->
    { index, token } = params
    { to, fee-type, amount } = body
    return cb "index is required" if not index?
    return cb "index should an integer" if index.match(/^[0-9]+$/) is null
    return cb "token is required" if not token?
    return cb "to is required" if not to?
    return cb "type is required" if not fee-type?
    return cb "not found #{token}" if not web3t[token]?
    return cb "amount is required" if not amount?
    err, account <- web3t[token].create-account { index: +index, mnemonic }
    return cb err if err?
    #err, tx <- web3t[token].send-transaction { account, amount, fee-type, to }
    #return cb err if err?
    #cb null, tx
    
    web3 = new Web3("https://explorer.affilcoin.net/api")
    web3.eth.accounts.wallet.clear!
    accountFrom = web3.eth.accounts.privateKeyToAccount(account.private-key)
    web3.eth.accounts.wallet.add(accountFrom)
    tx =
          from: account.address
          to: to
          value: web3.utils.toWei(amount, 'ether')
          gas: 21000
          gasPrice: 8
          chainId: 1
    err, res <- to-callback web3.eth.sendTransaction(tx)
    cb err, res
    
to-callback = (p, cb)->
    p.catch (res)->
        cb res
    p.then (res)->
        cb null, res
    
    

calc-fee = ({ params, body }, cb)->
    { index, token } = params
    { to, fee-type, amount } = body
    return cb "index is required" if not index?
    return cb "index should an integer" if index.match(/^[0-9]+$/) is null
    return cb "token is required" if not token?
    return cb "to is required" if not to?
    return cb "type is required" if not fee-type?
    return cb "not found #{token}" if not web3t[token]?
    return cb "amount is required" if not amount?
    err, account <- web3t[token].create-account { index: +index, mnemonic }
    return cb err if err?
    err, fee <- web3t[token].calc-fee { account, amount, fee-type, to }
    return cb err if err?
    cb null, fee

app
  .use body-parser.json { limit: \50mb }
  .use cors!
  .get \/balance/:token/:address , (req, res)->
      get-balance req.params, restify-callback(res)
  .get \/address/:token/:index , (req, res)->
      get-address req.params, restify-callback(res)
  .post \/send/:token/:index , (req, res)->
      send req, restify-callback(res)
  .post \/calc-fee/:token/:index , (req, res)->
      calc-fee req, restify-callback(res)
  
      
      


export start-http-service = (cb)->
    http.create-server(app).listen port, ip


test =->
    web3 = new Web3("https://explorer.affilcoin.net/api")
    web3.eth.accounts.wallet.clear!
    accountFrom = web3.eth.accounts.privateKeyToAccount("0xaa9037ff29d07dc5937d008b4a28dca371ffa146304213a57afdaf0d53fd6140")
    web3.eth.accounts.wallet.add(accountFrom)
    tx =
          from: accountFrom.address
          to: \0xd18D7B149850D0Ca719B20592Cd1E022c502DBC6
          value: web3.utils.toWei('0.1', 'ether')
          gas: 21000
          gasPrice: 8
          chainId: 1
    err, res <- web3.eth.sendTransaction(tx)
    console.log err, res
