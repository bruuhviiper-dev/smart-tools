# Smart Tools — regras R8/ProGuard (ofuscação + shrink) com keeps defensivos.

# Flutter engine
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.**

# mobile_scanner / ML Kit (leitor de QR/código de barras)
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-keep class com.google.android.odml.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.odml.**

# Play Billing (in_app_purchase)
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

# camera / sensores / geolocator / permission_handler — plugins com interop nativa
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# Modelos (de)serializados por reflexão, se houver — mantém anotações
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod

# Evita remover métodos nativos
-keepclasseswithmembernames class * {
    native <methods>;
}
