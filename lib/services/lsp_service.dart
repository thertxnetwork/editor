import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/lsp_models.dart';

/// Service for Language Server Protocol integration
class LspService {
  Process? _process;
  StreamSubscription? _stdoutSubscription;
  StreamSubscription? _stderrSubscription;
  
  final _diagnosticsController = StreamController<List<LspDiagnostic>>.broadcast();
  final _completionController = StreamController<List<CompletionItem>>.broadcast();
  final _hoverController = StreamController<HoverInfo?>.broadcast();
  
  Stream<List<LspDiagnostic>> get diagnostics => _diagnosticsController.stream;
  Stream<List<CompletionItem>> get completions => _completionController.stream;
  Stream<HoverInfo?> get hover => _hoverController.stream;

  bool _isInitialized = false;
  int _messageId = 0;
  final Map<int, Completer<dynamic>> _pendingRequests = {};
  final StringBuffer _messageBuffer = StringBuffer();

  bool get isInitialized => _isInitialized;

  /// Initialize LSP for a specific language
  Future<bool> initialize(String language, String workspacePath) async {
    final serverCommand = _getServerCommand(language);
    if (serverCommand == null) return false;

    try {
      _process = await Process.start(
        serverCommand.executable,
        serverCommand.arguments,
        workingDirectory: workspacePath,
      );

      _stdoutSubscription = _process!.stdout
          .transform(utf8.decoder)
          .listen(_handleOutput);
      
      _stderrSubscription = _process!.stderr
          .transform(utf8.decoder)
          .listen((data) => debugPrint('LSP stderr: $data'));

      // Send initialize request
      await _sendInitialize(workspacePath);
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Failed to start LSP server: $e');
      return false;
    }
  }

  /// Get the server command for a language
  _ServerCommand? _getServerCommand(String language) {
    switch (language) {
      case 'dart':
        return _ServerCommand('dart', ['language-server']);
      case 'typescript':
      case 'javascript':
        return _ServerCommand('typescript-language-server', ['--stdio']);
      case 'python':
        return _ServerCommand('pylsp', []);
      case 'rust':
        return _ServerCommand('rust-analyzer', []);
      case 'go':
        return _ServerCommand('gopls', ['serve']);
      case 'java':
        return _ServerCommand('jdtls', []);
      case 'kotlin':
        return _ServerCommand('kotlin-language-server', []);
      default:
        return null;
    }
  }

  /// Send initialize request to LSP server
  Future<void> _sendInitialize(String workspacePath) async {
    await _sendRequest('initialize', {
      'processId': pid,
      'rootUri': Uri.file(workspacePath).toString(),
      'capabilities': {
        'textDocument': {
          'completion': {
            'completionItem': {
              'snippetSupport': true,
              'documentationFormat': ['markdown', 'plaintext'],
            },
          },
          'hover': {
            'contentFormat': ['markdown', 'plaintext'],
          },
          'publishDiagnostics': {
            'relatedInformation': true,
          },
        },
      },
    });

    // Send initialized notification
    _sendNotification('initialized', {});
  }

  /// Send a request to the LSP server
  Future<dynamic> _sendRequest(String method, Map<String, dynamic> params) {
    final id = _messageId++;
    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;

    _sendMessage({
      'jsonrpc': '2.0',
      'id': id,
      'method': method,
      'params': params,
    });

    return completer.future;
  }

  /// Send a notification to the LSP server
  void _sendNotification(String method, Map<String, dynamic> params) {
    _sendMessage({
      'jsonrpc': '2.0',
      'method': method,
      'params': params,
    });
  }

  /// Send a message to the LSP server
  void _sendMessage(Map<String, dynamic> message) {
    final content = jsonEncode(message);
    final header = 'Content-Length: ${content.length}\r\n\r\n';
    _process?.stdin.write('$header$content');
  }

  /// Handle output from the LSP server
  void _handleOutput(String data) {
    _messageBuffer.write(data);
    _processBuffer();
  }

  /// Process the message buffer
  void _processBuffer() {
    final content = _messageBuffer.toString();
    
    // Look for complete messages
    final headerEnd = content.indexOf('\r\n\r\n');
    if (headerEnd == -1) return;

    final header = content.substring(0, headerEnd);
    final lengthMatch = RegExp(r'Content-Length: (\d+)').firstMatch(header);
    if (lengthMatch == null) return;

    final length = int.parse(lengthMatch.group(1)!);
    final messageStart = headerEnd + 4;
    
    if (content.length < messageStart + length) return;

    final messageContent = content.substring(messageStart, messageStart + length);
    _messageBuffer.clear();
    _messageBuffer.write(content.substring(messageStart + length));

    try {
      final message = jsonDecode(messageContent) as Map<String, dynamic>;
      _handleMessage(message);
    } catch (e) {
      debugPrint('Failed to parse LSP message: $e');
    }

    // Process any remaining messages
    _processBuffer();
  }

