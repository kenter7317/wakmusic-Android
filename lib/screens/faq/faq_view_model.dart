import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wakmusic/models/faq.dart';
import 'package:wakmusic/services/api.dart';

class FAQViewModel with ChangeNotifier {
  late final API _api;
  late final List<String> _categories;
  late Map<String, List<FAQ>> _faqLists;

  List<String> get categories => _categories;
  Map<String, List<FAQ>> get faqLists => _faqLists;

  FAQViewModel() {
    _api = API();
    getFAQ();
  }

  Future<void> getFAQ() async {
    _categories = ['전체', '카테고리1', '카테고리2', '카테고리3', '카테고리4'];
    _faqLists = {
      '전체': [
        FAQ(
          category: '카테고리1', 
          question: '자주 묻는 질문 제목', 
          description: '자주 묻는 질문 답변이 나옵니다.\n위아래 여백에 맞춰 답변 길이가 유동적으로 바뀝니다.',
          createAt: DateTime.now(),
        ),
        FAQ(
          category: '카테고리2', 
          question: '자주 묻는 질문 제목', 
          description: '자주 묻는 질문 답변이 나옵니다.위아래 여백에 맞춰 답변 길이가 유동적으로 바뀝니다.\n자주 묻는 질문 답변이 나옵니다.\n위아래 여백에 맞춰 답변 길이가 유동적으로 바뀝니다.',
          createAt: DateTime.now(),
        ),
        FAQ(
          category: '카테고리3', 
          question: '자주 묻는 질문 제목 두 줄인 경우 자주 묻는 질문 제목 두 줄인 경우 자주 묻는 질문 제목 두 줄인 경우', 
          description: '자주 묻는 질문 답변이 나옵니다.\n위아래 여백에 맞춰 답변 길이가 유동적으로 바뀝니다.',
          createAt: DateTime.now(),
        ),
        FAQ(
          category: '카테고리4', 
          question: '자주 묻는 질문 제목 두 줄인 경우 자주 묻는 질문 제목 두 줄인 경우 자주 묻는 질문 제목 두 줄인 경우', 
          description: '자주 묻는 질문 답변이 나옵니다.\n위아래 여백에 맞춰 답변 길이가 유동적으로 바뀝니다.\n자주 묻는 질문 답변이 나옵니다.\n위아래 여백에 맞춰 답변 길이가 유동적으로 바뀝니다.',
          createAt: DateTime.now(),
        ),
      ],
    };
    for(String category in _categories) {
      if (category == '전체') continue;
      _faqLists[category] = _faqLists['전체']!.where((faq) => faq.category == category).map((faq) => FAQ.clone(faq)).toList();
    }
    notifyListeners();
  }

  void onTap(FAQ faq) {
    faq.isExpanded = !faq.isExpanded;
    notifyListeners();
  }
  
  void collapseAll() {
    for(String category in _faqLists.keys) {
      for(FAQ faq in _faqLists[category]!) {
        faq.isExpanded = false;
      }
    }
    notifyListeners();
  }
}