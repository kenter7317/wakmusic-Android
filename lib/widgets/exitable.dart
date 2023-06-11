import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/scope.dart';

export 'package:wakmusic/models_v2/scope.dart';

typedef ExitableCallback<T> = void Function(T);

class Exitable extends StatefulWidget {
  const Exitable({
    super.key,
    required this.onExitable,
    required this.child,
  });

  final ExitableCallback<ExitScope>? onExitable;

  final Widget child;

  @override
  State<Exitable> createState() => _ExitableState();
}

class _ExitableState extends State<Exitable> {
  StreamSubscription<ExitScope>? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.onExitable != null) {
      _subscription?.cancel();
      _subscription = ExitScope.stream.listen(widget.onExitable);
    }
  }

  @override
  void didUpdateWidget(Exitable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onExitable != oldWidget.onExitable && _subscription != null) {
      if (oldWidget.onExitable != null) {
        _subscription!.cancel();
      }
      if (widget.onExitable != null) {
        _subscription = ExitScope.stream.listen(widget.onExitable);
      }
    }
  }

  @override
  void dispose() {
    if (widget.onExitable != null) {
      _subscription?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
