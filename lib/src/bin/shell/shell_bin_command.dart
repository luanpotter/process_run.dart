import 'dart:io';

import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'package:process_run/src/bin/shell/shell.dart';
import 'package:process_run/src/common/import.dart';
import 'package:pub_semver/pub_semver.dart';

class ShellBinCommand {
  // Optional parent
  ShellBinCommand /*?*/ parent;
  String name;

  ArgParser get parser => _parser ??= ArgParser(allowTrailingOptions: false);
  FutureOr<bool> Function() _onRun;
  ArgParser _parser;
  ArgResults results;
  bool _verbose;

  // Set before run
  bool get verbose => _verbose ??= parent?.verbose;

  String _description;

  String get description => _description;
  Version _version;

  Version get version => _version ??= parent?.version;

  // name
  //   description
  void printNameDescription() {
    stdout.writeln('$name${parent != null ? '' : ' ${version.toString()}'}');
    if (description != null) {
      stdout.writeln('  $description');
    }
  }

  void printUsage() {
    printNameDescription();
    stdout.writeln();
    stdout.writeln(parser.usage);
    if (_commands.isNotEmpty) {
      stdout.writeln();
      printCommands();
    }
  }

  /// Prepend an em
  void printCommands() {
    _commands.forEach((name, value) {
      value.printNameDescription();
    });
    stdout.writeln();
  }

  void printBaseUsage() {
    printNameDescription();
    stdout.writeln();
    if (_commands.isNotEmpty) {
      stdout.writeln();
      printCommands();
    } else {
      stdout.writeln();
      stdout.writeln(parser.usage);
    }
  }

  ArgResults parse(List<String> arguments) {
    return results = parser.parse(arguments);
  }

  @nonVirtual
  FutureOr<bool> parseAndRun(List<String> arguments) {
    parse(arguments);
    return run();
  }

  final _commands = <String, ShellBinCommand>{};

  ShellBinCommand(
      {@required this.name,
      Version version,
      ArgParser parser,
      ShellBinCommand parent,
      @deprecated FutureOr<bool> Function() onRun,
      String description}) {
    _onRun = onRun;
    _parser = parser;
    _description = description;
    _version = version;
    // read or create
    parser = this.parser;
    parser.addFlag(flagHelp, abbr: 'h', help: 'Usage help', negatable: false);
    if (parent == null) {
      parser.addFlag(flagVersion,
          help: 'Print the command version', negatable: false);

      parser.addFlag(flagVerbose, help: 'Verbose mode', negatable: false);
    }
  }

  void addCommand(ShellBinCommand command) {
    parser.addCommand(command.name, command.parser);
    _commands[command.name] = command;
    command.parent = this;
  }

  /// To override
  ///
  /// return true if handled.
  @visibleForOverriding
  FutureOr<bool> onRun() {
    if (_onRun != null) {
      return _onRun();
    }
    return false;
  }

  /// Get a flag
  bool getFlag(String name) => results[name] as bool;

  @nonVirtual
  FutureOr<bool> run() async {
    // Handle verbose
    // Handle version first
    if (parent == null) {
      final hasVersion = getFlag(flagVersion);
      if (hasVersion) {
        stdout.writeln(version);
        return true;
      }
    }
    // Handle help
    final help = results[flagHelp] as bool;

    if (help) {
      printUsage();
      return true;
    }

    // Find the command if any
    var command = results.command;
    if (command != null) {
      var shellCommand = _commands[command.name];
      if (shellCommand != null) {
        // Set the result in the the shell command
        shellCommand.results = command;
        return shellCommand.run();
      }
    }
    var ran = await onRun();
    if (!ran) {
      stderr.writeln('No command ran');
      printBaseUsage();
      exit(1);
    }
    return ran;
  }

  @override
  String toString() => 'ShellCommand($name)';
}
