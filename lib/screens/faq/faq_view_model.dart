import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wakmusic/models/faq.dart';
import 'package:wakmusic/services/api.dart';

class FAQViewModel with ChangeNotifier {
  late final API _api;
  late List<String> _categories;
  late Map<String, List<FAQ?>> _faqLists;
  bool _isFirst = true;

  List<String> get categories => _categories;
  Map<String, List<FAQ?>> get faqLists => _faqLists;

  FAQViewModel() {
    _api = API();
  }

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
      _categories = await _api.fetchFAQCategories();
      _categories.insert(0, '전체');
      _faqLists = {
        '전체': await _api.fetchFAQ(),
      };
      for(String category in _categories) {
        if (category == '전체') continue;
        _faqLists[category] = _faqLists['전체']!.where((faq) => faq!.category == category).map((faq) => FAQ.clone(faq!)).toList();
      }
      notifyListeners();
    }
  }

  void onTap(FAQ faq) {
    faq.isExpanded = !faq.isExpanded;
    notifyListeners();
  }
  
  void collapseAll() {
    for(String category in _categories) {
      for(FAQ? faq in _faqLists[category]!) {
        faq?.isExpanded = false;
      }
    }
    notifyListeners();
  }
}