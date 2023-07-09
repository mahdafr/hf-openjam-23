const String pref = 'assets/images/dogs/';
const String suf = '0.png';
const String sep = '_';

final List<String> rtImgList = [
  'husk',
  'chih',
  'pug',
];

var imgList = rtImgList.map((val) => '$pref$val$suf').toList();
