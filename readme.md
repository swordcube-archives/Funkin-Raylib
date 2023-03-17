# Funkin-Raylib
A port of Friday Night Funkin' to Raylib
Includes a framework called `Droplet` made specifically for the project (as of now).

This is not finished and WILL have bugs! If you find any,
**Please** report them using the issues tab!

# 🖥️ Building the game
- Step 1. [Install git-scm](https://git-scm.com/downloads) if you don't have it already.
- Step 2. [Install Haxe](https://haxe.org/download/)
- Step 3. Run these commands to install required libraries:
```
haxelib git raylib-hx https://github.com/foreignsasquatch/raylib-hx
haxelib git hscript-improved https://github.com/YoshiCrafter29/hscript-improved
```
- Step 5. If you run on Windows, install [Visual Studio Community 2019](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=community&rel=16&utm_medium=microsoft&utm_source=docs.microsoft.com&utm_campaign=download+from+relnotes&utm_content=vs2019ga+button) using these specific components in `Individual Components` instead of selecting the normal options:
```
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)
```
- Step 6. Run `haxe <windows/linux/mac>.hxml`, choosing your OS. (Ex. `haxe windows.hxml`)

If your OS doesn't have an hxml file, Make a pull request for it!

And maybe try to help test other operating systems! As only `Windows` and `Linux` have been tested!
