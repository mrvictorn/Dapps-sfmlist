Template.vote.events
  'submit .vote': (event)->
    event.preventDefault()
    address = TemplateVar.getFrom '.dapp-address-input .sender-address', 'value'
    amount = parseInt event.target.amount.value
    film = event.target.film.value
    if (amount && film && address )
      actions.voteForMovie address,film,amount, (err,data)->
        console.log err,data
        if err
          sAlert.error err.toString()
        else  topFilmsList.reload()
    return
