# Keep Google Play services
-keep class com.google.android.gms.** { *; }
-keepclassmembers class com.google.android.gms.** { *; }

# Keep any required tasks/listeners
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.location.** { *; }

# Prevent removal of Flutter plugin registration classes
-keep class io.flutter.plugins.** { *; }

# Firebase optimizations
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn org.xmlpull.v1.**
-dontnote com.google.android.gms.**

# Flutter optimizations
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }
-keep class com.google.** { *; }

# Image optimization
-keep class * extends androidx.appcompat.app.AppCompatActivity {
   public void onCreate(android.os.Bundle);
}
-keep class * extends androidx.fragment.app.Fragment {
   public void onCreate(android.os.Bundle);
}

# General optimizations
-optimizationpasses 5
-allowaccessmodification
-dontpreverify
-dontwarn android.support.**
-dontwarn androidx.**

# Google Play Core (for deferred components/split APKs)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
