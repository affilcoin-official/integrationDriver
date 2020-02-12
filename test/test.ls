require! {
    \superagent : { get, post }
    \../config.json : { port }
    \../web3t.ls
}

url = "http://127.0.0.1:#{port}"

address = "0xa420d12ed0129ae360e504c42d0d340691188aaa"

#err, data <- web3t.eth.get-balance { account: { address } }

#console.log err, data

#return 

err, data <- get "#{url}/balance/btc/39u1ucrhyRh5pKAyp4SmFPb6aWm96fq5gr" .end

console.log err, data.text

return

invoice = 
    amount            : \100
    amount-currency   : \USD
    callback-url      : \https://google.com.ua
    invoice-currency  : \BTC


err, data <- post "#{url}/invoice/create", invoice .end
console.log err, data?data
