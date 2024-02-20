const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "SCATMECH",
        .target = target,
        .optimize = optimize,
    });
    lib.addCSourceFiles(.{
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
    lib.linkLibCpp();
    lib.installHeadersDirectoryOptions(.{
        .source_dir = .{ .path = "code" },
        .install_dir = .header,
        .install_subdir = "",
        .include_extensions = &.{".h"},
    });
    b.installArtifact(lib);

    const brdf_exe = b.addExecutable(.{
        .name = "BRDFProg",
        .target = target,
        .optimize = optimize,
    });
    brdf_exe.addCSourceFile(.{ .file = .{ .path = "code/BRDFProg/BRDFProg.cpp" } });
    brdf_exe.linkLibrary(lib);
    b.installArtifact(brdf_exe);

    const rcw_exe = b.addExecutable(.{
        .name = "RCWProg",
        .target = target,
        .optimize = optimize,
    });
    rcw_exe.addCSourceFile(.{ .file = .{ .path = "code/RCWProg/RCWProg.cpp" } });
    rcw_exe.linkLibrary(lib);
    b.installArtifact(rcw_exe);

    const reflect_exe = b.addExecutable(.{
        .name = "ReflectProg",
        .target = target,
        .optimize = optimize,
    });
    reflect_exe.addCSourceFile(.{ .file = .{ .path = "code/ReflectProg/ReflectProg.cpp" } });
    reflect_exe.linkLibrary(lib);
    b.installArtifact(reflect_exe);

    const mie_exe = b.addExecutable(.{
        .name = "MieProg",
        .target = target,
        .optimize = optimize,
    });
    mie_exe.addCSourceFile(.{ .file = .{ .path = "code/MieProg/MieProg.cpp" } });
    mie_exe.linkLibrary(lib);
    b.installArtifact(mie_exe);
}
