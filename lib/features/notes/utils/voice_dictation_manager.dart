import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:cashly/core/services/speech/speech_service.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

class VoiceDictationManager {
  final BuildContext context;
  final QuillController controller;
  final VoidCallback onStateChanged;
  final VoidCallback onUnsavedChanges;

  final SpeechService _speechService = SpeechService();
  bool isDictationBoxOpen = false;
  bool isListening = false;
  String lastRecognizedWords = '';
  String interimText = '';
  int _interimOffset = -1;
  Timer? _voiceSilenceTimer;
  Timer? _voicePauseTimer;
  bool _isRestarting = false;

  VoiceDictationManager({
    required this.context,
    required this.controller,
    required this.onStateChanged,
    required this.onUnsavedChanges,
  });

  void dispose() {
    _voiceSilenceTimer?.cancel();
    _voicePauseTimer?.cancel();
    _speechService.dispose();
  }

  Future<void> startVoiceDictation() async {
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    controller.readOnly = true;
    isDictationBoxOpen = true;
    isListening = true;
    lastRecognizedWords = '';
    interimText = '';
    _interimOffset = -1;
    onStateChanged();

    final success = await _speechService.initialize();
    if (!success) {
      isDictationBoxOpen = false;
      isListening = false;
      controller.readOnly = false;
      onStateChanged();
      // ignore: use_build_context_synchronously
      if (context.mounted) AppSnackBar.error(context, context.l10n.micAccessDenied);
      return;
    }

    _isRestarting = false;
    resetVoiceSilenceTimer();
    await resumeListeningSession();
  }

  Future<void> resumeListeningSession() async {
    if (!isListening || _isRestarting) return;
    onStateChanged();

    await _speechService.startListening(
      onResult: (text, {required bool isFinal}) {
        if (!isListening) return;

        if (text.trim().isNotEmpty) {
          resetVoiceSilenceTimer();
        }

        if (isFinal) {
          if (text.isNotEmpty) applyInterimText(text);
          commitInterimText();
        } else {
          applyInterimText(text);
        }
      },
      onStatus: (status) {
        if (!isListening) return;

        if (status.startsWith('error')) {
          final errorMsg = status.split(':').length > 1
              ? status.split(':')[1]
              : '';

          if (errorMsg == 'error_no_match' ||
              errorMsg == 'error_speech_timeout' ||
              errorMsg == 'error_busy') {
            // Sessizlikten kaynaklı hata — motor done'a geçip restart döngüsü başlar.
            return;
          }

          // Kalıcı hata: dikteyi durdur ve kullanıcıya bilgi ver.
          stopVoiceDictation(closeBox: false);
          String userMsg = context.l10n.voiceRecognitionError;
          if (errorMsg == 'error_network') {
            userMsg = context.l10n.internetDisconnectedOrWeak;
          } else if (errorMsg == 'error_audio_error' ||
              errorMsg == 'error_client') {
            userMsg = context.l10n.micUnavailable;
          } else if (errorMsg == 'error_listen_failed') {
            userMsg = context.l10n.micInUseByOtherApp;
          }
          AppSnackBar.error(context, userMsg);
          return;
        } else if (status == 'done' || status == 'notListening') {
          commitInterimText();

          if (!_isRestarting && isListening && isDictationBoxOpen) {
            _isRestarting = true;
            Future.delayed(const Duration(milliseconds: 250), () async {
              _isRestarting = false;
              if (isListening && context.mounted) await resumeListeningSession();
            });
          }
        }
      },
    );
  }

  void applyInterimText(String newText) {
    newText = newText.trimLeft();
    if (newText.isEmpty) return;

    if (interimText.isNotEmpty && _interimOffset >= 0) {
      controller.replaceText(
        _interimOffset,
        interimText.length,
        '',
        TextSelection.collapsed(offset: _interimOffset),
      );
    }

    interimText = newText;
    final doc = controller.document;

    if (_interimOffset < 0) {
      final selection = controller.selection;
      if (selection.isValid) {
        if (!selection.isCollapsed) {
          final start = selection.start;
          final length = selection.end - selection.start;
          controller.replaceText(
            start,
            length,
            '',
            TextSelection.collapsed(offset: start),
          );
          _interimOffset = start.clamp(0, doc.length - 1);
        } else {
          _interimOffset = selection.baseOffset.clamp(0, doc.length - 1);
        }
      } else {
        _interimOffset = (doc.length - 1).clamp(0, doc.length - 1);
      }
    }

    controller.replaceText(
      _interimOffset,
      0,
      newText,
      TextSelection.collapsed(offset: _interimOffset + newText.length),
    );
    
    _voicePauseTimer?.cancel();
    _voicePauseTimer = Timer(const Duration(milliseconds: 1200), () {
      if (isListening && interimText.isNotEmpty) {
        commitInterimText();
      }
    });

    resetVoiceSilenceTimer();
  }

  void resetVoiceSilenceTimer() {
    _voiceSilenceTimer?.cancel();
    if (!isListening) return;

    _voiceSilenceTimer = Timer(const Duration(seconds: 6), () {
      if (isListening) {
        stopVoiceDictation();
      }
    });
  }

  void commitInterimText({bool addSeparator = true}) {
    if (addSeparator && interimText.isNotEmpty && _interimOffset >= 0) {
      if (!interimText.endsWith(' ')) {
        final spaceOffset = _interimOffset + interimText.length;
        final maxOffset = (controller.document.length - 1).clamp(
          0,
          controller.document.length - 1,
        );
        if (spaceOffset <= maxOffset) {
          controller.replaceText(
            spaceOffset,
            0,
            ' ',
            TextSelection.collapsed(offset: spaceOffset + 1),
          );
        }
      }
    }
    _voicePauseTimer?.cancel();
    interimText = '';
    _interimOffset = -1;
    onStateChanged();
    onUnsavedChanges();
  }

  Future<void> toggleListening() async {
    if (isListening) {
      await stopVoiceDictation(closeBox: false);
    } else {
      isListening = true;
      onStateChanged();
      await resumeListeningSession();
    }
  }

  Future<void> stopVoiceDictation({bool closeBox = true}) async {
    if (!isListening && !closeBox) return;
    
    isListening = false;
    _isRestarting = false;
    
    _voiceSilenceTimer?.cancel();
    _voicePauseTimer?.cancel();
    commitInterimText(addSeparator: false);
    await _speechService.stopListening();
    
    if (closeBox) {
      isDictationBoxOpen = false;
      controller.readOnly = false;
    }
    
    onStateChanged();
    onUnsavedChanges();
  }
}
