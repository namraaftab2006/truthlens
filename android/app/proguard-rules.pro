# 🧠 Google ML Kit Text Recognition fix
# Prevent R8 from deleting ML Kit vision/text classes
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
