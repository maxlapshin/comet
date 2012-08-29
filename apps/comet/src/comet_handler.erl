-module(comet_handler).

-export([init/3, handle/2, info/3, terminate/2]).

-define(TIMEOUT, 60000).

init({tcp,http}, Req, _Opts) ->
  {TS, Req2} = cowboy_http_req:qs_val(<<"timestamp">>, Req),
  Timestamp = case TS of
    undefined -> last;
    _ -> list_to_integer(binary_to_list(TS))
  end,
  case tinymq:poll(<<"default_channel">>, Timestamp) of
    {ok, NewTS, Messages} when length(Messages) > 0 ->
      {ok, Req2, {NewTS, Messages}};
    {ok, NewTS, []} ->
      tinymq:pull(<<"default_channel">>, Timestamp, self()),
      {loop, Req2, NewTS, ?TIMEOUT, hibernate}
  end.

info({_Pid, NewTS, Messages}, Req, _) ->
  
  JSON = mochijson2:encode([{timestamp,NewTS},{messages,[Body || {message,Body} <- Messages]}]),
  {ok, Req2} = cowboy_http_req:reply(200, [], [JSON, "\n"], Req),
  {ok, Req2, NewTS};


info(_, Req, State) ->
  {loop, Req, State, hibernate}.


handle(Req, {NewTS, Messages}) ->
  JSON = mochijson2:encode([{timestamp,NewTS},{messages,Messages}]),
  {ok, Req2} = cowboy_http_req:reply(200, [], [JSON, "\n"], Req),
  {ok, Req2, NewTS}.
  

terminate(_Req, _State) ->
  ok.
