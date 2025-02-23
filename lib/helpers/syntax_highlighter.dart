import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CustomSyntaxHighlighter extends SyntaxHighlighter {
  final Map<String, TextStyle> _languageStyles = {
    'keyword': TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
    'string': TextStyle(color: Colors.green),
    'comment': TextStyle(color: Colors.grey),
    'number': TextStyle(color: Colors.orange),
    'default': TextStyle(color: Colors.black),
  };

  @override
  TextSpan format(String source) {
    final List<TextSpan> spans = [];

    // Language patterns for syntax highlighting
    final languagePatterns = {
      // Dart
      'dart': {
        'keywords':
            r'\b(class|void|var|final|if|else|for|while|try|catch|return|void)\b',
        'strings': r'\".*?\"',
        'comments': r'//.*|/\*.*?\*/',
        'numbers': r'\b\d+(\.\d+)?\b',
      },
      // JavaScript
      'javascript': {
        'keywords': r'\b(function|var|let|const|if|else|for|while|return)\b',
        'strings': r'\".*?\"',
        'comments': r'//.*|/\*.*?\*/',
        'numbers': r'\b\d+(\.\d+)?\b',
      },
      // Python
      'python': {
        'keywords': r'\b(def|class|if|else|elif|for|while|try|except|return)\b',
        'strings': r'\".*?\"',
        'comments': r'#.*',
        'numbers': r'\b\d+(\.\d+)?\b',
      },
      // Java
      'java': {
        'keywords':
            r'\b(class|public|private|static|void|int|if|else|for|while|try|catch|return)\b',
        'strings': r'\".*?\"',
        'comments': r'//.*|/\*.*?\*/',
        'numbers': r'\b\d+(\.\d+)?\b',
      },
      // C
      'c': {
        'keywords':
            r'\b(int|char|float|double|void|if|else|for|while|return)\b',
        'strings': r'\".*?\"',
        'comments': r'//.*|/\*.*?\*/',
        'numbers': r'\b\d+(\.\d+)?\b',
      },
      // C++
      'cpp': {
        'keywords':
            r'\b(int|char|float|double|void|if|else|for|while|return|namespace|class|public|private|protected|template|new|delete)\b',
        'strings': r'\".*?\"',
        'comments': r'//.*|/\*.*?\*/',
        'numbers': r'\b\d+(\.\d+)?\b',
      },
      // Ruby
      'ruby': {
        'keywords': r'\b(def|class|if|else|elsif|while|return|yield|module)\b',
        'strings': r'\".*?\"',
        'comments': r'#.*',
        'numbers': r'\b\d+(\.\d+)?\b',
      },
      // PHP
      'php': {
        'keywords':
            r'\b(function|class|if|else|elseif|for|while|return|public|private)\b',
        'strings': r'\".*?\"',
        'comments': r'//.*|/\*.*?\*/',
        'numbers': r'\b\d+(\.\d+)?\b',
      },
      // Swift
      'swift': {
        'keywords': r'\b(class|func|var|let|if|else|for|while|return|import)\b',
        'strings': r'\".*?\"',
        'comments': r'//.*|/\*.*?\*/',
        'numbers': r'\b\d+(\.\d+)?\b',
      },
      // Go
      'go': {
        'keywords': r'\b(func|var|package|if|else|for|return|import)\b',
        'strings': r'\".*?\"',
        'comments': r'//.*|/\*.*?\*/',
        'numbers': r'\b\d+(\.\d+)?\b',
      },
    };

    String language = 'c'; // Change this to the language you want to highlight

    // Match and highlight the various components
    final patterns = languagePatterns[language]!;
    final keywordRegExp = RegExp(patterns['keywords']!);
    final stringRegExp = RegExp(patterns['strings']!);
    final commentRegExp = RegExp(patterns['comments']!);
    final numberRegExp = RegExp(patterns['numbers']!);

    int lastMatchEnd = 0;

    // Function to add text span for each regex match
    void addTextSpan(String matchText, TextStyle style) {
      spans.add(TextSpan(text: matchText, style: style));
    }

    final allMatches = [
      keywordRegExp.allMatches(source),
      stringRegExp.allMatches(source),
      commentRegExp.allMatches(source),
      numberRegExp.allMatches(source),
    ];

    final List<Iterable<RegExpMatch>> sortedMatches = [
      allMatches[0], // Keywords
      allMatches[1], // Strings
      allMatches[2], // Comments
      allMatches[3], // Numbers
    ];

    for (var matches in sortedMatches) {
      for (final match in matches) {
        if (match.start > lastMatchEnd) {
          addTextSpan(
            source.substring(lastMatchEnd, match.start),
            _languageStyles['default']!,
          );
        }

        TextStyle matchStyle = _languageStyles['default']!;
        if (matches == allMatches[0]) {
          matchStyle = _languageStyles['keyword']!;
        } else if (matches == allMatches[1]) {
          matchStyle = _languageStyles['string']!;
        } else if (matches == allMatches[2]) {
          matchStyle = _languageStyles['comment']!;
        } else if (matches == allMatches[3]) {
          matchStyle = _languageStyles['number']!;
        }

        addTextSpan(match.group(0)!, matchStyle);
        lastMatchEnd = match.end;
      }
    }

    if (lastMatchEnd < source.length) {
      spans.add(
        TextSpan(
          text: source.substring(lastMatchEnd),
          style: _languageStyles['default']!,
        ),
      );
    }

    return TextSpan(children: spans);
  }
}
