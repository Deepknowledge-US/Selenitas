local colors = {}

-- From: https://flaviocopes.com/rgb-color-codes/

colors.color_table = {
	maroon                  = { 0.502 , 0 , 0 , 1 },
	dark_red                = { 0.545 , 0 , 0 , 1 },
	brown                   = { 0.647 , 0.165 , 0.165 , 1 },
	firebrick               = { 0.698 , 0.133 , 0.133 , 1 },
	crimson                 = { 0.863 , 0.078 , 0.235 , 1 },
	red                     = { 1 , 0 , 0 , 1 },
	tomato                  = { 1 , 0.388 , 0.278 , 1 },
	coral                   = { 1 , 0.498 , 0.314 , 1 },
	indian_red              = { 0.804 , 0.361 , 0.361 , 1 },
	light_coral             = { 0.941 , 0.502 , 0.502 , 1 },
	dark_salmon             = { 0.914 , 0.588 , 0.478 , 1 },
	salmon                  = { 0.98 , 0.502 , 0.447 , 1 },
	light_salmon            = { 1 , 0.627 , 0.478 , 1 },
	orange_red              = { 1 , 0.271 , 0 , 1 },
	dark_orange             = { 1 , 0.549 , 0 , 1 },
	orange                  = { 1 , 0.647 , 0 , 1 },
	gold                    = { 1 , 0.843 , 0 , 1 },
	dark_golden_rod         = { 0.722 , 0.525 , 0.043 , 1 },
	golden_rod              = { 0.855 , 0.647 , 0.125 , 1 },
	pale_golden_rod         = { 0.933 , 0.91 , 0.667 , 1 },
	dark_khaki              = { 0.741 , 0.718 , 0.42 , 1 },
	khaki                   = { 0.941 , 0.902 , 0.549 , 1 },
	olive                   = { 0.502 , 0.502 , 0 , 1 },
	yellow                  = { 1 , 1 , 0 , 1 },
	yellow_green            = { 0.604 , 0.804 , 0.196 , 1 },
	dark_olive_green        = { 0.333 , 0.42 , 0.184 , 1 },
	olive_drab              = { 0.42 , 0.557 , 0.137 , 1 },
	lawn_green              = { 0.486 , 0.988 , 0 , 1 },
	chart_reuse             = { 0.498 , 1 , 0 , 1 },
	green_yellow            = { 0.678 , 1 , 0.184 , 1 },
	dark_green              = { 0 , 0.392 , 0 , 1 },
	green                   = { 0 , 0.502 , 0 , 1 },
	forest_green            = { 0.133 , 0.545 , 0.133 , 1 },
	lime                    = { 0 , 1 , 0 , 1 },
	lime_green              = { 0.196 , 0.804 , 0.196 , 1 },
	light_green             = { 0.565 , 0.933 , 0.565 , 1 },
	pale_green              = { 0.596 , 0.984 , 0.596 , 1 },
	dark_sea_green          = { 0.561 , 0.737 , 0.561 , 1 },
	medium_spring_green     = { 0 , 0.98 , 0.604 , 1 },
	spring_green            = { 0 , 1 , 0.498 , 1 },
	sea_green               = { 0.18 , 0.545 , 0.341 , 1 },
	medium_aqua_marine      = { 0.4 , 0.804 , 0.667 , 1 },
	medium_sea_green        = { 0.235 , 0.702 , 0.443 , 1 },
	light_sea_green         = { 0.125 , 0.698 , 0.667 , 1 },
	dark_slate_gray         = { 0.184 , 0.31 , 0.31 , 1 },
	teal                    = { 0 , 0.502 , 0.502 , 1 },
	dark_cyan               = { 0 , 0.545 , 0.545 , 1 },
	aqua                    = { 0 , 1 , 1 , 1 },
	cyan                    = { 0 , 1 , 1 , 1 },
	light_cyan              = { 0.878 , 1 , 1 , 1 },
	dark_turquoise          = { 0 , 0.808 , 0.82 , 1 },
	turquoise               = { 0.251 , 0.878 , 0.816 , 1 },
	medium_turquoise        = { 0.282 , 0.82 , 0.8 , 1 },
	pale_turquoise          = { 0.686 , 0.933 , 0.933 , 1 },
	aqua_marine             = { 0.498 , 1 , 0.831 , 1 },
	powder_blue             = { 0.69 , 0.878 , 0.902 , 1 },
	cadet_blue              = { 0.373 , 0.62 , 0.627 , 1 },
	steel_blue              = { 0.275 , 0.51 , 0.706 , 1 },
	corn_flower_blue        = { 0.392 , 0.584 , 0.929 , 1 },
	deep_sky_blue           = { 0 , 0.749 , 1 , 1 },
	dodger_blue             = { 0.118 , 0.565 , 1 , 1 },
	light_blue              = { 0.678 , 0.847 , 0.902 , 1 },
	sky_blue                = { 0.529 , 0.808 , 0.922 , 1 },
	light_sky_blue          = { 0.529 , 0.808 , 0.98 , 1 },
	midnight_blue           = { 0.098 , 0.098 , 0.439 , 1 },
	navy                    = { 0 , 0 , 0.502 , 1 },
	dark_blue               = { 0 , 0 , 0.545 , 1 },
	medium_blue             = { 0 , 0 , 0.804 , 1 },
	blue                    = { 0 , 0 , 1 , 1 },
	royal_blue              = { 0.255 , 0.412 , 0.882 , 1 },
	blue_violet             = { 0.541 , 0.169 , 0.886 , 1 },
	indigo                  = { 0.294 , 0 , 0.51 , 1 },
	dark_slate_blue         = { 0.282 , 0.239 , 0.545 , 1 },
	slate_blue              = { 0.416 , 0.353 , 0.804 , 1 },
	medium_slate_blue       = { 0.482 , 0.408 , 0.933 , 1 },
	medium_purple           = { 0.576 , 0.439 , 0.859 , 1 },
	dark_magenta            = { 0.545 , 0 , 0.545 , 1 },
	dark_violet             = { 0.58 , 0 , 0.827 , 1 },
	dark_orchid             = { 0.6 , 0.196 , 0.8 , 1 },
	medium_orchid           = { 0.729 , 0.333 , 0.827 , 1 },
	purple                  = { 0.502 , 0 , 0.502 , 1 },
	thistle                 = { 0.847 , 0.749 , 0.847 , 1 },
	plum                    = { 0.867 , 0.627 , 0.867 , 1 },
	violet                  = { 0.933 , 0.51 , 0.933 , 1 },
	fuchsia                 = { 1 , 0 , 1 , 1 },
	magenta                 = { 1 , 0 , 1 , 1 },
	orchid                  = { 0.855 , 0.439 , 0.839 , 1 },
	medium_violet_red       = { 0.78 , 0.082 , 0.522 , 1 },
	pale_violet_red         = { 0.859 , 0.439 , 0.576 , 1 },
	deep_pink               = { 1 , 0.078 , 0.576 , 1 },
	hot_pink                = { 1 , 0.412 , 0.706 , 1 },
	light_pink              = { 1 , 0.714 , 0.757 , 1 },
	pink                    = { 1 , 0.753 , 0.796 , 1 },
	antique_white           = { 0.98 , 0.922 , 0.843 , 1 },
	beige                   = { 0.961 , 0.961 , 0.863 , 1 },
	bisque                  = { 1 , 0.894 , 0.769 , 1 },
	blanched_almond         = { 1 , 0.922 , 0.804 , 1 },
	wheat                   = { 0.961 , 0.871 , 0.702 , 1 },
	corn_silk               = { 1 , 0.973 , 0.863 , 1 },
	lemon_chiffon           = { 1 , 0.98 , 0.804 , 1 },
	light_golden_rod_yellow = { 0.98 , 0.98 , 0.824 , 1 },
	light_yellow            = { 1 , 1 , 0.878 , 1 },
	saddle_brown            = { 0.545 , 0.271 , 0.075 , 1 },
	sienna                  = { 0.627 , 0.322 , 0.176 , 1 },
	chocolate               = { 0.824 , 0.412 , 0.118 , 1 },
	peru                    = { 0.804 , 0.522 , 0.247 , 1 },
	sandy_brown             = { 0.957 , 0.643 , 0.376 , 1 },
	burly_wood              = { 0.871 , 0.722 , 0.529 , 1 },
	tan                     = { 0.824 , 0.706 , 0.549 , 1 },
	rosy_brown              = { 0.737 , 0.561 , 0.561 , 1 },
	moccasin                = { 1 , 0.894 , 0.71 , 1 },
	navajo_white            = { 1 , 0.871 , 0.678 , 1 },
	peach_puff              = { 1 , 0.855 , 0.725 , 1 },
	misty_rose              = { 1 , 0.894 , 0.882 , 1 },
	lavender_blush          = { 1 , 0.941 , 0.961 , 1 },
	linen                   = { 0.98 , 0.941 , 0.902 , 1 },
	old_lace                = { 0.992 , 0.961 , 0.902 , 1 },
	papaya_whip             = { 1 , 0.937 , 0.835 , 1 },
	sea_shell               = { 1 , 0.961 , 0.933 , 1 },
	mint_cream              = { 0.961 , 1 , 0.98 , 1 },
	slate_gray              = { 0.439 , 0.502 , 0.565 , 1 },
	light_slate_gray        = { 0.467 , 0.533 , 0.6 , 1 },
	light_steel_blue        = { 0.69 , 0.769 , 0.871 , 1 },
	lavender                = { 0.902 , 0.902 , 0.98 , 1 },
	floral_white            = { 1 , 0.98 , 0.941 , 1 },
	alice_blue              = { 0.941 , 0.973 , 1 , 1 },
	ghost_white             = { 0.973 , 0.973 , 1 , 1 },
	honeydew                = { 0.941 , 1 , 0.941 , 1 },
	ivory                   = { 1 , 1 , 0.941 , 1 },
	azure                   = { 0.941 , 1 , 1 , 1 },
	snow                    = { 1 , 0.98 , 0.98 , 1 },
	black                   = { 0 , 0 , 0 , 1 },
	dim_grey                = { 0.412 , 0.412 , 0.412 , 1 },
	dim_gray                = { 0.412 , 0.412 , 0.412 , 1 },
	grey                    = { 0.502 , 0.502 , 0.502 , 1 },
	gray                    = { 0.502 , 0.502 , 0.502 , 1 },
	dark_grey               = { 0.663 , 0.663 , 0.663 , 1 },
	dark_gray               = { 0.663 , 0.663 , 0.663 , 1 },
	silver                  = { 0.753 , 0.753 , 0.753 , 1 },
	light_grey              = { 0.827 , 0.827 , 0.827 , 1 },
	light_gray              = { 0.827 , 0.827 , 0.827 , 1 },
	gainsboro               = { 0.863 , 0.863 , 0.863 , 1 },
	white_smoke             = { 0.961 , 0.961 , 0.961 , 1 },
	white                   = { 1 , 1 , 1 , 1 }
}

colors.keys = {}
for k in pairs(colors.color_table) do table.insert(colors.keys, k) end

-- color returns a color from previous table. If an alpha value is
-- given, it is used as transparency (if not, defaut value is 1)
colors.color = function(color_name,alpha)
    ret = copy(colors.color_table[color_name])
    if alpha then ret[4]=alpha end
    return ret
end

colors.shade_of = function(col, ratio)
  local ext = ratio <= 0 and {0,0,0,1} or {1,1,1,1}
  local r = math.abs(ratio)
  local ret=copy(col)
  for i=1,3 do
    ret[i]=col[i]+r*(ext[i]-col[i])
  end
  return ret
end

colors.random_color = function (alpha)
    ret = colors.color(one_of(colors.keys))
    if alpha then ret[4]=alpha end
    return ret
end

return colors