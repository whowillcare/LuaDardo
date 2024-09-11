import './match_slice.dart';
import './match.dart';

const int MAX_CAPTURES = 32;

const CAP_UNFINISHED = -1;
const CAP_POSITION = -2;

const MAX_CALLS = 1024;

class Capture {
  int init;
  int len;

  Capture(this.init, this.len);
}

class RegState {
  String input = '';
  int initPos = 0;
  int level = 0;
  int matchDepth = MAX_CALLS;
  String pattern;
  List<Capture> captures = [];

  List<MatchSlice> get capturesList {
    List<MatchSlice> res = [];
    for (int i = 0; i < level; i++) {
      if (captures[i].len >= 0) {
        res.add(MatchSlice(captures[i].init, captures[i].init + captures[i].len, input));
      }
    }

    return res;
  }

  void represtate() {
    level = 0;
    if (matchDepth != MAX_CALLS) {
      throw Exception('invalid pattern capture');
    }
  }


  List<Match> matchAll(String input, [int initPos = 0]) {
    return _matchAll(input, initPos, false);
  }

  Match? firstMatch(String input, [int initPos = 0]) {
    List<Match> matches = _matchAll(input, initPos, true);
    return matches.isEmpty ? null : matches[0];
  }

  List<Match> _matchAll(String input, int initPos, bool isFirst) {
    this.input = input;
    this.initPos = initPos;
    matchDepth = MAX_CALLS;
    int s = initPos;
    int p = 0;
    bool anchor = pattern.codeUnitAt(p) == 94; // ^ ascii is 94
    if (anchor) {
      p++;
    }

    List<Match> matches = [];
    do {
      represtate();
      int res;
      // try {
        res = match(s, p);
      // }
      // catch (e) {
      //   print('e is $e');
      //   res = -1;
      // }

      if(res != -1) {
        List<int> find = [];
        List<bool> isPosition = [];
        find.add(s);
        find.add(res);
        isPosition.add(false);

        for (int i = 0; i < captures.length; i++) {
          var cap = captures[i];
          find.add(cap.init);
          if (cap.len == CAP_POSITION) {
            find.add(cap.init);
            isPosition.add(true);
          }
          else {
            find.add(cap.init + cap.len);
            isPosition.add(false);
          }
        }

        s = res - 1;
        matches.add(Match(input, find, isPosition));
        if (isFirst) {
          break;
        }
      }
    } while (s++ < input.length && (!anchor));

    match(initPos, 0);
    return matches;
  }

  RegState(this.pattern);

  int match(int inputPos, int patternPos, [bool isInit = false]) {
    if (!isInit) {
      if (matchDepth-- == 0) {
        throw Exception('pattern too complex');
      }
    }

    // init start here
    if (patternPos == pattern.length) {
      matchDepth++;
      return inputPos;
    }

    switch (pattern.codeUnitAt(patternPos)) {
      case 40: // '('
        if (pattern.codeUnitAt(patternPos + 1) == 41) { // ')'
          inputPos = startCapture(inputPos, patternPos + 2, CAP_POSITION);
        } else {
          inputPos = startCapture(inputPos, patternPos + 1, CAP_UNFINISHED);
        }
        break;

      case 41: // ')'
        inputPos = endCapture(inputPos, patternPos + 1);
        break;
      case 36: // $ ascii is 36
        if ((patternPos + 1) != pattern.length) {
          return dflt(inputPos, patternPos);
        }

        inputPos = (inputPos == input.length) ? inputPos : -1;
        break;

      case 92: // \ ascii is 92
      case 37: // % ascii is 37
        switch (pattern.codeUnitAt(patternPos + 1)) {
          case 98: // b ascii is 98
            inputPos = matchBalance(inputPos, patternPos + 2);
            if (inputPos != -1) {
              return match(inputPos, patternPos + 4, true);
            }
            break;
          case 102: // f ascii is 102
            patternPos += 2;
            // [ ascii is 91
            if (pattern.codeUnitAt(patternPos) != 91) {
              throw Exception("missing '[' after '%%f' in pattern");
            }

            int ep = classend(patternPos);
            int previous = (inputPos == initPos) ? 0 : input.codeUnitAt(inputPos - 1);
            if (!matchBracketClass(previous, patternPos, ep - 1) &&
                matchBracketClass(input.codeUnitAt(inputPos), patternPos, ep - 1)) {
              return match(inputPos, ep, true);
            }
            inputPos = -1;
            break;
          // 0 ascii is 48
          // 9 ascii is 57
          case 48:
          case 49:
          case 50:
          case 51:
          case 52:
          case 53:
          case 54:
          case 55:
          case 56:
          case 57:
            inputPos = matchCapture(inputPos, pattern.codeUnitAt(patternPos + 1));
            if (inputPos != -1) {
              return match(inputPos, patternPos + 2, true);
            }
            break;
          default:
            return dflt(inputPos, patternPos);
        }
        break;
      default:
        return dflt(inputPos, patternPos);
    }

    matchDepth++;
    return inputPos;
  }

