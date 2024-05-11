class Images {

  static String get distance => 'distance'.png;

}

extension on String {
  String get png => 'assets/images/$this.png';
}