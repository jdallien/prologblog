/*
<html>
<head>
  <title>Prolog Blog</title>
  <?, html([\css('main.css')], Tokens, []),  print_html(Tokens), ?>
  <link type='application/rss+xml' rel='alternate' href='posts.rss' title='Prolog Blog RSS'>
</head>
<body>
<h1>Prolog Blog</h1>
<div class="tagline">A blog about Prolog written in Prolog</div>

<?, forall(post(Id, Title, Date, Body), ?>
  
  <h2><a href="/post?id=<?= Id ?>"><?= Title ?></a></h2>
  <div class="date"><?= Date ?></div>
  <div class="post_body">
    <?= Body ?>
  </div>

  <a href="http://prologblog.com/post?id=<?= Id ?>#disqus_thread">View Comments</a>
<?) ,?>

<div class="footer">
  <p>Copyright 2009 <a href="http://jeff.dallien.net/">Jeff Dallien</a></p>
</div>

<script type="text/javascript">
//<![CDATA[
(function() {
    var links = document.getElementsByTagName('a');
    var query = '?';
    for(var i = 0; i < links.length; i++) {
      if(links[i].href.indexOf('#disqus_thread') >= 0) {
        query += 'url' + i + '=' + encodeURIComponent(links[i].href) + '&';
      }
    }
    document.write('<script charset="utf-8" type="text/javascript" src="http://disqus.com/forums/prologblog/get_num_replies.js' + query + '"></' + 'script>');
  })();
//]]>
</script>

</body>
</html>
*/
