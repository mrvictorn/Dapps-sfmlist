Template.vote.events
  'click #vote': (event)->
    address = TemplateVar.getFrom '.dapp-address-input .sender-address', 'value'
    amount = parseInt document.getElementById("amount").value
    film = document.getElementById("newFilmName").value
    if (amount && film && address )
      actions.voteForMovie address,film,amount*1000000, (err,data)->
        console.log err,data
        if err
          sAlert.error err.toString()
        else
          sAlert.success  'Sent '+amount+ ' Mwei for '+ film
          topFilmsList.startPolling4PendingTransactions()

    return

Template.vote.helpers
  testAccount: ->
    web3.eth.accounts[0]
  testAccBalance: ->
    web3.fromWei(web3.eth.getBalance(web3.eth.accounts[0]), "ether") + " ether"