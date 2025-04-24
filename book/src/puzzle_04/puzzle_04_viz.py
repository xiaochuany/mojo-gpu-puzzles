from manim import *

class Puzzle04Visualization(Scene):
    def construct(self):
        array_scale = 0.8
        thread_scale = 0.5

        # Input 2D matrix (2x2) - positioned on the left
        input_matrix = VGroup()
        input_bg = Rectangle(
            width=array_scale * 2 + 1.0,
            height=array_scale * 2 + 1.0,
            stroke_color=BLUE_D,
            fill_color=BLUE_E,
            fill_opacity=0.2
        ).shift(LEFT * 5)

        for j in range(2):
            for i in range(2):
                cell = Square(side_length=array_scale, stroke_width=1)
                index_text = Text(f"a[{j}][{i}]", font_size=14, color=YELLOW)
                cell.add(index_text)
                input_matrix.add(cell)
        input_matrix.arrange_in_grid(rows=2, cols=2, buff=0)  # No gaps
        input_matrix.move_to(input_bg)
        input_group = VGroup(input_bg, input_matrix)
        input_label = Text("Input Matrix (2×2)", font_size=24).next_to(input_group, UP)
        input_group = VGroup(input_label, input_group)

        # Thread block (3x3) - positioned in center
        thread_block = VGroup()
        for j in range(3):
            for i in range(3):
                cell = RoundedRectangle(
                    width=1.4,
                    height=1.6,
                    corner_radius=0.2
                )
                thread_text = Text(
                    f"Thread ({j},{i})",
                    font_size=16,
                    color=GREEN_A if (i < 2 and j < 2) else RED
                )
                cell.set_fill(DARK_GRAY, opacity=0.8)
                cell.add(thread_text)
                thread_block.add(cell)
        thread_block.arrange_in_grid(rows=3, cols=3, buff=0.4)  # Keep small gap for readability
        thread_label = Text("GPU Threads (3×3 > 2×2 elements!)", font_size=24).next_to(thread_block, UP)
        thread_group = VGroup(thread_label, thread_block).move_to(ORIGIN)

        # Output matrix - positioned on the right
        output_matrix = VGroup()
        output_bg = Rectangle(
            width=array_scale * 2 + 1.0,
            height=array_scale * 2 + 1.0,
            stroke_color=GREEN_D,
            fill_color=GREEN_E,
            fill_opacity=0.2
        ).shift(RIGHT * 5)

        for j in range(2):
            for i in range(2):
                cell = Square(side_length=array_scale, stroke_width=1)
                index_text = Text(f"out[{j}][{i}]", font_size=14, color=YELLOW)
                cell.add(index_text)
                output_matrix.add(cell)
        output_matrix.arrange_in_grid(rows=2, cols=2, buff=0)  # No gaps
        output_matrix.move_to(output_bg)
        output_group = VGroup(output_bg, output_matrix)
        output_label = Text("Output Matrix (2×2)", font_size=24).next_to(output_group, UP)
        output_group = VGroup(output_label, output_group)

        # Animations
        self.play(Write(input_label))
        self.play(Create(input_bg), Create(input_matrix), run_time=1.5)

        self.play(Write(thread_label))
        self.play(Create(thread_block), run_time=1.5)

        self.play(Write(output_label))
        self.play(Create(output_bg), Create(output_matrix), run_time=1.5)

        # Create arrows flowing left to right
        arrows = VGroup()
        for j in range(3):
            for i in range(3):
                if i < 2 and j < 2:  # Only create arrows for valid threads
                    # Arrow from input to thread
                    start = input_matrix[j * 2 + i].get_right()
                    end = thread_block[j * 3 + i].get_left()
                    arrow1 = Arrow(
                        start, end,
                        buff=0.1,
                        color=BLUE_C,  # Lighter blue
                        stroke_width=2,  # Thinner line
                        max_tip_length_to_length_ratio=0.2  # Smaller arrow tip
                    ).set_opacity(0.6)  # Set opacity after creation

                    # Arrow from thread to output
                    start = thread_block[j * 3 + i].get_right()
                    end = output_matrix[j * 2 + i].get_left()
                    arrow2 = Arrow(
                        start, end,
                        buff=0.1,
                        color=GREEN_C,  # Lighter green
                        stroke_width=2,  # Thinner line
                        max_tip_length_to_length_ratio=0.2  # Smaller arrow tip
                    ).set_opacity(0.6)  # Set opacity after creation

                    arrows.add(arrow1, arrow2)
                else:
                    # Make X marks more subtle too
                    warning = Text("×", font_size=24, color=RED_C).set_opacity(0.7)
                    warning.move_to(thread_block[j * 3 + i])
                    arrows.add(warning)

        self.play(FadeIn(arrows), run_time=0.3)
        self.wait(4)

if __name__ == "__main__":
    with tempconfig({
        "preview": True,
        "format": "gif",
        "media_dir": "./media",
        "quality": "medium_quality",
        "output_file": "puzzle_04_viz"
    }):
        scene = Puzzle04Visualization()
        scene.render()
