class TopFilmsList
  constructor: ->
    @filmList = new ReactiveVar []
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
      list[i].score = 'pending' if !list[i].score
    return list
  reload: =>
    @filmList.set @getFilmList()

@topFilmsList = new TopFilmsList()

Template.toplistmovies.created = ->
  topFilmsList.reload()

Template.toplistmovies.helpers
  films: ->
    return topFilmsList.filmList.get()
  hasFilms: ->
    return topFilmsList.filmList.get().length
