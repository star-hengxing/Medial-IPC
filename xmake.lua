package("libqglviewer")
    set_sourcedir(path.join(os.scriptdir(), "external/libQGLViewer-2.9.1"))

    add_deps("freeglut")

    -- on_load(function (package)
    --     import("detect.sdks.find_qt")
    --     -- find qt sdk
    --     local qt = assert(find_qt(nil, {verbose = true}), "Qt SDK not found!")
    --     if qt and qt.sdkver then
    --         if qt.sdkver:startswith("5") then
    --             -- skip
    --         elseif qt.sdkver:startswith("6") then
    --             package:add("frameworks", "QtOpenGLWidgets")
    --         else
    --             raise("Qt SDK version 5 or 6 not found, please run `xmake f --qt_sdkver=xxx` to set it.")
    --         end
    --         package:add("frameworks", {"QtCore", "QtGui", "QtWidgets", "QtXml", "QtOpenGL"})
    --     end
    -- end)

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        else
            package:add("defines", "QGLVIEWER_STATIC")
        end
        import("package.tools.xmake").install(package, configs)
    end)
package_end()

package("qucsdk")
    on_load(function (package)
        package:set("installdir", path.join(os.scriptdir(), "external/qucsdk"))
    end)

    on_fetch(function (package)
        local result = {}
        result.includedirs = package:installdir("include")
        result.linkdirs = package:installdir()
        result.links = {"quc", "qucd"}

        if package:config("shared") then
            package:addenv("PATH", package:installdir())
        end
        return result
    end)
package_end()

add_rules("mode.debug", "mode.release")

add_requires("eigen", "mkl", "cuda", "freetype", "openmp")
add_requires("qucsdk", "libqglviewer")

set_languages("c++17")
set_runtimes("MD")

add_includedirs(".")

target("main")
    add_rules("qt.widgetapp")

    add_files("Commom/**.h")
    add_files("Commom/**.cpp")

    add_files("Model/**.h")
    add_files("Model/**.cpp")
    add_files("Model/tiny_obj_loader.cc")

    add_files("Scene/**.h")
    add_files("Scene/**.cpp")

    add_files("Shader/**.h")
    add_files("Shader/**.cpp")

    add_files("Simulator/**.h")
    add_files("Simulator/**.cpp")
    add_files("Simulator/**.cu")
    remove_files("Simulator/CollisionDetection/CollisionDetectionMedialMesh11.h")
    remove_files("Simulator/CollisionDetection/CollisionDetectionMedialMesh11.cpp")

    add_files("Ui/**.h")
    add_files("Ui/**.cpp")
    add_files("Ui/**.ui")

    add_files("*.ui")
    add_files("*.h")
    add_files("*.qrc")
    add_files("*.cpp")
    add_files("Cuda/*.cu")
    add_files("icon/ui_icon.qrc")
    add_files("SimFramework.rc")

    -- if is_mode("debug") then
    --     add_ldflags("/subsystem:console")
    -- end
    add_ldflags("/subsystem:console")

    add_links("cublas", "cusolver", "cusparse")

    add_packages("cuda", "eigen", "mkl", "qucsdk", "freetype", "libqglviewer", "openmp")

    set_rundir("$(projectdir)")

    on_load(function(target)
        import("detect.sdks.find_qt")
        -- find qt sdk
        local qt = target:data("qt")
        if not qt then
            qt = assert(find_qt(nil, {verbose = true}), "Qt SDK not found!")
            target:data_set("qt", qt)
        end

        if qt and qt.sdkver then
            if qt.sdkver:startswith("5") then
                -- skip
            elseif qt.sdkver:startswith("6") then
                target:add("frameworks", "QtOpenGLWidgets")
            else
                raise("Qt SDK version 5 or 6 not found, please run `xmake f --qt_sdkver=xxx` to set it.")
            end
            target:add("frameworks", {"QtCore", "QtGui", "QtWidgets", "QtXml", "QtOpenGL"})
        end
    end)
