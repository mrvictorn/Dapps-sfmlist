# deployedcontract =
#   sourceFileName:
#   sourceFileHash:
#   name:
#   version:
#   deployedAddress:
#   code:
#   abi:
#
#


Meteor.subscribe 'deployedContracts'


@deployedContracts = new Mongo.Collection 'deployedContracts'