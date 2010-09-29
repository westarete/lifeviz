class Float
  def be_close(match, delta=0.1)
    (self - match).abs < delta
  end
end

class Numeric
  def be_close(match, delta=0.1)
    (self - match).abs < delta
  end
end
