import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../controllers/auth_controller.dart';

/// Şifremi Unuttum akışı yardımcı sınıfı
/// E-posta → Güvenlik Sorusu → Yeni PIN akışını yönetir
class ForgotPasswordHelper {
  final AuthController authController;
  final BuildContext context;

  ForgotPasswordHelper({required this.authController, required this.context});

  /// Şifremi Unuttum akışını başlat
  void showForgotPasswordSheet() {
    _showEmailStepSheet();
  }

  /// Adım 1: E-posta girişi
  void _showEmailStepSheet() {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHandle(sheetContext),
                    Text(
                      context.l10n.forgotPassword,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(sheetContext).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.enterRegisteredEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          sheetContext,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildEmailField(sheetContext, emailController, () {
                      if (errorMessage != null) {
                        setSheetState(() => errorMessage = null);
                      }
                    }),
                    if (errorMessage != null)
                      _buildErrorBox(builderContext, errorMessage!),
                    const SizedBox(height: 24),
                    _buildContinueButton(
                      sheetContext,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final email = emailController.text.trim();
                        final user = await authController.getUserByEmail(email);

                        if (!context.mounted) return;

                        if (user == null) {
                          setSheetState(() {
                            errorMessage = context.l10n.userNotFoundWithEmail;
                          });
                          return;
                        }

                        if (user.securityQuestion == null ||
                            user.securityAnswer == null) {
                          setSheetState(() {
                            errorMessage =
                                context.l10n.noSecurityQuestionDefined;
                          });
                          return;
                        }

                        Navigator.pop(sheetContext);
                        if (context.mounted) {
                          _showSecurityQuestionSheet(
                            email,
                            user.securityQuestion!,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Adım 2: Güvenlik sorusu
  void _showSecurityQuestionSheet(String email, String securityQuestion) {
    final answerController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHandle(sheetContext),
                    Text(
                      context.l10n.securityQuestion,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(sheetContext).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuestionBox(sheetContext, securityQuestion),
                    const SizedBox(height: 24),
                    _buildAnswerField(sheetContext, answerController),
                    if (errorMessage != null)
                      _buildErrorBox(builderContext, errorMessage!),
                    const SizedBox(height: 24),
                    _buildVerifyButton(
                      sheetContext,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final answer = answerController.text;
                        final user = await authController.getUserByEmail(email);

                        if (!context.mounted) return;

                        if (user == null) {
                          setSheetState(
                            () => errorMessage = context.l10n.userNotFound,
                          );
                          return;
                        }

                        final normalizedAnswer = answer.trim().toLowerCase();
                        if (user.securityAnswer != normalizedAnswer) {
                          setSheetState(() {
                            errorMessage = context.l10n.wrongAnswerTryAgain;
                          });
                          return;
                        }

                        Navigator.pop(sheetContext);
                        if (context.mounted) {
                          _showNewPinSheet(email);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Adım 3: Yeni PIN belirleme
  void _showNewPinSheet(String email) {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isPinVisible = false;
    String? errorMessage;
    String? successMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHandle(builderContext),
                    Text(
                      context.l10n.setNewPin,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(builderContext).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.enterNewPinDigits,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          builderContext,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildPinField(
                      builderContext,
                      pinController,
                      isPinVisible,
                      context.l10n.newPinLabel,
                      Icons.lock_outline,
                      onVisibilityToggle: () {
                        setSheetState(() => isPinVisible = !isPinVisible);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildConfirmPinField(
                      builderContext,
                      confirmPinController,
                      pinController,
                      isPinVisible,
                    ),
                    if (errorMessage != null || successMessage != null)
                      _buildMessageBox(
                        builderContext,
                        successMessage,
                        errorMessage,
                      ),
                    const SizedBox(height: 24),
                    _buildUpdatePinButton(
                      builderContext,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final newPin = pinController.text;
                        final user = await authController.getUserByEmail(email);

                        if (user != null) {
                          await authController.updateUserPin(user.id, newPin);

                          setSheetState(() {
                            successMessage = context.l10n.pinUpdatedSuccess;
                            errorMessage = null;
                          });

                          await Future.delayed(
                            const Duration(milliseconds: 1500),
                          );
                          if (!context.mounted) return;
                          Navigator.pop(sheetContext);
                        } else {
                          setSheetState(
                            () => errorMessage = context.l10n.userNotFound,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // === Yardımcı Widget Builder'lar ===

  Widget _buildHandle(BuildContext ctx) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildEmailField(
    BuildContext ctx,
    TextEditingController controller,
    VoidCallback onChanged,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
      onChanged: (_) => onChanged(),
      decoration: _inputDecoration(
        ctx,
        context.l10n.emailLabel,
        Icons.email_outlined,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return context.l10n.pleaseEnterEmail;
        }
        if (!value.contains('@')) {
          return context.l10n.enterValidEmail;
        }
        return null;
      },
    );
  }

  Widget _buildAnswerField(BuildContext ctx, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
      decoration: _inputDecoration(
        ctx,
        context.l10n.yourAnswer,
        Icons.question_answer_outlined,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return context.l10n.pleaseEnterAnswer;
        }
        return null;
      },
    );
  }

  Widget _buildPinField(
    BuildContext ctx,
    TextEditingController controller,
    bool isVisible,
    String label,
    IconData icon, {
    VoidCallback? onVisibilityToggle,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      obscureText: !isVisible,
      maxLength: 6,
      style: TextStyle(
        color: Theme.of(ctx).colorScheme.onSurface,
        letterSpacing: 4,
      ),
      decoration: _inputDecoration(ctx, label, icon).copyWith(
        counterText: "",
        suffixIcon: onVisibilityToggle != null
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(
                    ctx,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.l10n.pleaseEnterNewPin;
        }
        if (value.length < 4) {
          return context.l10n.pinMinDigits;
        }
        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
          return context.l10n.pinOnlyNumbers;
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPinField(
    BuildContext ctx,
    TextEditingController controller,
    TextEditingController pinController,
    bool isVisible,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      obscureText: !isVisible,
      maxLength: 6,
      style: TextStyle(
        color: Theme.of(ctx).colorScheme.onSurface,
        letterSpacing: 4,
      ),
      decoration: _inputDecoration(
        ctx,
        context.l10n.pinRepeatLabel,
        Icons.lock_reset,
      ).copyWith(counterText: ""),
      validator: (value) {
        if (value == null || value.isEmpty) return context.l10n.pleaseRepeatPin;
        if (value != pinController.text) return context.l10n.pinsDoNotMatch;
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(
    BuildContext ctx,
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      prefixIcon: Icon(icon, color: Theme.of(ctx).colorScheme.secondary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(
          color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.24),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: Theme.of(ctx).colorScheme.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: Theme.of(ctx).colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: Theme.of(ctx).colorScheme.error),
      ),
    );
  }

  Widget _buildQuestionBox(BuildContext ctx, String question) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline, color: Theme.of(ctx).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              question,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(ctx).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBox(BuildContext ctx, String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(ctx).colorScheme.error.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(ctx).colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBox(BuildContext ctx, String? success, String? error) {
    final isSuccess = success != null;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSuccess
              ? Colors.green.withValues(alpha: 0.1)
              : Theme.of(ctx).colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSuccess
                ? Colors.green.withValues(alpha: 0.3)
                : Theme.of(ctx).colorScheme.error.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: isSuccess ? Colors.green : Theme.of(ctx).colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                success ?? error!,
                style: TextStyle(
                  color: isSuccess
                      ? Colors.green
                      : Theme.of(ctx).colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(
    BuildContext ctx, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(ctx).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          context.l10n.continueButton,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton(
    BuildContext ctx, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(ctx).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          context.l10n.verifyButton,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildUpdatePinButton(
    BuildContext ctx, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(ctx).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          context.l10n.updatePinButton,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
