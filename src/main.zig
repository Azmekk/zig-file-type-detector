const std = @import("std");
const zig_file_type_detector = @import("zig_file_type_detector");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: zig-file-type-detector <file_path> [--benchmark]\n", .{});
        return;
    }

    const filepath = args[1];
    const is_benchmark = args.len > 2 and std.mem.eql(u8, args[2], "--benchmark");

    var analyzer = zig_file_type_detector.MagicNumberAnalyzer.init(allocator);
    defer analyzer.deinit();

    if (is_benchmark) {
        var timer = try std.time.Timer.start();
        const iterations = 500;

        var i: usize = 0;
        while (i < iterations) : (i += 1) {
            const mime_type = analyzer.getMimeTypeFromFile(filepath) catch |err| {
                std.debug.print("Error reading file: {}\n", .{err});
                return;
            };
            _ = mime_type;
        }

        const elapsed = timer.read();
        const avg_per_run = elapsed / iterations;

        std.debug.print("[BENCHMARK] Completed {} iterations\n", .{iterations});
        std.debug.print("  Total time: {d:.2} ms\n", .{@as(f64, @floatFromInt(elapsed)) / 1_000_000.0});
        std.debug.print(
            "  Average per run: {d:.3} microseconds\n",
            .{@as(f64, @floatFromInt(avg_per_run)) / 1_000.0},
        );
    } else {
        const mime_type = analyzer.getMimeTypeFromFile(filepath) catch |err| {
            std.debug.print("Error reading file: {}\n", .{err});
            return;
        };

        std.debug.print("{s}\n", .{mime_type});
    }
}
