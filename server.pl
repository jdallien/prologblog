/* Prolog Blog
 * A Prolog application to run http://prologblog.com
 *
 * Copyright 2009 Jeff Dallien 
 * jeff@dallien.net
 * http://jeff.dallien.net/ 
 * */

:- use_module(library('http/thread_httpd')).
:- use_module(library('http/http_dispatch')).
:- use_module(library('http/html_write')).

:- multifile post/1.

server(Port) :-
        http_server(http_dispatch, [port(Port)]).

:- http_handler('/', index, []).
:- http_handler('/request', inspect, []).
:- http_handler('/main.css', main_css, []).

css(URL) -->
  html_post(css,
  link([ type('text/css'),
         rel('stylesheet'),
         href(URL)
       ])).

index(_Request) :-
  all_posts(Posts),
  append([ 
           \css('main.css'),
           h1('Prolog Blog'),
           div(class('tagline'), 'A blog about Prolog written in Prolog')
         ],
         Posts,
         PageContent),
  reply_html_page([ title('Prolog Blog'),
                    \html_receive(css)
                  ],
                  PageContent).

all_posts(List) :-
  setof(Post, post(Post), TempList),
  flatten(TempList, List).

post([h2('Congratulations'), p('You have correctly set up a Prolog Blog server.')]).

% can use this to force closing p tags
% p(X) --> ['<p>'], X, ['</p>'].

main_css(_Request) :-
  format('Content-type: text/css~n~n', []),
  format('div.tagline {
           font-size: small;
          }').

/* show the incoming request as a page */
request(Request) :-
  format('Content-type: text/html~n~n', []),
  format('<html><body>~n', []),
  format('<pre>', []),
  write(Request),
  format('</pre></body></html>').


