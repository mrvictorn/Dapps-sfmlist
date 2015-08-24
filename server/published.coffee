Meteor.publish 'deployedContracts', ->
  deployedContracts.find()

###
deployedContracts.allow
  insert: (userId, data) ->
    false

###