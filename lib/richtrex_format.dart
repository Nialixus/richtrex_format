/// An extended package of `RichTrexPackage`. This package is used to encode [TextSpan] into String, and decode [TextSpan] from String.
library richtrex_format;

import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import 'package:richtrex_image/richtrex_image.dart';

/// This tool has two main functions, which are encoding and decoding [TextSpan].
class RichTrexFormat {
  /// Decode [TextSpan] from String.
  ///
  /// ```dart
  /// RichTrexFormat.decode(
  ///   '<style="font-size:75;">Text</style>'
  /// );
  /// ```
  static TextSpan decode(String text, {TextStyle? style}) {
    // Shortcut of find matched text with [RegExp].
    String? regMatch(String text, String pattern) =>
        RegExp(pattern).stringMatch(text);

    // Split text between Tagged Text and Plain Text.
    List<String> textlist = text.split(RegExp(
        r'(?=<style=)|(?<=<\/style>)|(?=<widget=)|(?<=;"\/>)|(?<=<\/widget>)'));

    // Clean Text from Tag.
    String newText(String text) {
      try {
        return text.replaceAll(
            RegExp(
                r'<style=".*?">|<\/style>|<widget=.*?;"\/>|(<widget=".*?;">)|(<\/widget>)'),
            "");
      } catch (e) {
        return text;
      }
    }

    // Get Color from Tag.
    Color? color(String text) {
      try {
        String value = regMatch(text, r'(?<=font-color:).*?(?=;)')!;
        return Color(int.parse(value));
      } catch (e) {
        return null;
      }
    }

    // Get Background-Color from Tag.
    Color? backgroundColor(String text) {
      try {
        String value = regMatch(text, r'(?<=background-color:).*?(?=;)')!;
        return Color(int.parse(value));
      } catch (e) {
        return null;
      }
    }

    // Get Font-Weight from Tag.
    FontWeight? fontWeight(String text) {
      try {
        String value = regMatch(text, r'(?<=font-weight:).*?(?=;)')!;
        return FontWeight.values[int.parse(value)];
      } catch (e) {
        return null;
      }
    }

    // Get Height from Tag.
    double? height(String text) {
      try {
        String value = regMatch(text, r'(?<=height:).*?(?=;)')!;
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }

    // Get Font-Family from Tag.
    String? fontFamily(String text) {
      try {
        String value = regMatch(text, r'(?<=font-family:).*?(?=;)')!;
        return value;
      } catch (e) {
        return null;
      }
    }

    // Get Font-Size from Tag.
    double? fontSize(String text) {
      try {
        String value = regMatch(text, r'(?<=font-size:).*?(?=;)')!;
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }

    // Get Font-Space from Tag.
    double? fontSpace(String text) {
      try {
        String value = regMatch(text, r'(?<=font-space:).*?(?=;)')!;
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }

    // Get Shadow from Tag.
    List<Shadow>? shadow(String text) {
      try {
        String? x = regMatch(text, r'(?<=shadow-x:).*?(?=;)');
        String? y = regMatch(text, r'(?<=shadow-y:).*?(?=;)');
        String color = regMatch(text, r'(?<=shadow-color:).*?(?=;)')!;
        String blurRadius = regMatch(text, r'(?<=shadow-blur:).*?(?=;)')!;
        return [
          Shadow(
              color: Color(int.parse(color)),
              blurRadius: double.parse(blurRadius),
              offset: Offset(double.parse(x ?? "0"), double.parse(y ?? "0")))
        ];
      } catch (e) {
        return null;
      }
    }

    // Get Italic from Tag.
    FontStyle? italic(String text) {
      try {
        bool value = text.contains('decoration:italic;');
        return value == true ? FontStyle.italic : null;
      } catch (e) {
        return null;
      }
    }

    // Get Strikethrough from Tag.
    TextDecoration strikeThrough(String text) {
      try {
        bool value = text.contains('decoration:strikethrough;');
        return value == true ? TextDecoration.lineThrough : TextDecoration.none;
      } catch (e) {
        return TextDecoration.none;
      }
    }

    // Get Underline from Tag.
    TextDecoration underline(String text) {
      try {
        bool value = text.contains('decoration:underline;');
        return value == true ? TextDecoration.underline : TextDecoration.none;
      } catch (e) {
        return TextDecoration.none;
      }
    }

    // Get Overline from Tag.
    TextDecoration overline(String text) {
      try {
        bool value = text.contains('decoration:overline;');
        return value == true ? TextDecoration.overline : TextDecoration.none;
      } catch (e) {
        return TextDecoration.none;
      }
    }

    // Get BlockQuote from Tag.
    Decoration? blockQuote(String text) {
      try {
        bool value = text.contains("decoration:blockquote;");
        return value == true
            ? BoxDecoration(
                color: Colors.grey.shade200,
                border: const Border(
                    left: BorderSide(width: 4, color: Colors.grey)))
            : null;
      } catch (e) {
        return null;
      }
    }

    // Get Align from Tag.
    AlignmentGeometry? align(String text) {
      try {
        String x = regMatch(text, r'(?<=align-x:).*?(?=;)')!;
        String? y = regMatch(text, r'(?<=align-y:).*?(?=;)');
        return Alignment(double.parse(x), double.parse(y ?? "0"));
      } catch (e) {
        return null;
      }
    }

    // Get Image from Tag.
    RichTrexImage? image(String text) {
      if (text.contains(RegExp(r'<widget=".*?/>'))) {
        try {
          String? file = regMatch(text, r'(?<=image-file:).*?(?=;)');
          String? width = regMatch(text, r'(?<=image-width:).*?(?=;)');
          String? asset = regMatch(text, r'(?<=image-asset:).*?(?=;)');
          String? memory = regMatch(text, r'(?<=image-memory:).*?(?=;)');
          String? resize = regMatch(text, r'(?<=image-resize:).*?(?=;)');
          String? height = regMatch(text, r'(?<=image-height:).*?(?=;)');
          String? network = regMatch(text, r'(?<=image-network:).*?(?=;)');

          // Parsed [size] from [width] and [height].
          Size size =
              Size(double.parse(width ?? "100"), double.parse(height ?? "100"));

          // Check whether user allowed to resize or not.
          bool allowed = resize == null ? true : resize == "true";

          if (network != null) {
            return RichTrexImage.network(network, size: size, resize: allowed);
          } else if (memory != null) {
            return RichTrexImage.memory(memory, size: size, resize: allowed);
          } else if (file != null) {
            return RichTrexImage.file(file, size: size, resize: allowed);
          } else if (asset != null) {
            return RichTrexImage.asset(asset, size: size, resize: allowed);
          } else {
            return null;
          }
        } catch (e) {
          return null;
        }
      } else {
        return null;
      }
    }

    // Get Hyperlink URL from Tag.
    Link? hyperlink(String text, {required TextSpan span}) {
      try {
        String value = regMatch(text, r'(?<=hyperlink:).*?(?=;)')!;
        return Link(
            uri: Uri.parse(value),
            builder: (_, onTap) => Material(
                child: InkWell(
                    splashColor: Colors.blue.withOpacity(0.1),
                    highlightColor: Colors.blue.withOpacity(0.1),
                    onTap: onTap,
                    child: Text.rich(TextSpan(
                        text: span.text,
                        style: span.style
                            ?.copyWith(color: Colors.blue.shade700))))));
      } catch (e) {
        return null;
      }
    }

    // Generated [TextSpan] from Tag.
    return TextSpan(
        children: List.generate(textlist.length, (x) {
      // Basic style if [style] is null.
      TextStyle initialStyle = style ?? const TextStyle(color: Colors.black);

      // Generated style when tag exist.
      TextStyle generatedStyle = initialStyle.copyWith(
          leadingDistribution: TextLeadingDistribution.even,
          color: color(textlist[x]),
          fontStyle: italic(textlist[x]),
          height: height(textlist[x]),
          fontSize: fontSize(textlist[x]),
          shadows: shadow(textlist[x]),
          fontWeight: fontWeight(textlist[x]),
          fontFamily: fontFamily(textlist[x]),
          letterSpacing: fontSpace(textlist[x]),
          backgroundColor: backgroundColor(textlist[x]),
          decoration: TextDecoration.combine([
            overline(textlist[x]),
            underline(textlist[x]),
            strikeThrough(textlist[x])
          ]));

      // Generated [TextSpan] from <style ... ></style> tag.
      TextSpan textSpan({TextStyle? style}) =>
          TextSpan(text: newText(textlist[x]), style: style ?? generatedStyle);

      // Generated [WidgetSpan] from <widget ... ></widget> tag.
      WidgetSpan widgetSpan({required Widget child}) => WidgetSpan(
          style: initialStyle,
          child: Container(
              alignment: align(textlist[x]),
              decoration: blockQuote(textlist[x]),
              constraints: (align(textlist[x]) == null &&
                      blockQuote(textlist[x]) == null)
                  ? null
                  : const BoxConstraints(minWidth: double.infinity),
              child: child));

      if (textlist[x].contains(RegExp(r'<style=.*?\/style>'))) {
        // textlist[x] with `<style ... ></style>` tag.
        return textSpan();
      } else if (textlist[x]
          .contains(RegExp(r'<widget=.*?;"\/>|<widget=.*?<\/widget>'))) {
        // textlist[x] with `<widget ... />` or <widget ... ></widget> tag.
        List<Widget?> child = [
          image(textlist[x]),
          hyperlink(textlist[x], span: textSpan())
        ];
        try {
          return widgetSpan(
              child: child.lastWhere((element) => element != null)!);
        } catch (e) {
          return widgetSpan(child: Text.rich(textSpan()));
        }
      } else {
        // if textlist[x] has no style, just return basic textspan.
        return TextSpan(text: textlist[x], style: initialStyle);
      }
    }));
  }
}
