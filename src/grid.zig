const std = @import("std");
const Allocator = std.mem.Allocator;
const Game = @import("game.zig").Game;
const ecs = @import("ecs");
const Maze = @import("maze.zig").Maze;
const rl = @import("raylib");

const Grid = struct {
    data: []Cell,
    width: usize,
    height: usize,

    pub const Cell = struct {
        is_solid: bool = false,
    };

    pub const Axis = enum { x, y };

    pub fn init(allocator: Allocator, width: usize, height: usize) !@This() {
        return .{
            .data = try allocator.alloc(Cell, width * height),
            .width = width,
            .height = height,
        };
    }

    pub const CollisionEvent = union(enum) {
        pellet: ecs.Entity,
        ghost: ecs.Entity,
    };

    pub fn resolveCollisions(self: *Grid, game: *Game, comptime axis: Axis) CollisionEvent {
        var it = game.entityIterator(.{ Game.C.Body, Game.C.Renderable }, .{});

        while (it.next()) |ctx| {
            const hitbox = game.hitbox(ctx);
            const hitbox_min = Game.Vector.init(hitbox.x, hitbox.y);
            const hitbox_max = hitbox_min.add(.init(hitbox.width, hitbox.height));
            var min_grid_pos = hitbox_min.scale(1.0 / Maze.cell_size);
            min_grid_pos.x = @floor(min_grid_pos.x);
            min_grid_pos.y = @floor(min_grid_pos.y);
            var max_grid_pos = hitbox_max.scale(1.0 / Maze.cell_size);
            max_grid_pos.x = @ceil(max_grid_pos.x);
            max_grid_pos.y = @ceil(max_grid_pos.y);

            for (min_grid_pos.x..max_grid_pos.x) |x| {
                for (min_grid_pos.y..max_grid_pos.y) |y| {
                    const cell = self.data[x + y * self.width];
                    if (!cell.is_solid) continue;

                    const cell_hitbox = rl.Rectangle.init(
                        x * Maze.cell_size,
                        y * Maze.cell_size,
                        Maze.cell_size,
                        Maze.cell_size,
                    );

                    if (rl.checkCollisionsRecs(hitbox, cell_hitbox)) {
                        const body = ctx.get(Game.C.Body);

                        if (axis == .x) {
                            const d_left = hitbox.x - (cell_hitbox.x + cell_hitbox.width);
                            const d_right = hitbox.x + hitbox.width - cell_hitbox.x;

                            if (@abs(d_left) < @abs(d_right)) {
                                body.position.x += -d_left;
                            } else {
                                body.position.x -= -d_right;
                            }
                        } else {
                            const d_top = hitbox.y - (cell_hitbox.y + cell_hitbox.height);
                            const d_bottom = hitbox.y + hitbox.height - cell_hitbox.y;

                            if (@abs(d_top) < @abs(d_bottom)) {
                                body.position.y += -d_top;
                            } else {
                                body.position.y -= -d_bottom;
                            }
                        }
                    }
                }
            }
        }
    }
};
