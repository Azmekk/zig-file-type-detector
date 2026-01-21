# Zig File Type Detector

A fast and efficient Zig library for detecting file types using magic numbers (file signatures). This library analyzes the beginning bytes of files to identify their type and return the appropriate MIME type.

## Features

- **Magic number detection**: Identify file types by their magic bytes
- **Multi-sequence support**: Handle file formats that require multiple byte sequences at different offsets (e.g., WebP)
- **Custom magic numbers**: Add your own magic number definitions
- **Zero-copy**: Efficient byte-level analysis
- **Comprehensive built-in support**: JPEG, PNG, GIF, PDF, ZIP, WebP, and more
- **CLI tool**: Command-line utility for quick file type detection
- **Benchmark support**: Built-in performance testing

## Installation

Download and add zig-file-type-detector as a dependency by running the following command in your project root:

```
zig fetch --save git+https://github.com/Azmekk/zig-file-type-detector#main
```

Then reference it in your `build.zig`:

```zig
const zig_file_type_detector_dep = b.dependency("zig_file_type_detector", .{
    .target = target,
    .optimize = optimize,
});

const zig_file_type_detector = zig_file_type_detector_dep.module("zig_file_type_detector");

// Add to your executable
exe.root_module.addImport("zig_file_type_detector", zig_file_type_detector);
```

## Usage

### Basic File Type Detection

```zig
const std = @import("std");
const zig_file_type_detector = @import("zig_file_type_detector");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var analyzer = zig_file_type_detector.MagicNumberAnalyzer.init(allocator);
    defer analyzer.deinit();

    // Detect from file
    const mime_type = try analyzer.getMimeTypeFromFile("path/to/file.jpg");
    std.debug.print("MIME type: {s}\n", .{mime_type});

    // Detect from bytes
    const jpeg_bytes = [_]u8{ 0xFF, 0xD8, 0xFF, 0xE0 };
    const mime = analyzer.getMimeTypeFromBytes(&jpeg_bytes);
    std.debug.print("MIME type: {s}\n", .{mime});
}
```

### Adding Custom Magic Numbers

```zig
const custom_sequence = zig_file_type_detector.KnownByteSequence.init(
    &[_]u8{ 0xCA, 0xFE, 0xBA, 0xBE },
    0 // offset
);

const custom_magic = zig_file_type_detector.MagicNumber.init(
    "application/custom-format",
    &[_]zig_file_type_detector.KnownByteSequence{custom_sequence}
);

try analyzer.addCustomMagicNumber(custom_magic);
```

### Multi-Sequence Detection (e.g., WebP)

```zig
const sequences = [_]zig_file_type_detector.KnownByteSequence{
    zig_file_type_detector.KnownByteSequence.init(&[_]u8{ 0x52, 0x49, 0x46, 0x46 }, 0),  // RIFF at offset 0
    zig_file_type_detector.KnownByteSequence.init(&[_]u8{ 0x57, 0x45, 0x42, 0x50 }, 8),  // WEBP at offset 8
};

const webp_magic = zig_file_type_detector.MagicNumber.init(
    "image/webp",
    &sequences
);
```

## CLI Usage

### Basic File Detection

```bash
zig build run -- path/to/file.jpg
# Output: image/jpeg
```

### Benchmark Mode

Run the file type detection 500 times and measure performance:

```bash
zig build run --release=safe -- path/to/file.jpg --benchmark
# Output:
# [BENCHMARK] Completed 500 iterations
#   Total time: 45.23 ms
#   Average per run: 90.460 µs
```

## Building

```bash
# Build the library and CLI tool
zig build

# Build with optimizations
zig build --release=safe
zig build --release=fast

# Install to prefix
zig build --prefix /usr/local
```

## Testing

Run all tests (unit tests + benchmarks):

```bash
zig build test
```

Tests include:

- MIME type detection for common formats
- Custom magic number support
- Multi-sequence magic number handling
- Edge cases and unknown formats
- Performance benchmarks

## Supported Formats

Built-in support includes:

- **Images**: JPEG, PNG, GIF (87a/89a), WebP, BMP, TIFF
- **Documents**: PDF
- **Archives**: ZIP, RAR, 7-Zip
- **Audio**: MP3, WAV, FLAC, OGG
- **Video**: MP4, AVI, MKV
- **Other**: ELF binaries, and more

## API Reference

### `MagicNumberAnalyzer`

- `init(allocator: std.mem.Allocator) MagicNumberAnalyzer` - Initialize the analyzer
- `deinit()` - Free allocated resources
- `getMimeTypeFromFile(path: []const u8) ![]const u8` - Detect MIME type from file
- `getMimeTypeFromBytes(bytes: []const u8) []const u8` - Detect MIME type from byte slice
- `addCustomMagicNumber(magic: MagicNumber) !void` - Add a custom magic number

### `MagicNumber`

- `init(mime_type: []const u8, sequences: []const KnownByteSequence) MagicNumber` - Create a magic number definition

### `KnownByteSequence`

- `init(signature: []const u8, offset: usize) KnownByteSequence` - Create a byte sequence to match at a specific offset
