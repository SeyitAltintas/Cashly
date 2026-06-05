import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../controllers/auth_controller.dart';

/// Şifremi Unuttum akışı — OTP tabanlı (deep link gerektirmez)
/// Adım 1: E-posta gir → Adım 2: Kodu gir + Yeni PIN belirle
class ForgotPasswordHelper {
  final AuthController authController;
  final BuildContext context;

  ForgotPasswordHelper({required this.authController, required this.context});

  void showForgotPasswordSheet() {
    _showEmailStepSheet();
  }

  // ──────────────────────────────────────────────────────────
  // ADIM 1: E-posta girişi ve OTP gönderimi
  // ──────────────────────────────────────────────────────────
  void _showEmailStepSheet() {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? errorMessage;
    bool isSending = false;

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
                      "Kayıtlı e-posta adresinize 6 haneli bir doğrulama kodu göndereceğiz.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(sheetContext).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildEmailField(sheetContext, emailController, () {
                      if (errorMessage != null) {
                        setSheetState(() => errorMessage = null);
                      }
                    }),
                    if (errorMessage != null)
                      _buildMessageBox(builderContext, null, errorMessage),
                    const SizedBox(height: 24),
                    isSending
                        ? const Center(child: CircularProgressIndicator())
                        : _buildPrimaryButton(
                            sheetContext,
                            label: "Kod Gönder",
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              final email = emailController.text.trim();

                              setSheetState(() => isSending = true);

                              final user = await authController.getUserByEmail(email);
                              if (!context.mounted) return;

                              if (user == null) {
                                setSheetState(() {
                                  isSending = false;
                                  errorMessage = context.l10n.userNotFoundWithEmail;
                                });
                                return;
                              }

                              final sent = await authController.sendPinResetOtp(email);
                              if (!context.mounted) return;

                              setSheetState(() => isSending = false);

                              if (sent) {
                                // Adım 2'ye geç
                                Navigator.of(sheetContext).pop();
                                _showOtpAndPinStepSheet(email);
                              } else {
                                setSheetState(() {
                                  errorMessage = authController.error ?? "Kod gönderilemedi. Lütfen tekrar deneyin.";
                                });
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

  // ──────────────────────────────────────────────────────────
  // ADIM 2: OTP kodu + Yeni PIN belirleme
  // ──────────────────────────────────────────────────────────
  void _showOtpAndPinStepSheet(String email) {
    final otpController = TextEditingController();
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isPinVisible = false;
    String? errorMessage;
    String? successMessage;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return SingleChildScrollView(
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
                      "Kodu Doğrula",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(sheetContext).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(sheetContext).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        children: [
                          const TextSpan(text: "E-postanıza gönderilen 6 haneli kodu ve yeni PIN'inizi girin.\n\n"),
                          TextSpan(
                            text: email,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(sheetContext).colorScheme.primary,
                            ),
                          ),
                          const TextSpan(text: " adresine kod gönderildi."),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // OTP alanı
                    TextFormField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: TextStyle(
                        color: Theme.of(sheetContext).colorScheme.onSurface,
                        letterSpacing: 8,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: "Doğrulama Kodu",
                        labelStyle: TextStyle(
                          color: Theme.of(sheetContext).colorScheme.onSurface.withAlpha(180),
                        ),
                        prefixIcon: Icon(
                          Icons.verified_outlined,
                          color: Theme.of(sheetContext).colorScheme.primary,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(sheetContext).colorScheme.primary.withAlpha(80),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(sheetContext).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Theme.of(sheetContext).colorScheme.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Theme.of(sheetContext).colorScheme.error),
                        ),
                        counterText: "",
                        filled: true,
                        fillColor: Theme.of(sheetContext).colorScheme.primary.withAlpha(10),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Lütfen doğrulama kodunu girin";
                        if (value.length < 6) return "Kod 6 haneli olmalıdır";
                        if (!RegExp(r'^\d{6}$').hasMatch(value)) return "Kod sadece rakamlardan oluşmalıdır";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Yeni PIN alanı
                    _buildPinField(
                      sheetContext,
                      pinController,
                      isPinVisible,
                      context.l10n.newPinLabel,
                      Icons.lock_outline,
                      onVisibilityToggle: () {
                        setSheetState(() => isPinVisible = !isPinVisible);
                      },
                    ),
                    const SizedBox(height: 16),

                    // PIN tekrar
                    _buildConfirmPinField(
                      sheetContext,
                      confirmPinController,
                      pinController,
                      isPinVisible,
                      context,
                    ),

                    if (errorMessage != null || successMessage != null)
                      _buildMessageBox(builderContext, successMessage, errorMessage),
                    const SizedBox(height: 24),

                    // Yeniden gönder butonu
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text("Kodu tekrar gönder"),
                        onPressed: isSaving
                            ? null
                            : () async {
                                final sent = await authController.sendPinResetOtp(email);
                                if (!context.mounted) return;
                                setSheetState(() {
                                  if (sent) {
                                    successMessage = "Yeni kod gönderildi!";
                                    errorMessage = null;
                                  } else {
                                    errorMessage = authController.error ?? "Kod gönderilemedi.";
                                    successMessage = null;
                                  }
                                });
                              },
                      ),
                    ),
                    const SizedBox(height: 8),

                    isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : _buildPrimaryButton(
                            sheetContext,
                            label: context.l10n.updatePinButton,
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;

                              setSheetState(() => isSaving = true);

                              final success = await authController.verifyOtpAndSetPin(
                                email,
                                otpController.text.trim(),
                                pinController.text,
                              );

                              if (!context.mounted) return;
                              setSheetState(() => isSaving = false);

                              if (success) {
                                setSheetState(() {
                                  successMessage = context.l10n.pinUpdatedSuccess;
                                  errorMessage = null;
                                });
                                await Future.delayed(const Duration(milliseconds: 1500));
                                if (!context.mounted) return;
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              } else {
                                setSheetState(() {
                                  errorMessage = authController.error ?? "Güncelleme başarısız oldu.";
                                  successMessage = null;
                                });
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

  // ──────────────────────────────────────────────────────────
  // Widget Builder'lar
  // ──────────────────────────────────────────────────────────

  Widget _buildHandle(BuildContext ctx) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.onSurface.withAlpha(70),
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
      decoration: _inputDecoration(ctx, context.l10n.emailLabel, Icons.email_outlined),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return context.l10n.pleaseEnterEmail;
        final emailRegex = RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}');
        if (!emailRegex.hasMatch(value.trim())) return context.l10n.enterValidEmail;
        return null;
      },
    );
  }

  static Widget _buildPinField(
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
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(ctx).colorScheme.onSurface.withAlpha(180)),
        prefixIcon: Icon(icon, color: Theme.of(ctx).colorScheme.secondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Theme.of(ctx).colorScheme.onSurface.withAlpha(60)),
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
        counterText: "",
        suffixIcon: onVisibilityToggle != null
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(ctx).colorScheme.onSurface.withAlpha(180),
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return ctx.l10n.pleaseEnterNewPin;
        if (value.length < 6) return "PIN en az 6 haneli olmalıdır";
        if (!RegExp(r'^[0-9]+$').hasMatch(value)) return ctx.l10n.pinOnlyNumbers;
        return null;
      },
    );
  }

  static Widget _buildConfirmPinField(
    BuildContext ctx,
    TextEditingController controller,
    TextEditingController pinController,
    bool isVisible,
    BuildContext l10nCtx,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      obscureText: !isVisible,
      maxLength: 6,
      style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface, letterSpacing: 4),
      decoration: InputDecoration(
        labelText: l10nCtx.l10n.pinRepeatLabel,
        labelStyle: TextStyle(color: Theme.of(ctx).colorScheme.onSurface.withAlpha(180)),
        prefixIcon: Icon(Icons.lock_reset, color: Theme.of(ctx).colorScheme.secondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Theme.of(ctx).colorScheme.onSurface.withAlpha(60)),
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
        counterText: "",
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return l10nCtx.l10n.pleaseRepeatPin;
        if (value != pinController.text) return l10nCtx.l10n.pinsDoNotMatch;
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(BuildContext ctx, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Theme.of(ctx).colorScheme.onSurface.withAlpha(180)),
      prefixIcon: Icon(icon, color: Theme.of(ctx).colorScheme.secondary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: Theme.of(ctx).colorScheme.onSurface.withAlpha(60)),
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

  Widget _buildMessageBox(BuildContext ctx, String? success, String? error) {
    final isSuccess = success != null;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSuccess
              ? Colors.green.withAlpha(30)
              : Theme.of(ctx).colorScheme.error.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSuccess
                ? Colors.green.withAlpha(80)
                : Theme.of(ctx).colorScheme.error.withAlpha(80),
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
                  color: isSuccess ? Colors.green : Theme.of(ctx).colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext ctx, {
    required String label,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? Theme.of(ctx).colorScheme.primary
              : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: enabled ? Colors.white : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.38),
          ),
        ),
      ),
    );
  }
}
