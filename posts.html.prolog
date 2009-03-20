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
  
  <h2><?= Title ?></h2>
  <div class="date"><?= Date ?></div>
  <div class="post_body">
    <?= Body ?>
  </div>

<?) ,?>

<div class="footer">
  <p>Copyright 2009 <a href=\'http://jeff.dallien.net/\'>Jeff Dallien</a></p>
</div>
</body>
</html>
*/
