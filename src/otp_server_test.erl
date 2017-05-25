%%%-------------------------------------------------------------------
%%% @author przemek
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. maj 2017 19:56
%%%-------------------------------------------------------------------
-module(otp_server_test).
-author("przemek").

-include_lib("eunit/include/eunit.hrl").

simple_test() ->
  otp_pollution_server:start(),
  otp_pollution_server:add_station("nazwa", {1,2}).

