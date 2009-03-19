/*
The templating system extracted from Prolog Server Pages.

PSP written by Benjain Johnston
http://www.benjaminjohnston.com.au/template.prolog?t=psp

Templating extracted from PSP by Jeff Dallien
http://jeff.dallien.net/

Prolog Server Pages original license
------------------------------------
PSP is free for any purpose (including commercial use) and
is provided without warranty of any kind. I grant you a
permanent, non-exclusive, royalty-free license to use and
modify this code (or any of its concepts) in any way you
wish.

If you do use PSP, if incorporate it into another product,
or if it inspires you to create something similar or related,
I ask for a completely optional favor. If you wish to do one
(or more!) of the following - and, again, this is completely
optional - it would by greatly appreciated:

- Donate money to SWI Prolog in my name
- Let me know how you used PSP, and provide some feedback
- Write me a letter of thanks on your corporate letterhead
  PO Box A1070, Sydney South 1235, New South Wales, Australia
- Send me an Amazon.com gift certificate
  feedback@benjaminjohnston.com.au
- Consider contracting me for some Prolog work

I can write up an invoice if this is necessary for your
company's procedures.

Thanks,

-Benjamin Johnston
*/



:- multifile message_hook/3.
:- dynamic message_hook/3.

:- dynamic session_predicates/1.
:- dynamic session_file_before/3.
:- dynamic session_file_now/2.
:- dynamic session_local_now/3.
:- prompt(_,'').

%------------------------------------------
%------------------------------------------
% Configuration Options
%------------------------------------------
%------------------------------------------

%------------------------------------------
% General PSP Options
%------------------------------------------

psp_file_extension(prolog).

psp_maximum_post_length(10240).

psp_stop_on_warnings(true).

psp_on_page_did_not_load :- write('Error: Page did not load correctly').

psp_on_page_fail :- write('Error: Page failed').

psp_on_page_exception(Exception) :- message_to_string(Exception, Message), write('Error: Page or included page generated exception: '),write(Message),nl.

psp_on_include_failed(PageName) :- write('Error: Included page "'), write(PageName),write('" failed').

psp_on_include_not_found(PageName) :- write('Error: Included page "'),write(PageName),write('" not found').

%------------------------------------------
%------------------------------------------
% PSP Handling
%------------------------------------------
%------------------------------------------

%------------------------------------------
% Main execution loop.
%------------------------------------------

% run_page.
% Consults the file, parses the PSP, executes the PSP.
% Note that if there is no PSP, it just consults the file.

run_page(File, ExternalBindings) :-
	silent_consult(File),
	compiled_file(File, Cookie, false, Page, Bindings),
	union(Bindings, ExternalBindings, FullBindings),
/*	union(Bindings,['Get'=Get,'Post'=Post,'Cookie'=Cookie], FullBindings), */
	!,
	b_setval(psp_bindings,FullBindings),
	nb_setval(psp_headers,not_required),
	(
		call_cleanup(
			catch(
				once((
					call(Page),
					!
				)),
				Exception,
				psp_on_page_exception(Exception)
			),
			exception(Exception),
			psp_on_page_exception(Exception)
		),
		flush_output
	;
		psp_on_page_fail,
		flush_output
	).

run_page(_File) :- 
	psp_on_page_did_not_load,
	flush_output.

% read_stream_codes(+stream, +int, -[char_code]).
% Reads a fixed number of character codes from a stream.

read_stream_codes(_Stream, 0, []).
read_stream_codes(Stream, Length, [Current|Rest]) :-
	Length > 0,
	get_code(Stream, Current),
	NewLength is Length - 1,
	!,
	read_stream_codes(Stream, NewLength, Rest).


% message_hook(+term, +atom, +[term]).
% A hook into the SWI Prolog message generation routines to ensure HTML headers are
% generated if an error occurs while loading PSP.
% Furthermore, if an error does occur, it is noted so that processing does not continue.

