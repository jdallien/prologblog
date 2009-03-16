post([h2(class('post_title'), 'Prolog Blog launches'),
      div(class('date'), 'March 16, 2009'),
      p('Welcome to Prolog Blog, a site dedicated to Prolog news, tutorials and helping to connect the Prolog community. The site itself is written in Prolog and the source is available on GitHub. Visit the '),
      a(href('http://github.com/jdallien/prologblog'), 'Prolog Blog GitHib repository'),
      '. The site is very simple for now but will be undergoing constant improvement. An RSS feed is coming soon.',
      p('Feedback, links, suggestions for posts or links to your own blog posts you would like to share are welcome. Please email '),
      a(href('mailto:contact@prologblog.com'), 'contact@prologblog.com'), '.',
      p('For details on the work leading up this point, please see these blog posts from my personal site, '),
      a(href('http://jeff.dallien.net'), 'jeff.dallien.net'), ':',
      ul([
          li(a(href('http://jeff.dallien.net/posts/analysis-paralysis'), 'Analysis Paralysis')),
          li(a(href('http://jeff.dallien.net/posts/installing-plunit-on-ubuntu'), 'Installing PlUnit on Ubuntu')),
          li(a(href('http://jeff.dallien.net/posts/apache-reverse-proxy-to-swi-prolog'), 'Apache reverse proxy to SWI-Prolog')),
          li(a(href('http://jeff.dallien.net/posts/a-chain-of-my-own-and-making-progress'), 'A chain of my own and making progress')),
          li(a(href('http://jeff.dallien.net/posts/the-simplest-thing-that-could-possibly-fail-miserably'), 'The simplest thing that could possibly fail miserably')),
          li(a(href('http://jeff.dallien.net/posts/yes-i-use-prolog-and-i-like-it'), 'Yes, I use Prolog and I like it'))
         ]),
       p(['You can also check out the ',
       a(href('http://github.com/jdallien/prologblog/tree/master/posts/first_post.pl'), 'Prolog code that generated this post'),
       '. Thanks for visiting.']),
      div(class('footer'), [p('Copyright 2009 '),
      a(href('http://jeff.dallien.net/'), 'Jeff Dallien')])
     ]).
