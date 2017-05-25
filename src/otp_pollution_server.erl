%%%-------------------------------------------------------------------
%%% @author przemek
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. maj 2017 18:50
%%%-------------------------------------------------------------------
-module(otp_pollution_server).
-author("przemek").
-behavior(gen_server).

%% API
-export([start/0, add_station/2,add_one_value/4,remove_value/3,get_one_value/3,get_daily_mean/2,get_station_mean/2,init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% user interface
start()->
  gen_server:start_link(
    {local, pollution_server},
    otp_pollution_server,
    [],
    []
    ).
add_station(Name, Cord) ->
  gen_server:cast(pollution_server, {add_station, Name, Cord}).
add_one_value(Cord_or_Name, DateTime, Type, Value)->
  gen_server:cast(polltion_server, {add_value, Cord_or_Name, DateTime, Type, Value}).
remove_value(Cord_or_Name, DateTime, Type)->
  gen_server:cast(pollution_server, {remove_value, Cord_or_Name, DateTime, Type}).
get_one_value(Cord_or_Name, DateTime, Type)->
  gen_server:call(pollution_server, {get_one_value, Cord_or_Name, DateTime, Type}).
get_daily_mean(Date, Type)->
  gen_server:call(pollution_server, {get_daily_mean, Date, Type}).
get_station_mean(Cord_Or_Name, Type) ->
  gen_server:call(pollution_server, {get_station_mean, Cord_Or_Name, Type}).

stop()->
  gen_server:cast(pollution_server, stop).



%% call back

init(Args) ->
  Monitor = pollution:create_monitor(),
  {ok, Monitor}.

handle_call({get_one_value, Cord_or_Name, DateTime, Type}, From, State) ->
  Val = pollution:get_one_value(State, Cord_or_Name,DateTime,Type),
  {reply, Val, State};

handle_call({get_daily_mean, Date, Type}, From, State) ->
  Val = pollution:get_daily_mean(State,Date,Type),
  {reply, Val, State};

handle_call({get_station_mean, Cord_Or_Name, Type}, _From, State) ->
  Val = pollution:get_station_mean(State, Cord_Or_Name,Type),
  io:format("aaa"),
  {reply, Val, State}.


handle_cast({add_station, Name, Cord}, State) ->
  New_State = pollution:add_station(State, Name, Cord),
  io:format("Added station ~p located at ~p ~n",[Name, Cord]),
  {noreply, New_State};


handle_cast({add_value, Cord_or_Name, DateTime, Type, Value}, State) ->

  Updated_Monitor=pollution:add_value(State,Cord_or_Name,DateTime,Type,Value),
  io:format("Added value ~p=~p measured on ~p to station ~p ~n",[Type, Value, DateTime,Cord_or_Name]),
  {noreply, Updated_Monitor};


handle_cast({remove_value, Cord_or_Name, DateTime, Type}, State) ->
  Updated_Monitor=pollution:remove_value(State,Cord_or_Name,DateTime,Type),
  io:format("Removed value ~p measuread on~p ~n",[Type, DateTime]),
  {noreply, Updated_Monitor}.


handle_info(Info, State) ->
  erlang:error(not_implemented).

terminate(Reason, State) ->
  erlang:error(not_implemented).

code_change(OldVsn, State, Extra) ->
  erlang:error(not_implemented).