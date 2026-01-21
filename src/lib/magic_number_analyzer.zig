const std = @import("std");
const MagicNumber = @import("file_type_helper.zig").MagicNumber;
const KnownByteSequence = @import("file_type_helper.zig").KnownByteSequence;

/// Analyzer for detecting file MIME types based on magic numbers (file signatures).
pub const MagicNumberAnalyzer = struct {
    /// Predefined known magic numbers for analysis.
    const known_magic_numbers = @import("file_type_helper.zig").magic_numbers;

    /// Custom magic numbers that can be added for analysis.
    _custom_magic_numbers: []MagicNumber,

    /// The maximum number of bytes to read from the file for analysis.
    byte_limit: usize = 256,

    /// Allocator for managing dynamic memory.
    allocator: std.mem.Allocator,

    /// Initializes a new MagicNumberAnalyzer with the specified allocator.
    pub fn init(allocator: std.mem.Allocator) MagicNumberAnalyzer {
        return .{
            .allocator = allocator,
            ._custom_magic_numbers = &[_]MagicNumber{},
        };
    }

    /// Scans a file for predefined magic numbers to identify file types.
    /// Returns the detected MIME type or "application/octet-stream" if no match is found.
    pub fn getMimeTypeFromFile(self: *MagicNumberAnalyzer, filepath: []const u8) ![]const u8 {
        const file = try std.fs.cwd().openFile(filepath, .{});
        defer file.close();

        var buffer: [256]u8 = undefined;
        _ = try file.read(&buffer);

        return self.determineMimeType(&buffer);
    }

    /// Scans a byte array for known magic numbers.
    /// Returns the detected MIME type or "application/octet-stream" if no match is found.
    pub fn getMimeTypeFromBytes(self: *MagicNumberAnalyzer, bytes: []const u8) []const u8 {
        return self.determineMimeType(bytes);
    }

    /// Internal function to determine MIME type from byte data.
    fn determineMimeType(self: *MagicNumberAnalyzer, bytes: []const u8) []const u8 {
        // Check custom magic numbers first
        if (self.matchBytesToMagicNumbers(self._custom_magic_numbers, bytes)) |mime_type| {
            return mime_type;
        }

        // Check predefined magic numbers
        if (self.matchBytesToMagicNumbers(&known_magic_numbers, bytes)) |mime_type| {
            return mime_type;
        }

        return "application/octet-stream";
    }

    /// Matches bytes against a list of magic numbers.
    /// Returns the MIME type if a match is found, null otherwise.
    fn matchBytesToMagicNumbers(
        self: *MagicNumberAnalyzer,
        magic_numbers: []const MagicNumber,
        bytes: []const u8,
    ) ?[]const u8 {
        for (magic_numbers) |magic_number| {
            if (self.allSequencesMatch(magic_number, bytes)) {
                return magic_number.mime_type;
            }
        }
        return null;
    }

    /// Checks if all byte sequences in a magic number match the provided bytes.
    fn allSequencesMatch(
        self: *MagicNumberAnalyzer,
        magic_number: MagicNumber,
        bytes: []const u8,
    ) bool {
        for (magic_number.known_byte_sequences) |sequence| {
            const start = @as(usize, @intCast(sequence.start_offset));

            if (start + sequence.byte_arr.len > bytes.len) {
                return false;
            }

            if (!self.compareBytes(bytes, sequence.byte_arr, start)) {
                return false;
            }
        }
        return true;
    }

    /// Compares two byte sequences at a specified offset.
    fn compareBytes(
        self: *MagicNumberAnalyzer,
        buffer: []const u8,
        pattern: []const u8,
        offset: usize,
    ) bool {
        _ = self;
        return std.mem.eql(u8, buffer[offset .. offset + pattern.len], pattern);
    }

    /// Adds a custom magic number to the analysis list.
    pub fn addCustomMagicNumber(self: *MagicNumberAnalyzer, magic_number: MagicNumber) !void {
        var new_list = try self.allocator.alloc(MagicNumber, self._custom_magic_numbers.len + 1);
        @memcpy(new_list[0..self._custom_magic_numbers.len], self._custom_magic_numbers);
        new_list[self._custom_magic_numbers.len] = magic_number;

        if (self._custom_magic_numbers.len > 0) {
            self.allocator.free(self._custom_magic_numbers);
        }
        self._custom_magic_numbers = new_list;
    }

    /// Adds multiple custom magic numbers to the analysis list.
    pub fn addCustomMagicNumbersRange(self: *MagicNumberAnalyzer, magic_numbers: []const MagicNumber) !void {
        const new_len = self._custom_magic_numbers.len + magic_numbers.len;
        var new_list = try self.allocator.alloc(MagicNumber, new_len);
        @memcpy(new_list[0..self._custom_magic_numbers.len], self._custom_magic_numbers);
        @memcpy(new_list[self._custom_magic_numbers.len..], magic_numbers);

        if (self._custom_magic_numbers.len > 0) {
            self.allocator.free(self._custom_magic_numbers);
        }
        self._custom_magic_numbers = new_list;
    }

    /// Cleans up resources used by the analyzer.
    pub fn deinit(self: *MagicNumberAnalyzer) void {
        if (self._custom_magic_numbers.len > 0) {
            self.allocator.free(self._custom_magic_numbers);
        }
    }
};
