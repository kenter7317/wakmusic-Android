import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/faq.dart';
import 'package:wakmusic/services/apis/api.dart';

class FAQViewModel with ChangeNotifier {
  late List<String> _categories;
  late Map<String, List<FAQ?>> _faqLists;
  bool _isFirst = true;

  List<String> get categories => _categories;
  Map<String, List<FAQ?>> get faqLists => _faqLists;

  FAQViewModel();

  void clear() {
    _categories = List.filled(5, '');
    _faqLists = {
      '': List.filled(10, null),
    };
  }

  Future<void> getFAQ() async {
    if (_isFirst) {
      clear();
      _isFirst = false;
      _categories = await API.faq.categories;
      _categories.insert(0, '전체');
      _faqLists = {
        '전체': await API.faq.list,
      };
      _faqLists['전체']!.sort((a, b) {
        int categoryIdxA, categoryIdxB;
        categoryIdxA = _categories.indexOf(a!.category);
        categoryIdxB = _categories.indexOf(b!.category);
        return categoryIdxA.compareTo(categoryIdxB);
      });
      for (String category in _categories) {
        if (category == '전체') continue;
        _faqLists[category] = _faqLists['전체']!
            .where((faq) => faq!.category == category)
            .map((faq) => FAQ.clone(faq!))
            .toList();
      }
      notifyListeners();
    }
  }

  void onTap(FAQ faq) {
    faq.isExpanded = !faq.isExpanded;
    notifyListeners();
  }

  void collapseAll() {
    for (String category in _categories) {
      for (FAQ? faq in _faqLists[category]!) {
        faq?.isExpanded = false;
      }
    }
    notifyListeners();
  }
}