  /// Handle a parsed LSP message
  void _handleMessage(Map<String, dynamic> message) {
    if (message.containsKey('id')) {
      // This is a response
      final id = message['id'] as int;
      final completer = _pendingRequests.remove(id);
      if (completer != null) {
        if (message.containsKey('error')) {
          completer.completeError(message['error']);
        } else {
          completer.complete(message['result']);
        }
      }
    } else if (message.containsKey('method')) {
      // This is a notification
      _handleNotification(message['method'], message['params'] ?? {});
    }
  }

  /// Handle LSP notifications
  void _handleNotification(String method, Map<String, dynamic> params) {
    switch (method) {
      case 'textDocument/publishDiagnostics':
        _handleDiagnostics(params);
        break;
    }
  }

  /// Handle diagnostics notification
  void _handleDiagnostics(Map<String, dynamic> params) {
    final diagnostics = (params['diagnostics'] as List?)
        ?.map((d) => LspDiagnostic(
              message: d['message'],
              severity: DiagnosticSeverity.values[d['severity'] - 1],
              startLine: d['range']['start']['line'],
              startColumn: d['range']['start']['character'],
              endLine: d['range']['end']['line'],
              endColumn: d['range']['end']['character'],
              source: d['source'],
              code: d['code']?.toString(),
            ))
        .toList() ?? [];

    _diagnosticsController.add(diagnostics);
  }

  /// Open a document
  void didOpen(String uri, String language, String content) {
    _sendNotification('textDocument/didOpen', {
      'textDocument': {
        'uri': uri,
        'languageId': language,
        'version': 1,
        'text': content,
      },
    });
  }

  /// Update a document
  void didChange(String uri, String content, int version) {
    _sendNotification('textDocument/didChange', {
      'textDocument': {
        'uri': uri,
        'version': version,
      },
      'contentChanges': [
        {'text': content},
      ],
    });
  }

  /// Close a document
  void didClose(String uri) {
    _sendNotification('textDocument/didClose', {
      'textDocument': {'uri': uri},
    });
  }

  /// Request completion at position
  Future<List<CompletionItem>> getCompletion(
    String uri,
    int line,
    int character,
  ) async {
    if (!_isInitialized) return [];

    try {
      final result = await _sendRequest('textDocument/completion', {
        'textDocument': {'uri': uri},
        'position': {'line': line, 'character': character},
      });

      final items = result is List ? result : (result['items'] ?? []);
      return items
          .map<CompletionItem>((item) => CompletionItem(
                label: item['label'],
                kind: CompletionItemKind.values[
                    (item['kind'] ?? 1) - 1],
                detail: item['detail'],
                documentation: item['documentation'] is String
                    ? item['documentation']
                    : item['documentation']?['value'],
                insertText: item['insertText'] ?? item['label'],
              ))
          .toList();
    } catch (e) {
      debugPrint('Completion error: $e');
      return [];
    }
  }

  /// Request hover information
  Future<HoverInfo?> getHover(String uri, int line, int character) async {
    if (!_isInitialized) return null;

    try {
      final result = await _sendRequest('textDocument/hover', {
        'textDocument': {'uri': uri},
        'position': {'line': line, 'character': character},
      });

      if (result == null) return null;

      final contents = result['contents'];
      String text;
      if (contents is String) {
        text = contents;
      } else if (contents is Map) {
        text = contents['value'] ?? '';
      } else if (contents is List) {
        text = contents.map((c) => c is String ? c : c['value']).join('\n');
      } else {
        return null;
      }

      return HoverInfo(
        contents: text,
        startLine: result['range']?['start']?['line'],
        startColumn: result['range']?['start']?['character'],
        endLine: result['range']?['end']?['line'],
        endColumn: result['range']?['end']?['character'],
      );
    } catch (e) {
      debugPrint('Hover error: $e');
      return null;
    }
  }

  /// Request go to definition
  Future<LocationInfo?> getDefinition(
    String uri,
    int line,
    int character,
  ) async {
    if (!_isInitialized) return null;

    try {
      final result = await _sendRequest('textDocument/definition', {
        'textDocument': {'uri': uri},
        'position': {'line': line, 'character': character},
      });

      if (result == null || (result is List && result.isEmpty)) return null;

      final location = result is List ? result.first : result;
      return LocationInfo(
        uri: location['uri'],
        startLine: location['range']['start']['line'],
        startColumn: location['range']['start']['character'],
        endLine: location['range']['end']['line'],
        endColumn: location['range']['end']['character'],
      );
    } catch (e) {
      debugPrint('Definition error: $e');
      return null;
    }
  }

  /// Shutdown the LSP server
  Future<void> shutdown() async {
    if (!_isInitialized) return;

    try {
      await _sendRequest('shutdown', {});
      _sendNotification('exit', {});
    } catch (e) {
      debugPrint('Shutdown error: $e');
    }

    await dispose();
  }

  /// Dispose resources
  Future<void> dispose() async {
    _isInitialized = false;
    await _stdoutSubscription?.cancel();
    await _stderrSubscription?.cancel();
    _process?.kill();
    _process = null;
    await _diagnosticsController.close();
    await _completionController.close();
    await _hoverController.close();
  }
}

/// Helper class for server command
class _ServerCommand {
  final String executable;
  final List<String> arguments;

  _ServerCommand(this.executable, this.arguments);
}
