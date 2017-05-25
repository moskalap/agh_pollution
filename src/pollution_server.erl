%%%-------------------------------------------------------------------
%%% @author przemek
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. kwi 2017 18:27
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("przemek").
-c("pollution").
%% API
-export([start/0]).

start() ->
  io:format("Server started succesfully!~n"),  run(pollution:create_monitor()).

run(Monitor)->
  io:format("Runn!~n"),
  receive
    stop -> ok;
    {add_station,{Name, Cord}} ->
      run(add_station(Monitor, Name, Cord));

    {add_value, {Cord_or_Name, DateTime, Type, Value}} ->
      run(add_value(Monitor, Cord_or_Name, DateTime, Type, Value));

    {remove_value, {Cord_or_Name, DateTime, Type}} ->
      run(remove_value(Monitor, Cord_or_Name, DateTime, Type));

    {get_one_value, {Cord_or_Name, DateTime, Type}} ->
      run(get_one_value(Monitor,Cord_or_Name,DateTime,Type));


    {get_station_mean,{Cord_or_Name,Type}} ->
      run(get_station_mean(Monitor, Cord_or_Name,Type));

    {get_daily_mean, {Date, Type}} -> Monitor;

    _->run(Monitor)
  end.
get_one_value(Monitor,Cord_or_Name,DateTime,Type)->
  Val = pollution:get_one_value(Monitor,Cord_or_Name,DateTime,Type),
  io:format("~p measured at ~p = ~p",[Type,DateTime,Val]),
  Monitor.

add_station(Monitor, Name, Cord) ->
  Updated_Monitor=pollution:add_station(Monitor,Name,Cord),
  io:format("Added station ~p located at ~p ~n",[Name, Cord]),
  Updated_Monitor.


add_value(Monitor, Cord_or_Name, DateTime, Type, Value)->
  Updated_Monitor=pollution:add_value(Monitor,Cord_or_Name,DateTime,Type,Value),
  io:format("Added value ~p=~p measured on ~p to station ~p ~n",[Type, Value, DateTime,Cord_or_Name]),
  Updated_Monitor.

remove_value(Monitor, Cord_or_Name, DateTime, Type)->
  Updated_Monitor=pollution:remove_value(Monitor,Cord_or_Name,DateTime,Type),
  io:format("Removed value ~p measuread on~p ~n",[Type, DateTime]),
  Updated_Monitor.
get_station_mean(Monitor, Cord_or_Name,Type)->
  Mean = pollution:get_station_mean(Monitor,Cord_or_Name,Type),
  io:format("~p = ~p~n",[Type,Mean]),
  Monitor.