  int matchBalance(int inputPos, int patternPos) {
    if (patternPos + 1 >= pattern.length) {
      throw Exception("malformed pattern (missing arguments to '%%b')");
    }

    if (input.codeUnitAt(inputPos) != pattern.codeUnitAt(patternPos)) {
      return -1;
    }
    else {
      int b = pattern.codeUnitAt(patternPos);
      int e = pattern.codeUnitAt(patternPos + 1);
      int cont = 1;
      while (++inputPos < input.length) {
        if (input.codeUnitAt(inputPos) == e) {
          if (--cont == 0) {
            return inputPos + 1;
          }
        }
        else if (input.codeUnitAt(inputPos) == b) {
          cont++;
        }
      }
    }

    return -1;
  }

  int maxExpand(int inputPos, int patternPos, int ep) {
    int i = 0;
    while (singleMatch(inputPos + i, patternPos, ep)) {
      i++;
    }

    while (i >= 0) {
      int res = match(inputPos + i, ep + 1);
      if (res != -1) {
        return res;
      }
      i--;
    }

    return -1;
  }

  int minExpand(int inputPos, int patternPos, int ep) {
    for (;;) {
      int res = match(inputPos, ep + 1);
      if (res != -1) {
        return res;
      }
      else if (singleMatch(inputPos, patternPos, ep)) {
        inputPos++;
      }
      else {
        return -1;
      }
    }
  }

  int captureToClose() {
    int level = this.level;
    for (level--; level >=0; level--) {
      if (captures[level].len == CAP_UNFINISHED) {
        return level;
      }
    }

    throw Exception('invalid pattern capture');
  }

  int classend(int patternPos) {
    switch (pattern.codeUnitAt(patternPos++)) {
      case 92: // \ ascii is 92
      case 37: // % ascii is 37
        if (patternPos == pattern.length) {
          throw Exception('malformed pattern (ends with %)');
        }
        return patternPos + 1;
      case 91: // [ ascii is 91
        if (pattern.codeUnitAt(patternPos) == 94) { // ^ ascii is 94
          patternPos++;
        }

        do {
          if (patternPos == pattern.length) {
            throw Exception('malformed pattern (missing ]');
          }

          int charP = pattern.codeUnitAt(patternPos++);
          if ((charP == 37 || charP == 92) && patternPos < pattern.length) { // % ascii is 37
            patternPos++;
          }
        } while (pattern.codeUnitAt(patternPos) != 93); // ] ascii is 93
        return patternPos + 1;
      default:
        return patternPos;
    }
  }

  int tolower(int c) {
    return (c >= 65 && c <= 90) ? c + 32 : c;
  }

  bool isalpha(int c) {
    return (c >= 65 && c <= 90) || (c >= 97 && c <= 122);
  }

  bool iscntrl(int c) {
    return (c >= 0 && c <= 31) || (c == 127);
  }

  bool isdigit(int c) {
    return (c >= 48 && c <= 57);
  }

  bool isgraph(int c) {
    return (c > 32 && c <= 126);
  }

  bool islower(int c) {
    return (c >= 97 && c <= 122);
  }

  bool ispunct(int c) {
    return (c > 32 && c <= 126) && !isalnum(c);
  }

  bool isspace(int c) {
    return (c >= 9 && c <= 13) || (c == 32);
  }

  bool isupper(int c) {
    return (c >= 65 && c <= 90);
  }

  bool isalnum(int c) {
    return isalpha(c) || isdigit(c);
  }

  bool isxdigit(int c) {
    return isdigit(c) || (c >= 65 && c <= 70) || (c >= 97 && c <= 102);
  }

  bool singleMatch(int s, int p, int ep) {
    if (s >= input.length) {
      return false;
    }
    else {
      int c = input.codeUnitAt(s);
      switch (pattern.codeUnitAt(p)) {
        case 46: // . ascii is 46
          return true;
        case 92: // \ ascii is 92
        case 37: // % ascii is 37
          return matchClass(c, pattern.codeUnitAt(p + 1));
        case 91: // [ ascii is 91
          return matchBracketClass(c, p, ep - 1);
        default:
          return pattern.codeUnitAt(p) == c;
      }
    }
  }

