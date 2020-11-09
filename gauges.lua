require 'cairo'

WHITE = 0xFFFFFF
LIGHTBLUE = 0xB0D9E8
GREEN = 0x00FF00
YELLOW = 0xFFFF00
RED = 0xFF0000

prev_cpu = 0
prev_ram = 0

function conky_main()
  if conky_window == nil then
      return
  end
  local cs = cairo_xlib_surface_create (conky_window.display,
                                       conky_window.drawable,
                                       conky_window.visual,
                                       conky_window.width,
                                       conky_window.height)
  cr = cairo_create (cs)
  cpu = tonumber(conky_parse('$cpu'))
  ram = tonumber(conky_parse('$memperc'))
  if cpu < prev_cpu then prev_cpu = prev_cpu - 1 end
  if cpu > prev_cpu then prev_cpu = prev_cpu + 1 end
  if ram < prev_ram then prev_ram = prev_ram - 1 end
  if ram > prev_ram then prev_ram = prev_ram + 1 end

  if cpu*2 < prev_cpu then prev_cpu = prev_cpu - 1 end
  if cpu/2 > prev_cpu then prev_cpu = prev_cpu + 1 end
  if ram*2 < prev_ram then prev_ram = prev_ram - 1 end
  if ram/2 > prev_ram then prev_ram = prev_ram + 1 end

  gauges = {
    {
      x = 70,
      y = 260,
      value = prev_cpu,
      danger_value = 90.0,
      max_value = 100,
      value_text = prev_cpu .. '%',
      label = 'CPU'
    },
    {
      x = 250,
      y = 260,
      value = prev_ram,
      danger_value = 90.0,
      max_value = 100,
      value_text = prev_ram .. '%',
      label = 'RAM'
    }
  }
  for _,g in ipairs(gauges) do
    gauge(cr, g)
  end
  cairo_destroy (cr)
  cairo_surface_destroy (cs)
  cr = nil
end

function colour(c, a)
	return ((c / 0x10000) % 0x100) / 255, ((c / 0x100) % 0x100) / 255,
			(c % 0x100) / 255, a
end

function deg_to_rad(d)
  return (d - 90) * (math.pi / 180)
end

function clamp_deg(d)
  while d>360 do d=d-360 end 
  while d<0 do d=d+360 end
  return d
end

function polar( cx, cy, deg, radius )
  rad = deg_to_rad(deg)
  x = (radius * math.cos(rad)) + cx
  y = (radius * math.sin(rad)) + cy
  return x, y
end

function arc( cr, start_angle, end_angle, x, y, radius )
  cairo_arc (cr, x, y, radius,
		deg_to_rad(start_angle), deg_to_rad(end_angle))
end

function gauge( cr, g )
  radius = 40
  start_angle = 220
  end_angle = 70
  range = end_angle - start_angle + 360
  danger_angle = clamp_deg(start_angle + ((g.danger_value / g.max_value ) * range))
  value_angle = start_angle + ((g.value / g.max_value ) * range)
  cairo_set_line_width (cr, 4)
  cairo_set_line_cap (cr, CAIRO_LINE_CAP_ROUND)
  cairo_set_source_rgba (cr, colour(WHITE,1))
  arc(cr, start_angle, danger_angle, g.x, g.y, radius )
  cairo_stroke (cr)
  cairo_set_source_rgba (cr, colour(RED,1))
  arc(cr, danger_angle, end_angle, g.x, g.y, radius )
  cairo_stroke (cr)
  cairo_set_line_width (cr, 3)
  cairo_set_source_rgba (cr, colour(GREEN,1))
  cairo_move_to( cr, polar( g.x, g.y, value_angle, radius * 3/8 ))
  cairo_line_to( cr, polar( g.x, g.y, value_angle, radius * 3/4 ))
  cairo_stroke( cr )
  cairo_set_source_rgba (cr, colour(YELLOW,1))
  cairo_set_line_width (cr, 2)
  cairo_move_to( cr, polar( g.x, g.y, danger_angle, radius-4) )
  cairo_line_to( cr, polar( g.x, g.y, danger_angle, radius+4) )
  cairo_stroke( cr )
  text(cr, g.x+10, g.y+radius*1/4, g.value_text, 12, LIGHTBLUE, 1 )
  text(cr, g.x+10+radius, g.y, g.label, 16, WHITE, 1 )
end

function text( cr, x, y, text, size, text_color, text_alpha, font )
  font = "ECAMFontRegular"
  font_slant = CAIRO_FONT_SLANT_NORMAL
  font_face = CAIRO_FONT_WEIGHT_NORMAL

  cairo_select_font_face (cr, font, font_slant, font_face);
  cairo_set_font_size (cr, size)
  cairo_set_source_rgba (cr, colour(text_color,text_alpha))
  cairo_move_to (cr, x, y)
  cairo_show_text (cr, text)
  cairo_stroke (cr)
end
