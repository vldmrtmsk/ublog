-module(ublog).
-behaviour(supervisor).
-behaviour(application).
-export([init/1, start/2, stop/1, main/1]).

main(A)    -> mad:main(A).
start()    -> start(normal,[]).
start(_,_) ->
  %application:start(ssl),
  supervisor:start_link({local,ublog},ublog,[]).

stop(_)    -> ok.

init([]) ->
  {ok, {{one_for_one, 5, 10},
        [spec(),
         #{id => pg_pool_1,
           start => {pg, start_link, []},
           restart => permanent,
           type => worker,
           modules => [pg] }
        ]}}.

spec()   -> ranch:child_spec(http, 100, ranch_tcp, port(), cowboy_protocol, env()).
env()    -> [ { env, [ { dispatch, points() } ] } ].
%static() ->   { dir, "apps/ublog/priv/static", mime() }.
%n2o()    ->   { dir, "deps/n2o/priv",           mime() }.
%mime()   -> [ { mimetypes, cow_mimetypes, all   } ].
port()   -> [ { port, wf:config(n2o,port,8000)  } ].
points() -> cowboy_router:compile([{'_', [

%    {"/static/[...]",       n2o_static,  static()},
%    {"/n2o/[...]",          n2o_static,  n2o()},
    {"/multipart/[...]",  n2o_multipart, []},
    %{"/rest/:resource",     rest_cowboy, []},
    %{"/rest/:resource/:id", rest_cowboy, []},
    %{"/",                           testrest, []},
    %{"/resttest/[:resource]",       testrest, []},
    %{"/resttest/[:resource]/[:id]", testrest, []},
    {"/",                           main_rest, []},
    {"/page/[:num]",                main_rest, []},
    {"/tag/[:id]/page/[:num]",       tag_rest, []},
    {"/post/[:id]",                 post_rest, []},
    {"/ws/[...]",           n2o_stream,  []},
    {'_',                   n2o_cowboy,  []} ]}]).


