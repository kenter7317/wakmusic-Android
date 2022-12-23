import 'package:flutter/material.dart';

// extension WakText on TextTheme {
//   TextStyle get txt12L{
//     return TextStyle(
//       fontSize: 12.0, 
//     );
//   }
// }
class WakText {
  /* light */
  static final TextStyle txt12L = TextStyle(height: 1.5, fontSize: 12.0, fontWeight: FontWeight.w400);
  /* medium */
  static final TextStyle txt11M = TextStyle(height: 1.4, fontSize: 16.0, fontWeight: FontWeight.w600);
  static final TextStyle txt12M = TextStyle(height: 1.1, fontSize: 16.0, fontWeight: FontWeight.w600);
  static final TextStyle txt12MH = TextStyle(height: 1.5, fontSize: 16.0, fontWeight: FontWeight.w600);
  static final TextStyle txt14M = TextStyle(height: 1.4, fontSize: 14.0, fontWeight: FontWeight.w600);
  static final TextStyle txt14MH = TextStyle(height: 1.7, fontSize: 16.0, fontWeight: FontWeight.w600);
  static final TextStyle txt16M = TextStyle(height: 1.5, fontSize: 16.0, fontWeight: FontWeight.w600);
  static final TextStyle txt18M = TextStyle(height: 1.5, fontSize: 18.0, fontWeight: FontWeight.w600);
  /* bold */
  static final TextStyle txt12B = TextStyle(height: 1.5, fontSize: 12.0, fontWeight: FontWeight.w700);
  static final TextStyle txt16B = TextStyle(height: 1.5, fontSize: 16.0, fontWeight: FontWeight.w700);
}