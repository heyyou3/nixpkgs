{ lib, stdenv, llvm_meta, version, fetch, cmake, python3, libllvm, libcxxabi }:

let

  useLLVM = stdenv.hostPlatform.useLLVM or false;
  bareMetal = stdenv.hostPlatform.parsed.kernel.name == "none";
  inherit (stdenv.hostPlatform) isMusl;

in

stdenv.mkDerivation {
  pname = "compiler-rt";
  inherit version;
  src = fetch "compiler-rt" "0ipd4jdxpczgr2w6lzrabymz6dhzj69ywmyybjjc1q397zgrvziy";

  nativeBuildInputs = [ cmake python3 libllvm.dev ];
  buildInputs = lib.optional stdenv.hostPlatform.isDarwin libcxxabi;

  NIX_CFLAGS_COMPILE = [
    "-DSCUDO_DEFAULT_OPTIONS=DeleteSizeMismatch=0:DeallocationTypeMismatch=0"
  ];

  cmakeFlags = [
    "-DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON"
    "-DCMAKE_C_COMPILER_TARGET=${stdenv.hostPlatform.config}"
    "-DCMAKE_ASM_COMPILER_TARGET=${stdenv.hostPlatform.config}"
  ] ++ lib.optionals (useLLVM || bareMetal || isMusl) [
    "-DCOMPILER_RT_BUILD_SANITIZERS=OFF"
    "-DCOMPILER_RT_BUILD_XRAY=OFF"
    "-DCOMPILER_RT_BUILD_LIBFUZZER=OFF"
    "-DCOMPILER_RT_BUILD_PROFILE=OFF"
  ] ++ lib.optionals (useLLVM || bareMetal) [
    "-DCMAKE_C_COMPILER_WORKS=ON"
    "-DCMAKE_CXX_COMPILER_WORKS=ON"
    "-DCOMPILER_RT_BAREMETAL_BUILD=ON"
    "-DCMAKE_SIZEOF_VOID_P=${toString (stdenv.hostPlatform.parsed.cpu.bits / 8)}"
  ] ++ lib.optionals (useLLVM) [
    "-DCOMPILER_RT_BUILD_BUILTINS=ON"
    "-DCMAKE_C_FLAGS=-nodefaultlibs"
    #https://stackoverflow.com/questions/53633705/cmake-the-c-compiler-is-not-able-to-compile-a-simple-test-program
    "-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY"
  ] ++ lib.optionals (bareMetal) [
    "-DCOMPILER_RT_OS_DIR=baremetal"
  ] ++ lib.optionals (stdenv.hostPlatform.isDarwin) [
    # The compiler-rt build infrastructure sniffs supported platforms on Darwin
    # and finds i386;x86_64;x86_64h. We only build for x86_64, so linking fails
    # when it tries to use libc++ and libc++api for i386.
    "-DDARWIN_osx_ARCHS=${stdenv.hostPlatform.darwinArch}"
  ];

  outputs = [ "out" "dev" ];

  patches = [
    ./codesign.patch # Revert compiler-rt commit that makes codesign mandatory
    # https://github.com/llvm/llvm-project/commit/947f9692440836dcb8d88b74b69dd379d85974ce
    ../../common/compiler-rt/glibc.patch
    ./gnu-install-dirs.patch
  ] ++ lib.optional stdenv.hostPlatform.isMusl ./sanitizers-nongnu.patch
    ++ lib.optional (stdenv.hostPlatform.libc == "glibc") ./sys-ustat.patch
    ++ lib.optional stdenv.hostPlatform.isAarch32 ./armv7l.patch
    ++ [ ../../common/compiler-rt/libsanitizer-no-cyclades-9.patch ];

  # TSAN requires XPC on Darwin, which we have no public/free source files for. We can depend on the Apple frameworks
  # to get it, but they're unfree. Since LLVM is rather central to the stdenv, we patch out TSAN support so that Hydra
  # can build this. If we didn't do it, basically the entire nixpkgs on Darwin would have an unfree dependency and we'd
  # get no binary cache for the entire platform. If you really find yourself wanting the TSAN, make this controllable by
  # a flag and turn the flag off during the stdenv build.
  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace cmake/config-ix.cmake \
      --replace 'set(COMPILER_RT_HAS_TSAN TRUE)' 'set(COMPILER_RT_HAS_TSAN FALSE)'
  '' + lib.optionalString (useLLVM) ''
    substituteInPlace lib/builtins/int_util.c \
      --replace "#include <stdlib.h>" ""
    substituteInPlace lib/builtins/clear_cache.c \
      --replace "#include <assert.h>" ""
    substituteInPlace lib/builtins/cpu_model.c \
      --replace "#include <assert.h>" ""
  '';

  # Hack around weird upsream RPATH bug
  postInstall = lib.optionalString (stdenv.hostPlatform.isDarwin || stdenv.hostPlatform.isWasm) ''
    ln -s "$out/lib"/*/* "$out/lib"
  '' + lib.optionalString (useLLVM) ''
    ln -s $out/lib/*/clang_rt.crtbegin-*.o $out/lib/linux/crtbegin.o
    ln -s $out/lib/*/clang_rt.crtend-*.o $out/lib/linux/crtend.o
    ln -s $out/lib/*/clang_rt.crtbegin_shared-*.o $out/lib/linux/crtbeginS.o
    ln -s $out/lib/*/clang_rt.crtend_shared-*.o $out/lib/linux/crtendS.o
  '';

  meta = llvm_meta // {
    homepage = "https://compiler-rt.llvm.org/";
    description = "Compiler runtime libraries";
    longDescription = ''
      The compiler-rt project provides highly tuned implementations of the
      low-level code generator support routines like "__fixunsdfdi" and other
      calls generated when a target doesn't have a short sequence of native
      instructions to implement a core IR operation. It also provides
      implementations of run-time libraries for dynamic testing tools such as
      AddressSanitizer, ThreadSanitizer, MemorySanitizer, and DataFlowSanitizer.
    '';
    # "All of the code in the compiler-rt project is dual licensed under the MIT
    # license and the UIUC License (a BSD-like license)":
    license = with lib.licenses; [ mit ncsa ];
    broken = stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64;
  };
}
