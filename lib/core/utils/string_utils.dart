class StringUtils {
  static String toTitleCase(String input) {
    if (input.isEmpty) return input;
    return input
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  static String formatRequestType(String requestType) {
    switch (requestType.toLowerCase()) {
      case 'normal':
        return 'Normal';
      case 'corporate':
        return 'Corporate';
      case 'roster_auto':
        return 'Roster';
      default:
        return toTitleCase(requestType);
    }
  }
}
