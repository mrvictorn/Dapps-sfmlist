###
Meteor.methods
  getFilmList: ->
    mCount = sciFiContract.movie_num()
    list = []
    _addFilm = (i) ->
      hexMovie = sciFiContract.movies i
      list.push(
        filmName: web3.toAscii hexMovie
        score: parseFloat web3.fromWei sciFiContract.bids(hexMovie),'ether'
      )
    _addFilm ind for ind in [0..mCount-1]
    return list


###