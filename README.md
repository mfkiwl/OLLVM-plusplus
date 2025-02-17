# Pluto-Obfuscator
Pluto-Obfuscator is an obfuscator based on LLVM 12.0.1 by [34r7h4mn](https://github.com/bluesadi) and [za233](https://github.com/za233).

## Environment
This project was developed and tested on the following environment:
- Ubuntu 20.04.3 LTS
- Clang/LLVM 12.0.1
- CMake 3.16.3
- Ninja 1.10.0

You can also build this project on Windows and MacOS, or even merge it into Android NDK toolchain (tested on Android NDK r23).

## Features
Pluto-Obfuscator encompasses multiple passes as follows (`*` indicates highly recommended passes):

- Control Flow Flattening ([Ref: Obfuscator-LLVM](https://github.com/obfuscator-llvm/obfuscator/wiki/Control-Flow-Flattening))
- \*Control Flow Flattening Enhanced ([Chinese documentation](https://bbs.pediy.com/thread-274778.htm))
- Bogus Control Flow ([Ref: Obfuscator-LLVM](https://github.com/obfuscator-llvm/obfuscator/wiki/Bogus-Control-Flow))
- Instruction Substitution ([Ref: Obfuscator-LLVM](https://github.com/obfuscator-llvm/obfuscator/wiki/Instructions-Substitution))
- Random Control Flow
- Variable Substitution
- String Encryption
- \*Globals Encryption
- [Trap Angr (Experimental)](docs/TrapAngr.md)
- \*MBA Obfuscation ([Chinese documentation](https://bbs.pediy.com/thread-271574.htm))

> 34r7hm4n: The documentation of this project is still lacking. I will work on it when I am available.

## Usage
### Build on Linux/Windows
The following commands work on both Linux and Windows:
```shell
mkdir -p build
cd build
cmake -G "Ninja" -DLLVM_ENABLE_PROJECTS="clang" \
    -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" \
    -DBUILD_SHARED_LIBS=On -DCMAKE_INSTALL_PREFIX="../install" ../llvm

ninja -j$(nproc)
ninja install
```
### Build on MacOS

```shell
mkdir -p build
cd build
cmake -G "Ninja" -DLLVM_ENABLE_PROJECTS="clang" \
    -DCMAKE_BUILD_TYPE=Release \
    -DDEFAULT_SYSROOT=$(xcrun --show-sdk-path) \
    -DCMAKE_OSX_SYSROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX$(xcrun --show-sdk-version).sdk \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_INSTALL_PREFIX="../install" \
    ../llvm

ninja -j$(sysctl -n hw.logicalcpu)
ninja install
```

### Compile
// TODO

`-s -mllvm -mba -mllvm -mba-prob=50 -mllvm -fla-ex -mllvm -gle`

### Filter Mode
In case you just want to obfuscate specific functions, Pluto-Obfuscator also provides a filter mechanism using annotation, to help you specify which functions should or should not be obfuscated.

To enable this mechanism, you should pass `-mllvm -filter-mode=include` or `-mllvm -filter-mode=exclude` to clang as an argument. 

- `-filter-mode=include`: only those functions with "include" annotation will be obfuscated.
- `-filter-mode=exclude`: ignore those functions with "exclude" annotation.
- `-filter-mode=none`: all functions will be processed. (by defualt)

For example:
```shell
clang++ TestFilter.cpp -mllvm -fla -mllvm -filter-mode=include -o TestFilter_include    # include mode
clang++ TestFilter.cpp -mllvm -fla -mllvm -filter-mode=exclude -o TestFilter_include    # exclude mode
clang++ TestFilter.cpp -mllvm -fla -mllvm -o TestFilter_include    # default mode
```

Following is a self-explanatory snippet showing how to annonate functions. In this case, only foo1 will be obfuscated in `include` mode. Only foo2 will be ignored in `exclude` mode. And foo3 will always be obfuscated:
```cpp
#define FUNC_INCLUDE __attribute__((annotate("include")))
#define FUNC_EXCLUDE __attribute__((annotate("exclude")))

FUNC_INCLUDE
void foo1(){ }

FUNC_EXCLUDE
void foo2(){ }

void foo3(){ }

int main(){
    foo1();
    foo2();
    foo3();
}
```

## Test suite
**IMPORTANT:** If you would like to improve this project by creating pull requests, please make sure your modified code can pass the tests as follows.

### Quick Test on AES
Usage: `./fast-check [your-passes]` (e.g., `./fast-check.sh mba mba-prob=50 fla-ex gle`).

See [fast-check.sh](fast-check.sh) and [test/aes](test/aes/).

### Test on libsecp256k1
Usage: `./check.sh [your-passes]` (e.g., `./check.sh mba mba-prob=50 fla-ex gle`)

Generally, it will cost several minutes to be done, much slower compared to AES test.

Passed Parameters:
- Flattening: `fla`
- FlatteningEnhanced: `fla-ex`
- Substitution: `sub`
- GlobalsEncryption: `gle`
- MBAObfuscation: `mba mba-prob=100`
- FullProtection (**HIGHLY RECOMMENDED**): `mba mba-prob=50 fla-ex gle`

See [check.sh](check.sh) and [test/secp256k1](test/secp256k1/).
