web3.setProvider(new web3.providers.HttpProvider('http://localhost:8101'));web3.eth.defaultAccount = web3.eth.accounts[0];SciFiMoviesAbi = [{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"movies","outputs":[{"name":"","type":"bytes32"}],"type":"function"},{"constant":true,"inputs":[],"name":"movie_num","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"bytes32"}],"name":"bids","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"name","type":"bytes32"}],"name":"vote","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"name","type":"bytes32"}],"name":"downvote","outputs":[{"name":"","type":"string"}],"type":"function"}];SciFiMoviesContract = web3.eth.contract(SciFiMoviesAbi);SciFiMovies = SciFiMoviesContract.at('0xf3ef3d5e2b40605306e0bf8a23a8f0d32d6c578e');