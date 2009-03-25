escaped_posts(EscapedPosts) :-
  setof(post(Id,Title,Date,Body), post(Id,Title,Date,Body), Posts),
  escape_posts(Posts, [], EscapedPosts).

escape_posts([], EscapedPosts, EscapedPosts).

escape_posts([post(Id,Title,Date,Body)|Tail], TempList, EscapedPosts) :-
  escape_html_tags(Body, EscapedBody),
  append([post(Id,Title,Date,EscapedBody)], TempList, NewTempList),
  escape_posts(Tail, NewTempList, EscapedPosts).


/*
<rss version="2.0">
  <channel>
    <title>Prolog Blog</title>
    <link>http://prologblog.com/posts.rss</link>
    <description>A blog about Prolog written in Prolog</description>
    <language>en-us</language>

<?, escaped_posts(EscapedPosts) ,?>
<?, forall(select(post(Id,Title,Date,Body), EscapedPosts, _), ?>

    <item>
      <title><?= Title ?></title>
      <category/>
      <description>
        <?= Body ?>
      </description>
      <pubDate><?= Date ?></pubDate>
      <link>http://prologblog.com/post?id=<?= Id ?></link>
      <guid>http://prologblog.com/post?id=<?= Id ?></guid>
    </item>

<?) ,?>

  </channel>
</rss>
*/
