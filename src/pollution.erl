%%%-------------------------------------------------------------------
%%% @author przemek
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. mar 2017 23:07
%%%-------------------------------------------------------------------
-module(pollution).
-author("przemek").
-record(station, {geo_cord,name,measurement}).
-record(measurement, { temperature, pm2p5, pm10, pressure, humidity, others=[]}).
-record(monitor, {by_name, by_cord, stations, id_count}).
%% API
-export([create_monitor/0,get_daily_mean/3,get_station_mean/3,get_maximum_gradient_stations/3,test_creation_station/0,add_station/3,add_value/5,remove_value/4,get_one_value/4,get_daily_mean/3]).
create_monitor()-> #monitor{
  by_name = maps:new(),
  by_cord = maps:new(),
  stations=maps:new(),
  id_count=0
}.



add_station(Monitor, Name, Cord) ->
  case {maps:is_key(Name, Monitor#monitor.by_name), maps:is_key(Cord, Monitor#monitor.by_cord)}  of
    {true, _} -> Monitor;
    {_,true}  -> Monitor;
    _ ->  #monitor{
      by_name = maps:put(Name,Monitor#monitor.id_count,Monitor#monitor.by_name),
      by_cord = maps:put(Cord,Monitor#monitor.id_count,Monitor#monitor.by_cord),
      stations = maps:put(Monitor#monitor.id_count, #station{
        geo_cord = Cord,
        name = Name,
        measurement = maps:new()
      },
        Monitor#monitor.stations),
      id_count = Monitor#monitor.id_count+1

    }
  end.

add_value(Monitor, Cord_or_Name, DateTime, Type, Value) ->
  {Date, Time}=DateTime,
  Station = get_station(Monitor,Cord_or_Name),
  Measurement = get_measurment(Station,Date),

  case Type of
    "pm2.5"       ->  add_measurement(Monitor, Cord_or_Name, Date, Measurement#measurement{pm2p5 = Value}, Station);
    "pm10"        ->  add_measurement(Monitor, Cord_or_Name, Date, Measurement#measurement{pm10 = Value}, Station);
    "temperature" ->  add_measurement(Monitor, Cord_or_Name, Date, Measurement#measurement{temperature = Value}, Station);
    "pressure"    ->  add_measurement(Monitor, Cord_or_Name, Date, Measurement#measurement{pressure = Value}, Station);
    "humidity"    ->  add_measurement(Monitor, Cord_or_Name, Date, Measurement#measurement{humidity = Value}, Station);
    _             ->  Others = Measurement#measurement.others,
      add_measurement(Monitor, Cord_or_Name, Date, Measurement#measurement{others = Others++[{Type,Value}]}, Station)

  end.


remove_value(Monitor, Cord_or_Name, Date, Type)->
  add_value(Monitor,Cord_or_Name,Date,Type,undefined).
get_one_value(Monitor,Cord_or_Name,Date,Type)->
  Measure = get_measurment(get_station(Monitor,Cord_or_Name),Date),
  case Type of
    "pm2.5"       ->  Measure#measurement.pm2p5;
    "pm10"        ->  Measure#measurement.pm10;
    "temperature" ->  Measure#measurement.temperature;
    "pressure"    ->  Measure#measurement.pressure;
    "humidity"    ->  Measure#measurement.humidity;
    _             ->  Measure#measurement.others


  end.
get_station_mean(Monitor,Cord_or_Name,Type)->
  Station = get_station(Monitor,Cord_or_Name),
  Measure = maps:values(Station#station.measurement),
  case Type of
    "pm2.5"       ->  average(lists:filter(fun (X) -> X /= undefined end, map(fun (X) -> X#measurement.pm2p5 end, Measure)));
    "pm10"        ->
      Lista = map(fun (X) -> X#measurement.pm10 end, Measure),
      List = lists:filter(fun (X) -> X /= undefined end, Lista),
      A = average(List),
    A;
    "temperature" ->  average(lists:filter(fun (X) -> X /= undefined end, map(fun (X) -> X#measurement.temperature end, Measure)));
    "pressure"    ->  average(lists:filter(fun (X) -> X /= undefined end, map(fun (X) -> X#measurement.pressure end, Measure)));
    "humidity"    ->  average(lists:filter(fun (X) -> X /= undefined end, map(fun (X) -> X#measurement.humidity end, Measure)));
    _             ->  map(fun (X) -> X#measurement.others end, Measure)


  end.

get_daily_mean(Monitor, DatetIME, Type)->
  {Date, Time} = DatetIME,

  Stations = maps:values(Monitor#monitor.stations),
  Measurements = map(fun(X) ->maps:get(Date,X) end, filter(fun (X) -> maps:is_key(Date, X) end, map(fun(X)-> X#station.measurement end,Stations))),
  case Type of
    "pm2.5"       ->  average(lists:filter(fun (X) -> X /= undefined end, map(fun (X) -> X#measurement.pm2p5 end, Measurements)));
    "pm10"        ->  average(lists:filter(fun (X) -> X /= undefined end, map(fun (X) -> X#measurement.pm10 end, Measurements)));
    "temperature" ->  average(lists:filter(fun (X) -> X /= undefined end, map(fun (X) -> X#measurement.temperature end, Measurements)));
    "pressure"    ->  average(lists:filter(fun (X) -> X /= undefined end, map(fun (X) -> X#measurement.pressure end, Measurements)));
    "humidity"    ->  average(lists:filter(fun (X) -> X /= undefined end, map(fun (X) -> X#measurement.humidity end,Measurements)));
    _             ->  func:map(fun (X) -> X#measurement.others end, Measurements)

  end.
%get_maximum_gradient_stations - wyszuka parę stacji na których wystąpił największy gradient zanieczyszczeń w kontekście odległosci
get_maximum_gradient_stations(Monitor, Type, Date) ->
  Map_of_Gradients = get_map_of_gradients(Monitor,Type,Date),
  [K|_] = lists:reverse(lists:sort(maps:keys(Map_of_Gradients))),
  {A,B} = maps:get(K, Map_of_Gradients),
  {A#station.name,B#station.name, K}.

get_map_of_gradients(Monitor,Type, Date)->
  M = maps:new(),
  Stations = maps:values(Monitor#monitor.stations),
  L=[{X,Y} || X<-Stations, Y<-Stations ,X/=Y],


  get_map_of_gradients_from_list(L, Date, Type).


get_map_of_gradients_from_list([], Date, Type)->maps:new();

get_map_of_gradients_from_list(L, Date, Type)->
  [H|Tail] = L,
  Grad = count_gradient(H,Type,Date),
  maps:put(Grad, H, get_map_of_gradients_from_list(Tail, Date, Type)).

count_gradient(H, Type, Date)->
  {X,Y} = H,
  Mx = maps:get(Date, X#station.measurement),
  My = maps:get(Date, Y#station.measurement),
  case Type of
    "pm2.5"        -> abs(Mx#measurement.pm2p5-My#measurement.pm2p5)/get_distance(X,Y);
    "pm10"          -> abs(Mx#measurement.pm10-My#measurement.pm10)/get_distance(X,Y);
    "temperature" -> abs(Mx#measurement.temperature-My#measurement.temperature)/get_distance(X,Y);
    "pressure"    -> abs(Mx#measurement.pressure-My#measurement.pressure)/get_distance(X,Y);
    "humidity"    -> abs(Mx#measurement.humidity-My#measurement.humidity)/get_distance(X,Y);
    _             -> abs(Mx#measurement.others-My#measurement.others)/get_distance(X,Y)

  end.




get_distance(StationA, StationB) ->
  {X1,Y1} = StationA#station.geo_cord,
  {X2,Y2} = StationB#station.geo_cord,
  math:sqrt(

    math:pow(X2-X1,2)+math:pow(math:cos(X1*math:pi()/180)*(Y2-Y1),2)

  )*4075.704/36.

get_measurment(Station,Date)->
  maps:get(Date,Station#station.measurement, #measurement{}).

get_ID(Cord_or_Name, Monitor) ->
  case Cord_or_Name of
    {_,_} ->maps:get(Cord_or_Name, Monitor#monitor.by_cord);
    _   ->maps:get(Cord_or_Name, Monitor#monitor.by_name)
  end.
average(X) ->
  average(X, 0, 0).

average([H|T], Length, Sum) ->


  average(T, Length + 1, Sum + H);

average([], Length, Sum) ->
  Sum / Length.

add_full_measure(Monitor, Cord_or_Name, Date, Pm25, Pm10, Temp, Hum, Pres)->
  Monitor1=add_value(Monitor,Cord_or_Name,Date,"pm2.5",Pm25),
  Monitor2=add_value(Monitor1,Cord_or_Name,Date,"pm10",Pm10),
  Monitor3=add_value(Monitor2,Cord_or_Name,Date,"temperature",Temp),
  Monitor4=add_value(Monitor3,Cord_or_Name,Date,"humidity",Hum),
  add_value(Monitor4,Cord_or_Name,Date,"pressure",Pres).

map(Fun, List) -> [Fun(X) || X<-List].
filter(P, List) -> [X || X<- List, P(X)].

get_station(Monitor, Cord_Or_Name)->
  maps:get(get_ID(Cord_Or_Name, Monitor),Monitor#monitor.stations).
add_measurement(Monitor, Cord_or_Name, Date, Measurement, Station)->
  NewStation=Station#station{measurement = maps:put(Date,Measurement,Station#station.measurement)},
  Monitor#monitor{stations = maps:update(get_ID(Cord_or_Name,Monitor), NewStation, Monitor#monitor.stations)}.
test_creation_station()->
  M = pollution:create_monitor(),
  A = pollution:add_station(M, "ww", {2,3}),
  B = pollution:add_station(A, "wx", {3,3}),
  D = calendar:local_time(),
  M1= pollution:add_value(B, "ww",{{2017,5,1},{0}},"pm10", 43),
  MF= pollution:add_value(M1, "ww",{{2017,5,2},{0}},"pm10", 45),

  M3 = pollution:get_station_mean(MF,"ww","pm10").