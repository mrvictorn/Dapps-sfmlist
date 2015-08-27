Meteor.startup ()->
  EthContracts.once 'contractReady'+'SciFiMovies',(contract)->
    console.log contract
  EthContracts.bootstrap