# Installation

Though distributed as a Swift Package Manager (SPM) package, SwifterLog will fail to build using the SPM.

This is due to the fact that a little C glue code is necessary to use the ASL interface. The SPM however cannot handle mixed language modules.

(Note: at the time it is unfortunately also not possible to put the glue code in a seperate package, that leads to an "Illegal instruction: 4" error from the SPM)

Still, there is an advantage to this way of distribution as it will resolve the dependencies of SwifterLog.

To install SwifterLog type the following:

    $ git clone https://github.com/Balancingrock/SwifterLog

This will create a directory SwifterLog with the project contained in it.

Go down in the directory that was created:

    $ cd SwifterLog

Then attempt a SPM build (which will fail, but will also load the dependencies)

    $ swift build

The open the xcode project (with Xcode).

Hit ⌘B to build the project.

This creates a modular framework (in products).

Include this framework in a Xcode project under the target `General` settings, subsection `Embedded Binaries`.

## Optional

### Remove SwifterJSON and SwifterSockets dependency

By default SwifterLog also needs SwifterJSON and SwifterSockets for the networking target. If the networking target is not needed, that code can be excluded by adding an Active Compilation Condition:

In the xcode project, the SwifterLog framework target, select the `Build Settings` and under `Swift Compiler - Custom Flags` add `SWIFTERLOG_DISABLE_NETWORK_TARGET` to the `Active Compiler Conditions`.

Then also remove the SwifterJSON and SwifterSockets from the `Linked Frameworks and Libraries` settings under the `General` tab for the SwifterLog target.

### Install as source code

It is of course also possible to use SwifterLog as sourcecode. If so, simply add the sources from the SwifterJSON, SwifterSockets (from `Packages`)and the SwifterLog subdirectories (from `Sources`) to the project target.

It is then also necessary to include the C headers in a project bridging file, or to create a bridging file if the project does not have one.

If the networking destination is not needed, do not include the sources from SwifterJSON and SwifterSockets and set the active compiler condition `SWIFTERLOG_DISABLE_NETWORK_TARGET` as described above.