import 'dart:convert';
import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:process_run/src/bin/shell/env.dart';
import 'package:process_run/src/bin/shell/shell.dart';
import 'package:process_run/src/common/import.dart';

class ShellEnvVarSetCommand extends ShellEnvCommandBase {
  ShellEnvVarSetCommand()
      : super(
          name: 'set',
          description: 'Set environment variable',
        );

  @override
  void printUsage() {
    stdout.writeln('ds env var set <name> <command with space>');
    super.printUsage();
  }

  @override
  FutureOr<bool> onRun() async {
    var rest = results.rest;
    if (rest.length < 2) {
      stderr.writeln('At least 2 arguments expected');
      exit(1);
    } else {
      if (verbose) {
        stdout.writeln('before: ${jsonEncode(ShellEnvironment().vars)}');
      }
      var name = rest[0];
      var value = rest.sublist(1).join(' ');
      var fileContent = await envFileReadOrCreate();
      if (fileContent.addVar(name, value)) {
        await fileContent.write();
      }
      // Force reload
      shellEnvironment = null;
      if (verbose) {
        stdout.writeln('After: ${jsonEncode(ShellEnvironment().vars)}');
      }
      return true;
    }
  }
}

/// Direct shell env Var Set run helper for testing.
Future<void> main(List<String> arguments) async {
  await ShellEnvVarSetCommand().parseAndRun(arguments);
}
