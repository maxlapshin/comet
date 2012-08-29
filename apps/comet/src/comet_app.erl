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
    comet_sup:start_link().

stop(_State) ->
    ok.
