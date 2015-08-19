class TopFilmsList
  constructor: ->
    @filmList = new ReactiveVar []
    @pendingTransactions = new ReactiveVar []
    @pollerTimer = undefined
    @SciFiMoviesEvents = SciFiMovies.allEvents()
    @SciFiMoviesEvents.watch (error, event)->
        console.log 'Event fired:', error, event
  getFilmList: ->
    mCount = parseInt SciFiMovies.movie_num()
    list = []
    for i in [0...mCount]
      hexMovie = SciFiMovies.movies i
      list.push
        filmName: web3.toAscii hexMovie
        #score: parseFloat web3.fromWei SciFiMovies.bids(hexMovie),'ether'
        score: SciFiMovies.bids(hexMovie).dividedBy(1000000).toNumber() #Mwei
    list = _.sortBy list, (el)->
      -el.score
    list = _.first list,20
    _.each list,(el,i) ->
      list[i].position = i+1
      #list[i].score = 'pending' if !list[i].score
    return list
  reload: =>
    @filmList.set @getFilmList()
  getPendingTransactions: =>
    pendingTr = web3.eth.getBlock("pending", true).transactions
    @pendingTransactions.set pendingTr
    if not pendingTr.length
      @reload()
      clearInterval @pollerTimer
      Session.set 'waitingPendingTransactions', false
  startPolling4PendingTransactions: =>
    Session.set 'waitingPendingTransactions', true
    @pollerTimer = setInterval ->
      @topFilmsList.getPendingTransactions()
    ,500

@topFilmsList = new TopFilmsList()

Template.toplistmovies.created = ->
  topFilmsList.reload()

Session.setDefault 'waitingPendingTransactions', false

Template.toplistmovies.helpers
  films: ->
    topFilmsList.filmList.get()
  hasFilms: ->
    topFilmsList.filmList.get().length
  pendingTransactions: ->
    topFilmsList.pendingTransactions.get()
  hasPendingTransactions: ->
    Session.get 'waitingPendingTransactions'
