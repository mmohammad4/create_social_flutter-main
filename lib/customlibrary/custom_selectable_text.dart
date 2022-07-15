    // selecting text for text post

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const int iOSHorizontalOffset = -2;

class CustomSelectableText extends StatefulWidget {
  const CustomSelectableText(
      String this.data, {
        Key? key,
        this.focusNode,
        this.style,
        this.textAlign,
        this.showCursor = false,
        this.autofocus = false,
        ToolbarOptions? toolbarOptions,
        this.minLines,
        this.maxLines,
        this.cursorWidth = 2.0,
        this.cursorHeight,
        this.cursorRadius,
        this.cursorColor,
        this.dragStartBehavior = DragStartBehavior.start,
        this.enableInteractiveSelection = true,
        this.selectionControls,
        this.onTap,
        this.scrollPhysics,
        this.textHeightBehavior,
        this.textWidthBasis,
        this.onSelectionChanged,
      }) :  assert(showCursor != null),
        assert(autofocus != null),
        assert(dragStartBehavior != null),
        assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert(
        (maxLines == null) || (minLines == null) || (maxLines >= minLines),
        "minLines can't be greater than maxLines",
        ),
        assert(
        data != null,
        'A non-null String must be provided to a SelectableText widget.',
        ),
        textSpan = null,
        toolbarOptions = toolbarOptions ??
            const ToolbarOptions(
              selectAll: true,
              copy: true,
            ),
        super(key: key);


  const CustomSelectableText.rich(
      TextSpan this.textSpan, {
        Key? key,
        this.focusNode,
        this.style,
        this.textAlign,
        this.showCursor = false,
        this.autofocus = false,
        ToolbarOptions? toolbarOptions,
        this.minLines,
        this.maxLines,
        this.cursorWidth = 2.0,
        this.cursorHeight,
        this.cursorRadius,
        this.cursorColor,
        this.dragStartBehavior = DragStartBehavior.start,
        this.enableInteractiveSelection = true,
        this.selectionControls,
        this.onTap,
        this.scrollPhysics,
        this.textHeightBehavior,
        this.textWidthBasis,
        this.onSelectionChanged,
      }) :  assert(showCursor != null),
        assert(autofocus != null),
        assert(dragStartBehavior != null),
        assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert(
        (maxLines == null) || (minLines == null) || (maxLines >= minLines),
        "minLines can't be greater than maxLines",
        ),
        assert(
        textSpan != null,
        'A non-null TextSpan must be provided to a SelectableText.rich widget.',
        ),
        data = null,
        toolbarOptions = toolbarOptions ??
            const ToolbarOptions(
              selectAll: true,
              copy: true,
            ),
        super(key: key);

  final String? data;
  final TextSpan? textSpan;
  final FocusNode? focusNode;
  final TextStyle? style;
  final TextAlign? textAlign;


  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.editableText.minLines}
  final int? minLines;

  /// {@macro flutter.widgets.editableText.maxLines}
  final int? maxLines;

  /// {@macro flutter.widgets.editableText.showCursor}
  final bool showCursor;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius? cursorRadius;

  /// The color to use when painting the cursor.
  ///
  /// Defaults to the theme's `cursorColor` when null.
  final Color? cursorColor;

  /// {@macro flutter.widgets.editableText.enableInteractiveSelection}
  final bool enableInteractiveSelection;

  /// {@macro flutter.widgets.editableText.selectionControls}
  final TextSelectionControls? selectionControls;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  final ToolbarOptions toolbarOptions;

  /// {@macro flutter.widgets.editableText.selectionEnabled}
  bool get selectionEnabled => enableInteractiveSelection;

  final GestureTapCallback? onTap;

  /// {@macro flutter.widgets.editableText.scrollPhysics}
  final ScrollPhysics? scrollPhysics;

  /// {@macro flutter.dart:ui.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis? textWidthBasis;

  /// {@macro flutter.widgets.editableText.onSelectionChanged}
  final SelectionChangedCallback? onSelectionChanged;

  @override
  State<CustomSelectableText> createState() => _CustomSelectableTextState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<String>('data', data, defaultValue: null));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode, defaultValue: null));
    properties.add(DiagnosticsProperty<TextStyle>('style', style, defaultValue: null));
    properties.add(DiagnosticsProperty<bool>('autofocus', autofocus, defaultValue: false));
    properties.add(DiagnosticsProperty<bool>('showCursor', showCursor, defaultValue: false));
    properties.add(IntProperty('minLines', minLines, defaultValue: null));
    properties.add(IntProperty('maxLines', maxLines, defaultValue: null));
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign, defaultValue: null));
    properties.add(DoubleProperty('cursorWidth', cursorWidth, defaultValue: 2.0));
    properties.add(DoubleProperty('cursorHeight', cursorHeight, defaultValue: null));
    properties.add(DiagnosticsProperty<Radius>('cursorRadius', cursorRadius, defaultValue: null));
    properties.add(DiagnosticsProperty<Color>('cursorColor', cursorColor, defaultValue: null));
    properties.add(FlagProperty('selectionEnabled', value: selectionEnabled, defaultValue: true, ifFalse: 'selection disabled'));
    properties.add(DiagnosticsProperty<TextSelectionControls>('selectionControls', selectionControls, defaultValue: null));
    properties.add(DiagnosticsProperty<ScrollPhysics>('scrollPhysics', scrollPhysics, defaultValue: null));
    properties.add(DiagnosticsProperty<TextHeightBehavior>('textHeightBehavior', textHeightBehavior, defaultValue: null));
  }
}

