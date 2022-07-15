        // see more and see less in text post

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:linkify/linkify.dart';

import 'custom_selectable_text.dart';


enum TrimMode {
  Length,
  Line,
}

class ReadMoreText extends StatefulWidget {
  const ReadMoreText(
      this.data, {
        Key? key,
        this.trimExpandedText = 'show less',
        this.trimCollapsedText = 'read more',
        this.colorClickableText,
        this.trimLength = 240,
        this.trimLines = 2,
        this.trimMode = TrimMode.Length,
        this.style,
        this.textAlign,
        this.textDirection,
        this.semanticsLabel,
        this.moreStyle,
        this.lessStyle,
        this.linkStyle,
        this.onOpen,
        this.showMoreText=true,
        this.delimiter = _kEllipsis + ' ',
        this.delimiterStyle,
        this.callback,
        this.extraLeadingText,
        this.onClickExtraText,
      }) : super(key: key);

  /// Used on TrimMode.Length
  final int trimLength;
  /// TextStyle for expanded text
  final TextStyle? moreStyle;

  /// TextStyle for compressed text
  final TextStyle? lessStyle;

  /// Text to be linkified
  final String? extraLeadingText;

  final bool? showMoreText;

  ///Extra text link
  final Function()? onClickExtraText;

  /// TextStyle for link text
  final TextStyle? linkStyle;

  /// Used on TrimMode.Lines
  final int trimLines;

  /// Callback for tapping a link
  final LinkCallback? onOpen;

  final TextStyle? style;
  final String data;
  final String trimExpandedText;
  final String trimCollapsedText;
  final Color? colorClickableText;
  final TextAlign? textAlign;

  /// Determines the type of trim. TrimMode.Length takes into account
  /// the number of letters, while TrimMode.Lines takes into account
  /// the number of lines
  final TrimMode trimMode;



  ///Called when state change between expanded/compress
  final Function(bool val)? callback;

  final String delimiter;
  final TextDirection? textDirection;
  final String? semanticsLabel;
  final TextStyle? delimiterStyle;

  @override
  ReadMoreTextState createState() => ReadMoreTextState();
}

const String _kEllipsis = '\u2026';

const String _kLineSeparator = '\u2028';

class ReadMoreTextState extends State<ReadMoreText> {
  bool _readMore = true;

  bool useMouseRegion=true;


  @override
  void initState() {
     _readMore=widget.showMoreText ?? true;
    super.initState();
  }

