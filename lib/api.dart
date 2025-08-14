// Openapi Generator last run: : 2025-08-13T18:10:39.164052
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  additionalProperties:
      DioProperties(pubName: 'traileyes_api', pubDescription: 'Trail Eyes API'),
  inputSpec: RemoteSpec(path: 'https://api.nightly.traileyes.net/spec.json'),
  generatorName: Generator.dio,
  runSourceGenOnOutput: true,
  debugLogging: true,
  outputDirectory: 'api/traileyes_api',
  forceAlwaysRun: true,
)
class TrailEyesApi {}