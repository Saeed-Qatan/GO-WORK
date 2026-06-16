class SearchTextNormalizer {
  const SearchTextNormalizer._();

  static final RegExp _arabicDiacritics = RegExp(
    r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]',
  );
  static final RegExp _repeatedWhitespace = RegExp(r'\s+');

  static String normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(_arabicDiacritics, '')
        .replaceAll('\u0640', '')
        .replaceAll(RegExp('[\u0623\u0625\u0622\u0671]'), '\u0627')
        .replaceAll('\u0649', '\u064A')
        .replaceAll(_repeatedWhitespace, ' ');
  }
}
