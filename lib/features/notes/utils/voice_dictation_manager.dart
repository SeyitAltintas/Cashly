import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:cashly/core/services/speech/speech_service.dart';

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
  Timer? _voiceSilenceTimer;

  VoiceDictationManager({
    required this.context,
    required this.controller,
    required this.onStateChanged,
    required this.onUnsavedChanges,
  });

  void dispose() {
    _voiceSilenceTimer?.cancel();
    _speechService.dispose();
  }

  Future<void> startVoiceDictation() async {
    isDictationBoxOpen = true;
    isListening = true;
    lastRecognizedWords = '';
    interimText = '';
    onStateChanged();

    final success = await _speechService.initialize();
    if (!success) {
      isListening = false;
      onStateChanged();
      return;
    }

    await resumeListeningSession();
  }

  Future<void> resumeListeningSession() async {
    isListening = true;
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
        if (status.startsWith('error:')) {
           final errorMsg = status.substring(6);
           if (isDictationBoxOpen && (errorMsg == 'error_speech_timeout' || errorMsg == 'error_no_match')) {
             resumeListeningSession();
           } else {
             isListening = false;
             onStateChanged();
           }
        } else if (status == 'done' || status == 'notListening') {
          isListening = false;
          onStateChanged();
        }
      },
    );
  }

  void applyInterimText(String newText) {
    if (newText.trim().isEmpty) return;
    
    interimText = newText;
    onStateChanged();
    
    resetVoiceSilenceTimer();
  }

  void resetVoiceSilenceTimer() {
    _voiceSilenceTimer?.cancel();
    _voiceSilenceTimer = Timer(const Duration(seconds: 2), () {
      if (interimText.isNotEmpty) {
        commitInterimText();
      }
    });
  }

  void commitInterimText({bool addSeparator = true}) {
    if (interimText.trim().isEmpty) return;

    final index = controller.selection.baseOffset;
    final textToInsert = (addSeparator && index > 0) ? ' $interimText' : interimText;

    controller.document.insert(index, textToInsert);
    controller.updateSelection(
      TextSelection.collapsed(offset: index + textToInsert.length),
      ChangeSource.local,
    );

    lastRecognizedWords = textToInsert.trim();
    interimText = '';
    onStateChanged();
    onUnsavedChanges();
  }

  Future<void> toggleListening() async {
    if (isListening) {
      await _speechService.stopListening();
      isListening = false;
      onStateChanged();
    } else {
      if (interimText.isNotEmpty) {
        commitInterimText();
      }
      await resumeListeningSession();
    }
  }

  Future<void> stopVoiceDictation() async {
    _voiceSilenceTimer?.cancel();
    if (interimText.isNotEmpty) {
      commitInterimText(addSeparator: true);
    }
    await _speechService.stopListening();
    isDictationBoxOpen = false;
    isListening = false;
    onStateChanged();
  }
}
