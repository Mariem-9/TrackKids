allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

//subprojects {
//    val project = this
//
//    // Function to apply the fix safely
//    val applyFixes = {
//        // 1. Fix Namespace for plugins that lack it
//        if (project.extensions.findByName("android") != null) {
//            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
//            if (android.namespace == null) {
//                // Use group name or fallback to project name
//                android.namespace = project.group.toString().ifEmpty { "com.fix.${project.name.replace("-", "_")}" }
//            }
//        }
//
//        // 2. Force Java Compiler to 17 (or 1.8 if you prefer)
//        tasks.withType<JavaCompile>().configureEach {
//            sourceCompatibility = "17"
//            targetCompatibility = "17"
//        }
//
//        // 3. Force Kotlin Compiler to 17
//        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>().configureEach {
//            compilerOptions {
//                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
//            }
//        }
//    }
//
//    // Logic to prevent the "Already Evaluated" error
//    if (project.state.executed) {
//        applyFixes()
//    } else {
//        project.afterEvaluate { applyFixes() }
//    }
//}
