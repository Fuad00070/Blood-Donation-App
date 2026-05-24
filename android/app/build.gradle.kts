plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.untitled"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Core Library Desugaring এনাবল করা হলো
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.untitled"
        // Firebase এবং আধুনিক প্লাগইনগুলোর জন্য minSdk অন্তত ২১ বা ২৩ হওয়া ভালো
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Desugaring এর জন্য লাইব্রেরি যোগ করা হলো
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
