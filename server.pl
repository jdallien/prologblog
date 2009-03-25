/* Prolog Blog
 * A Prolog application to run http://prologblog.com
 *
 * Copyright 2009 Jeff Dallien 
 * jeff@dallien.net
 * http://jeff.dallien.net/ 
 * */

:- ['psp_templating'].
:- use_module(library('http/thread_httpd')).
:- use_module(library('http/http_dispatch')).
:- use_module(library('http/html_write')).
:- use_module(library('http/http_parameters')).

:- dynamic post/4.
:- multifile post/4.

server(Port) :-
        http_server(http_dispatch, [port(Port)]).

:- http_handler('/', index, []).
:- http_handler('/post', single_post, []).
:- http_handler('/posts.rss', posts_rss, []).
:- http_handler('/request', request, []).

css(URL) -->
  html(link([ type('text/css'),
         rel('stylesheet'),
         href(URL)
       ])).

% TODO: shouldn't need to do this on every request 
setup_templating :-
  nb_setval(psp_headers, not_required),
  nb_setval(psp_error, no).

posts_rss(_Request) :-
  setup_templating,
  format('Content-type: text/xml~n~n', []),
  format('<?xml version="1.0" encoding="UTF-8"?>', []),
  run_page('views/posts.rss.prolog', []).

index(_Request) :-
  setup_templating,
  format('Content-type: text/html~n~n', []),!,
  run_page('views/posts.html.prolog', []).

single_post(Request) :-
  http_parameters(Request, [id(Id, [optional(true)])]),
  atom_number(Id, PostId),
  post(PostId, Title, Date, Body),
  setup_templating,
  format('Content-type: text/html~n~n', []),!,
  run_page('views/post.html.prolog', ['Title'=Title, 'Id'=PostId, 'Date'=Date, 'Body'=Body]).

single_post(Request) :-
  index(Request).

post(1, 'Congratulations', '16 March 2009', '<p>You have correctly set up a Prolog Blog server.</p>').

% can use this to force closing p tags
% p(X) --> ['<p>'], X, ['</p>'].

/* show the incoming request as a page */
request(Request) :-
  format('Content-type: text/html~n~n', []),
  format('<html><body>~n', []),
  format('<pre>', []),
  http_parameters(Request, [id(Id, [optional(true)])]),
  write(Request),
  write(Id),
  format('</pre></body></html>').

escape_html_tags(Text, Escaped) :-
  atom_codes(Text, Codes),
  replace(60, "&lt;", Codes, Escaped1),
  replace(62, "&gt;", Escaped1, Escaped2),
  flatten(Escaped2, EscapedCodes),
  atom_codes(Escaped, EscapedCodes).

post_escaped(A,B,C,EscapedBody) :-
  post(A,B,C,Body),
  escape_html_tags(Body,EscapedBody), !.

replace(_,_,[],[]).
replace(HReplacant,HReplacer,[HReplacant|Tail],[HReplacer|NewTail]):-
  replace(HReplacant,HReplacer,Tail,NewTail).
replace(HReplacant,HReplacer,[Head|Tail],[Head|NewTail]):-
  replace(HReplacant,HReplacer,Tail,NewTail).

