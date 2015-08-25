PATH_CONTRACTS_DIR = '../../../../../contracts'
DEPLOY_GAS = 400000
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
# deployedcontract = [
#    {
#     name:
#     address:
#     code:
#     codeHash:
#     deployVersion:
#     abi:
#   },...
# ]
#



@Ether =
  deployedContracts: {} # to use on server side
  systemContracts: new Mongo.Collection 'deployedContracts' # to use on client side (abi,code,address)
  systemContractsFiles: new Mongo.Collection 'contractsFiles'
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
          contractStruct.address = myContract.address
          contractStruct.contract = myContract
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
    debugger
    oldFiles = Ether.systemContractsFiles.find({type:'sol',sourceFileName: {$in: solFileNames}}).fetch()
    oldContracts = Ether.systemContracts.find({type:'sol'}).fetch()
    files2BeCompiled = _.filter solFilesList, (oFile) ->
      return not _.findWhere(oldFiles,{sourceFileName: oFile.fileName,sourceFileHash: oFile.sourceFileHash})
      # search for files with newhashes, and without
    if files2BeCompiled?.length and Ether.connect2Node(NODE_URL)
      ## we have some work here!
      async.map files2BeCompiled, (oFile,asyncCB) ->
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
                    isCompiled: true
                asyncCB(null, {type:'sol',sourceFileName:oFile.fileName,sourceFileHash:oFile.sourceFileHash, contracts:contracts});
              return
          else
            asyncCB()
      ,
        (err,data) ->
          if err then return console.log 'Got error while compiling contracts',err
          if not data?.length then return console.log 'Got no file contracts to re/deploy',data
          ## saving here compiled files to collection
          Fiber( ()->
            data.forEach (file)->
              Ether.systemContractsFiles.update {type:'sol',sourceFileName: file.sourceFileName},
                $inc:
                  compiledVersion: 1
                $set:
                  contacts:file.contracts
                  sourceFileHash: file.sourceFileHash
              ,
                upsert: true
          ).run()
          debugger
          contracts2Check = []
          contracts2Check.push file.contracts for file in data
          contracts2Check = _.flatten contracts2Check
          console.log contracts2Check
          contractNames = []
          contracts2Check.forEach (oContract,i) ->
            contractNames.push oContract.name
            oContract.codeHash = CryptoJS.MD5(oContract.code).toString()
          contracts2Check = _.uniq contracts2Check,(el)-> el.codeHash
          oldContracts = _.filter oldContracts, (el)->
            return true if not el.address  ## old, compiled but undeployed contracts
            return false if _.indexOf(contractNames,el.name) == -1
            return true
          contracts2BeDeployed = _.filter contracts2Check, (oContract) ->
            return not _.findWhere oldContracts, {codeHash: oContract.codeHash, name: oContract.name }

          console.log contracts2BeDeployed
          #check here for changed MD5(source) changed and not deployed contracts
          contracts2BeDeployed.forEach (oContract)->
            Ether.deployContract oContract ,(err,deployedContract) ->
              if err then return console.log 'Received error while deploying contract ',err,oContract
              Ether.deployedContracts[deployedContract.name] = deployedContract.contract
              Fiber( ()->
                Ether.systemContracts.update {type:'sol',name: deployedContract.name},
                  $inc:
                    deployVersion: 1
                  $set:
                    code: deployedContract.code
                    abi: deployedContract.abi
                    codeHash: deployedContract.codeHash
                    address: deployedContract.address
                ,
                  upsert: true
              ).run()
              return



Meteor.publish 'deployedContracts', ()->
  console.log 'publishing deployedContracts ', Ether.deployedContracts
  return Ether.systemContracts.find {}