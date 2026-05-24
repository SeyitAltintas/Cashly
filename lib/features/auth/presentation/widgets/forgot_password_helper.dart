import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../controllers/auth_controller.dart';

/// Şifremi Unuttum akışı yardımcı sınıfı
/// E-posta → Email Link → Yeni PIN akışını yönetir
class ForgotPasswordHelper {
  final AuthController authController;
  final BuildContext context;

  ForgotPasswordHelper({required this.authController, required this.context});

  /// Şifremi Unuttum akışını başlat (E-posta sorma aşaması)
  void showForgotPasswordSheet() {
    _showEmailStepSheet();
  }

  /// Adım 1: E-posta girişi ve Magic Link Gönderimi
  void _showEmailStepSheet() {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? errorMessage;
    String? successMessage;
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
                      "Kayıtlı e-posta adresinize bir şifre sıfırlama bağlantısı göndereceğiz.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          sheetContext,
                        ).colorScheme.onSurface.withAlpha(180),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildEmailField(sheetContext, emailController, () {
                      if (errorMessage != null || successMessage != null) {
                        setSheetState(() {
                          errorMessage = null;
                          successMessage = null;
                        });
                      }
                    }),
                    if (errorMessage != null || successMessage != null)
                      _buildMessageBox(
                          builderContext, successMessage, errorMessage),
                    const SizedBox(height: 24),
                    isSending 
                      ? const Center(child: CircularProgressIndicator()) 
                      : _buildContinueButton(
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

                        setSheetState(() => isSending = true);
                        
                        final sent = await authController.sendPinResetEmailLink(email);
                        
                        if (!context.mounted) return;

                        setSheetState(() {
                          isSending = false;
                          if (sent) {
                            successMessage = "Bağlantı e-posta adresinize gönderildi. Lütfen e-postanızı kontrol edin.";
                            errorMessage = null;
                          } else {
                            errorMessage = authController.error ?? "Bağlantı gönderilemedi.";
                            successMessage = null;
                          }
                        });
                        
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

  /// Adım 2: Magic Link ile App açıldıktan sonra Yeni PIN belirleme ekranı
  /// Bu metod AppLinks listener tarafından tetiklenir
  static void showSetNewPinSheet(BuildContext context, AuthController authController, String email, String emailLink) {
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
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return PopScope(
          canPop: false,
          child: StatefulBuilder(
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
                      _buildStaticHandle(builderContext),
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
                         "Doğrulama başarılı! Lütfen 6 haneli yeni PIN kodunuzu oluşturun.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            builderContext,
                          ).colorScheme.onSurface.withAlpha(180),
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
                        context,
                      ),
                      if (errorMessage != null || successMessage != null)
                        _buildMessageBoxInstance(
                          builderContext,
                          successMessage,
                          errorMessage,
                        ),
                      const SizedBox(height: 24),
                      isSaving 
                        ? const Center(child: CircularProgressIndicator()) 
                        : _buildUpdatePinButton(
                        builderContext,
                        context,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
  
                          final newPin = pinController.text;
                          
                          setSheetState(() => isSaving = true);
  
                          final success = await authController.verifyEmailLinkAndSetPin(email, emailLink, newPin);
                          
                          if (!context.mounted) return;
                          
                          setSheetState(() => isSaving = false);
  
                          if (success) {
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
                              () => errorMessage = authController.error ?? "Güncelleme başarısız oldu.",
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
          ),
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
          color: Theme.of(ctx).colorScheme.onSurface.withAlpha(70),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
  
  static Widget _buildStaticHandle(BuildContext ctx) {
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
        if (!value.contains('@')) {
          return context.l10n.enterValidEmail;
        }
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
        labelStyle: TextStyle(
          color: Theme.of(ctx).colorScheme.onSurface.withAlpha(180),
        ),
        prefixIcon: Icon(icon, color: Theme.of(ctx).colorScheme.secondary),
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
        if (value == null || value.isEmpty) {
          return ctx.l10n.pleaseEnterNewPin;
        }
        if (value.length < 6) {
          return "PIN en az 6 haneli olmalıdır";
        }
        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
          return ctx.l10n.pinOnlyNumbers;
        }
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
      style: TextStyle(
        color: Theme.of(ctx).colorScheme.onSurface,
        letterSpacing: 4,
      ),
      decoration: InputDecoration(
        labelText: l10nCtx.l10n.pinRepeatLabel,
        labelStyle: TextStyle(
          color: Theme.of(ctx).colorScheme.onSurface.withAlpha(180),
        ),
        prefixIcon: Icon(Icons.lock_reset, color: Theme.of(ctx).colorScheme.secondary),
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
        counterText: "",
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return l10nCtx.l10n.pleaseRepeatPin;
        if (value != pinController.text) return l10nCtx.l10n.pinsDoNotMatch;
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
      prefixIcon: Icon(icon, color: Theme.of(ctx).colorScheme.secondary),
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
    return _buildMessageBoxInstance(ctx, success, error);
  }
  
  static Widget _buildMessageBoxInstance(BuildContext ctx, String? success, String? error) {
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

  static Widget _buildUpdatePinButton(
    BuildContext ctx,
    BuildContext originalCtx, {
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
          originalCtx.l10n.updatePinButton,
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
