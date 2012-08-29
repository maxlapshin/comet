-module(sendmessage_handler).

-export([init/3, handle/2, terminate/2]).


init({tcp, http}, Req, Opts) ->
  {ok, Req, Opts}.


handle(Req, State) ->
  {Post, Req2} = cowboy_http_req:body_qs(Req),
  {<<"body">>, Body} = lists:keyfind(<<"body">>, 1, Post),
  {ok, Req3} = cowboy_http_req:reply(200, [], <<"Got it\n">>, Req2),
  {ok, Req3, State}.


terminate(_Req, _State) ->
  ok.
