# MPQExtractor

A command-line tool to extract files from MPQ archives (used by Blizzard games).

Works on macOS, Linux and Windows.


## IN CASE OF ERROR (COMPILATION PROBLEMS / EXTRACTION ISSUES)

Most of the compilations problems and failures to extract a file from a MPQ archive can be solved by
**updating the version of StormLib used**:

    $ cd StormLib
    $ git pull origin master


## Dependencies

The following libraries are necessary to build the extractor:

* StormLib (http://www.zezula.net/en/mpq/stormlib.html), MIT License, free to use -
  included as a GIT submodule
* SimpleOpt 3.4 (http://code.jellycan.com/simpleopt/), MIT License - part of the
  distribution

To download the StormLib submodule, do:

    somewhere$ cd <path/to/the/source/of/MPQExtractor>
    MPQExtractor$ git submodule init
    MPQExtractor$ git submodule update


## Compilation

Requires <a href="http://www.cmake.org/">cmake</a> to build:

    $ mkdir build
    $ cd build
    $ cmake <path/to/the/source/of/MPQExtractor>
    $ cmake --build .

The executable will be put in build/bin/

**Windows**:
To specify the compiler and build in Release mode:

    mkdir build
    cd build
    cmake <path/to/the/source/of/MPQExtractor> -G "Visual Studio 15 2017 Win64" 
    cmake --build . --config Release


## Usage

See `MPQExtractor --help` for more details. All the examples below are shown using the World of Warcraft 4.3 files, as of Jan 2012.

**Retrieve the list of files in a MPQ archive:**

    $ MPQExtractor -l list.txt /path/to/art.MPQ
    $ cat list.txt
    art-md5.lst
    Cameras\Abyssal_Maw_CameraFly_01.M2
    Cameras\Abyssal_Maw_CameraFly_0100.skin
    Cameras\FlyBy_Maelstrom.M2
    ...


**Search all the *.M2 files in a MPQ archive:**

    $ MPQExtractor -s *.M2 /path/to/art.MPQ
    Opening 'path/to/art.MPQ'...

    Searching for '*.M2'...

    Found files:
      - PARTICLES\LoginFX.m2
      - Character\Worgen\Male\WorgenMale.M2
      - Character\Worgen\Female\WorgenFemale.M2
      - Character\Goblin\Female\GoblinFemale.M2
    ....


**Extract a specific file from a MPQ archive:**

**IMPORTANT:** Note that the file name is enclosed in "". This is to prevent the shell
to try to interpret the backslashes (\\) as the start of an escape sequence, which would
result in invalid file names.

    $ mkdir out
    $ MPQExtractor -e "Character\Worgen\Male\WorgenMale.M2" -o out /path/to/art.MPQ
    Opening '/path/to/art.MPQ'...

    Extracting files...

    $ ls out/
    WorgenMale.M2


**Extract some specific files from a MPQ archive, preserving the path hierarchy found
inside the MPQ archive:**

    $ mkdir out
    $ MPQExtractor -e "Character\Worgen\Male\WorgenMale*" -f -o out /path/to/art.MPQ
    Opening '/path/to/art.MPQ'...

    Searching for 'Character\Worgen\Male\WorgenMale*'...

    Found files:
      - Character\Worgen\Male\WorgenMale.M2
      - Character\Worgen\Male\WorgenMaleSkin00_03.blp
      - Character\Worgen\Male\WorgenMaleSkin00_01.blp
      - Character\Worgen\Male\WorgenMaleSkin00_05.blp
      - Character\Worgen\Male\WorgenMaleNakedPelvisSkin00_05.blp
    ...

    Extracting files...

    $ ls out/Character/Worgen/Male/
    WorgenMale.M2
    WorgenMale00.skin
    WorgenMale0060-00.anim
    WorgenMale0060-01.anim
    WorgenMale0061-00.anim
    WorgenMale0062-00.anim
    WorgenMale0064-00.anim
    WorgenMale0065-00.anim
    WorgenMale0066-00.anim
    WorgenMale0067-00.anim
    WorgenMale0068-00.anim
    WorgenMale0069-00.anim
    WorgenMale0069-01.anim
    ...


**Apply some patches before extracting a specific file from a MPQ archive:**

    $ mkdir out
    $ MPQExtractor -p /patches/wow-update-*.MPQ  \
                   /patches/wow-update-base-1*.MPQ  \
                   --prefix base
                   -e "Character\Worgen\Male\WorgenMale.M2"  \
                   -o out /path/to/art.MPQ
    Opening '/path/to/art.MPQ'...
    Applying patch '/patches/wow-update-13164.MPQ'...
    Applying patch '/patches/wow-update-13205.MPQ'...
    Applying patch '/patches/wow-update-13287.MPQ'...
    Applying patch '/patches/wow-update-13329.MPQ'...
    Applying patch '/patches/wow-update-13596.MPQ'...
    Applying patch '/patches/wow-update-13623.MPQ'...
    Applying patch '/patches/wow-update-base-13914.MPQ'...
    Applying patch '/patches/wow-update-base-14007.MPQ'...
    Applying patch '/patches/wow-update-base-14333.MPQ'...
    Applying patch '/patches/wow-update-base-13914.MPQ'...
    Applying patch '/patches/wow-update-base-14007.MPQ'...
    Applying patch '/patches/wow-update-base-14333.MPQ'...

    Extracting files...

    $ ls out/
    WorgenMale.M2

**Apply patches with different bases, extract files in lowercase:**

    $ mkdir out
    $ MPQExtractor -p /patches/wow-update-13164.MPQ,base  \
                    /patches/wow-update-13205.MPQ,base  \
                    /patches/wow-update-base-13914.MPQ
                    -e "World\Minimaps\*" -f -c -o out  \
                    /path/to/art.MPQ
    Opening '/path/to/art.MPQ'...
    Applying patch '/patches/wow-update-13164.MPQ' (prefix 'base')...
    Applying patch '/patches/wow-update-13205.MPQ' (prefix 'base')...
    Applying patch '/patches/wow-update-base-13914.MPQ' (no prefix)...

    Extracting files...

    $ ls out/
    world/

## Usage with Docker

1\. Initialize submodule dependencies

```sh
git submodule init
git submodule update
```

2\. Build docker image

```sh
docker build --target mpq-extractor-debian -t mpq-extractor-debian .
```

> [!NOTE]
> Typically, building `mpq-extractor-debian` image is required only once.
> This image will contain only the built `MPQExtractor` binary,
> without build tools like `gcc` or `make`.
> Compilation process itself occurs inside the `mpq-extractor-builder-debian` container.
> Such design is used to get optimal image.

> [!TIP]
> When it's required to play with compilation interactively, such command may be used:
>
> ```sh
> docker build --target mpq-extractor-builder-debian -t mpq-extractor-builder-debian .
> docker run -it --rm --volume "$PWD:/src" --entrypoint '/bin/bash' mpq-extractor-builder-debian
> # ... do something inside the container, for example `cmake /src`
> ```

3\. Run binary from container

Synopsis:
```
docker run --rm -it mpq-extractor-debian [MPQExtractor ARGUMENTS ...]
```

Print help:

```sh
docker run --rm -it mpq-extractor-debian  -h
```

> [!NOTE]
> Container filesystem is isolated from host filesystem, to make host directories accessible from the container, 
> it's required to mount it on `docker run` command invocation, for example:
> 
> ```sh
> export MPQ_DATA_DIR="/home/user/Documents/World of Warcraft 3.3.5a/Data"  # directory on host
> export OUT_DATA_DIR="/home/user/Documents/MPQExtractor-output"  # directory on host
> 
> docker run -it --rm \
>   --volume "$MPQ_DATA_DIR:/opt/data" \
>   --volume "$OUT_DATA_DIR:/opt/data/out" \
>   mpq-extractor-debian \
>   -l /opt/data/out/list.txt /opt/data/patch-4.MPQ
> 
> cat "$OUT_DATA_DIR/list.txt"  # Print file on host (which created in container)
> ```

> [!TIP]
> Like in example from previous step, when it's required to play with container (containing
> the only `MPQExtractor`) interactively, such command may be used:
>
> ```sh
> docker run -it --rm --volume "$PWD:/opt/data" --entrypoint '/bin/bash' mpq-extractor-debian
> # ... do something inside the container, for example `MPQExtractor -h`
> ```

See [Usage](#usage) section for more usage examples.

## License

MPQExtractor is made available under the MIT License. The text of the license is in the file 'LICENSE'.

Under the MIT License you may use MPQExtractor for any purpose you wish, without warranty, and modify it if you require, subject to one condition:

>   "The above copyright notice and this permission notice shall be included in
>   all copies or substantial portions of the Software."

In practice this means that whenever you distribute your application, whether as binary or as source code, you must include somewhere in your distribution the
text in the file 'LICENSE'. This might be in the printed documentation, as a file on delivered media, or even on the credits / acknowledgements of the
runtime application itself; any of those would satisfy the requirement.

Even if the license doesn't require it, please consider to contribute your modifications back to the community.
