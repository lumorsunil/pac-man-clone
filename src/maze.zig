const rl = @import("raylib");

pub const Maze = struct {
    pub const sheet_grid_offset = rl.Vector2.init(745, 187);
    pub const cell_size = 8;
    const spacing = 1;

    pub fn source(grid_coord: rl.Vector2) rl.Rectangle {
        const cell_factor = cell_size + spacing;
        return .init(
            grid_coord.x * cell_factor + sheet_grid_offset.x,
            grid_coord.y * cell_factor + sheet_grid_offset.y,
            cell_size,
            cell_size,
        );
    }

    pub const wall_top_left = source(.init(0, 0));
    pub const wall_top = source(.init(1, 0));
    pub const wall_top_right = source(.init(2, 0));
    pub const wall_left = source(.init(0, 1));
    pub const tile_empty = source(.init(1, 1));
    pub const wall_right = source(.init(2, 1));
    pub const wall_bottom_left = source(.init(0, 2));
    pub const wall_bottom = source(.init(1, 2));
    pub const wall_bottom_right = source(.init(2, 2));

    pub const prison_top_left = source(.init(3, 0));
    pub const prison_top = source(.init(4, 0));
    pub const prison_top_right = source(.init(5, 0));
    pub const prison_left = source(.init(3, 1));
    pub const prison_right = source(.init(5, 1));
    pub const prison_bottom_left = source(.init(3, 2));
    pub const prison_bottom = source(.init(4, 2));
    pub const prison_bottom_right = source(.init(5, 2));

    pub const thin_wall_top_left = source(.init(0, 3));
    pub const thin_wall_top_left_2 = source(.init(2, 5));
    pub const thin_wall_top_right = source(.init(3, 3));
    pub const thin_wall_bottom_left = source(.init(0, 6));
    pub const thin_wall_bottom_right = source(.init(3, 6));
    pub const thin_wall_vertical_left = prison_right;
    pub const thin_wall_vertical_right = prison_left;
    pub const thin_wall_horizontal_top = prison_top;
    pub const thin_wall_horizontal_bottom = prison_bottom;
    pub const thin_wall_center_top_left = source(.init(1, 3));
    pub const thin_wall_center_top_right = source(.init(2, 3));
    pub const thin_wall_center_left_top = source(.init(0, 4));
    pub const thin_wall_center_left_bottom = source(.init(0, 5));
    pub const thin_wall_center_right_top = source(.init(3, 4));
    pub const thin_wall_center_right_bottom = source(.init(3, 5));

    pub const maze_width = 28;
    pub const maze_height = 36;

    fn mapCharToTile(comptime char: u8) rl.Rectangle {
        return switch (char) {
            '.', ' ' => tile_empty,
            'L' => wall_bottom_left,
            '-' => wall_top,
            '_' => wall_bottom,
            '<' => wall_left,
            '>' => wall_right,
            'J' => wall_bottom_right,
            '"' => wall_top_right,
            '/' => wall_top_left,
            '+' => thin_wall_top_left,
            '*' => thin_wall_top_left_2,
            '~' => thin_wall_top_right,
            'c' => thin_wall_bottom_left,
            'j' => thin_wall_bottom_right,
            '|' => thin_wall_vertical_left,
            'l' => thin_wall_vertical_right,
            'v' => thin_wall_horizontal_top,
            '^' => thin_wall_horizontal_bottom,
            ',' => thin_wall_center_top_left,
            'x' => thin_wall_center_top_right,
            'm' => thin_wall_center_left_top,
            'M' => thin_wall_center_left_bottom,
            'h' => thin_wall_center_right_top,
            'H' => thin_wall_center_right_bottom,
            'o' => prison_top_left,
            'O' => prison_top_right,
            'k' => prison_bottom_left,
            'd' => prison_bottom_right,
            else => {
                const err_char: []const u8 = &.{char};
                @compileError("invalid tile char '" ++ err_char ++ "'");
            },
        };
    }

    const maze_layout_string =
        \\                            
        \\                            
        \\                            
        \\+^^^^^^^^^^^^,x^^^^^^^^^^^^~
        \\|............<>............l
        \\|./--"./---".<>./---"./--".l
        \\|.<  >.<   >.<>.<   >.<  >.l
        \\|.L__J.L___J.LJ.L___J.L__J.l
        \\|..........................l
        \\|./--"./"./------"./"./--".l
        \\|.L__J.<>.L__"/__J.<>.L__J.l
        \\|......<>....<>....<>......l
        \\cvvvv".<L--".<>./--J>./vvvvj
        \\     |.</__J.LJ.L__">.l     
        \\     |.<>..........<>.l     
        \\     |.<>.ovvvvvvO.<>.l     
        \\^^^^^J.LJ.l      |.LJ.L^^^^^
        \\..........l      |..........
        \\vvvvv"./".l      |./"./vvvvv
        \\     |.<>.k^^^^^^d.<>.l     
        \\     |.<>..........<>.l     
        \\     |.<>./------".<>.l     
        \\+^^^^J.LJ.L__"/__J.LJ.L^^^^~
        \\|............<>............l
        \\|./--"./---".<>./---"./--".l
        \\|.L_">.L___J.LJ.L___J.</_J.l
        \\|...<>................<>...l
        \\m-".<>./"./------"./".<>./-h
        \\M_J.LJ.<>.L__"/__J.<>.LJ.L_H
        \\|......<>....<>....<>......l
        \\|./----JL--".<>./--JL----".l
        \\|.L________J.LJ.L________J.l
        \\|..........................l
        \\cvvvvvvvvvvvvvvvvvvvvvvvvvvj
        \\                            
        \\                            
    ;

    pub const maze_layout: []const rl.Rectangle = brk: {
        var result: []const rl.Rectangle = &.{};

        @setEvalBranchQuota(10000);

        for (maze_layout_string) |char| {
            if (char == '\n') {
                continue;
            }

            const tile: []const rl.Rectangle = &.{mapCharToTile(char)};
            result = result ++ tile;
        }

        break :brk result;
    };
};
