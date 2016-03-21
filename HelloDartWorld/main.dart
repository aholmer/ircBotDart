library HelloDartWorld.irc;

import 'dart:io' show Socket;
import 'dart:convert' show UTF8, LineSplitter;

import 'sentence_generator.dart' show SentenceGenerator;

part 'irc.dart';

void main(arguments) { 
  var generator = new SentenceGenerator();
  arguments.forEach(generator.addBook);
  runIrcBot(generator);
}
