library HelloDartWorld.irc.sentence_generator;

import 'dart:io' show File;
import 'dart:math' show Random;


class SentenceGenerator {
  final _db = new Map<String, Set<String>>();
  final rng = new Random();
  
  int get keyCount => _db.length;
  
  String pickRandomPair() => _db.keys.elementAt(rng.nextInt(keyCount));
  
  String pickRandomThirdWord(String firstWord, String secondWord) {
    var key = "$firstWord $secondWord";
    var possibleSequences = _db[key];
    return possibleSequences.elementAt(rng.nextInt(possibleSequences.length));
  }
  
  void addBook(String fileName) {
    var content = new File(fileName).readAsStringSync();
    
    if (!content.endsWith(".")) {
      content += ".";
    }
    
    var words = content
        .replaceAll("\n", " ")
        .replaceAll("\r", "") 
        .replaceAll(".", " .") 
        .split(" ")
        .where((String word) => word != "");
    
    var preprevious = null;
    var previous = null;
    for (String current in words) {
      if (previous != null) {
        _db.putIfAbsent("$preprevious $previous", () => new Set())
           .add(current);
      }
      
      preprevious = previous;
      previous = current;
    }
  }
  
  String generateRandomSentence() {
    var start = pickRandomPair();
    var startingWords = start.split(" ");
    return generateSentenceStartingWith(startingWords[0], startingWords[1]);
  }
  
  String generateSentenceStartingWith(String preprevious, String previous) {
    var sentence = [preprevious, previous];
    var current;
    do {
      current = pickRandomThirdWord(preprevious, previous);
      sentence.add(current);
      preprevious = previous;
      previous = current;
    } while (current != ".");
    return sentence.join(" ");
  }
  
  String finishSentence(String start) {
    List words = start.split(" ");
    Iterable reversedRemaining = words.reversed;
    
    while (reversedRemaining.length >= 2) {
      String secondToLast = reversedRemaining.elementAt(1);
      String last = reversedRemaining.first;
      String leadPair = "$secondToLast $last";
      if (_db.containsKey(leadPair)) {
        String beginning = reversedRemaining
            .skip(2)
            .toList()
            .reversed
            .join(" ");
        String end = generateSentenceStartingWith(secondToLast, last);
        return "$beginning $end";
      }
      
      reversedRemaining = reversedRemaining.skip(1);
    }
    
    return null;
  }
  
  Iterable<String> generateSentences({String startingWith}) sync* {
    while (true) {
      if (startingWith == null) {
        yield generateRandomSentence();
      } else {
        yield finishSentence(startingWith);
      }
    }
  }
}