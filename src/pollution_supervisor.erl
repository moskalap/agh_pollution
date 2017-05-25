%%%-------------------------------------------------------------------
%%% @author przemek
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. maj 2017 20:34
%%%-------------------------------------------------------------------
-module(pollution_supervisor).
-author("przemek").
-behavior(supervisor).

%% API
-export([init/1]).

start_link(InitValue) ->
  supervisor:start_link({local, pollution_supvsr},?MODULE, InitValue).


init(Args) ->
  {ok, {
    {one_for_all, 2, 2000},
    [ {otp_pollution_server,
      {otp_pollution_server, start, []},
      permament, brutall_kill, worker, [otp_pollution_server]}
    ]}
  }.