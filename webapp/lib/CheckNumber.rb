def sumOfNumber(number)
  sum = 0

  number.to_s.each_char do |item|
    sum += item.to_i
  end

  return sum
end
