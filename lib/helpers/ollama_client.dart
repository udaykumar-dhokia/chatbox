import 'package:ollama_dart/ollama_dart.dart';

class OllamaClient {
  final OllamaClient client = OllamaClient();

  Future<Model> listModels() async {
    return await client.listModels();
  }

  Stream<GenerateCompletionResponse> generateCompletionStream({
    required GenerateCompletionRequest request,
  }) {
    return client.generateCompletionStream(request: request);
  }
}
