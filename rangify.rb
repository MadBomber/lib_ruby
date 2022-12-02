# lib_ruby/rangify.rb

# convert and array of integers into an array of ranges.
def rangify(an_array)
  result = []
  list = an_array.sort.uniq

  prev = list[0]

  result = list.slice_before { |e|
    prev, prev2 = e, prev
    prev2 + 1 != e
  }.map{|b,*,c| c ? (b..c) : b }


  return result
end

def unrangify(an_array)
  result = []

  an_array.each do |entry|
    if entry.is_a?(Range)
      result << entry.to_a
    else
      result << entry
    end
  end

  return result.flatten
end

__END__


an_array = [
  152, 153, 154, 155, 158, 161, 162, 165, 178, 179,
  180, 181, 182, 185, 186, 187, 188, 194, 199, 206,
  220, 225, 226, 228, 229, 260, 263, 264, 267, 270,
  273, 276, 277, 280, 281, 284, 285, 292, 299, 351,
  352, 353, 354, 355, 356, 357, 358, 359, 360, 370,
  371, 372, 373, 374, 379, 380, 386, 401, 406, 407,
  408, 411, 422, 423, 426, 431, 432, 433, 453, 454,
  455, 456, 457, 458, 462, 463, 489, 490, 492, 493,
  494, 508, 509, 510, 513, 516, 517, 518, 519, 520,
  523, 540, 543, 544, 545, 551, 554, 555, 556, 557,
  558, 559, 563, 565, 568, 571, 572, 599, 600, 606,
  607, 608, 611, 612, 613, 614, 615, 616, 617, 618,
  621, 622, 623, 624, 627, 630, 634, 637, 640, 641,
  646, 649, 650, 651, 652, 655, 658, 659, 666, 667,
  668, 669, 670, 673,
]


fixed   = rangify(an_array)
unfixed = unrangify(fixed)

puts an_array == unfixed
