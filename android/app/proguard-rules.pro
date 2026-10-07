# Keep smart_auth classes
-keep class com.google.android.gms.auth.** { *; }
-keep class fman.ge.smart_auth.** { *; }
-keep class com.google.android.gms.auth.api.credentials.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }

# Keep Google Sign-In classes
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# Don't warn about missing classes
-dontwarn com.google.android.gms.auth.api.credentials.**
