const std = @import("std");

fn less_than(_: void, a: []const u8, b: []const u8) bool {
  return std.mem.lessThan(u8, a, b);
}

pub fn main(init: std.process.Init) !void {
  const stdout = std.Io.File.stdout();
  const stdin = std.Io.File.stdin();

  var out_buffer: [4096]u8 = undefined;
  var file_writer = std.Io.File.writer(stdout, init.io, &out_buffer);
  const output = &file_writer.interface;

  var in_buffer: [4096]u8 = undefined;
  var file_reader = std.Io.File.reader(stdin, init.io, &in_buffer);
  const input = &file_reader.interface;

  var lines: std.ArrayList([]const u8) = .empty;

  defer {
    for (lines.items) |line| {
      init.gpa.free(line);
    }
    lines.deinit(init.gpa);
  }
  
  while (try input.takeDelimiter('\n')) |line| {
    const owned = try init.gpa.dupe(u8, line);
    try lines.append(init.gpa, owned);
  }

  std.mem.sort([]const u8, lines.items, {}, less_than);

  for (lines.items) |line| {
    try output.print("{s}\n", .{line});
  }

  try output.flush();
}