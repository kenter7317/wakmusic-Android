enum ChartType {
  hourly('시간순'),
  daily('일간순'),
  weekly('주간순'),
  monthly('월간순'),
  total('누적순');

  const ChartType(this.str);
  final String str;
}

enum SearchType {
  title('노래'),
  artist('가수'),
  remix('조교'),
  ids('아이디');

  const SearchType(this.str);
  final String str;
}

enum AlbumType {
  latest("최신순", "new"),
  popular("인기순", "popular"),
  old("과거순", "old");

  const AlbumType(this.kor, this.eng);
  final String kor;
  final String eng;
}

enum GroupType {
  all('전체'),
  woowakgood('우왁굳'),
  isedol('이세돌'),
  gomem('고멤'),
  academy('아카데미');

  const GroupType(this.locale);
  final String locale;
}
