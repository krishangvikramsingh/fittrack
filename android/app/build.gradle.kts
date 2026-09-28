plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.krishangvikramsingh.fittrack"
    // Must be >= what any plugin requires to compile against; shared_preferences
    // and sqflite's Android implementations require compileSdk 36. targetSdk
    // below is kept at the spec's 35 - compileSdk and targetSdk are independent.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications 18.x, which uses java.time APIs
        // that need desugaring to run on API levels below 26.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.krishangvikramsingh.fittrack"
        // Support floor is Android 7.0 (API 24) - Flutter 3.47's actual
        // minimum supported platform (its engine/embedding no longer builds
        // below API 24). The original spec asked for API 21, but the Flutter
        // Gradle plugin auto-rewrites any hardcoded value in [16,23] back to
        // `flutter.minSdkVersion` on every build for exactly this reason, so
        // this value is left as-is rather than fought on every build.
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Backports java.time / java.util.concurrent APIs to API < 26.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
