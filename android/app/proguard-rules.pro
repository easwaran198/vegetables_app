# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# JSON
-keep class * implements com.google.gson.TypeAdapter { *; }
-keep class * extends com.google.gson.TypeAdapter { *; }

# Platform channels
-keep class io.flutter.plugin.editing.** { *; }

# Reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes EnclosingMethod

# Preserve native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all classes that might be accessed via reflection
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.view.View

# Add any specific rules from your missing_rules.txt file here