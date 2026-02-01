# Keep rules for Agora Chat SDK - Chinese push services (optional dependencies)
# These are referenced but not used in this project
-dontwarn com.heytap.msp.push.**
-dontwarn com.meizu.cloud.pushsdk.**
-dontwarn com.vivo.push.**
-dontwarn com.xiaomi.mipush.sdk.**

# Google Play Core (optional dependency for deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Keep Agora Chat classes
-keep class com.hyphenate.** { *; }
-dontwarn com.hyphenate.**

# Keep Socket.IO classes
-keep class io.socket.** { *; }
-dontwarn io.socket.**

# Keep OkHttp classes
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**

# Keep Gson classes for JSON parsing
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep data model classes (update with your actual package name)
-keep class com.docmobi.app.models.** { *; }

# Keep Flutter wrapper classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
