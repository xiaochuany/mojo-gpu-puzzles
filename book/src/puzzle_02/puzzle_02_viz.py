from manim import *

class Puzzle02Visualization(Scene):
    def construct(self):
        array_scale = 0.5
        thread_scale = 0.5

        # First input array (a)
        input_array_a = VGroup()
        input_values_a = [1, 2, 3, 4]
        input_bg_a = Rectangle(
            width=array_scale * 4 + 0.6,
            height=array_scale + 0.6,
            stroke_color=BLUE_D,
            fill_color=BLUE_E,
            fill_opacity=0.2
        )
        for i, val in enumerate(input_values_a):
            cell = Square(side_length=array_scale, stroke_width=1)
            value_text = Text(f"{val}", font_size=20)
            index_text = Text(f"a[{i}]", font_size=16, color=BLUE).next_to(cell, DOWN, buff=0.1)
            cell.add(value_text, index_text)
            input_array_a.add(cell)
        input_array_a.arrange(RIGHT, buff=0)
        input_array_a.move_to(input_bg_a)
        input_group_a = VGroup(input_bg_a, input_array_a)
        input_label_a = Text("Input Array A", font_size=24).next_to(input_group_a, UP)
        input_group_a = VGroup(input_label_a, input_group_a)

        # Second input array (b)
        input_array_b = VGroup()
        input_values_b = [1, 2, 3, 4]
        input_bg_b = Rectangle(
            width=array_scale * 4 + 0.6,
            height=array_scale + 0.6,
            stroke_color=RED_D,
            fill_color=RED_E,
            fill_opacity=0.2
        )
        for i, val in enumerate(input_values_b):
            cell = Square(side_length=array_scale, stroke_width=1)
            value_text = Text(f"{val}", font_size=20)
            index_text = Text(f"b[{i}]", font_size=16, color=RED).next_to(cell, DOWN, buff=0.1)
            cell.add(value_text, index_text)
            input_array_b.add(cell)
        input_array_b.arrange(RIGHT, buff=0)
        input_array_b.move_to(input_bg_b)
        input_group_b = VGroup(input_bg_b, input_array_b)
        input_label_b = Text("Input Array B", font_size=24).next_to(input_group_b, UP)
        input_group_b = VGroup(input_label_b, input_group_b)

        # Arrange input arrays side by side
        input_arrays = VGroup(input_group_a, input_group_b).arrange(RIGHT, buff=1.0)

        # Thread block
        thread_block = VGroup()
        for i in range(4):
            cell = RoundedRectangle(width=1.2, height=1.4, corner_radius=0.2)
            thread_info = VGroup(
                Text(f"Thread {i}", font_size=18, color=WHITE),
                Text(f"local_i = {i}", font_size=16, color=YELLOW),
                Text("a[i] + b[i]", font_size=14, color=GREEN_A)
            ).arrange(DOWN, buff=0.15)
            cell.set_fill(DARK_GRAY, opacity=0.8)
            cell.add(thread_info)
            thread_block.add(cell)
        thread_block.arrange(RIGHT, buff=0.4)
        thread_label = Text("GPU Threads (Execute in Parallel)", font_size=24).next_to(thread_block, UP)
        thread_group = VGroup(thread_label, thread_block)

        # Output array
        output_array = VGroup()
        output_bg = Rectangle(
            width=array_scale * 4 + 0.8,
            height=array_scale + 0.8,
            stroke_color=GREEN_D,
            fill_color=GREEN_E,
            fill_opacity=0.2
        )
        for i in range(4):
            cell = Square(side_length=array_scale, stroke_width=1)
            value_text = Text("?", font_size=20, color=RED)
            index_text = Text(f"out[{i}]", font_size=14, color=GREEN).next_to(cell, DOWN, buff=0.15)
            cell.add(value_text, index_text)
            output_array.add(cell)
        output_array.arrange(RIGHT, buff=0)
        output_array.move_to(output_bg)
        output_group = VGroup(output_bg, output_array)
        output_label = Text("Output Array", font_size=24).next_to(output_group, UP)
        output_group = VGroup(output_label, output_group)

        # Arrange all groups vertically
        full_group = VGroup(input_arrays, thread_group, output_group).arrange(DOWN, buff=0.8)
        full_group.move_to(ORIGIN).shift(UP * 0.8)
        full_group.scale(0.8)

        # Animations
        self.play(Write(input_label_a), Write(input_label_b))
        self.play(
            Create(input_bg_a),
            Create(input_array_a),
            Create(input_bg_b),
            Create(input_array_b),
            run_time=1.5
        )

        self.play(Write(thread_label))
        self.play(Create(thread_block), run_time=1.5)

        self.play(Write(output_label))
        self.play(
            Create(output_bg),
            Create(output_array),
            run_time=1.5
        )

        # Create all arrows simultaneously
        arrows = VGroup()
        for i in range(4):
            # Arrows from first input array
            start_a = input_array_a[i].get_bottom() + DOWN * 0.2
            end = thread_block[i].get_top() + UP * 0.2
            arrow_a = Arrow(start_a, end, buff=0.1, color=BLUE)

            # Arrows from second input array
            start_b = input_array_b[i].get_bottom() + DOWN * 0.2
            arrow_b = Arrow(start_b, end, buff=0.1, color=RED)

            # Arrows to output array
            start_out = thread_block[i].get_bottom() + DOWN * 0.2
            end_out = output_array[i].get_top() + UP * 0.2
            arrow_out = Arrow(start_out, end_out, buff=0.1, color=GREEN)

            arrows.add(arrow_a, arrow_b, arrow_out)

        self.play(FadeIn(arrows), run_time=0.3)

        notes = VGroup(
            Text("• Each thread adds elements from both arrays at position i", font_size=18),
            Text("• All threads execute in parallel", font_size=18),
            Text("• Perfect for element-wise operations on multiple arrays", font_size=18)
        ).arrange(DOWN, aligned_edge=LEFT, buff=0.08)
        notes.next_to(full_group, DOWN, buff=0.4)
        notes.scale(0.8)

        self.play(Write(notes), run_time=2)
        self.wait(2)

if __name__ == "__main__":
    with tempconfig({
        "preview": True,
        "format": "gif",
        "media_dir": "./media",
        "quality": "medium_quality",
        "output_file": "puzzle_02_viz"
    }):
        scene = Puzzle02Visualization()
        scene.render()
