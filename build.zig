const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const enable_tracy = b.option(bool, "tracy", "enable tracy performance profiler integration") orelse false;

    const Tracy = b.dependency("Tracy", .{
        .target = target,
        .optimize = optimize,
        .python = enable_tracy,
        .enable = enable_tracy,
    });

    const SCATMECH = b.addStaticLibrary(.{
        .name = "SCATMECH",
        .target = target,
        .optimize = optimize,
    });
    SCATMECH.bundle_compiler_rt = true;
    SCATMECH.addCSourceFiles(.{
        .files = &.{
            "code/allrough.cpp",
            "code/askuser.cpp",
            "code/axifree.cpp",
            "code/axipart1.cpp",
            "code/axipart2.cpp",
            "code/axisym.cpp",
            "code/bobvlieg1.cpp",
            "code/bobvlieg2.cpp",
            "code/bobvlieg3.cpp",
            "code/brdf.cpp",
            "code/coatedmie.cpp",
            "code/crossgrating.cpp",
            "code/crossgrating2.cpp",
            "code/crossrcw.cpp",
            "code/crough.cpp",
            "code/dielfunc.cpp",
            "code/diffuse.cpp",
            "code/facet.cpp",
            "code/fft.cpp",
            "code/filmtran.cpp",
            "code/finiteaperture.cpp",
            "code/firstdiffuse.cpp",
            "code/flake.cpp",
            "code/focussedbeam.cpp",
            "code/fresnel.cpp",
            "code/gcross.cpp",
            "code/grating.cpp",
            "code/inherit.cpp",
            "code/instrument.cpp",
            "code/jmatrix.cpp",
            "code/jvector.cpp",
            "code/lambert.cpp",
            "code/local.cpp",
            "code/matrixmath.cpp",
            "code/matrixmath2.cpp",
            "code/miescat.cpp",
            "code/models.cpp",
            "code/mueller.cpp",
            "code/nsphere.cpp",
            "code/oasphere.cpp",
            "code/onelayer.cpp",
            "code/phasefunction.cpp",
            "code/polydisperse.cpp",
            "code/random.cpp",
            "code/raygscat.cpp",
            "code/rayinst.cpp",
            "code/rayscat.cpp",
            "code/raystack.cpp",
            "code/rcw.cpp",
            "code/reflectance.cpp",
            "code/reg_brdf.cpp",
            "code/reg_facet.cpp",
            "code/reg_instrument.cpp",
            "code/reg_lambert.cpp",
            "code/reg_local.cpp",
            "code/reg_rough.cpp",
            "code/reg_sphrscat.cpp",
            "code/rough.cpp",
            "code/roughnes.cpp",
            "code/scateval.cpp",
            "code/scatmatrix.cpp",
            "code/scattabl.cpp",
            "code/sizedistribution.cpp",
            "code/sphdfct.cpp",
            "code/sphprt.cpp",
            "code/sphrscat.cpp",
            "code/stokes.cpp",
            "code/subbobvlieg.cpp",
            "code/subsphere.cpp",
            "code/tmatrix.cpp",
            "code/torrspar.cpp",
            "code/transmit.cpp",
            "code/two_source.cpp",
            "code/twoface.cpp",
            "code/urough.cpp",
            "code/vector3d.cpp",
            "code/zernike.cpp",
            "code/zernikeexpansion.cpp",
        },
    });
    SCATMECH.linkLibCpp();
    SCATMECH.installHeadersDirectoryOptions(.{
        .source_dir = .{ .path = "code" },
        .install_dir = .header,
        .install_subdir = "",
        .include_extensions = &.{".h"},
    });
    SCATMECH.linkLibrary(Tracy.artifact("TracyClient"));
    if (enable_tracy) {
        SCATMECH.defineCMacro("TRACY_ENABLE", "1");
    }
    b.installArtifact(SCATMECH);

    _ = buildPythonModule(b, .{
        .target = target,
        .optimize = optimize,
        .SCATMECH = SCATMECH,
    });

    buildExamples(b, .{
        .target = target,
        .optimize = optimize,
        .SCATMECH = SCATMECH,
    });
}

pub fn buildPythonModule(b: *std.Build, options: struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    SCATMECH: *std.Build.Step.Compile,
}) *std.Build.Step {
    const python_module_install_step = b.step("pySCATMECH", "Build python module");

    const SCATPY = b.addSharedLibrary(.{
        .name = "SCATPY",
        .target = options.target,
        .optimize = options.optimize,
    });
    SCATPY.addCSourceFile(.{
        .file = .{ .path = "pySCATMECH/SCATPYmodule.cpp" },
    });
    SCATPY.linkLibrary(options.SCATMECH);
    SCATPY.linkSystemLibrary("python");
    const SCATPY_install = b.addInstallArtifact(SCATPY, .{
        .dest_dir = .{ .override = .{ .custom = "site-packages/" } },
        .dest_sub_path = if (options.target.result.os.tag == .windows) "SCATPY.pyd" else "SCATPY.so",
    });
    python_module_install_step.dependOn(&SCATPY_install.step);

    // use Zig's ability to install header files to ensure that the python source code is
    // distributed alongside the dll.
    const install_python_source = b.addInstallDirectory(.{
        .source_dir = .{ .path = "./pySCATMECH" },
        .install_dir = .{ .custom = "site-packages/" },
        .install_subdir = "pySCATMECH",
        .include_extensions = &.{".py"},
    });

    python_module_install_step.dependOn(&install_python_source.step);

    return python_module_install_step;
}

pub fn buildExamples(b: *std.Build, options: struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    SCATMECH: *std.Build.Step.Compile,
}) void {
    const examples = b.step("examples", "Build example programs");

    const brdf_exe = b.addExecutable(.{
        .name = "BRDFProg",
        .target = options.target,
        .optimize = options.optimize,
    });
    brdf_exe.addCSourceFile(.{ .file = .{ .path = "code/BRDFProg/BRDFProg.cpp" } });
    brdf_exe.linkLibrary(options.SCATMECH);
    const brdf_exe_install = b.addInstallArtifact(brdf_exe, .{});
    examples.dependOn(&brdf_exe_install.step);

    const rcw_exe = b.addExecutable(.{
        .name = "RCWProg",
        .target = options.target,
        .optimize = options.optimize,
    });
    rcw_exe.addCSourceFile(.{ .file = .{ .path = "code/RCWProg/RCWProg.cpp" } });
    rcw_exe.linkLibrary(options.SCATMECH);
    const rcw_exe_install = b.addInstallArtifact(rcw_exe, .{});
    examples.dependOn(&rcw_exe_install.step);

    const reflect_exe = b.addExecutable(.{
        .name = "ReflectProg",
        .target = options.target,
        .optimize = options.optimize,
    });
    reflect_exe.addCSourceFile(.{ .file = .{ .path = "code/ReflectProg/ReflectProg.cpp" } });
    reflect_exe.linkLibrary(options.SCATMECH);
    const reflect_exe_install = b.addInstallArtifact(reflect_exe, .{});
    examples.dependOn(&reflect_exe_install.step);

    const mie_exe = b.addExecutable(.{
        .name = "MieProg",
        .target = options.target,
        .optimize = options.optimize,
    });
    mie_exe.addCSourceFile(.{ .file = .{ .path = "code/MieProg/MieProg.cpp" } });
    mie_exe.linkLibrary(options.SCATMECH);
    const mie_exe_install = b.addInstallArtifact(mie_exe, .{});
    examples.dependOn(&mie_exe_install.step);
}
