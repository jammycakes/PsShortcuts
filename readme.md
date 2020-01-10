PowerShell Shortcuts
====================

This is a little PowerShell script that lets you navigate quickly to your
most commonly used locations in your filespace. Rather than typing something
like `cd c:\windows\system32\drivers\etc`, you can type `go winetc`. Much
simpler and much more straightforward.

You can also define shortcuts that only apply in a specific directory. For
example, if you have a Visual Studio solution with a deeply nested hierarchy
or with directories pedantically named after the full namespaces to each assembly,
you can define a shortcut, say js, to point to the `\Scripts` directory in your
web front end.

Installation
------------
 1. Enable scripts on your computer by typing the following at a PowerShell
    command prompt:

    Set-ExecutionPolicy Unrestricted -Scope CurrentUser

 2. Run the installation script `install.ps1`.

Configuration
-------------
To edit your shortcuts, type the following at a PowerShell command prompt:

    vim $(Get-UserGoTargetDescriptor)

Or if you don't use vim, you can use this instead:

    notepad $(Get-UserGoTargetDescriptor)

This will bring up your user-level target definition file. It consists of
a series of shortcuts and their definitions, for example:

    winetc=c:\windows\system32\drivers\etc
    docs=c:\users\james\Documents

You can also define shortcuts to web pages:

    github=https://github.com/
    twitter=https://twitter.com/

Any line beginning with a hash (#) character will be treated as a comment
and ignored.

PsShortcuts recognises the tilde (~) as referring to your home directory
when it occurs at the start of a path:

    docs=~/Documents

For shortcuts that you want to apply only to a specific directory and its
subdirectories, create a file called .go in that directory. The syntax is
the same.

Usage
-----
To see a list of all shortcuts available to you, type `go` at a PowerShell
command prompt.

To chdir into that particular shortcut, type `go` followed by the name of
the shortcut that you navigate to.

To follow multiple shortcuts (for example, to chdir into a Visual Studio
solution then into shortcuts within that solution), you can type multiple
targets, for example:

    go project web js

To open an Explorer window in the current directory, type `here`.
