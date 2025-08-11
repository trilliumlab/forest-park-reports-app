// Openapi Generator last run: : 2025-08-06T11:35:36.056287
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  additionalProperties:
      DioProperties(pubName: 'traileyes_api', pubDescription: 'Trail Eyes API'),
  inputSpec: RemoteSpec(path: 'https://api.nightly.traileyes.net/openapi.json'),
  generatorName: Generator.dio,
  runSourceGenOnOutput: true,
  outputDirectory: 'api/traileyes_api',
)
class TrailEyesApi {}