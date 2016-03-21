part of HelloDartWorld.irc;

void runIrcBot(SentenceGenerator generator) {
  Socket.connect("chat.freenode.net", 6667)
        .then((socket) => handleIrcSocket(socket, generator));
  print("Callback has been registrered, but hasn't been called yet");
}


void handleIrcSocket(Socket socket, SentenceGenerator sentenceGenerator) {
  var nick = "Trump3";
  
  void authenticate() {
    socket.write('NICK $nick\r\n');
    socket.write('USER username 7 * :$nick\r\n');
  }

  void writeln(String line) {
    socket.write('$line\r\n');
  }
  
  void say(String message) {
    if (message.length > 120) {
      message = message.substring(0,120);
    }
    writeln('PRIVMSG ##dart-irc-codelab :$message');
  }
  
  final RegExp ircMessageRegExp =
    new RegExp(r":([^!]+)!([^ ]+) PRIVMSG ([^ ]+) :(.*)");
  
  void handleMessage(String msgNick,
                     String server,
                     String channel,
                     String msg) {
    if (msg.startsWith("$nick:")) {
      // Message to us :-)
      var text = msg.substring(msg.indexOf(":") + 1).trim();
      
      switch (text) {
        case "please leave2":
          print("leaving by request of $msgNick");
          writeln("QUIT");
          return;
        case "talk to me":
          say(sentenceGenerator.generateRandomSentence());
          return;
        default:
          if (text.startsWith("finish: ")) {
            var start = text.substring("finish: ".length);
            var sentence = sentenceGenerator
                  .generateSentences(startingWith: start)
                  .take(10000)
                  .where((sentence) => sentence != null)
                  .firstWhere((sentence) => sentence.length < 120,
                                orElse: () => null);
            say(sentence == null ? "Unable to comply." : sentence);
            return;
          }
      }
    }
    
    print("$msgNick: $msg");
  }
  
  void handleServerLine(String line) {
    if(line.startsWith("PING")) {
      writeln("PONG ${line.substring("PING ".length)}");
    }
    
    var match = ircMessageRegExp.firstMatch(line);
    if (match != null) {
      handleMessage(match[1], match[2], match[3], match[4]);
      return;
    }
    
    print("From server: $line");
  }
  
  socket.transform(UTF8.decoder)
        .transform(new LineSplitter())
        .listen(handleServerLine,
                onDone: socket.close);
  
  authenticate();
  
  writeln('JOIN ##dart-irc-codelab');
  //writeln('PRIVMSG ##dart-irc-codelab :Hello America');
  //writeln('PRIVMSG ##dart-irc-codelab :Let\'s make America great again!');
  
  print("Call finished");
}