%%%-------------------------------------------------------------------
%%% @author przemek
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. maj 2017 20:42
%%%-------------------------------------------------------------------
-module(otp_test).
-author("przemek").


%% API
-export([test/0]).
test()->
  pollution_supervisor:init([]),
  otp_pollution_server:start(),



  otp_pollution_server:add_station("ww", {2,3}),
  otp_pollution_server:add_station("wx", {3,3}),
  D = calendar:local_time(),
  otp_pollution_server:add_one_value("ww",{{2017,5,1},{0}},"pm10", 43),

  otp_pollution_server:add_one_value("ww",{{2017,5,2},{0}},"pm10", 45),
  M3 =  otp_pollution_server:get_one_value("ww",{{2017,5,2},{0}}, "pm10" ),
  M3.

  %%M3 =  otp_pollution_server:get_station_mean("ww","pm10").