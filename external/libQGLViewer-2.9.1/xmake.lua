add_rules("mode.debug", "mode.release")

add_requires("freeglut")

target("libqglviewer")
    add_rules("qt." .. "$(kind)")
    set_languages("c++17")

    add_files("QGLViewer/**.cpp")
    add_files("QGLViewer/*.h")
    add_files("QGLViewer/*.ui")

    add_headerfiles("(QGLViewer/**.h)")

    add_packages("freeglut")

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

        if target:get("kind") == "static" then
            target:add("defines", "QGLVIEWER_STATIC")
        elseif target:get("kind") == "shared" then
            target:add("defines", "CREATE_QGLVIEWER_DLL")
        end
    end)
