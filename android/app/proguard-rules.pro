# R8/Proguard rules for Google ML Kit Text Recognition
# We only compile the Latin script. These rules prevent build failure due to missing optional scripts.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
