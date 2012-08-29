-module(comet_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-export([start/0]).

start() ->
  application:start(comet).
  


%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
  ok = application:start(mimetypes),
  
  Routes = [
    {[<<"comet">>], comet_handler, []},
    {[<<"sendmessage">>], sendmessage_handler, []},
    {[], cowboy_http_static, [
      {directory, <<"www">>},
      {file, <<"index.html">>},
      {mimetypes,[{<<".html">>,[<<"text/html">>]}]}
    ]},
    {['...'], cowboy_http_static, [
      {directory, <<"www">>},
      {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
    ]}
  ],
  Dispatch = [{'_', Routes}],
  HTTPPort = 8080,


  ProtoOpts = [{dispatch, Dispatch},{max_keepalive,4096}],

  ok = application:start(cowboy),
  
  {ok, _Listener} = cowboy:start_listener(comet_http, 100, 
    cowboy_tcp_transport, [{port,HTTPPort},{backlog,4096},{max_connections,8192}],
    cowboy_http_protocol, ProtoOpts
  ),
  
  comet_sup:start_link().

stop(_State) ->
    ok.
