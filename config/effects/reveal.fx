fx::parallel(&[
    fx::coalesce((500, QuadOut)),
    fx::fade_from_fg(Color::DarkGray, (550, SineOut))
])
