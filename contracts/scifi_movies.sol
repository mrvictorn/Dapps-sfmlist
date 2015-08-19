contract SciFiMovies {
    mapping(bytes32 => uint) public bids;
    bytes32[1000000] public movies;
    uint public movie_num;
    function vote(bytes32 name) public returns (string) {
        if (msg.value==0)
            return "Error: zero amount not accepted";
        uint val=bids[name];
        if (val==0) {
            movies[movie_num++]=name;
        }
        bids[name]+=msg.value;
        return "Vote accepted";
    }
    function downvote(bytes32 name) public returns(string) {
        if (msg.value==0)
            return;
        uint val=bids[name];
        if (val==0) {return;}
        if (movie_num == 1){return;}
        uint rest = msg.value * 2 / (movie_num -1);
        bids[name]-=msg.value;
        for(uint i=0;i<movie_num;i++) {
            var cname = movies[i];
            if (cname != name) {
               bids[cname] += rest;
            }
        }
        return "Downvote accepted";
    }
}