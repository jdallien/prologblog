:- style_check(-atom).

post(6, 'XSB 3.2 Released', 'Sat, 4 Apr 2009 01:00:00 -0400',
      '
<p>
<a href="http://xsb.sourceforge.net/">XSB</a> version 3.2 was recently released. Many improvements and new features have been added, including:
</p>
<ul>
<li>speed improvements</li>
<li>improved ISO Prolog compatibility</li>
<li>better compatibility with another Prolog implementations</li>
<li>a working 64-bit version</li>
<li>improved tabling</li>
<li>and lots more</li>
</ul>
<p>
Check out the <a href="http://xsb.sourceforge.net/rel_notes.html">3.2 Release Notes</a> and <a href="http://xsb.sourceforge.net/downloads/downloads.html">download the source</a> and try it out. Basic compilation goes like this:</p>
<pre>
wget http://xsb.sourceforge.net/downloads/XSB.tar.gz
tar zxf XSB.tar.gz
cd XSB/build
./configure
./makexsb
</pre>
<p>XSB can then be run with:</p>
<pre>
cd ..
./bin/xsb
</pre>
     ').
