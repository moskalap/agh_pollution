%%%-------------------------------------------------------------------
%%% @author przemek
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. mar 2017 13:39
%%%-------------------------------------------------------------------
-module(func).
-author("przemek").

%% API
-export([map/2,filter/2,makeAList/1]).

map(Fun, List) -> [Fun(X) || X<-List].
filter(P, List) -> [X || X<- List, P(X)].

makeAList(0)-> [];
makeAList(N) ->[N rem 10] ++ makeAList(N/10).

