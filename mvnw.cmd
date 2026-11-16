@echo off
setlocal
if exist "%~dp0.mvn\wrapper\maven-wrapper.jar" (
    java -jar "%~dp0.mvn\wrapper\maven-wrapper.jar" %*
) else (
    if exist "C:\Users\ELCOT\Tools\apache-maven-3.9.9\bin\mvn.cmd" (
        "C:\Users\ELCOT\Tools\apache-maven-3.9.9\bin\mvn.cmd" %*
    ) else (
        mvn %*
    )
)
