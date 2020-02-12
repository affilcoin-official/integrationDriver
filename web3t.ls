require! {
    \./db.ls : { transdb }
    \./config.json : { mode }
    \web3t : web3t-builder
    \./plugins/ac.json
}

module.exports = {}

plugins= { ac }

err, web3t <- web3t-builder { mode, plugins }
throw err if err?
module.exports <<<< web3t