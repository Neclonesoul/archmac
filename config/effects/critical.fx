fx::sequence(&[
    fx::coalesce((170, QuadOut))
        .with_pattern(CheckerboardPattern::default()),
    fx::fade_to_fg(
        Color::White,
        (75, SineOut)
    ),
    fx::fade_to_fg(
        Color::Red,
        (120, SineIn)
    )
])
