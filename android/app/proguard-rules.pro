# ── Flutter & Dart ──────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# ── Kotlin ──────────────────────────────────────────────────────────────────
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# ── Accessibility service — must survive shrinking ──────────────────────────
-keep class com.example.hush.HushAccessibilityService { *; }
-keep class com.example.hush.BlockerState { *; }

# ── HTTP (OkHttp / http package under the hood) ─────────────────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ── JSON (if using Gson or kotlinx.serialization) ───────────────────────────
-keepattributes Signature
-keepattributes *Annotation*