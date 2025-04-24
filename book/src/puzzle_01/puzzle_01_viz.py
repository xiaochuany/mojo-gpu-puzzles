from manim import *

class Puzzle01Visualization(Scene):
    def construct(self):
        array_scale = 0.5
        thread_scale = 0.5

        input_array = VGroup()
        input_values = [1, 2, 3, 4]
        input_bg = Rectangle(
            width=array_scale * 4 + 0.6,
            height=array_scale + 0.6,
            stroke_color=BLUE_D,
            fill_color=BLUE_E,
            fill_opacity=0.2
        )
        for i, val in enumerate(input_values):
            cell = Square(side_length=array_scale, stroke_width=1)
            value_text = Text(f"{val}", font_size=20)
            index_text = Text(f"a[{i}]", font_size=16, color=BLUE).next_to(cell, DOWN, buff=0.1)
            cell.add(value_text, index_text)
            input_array.add(cell)
        input_array.arrange(RIGHT, buff=0)
        input_array.move_to(input_bg)
        input_group = VGroup(input_bg, input_array)
        input_label = Text("Input Array", font_size=24).next_to(input_group, UP)
        input_group = VGroup(input_label, input_group)

        thread_block = VGroup()
        for i in range(4):
            cell = RoundedRectangle(width=1.2, height=1.4, corner_radius=0.2)
            thread_info = VGroup(
                Text(f"Thread {i}", font_size=18, color=WHITE),
                Text(f"local_i = {i}", font_size=16, color=YELLOW),
                Text("parallel", font_size=14, color=GREEN_A)
            ).arrange(DOWN, buff=0.15)
            cell.set_fill(DARK_GRAY, opacity=0.8)
            cell.add(thread_info)
            thread_block.add(cell)
        thread_block.arrange(RIGHT, buff=0.4)
        thread_label = Text("GPU Threads (Execute in Parallel)", font_size=24).next_to(thread_block, UP)
        thread_group = VGroup(thread_label, thread_block)

        output_array = VGroup()
        output_bg = Rectangle(
            width=array_scale * 4 + 0.8,
            height=array_scale + 0.8,
            stroke_color=GREEN_D,
            fill_color=GREEN_E,
            fill_opacity=0.2
        )
        for i, val in enumerate(input_values):
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

        full_group = VGroup(input_group, thread_group, output_group).arrange(DOWN, buff=0.8)
        full_group.move_to(ORIGIN).shift(UP * 0.8)
        full_group.scale(0.8)

        self.play(Write(input_label))
        self.play(
            Create(input_bg),
            Create(input_array),
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

        arrows = VGroup()
        for i in range(4):
            start = input_array[i].get_bottom() + DOWN * 0.2
            end = thread_block[i].get_top() + UP * 0.2
            arrow1 = Arrow(start, end, buff=0.1, color=BLUE)

            start = thread_block[i].get_bottom() + DOWN * 0.2
            end = output_array[i].get_top() + UP * 0.2
            arrow2 = Arrow(start, end, buff=0.1, color=GREEN)

            arrows.add(arrow1, arrow2)

        # Change Create to FadeIn for instant appearance
        self.play(FadeIn(arrows), run_time=0.3)

        notes = VGroup(
            Text("• Each thread processes one array element independently", font_size=18),
            Text("• All threads execute the same operation in parallel", font_size=18),
            Text("• Perfect for data-parallel operations like array transformations", font_size=18)
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
        "output_file": "puzzle_01_viz"
    }):
        scene = Puzzle01Visualization()
        scene.render()
