import 'dart:math';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/profile.dart';
import 'package:wakmusic/repository/user_repo.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:wakmusic/widgets/common/edit_btn.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/widgets/common/text_with_dot.dart';
import 'package:wakmusic/widgets/common/toast_msg.dart';

enum BotSheetType {
  createList('리스트 만들기', '리스트 명', '리스트 생성'),
  editList('리스트 수정하기', '리스트 명', '리스트 수정'),
  loadList('리스트 가져오기', '리스트 코드', '가져오기'),
  shareList('리스트 공유하기', '리스트 코드', '확인'),
  selProfile('프로필을 선택해주세요', '', '완료'),
  editName('닉네임 수정', '닉네임', '완료');

  const BotSheetType(this.title, this.formTitle, this.btnText);
  final String title;
  final String formTitle;
  final String btnText;
}

enum FormType {
  none(WakColor.grey200, ''),
  error(WakColor.pink, '자 이내로 입력해 주세요.'),
  enable(WakColor.blue, '사용할 수 있는 제목입니다.'),
  loading(WakColor.grey200, '');

  const FormType(this.color, this.errorMsg);
  final Color color;
  final String errorMsg;
}

class BotSheet extends StatefulWidget {
  const BotSheet({
    super.key,
    required this.type,
    this.initialValue,
    this.profiles,
  });
  final BotSheetType type;
  final String? initialValue;
  final List<Profile>? profiles;

  @override
  State<BotSheet> createState() => _BotSheetState();
}

class _BotSheetState extends State<BotSheet> {
  final int _maxLength = 12;
  FormType _type = FormType.none;
  late String _profile;
  late final TextEditingController _fieldText;

