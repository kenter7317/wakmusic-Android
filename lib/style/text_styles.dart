import 'package:flutter/material.dart';

class WakText {
  /* base */
  static const TextStyle txtBase = TextStyle(overflow: TextOverflow.ellipsis, letterSpacing: -0.5, leadingDistribution: TextLeadingDistribution.even);
  static final TextStyle txtLBase = txtBase.copyWith(fontWeight: FontWeight.w300);
  static final TextStyle txtMBase = txtBase.copyWith(fontWeight: FontWeight.w500);
  static final TextStyle txtBBase = txtBase.copyWith(fontWeight: FontWeight.w700);
  /* light */
  static final TextStyle txt12L = txtLBase.copyWith(height: 18/12, fontSize: 12.0);
  static final TextStyle txt14L = txtLBase.copyWith(height: 24/14, fontSize: 14.0);
  static final TextStyle txt16L = txtLBase.copyWith(height: 24/16, fontSize: 16.0);
  /* medium */
  static final TextStyle txt11M = txtMBase.copyWith(height: 16/11, fontSize: 11.0);
  static final TextStyle txt12M = txtMBase.copyWith(height: 14/12, fontSize: 12.0);
  static final TextStyle txt12MH = txtMBase.copyWith(height: 18/12, fontSize: 12.0);
  static final TextStyle txt14M = txtMBase.copyWith(height: 20/14, fontSize: 14.0);
  static final TextStyle txt14MH = txtMBase.copyWith(height: 24/14, fontSize: 14.0);
  static final TextStyle txt16M = txtMBase.copyWith(height: 24/16, fontSize: 16.0);
  static final TextStyle txt18M = txtMBase.copyWith(height: 28/18, fontSize: 18.0);
  static final TextStyle txt20M = txtMBase.copyWith(height: 32/20, fontSize: 20.0);
  /* bold */
  static final TextStyle txt12B = txtBBase.copyWith(height: 18/12, fontSize: 12.0);
  static final TextStyle txt14B = txtBBase.copyWith(height: 24/14, fontSize: 14.0);
  static final TextStyle txt16B = txtBBase.copyWith(height: 24/16, fontSize: 16.0);
}