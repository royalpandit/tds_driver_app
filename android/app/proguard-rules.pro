# Keep Mappls SDK classes and Google Play services used by Mappls
-keep class com.mappls.** { *; }
-keepclassmembers class com.mappls.** { *; }
-keep class com.google.android.gms.** { *; }
-keepclassmembers class com.google.android.gms.** { *; }

# Keep any required tasks/listeners
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.location.** { *; }

# Prevent removal of Flutter plugin registration classes
-keep class io.flutter.plugins.** { *; }
-keep class com.mappls.sdk.maps.flutter.** { *; }
