class TopFilmsList
  constructor: ->
    @filmList = new ReactiveVar []
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
    _.each list,(el,i) ->
      list[i].position = i+1
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