  @override
  void initState() {
    super.initState();
    assert(widget.type != BotSheetType.selProfile || widget.profiles != null);
    if (widget.type == BotSheetType.selProfile) {
      _profile = widget.initialValue ?? 'panchi';
    }
    _fieldText = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _fieldText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: max(MediaQuery.of(context).viewInsets.bottom,
                MediaQuery.of(context).viewPadding.bottom),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.type.title,
                  style: WakText.txt18M,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 32, 0, 40),
                  child: (widget.type != BotSheetType.selProfile)
                      ? _buildFormSheet(context)
                      : _buildProfileSheet(),
                ),
                GestureDetector(
                  onTap: () async {
                    if (_type == FormType.enable) {
                      if (widget.type == BotSheetType.loadList) {
                        try {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            _type = FormType.loading;
                          });
                          if (_fieldText.text.length != 10) {
                            throw Exception('Invalid Playlist Key :(');
                          }

                          final repo = UserRepository();
                          await repo
                              .addToMyPlaylist(_fieldText.text)
                              .then((list) => Navigator.pop(context, list));
                        } catch (_) {
                          if (_ == HttpStatus.notFound) {
                            return;
                          }
                          showToastWidget(
                            context: context,
                            position: const StyledToastPosition(
                              align: Alignment.bottomCenter,
                              offset: 56,
                            ),
                            animation: StyledToastAnimation.slideFromBottomFade,
                            reverseAnimation: StyledToastAnimation.fade,
                            const ToastMsg(msg: '잘못된 리스트 코드입니다.'),
                          );
                          setState(() => _type = FormType.enable);
                        }
                      } else {
                        Navigator.pop(
                          context,
                          () {
                            switch (widget.type) {
                              case BotSheetType.shareList:
                                return null;
                              case BotSheetType.selProfile:
                                return widget.profiles
                                    ?.singleWhere((e) => e.type == _profile);
                              default:
                                return _fieldText.text;
                            }
                          }(),
                        );
                      }
                    }
                  },
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (_type == FormType.enable ||
                              _type == FormType.loading)
                          ? WakColor.lightBlue
                          : WakColor.grey300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: (_type == FormType.loading)
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                                color: WakColor.grey25),
                          )
                        : Text(
                            widget.type.btnText,
                            style:
                                WakText.txt18M.copyWith(color: WakColor.grey25),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSheet(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.type.formTitle,
          style: WakText.txt16L.copyWith(color: WakColor.grey400),
        ),
        const SizedBox(height: 4),
        () {
          switch (widget.type) {
            case BotSheetType.createList:
            case BotSheetType.editList:
              return _buildCreateForm();
            case BotSheetType.editName:
              return _buildNameForm();
            case BotSheetType.loadList:
              return _buildLoadForm();
            case BotSheetType.shareList:
              return _buildShareForm(context);
            default:
              return Container();
          }
        }(),
      ],
    );
  }

  Widget _buildBaseForm({
    required UnderlineInputBorder border,
    required String hintText,
    int? maxLength,
    required void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: _fieldText,
      style: WakText.txt20M.copyWith(height: 1.0, color: WakColor.grey800),
      cursorColor: WakColor.grey900,
      maxLength: maxLength,
      buildCounter:
          (_, {required currentLength, required isFocused, maxLength}) => null,
      onChanged: onChanged,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: border,
        focusedBorder: border,
        enabledBorder: border,
        hintText: hintText,
        hintStyle: WakText.txt20M.copyWith(color: WakColor.grey400),
        suffixIcon: (_fieldText.text != '')
            ? GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _fieldText.clear();
                  setState(() => _type = FormType.none);
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(8, 16, 0, 16),
                  child: EditBtn(type: BtnType.cancel),
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(maxWidth: 53),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Column(
      children: [
        _buildBaseForm(
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: _type.color),
          ),
          hintText: '리스트 명을 입력하세요.',
          maxLength: _maxLength,
          onChanged: (value) {
            setState(() {
              if (value.isEmpty || value == widget.initialValue) {
                _type = FormType.none;
              } /* else if (value == 'test') { /* error condition */
                _type = FormType.error;
              }*/
              else {
                _type = FormType.enable;
              }
            });
          },
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                _type.errorMsg,
                style: WakText.txt12L.copyWith(color: _type.color),
              ),
            ),
            Text(
              '${_fieldText.text.runes.length}자',
              style: WakText.txt12L.copyWith(color: WakColor.lightBlue),
              textAlign: TextAlign.right,
            ),
            Text(
              '/$_maxLength자',
              style: WakText.txt12L.copyWith(color: WakColor.grey500),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadForm() {
    return Column(
      children: [
        _buildBaseForm(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: FormType.none.color),
            ),
            hintText: '코드를 입력해주세요.',
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _type = FormType.none;
                } else {
                  _type = FormType.enable;
                }
              });
            }),
        const SizedBox(height: 12),
        const TextWithDot(text: '리스트 코드로 리스트를 가져올 수 있습니다.'),
      ],
    );
  }

  Widget _buildShareForm(BuildContext context) {
    _type = FormType.enable;
    return Column(
      children: [
        TextFormField(
          initialValue: widget.initialValue,
          readOnly: true,
          enableInteractiveSelection: false,
          style: WakText.txt20M.copyWith(color: WakColor.grey800),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: FormType.none.color),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: FormType.none.color),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: FormType.none.color),
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.initialValue));
                showToastWidget(
                  context: context,
                  position: const StyledToastPosition(
                    align: Alignment.bottomCenter,
                    offset: 56,
                  ),
                  animation: StyledToastAnimation.slideFromBottomFade,
                  reverseAnimation: StyledToastAnimation.fade,
                  const ToastMsg(msg: '복사가 완료되었습니다.'),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 0, 12),
                child: SvgPicture.asset(
                  'assets/icons/ic_32_copy.svg',
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(maxWidth: 40),
          ),
        ),
        const SizedBox(height: 12),
        const TextWithDot(text: '리스트 코드로 리스트를 가져올 수 있습니다.'),
      ],
    );
  }

  Widget _buildProfileSheet() {
    _type = FormType.enable;
    return Column(
      children: [
        Row(
          children: List.generate(
            7,
            (idx) {
              if (idx % 2 == 0) {
                return _buildProfile(idx ~/ 2);
              } else {
                return const SizedBox(width: 10);
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(
            7,
            (idx) {
              if (idx % 2 == 0) {
                return _buildProfile(4 + idx ~/ 2);
              } else {
                return const SizedBox(width: 10);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfile(int idx) {
    final profile = widget.profiles![idx];
    double width = (MediaQuery.of(context).size.width - 70) / 4;
    return GestureDetector(
      onTap: () => setState(() => _profile = profile.type),
      child: ExtendedImage.network(
        '${API.static.url}/profile/${profile.type}.png'
        '?v=${profile.imageVersion}',
        fit: BoxFit.cover,
        shape: BoxShape.circle,
        width: width,
        height: width,
        border: Border.all(
          color: (_profile == profile.type)
              ? WakColor.lightBlue
              : Colors.transparent,
          width: 2,
        ),
        loadStateChanged: (state) {
          if (state.extendedImageLoadState != LoadState.completed) {
            return SkeletonBox(
              child: Container(
                width: width,
                height: width,
                decoration: const BoxDecoration(
                  color: WakColor.grey200,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }
          return null;
        },
        cacheMaxAge: const Duration(days: 30),
      ),
    );
  }

  Widget _buildNameForm() {
    if (_fieldText.text.runes.length > 8) _type = FormType.error;
    return Column(
      children: [
        _buildBaseForm(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: _type.color),
            ),
            hintText: '닉네임을 입력하세요.',
            maxLength: 8,
            onChanged: (value) {
              setState(() {
                if (value.isEmpty || value == widget.initialValue) {
                  _type = FormType.none;
                } /* else if (value == 'test') { /* error condition */
                _type = FormType.error;
              }*/
                else {
                  _type = FormType.enable;
                }
              });
            }),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                () {
                  switch (_type) {
                    case FormType.error:
                      return '8${_type.errorMsg}';
                    case FormType.enable:
                      return '사용할 수 있는 닉네임입니다.';
                    default:
                      return _type.errorMsg;
                  }
                }(),
                style: WakText.txt12L.copyWith(color: _type.color),
              ),
            ),
            Text(
              '${_fieldText.text.runes.length}자',
              style: WakText.txt12L.copyWith(color: WakColor.lightBlue),
              textAlign: TextAlign.right,
            ),
            Text(
              '/8자',
              style: WakText.txt12L.copyWith(color: WakColor.grey500),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ],
    );
  }
}
