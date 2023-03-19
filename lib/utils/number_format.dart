import 'package:intl/intl.dart';

koreanNumberFormater(int num) {
  switch (num.toString().length) {
    case 4:
      return NumberFormat("#.##천").format((num / 10).floor() / 100);
    case 5:
      return NumberFormat("#.##만").format((num / 100).floor() / 100);
    case 6:
      return NumberFormat("##.#만").format((num / 1000).floor() / 10);
    case 7:
      return NumberFormat("###만").format((num / 10000).floor());
    case 8:
      return NumberFormat("####만").format((num / 10000).floor());
    case 9:
      return NumberFormat("#.##억")
          .format((num / 1000000).floor() / 100);
    default:
      return num.toString();
  }
}
