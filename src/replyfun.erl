-module(replyfun).
-behaviour(gen_server).

-define(SERVER, ?MODULE).

-export([start_link/0,
	 inc/0]).

-export([init/1,
	 handle_call/3,
	 handle_cast/2,
	 handle_info/2,
	 terminate/2,
	 code_change/3]).

%%====================================================================
%% API
%%====================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

inc() ->
    gen_server:call(?SERVER, inc).

%%====================================================================
%% Behaviour Callbacks
%%====================================================================

init(_) ->
    {ok, #{cnt => 0, waiting => []}}.

handle_call(inc, From, State=#{cnt := Cnt, waiting := WS}) ->
    {noreply, State#{cnt => Cnt+1, waiting => [From|WS]}, 7000}.

handle_cast(_What, State) ->
    {noreply, State}.

handle_info(timeout, State=#{cnt := Cnt, waiting := Waiting}) ->
    priv_reply_all(Cnt, Waiting),
    {noreply, State#{waiting => []}};

handle_info(_What, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_Vsn, State, _Extra) ->
    {ok, State}.

%%====================================================================
%% Private
%%====================================================================

priv_reply_all(_, []) ->
    ok;

priv_reply_all(Cnt, [H|T]) ->
    gen_server:reply(H, Cnt),
    priv_reply_all(Cnt, T).