:- nb_setval(psp_headers, not_required).
:- nb_setval(psp_error, no).

message_hook(_Term, warning, _Lines) :-
	psp_stop_on_warnings(false),
	!.

message_hook(_Term, warning, _Lines) :-
	nb_getval(psp_headers, required),
	nb_setval(psp_headers, not_required),
	write('Content-Type: text/html\r\n\r\n'),
	fail.

message_hook(_Term, warning, _Lines) :-
	psp_stop_on_warnings(true),
	nb_setval(psp_error, yes),
	fail.

message_hook(_Term, error, _Lines) :-
	nb_getval(psp_headers, required),
	nb_setval(psp_headers, not_required),
	write('Content-Type: text/html\r\n\r\n'),
	fail.

message_hook(_Term, error, _Lines) :-
	nb_setval(psp_error, yes),
	fail.

% silent_consult(+atom).
% Loads a PSP file silently (i.e., without generating the "file loaded" message).

silent_consult(File) :-
	load_files([File],[silent(true)]),
	check_load.

% check_load.
% Checks that no errors occurred while consulting the file.

check_load :-
	nb_getval(psp_error, yes),
	flush_output.
check_load.

%------------------------------------------
% in-PSP Helper functions
%------------------------------------------

% include_page(+atom).
% Includes the PSP file of the supplied name in-line into the current PSP page.
include_page(PageName) :-
	psp_file_extension(Extension),
	(absolute_file_name(PageName,[extensions(['',Extension]),access(exist),file_errors(fail)],File) ->
			b_getval(psp_bindings,OldBindings),
			silent_consult(File),
			compiled_include_file(File, Page, Bindings),
			union(OldBindings, Bindings, FullBindings),
			(
				b_setval(psp_bindings,FullBindings),
				once(call(Page))
			;
				psp_on_include_failed(PageName)
			)
		;
			psp_on_include_not_found(PageName)
	),
	!.

% nth_solution(+term, +int).
% Finds the Nth solution for the supplied goal.
nth_solution(Goal, N) :- 
	Counter = counter(0), 
	Goal,
	arg(1, Counter, Count),
	Count1 is Count + 1,
	nb_setarg(1, Counter, Count1),
	Count1 = N,
	!.

%------------------------------------------
% PHP Compilation
%------------------------------------------

% compiled_file(+atom, -term, -[atom=var]).
% This identifies the PHP section and sets up for calling the parser.

