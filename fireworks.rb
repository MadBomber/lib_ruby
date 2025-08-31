# ~/lib/ruby/fireworks.rb
# A spectacular fireworks display on the console

def fireworks(how_many = 7, simultaneous = false)
  # Get terminal size dynamically
  require "io/console"
  height, width = IO.console.winsize
  width -= 5
  height -= 1  # Leave room for prompt

  # ANSI color codes
  colors = [
    "\e[91m",  # bright red
    "\e[92m",  # bright green
    "\e[93m",  # bright yellow
    "\e[94m",  # bright blue
    "\e[95m",  # bright magenta
    "\e[96m",  # bright cyan
    "\e[97m",  # bright white
  ]
  reset_color = "\e[0m"

  # Different explosion patterns
  explosion_types = [
    # Standard burst
    -> (size, x, y, canvas, color, frame, max_frames) {
      chars = ["✦", "✧", "★", "☆", "✨", "✺", "✹", "✸", "*", "+", "·"]
      density = 0.8 * (1.0 - frame.to_f / max_frames)

      (-size..size).each do |dy|
        (-size..size).each do |dx|
          distance = Math.sqrt(dx * dx + dy * dy)
          if distance <= size && y + dy >= 0 && y + dy < height &&
             x + dx >= 0 && x + dx < width && rand < density
            canvas[y + dy][x + dx] = color + chars.sample + reset_color
          end
        end
      end
    },
    # Ring explosion
    -> (size, x, y, canvas, color, frame, max_frames) {
      chars = ["◯", "○", "◉", "◈", "◊", "◇", "◆"]
      ring_size = (size * frame.to_f / max_frames * 2).to_i

      (-ring_size..ring_size).each do |dy|
        (-ring_size..ring_size).each do |dx|
          distance = Math.sqrt(dx * dx + dy * dy)
          if distance >= ring_size - 1 && distance <= ring_size + 1 &&
             y + dy >= 0 && y + dy < height && x + dx >= 0 && x + dx < width
            canvas[y + dy][x + dx] = color + chars.sample + reset_color
          end
        end
      end
    },
    # Cascading sparks
    -> (size, x, y, canvas, color, frame, max_frames) {
      chars = ["｡", "･", ".", "˚", "✧", "✦"]
      spark_fall = (frame * 2).to_i

      (-size..size).each do |dx|
        base_y = y + spark_fall
        spread = (size - dx.abs) * frame / max_frames

        (0..spread).each do |dy|
          if base_y + dy >= 0 && base_y + dy < height &&
             x + dx >= 0 && x + dx < width && rand < 0.6
            canvas[base_y + dy][x + dx] = color + chars.sample + reset_color
          end
        end
      end
    },
    # Double burst
    -> (size, x, y, canvas, color, frame, max_frames) {
      chars = ["✺", "✹", "✸", "✷", "✶", "✵", "*"]
      density = 0.7 * (1.0 - frame.to_f / max_frames)

      # First burst
      inner_size = size / 2
      outer_size = size

      [inner_size, outer_size].each_with_index do |burst_size, i|
        (-burst_size..burst_size).each do |dy|
          (-burst_size..burst_size).each do |dx|
            distance = Math.sqrt(dx * dx + dy * dy)
            if distance <= burst_size && distance >= burst_size - 2 &&
               y + dy >= 0 && y + dy < height && x + dx >= 0 && x + dx < width &&
               rand < density
              canvas[y + dy][x + dx] = color + chars[i * 3 + frame % 3] + reset_color
            end
          end
        end
      end
    }
  ]

  if simultaneous
    # Launch fireworks in groups of 1-3 at a time
    firework_data = []
    total_launched = 0
    delay_offset = 0

    while total_launched < how_many
      # Launch 1-3 fireworks simultaneously
      group_size = [rand(1..3), how_many - total_launched].min

      group_size.times do
        firework_data << {
          x: rand(10..width - 10),
          launch_height: rand(5..height - 5),
          color: colors.sample,
          size: rand(4..7),
          explosion_type: explosion_types.sample,
          launch_delay: delay_offset + rand(0..2),
          trail: []
        }
        total_launched += 1
      end

      # Add delay before next group
      delay_offset += rand(15..25)
    end

    # Animation loop for simultaneous fireworks
    max_frames = delay_offset + 60  # Ensure we have enough frames for all groups
    canvas = Array.new(height) { Array.new(width, " ") }

    max_frames.times do |frame|
      # Clear canvas
      canvas = Array.new(height) { Array.new(width, " ") }

      firework_data.each do |fw|
        next if frame < fw[:launch_delay]

        adjusted_frame = frame - fw[:launch_delay]

        if adjusted_frame < 20
          # Launch phase
          launch_y = height - 1 - (adjusted_frame * (height - 1 - fw[:launch_height]) / 20)
          if launch_y >= 0 && launch_y < height
            # Add to trail
            fw[:trail] << [fw[:x], launch_y.to_i]
            fw[:trail] = fw[:trail].last(5)  # Keep last 5 positions

            # Draw trail
            fw[:trail].each_with_index do |(tx, ty), i|
              if ty >= 0 && ty < height && tx >= 0 && tx < width
                trail_char = i == fw[:trail].length - 1 ? "▲" : "|"
                opacity = i == fw[:trail].length - 1 ? fw[:color] : "\e[90m"
                canvas[ty][tx] = opacity + trail_char + reset_color
              end
            end
          end
        elsif adjusted_frame < 40
          # Explosion phase
          explosion_frame = adjusted_frame - 20
          fw[:explosion_type].call(fw[:size], fw[:x], fw[:launch_height], canvas,
                                   fw[:color], explosion_frame, 20)
        end
      end

      # Add random stars in background
      if frame % 3 == 0
        3.times do
          star_x = rand(0...width)
          star_y = rand(0...height/3)
          canvas[star_y][star_x] = "\e[90m·\e[0m" if canvas[star_y][star_x] == " "
        end
      end

      canvas.each { |row| puts row.join("") }
      sleep 0.05
    end
  else
    # Sequential fireworks (original style but enhanced)
    canvas = Array.new(height) { Array.new(width, " ") }

    how_many.times do |i|
      # Create a new firework at random position
      x = rand(10..width - 10)
      y = height - 1
      color = colors.sample
      explosion_type = explosion_types.sample

      # Launch the firework upward with trail effect
      launch_height = rand(5..height - 5)
      trail_positions = []

      (y).downto(launch_height) do |py|
        # Add current position to trail
        trail_positions << py
        trail_positions = trail_positions.last(4)  # Keep last 4 positions

        # Clear old trails
        trail_positions.each { |ty| canvas[ty][x] = " " if ty != py }

        # Draw trail with fading effect
        trail_positions.each_with_index do |ty, idx|
          if idx == trail_positions.length - 1
            canvas[ty][x] = color + "▲" + reset_color
          else
            opacity = "\e[90m"  # dim
            canvas[ty][x] = opacity + "|" + reset_color
          end
        end

        # Add twinkle stars occasionally
        if rand < 0.1
          star_x = rand(0...width)
          star_y = rand(0...height/3)
          canvas[star_y][star_x] = "\e[90m·\e[0m"
        end

        canvas.each { |row| puts row.join("") }
        sleep 0.03
      end

      # Clear the trail
      trail_positions.each { |ty| canvas[ty][x] = " " }

      # Sound effect text
      sound_x = [0, x - 4].max
      sound_y = [0, launch_height - 2].max
      if sound_y >= 0 && sound_y < height && sound_x >= 0 && sound_x + 5 < width
        "BOOM!".chars.each_with_index do |char, idx|
          canvas[sound_y][sound_x + idx] = "\e[93m#{char}\e[0m"
        end
      end

      # system("clear") || system("cls")
      canvas.each { |row| puts row.join("") }
      sleep 0.1

      # Clear sound effect
      if sound_y >= 0 && sound_y < height && sound_x >= 0 && sound_x + 5 < width
        5.times { |idx| canvas[sound_y][sound_x + idx] = " " }
      end

      # Explosion with selected pattern
      size = rand(5..8)
      fade_frames = 15

      fade_frames.times do |t|
        # Clear previous explosion frame
        (-size*2..size*2).each do |dy|
          (-size*2..size*2).each do |dx|
            if launch_height + dy >= 0 && launch_height + dy < height &&
               x + dx >= 0 && x + dx < width
              canvas[launch_height + dy][x + dx] = " "
            end
          end
        end

        # Draw explosion frame
        explosion_type.call(size, x, launch_height, canvas, color, t, fade_frames)

        canvas.each { |row| puts row.join("") }
        sleep 0.08
      end

      # Clear explosion area after fade complete
      (-size*2..size*2).each do |dy|
        (-size*2..size*2).each do |dx|
          if launch_height + dy >= 0 && launch_height + dy < height &&
             x + dx >= 0 && x + dx < width
            canvas[launch_height + dy][x + dx] = " "
          end
        end
      end
    end
  end

  # Clear terminal after all fireworks complete
  canvas.each { |row| puts row.join("") }
  sleep 0.08
end

def grand_finale
  # Spectacular ending with many simultaneous fireworks
  sleep 1
  fireworks(60, true)
end

def fireworks_show(duration = 60)
  # Run fireworks for approximately the specified duration in seconds
  count = (duration / 3).to_i
  fireworks(count, false)
  grand_finale
end
