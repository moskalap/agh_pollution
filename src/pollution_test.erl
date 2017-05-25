%%%-------------------------------------------------------------------
%%% @author przemek
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. maj 2017 13:12
%%%-------------------------------------------------------------------
-module(pollution_test).
-author("przemek").

-include_lib("eunit/include/eunit.hrl").




otp_test()->
  ?assert(true),
  otp_pollution_server:start(),



  otp_pollution_server:add_station("ww", {2,3}),
  otp_pollution_server:add_station("wx", {3,3}),
  D = calendar:local_time(),
  otp_pollution_server:add_one_value("ww",{{2017,5,1},{0}},"pm10", 43),

  otp_pollution_server:add_one_value("ww",{{2017,5,2},{0}},"pm10", 45),

 M3 =  otp_pollution_server:get_one_value("ww",{{2017,5,2},{0}}, "pm10" ),
  ?assertEqual(M3, 44.0).







creat_test() ->
  ?assertEqual({monitor,#{},#{},#{},0},pollution:create_monitor()),
  ?assert(true).
add_st_test()->
  M = pollution:create_monitor(),
  A = pollution:add_station(M, "ww", {2,3}),
  ?assertEqual(A, {monitor,#{"ww" => 0},#{{2,3} => 0},#{0 => {station,{2,3},"ww",#{}}},1}),

  A.

get_mean_test()->
  M = pollution:create_monitor(),
  A = pollution:add_station(M, "ww", {2,3}),
  B = pollution:add_station(A, "wx", {3,3}),
  D = calendar:local_time(),
  M1= pollution:add_value(B, "ww",{{2017,5,1},{0}},"pm10", 43),
  MF= pollution:add_value(M1, "ww",{{2017,5,2},{0}},"pm10", 45),

  M3 = pollution:get_station_mean(MF,"ww","pm10"),
?assertEqual(M3, 44.0).

get_daily_mean_test()->
  M = pollution:create_monitor(),
  A = pollution:add_station(M, "w1", {1,3}),
  B = pollution:add_station(A, "w2", {2,3}),
  C = pollution:add_station(B, "w3", {3,3}),
  D = pollution:add_station(C, "w4", {4,3}),
  E = pollution:add_station(D, "w5", {5,3}),
  DATE = calendar:local_time(),

  F= pollution:add_value(E, "w1",DATE,"pm10", 1),
  ?assertEqual(pollution:get_daily_mean(F,DATE,"pm10"),1.0),
  G= pollution:add_value(F, "w2",DATE,"pm10", 2),
  ?assertEqual(pollution:get_daily_mean(G,DATE,"pm10"),1.5),
  H= pollution:add_value(G, "w3",DATE,"pm10", 3),
  ?assertEqual(pollution:get_daily_mean(H,DATE,"pm10"),2.0),
  I= pollution:add_value(H, "w4",DATE,"pm10", 4),
  ?assertEqual(pollution:get_daily_mean(I,DATE,"pm10"),2.5),
  J= pollution:add_value(I, "w5",DATE,"pm10", 5),
  M3 = pollution:get_daily_mean(J,DATE,"pm10"),
  ?assertEqual(M3, 3.0).




