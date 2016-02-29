
newoption {
    trigger     = "include",
    value       = "path",
    description = "The location of wren.h"
}

newoption {
    trigger     = "link",
    value       = "path",
    description = "The location of the wren static lib"
}

workspace "wrenly"
    if _ACTION then
        -- guard this in case the user is calling `premake5 --help`
        -- in which case there will be no action
        location( "build/" .. _ACTION )
    end
    configurations { "Debug", "Release" }

    -- global configuration
    filter "configurations:Debug"
        defines { "DEBUG" }
        flags { "Symbols" }

    filter "configurations:Release"
        defines { "NDEBUG" }
        optimize "On"

    project "lib"
        kind "StaticLib"
        language "C++"
        targetdir "lib/"
        targetname "wrenly"
        if _OPTIONS["include"] then
            includedirs { _OPTIONS["include"] }
        end

        files { "src/**.cpp", "src/**.h" }
        includedirs { "src" }

        filter "action:gmake"
            buildoptions { "-std=gnu++14" }

    project "test"
        kind "ConsoleApp"
        language "C++"
        targetdir "bin"
        targetname "test"
        files { "test/**.cpp", "test/***.h", "test/**.wren" }
        includedirs { "src", "test" }
        if _OPTIONS["include"] then
            includedirs { _OPTIONS["include"] }
        end

        configuration "vs*"
            if _OPTIONS["link"] then
                filter "configurations:Debug"
                    libdirs {
                        _OPTIONS["link"] .. "/Debug"
                    }
                    links { "lib", "wren_static_d" }
                    project "test"
                filter "configurations:Release"
                    libdirs {
                        _OPTIONS["link"] .. "/Release"
                    }
                    links { "lib", "wren_static" }
                    project "test"
            end
            project "test"
            filter "files:**.wren"
                buildcommands { "copy ..\\..\\test\\%{file.name} ..\\..\\bin" }
                buildoutputs { "..\\..\\bin\\%{file.name}" }

        configuration "gmake"
            filter "files:**.wren"
                buildcommands { "cp ../../test/%{file.name} ../../bin" }
                buildoutputs { "../../bin/test/%{file.name}" }