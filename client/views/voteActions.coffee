Template.voteActions.events
  'click #upVote': (e) ->
    film = @filmName
    address = TemplateVar.getFrom '.dapp-address-input .sender-address', 'value'
    amount = 1000000
    if ( address )
      actions.voteForMovie address,@filmName,amount, (err,data)->
        console.log err,data
        if err
          sAlert.error err.toString()
        else
          sAlert.success  'Sent '+amount/1000000+ ' Mwei for '+ film
          topFilmsList.startPolling4PendingTransactions()

    return
  'click #downVote': (e) ->
    film = @filmName
    address = TemplateVar.getFrom '.dapp-address-input .sender-address', 'value'
    amount = 1000000
    if ( address )
      actions.downVoteForMovie address,@filmName,amount, (err,data)->
        console.log err,data
        if err
          sAlert.error err.toString()
        else
          sAlert.success  'Sent '+amount/1000000+ ' Mwei for '+ film
          topFilmsList.startPolling4PendingTransactions()
  'change #claim': (e) ->
    console.log @filmName

Template.voteActions.helpers
  isNotPending: (status)->
    status != 'pending'
