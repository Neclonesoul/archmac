fx::sequence(&[
    fx::coalesce((250, QuadOut))
        .with_pattern(DiagonalPattern::top_left_to_bottom_right()),
    fx::sequence(&[
        fx::fade_to_fg(
            Color::White,
            (80, SineOut)
        ),
        fx::fade_to_fg(
            Color::Yellow,
            (170, SineInOut)
        )
    ])
])