class _CustomSelectableTextState extends State<CustomSelectableText> with
    AutomaticKeepAliveClientMixin implements TextSelectionGestureDetectorBuilderDelegate {
  EditableTextState? get _editableText => editableTextKey.currentState;

  late _TextSpanEditingController _controller;

  FocusNode? _focusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode(skipTraversal: true));

  bool _showSelectionHandles = false;

  late _SelectableTextSelectionGestureDetectorBuilder _selectionGestureDetectorBuilder;

  // API for TextSelectionGestureDetectorBuilderDelegate.
  @override
  late bool forcePressEnabled;

  @override
  final GlobalKey<EditableTextState> editableTextKey = GlobalKey<EditableTextState>();

  @override
  bool get selectionEnabled => widget.selectionEnabled;
  // End of API for TextSelectionGestureDetectorBuilderDelegate.

  @override
  void initState() {
    super.initState();
    _selectionGestureDetectorBuilder = _SelectableTextSelectionGestureDetectorBuilder(state: this);
    _controller = _TextSpanEditingController(
      textSpan: widget.textSpan ?? TextSpan(text: widget.data),
    );
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(CustomSelectableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data || widget.textSpan != oldWidget.textSpan) {
      _controller.removeListener(_onControllerChanged);
      _controller = _TextSpanEditingController(
        textSpan: widget.textSpan ?? TextSpan(text: widget.data),
      );
      _controller.addListener(_onControllerChanged);
    }
    if (_effectiveFocusNode.hasFocus && _controller.selection.isCollapsed) {
      _showSelectionHandles = false;
    } else {
      _showSelectionHandles = true;
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final bool showSelectionHandles = !_effectiveFocusNode.hasFocus
        || !_controller.selection.isCollapsed;
    if (showSelectionHandles == _showSelectionHandles) {
      return;
    }
    setState(() {
      _showSelectionHandles = showSelectionHandles;
    });
  }

  TextSelection? _lastSeenTextSelection;

  void _handleSelectionChanged(TextSelection selection, SelectionChangedCause? cause) {
    final bool willShowSelectionHandles = _shouldShowSelectionHandles(cause);
    if (willShowSelectionHandles != _showSelectionHandles) {
      setState(() {
        _showSelectionHandles = willShowSelectionHandles;
      });
    }
    // TODO(chunhtai): The selection may be the same. We should remove this
    // check once this is fixed https://github.com/flutter/flutter/issues/76349.
    if (widget.onSelectionChanged != null && _lastSeenTextSelection != selection) {
      widget.onSelectionChanged!(selection, cause);
    }
    _lastSeenTextSelection = selection;

    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        if (cause == SelectionChangedCause.longPress) {
          _editableText?.bringIntoView(selection.base);
        }
        return;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      // Do nothing.
    }
  }

  /// Toggle the toolbar when a selection handle is tapped.
  void _handleSelectionHandleTapped() {
    if (_controller.selection.isCollapsed) {
      _editableText!.toggleToolbar();
    }
  }

  bool _shouldShowSelectionHandles(SelectionChangedCause? cause) {
    // When the text field is activated by something that doesn't trigger the
    // selection overlay, we shouldn't show the handles either.
    if (!_selectionGestureDetectorBuilder.shouldShowSelectionToolbar)
      return false;

    if (_controller.selection.isCollapsed)
      return false;

    if (cause == SelectionChangedCause.keyboard)
      return false;

    if (cause == SelectionChangedCause.longPress)
      return true;

    if (_controller.text.isNotEmpty)
      return true;

    return false;
  }

  @override
  bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    assert(() {
      return _controller._textSpan.visitChildren((InlineSpan span) => span.runtimeType == TextSpan);
    }(), 'SelectableText only supports TextSpan; Other type of InlineSpan is not allowed');
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasDirectionality(context));
    assert(
    !(widget.style != null && widget.style!.inherit == false &&
        (widget.style!.fontSize == null || widget.style!.textBaseline == null)),
    'inherit false style must supply fontSize and textBaseline',
    );

    final ThemeData theme = Theme.of(context);
    final TextSelectionThemeData selectionTheme = TextSelectionTheme.of(context);
    final FocusNode focusNode = _effectiveFocusNode;

    TextSelectionControls? textSelectionControls =  widget.selectionControls;
    final bool paintCursorAboveText;
    final bool cursorOpacityAnimates;
    Offset? cursorOffset;
    Color? cursorColor = widget.cursorColor;
    final Color selectionColor;
    Radius? cursorRadius = widget.cursorRadius;

    switch (theme.platform) {
      case TargetPlatform.iOS:
        final CupertinoThemeData cupertinoTheme = CupertinoTheme.of(context);
        forcePressEnabled = true;
        textSelectionControls ??= cupertinoTextSelectionControls;
        paintCursorAboveText = true;
        cursorOpacityAnimates = true;
        cursorColor ??= selectionTheme.cursorColor ?? cupertinoTheme.primaryColor;
        selectionColor = selectionTheme.selectionColor ?? cupertinoTheme.primaryColor.withOpacity(0.40);
        cursorRadius ??= const Radius.circular(2.0);
        cursorOffset = Offset(iOSHorizontalOffset / MediaQuery.of(context).devicePixelRatio, 0);
        break;

      case TargetPlatform.macOS:
        final CupertinoThemeData cupertinoTheme = CupertinoTheme.of(context);
        forcePressEnabled = false;
        textSelectionControls ??= cupertinoDesktopTextSelectionControls;
        paintCursorAboveText = true;
        cursorOpacityAnimates = true;
        cursorColor ??= selectionTheme.cursorColor ?? cupertinoTheme.primaryColor;
        selectionColor = selectionTheme.selectionColor ?? cupertinoTheme.primaryColor.withOpacity(0.40);
        cursorRadius ??= const Radius.circular(2.0);
        cursorOffset = Offset(iOSHorizontalOffset / MediaQuery.of(context).devicePixelRatio, 0);
        break;

      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        forcePressEnabled = false;
        textSelectionControls ??= materialTextSelectionControls;
        paintCursorAboveText = false;
        cursorOpacityAnimates = false;
        cursorColor ??= selectionTheme.cursorColor ?? theme.colorScheme.primary;
        selectionColor = selectionTheme.selectionColor ?? theme.colorScheme.primary.withOpacity(0.40);
        break;

      case TargetPlatform.linux:
      case TargetPlatform.windows:
        forcePressEnabled = false;
        textSelectionControls ??= desktopTextSelectionControls;
        paintCursorAboveText = false;
        cursorOpacityAnimates = false;
        cursorColor ??= selectionTheme.cursorColor ?? theme.colorScheme.primary;
        selectionColor = selectionTheme.selectionColor ?? theme.colorScheme.primary.withOpacity(0.40);
        break;
    }

    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = widget.style;
    if (effectiveTextStyle == null || effectiveTextStyle.inherit)
      effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
    if (MediaQuery.boldTextOverride(context))
      effectiveTextStyle = effectiveTextStyle.merge(const TextStyle(fontWeight: FontWeight.bold));
    final Widget child = RepaintBoundary(
      child: EditableText(
        key: editableTextKey,
        style: effectiveTextStyle,
        readOnly: true,
        textWidthBasis: widget.textWidthBasis ?? defaultTextStyle.textWidthBasis,
        textHeightBehavior: widget.textHeightBehavior ?? defaultTextStyle.textHeightBehavior,
        showSelectionHandles: _showSelectionHandles,
        showCursor: widget.showCursor,
        controller: _controller,
        focusNode: focusNode,
        strutStyle: const StrutStyle(),
        textAlign: widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start,
        autofocus: widget.autofocus,
        forceLine: false,
        toolbarOptions: widget.toolbarOptions,
        minLines: widget.minLines,
        maxLines: widget.maxLines ?? defaultTextStyle.maxLines,
        selectionColor: selectionColor,
        selectionControls: widget.selectionEnabled ? textSelectionControls : null,
        onSelectionChanged: _handleSelectionChanged,
        onSelectionHandleTapped: _handleSelectionHandleTapped,
        rendererIgnoresPointer: true,
        cursorWidth: widget.cursorWidth,
        cursorHeight: widget.cursorHeight,
        cursorRadius: cursorRadius,
        cursorColor: cursorColor,
        cursorOpacityAnimates: cursorOpacityAnimates,
        cursorOffset: cursorOffset,
        paintCursorAboveText: paintCursorAboveText,
        backgroundCursorColor: CupertinoColors.inactiveGray,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        dragStartBehavior: widget.dragStartBehavior,
        scrollPhysics: widget.scrollPhysics,
      ),
    );

    return Semantics(
      onLongPress: () {
        _effectiveFocusNode.requestFocus();
      },
      child: _selectionGestureDetectorBuilder.buildGestureDetector(
        behavior: HitTestBehavior.translucent,
        child: child,
      ),
    );
  }
}


