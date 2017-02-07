# Installation

## As an SPM package
To install SwifterLog type the following:

    $ git clone https://github.com/Balancingrock/SwifterLog

This will create a directory SwifterLog with the project contained in it.

Go down in the directory that was created:

    $ cd SwifterLog

Then perform a SPM build.

    $ swift build

## As a modular framework
To install SwifterLog type the following:

    $ git clone https://github.com/Balancingrock/SwifterLog

Then open the xcode project (with Xcode) in the new directory.

Hit ⌘B to build the project.

This creates a modular framework (in products).

Include the produced frameworks in a Xcode project under the target `General` settings, subsection `Embedded Binaries`.

## Install as source code

It is of course also possible to use SwifterLog as sourcecode. If so, simply add the sources from the SwifterJSON, SwifterSockets (from `Packages`)and the SwifterLog subdirectories (from `Sources`) to the project target.

You will also need the [CAsl framework](https://github.com/Balancingrock/CAsl) which contains the bridging information and C-glue code.

If the networking destination is not needed, do not include the sources from Ascii, SwifterJSON and SwifterSockets and set the active compiler condition `SWIFTERLOG_DISABLE_NETWORK_TARGET` as described above.

## Optional removal of Ascii, SwifterJSON and SwifterSockets dependency

By default SwifterLog also needs Ascii, SwifterJSON and SwifterSockets for the networking target. If the networking target is not needed, that code can be excluded by adding an Active Compilation Condition:

In the xcode project, the SwifterLog framework target, select the `Build Settings` and under `Swift Compiler - Custom Flags` add `SWIFTERLOG_DISABLE_NETWORK_TARGET` to the `Active Compiler Conditions`.

Also remove the Ascii, SwifterJSON and SwifterSockets from the `Linked Frameworks and Libraries` settings under the `General` tab for the SwifterLog target.

However do not remove the CAsl framework.
