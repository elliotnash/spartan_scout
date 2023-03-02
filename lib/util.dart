extension Capitalize on String {
  String capitalizeWords() {
    var result = this[0].toUpperCase();
    for (int i = 1; i < length; i++) {
      if (this[i - 1] == " ") {
        result = result + this[i].toUpperCase();
      } else {
        result = result + this[i];
      }
    }
    return result;
  }
}

DateTime dateTimeFromEpoch(int int) => DateTime.fromMillisecondsSinceEpoch(int);
int dateTimeToEpoch(DateTime time) => time.millisecondsSinceEpoch;