  void _onTapLink() {
    setState(() {
      _readMore = !_readMore;
      widget.callback?.call(_readMore);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = widget.style;
    if (widget.style?.inherit ?? false) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
    }

    final textAlign =
        widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final textDirection = widget.textDirection ?? Directionality.of(context);
    final overflow = defaultTextStyle.overflow;

    final colorClickableText =widget.colorClickableText ?? Theme.of(context).
    colorScheme.secondary;
    final _defaultLessStyle = widget.lessStyle ??
        effectiveTextStyle?.copyWith(color: colorClickableText);
    final _defaultMoreStyle = widget.moreStyle ??
        effectiveTextStyle?.copyWith(color: colorClickableText);
    final _defaultDelimiterStyle = widget.delimiterStyle ?? effectiveTextStyle;

    TextSpan _userName = TextSpan(text: widget.extraLeadingText,
        style: const TextStyle(fontSize: 15,
            color: Colors.blueAccent,
            fontWeight: FontWeight.w500
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = widget.onClickExtraText
    );

    TextSpan link = TextSpan(
      text: _readMore ? widget.trimCollapsedText : widget.trimExpandedText,
      style: _readMore ? _defaultMoreStyle : _defaultLessStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    TextSpan _delimiter = TextSpan(
      text: _readMore
          ? widget.trimCollapsedText.isNotEmpty
          ? widget.delimiter
          : ' '
          : ' ',
      style: _defaultDelimiterStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;

        // Create a TextSpan with data
        final text = TextSpan(
          style: effectiveTextStyle,
          text: widget.data,
        );

        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,
          textAlign: textAlign,
          textDirection: textDirection,
          maxLines: widget.trimLines,
          ellipsis: overflow == TextOverflow.ellipsis ? widget.delimiter : null,
        );
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final linkSize = textPainter.size;

        // Layout and measure delimiter
        textPainter.text = _delimiter;
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final delimiterSize = textPainter.size;

        // Layout and measure text
        textPainter.text= text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;

        // Get the endIndex of data
        bool linkLongerThanLine = false;
        int endIndex;

        if (linkSize.width < maxWidth) {
          final readMoreSize = linkSize.width + delimiterSize.width;
          final pos = textPainter.getPositionForOffset(Offset(
            textDirection == TextDirection.rtl
                ? readMoreSize
                : textSize.width - readMoreSize,
            textSize.height,
          ));
          endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
        } else {
          var pos = textPainter.getPositionForOffset(
            textSize.bottomLeft(Offset.zero),
          );
          endIndex = pos.offset;
          linkLongerThanLine = true;
        }

        var textSpan;
        var elements;
        switch (widget.trimMode) {
          case TrimMode.Line:
            if (textPainter.didExceedMaxLines) {
              elements = linkify(
                _readMore
                    ? widget.data.substring(0, endIndex) +
                    (linkLongerThanLine ? _kLineSeparator : '')
                    : widget.data,
                options: const LinkifyOptions(
                ),
                linkifiers: defaultLinkifiers,
              );
              var _text=elements.map<InlineSpan>(
                    (element) {
                  if (element is LinkableElement ) {
                    if (useMouseRegion) {
                      return TextSpan(
                          text: element.text,
                          style: widget.linkStyle,
                          recognizer: widget.onOpen != null ?
                          (TapGestureRecognizer()..onTap = () => widget.onOpen!(element))
                              : null,
                        );
                    }
                    else {
                      return TextSpan(
                        text: element.text,
                        style: widget.linkStyle,
                        recognizer: widget.onOpen != null ?
                        (TapGestureRecognizer()..onTap = () =>
                            widget.onOpen!(element))
                            : null,
                      );
                    }
                  } else {
                    return TextSpan(
                      text: element.text,
                      style: widget.style,
                    );
                  }
                },
              ).toList();
              if(widget.extraLeadingText != null && widget.onClickExtraText!=null){
                _text.insert(0,_userName);
              }
              _text.add(_delimiter);
              _text.add(link);
              textSpan = TextSpan(
                style: effectiveTextStyle,
                children: _text,
              );
            }
            else {
              elements = linkify(
                widget.data,
                options: const LinkifyOptions(),
                linkifiers: defaultLinkifiers,
              );
              var _text=elements.map<InlineSpan>(
                    (element) {
                  if (element is LinkableElement ) {
                    if (useMouseRegion) {
                      return  TextSpan(
                          text: element.text,
                          style: widget.linkStyle,
                          recognizer: widget.onOpen != null ?
                          (TapGestureRecognizer()..onTap = () => widget.onOpen!(element)) : null,
                        );
                    } else {
                      return TextSpan(
                        text: element.text,
                        style: widget.linkStyle,
                        recognizer: widget.onOpen != null ?
                        (TapGestureRecognizer()..onTap = () => widget.onOpen!(element)) : null,
                      );
                    }
                  }
                  else {
                    return TextSpan(
                      text: element.text,
                      style: widget.style,
                    );
                  }
                },
              ).toList();
              if(widget.extraLeadingText != null && widget.onClickExtraText!=null){
                _text.insert(0,_userName);
              }
              textSpan = TextSpan(
                style: effectiveTextStyle,
                children: _text,
              );
            }
            break;
          default:
            throw Exception(
                'TrimMode type: ${widget.trimMode} is not supported');
        }

        return CustomSelectableText.rich(
          textSpan,
        );
      },
    );
    if (widget.semanticsLabel != null) {
      result = Semantics(
        textDirection: widget.textDirection,
        label: widget.semanticsLabel,
        child: ExcludeSemantics(
          child: result,
        ),
      );
    }
    return result;
  }

}


