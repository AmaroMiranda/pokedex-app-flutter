extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          // Mantém palavras em maiúsculas (como "HP") intactas
          if (word.toUpperCase() == word) return word;
          // Capitaliza a primeira letra do resto
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }
}
