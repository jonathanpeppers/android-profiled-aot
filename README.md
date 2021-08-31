# android-profiled-aot

This is a repo for recording .NET 6 AOT profiles.

See:

* https://github.com/xamarin/xamarin-android/pull/6171
* 
* https://github.com/radekdoulik/aotprofile-tool

A few pieces are needed for recording AOT profiles to be distributed
as a "built-in" profile for .NET 6:

1. `aprofutil` from Mono.
1. `libmono-profiler-aot.so` from dotnet/runtime.
1. @radekdoulik's `aotprofile-tool` to strip out the project assembly,
   as it won't match other users' project assemblies.

## How do you update files in `binaries` folder?

For `aprofutil`, you can simply copy one of:

* From your system Xamarin.Android install:
  * `C:\Program Files\Microsoft Visual Studio\2022\Preview\MSBuild\Xamarin\Android\aprofutil.exe`
  * `C:\Program Files\Microsoft Visual Studio\2022\Preview\MSBuild\Xamarin\Android\aprofutil.pdb`
  * `/Library/Frameworks/Xamarin.Android.framework/Versions/Current/lib/xbuild/Xamarin/Android/Darwin/aprofutil`
  * `/Library/Frameworks/Xamarin.Android.framework/Versions/Current/lib/xbuild/Xamarin/Android/aprofutil.exe`
  * `/Library/Frameworks/Xamarin.Android.framework/Versions/Current/lib/xbuild/Xamarin/Android/aprofutil.pdb`
* From a local Xamarin.Android build tree:
  * `tools/scripts/aprofutil`
  * `bin/Debug/lib/xamarin.android/xbuild/Xamarin/Android/aprofutil.exe`
  * `bin/Debug/lib/xamarin.android/xbuild/Xamarin/Android/aprofutil.pdb`

I updated the `aprofutil` script to use `aprofutil.exe` in the current directory.

For `libmono-profiler-aot.so`, start with
[dotnet/runtime#57511][dotnet/runtime#57511] and rebase it on top of
the release branch of choice, such as `release/6.0`.

Build each architecture:

```bash
./build.sh mono -bl -c Release -os android -arch arm
./build.sh mono -bl -c Release -os android -arch arm64
./build.sh mono -bl -c Release -os android -arch x64
./build.sh mono -bl -c Release -os android -arch x86
```

This should produce the files:

```bash
ls -l artifacts/obj/mono/Android.*/out/lib/libmono-profiler-aot.so 
413144 Aug 31 10:46 artifacts/obj/mono/Android.arm.Release/out/lib/libmono-profiler-aot.so
702424 Aug 31 11:06 artifacts/obj/mono/Android.arm64.Release/out/lib/libmono-profiler-aot.so
702240 Aug 31 09:48 artifacts/obj/mono/Android.x64.Release/out/lib/libmono-profiler-aot.so
517276 Aug 31 09:58 artifacts/obj/mono/Android.x86.Release/out/lib/libmono-profiler-aot.so
```

Copy the files to:

* `binaries/android-arm/`
* `binaries/android-arm64/`
* `binaries/android-x64/`
* `binaries/android-x86/`

[dotnet/runtime#57511]: https://github.com/dotnet/runtime/pull/57511
