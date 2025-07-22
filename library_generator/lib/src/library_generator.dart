import "package:analyzer/dart/element/element.dart";
import "package:build/build.dart";
import "package:glob/glob.dart";
import "package:library_generator_annotation/library_generator_annotation.dart";
import "package:source_gen/source_gen.dart";

Builder libraryGenerator(BuilderOptions options) =>
    LibraryBuilder(LibraryGenerator(), generatedExtension: ".lib.dart");

class LibraryGenerator extends GeneratorForAnnotation<Lib> {
  @override
  dynamic generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    // Get the current file's AssetId.
    final currentId = buildStep.inputId;

    // Compute the directory where the file is located.
    final directory = currentId.path.replaceFirst(RegExp(r"[^/]+$"), "");

    // Find all Dart files in the directory.
    final assets =
        await buildStep.findAssets(Glob("$directory*.dart")).toList();

    final exports = <String>[];
    for (final asset in assets) {
      // Exclude the library file itself and any generated files.
      if (asset.path == currentId.path || asset.path.endsWith(".g.dart")) {
        continue;
      }
      // Here we just use the file name (you may adjust the path if needed).
      final relativePath = asset.uri.pathSegments.last;
      exports.add('export "$relativePath";');
    }

    // Join the export statements with newlines.
    final list = exports.join("\n");

    return """
    library;

    $list
    """;
  }
}
