@actions = {}

actions.voteForMovie = (account,movieName,weiValue,callback)->
  SciFiMovies.vote.sendTransaction web3.toHex(movieName.trim()),
    from:account,
    value:weiValue,
    gas:200000
  ,
    callback

actions.downVoteForMovie = (account,movieName,weiValue,callback)->
  SciFiMovies.downvote.sendTransaction web3.toHex(movieName.trim()),
    from:account,
    value:weiValue,
    gas:300000
  ,
    callback