-- Update this to point to the location of the CHERIoT SDK
sdkdir = path.absolute("./cheriot-rtos/sdk")
set_project("CHERIoT CoreMark Port")

includes(sdkdir)

set_toolchains("cheriot-clang")

includes(path.join(sdkdir, "lib"))

option("board")
  set_default("sonata-1.1")

compartment("coremark")
    set_default(false)
    add_includedirs("./coremark", "./coremark/barebones")
    add_deps("freestanding", "stdio")
    add_files("coremark/core_main.c",
              "coremark/core_list_join.c",
              "coremark/core_matrix.c",
              "coremark/core_state.c",
              "coremark/core_util.c",
              "coremark/barebones/core_portme.c")
    add_defines("ITERATIONS=800", "MEM_METHOD=MEM_STATIC", "MEM_LOCATION=\"STATIC\"", "PERFORMANCE_RUN=1")

firmware("coremark_firmware")
    add_deps("coremark")
    on_load(function(target)
        target:values_set("board", "$(board)")
        target:values_set("threads", {
          {
            compartment = "coremark",
            priority = 1,
            entry_point = "entry",
            stack_size = 0xe00,
            trusted_stack_frames = 6
          },
        }, {expand = false})
    end)