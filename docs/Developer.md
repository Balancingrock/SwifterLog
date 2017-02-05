# Developer

Since SwifterLog needs the C-glue code, a compilation after modifying the project (environment) need some extra steps.

This also applies to upgrading the dependencies. 

Whenever the xcode project needs to be regenerated, use the following steps:

1) Remove the C headers and implementation files from the Sources directory:

    $ rm Sources/*.m
    $ rm Sources/*.h

2) Then create a new xcode project (overwriting the old one)

    $ swift package generate-xcodeproj
    
3) Open xcode project

4) Add the sources in `c-sources-backup` to the `SwifterLog` folder in Xcode. It is recommened to use the "copy if needed" option. And add the sources to the `SwifterLog.framework` target.

5) Open the target settings and make sure the `Defines Module` option is set to `Yes` for all frameworks (Ascii, SwifterJSON, SwifterSockets and SwifterLog). This option is under `Build Settings` subsection `Packaging`.

6) For the SwifterLog target only, add the `Objective-C Bridging Header`, path: `Sources/SwifterLog-Bridging-Header.h`.

7) Rebuild the project.