compiled_file(File, Cookie, CookieStatus, PspTerm, Bindings) :-
	psp_codes(File, PspCodes),
	PspCodes = [First|_],
	((First = 0'< ; whitespace([First])) ->
			(CookieStatus = new ->
					PspTerm = (write('Content-Type: text/html\r\nSet-Cookie: PSPID='), write(Cookie), write('\r\n\r\n'),!,PageTerm)
				;
					PspTerm = PageTerm
			)
		;
			PspTerm = PageTerm
	),
	parse(PspCodes, PageTerm, Bindings).

% compiled_include_file(+atom, -term, -[atom=var]).
% As for compiled_file/3, but does not include HTTP headers.

compiled_include_file(File, PageTerm, Bindings) :-
	psp_codes(File, PspCodes),
	parse(PspCodes, PageTerm, Bindings).

% psp_codes(+atom, -[int]).
% This reads a file, and extracts the PSP section as a list of codes.

psp_codes(File, PspCodes) :-
	read_file_to_codes(File, FullFileCodes, []),
	bracket_match(FullFileCodes, _, "/*", PspCodes, "*/", Whitespace),
	whitespace(Whitespace).

% parse(+[char_code], -term, -[atom=var]).
% This wrapper takes the simplified PHP code and parses it into a term

parse(Text, Term, Bindings) :-
	append("?>", Text, Text1),
	append(Text1, "<?", ReadyText),
	simplify_psp([], [], ReadyText, Simplified, SimpleBindings, Internals),
	atom_codes(TermAtom, Simplified),
	atom_to_term(TermAtom, Term, NewBindings),
	subtract(NewBindings, Internals, NewBindings1),
	union(NewBindings1, SimpleBindings, Bindings).

% simplify_psp(+[char_code], +[term=var], +[char_code], -[char_code], -[atom=var], -[atom=term]).
% This identifies the Prolog (<? ?>) parts and the HTML (with embedded value <?= ?>) parts.
% Therefore the net effect of this predicate is to simply PSP.
% e.g., a,b,%> Hello World <%,d,e  --> a,b, PSP_HTML_BLOCK_id,d,e

simplify_psp(CurrentText, CurrentBindings, RemainingText, FinalText, FinalBindings, [Internal|Internals]) :-
	bracket_match(RemainingText, Before, "?>", Html, "<?", After),
	\+ After = [0'=|_],
	!,
	parse_html(Html, Placeholder, Bindings, Internal),
	append(CurrentText,Before,NewCurrentText1),
	append(NewCurrentText1,Placeholder,NewCurrentText),
	union(CurrentBindings, Bindings, NewCurrentBindings),
	simplify_psp(NewCurrentText, NewCurrentBindings, After, FinalText, FinalBindings, Internals).

simplify_psp(FinalText, FinalBindings, [], FinalText, FinalBindings, []).

% parse_html(+[char_code], -[char_code], -[atom=Var], -[atom=term]).
% This converts Html text into a string representing a variable.
% An "internal" binding then created that maps the variable into appropriate prolog 
% code to generate html.

parse_html(Html, [Space|Placeholder], Bindings, Internal) :-
	parse_html_term(Html, Term, Bindings),
	gensym('PSP_HTML_BLOCK_id',PlaceholderAtom),
	atom_codes(PlaceholderAtom,Placeholder),
	[Space] = " ",
	Internal = (PlaceholderAtom = Term).

% parse_html_term(+[char_code], -term, -[atom=var]).
% Does the actual work of splitting up the PSP into HTML and Prolog literal expressions <?= ?>

parse_html_term(Html, Term, Bindings) :-
	bracket_match(Html, Before, "<?=", Expr, "?>", After),
	!,
	atom_to_term(Expr, ExprTerm, ExprBindings),
	atom_codes(BeforeAtom, Before),
	parse_html_term(After, AfterTerm, AfterBindings),
	union(AfterBindings, ExprBindings, Bindings),
	Term = (write(BeforeAtom), write(ExprTerm), AfterTerm).

parse_html_term(Html, write(Term), []) :-
	atom_codes(Term, Html).


%------------------------------------------
% Helper functions
%------------------------------------------

% bracket_match(+[char_code], ?[char_code], +[char_code], ?[char_code], +[char_code], ?[char_code]).
% Split a set of codes along a boundary specified by a delimiter.
% Calling bracket_match("before ( body ) after", Before, "(", Body, ")", After).
% gives Before = "before", Body = "body", After = "after"

bracket_match(Match, Before, Open, Body, Close, After) :-
	append(Open, BodyCloseAfter, OpenBodyCloseAfter),
	append(Before, OpenBodyCloseAfter, Match),
	append(Close, After, CloseAfter),
	append(Body, CloseAfter, BodyCloseAfter).

% whitespace(+[char_code]).
% Tests that a string is entirely whitespace

whitespace(Codes) :-
	forall(member(Code, Codes), whitespace_char([Code])).

whitespace_char(" ").
whitespace_char("\t").
whitespace_char("\r").
whitespace_char("\n").

% strip_whitespace(+[char_code], -[char_code]).
% Removes the leading and trailing whitespace from a string.
strip_whitespace([H|T], Stripped) :-
	whitespace_char([H]),
	!,
	strip_whitespace(T, Stripped).

strip_whitespace(Tail, Stripped) :-
	append(Stripped, Whitespace, Tail),
	whitespace(Whitespace),
	!.

