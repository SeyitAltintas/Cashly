import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../controllers/auth_controller.dart';
import 'package:cashly/core/constants/color_constants.dart';

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
                      "Kayıtlı e-posta adresinize şifrenizi sıfırlayabileceğiniz bir bağlantı göndereceğiz.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          sheetContext,
                        ).colorScheme.onSurface.withValues(alpha: 0.9),
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
                            label: "Bağlantı Gönder",
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              final email = emailController.text.trim();

                              setSheetState(() => isSending = true);

                              final user = await authController.getUserByEmail(
                                email,
                              );
                              if (!context.mounted) return;

                              if (user == null) {
                                setSheetState(() {
                                  isSending = false;
                                  errorMessage =
                                      context.l10n.userNotFoundWithEmail;
                                });
                                return;
                              }

                              try {
                                await authController.sendPinResetOtp(email);
                              } catch (e) {
                                if (context.mounted) {
                                  setSheetState(() {
                                    isSending = false;
                                    errorMessage = e.toString().replaceAll(
                                      'Exception: ',
                                      '',
                                    );
                                  });
                                }
                                return;
                              }

                              if (!context.mounted) return;

                              setSheetState(() => isSending = false);

                              // Başarılı olduğunda kullanıcıyı bilgilendir ve kapat
                              Navigator.of(sheetContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "E-postanıza şifre sıfırlama bağlantısı gönderdik. "
                                    "Lütfen linke tıklayarak web sayfasında yeni şifrenizi belirleyin ve ardından uygulamaya giriş yapın.",
                                  ),
                                  duration: Duration(seconds: 8),
                                  backgroundColor: ColorConstants.yesil,
                                ),
                              );
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
      decoration: _inputDecoration(
        ctx,
        context.l10n.emailLabel,
        Icons.email_outlined,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return context.l10n.pleaseEnterEmail;
        }
        final emailRegex = RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}');
        if (!emailRegex.hasMatch(value.trim())) {
          return context.l10n.enterValidEmail;
        }
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
        color: Theme.of(ctx).colorScheme.onSurface.withAlpha(180),
      ),
      prefixIcon: Icon(icon, color: Theme.of(ctx).colorScheme.primary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(
          color: Theme.of(ctx).colorScheme.onSurface.withAlpha(60),
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

  Widget _buildMessageBox(BuildContext ctx, String? success, String? error) {
    final isSuccess = success != null;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSuccess
              ? ColorConstants.yesil.withAlpha(30)
              : Theme.of(ctx).colorScheme.error.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSuccess
                ? ColorConstants.yesil.withAlpha(80)
                : Theme.of(ctx).colorScheme.error.withAlpha(80),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: isSuccess
                  ? ColorConstants.yesil
                  : Theme.of(ctx).colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                success ?? error!,
                style: TextStyle(
                  color: isSuccess
                      ? ColorConstants.yesil
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: enabled
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.38),
          ),
        ),
      ),
    );
  }
}
