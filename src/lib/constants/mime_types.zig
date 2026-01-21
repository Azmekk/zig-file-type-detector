/// MIME type constants for various file formats.
/// These constants define the standard MIME types used throughout the file type detection system.
pub const MimeTypes = struct {
    /// Image MIME types
    pub const jpeg = "image/jpeg";
    pub const png = "image/png";
    pub const bmp = "image/bmp";
    pub const gif = "image/gif";
    pub const icon = "image/x-icon";
    pub const svg = "image/svg+xml";
    pub const tiff = "image/tiff";
    pub const webp = "image/webp";
    pub const avif = "image/avif";
    pub const heic = "image/heic";
    pub const heif = "image/heif";
    pub const jxl = "image/jxl";

    /// Application MIME types
    pub const pdf = "application/pdf";
    pub const zip = "application/zip";
    pub const rar = "application/x-rar-compressed";
    pub const seven_zip = "application/x-7z-compressed";
    pub const gzip = "application/gzip";
    pub const bzip2 = "application/x-bzip2";
    pub const xz = "application/x-xz";
    pub const exe = "application/x-msdownload";
    pub const elf = "application/x-executable";
    pub const mach_binary = "application/x-mach-binary";
    pub const sqlite = "application/x-sqlite3";
    pub const wasm = "application/wasm";
    pub const tar = "application/x-tar";

    /// Audio MIME types
    pub const mp3 = "audio/mpeg";
    pub const wav = "audio/wav";
    pub const flac = "audio/flac";
    pub const ogg = "audio/ogg";
    pub const midi = "audio/midi";
    pub const aiff = "audio/aiff";

    /// Video MIME types
    pub const mp4 = "video/mp4";
    pub const mov = "video/quicktime";
    pub const avi = "video/x-msvideo";
    pub const webm = "video/webm";
    pub const flv = "video/x-flv";
    pub const m4v = "video/mp4";

    /// Font MIME types
    pub const ttf = "font/ttf";
    pub const otf = "font/otf";
    pub const woff = "font/woff";
    pub const woff2 = "font/woff2";
};
