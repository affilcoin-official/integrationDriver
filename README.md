# Gateway 


## Install 

```
git clone ... /gateway
cd gateway
npm i
vi config.json
```

Change the config

```JSON
{
    "ip": "127.0.0.1",
    "port": 8889,
    "mode": "mainnet",
    "enableTrace": true,
    "mnemonic" : "xmr bch btg ltc eth eos xem ada dash btc zec bcn some"
}
```

Please change `mnemonic` and keep it in secret  
Change `port`

```
npm i pm2 -g
lsc -c server.ls
pm2 start server.js
```


## Examples


### Get Balance

Supports eth, ac

```Javascript 

var serverPath = "http://...."

var superagent = require('superagent');


superagent.get(serverPath + '/balance/eth/0x865d4efe42a80dc42d8449911392fc25ac951c8c').end((err, data) => {

    console.log(data.body);
    
})

```


### Create Account

```Javascript 

var serverPath = "http://...."

var superagent = require('superagent');

superagent.get(serverPath + '/address/eth/0').end((err, data) => {

    console.log(data.body);
    
})

```


### Calc Fee

```Javascript 

var serverPath = "http://...."

var superagent = require('superagent');

var recipient = {
    to: '0x...',
    amount: '1' //ETH,
    feeType: 'cheap'
}

superagent.post(serverPath + '/calc-fee/eth/0', recipient).end((err, data) => {

    console.log(data.body);
    
})

```

### Send Transaction

```Javascript 

var serverPath = "http://...."

var superagent = require('superagent');

var recipient = {
    to: '0x...',
    amount: '1' //ETH,
    feeType: 'cheap'
}

superagent.post(serverPath + '/send/eth/0', recipient).end((err, data) => {

    console.log(data.body);
    
})
```

### Get Block
```
Methods for getting the last block in chain and transactions on the block are similar to Ethereum methods
(eth_blockNumber and eth_getBlockByNumber)
You don't need to use driver for this methods
```