class _TextSpanEditingController extends TextEditingController {
  _TextSpanEditingController({required TextSpan textSpan}):
        assert(textSpan != null),
        _textSpan = textSpan,
        super(text: textSpan.toPlainText(includeSemanticsLabels: false));

  final TextSpan _textSpan;

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    // This does not care about composing.
    return TextSpan(
      style: style,
      children: <TextSpan>[_textSpan],
    );
  }

  @override
  set text(String? newText) {
    // This should never be reached.
    throw UnimplementedError();
  }
}

class _SelectableTextSelectionGestureDetectorBuilder extends
TextSelectionGestureDetectorBuilder {
  _SelectableTextSelectionGestureDetectorBuilder({
    required _CustomSelectableTextState state,
  }) : _state = state,
        super(delegate: state);

  final _CustomSelectableTextState _state;

  @override
  void onForcePressStart(ForcePressDetails details) {
    super.onForcePressStart(details);
    if (delegate.selectionEnabled && shouldShowSelectionToolbar) {
      editableText.showToolbar();
    }
  }

  @override
  void onForcePressEnd(ForcePressDetails details) {
    // Not required.
  }

  @override
  void onSingleLongTapMoveUpdate(LongPressMoveUpdateDetails details) {
    if (delegate.selectionEnabled) {
      renderEditable.selectWordsInRange(
        from: details.globalPosition - details.offsetFromOrigin,
        to: details.globalPosition,
        cause: SelectionChangedCause.longPress,
      );
    }
  }

  @override
  void onSingleTapUp(TapUpDetails details) {
    editableText.hideToolbar();
    if (delegate.selectionEnabled) {
      switch (Theme.of(_state.context).platform) {
        case TargetPlatform.iOS:
          renderEditable.selectWordEdge(cause: SelectionChangedCause.tap);
          break;
        case TargetPlatform.android:
          renderEditable.selectPosition(cause: SelectionChangedCause.tap);
          break;
        default :
          break;
      }
    }
    _state.widget.onTap?.call();
  }

  @override
  void onSingleLongTapStart(LongPressStartDetails details) {
    if (delegate.selectionEnabled) {
      renderEditable.selectWord(cause: SelectionChangedCause.longPress);
      Feedback.forLongPress(_state.context);
    }
  }
}


