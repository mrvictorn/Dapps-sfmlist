PATH_CONTRACTS_DIR = '../../../../../contracts'
DEPLOY_GAS = 300000
NODE_URL = 'http://localhost:8101'
Fiber = Npm.require 'fibers'


_loadSource = (sourceFile) ->
  fs.readFileSync path.join(PATH_CONTRACTS_DIR,sourceFile),{encoding: 'utf-8'}
# _getSolsList
# returns [{fileName:file.sol},...]
_getSolsList = () ->
  fList = fs.readdirSync PATH_CONTRACTS_DIR
  fileext = /(.sol)/i
  sols = ({fileName:name} for name in fList when name.match fileext )


#FYI collection.deployedContracts contains
# deployedcontract =
#   sourceFileName:
#   sourceFileHash:
#   deployedVersion:
#   compiledVersion:
#   contacts: [{
#     name:
#     deployedAddress:
#     code:
#     abi:
#     isDeployed:
#     isCompiled:
#
#


@Ether =
  deployedContracts: new Mongo.Collection 'deployedContracts'
  connect2Node: (nodeUrl) ->
    web3.setProvider new web3.providers.HttpProvider(nodeUrl)
    if web3.isConnected()
      web3.eth.defaultAccount = web3.eth.coinbase
      return true
    else
      return false

  compileContract: (source, cb) ->
    web3.eth.compile.solidity source, (err, data) ->
      #console.log 'Compile result: ',err, data
      cb err, data
  deployContract: (contractStruct, cb) ->
    contract = web3.eth.contract contractStruct.abi
    contract.new
      data: contractStruct.code
      gas: DEPLOY_GAS
      from: web3.eth.defaultAccount
    ,
      (err, myContract) ->
        if err then return cb err
        if not myContract.address
          console.log 'Contact ', contractStruct.name, ' got transaction hash:', myContract.transactionHash
        else
          contractStruct.address = address
          cb err, contractStruct
    return

  onStart: =>
    # -- check if there are some contracts in deployedContracts collection,
    # get list of contracts from ../contracts, check their hashes,
    # if hashes are different, try to compile and redeploy them
    solFilesList =  _getSolsList()
    if not solFilesList
      console.log "No solidity files found in #{PATH_CONTRACTS_DIR}"
      return
    solFileNames =[]
    solFilesList.forEach (oFile,i) ->
      solFileNames.push oFile.fileName
      fileBuff = _loadSource oFile.fileName
      if fileBuff
        solFilesList[i].sourceFileHash = CryptoJS.MD5(fileBuff).toString()
        solFilesList[i].source = fileBuff

    oldFiles = Ether.deployedContracts.find({sourceFileName: {$in: solFileNames}}).fetch()
    debugger
    files2BeCompiled = _.filter solFilesList, (oFile) ->
      return true if not oFile.deployedAddress
      return ! _.findWhere oldFiles, {sourceFileName: oFile.sourceFileName, sourceFileHash: oFile.sourceFileHash }
      # search for files with newhashes, and without
    if files2BeCompiled?.length and Ether.connect2Node(NODE_URL)
      ## we have some work here!
      async.map files2BeCompiled,
        (oFile,asyncCB) ->
          file = oFile
          if oFile.source
            Ether.compileContract oFile.source, (err,compiled)->
              if err then asyncCB()
              else
                contracts = []
                contrNames = Object.getOwnPropertyNames compiled;
                contrNames.forEach (contractName)->
                  compiledContr = compiled[contractName];
                  contracts.push
                    code: compiledContr.code
                    name: contractName
                    abi: compiledContr.info?.abiDefinition
                    isDeployed: false
                    isCompiled: true
                asyncCB(null, {sourceFileName:oFile,contracts:contracts});
              return
                #deployedContracts.update
                #  sourceFileName: file.sourceFileName
          else
            asyncCB()
        , (err,data) ->
          debugger
          if err
            return console.log 'Received error during compiling new contacts', err

          async.map data, # iterate for files
            (aFile, asyncCB) ->
              arrContracts = aFile.
              async.map arrContracts,
                Ether.deployContract
              ,
                (err,data) ->
                 asyncCB(err,data)
          ,
            (err,data) ->
              console.log 'Time to upsert data to collection',err,data
              #TODO upsert data to collection
          ###
            Fiber( ()->
            Ether.deployedContracts.update {sourceFileName: file.sourceFileName},
              sourceFileHash: file.sourceFileHash
              compiledVersion: 1
              contacts:contracts
            ,
              upsert: true
          ).run()
          console.log err,data
          ###






###


var contracts = Object.getOwnPropertyNames(compiled);
contracts.forEach(function (contract) {
var abiDefinition = compiled[contract];
res.push(abiDefinition);
});
return res;
}

function deployAbiContract(abi, initiatorAddr,cb) {
fContract = web3.eth.contract(abi.info.abiDefinition);
fContract.new({data: abi.code, gas: 300000, from: initiatorAddr},cb);
}
###