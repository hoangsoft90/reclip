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

// Fix JVM target mismatch using JVM Toolchain (recommended by Gradle)
// This ensures Java AND Kotlin both use JDK 17
subprojects {
    pluginManager.withPlugin("org.jetbrains.kotlin.android") {
        configure<org.jetbrains.kotlin.gradle.dsl.KotlinJvmProjectExtension> {
            jvmToolchain(17)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
