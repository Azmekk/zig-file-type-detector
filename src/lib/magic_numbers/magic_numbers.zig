/// Represents a known byte sequence with a byte array and a starting offset.
pub const KnownByteSequence = struct {
    /// The byte array of the known sequence.
    byte_arr: []const u8,
    /// The starting offset of the known sequence.
    start_offset: i32,

    /// Initializes a new instance of KnownByteSequence with the specified byte array and starting offset.
    ///
    /// Arguments:
    ///   - `byte_arr`: The byte array of the known sequence.
    ///   - `start_offset`: The starting offset of the known sequence.
    pub fn init(byte_arr: []const u8, start_offset: i32) KnownByteSequence {
        return .{
            .byte_arr = byte_arr,
            .start_offset = start_offset,
        };
    }
};

/// Represents a magic number with information about the associated MIME type and known byte sequences in a file.
pub const MagicNumber = struct {
    /// The string name representing the MIME type associated with the magic number.
    mime_type: []const u8,
    /// An array of known byte sequences in the file associated with the magic number.
    /// Each sequence is defined by a KnownByteSequence.
    known_byte_sequences: []const KnownByteSequence,

    /// Initializes a new instance of MagicNumber with the specified MIME type and known byte sequences.
    ///
    /// Arguments:
    ///   - `mime_type`: The string name representing the MIME type.
    ///   - `known_byte_sequences`: An array of known byte sequences in the file.
    pub fn init(mime_type: []const u8, known_byte_sequences: []const KnownByteSequence) MagicNumber {
        return .{
            .mime_type = mime_type,
            .known_byte_sequences = known_byte_sequences,
        };
    }
};
