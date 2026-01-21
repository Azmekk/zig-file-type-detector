/// Main library entry point for the file type detector.
pub const MagicNumberAnalyzer = @import("lib/magic_number_analyzer.zig").MagicNumberAnalyzer;
pub const MagicNumber = @import("lib/file_type_helper.zig").MagicNumber;
pub const KnownByteSequence = @import("lib/file_type_helper.zig").KnownByteSequence;
pub const MimeTypes = @import("lib/constants/mime_types.zig").MimeTypes;

const std = @import("std");

test "MagicNumberAnalyzer initialization" {
    const allocator = std.testing.allocator;
    var analyzer = MagicNumberAnalyzer.init(allocator);
    defer analyzer.deinit();

    try std.testing.expectEqual(@as(usize, 256), analyzer.byte_limit);
}

test "MIME type detection from JPEG bytes" {
    const allocator = std.testing.allocator;
    var analyzer = MagicNumberAnalyzer.init(allocator);
    defer analyzer.deinit();

    const jpeg_bytes = [_]u8{ 0xFF, 0xD8, 0xFF, 0xE0 };
    const mime_type = analyzer.getMimeTypeFromBytes(&jpeg_bytes);

    try std.testing.expectEqualStrings("image/jpeg", mime_type);
}

test "MIME type detection from PNG bytes" {
    const allocator = std.testing.allocator;
    var analyzer = MagicNumberAnalyzer.init(allocator);
    defer analyzer.deinit();

    const png_bytes = [_]u8{ 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A };
    const mime_type = analyzer.getMimeTypeFromBytes(&png_bytes);

    try std.testing.expectEqualStrings("image/png", mime_type);
}

test "MIME type detection from PDF bytes" {
    const allocator = std.testing.allocator;
    var analyzer = MagicNumberAnalyzer.init(allocator);
    defer analyzer.deinit();

    const pdf_bytes = [_]u8{ 0x25, 0x50, 0x44, 0x46 };
    const mime_type = analyzer.getMimeTypeFromBytes(&pdf_bytes);

    try std.testing.expectEqualStrings("application/pdf", mime_type);
}

test "MIME type detection from GIF87a bytes" {
    const allocator = std.testing.allocator;
    var analyzer = MagicNumberAnalyzer.init(allocator);
    defer analyzer.deinit();

    const gif_bytes = [_]u8{ 0x47, 0x49, 0x46, 0x38, 0x37, 0x61 };
    const mime_type = analyzer.getMimeTypeFromBytes(&gif_bytes);

    try std.testing.expectEqualStrings("image/gif", mime_type);
}

test "MIME type detection from GIF89a bytes" {
    const allocator = std.testing.allocator;
    var analyzer = MagicNumberAnalyzer.init(allocator);
    defer analyzer.deinit();

    const gif_bytes = [_]u8{ 0x47, 0x49, 0x46, 0x38, 0x39, 0x61 };
    const mime_type = analyzer.getMimeTypeFromBytes(&gif_bytes);

    try std.testing.expectEqualStrings("image/gif", mime_type);
}

test "MIME type detection for unknown bytes" {
    const allocator = std.testing.allocator;
    var analyzer = MagicNumberAnalyzer.init(allocator);
    defer analyzer.deinit();

    const unknown_bytes = [_]u8{ 0xAA, 0xBB, 0xCC, 0xDD };
    const mime_type = analyzer.getMimeTypeFromBytes(&unknown_bytes);

    try std.testing.expectEqualStrings("application/octet-stream", mime_type);
}

test "Add custom magic number" {
    const allocator = std.testing.allocator;
    var analyzer = MagicNumberAnalyzer.init(allocator);
    defer analyzer.deinit();

    const custom_sequence = KnownByteSequence.init(&[_]u8{ 0xCA, 0xFE }, 0);
    const custom_magic = MagicNumber.init("application/custom", &[_]KnownByteSequence{custom_sequence});

    try analyzer.addCustomMagicNumber(custom_magic);

    try std.testing.expectEqual(@as(usize, 1), analyzer._custom_magic_numbers.len);
}

test "Detect custom magic number before predefined ones" {
    const allocator = std.testing.allocator;
    var analyzer = MagicNumberAnalyzer.init(allocator);
    defer analyzer.deinit();

    const custom_sequence = KnownByteSequence.init(&[_]u8{ 0xFF, 0xD8 }, 0);
    const custom_magic = MagicNumber.init("application/custom-jpeg", &[_]KnownByteSequence{custom_sequence});

    try analyzer.addCustomMagicNumber(custom_magic);

    const jpeg_bytes = [_]u8{ 0xFF, 0xD8, 0xFF, 0xE0 };
    const mime_type = analyzer.getMimeTypeFromBytes(&jpeg_bytes);

    // Custom should be checked first, so it returns the custom MIME type
    try std.testing.expectEqualStrings("application/custom-jpeg", mime_type);
}

test "MIME type detection from ZIP bytes" {
    const allocator = std.testing.allocator;
    var analyzer = MagicNumberAnalyzer.init(allocator);
    defer analyzer.deinit();

    const zip_bytes = [_]u8{ 0x50, 0x4B, 0x03, 0x04 };
    const mime_type = analyzer.getMimeTypeFromBytes(&zip_bytes);

    try std.testing.expectEqualStrings("application/zip", mime_type);
}

test "Root exports are available" {
    const mime_types = MimeTypes;

    try std.testing.expectEqualStrings("image/jpeg", mime_types.jpeg);
    try std.testing.expectEqualStrings("image/png", mime_types.png);
    try std.testing.expectEqualStrings("application/pdf", mime_types.pdf);
}

test "Multi-sequence magic number detection (WebP)" {
    const allocator = std.testing.allocator;
    var analyzer = MagicNumberAnalyzer.init(allocator);
    defer analyzer.deinit();

    // WebP has two sequences: RIFF at offset 0 and WEBP at offset 8
    const webp_bytes = [_]u8{
        0x52, 0x49, 0x46, 0x46, // RIFF at offset 0
        0x00, 0x00, 0x00, 0x00, // Size
        0x57, 0x45, 0x42, 0x50, // WEBP at offset 8
    };
    const mime_type = analyzer.getMimeTypeFromBytes(&webp_bytes);

    try std.testing.expectEqualStrings("image/webp", mime_type);
}


