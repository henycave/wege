class Post {
  String authorName;
  String authorReference;
  String timeAgo;
  String imageUrl;
  String text;
  String authorImageUrl;
  String postReference;
  int like;
  int commentCount;

  Post({
    this.authorName,
    this.authorReference,
    this.timeAgo,
    this.imageUrl,
    this.text,
    this.authorImageUrl,
    this.postReference,
    this.like,
    this.commentCount
  });
}

final List<Post> posts = [
  Post(
    authorName: 'jimmy',
    authorImageUrl: 'assets/images/hanan.png',
    timeAgo: '5 min',
    imageUrl: 'assets/images/hanan.png',
  ),
  Post(
    authorName: 'henok',
    authorImageUrl: 'assets/images/pic4.jpg',
    timeAgo: '10 min',
    imageUrl: 'assets/images/pic4.jpg',
  ),
  Post(
    authorName: 'elsa',
    authorImageUrl: 'assets/images/pic5.jpg',
    timeAgo: '5 min',
    imageUrl: 'assets/images/pic5.webp',
  ),
  Post(
    authorName: 'fayo',
    authorImageUrl: 'assets/images/Finchitua.webp',
    timeAgo: '5 min',
    imageUrl: 'assets/images/Finchitua.webp',
  ),
  Post(
    authorName: 'sami',
    authorImageUrl: 'assets/images/Girls.jpg',
    timeAgo: '5 min',
    imageUrl: 'assets/images/Girls.jpg',
  ),
  Post(
    authorName: 'sol',
    authorImageUrl: 'assets/images/couple.jpg',
    timeAgo: '4 min',
    imageUrl: 'assets/images/couple.jpg',
  ),
  Post(
    authorName: 'elsa',
    authorImageUrl: 'assets/images/pic2.jpg',
    timeAgo: '3 min',
    imageUrl: 'assets/images/pic2.jpg',
  ),
];

final List<String> stories = [

  'assets/images/Ethiopia.jpg',
  'assets/images/Girls.jpg',
  'assets/images/ji.jpg',
  'assets/images/pic2.jpg',
  'assets/images/pic3.jpg',
  'assets/images/pic4.jpg',
];
