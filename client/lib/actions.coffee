@actions = {}

actions.voteForMovie = (account,movieName,weiValue,callback)->
  SciFiMovies.vote web3.toHex(movieName),
    from:account,
    value:weiValue,
    gas:200000
  ,
    callback