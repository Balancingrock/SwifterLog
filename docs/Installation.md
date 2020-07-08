# Installation

## As an SPM package

To install SwifterLog type the following:

    $ git clone https://github.com/Balancingrock/SwifterLog

This will create a directory SwifterLog with the project contained in it.

Go down in the directory that was created:

    $ cd SwifterLog

Then perform a SPM build.

    $ swift build

## Adding to an Xcode project

In the Xcode project using the navigator panel select the target SwifterLog should be added to.

Then select the `General` tab and click the `+` sign of the `Frameworks, Libraries, and Embedded Content` section.

In the dropdown window select `Add Other...` and choose `Add Package Dependency...`.

In the new dropdown window type `https://github.com/Balancingrock/SwifterLog.git` and click `Next`, `Next` and `Finish`.

Now use `import SwifterLog` in each source file where you need its capabilities.

## Optional removal of Ascii, BRUtils, VJson and SwifterSockets dependency

By default SwifterLog also needs Ascii, BRUtils, VJson and SwifterSockets for the networking target. If the networking target is not needed, that code can be excluded by adding an Active Compilation Condition:

In the xcode project, the SwifterLog framework target, select the `Build Settings` and under `Swift Compiler - Custom Flags` add `SWIFTERLOG_DISABLE_NETWORK_TARGET` to the `Active Compiler Conditions`.

Also remove the Ascii, BRUtils, VJson and SwifterSockets from the `Linked Frameworks and Libraries` settings under the `General` tab for the SwifterLog target.
