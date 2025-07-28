plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // ✅ Required for Firebase
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // ✅ Keep this after android & kotlin
}

android {
    namespace = "com.example.sarvam"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.sarvam"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
    // ✅ Firebase BoM - ensures version compatibility
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))

    // ✅ Example Firebase SDK - Analytics (add more as needed)
    implementation("com.google.firebase:firebase-analytics")

    // 🔁 Add others like Auth, Firestore, etc. below as needed:
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
}