  bool matchBracketClass(int c, int p, int ec) {
    bool sig = true;
    if (pattern.codeUnitAt(p + 1) == 94) { // ^ ascii is 94
      sig = false;
      p++;
    }

    while (++p < ec) {
      int charP = pattern.codeUnitAt(p);
      if (charP == 37 || charP == 92) { // % ascii is 37
        p++;
        if (matchClass(c, pattern.codeUnitAt(p))) {
          return sig;
        }
      } else if (pattern.codeUnitAt(p + 1) == 45 && p + 2 < ec) { // - ascii is 45
        p += 2;
        if (pattern.codeUnitAt(p - 2) <= c && c <= pattern.codeUnitAt(p)) {
          return sig;
        }
      } else if (charP == c) {
        return sig;
      }
    }

    return !sig;
  }

  bool matchClass(int c, int cl) {
    bool res;
    switch (tolower(cl)) {
      case 97: res = isalpha(c); break; // a ascii is 97
      case 99: res = iscntrl(c); break; // c ascii is 99
      case 100: res = isdigit(c); break; // d ascii is 100
      case 103: res = isgraph(c); break; // g ascii is 103
      case 108: res = islower(c); break; // l ascii is 108
      case 112: res = ispunct(c); break; // p ascii is 112
      case 115: res = isspace(c); break; // s ascii is 115
      case 117: res = isupper(c); break; // u ascii is 117
      case 119: res = isalnum(c); break; // w ascii is 119
      case 120: res = isxdigit(c); break; // x ascii is 120
      case 122: res = (c == 0); break; // z ascii is 122
      default: return (cl == c);
    }

    return (islower(cl) ? res : !res);
  }

  int dflt(int inputPos, int patternPos) {
    int ep = classend(patternPos);
    if (!singleMatch(inputPos, patternPos, ep)) {
      int epChar = 0;
      if (ep < pattern.length) {
        epChar = pattern.codeUnitAt(ep);
      }
      // * ascii is 42
      // ? ascii is 63
      // - ascii is 45
      if (epChar == 42 || epChar == 63 || epChar == 45) {
        return match(inputPos, ep + 1, true);
      } else {
        inputPos = -1;
      }
    }
    else {
      if (ep >= pattern.length) {
        matchDepth++;
        return inputPos;
      }
      switch (pattern.codeUnitAt(ep)) {
        case 63: // ? ascii is 63
          int res;
          if ((res = match(inputPos + 1, ep + 1)) != -1) {
            inputPos = res;
          }
          else {
            return match(inputPos, ep + 1, true);
          }
          break;
        // + ascii is 43
        case 43:
          inputPos ++;
          continue star;

        star:
        case 42: // * ascii is 42
          inputPos = maxExpand(inputPos, patternPos, ep);
          break;
        // - ascii is 45
        case 45:
          inputPos = minExpand(inputPos, patternPos, ep);
          break;
        default:
          return match(inputPos + 1, ep, true);
      }
    }

    matchDepth++;
    return inputPos;
  }

  int endCapture(int inputPos, int patternPos) {
    int level = captureToClose();
    int res;
    captures[level].len = inputPos - captures[level].init;
    if ((res = match(inputPos, patternPos)) == 0) {
      captures[level].len = CAP_UNFINISHED;
    }

    return res;
  }

  int checkCapture(int l) {
    // 1 ascii is 49
    l -= 49;
    if (l < 0 || l >= level || captures[l].len == CAP_UNFINISHED) {
      throw Exception('invalid capture index %%${l + 1}');
    }

    return l;
  }

  int matchCapture(int inputPos, int l) {
    l = checkCapture(l);
    int len = captures[l].len;
    if (input.length - inputPos >= len &&
        input.substring(captures[l].init, captures[l].init + len) == input.substring(inputPos, inputPos + len)) {
      return inputPos + len;
    }
    else {
      return -1;
    }
  }

  int startCapture(int inputPos, int patternPos, int what) {
    int level = this.level;
    if (level >= MAX_CAPTURES) {
      throw Exception('too many captures');
    }

    if (level == captures.length) {
      captures.add(Capture(0, 0));
    }
    captures[level].init = inputPos;
    captures[level].len = what;
    this.level++;
    int res;
    if ((res = match(inputPos, patternPos)) == 0) {
      this.level--;
    }

    return res;
  }

}
