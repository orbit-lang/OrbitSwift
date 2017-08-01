<p align="center">
<img src="orbit_badge_sml.png"/>
</p>
<h1 align="center" style="font-family: 'orbitron'">The Orbit Programming Language</h1>

The Orbit programming language is an attempt to make programming easier **and** safer.

## The Big Picture

Starting with the superset of all modern language features, what can we take away to make our lives easier while also ensuring safety, expressibility, comprehensibility and good performance? What can the compiler/build system do for us that we currently do ourselves? What classes of bugs can we eliminate, and at what cost?

## The Current Picture

Orbit is still in the early stages of development. Expect frequent breaking changes until v1.0. However, the project is now in a buildable state and should run on macOS & most Linux distros. The build is currently untested on Windows but we'll get there eventually. The backend currently targets LLVM so, in theory, it shouldn't be too difficult to get a build going on anything supported by LLVM.

## Installation

The best way to get started with Orbit is to build this project. This project builds a command line tool called "orbit", which is the user facing part of the toolchain. There are separate libraries for the [frontend](https://github.com/orbit-lang/OrbitFrontend) (lexer, parser), the [backend](https://github.com/orbit-lang/OrbitBackend) (type system & code generation) and some [shared utility stuff](https://github.com/orbit-lang/OrbitCompilerUtils).

The language is currently implemented in Swift, so you will need to install [**Swift**](https://swift.org/download/#releases) on your platform. Orbit will eventually be self-hosted but for now, Swift does the job.

Clone the repo & run Swift build to generate the Orbit command line tool.

``` bash
git clone https://github.com/orbit-lang/Orbit.git
cd Orbit
swift build -c release
```

If all goes well, you should now have the orbit command line tool sat in `.build/release/orbit`. It is recommended that you add this tool to your path. In a future release, a build script will be provided that handles everything but, for now, just go with it. Don't make it weird.

## Usage

The orbit tool is primarily used to compile Orbit source files (.orb extension) to an executable binary (libraries coming soon).

`orbit build test.orb`

If the program is correct, you will end up with a binary called test in the same directory.

The tool can also run individual compilation phases, such as lexing & type checking. These can be helpful for debugging the compiler.

For a full list of the tool's capabilities, run:

`orbit -h`

## Contributing

If you are interested in getting involved in the development of Orbit, feel free to start hacking on the various projects. Please do not put compiler code in this project. This repo is purely for user-facing stuff and gluing the different phases together.

There is no formal review process or coding standard at the moment, but do try to stay consistent with the existing codebase. Everyone is welcome. All pull requests and issues will be reviewed ASAP.

If you do use Orbit, any & all feedback would be massively appreciated. Especially if you're installing on some obscure, poorly supported platform (e.g. Windows ;) ).

Lastly, if you are artistically inclined, a proper logo would be very welcome.