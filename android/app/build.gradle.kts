plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val flutterMinSdk: Int = (project.findProperty("flutter.minSdkVersion") ?: "21").toString().toInt()
val flutterTargetSdk: Int = (project.findProperty("flutter.targetSdkVersion") ?: "33").toString().toInt()




android {
    namespace = "com.example.my_business_app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
    applicationId = "com.example.my_business_app"
    minSdk = flutterMinSdk
    targetSdk = flutterTargetSdk
    versionCode = 1
    versionName = "1.0"
    multiDexEnabled = true
}




    buildTypes {
        getByName("release") {
            // disable code shrinking and resource shrinking for now
            isMinifyEnabled = false
            isShrinkResources = false

            // keep signing as debug for local builds (not for production)
            signingConfig = signingConfigs.getByName("debug")

            // if you later enable minify, provide proguard rules:
            // proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    packagingOptions {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/NOTICE",
                "META-INF/LICENSE"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
